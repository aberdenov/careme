//
//  RegisterVC.swift
//  CareMe
//
//  Created by baytoor on 9/24/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Starscream

class RegisterVC: UIViewController, UITextFieldDelegate, WebSocketDelegate {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var repeatPasswordTF: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    
    var socket: WebSocket! = nil
    
    var jsonObject: Any  = []
    
    var parentOrChild: Bool?
    
    var kidCount = defaults.integer(forKey: "kidCount")
    var kidID: Int?
        
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
        repeatPasswordTF.text = ""
    }

}

//Function
extension RegisterVC {
    func uiStuffs() {
        addLineToView(view: emailTF, position: .bottom, color: UIColor.init(hex: navy), width: 1)
        addLineToView(view: passwordTF, position: .bottom, color: UIColor.init(hex: navy), width: 1)
        addLineToView(view: repeatPasswordTF, position: .bottom, color: UIColor.init(hex: navy), width: 1)
        
        emailTF.delegate = self
        passwordTF.delegate = self
        repeatPasswordTF.delegate = self
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
    
    @IBAction func registerBtnPressed (_ sender: Any) {
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
        if pwdSame() {
            var actionReg: String {
                if parentOrChild! {
                    return "reg"
                } else {
                    return "reg_kid"
                }
            }
            
            jsonObject = [
                "action": actionReg,
                "email": "\((emailTF.text)!)",
                "password": "\((passwordTF.text)!)"
            ]
            print("MSG:\(actionReg)")
            return true
        }
        return false
    }
    //Checking if passwords are same 
    func pwdSame() -> Bool {
        if isNotEmptyTF() && (passwordTF.text == repeatPasswordTF.text) {
            return true
        } else {
            errorWithText("Пароли не совпадают")
            return false
        }
    }
    //Checking if all textfield are filled
    func isNotEmptyTF() -> Bool {
        if emailTF.text == nil {
            return false
        }
        if passwordTF.text == nil {
            return false
        }
        if repeatPasswordTF.text == nil {
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
    
    func regParse(_ jsonObject: NSDictionary) {
        if let userID = jsonObject["user_id"] as? Int {
            if parentOrChild! {
                let jsonAuth = [
                    "action": "auth",
                    "email": "\((emailTF.text)!)",
                    "password": "\((passwordTF.text)!)"
                ]
                defaults.set(userID, forKey: "parentID")
                sendJson(jsonAuth) {}
            }
        }
    }
    
    func regKidParse(_ jsonObject: NSDictionary) {
        if let userID = jsonObject["user_id"] as? Int {
            //Todo set counter to kidID
            kidCount = kidCount + 1
            defaults.set(kidCount, forKey: "kidCount")
            print("MSG kidcount in defaults\(defaults.integer(forKey: "kidCount"))")
            if !parentOrChild! {
                print("MSG user id \(userID)")
                defaults.set(userID, forKey: "kidID\(kidCount)")
                print("MSG userID in defaults \(defaults.integer(forKey: "kidID\(kidCount)"))")
                performSegue(withIdentifier: "ParentGenerateCodeVC", sender: self)
            }
        }
    }
    
    func authParse(_ jsonObject: NSDictionary) {
        if let sid = jsonObject["sid"] as? String {
            defaults.set(sid, forKey: "sid")
            performSegue(withIdentifier: "NewChildVCSegue", sender: self)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destination = segue.destination as! ParentGenerateCodeVC
//        let kidCount = defaults.integer(forKey: "kidCount")
//        destination.newKidID = defaults.integer(forKey: "kid\(kidCount)")
//
//    }
    
}

// Delegations
extension RegisterVC {
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
                print(action)
                if action == "reg" {
                    regParse(jsonObject!)
                } else if action == "reg_kid" {
                    regKidParse(jsonObject!)
                } else if action == "auth" {
                    authParse(jsonObject!)
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
            repeatPasswordTF.becomeFirstResponder()
            break
        case repeatPasswordTF:
            passwordTF.resignFirstResponder()
            registerBtnPressed(self)
            break
        default:
            emailTF.resignFirstResponder()
            view.endEditing(true)
            break
        }
        return true
    }
}
