//
//  ViewController.swift
//  CareMe
//
//  Created by baytoor on 9/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Starscream
import SwiftKeychainWrapper

class LoginVC: UIViewController, UITextFieldDelegate, WebSocketDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    
    var socket: WebSocket! = nil
    
    var jsonObject: Any  = []
    
    let role = defaults.string(forKey: "role")
    
    var action: String {
        if role == "parent" {
            return "auth"
        } else {
            return "auth_kid"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiStuffs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorLbl.isHidden = true
        emailTF.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    
}

//Functions
extension LoginVC {
    func uiStuffs() {
        addLineToView(view: emailTF, position: .bottom, color: UIColor.init(hex: navy), width: 1)
        addLineToView(view: passwordTF, position: .bottom, color: UIColor.init(hex: navy), width: 1)
        
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    func sendJson(_ value: Any, onSuccess: @escaping ()-> Void) {
        guard JSONSerialization.isValidJSONObject(value) else {
            print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            if socket.isConnected {
                errorWithText("nil")
                socket.write(data: data) {
                    print("MSG: Successfully sended")
                    onSuccess()
                }
            }
        } catch let error {
            print("[WEBSOCKET] Error serializing JSON:\n\(error)")
        }
    }
    //Sending log in information to web socket
    @IBAction func loginBtnPressed (_ sender: Any) {
        if getData() {
            sendJson(jsonObject) {
                print("MSG: Succesfully sended to websocket")
            }
            if !socket.isConnected {
                socket.connect()
            }
        }
    }
    //Setting all info from tf to JSON format
    func getData() -> Bool {
        if isNotEmptyTF() {
            jsonObject = [
                "action": action,
                "email": "\((emailTF.text)!)",
                "password": "\((passwordTF.text)!)"
            ]
            defaults.set(emailTF.text, forKey: "email")
            defaults.set(passwordTF.text, forKey: "pwd")
            return true
        }
        return false
    }
    //Checking if all textfield are filled
    func isNotEmptyTF() -> Bool {
        if emailTF.text == nil {
            return false
        }
        if passwordTF.text == nil {
            return false
        }
        return true
    }
    
    func errorWithText(_ err: String) {
        
        if err == "nil" {
            errorLbl.isHidden = true
        } else {
            errorLbl.text = err
            errorLbl.isHidden = false
        }
    }
    
    func authParse(_ jsonObject: NSDictionary) {
        if let sid = jsonObject["sid"] as? String {
            defaults.set(sid, forKey: "sid")
            let saveSuccessful: Bool = KeychainWrapper.standard.set(sid, forKey: keyUID)
            if saveSuccessful {
                print("MSG: Data saved to keychain")
            }
        }
        if let userID = jsonObject["id"] as? String {
            defaults.set(Int(userID), forKey: "uid")
        }
        if let role = jsonObject["role"] as? Int {
            if role == 0 {
                let kids_list = [
                    "action": "kids_list",
                    "session_id": defaults.string(forKey: "sid")!
                ]
                sendJson(kids_list) {}
            }
        }
    }
    
    func authKidParse(_ jsonObject: NSDictionary) {
        if let sid = jsonObject["sid"] as? String {
            print(sid)
            defaults.set(sid, forKey: "sid")
            let saveSuccessful: Bool = KeychainWrapper.standard.set(sid, forKey: keyUID)
            if saveSuccessful {
                print("MSG: Data saved to keychain")
            }
        }
        if let userID = jsonObject["id"] as? String {
            defaults.set(Int(userID), forKey: "uid")
        }
        if let role = jsonObject["role"] as? Int {
            if role == 1 {
                print(role)
                let check_code_kid = [
                    "action": "check_code_kid",
                    "kid_session_id": defaults.string(forKey: "sid")!
                ]
                sendJson(check_code_kid) {}
            }
        }
    }
    
    func kidsListParse(_ jsonObject: NSDictionary) {
        //Todo
        
        let count = jsonObject.count-1
        print("Kid count: \(count)")
        defaults.set(count, forKey: "kidCount")
        
        for i in 0..<count {
            let kid = jsonObject["\(i)"] as? NSDictionary
            let kidID = kid!["id"]
            defaults.set(kidID, forKey: "kidID\(i)")
            print("Kid id: \(kidID!)")
        }
        
        
        if count == 0 {
            performSegue(withIdentifier: "NewChildVCSegue", sender: self)
        } else {
            performSegue(withIdentifier: "MenuVCSegue", sender: self)
        }
    }
    
    func kidStatusCheck(_ jsonObject: NSDictionary) {
        if let active = jsonObject["active"] as? String{
            if let parentID = jsonObject["parent_id"] as? String {
                defaults.set(Int(parentID), forKey: "parentID")
            }
            if Int(active) == 1 {
                performSegue(withIdentifier: "ChildMenuVCSegue", sender: self)
            } else {
                performSegue(withIdentifier: "ChildActivateVCSegue", sender: self)
            }
        }
    }
    
}

//Delegations
extension LoginVC {
    func websocketDidConnect(socket: WebSocketClient) {
        print("connected")
        errorWithText("nil")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("disconnected")
        errorWithText("Unable to connect to server")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Answer from websocket\(text)")
        do {
            let data = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            
            if let err = jsonObject?["error"] as? String {
                self.errorWithText(err)
            }
            
            if let action = jsonObject?["action"] as? String {
//                print(action)
                if action == "auth" {
                    authParse(jsonObject!)
                } else if action == "auth_kid" {
                    authKidParse(jsonObject!)
                } else if action == "kids_list" {
                    kidsListParse(jsonObject!)
                } else if action == "check_code_kid" {
                    kidStatusCheck(jsonObject!)
                }
            }
            
            
        } catch let error as NSError {
            print("MSG: json error \(error)")
        }

    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTF:
            passwordTF.becomeFirstResponder()
            break
        case passwordTF:
            passwordTF.resignFirstResponder()
            loginBtnPressed(self)
            break
        default:
            emailTF.resignFirstResponder()
            view.endEditing(true)
            break
        }
        return true
    }
}
