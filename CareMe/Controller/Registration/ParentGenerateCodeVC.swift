//
//  ParentVC.swift
//  CareMe
//
//  Created by baytoor on 9/14/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Starscream

class ParentGenerateCodeVC: UIViewController, WebSocketDelegate {

    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var thirdLbl: UILabel!
    @IBOutlet weak var fourthLbl: UILabel!
    
    var socket: WebSocket! = nil
    
//    var newKidID: Int?
    
    let jsonObject: Any  = [
        "action": "generate_code",
        "session_id": defaults.string(forKey: "sid")!,
        "kid_id": defaults.integer(forKey: "kidID\(defaults.integer(forKey: "kidCount"))")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiStuffs()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(jsonObject)
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
    }
    
    func uiStuffs() {
        
        addLineToView(view: firstLbl, position: .bottom, color: UIColor.init(hex: navy), width: 2)
        addLineToView(view: secondLbl, position: .bottom, color: UIColor.init(hex: navy), width: 2)
        addLineToView(view: thirdLbl, position: .bottom, color: UIColor.init(hex: navy), width: 2)
        addLineToView(view: fourthLbl, position: .bottom, color: UIColor.init(hex: navy), width: 2)
        
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
    
    @IBAction func nextPage() {
        performSegue(withIdentifier: "MainVCSegue", sender: self)
    }
    
    

}

//Delegations
extension ParentGenerateCodeVC {
    func websocketDidConnect(socket: WebSocketClient) {
        print("connected")
        sendJson(jsonObject) {}
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Answer from websocket\(text)")
        do {
            let data = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            
            if let code = jsonObject?["code"] as? String {
                firstLbl.text = code[0]
                secondLbl.text = code[1]
                thirdLbl.text = code[2]
                fourthLbl.text = code[3]
            }
            
            if text.lowercased().range(of:"new") != nil {
                self.sendJson(self.jsonObject) {}
            }
            
        } catch let error as NSError {
            print("MSG: json error \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
