//
//  HomeVC.swift
//  CareMe
//

import UIKit
import CTSlidingUpPanel
//import GoogleMaps
//import GooglePlaces
import PureLayout
import Starscream
import YandexMapKit
import Foundation
import CoreLocation

// Initializing and variables
class HomeVC: UIViewController, CTBottomSlideDelegate, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    @IBOutlet weak var mapMarker: UIView!
    @IBOutlet weak var mapViewer: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    var bottomController: CTBottomSlideController?;
    var homeBtnSelected: Bool = true
    var subscribeBtnSelected: Bool = false
    var chatBtnSelected: Bool = false
    var moreBtnSelected: Bool = false
    var settingsBtnSelected: Bool = false
    
    var socket: WebSocket! = nil
    var updateTimer: Timer!
    var isFirst: Bool = true
    var isFirstCentering: Bool = true
    
    var jsonObject: Any  = []
    var autoAuth: Any = [
            "action": "auth",
            "email": defaults.string(forKey: "email"),
            "password": defaults.string(forKey: "pwd")
        ]
    
    var kids: [Kid] = []
    var selectedKidIndex: Int = -1
    
    var tabBarIndex = 0
    
//    var camera = GMSCameraPosition()
//    var placesClient: GMSPlacesClient!
    var mapView: YMKMapView!
    var zoomLevel: Float = 15
    
//    var locationManager = CLLocationManager()
//    let location = CLLocationManager.location
//
//    var latitude: Double = location.coordinate.latitude
//    var longitude: Double = location.coordinate.longitude
    
//    var currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude)
    var currentCoordinate = YMKPoint(latitude: 43.243713, longitude: 76.918042)
//    var currentCoordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees.init(exactly: 43.243713)!,
//                                                        longitude: CLLocationDegrees.init(exactly: 76.918042)!)
    
    // An array to hold the list of likely places.
//    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
//    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiSettings()
        
        tabBarBtnPressed(homeBtn)
        tableView.delegate = self
        tableView.dataSource = self
        bottomController?.delegate = self
        
        mapView = YMKMapView()

        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: currentCoordinate, zoom: zoomLevel, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
            cameraCallback: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateInformation), userInfo: nil, repeats: true)
        
        UIApplication.shared.statusBarStyle = .default
        tabBarBtnPressed(homeBtn)
        chatBtn.imageView?.image = UIImage(named: "\(chatBtn.tag)Inactive")
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer.invalidate()
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
        
        mapFunction()
//        mapFunction(currentCoordinate, isFirst)
    }
}

// Map functions
extension HomeVC {
    @IBAction func zoomIn(_ sender: Any) {
        zoomLevel = zoomLevel + 1
        
        let position = YMKCameraPosition(target: currentCoordinate, zoom: zoomLevel, azimuth: 0, tilt: 0)
        mapView.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3), cameraCallback: nil)
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        zoomLevel = zoomLevel - 1
        
        let position = YMKCameraPosition(target: currentCoordinate, zoom: zoomLevel, azimuth: 0, tilt: 0)
        mapView.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3), cameraCallback: nil)
    }
    
    @IBAction func centerMap(_ sender: Any) {
        if kids.count > 0 {
            selectedKidIndex = selectedKidIndex + 1
            
            if (selectedKidIndex >= kids.count) {
                selectedKidIndex = 0
            }
            
            if let latitude: Double = Double(kids[selectedKidIndex].kidInfo.latitude), let longitude: Double = Double(kids[selectedKidIndex].kidInfo.longitude) {
                currentCoordinate = YMKPoint(latitude: latitude, longitude: longitude)
                
                let position = YMKCameraPosition(target: currentCoordinate, zoom: zoomLevel, azimuth: 0, tilt: 0)
                mapView.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3), cameraCallback: nil)
            }
        }
    }
    
    func listLikelyPlaces() {
        // Clean up from previous sessions.
//        likelyPlaces.removeAll()
//
//        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
//            if let error = error {
//                // TODO: Handle the error.
//                print("Current Place error: \(error.localizedDescription)")
//                return
//            }
//
//            // Get likely places and add to the list.
//            if let likelihoodList = placeLikelihoods {
//                for likelihood in likelihoodList.likelihoods {
//                    let place = likelihood.place
//                    self.likelyPlaces.append(place)
//                }
//            }
//        })
//        print(likelyPlaces)
    }
    
//    ========================= Map repairing
    
//    func setRadius(_ coordinate: CLLocationCoordinate2D,_ accuracy: Double) {
//        let circ = GMSCircle(position: coordinate, radius: CLLocationDistance(accuracy))
//        circ.fillColor = UIColor(red: 34/255, green: 193/255, blue: 195/255, alpha: 0.2)
//        circ.strokeColor = UIColor.clear
//        circ.strokeWidth = 0
//        circ.map = mapView
//    }
    
    func setChildMarker(_ kid: Kid) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        let latitude: Double = Double(kid.kidInfo.latitude)!
        let longitude: Double = Double(kid.kidInfo.longitude)!
        let placemark = mapObjects.addPlacemark(with: YMKPoint(latitude: latitude, longitude: longitude))

        placemark.isDraggable = true
        placemark.setIconWith(UIImage(named: "\(kid.imgUrlString)")!)
    }
    
    func putKidsToMap() {
        for kid in kids {
            if let _: Double = Double(kid.kidInfo.latitude), let _: Double = Double(kid.kidInfo.longitude) {
                setChildMarker(kid)
            }
        }
    }
    
    func mapFunction() {
//    func mapFunction(_ location: CLLocationCoordinate2D,_ isfirst: Bool) {
    
//        var zoom:Float = zoomLevel
//        var viewingAngle:Double = 0
//        var bearing:CLLocationDirection = CLLocationDirection(exactly: 0)!
//
//        if isFirst {
//            isFirst = false
//            zoom = zoomLevel
//            viewingAngle = 0
//            bearing = 0
//        } else {
//            zoom = mapView.camera.zoom
//            viewingAngle = mapView.camera.viewingAngle
//            bearing = mapView.camera.bearing
//        }
//
//        placesClient = GMSPlacesClient.shared()
//
//        camera = GMSCameraPosition.camera(withLatitude: location.latitude,
//                                          longitude: location.longitude,
//                                          zoom: zoom,
//                                          bearing: bearing,
//                                          viewingAngle: viewingAngle)
//
//        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
//        mapView.settings.myLocationButton = true
//        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        //mapView.isMyLocationEnabled = true
//
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
}

//Functions
extension HomeVC {
    func uiSettings() {
        bottomController = CTBottomSlideController(parent: view, bottomView: bottomView, tabController: nil, navController: nil, visibleHeight: 99)

        bottomController?.setExpandedTopMargin(pixels: 64)
        bottomController?.set(table: tableView)
        bottomController?.setAnchorPoint(anchor: CGFloat(0))

        bottomView.bounds.size.width = self.view.frame.width
        tableView.bounds.size.width = self.view.frame.width

        bottomView.roundCorners([.topLeft, .topRight], radius: 20)
        tableView.roundCorners([.topLeft, .topRight], radius: 20)

        addLineToView(view: tabBarView, position: .top, color: UIColor(hex: lightGrey), width: 0.5)

        tableView.autoPinEdge(.leading, to: .leading, of: bottomView)
        tableView.autoPinEdge(.trailing, to: .trailing, of: bottomView)
        tableView.autoPinEdge(.top, to: .top, of: bottomView)
        tableView.autoPinEdge(.bottom, to: .bottom, of: bottomView)
    }
    
    func tabBarColor(_ btn: UIButton) {
        let tag = btn.tag

        homeBtn.imageView?.image = UIImage(named: "\(homeBtn.tag)Inactive")
        subscribeBtn.imageView?.image = UIImage(named: "\(subscribeBtn.tag)Inactive")
        chatBtn.imageView?.image = UIImage(named: "\(chatBtn.tag)Inactive")
        moreBtn.imageView?.image = UIImage(named: "\(moreBtn.tag)Inactive")
        settingsBtn.imageView?.image = UIImage(named: "\(settingsBtn.tag)Inactive")

        if (tag == 5) {
            moreBtn.imageView?.image = UIImage(named: "\(moreBtn.tag)Active")
        } else if (tag != 2) {
            btn.imageView?.image = UIImage(named: "\(tag)Active")
        }
    }
    
    @IBAction func tabBarBtnPressed(_ sender: UIButton) {
        tabBarIndex = sender.tag
        tabBarColor(sender)
        
        // Setting height of contentView
        if (tabBarIndex == 0) {
            var anchor: Int {
                if kids.count > 0 {
                    return 99 + kids.count * 70
                } else {
                    return 99 + 70
                }
            }

            bottomController?.setAnchorPoint(anchor: CGFloat(anchor) / self.view.bounds.height)
            bottomController?.anchorPanel()
        } else if (tabBarIndex == 1) {
            bottomController?.setAnchorPoint(anchor: CGFloat(self.view.bounds.height-64) / self.view.bounds.height)
            bottomController?.closePanel()
            bottomController?.expandPanel()
        } else if (tabBarIndex == 2) {
            chatBtnPressed(sender)
        } else if (tabBarIndex == 3) {
            // Change the height of more functions 140/250 ToChange
            bottomController?.setAnchorPoint(anchor: CGFloat(99+140) / self.view.bounds.height)
            bottomController?.closePanel()
            bottomController?.anchorPanel()
        } else if (tabBarIndex == 4) {
//            bottomController?.setAnchorPoint(anchor: CGFloat(self.view.bounds.height-64) / self.view.bounds.height)
            bottomController?.setAnchorPoint(anchor: CGFloat(99) / self.view.bounds.height)
            bottomController?.closePanel()
            bottomController?.anchorPanel()
        } else if (tabBarIndex == 5) {
            // Settings of places instead of kids ToChange
            var anchor: Int {
                if kids.count > 0 {
                    return 99 + kids.count * 70
                } else {
                    return 99 + 70
                }
            }

            bottomController?.setAnchorPoint(anchor: CGFloat(anchor) / self.view.bounds.height)
            bottomController?.anchorPanel()
        }

        tableView.reloadData()
    }
    
    func chatBtnPressed(_ sender: Any) {
        if (kids.count > 1) {
            performSegue(withIdentifier: "ListOfChatsVCSegue", sender: self)
        } else if (kids.count == 1) {
            performSegue(withIdentifier: "ChatVCSegue", sender: self)
        } else {
            // trigger to wait or that he hasn't kid
        }
    }
    
    @IBAction func callCenterBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "CallCenterVCSegue", sender: self)
    }
    
    @IBAction func soundAroundBtnPressed (_ sender: Any) {
        performSegue(withIdentifier: "SoundAroundVCSegue", sender: self)
    }
    
    @IBAction func sendSignalBtnPressed (_ sender: Any) {
        performSegue(withIdentifier: "SendSignalVCSegue", sender: self)
    }
    
    @IBAction func headerBtnPressed() {
        if (tabBarIndex == 0) {
            updateInformation()
        } else if (tabBarIndex == 5) {
            print("MSG Adding ")
            performSegue(withIdentifier: "PlaceInMapVCSegue", sender: self)
        }
    }
    
    @IBAction func signOutBtnPressed() {
        signOut()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialPage")
        self.show(vc!, sender: self)
    }
    
    @objc func updateInformation() {
        if (socket.isConnected) {
            if (defaults.string(forKey: "kidID0") != nil) {
                kidsListRequest()
            }
        } else {
            socket.connect()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (tabBarIndex == 0 &&
            ((tableView.indexPathForSelectedRow?.row)! > 0 && (tableView.indexPathForSelectedRow?.row)! <= kids.count)) {
            let destination = segue.destination as! ChildVC
            destination.kid = kids[(tableView.indexPathForSelectedRow?.row)! - 1]
        } else if (tabBarIndex == 2 && kids.count > 1) {
            let destination = segue.destination as! ListOfChatsVC
            destination.kids = self.kids
        }
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
    
    func kidsListParse(_ jsonObject: NSDictionary) {
        let count = jsonObject.count - 1
        print("Kid count: \(count)")
        defaults.set(count, forKey: "kidCount")

        kids.removeAll()

        for i in 0..<count {
            let kid = jsonObject["\(i)"] as? NSDictionary
            let kidID = kid!["id"] as? String
            defaults.set(kidID, forKey: "kidID\(i)")

            let name = kid!["name"] as? String
            let surname = kid!["lastname"] as? String

            print("Kid id: \(kidID!)")

            var time = kid!["date"] as? String
            let latitude = kid!["latitude"] as? String
            let longitude = kid!["longitude"] as? String
            let batteryState = kid!["batteryState"] as? String
            let batteryLevel = kid!["batteryLevel"] as? String
            let course = kid!["course"] as? String
            let accuracy = kid!["accuracy"] as? String
//            let avatar = kid!["avatar"] as? String

            if (latitude == "") {
                time = "Данные не доступны"
            } else {
                time = "Данные получены 3 минуты назад"
            }

            let newKidInfo = KidInfo(kidID!, batteryLevel!, batteryState!, longitude! , latitude!, course!, time!, accuracy!)

            let newKid = Kid(kidID!, name!, surname!, "OvalMini", newKidInfo)
            kids.append(newKid)
        }
        
        putKidsToMap()
        tableView.reloadData()
        
        if (isFirstCentering) {
            isFirstCentering = false
            centerMap(self)
        }
    }
    
    func authParse(_ jsonObject: NSDictionary) {
        if let sid = jsonObject["sid"] as? String {
            defaults.set(sid, forKey: "sid")
        }
    }
    
    func kidsListRequest () {
        if (defaults.string(forKey: "kidID0") != nil) {
            let jsonKidsList: Any = ["action": "kids_list", "session_id": defaults.string(forKey: "sid")!]
            
            sendJson(jsonKidsList) {
                print("MSG: Successfully sended")
                print(jsonKidsList)
            }
        }
    }
}

// Websocket Delegate
extension HomeVC {
    func websocketDidConnect(socket: WebSocketClient) {
        sendJson(autoAuth) {
            print(self.autoAuth)
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {

    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Answer from websocket\(text)")
        
        do {
            let data = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary

            if let action = jsonObject?["action"] as? String {
                if (action == "kids_list") {
                    kidsListParse(jsonObject!)
                } else if (action == "auth") {
                    self.authParse(jsonObject!)
                    kidsListRequest()
                }
            }
        } catch let error as NSError {
            print("MSG: json error \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}

//Table View Delegates and DataSources
extension HomeVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tabBarIndex == 0) {
            return kids.count + 2
            // HTC Else if tabBarIndex others must be here
        } else if (tabBarIndex == 1) {
            // Settings
            return 2
        } else if (tabBarIndex == 3) {
            // More functions
            return 2
        } else if (tabBarIndex == 4) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // HeaderCell Identification
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! headerCell
            cell.setHeader(tabBarIndex)
            
            return cell
        }
        
        if (tabBarIndex == 0) {
            // ChildTabBar Identification
            if (indexPath.row == kids.count + 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addKidCell", for: indexPath) as! addKidCell
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "kidCell", for: indexPath) as! kidCell
                let kid = kids[indexPath.row - 1]
                cell.setKid(kid)
                
                return cell
            }
        } else if (tabBarIndex == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repairCell", for: indexPath) as! repairCell
            
            return cell
        } else if (tabBarIndex == 3 && indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "moreFunctionsCell", for: indexPath) as! moreFunctionsCell
            
            return cell
            // HTC Else if tabBarIndex others must be here
        } else if (tabBarIndex == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! settingsCell
            
            return cell
        } else if (tabBarIndex == 5) {
            return UITableViewCell()
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 50
            // HTC Else if tabBarIndex others must be here
        } else if (tabBarIndex == 3 && indexPath.row == 1) {
            // Change the height of more functions 140/240 ToChange
            return 140
        } else if (tabBarIndex == 1 || tabBarIndex == 4) {
            return CGFloat(self.view.bounds.height - 180)
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tabBarIndex == 0) {
            if (indexPath.row > 0 && indexPath.row <= kids.count) {
                performSegue(withIdentifier: "ChildVCSegue", sender: self)
            } else if (indexPath.row == kids.count + 1) {
                performSegue(withIdentifier: "NewChildVCSegue", sender: self)
                
                print("MSG: Adding child")
            }
        } else if (tabBarIndex == 3) {

        }
    }
    
    func didPanelCollapse() {
        
    }
    
    func didPanelExpand() {
        
    }
    
    func didPanelAnchor() {
        
    }
    
    func didPanelMove(panelOffset: CGFloat) {
        
    }
}
