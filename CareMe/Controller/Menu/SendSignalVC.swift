//
//  SendSignalVC.swift
//  CareMe
//
//  Created by baytoor on 9/24/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Starscream

class SendSignalVC: UIViewController, WebSocketDelegate {

    @IBOutlet weak var btn: UIButton!
    
    var socket: WebSocket! = nil
    
    var kids: [Kid]?
    var kid: Kid?
    
    var kidID: Int = 0
    
    let jsonObject: Any  = [
        "action": "send_signal",
        "session_id": defaults.string(forKey: "sid") as Any,
        "kid_id": defaults.integer(forKey: "kidID0")
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
    }

}

// Functions
extension SendSignalVC {
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
    
    @IBAction func sendSignalBtnPressed() {
        sendJson(jsonObject) {}
    }
    
}

// Delegations
extension SendSignalVC {
    func websocketDidConnect(socket: WebSocketClient) {
        print("connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Answer from websocket\(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
