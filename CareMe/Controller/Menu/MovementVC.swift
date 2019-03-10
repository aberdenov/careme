//
//  MovementVC.swift
//  CareMe
//
//  Created by baytoor on 9/24/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
//import MapKit
//import GoogleMaps
//import GooglePlaces
//import Starscream

class MovementVC: UIViewController/*, WebSocketDelegate*/ {
    
    var kids: [Kid]?
    var kid: Kid?

    @IBOutlet weak var mapMarker: UIView!
//
//    var socket: WebSocket! = nil
//
//    var jsonObject: Any  = []
//
//    var mapView: GMSMapView!
//    var placesClient: GMSPlacesClient!
//    var zoomLevel: Float = 15.0
//
//    var lastLoc = CLLocation()
//    let lastCoordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees.init(exactly: 43.243703)!,
//                                                     longitude: CLLocationDegrees.init(exactly: 76.918052)!)
//
//    // An array to hold the list of likely places.
//    var likelyPlaces: [GMSPlace] = []
//
//    // The currently selected place.
//    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setMap()
//        let url = URL(string: "ws://195.93.152.96:11210")!
//        socket = WebSocket(url: url)
//        socket.delegate = self
//        socket.connect()
//    }
//
//    func setMap() {
//        let camera = GMSCameraPosition.camera(withLatitude: lastCoordinate.latitude,
//                                              longitude: lastCoordinate.longitude,
//                                              zoom: zoomLevel)
//
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: lastCoordinate.latitude,
//                                                 longitude: lastCoordinate.longitude)
//        marker.iconView = mapMarker
//        marker.map = mapView
//
//        if mapView.isHidden {
//            mapView.isHidden = false
//            mapView.camera = camera
//        } else {
//            mapView.animate(to: camera)
//        }
//
//        listLikelyPlaces()
//
//    }
//
//    func listLikelyPlaces() {
//        // Clean up from previous sessions.
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
//    }
//
//    func sendJson(_ value: Any, onSuccess: @escaping ()-> Void) {
//        guard JSONSerialization.isValidJSONObject(value) else {
//            print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
//            return
//        }
//        do {
//            let data = try JSONSerialization.data(withJSONObject: value, options: [])
//            if socket.isConnected {
//                socket.write(data: data) {
//                    print("MSG: Successfully sended")
//                    onSuccess()
//                }
//            }
//        } catch let error {
//            print("[WEBSOCKET] Error serializing JSON:\n\(error)")
//        }
//    }
//
//}
//
////Websocket Delegate
//extension MovementVC {
//    func websocketDidConnect(socket: WebSocketClient) {
//        print("connected")
//    }
//
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        print("disconnected")
//    }
//
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        print("MSG:\(text)")
//        do {
////            let data = text.data(using: .utf8)!
////            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
//
//
//        } catch let error as NSError {
//            print("MSG: json error \(error)")
//        }
//
//    }
//
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//
//    }

}
