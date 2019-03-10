//
//  ChatController.swift
//  CareMe
//
//  Created by baytoor on 11/17/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import PureLayout
import Starscream

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var kid: Kid? {
        didSet {
            navigationItem.title = kid?.name
        }
    }
    var messages: [MessageDetail] = []
    
    var socket: WebSocket! = nil
    
    var roleInt: Int {
        if defaults.string(forKey: "role") == "parent" {
            return 0
        } else {
            return 1
        }
    }
    var parentID: String {
        if roleInt == 0 {
            return defaults.string(forKey: "uid")!
        } else {
            return defaults.string(forKey: "parentID")!
        }
    }
    var kidID: String {
        if roleInt == 0 {
            return "\(kid!.kidID)"
        } else {
            return defaults.string(forKey: "uid")!
        }
    }
    var jsonGetMessage: Any  = []
    var jsonSendMessage: Any = []
    
    let inputTF: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
        
        collectionView.alwaysBounceVertical = true
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        
        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
        
    }
    
    func setupInputComponents() {
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: preWhite)
        view.addSubview(containerView)
        containerView.autoSetDimensions(to: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 55))
        containerView.autoPinEdge(.left, to: .left, of: view)
        containerView.autoPinEdge(.bottom, to: .bottom, of: view)
        containerView.autoPinEdge(.right, to: .right, of: view)
        
        collectionView.autoPinEdge(.top, to: .top, of: view)
        collectionView.autoPinEdge(.right, to: .right, of: view)
        collectionView.autoPinEdge(.left, to: .left, of: view)
        collectionView.autoPinEdge(.bottom, to: .top, of: containerView)
        
        let sendBtn = UIButton()
        containerView.addSubview(sendBtn)
        sendBtn.setImage(UIImage(named: "SendBtn"), for: .normal)
        //Setting action for sendBtn
        sendBtn.addTarget(self, action: #selector(sendBtnPressed), for: .touchUpInside)
        sendBtn.autoSetDimensions(to: CGSize(width: 30, height: 30))
        sendBtn.autoPinEdge(.right, to: .right, of: containerView, withOffset: -10)
        sendBtn.autoAlignAxis(.horizontal, toSameAxisOf: containerView)
        
        containerView.addSubview(inputTF)
        inputTF.autoSetDimensions(to: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))
        inputTF.autoPinEdge(.left, to: .left, of: containerView, withOffset: 10)
        inputTF.autoPinEdge(.right, to: .left, of: sendBtn, withOffset: -10)
        inputTF.autoAlignAxis(.horizontal, toSameAxisOf: containerView)
        
    }
    
    
    
}

//Delegates
extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let text = messages[indexPath.row].message
        cell.textView.text = text
        let width = estimateFrameForText(text: text).width
        cell.bubbleView.autoSetDimensions(to: CGSize(width: width+32, height: cell.bounds.height))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = messages[indexPath.row].message
        let height: CGFloat = estimateFrameForText(text: text).height + 20
        return CGSize(width: view.frame.width, height: height)
    }
    
}

extension ChatController {
    
    @objc func sendBtnPressed() {
        self.view.endEditing(true)
        if inputTF.text != "" {
            jsonSendMessage = [
                "action": "send_message",
                "parent_id": self.parentID,
                "kid_id": self.kidID,
                "message": self.inputTF.text!,
                "type": "\(self.roleInt)"
            ]
            print(jsonSendMessage)
            sendJson(jsonSendMessage) {}
            inputTF.text = ""
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
    
    @objc func updateInformation() {
        jsonGetMessage = [
            "action": "get_message",
            "parent_id": parentID,
            "kid_id": kidID
        ]
        sendJson(jsonGetMessage) {
            print(self.jsonGetMessage)
        }
    }
    
    func messageParse(_ jsonObject: NSDictionary) {
        let count = jsonObject.count-1
        messages.removeAll()
        for i in 0..<count {
            let message = jsonObject["\(i)"] as? NSDictionary
            let id = message!["id"] as? String
            let date = message!["date"] as? String
            let sender_id = message!["parent_id"] as? String
            let receiver_id = message!["kid_id"] as? String
            let msg = message!["message"] as? String
            let type = message!["type"] as? String
            
            let newMsg = MessageDetail(id!, sender_id!, receiver_id!, msg!, type!, date!)
            messages.append(newMsg)
        }
        messages.reverse()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.messages.count > 0 {
                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
            }
            
        }
    }
    
    
}

extension ChatController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("connected")
        updateInformation()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        print("Answer from websocket\(text)")
        do {
            let data = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            
            if let action = jsonObject?["action"] as? String {
                if action == "get_message" {
                    messageParse(jsonObject!)
                } else if action == "send_message" {
                    updateInformation()
                }
            }
            
            
        } catch let error as NSError {
            print("MSG: json error \(error)")
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
    
}
