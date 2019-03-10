//
//  ChildMenuVC.swift
//  CareMe
//
//  Created by baytoor on 10/10/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import MapKit
import Starscream
import AVFoundation

class ChildMenuVC: UIViewController, CLLocationManagerDelegate, WebSocketDelegate {
    
    @IBOutlet weak var signOutBtn: UIButton!
    
    let role = defaults.string(forKey: "role")
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var socket: WebSocket! = nil
    
    var jsonObject: Any  = []
    
    let autoAuth: Any = [
        "action": "auth_kid",
        "email": defaults.string(forKey: "email"),
        "password": defaults.string(forKey: "pwd")
    ]
    
    var lastLoc = CLLocation()
    
    var loudSound: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        locationManager = CLLocationManager()        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
        
        let path = Bundle.main.path(forResource: "alert", ofType: "wav")
        let soundURL = URL(fileURLWithPath: path!)
        do{
            try loudSound = AVAudioPlayer(contentsOf: soundURL)
            loudSound.prepareToPlay()
        } catch let err as NSError{
            print(err.debugDescription)
        }
        //Todo
//        signOutBtn.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = locationAuthStatus()
        if !socket.isConnected {
            socket.connect()
        }
    }
    
}

// Functions
extension ChildMenuVC {
    
    @IBAction func chatBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "ChatVCSegue", sender: self)
    }
    
    @IBAction func sosBtnPressed(_ sender: Any) {
        let url = URL(string: "tel://87019329919")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
//        alert(title: "SOS", message: "Подтвердите действие")
//        loudSignal()
    }
    
    func loudSignal() {
        loudSound.play()
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let alertCancel = UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil)
        let alertAction = UIAlertAction.init(title: "Подтвердить", style: .default) { (UIAlertAction) in
            //SOS btn action
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func getData(_ location: CLLocation, complition: (() -> Void)!) {
        let batteryLevel = Int (UIDevice.current.batteryLevel * 100)
        var batteryState: String {
            switch UIDevice.current.batteryState {
            case .charging:
                return "Charging"
            case .full:
                return "Full"
            case .unknown:
                return "Unknown"
            case .unplugged:
                return "Unplugged"
            default:
                return ""
            }
        }
        
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        let course = location.course
        let speed = location.speed
        let time = location.timestamp
        var accuracy: CLLocationAccuracy {
            if location.horizontalAccuracy>location.verticalAccuracy {
                return location.horizontalAccuracy
            } else {
                return location.verticalAccuracy
            }
        }
        
        jsonObject = [
            "action": "send_geo",
            "session_id": "\(defaults.string(forKey: "sid")!)",
            "batteryLevel": "\(batteryLevel)",
            "batteryState": "\(batteryState)",
            "longitude": "\(longitude)",
            "latitude": "\(latitude)",
            "course": "\(course)",
            "speed": "\(speed)",
            "time": "\(time)",
            "accuracy": "\(accuracy)"
        ]
        
        print(self.jsonObject)
        
        self.sendJson(self.jsonObject, onSuccess: {})
        complition()
    }
    
    func locationAuthStatus() -> Bool {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            return true
        } else {
            locationManager.requestAlwaysAuthorization()
            return false
        }
    }
    
    func sendJson(_ value: Any, onSuccess: @escaping ()-> Void) {
        guard JSONSerialization.isValidJSONObject(value) else {
            print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            if socket.isConnected {
                socket.write(data: data) {
                    print("MSG: Successfully sended")
                    onSuccess()
                }
                
            }
        } catch let error {
            print("[WEBSOCKET] Error serializing JSON:\n\(error)")
        }
    }
    
    func kidStatusCheck(_ jsonObject: NSDictionary) {
        let msg = jsonObject["msg"] as? String
        if msg == "No kid" {
            signOutBtnPressed()
        } else {
            if self.locationAuthStatus() {
                self.getData(self.locationManager.location!) {}
            }
        }
    }
    
    func sendSignalHandler(_ jsonObject: NSDictionary) {
        let kidIDFromJson = (jsonObject["kid_id"])! as? Int
        if kidIDFromJson == defaults.integer(forKey: "uid") {
            
        }
        loudSignal()
    }
    
    @IBAction func signOutBtnPressed() {
        signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialPage")
        self.show(vc!, sender: self)
    }
    
    func authParse(_ jsonObject: NSDictionary) {
        if let sid = jsonObject["sid"] as? String {
            defaults.set(sid, forKey: "sid")
        }
    }
    
    func checkKidRequest() {
        let jsonCheckKid: Any = [
            "action": "check_kid",
            "kid_session_id": defaults.string(forKey: "sid")!
        ]
        sendJson(jsonCheckKid) {
            print(jsonCheckKid)
        }
    }
    
}

// Delegates
extension ChildMenuVC {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        getData(location) {}
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("connected")
        sendJson(autoAuth) {}
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Answer from websocket\(text)")
        do {
            let data = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            
            if let action = jsonObject?["action"] as? String {
                if action == "check_kid" {
                    kidStatusCheck(jsonObject!)
                } else if action == "send_signal" {
                    print(action)
                    sendSignalHandler(jsonObject!)
                } else if action == "auth_kid" {
                    authParse(jsonObject!)
                    checkKidRequest()
                }
            }
            
        } catch let error as NSError {
            print("MSG: json error \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
