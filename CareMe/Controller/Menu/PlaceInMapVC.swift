//
//  PlaceInMapView.swift
//  CareMe
//

import UIKit
import Starscream
import YandexMapKit
import Foundation
import CoreLocation

class PlaceInMapVC: UIViewController, WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
       
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
      
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var radiusLbl: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var mapViewer: UIView!

    var socket: WebSocket! = nil
    var mapView: YMKMapView!
    var zoomLevel: Float = 15
    var currentCoordinate = YMKPoint(latitude: 43.243713, longitude: 76.918042)
    var georesult: String = ""
    var radius = 150.0
    var latitude = ""
    var longitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = YMKMapView()
        
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: currentCoordinate, zoom: zoomLevel, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
            cameraCallback: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = URL(string: "ws://195.93.152.96:11210")!
      
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
        
        uiStuffs()
        mapFunction()
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        let radius = Float(radiusSlider.value)
        let jsonPlaceAdd: Any = ["action": "save_place", "session_id": defaults.string(forKey: "sid")!, "kid_id": "0", "title": nameTF.text!, "latitude": latitude, "longitude": longitude, "radius": radius, "type": "0"]
        
        sendJson(jsonPlaceAdd) {
            print("MSG: Successfully sended")
            print(jsonPlaceAdd)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addressChange(_ sender: Any) {
        // получаем данные с геокодера
        let geoUrlString = "https://geocode-maps.yandex.ru/1.x/?apikey=5b0aee36-b638-4ec0-b1e2-6c112be39be3&format=json&geocode="
        let urlString = geoUrlString + addressTF.text!
        print(urlString)
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        guard let url = URL(string: encodedUrl!) else { return }
       
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            
            do {
                let geoObject = try JSONDecoder().decode(Json4Swift_Base.self, from: data)
                
                self.setPoint(crd: (geoObject.response?.geoObjectCollection?.featureMember![0].geoObject?.point?.pos)!)
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

// Functions
extension PlaceInMapVC {
    func uiStuffs() {
        radiusSlider.minimumValue = 0.1
        radiusSlider.setValue(0.1, animated: false)
        radiusLbl.text = "\(Int(radius)) m"
    }

    @IBAction func sliderMove(sender: UISlider) {
        radius = Double(sender.value * 1500)
        radiusLbl.text = "\(Int(radius)) m"
        setRadius()
    }
}

// Map functions
extension PlaceInMapVC {
//    func newMarkerView() -> UIView {

//        let backView: UIView = {
//            let bv = UIView()
//            bv.layer.masksToBounds = true
//            bv.autoSetDimensions(to: CGSize(width: 36, height: 45))
//            bv.backgroundColor = UIColor.clear
//            return bv
//        }()

//        let markerImg: UIImageView = {
//            let img = UIImage(named: "mapMarker")
//            let imgView = UIImageView(image: img)
//            imgView.clipsToBounds = true
//            imgView.autoSetDimensions(to: CGSize(width: 36, height: 45))
//            imgView.backgroundColor = UIColor.clear
//            return imgView
//        }()

//        backView.addSubview(markerImg)
//        return backView
//    }

//    func listLikelyPlaces() {
//        // Clean up from previous sessions.
//        likelyPlaces.removeAll()

//        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
//            if let error = error {
//                // TODO: Handle the error.
//                print("Current Place error: \(error.localizedDescription)")
//                return
//            }

//            // Get likely places and add to the list.
//            if let likelihoodList = placeLikelihoods {
//                for likelihood in likelihoodList.likelihoods {
//                    let place = likelihood.place
//                    self.likelyPlaces.append(place)
//                }
//            }
//        })
//        print(likelyPlaces)
//    }
    
    func setPoint(crd: String) {
        DispatchQueue.main.async {
            let crdArr = crd.components(separatedBy: " ")

            if let latitude: Double = Double(crdArr[1]), let longitude: Double = Double(crdArr[0]) {
                self.currentCoordinate = YMKPoint(latitude: latitude, longitude: longitude)
                
                let position = YMKCameraPosition(target: self.currentCoordinate, zoom: self.zoomLevel, azimuth: 0, tilt: 0)
                self.mapView.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3), cameraCallback: nil)
                
                let mapObjects = self.mapView.mapWindow.map.mapObjects
                let placemark = mapObjects.addPlacemark(with: YMKPoint(latitude: latitude, longitude: longitude))
            }
        }
    }
    
    func setRadius() {
//        self.mapView.clear()
//        setMarker()
//        let circ = GMSCircle(position: currentCoordinate, radius: CLLocationDistance(radius))
//        circ.fillColor = UIColor(red: 34/255, green: 193/255, blue: 195/255, alpha: 0.2)
//        circ.strokeColor = UIColor.clear
//        circ.strokeWidth = 0
//        circ.map = mapView
//        print("MSG Circle location \(currentCoordinate)")
    }

//    func setMarker() {
//        let marker = GMSMarker(position: currentCoordinate)
//        //Set child's photo
//        let newMarker = newMarkerView()
//        marker.iconView = newMarker
//        marker.map = mapView
//        print("MSG Marker location \(currentCoordinate)")
//    }

    func mapFunction() {
//    func mapFunction(_ location: CLLocationCoordinate2D) {
//
//        placesClient = GMSPlacesClient.shared()
//
//        camera = GMSCameraPosition.camera(withLatitude: location.latitude,
//                                          longitude: location.longitude,
//                                          zoom: 11,
//                                          bearing: 0,
//                                          viewingAngle: 0)
//
//        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
//        mapView.settings.myLocationButton = true
//        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        //mapView.isMyLocationEnabled = true

        // Add the map to the view, hide it until we've got a location update.
        mapViewer.addSubview(mapView)
        mapView.autoPinEdge(.bottom, to: .bottom, of: mapViewer)
        mapView.autoPinEdge(.top, to: .top, of: mapViewer)
        mapView.autoPinEdge(.right, to: .right, of: mapViewer)
        mapView.autoPinEdge(.left, to: .left, of: mapViewer)

//        if mapView.isHidden {
//            mapView.isHidden = false
//            mapView.camera = camera
//        } else {
//            mapView.animate(to: camera)
//        }
//        listLikelyPlaces()
    }
    
    func sendJson(_ value: Any, onSuccess: @escaping ()-> Void) {
        guard JSONSerialization.isValidJSONObject(value) else {
            print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
            
            return
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            
            if (socket.isConnected) {
                socket.write(data: data) {
                    print("MSG: Successfully sended")
                    onSuccess()
                }
            }
        } catch let error {
            print("[WEBSOCKET] Error serializing JSON:\n\(error)")
        }
    }
}
