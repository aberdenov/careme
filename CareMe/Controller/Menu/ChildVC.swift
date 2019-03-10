//
//  ChildVC.swift
//  CareMe
//
//  Created by baytoor on 9/20/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Starscream

class ChildVC: UIViewController, WebSocketDelegate {
    
    var kid: Kid? = nil
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var barBtn: UIBarButtonItem!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var surnameView: UIView!
    @IBOutlet weak var removeChildBtn: UIButton!
    @IBOutlet weak var noImgView: UIView!
    @IBOutlet weak var noImgLbl: UILabel!
    
    var socket: WebSocket! = nil

    var jsonObject: Any  = []
    
    var kidID: Int = 0
    var isEditingMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiStuffs()
        
        if kid != nil {
            kidID = Int((kid?.kidID)!)!
            nameTF.text = kid!.name
            surnameTF.text = kid!.surname
            imgView.image = UIImage(named: kid!.imgUrlString)
            noImgLbl.text = kid?.name[0..<2]
            
            if kid?.imgUrlString == "" {
                imgView.isHidden = true
                noImgView.isHidden = false
            } else {
                imgView.isHidden = false
                noImgView.isHidden = true
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
    }
    

}

//Functions
extension ChildVC {
    
    func uiStuffs() {
        isEditingMode = false
        setEditingMode()
        nameTF.layer.borderColor = UIColor(hex: green).cgColor
        surnameTF.layer.borderColor = UIColor(hex: green).cgColor
        noImgView.layer.cornerRadius = noImgView.bounds.height/2
        noImgView.layer.borderColor = UIColor(hex: navy).cgColor
        noImgView.layer.borderWidth = 1.5
    }
    
    @IBAction func addPlaceBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "PlaceInMapVCSegue", sender: self)
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
    
    @IBAction func editModeBtnPressed(_ sender: Any) {
        if isEditingMode {
            isEditingMode = false
            saveData()
            view.endEditing(true)
        } else {
            isEditingMode = true
        }
        setEditingMode()
    }
    
    func setEditingMode() {
        if isEditingMode {
            barBtn.title = "Done"
            nameTF.isEnabled = true
            surnameTF.isEnabled = true
            nameTF.borderStyle = .line
            surnameTF.borderStyle = .line
            removeChildBtn.isHidden = false
        } else {
            removeChildBtn.isHidden = true
            barBtn.title = "Edit"
            nameTF.isEnabled = false
            surnameTF.isEnabled = false
            nameTF.borderStyle = .none
            surnameTF.borderStyle = .none
        }
    }
    
    func isNotEmptyTF() -> Bool {
        if nameTF.text == nil {
            return false
        }
        if surnameTF.text == nil {
            return false
        }
        return true
    }
    
    func saveData() {
        if isNotEmptyTF() {
            if socket.isConnected {
                jsonObject = [
                    "action": "edit_kid",
                    "kid": kidID,
                    "name": nameTF.text!,
                    "lastname": surnameTF.text!,
                    "avatar": ""
                ]
                print(jsonObject)
                sendJson(jsonObject) {
                    //Is not enable to change
                }
            
            } else {
                socket.connect()
            }
            
        }
    }
    
    @IBAction func removeChildBtnPressed() {
        let jsonObject: Any = [
            "action": "delete_kid",
            "kid_id": kidID,
            "session_id": defaults.string(forKey: "sid")!
        ]
        sendJson(jsonObject) {}
        
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
    
}

//Websocket Delegate
extension ChildVC {
    func websocketDidConnect(socket: WebSocketClient) {
        print("connected")
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
                if action == "delete_kid" {
                    _ = navigationController?.popViewController(animated: true)
                }
            }

        } catch let error as NSError {
            print("MSG: json error \(error)")
        }

    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {

    }
}
