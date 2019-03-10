//
//  ChatVC.swift
//  CareMe
//

import UIKit
import Starscream
import PureLayout

class ChatVC: UIViewController, WebSocketDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var barBtn: UIBarButtonItem!
    @IBOutlet weak var windowTitle: UINavigationItem!
    
    var kid: Kid?
    var bottomConstraints: NSLayoutConstraint?
    var refreshControl: UIRefreshControl!
    var messages: [MessageDetail] = []
    var previusMsgCount = 0
    var totalHeight = 0
    var socket: WebSocket! = nil
    var jsonGetMessage: Any  = []
    var jsonSendMessage: Any = []

    var roleInt: Int {
        if (defaults.string(forKey: "role") == "parent") {
            return 0
        } else {
            return 1
        }
    }

    var parentID: String {
        if (roleInt == 0) {
            return defaults.string(forKey: "uid")!
        } else {
            return defaults.string(forKey: "parentID")!
        }
    }

    var kidID: String {
        if (roleInt == 0) {
            return "\(kid!.kidID)"
        } else {
            return defaults.string(forKey: "uid")!
        }
    }

    let role = defaults.string(forKey: "role")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        windowTitle.title = ""
        
        refreshControl = UIRefreshControl()

        tableView.delegate = self
        tableView.dataSource = self

        let url = URL(string: "ws://195.93.152.96:11210")!
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()

        bottomConstraints = NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))

        view.addConstraint(bottomConstraints!)
        updateTableViewConstraints()

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        tableView.addSubview(refreshControl)

        refreshControl.addTarget(self, action: #selector(updateInformation), for: UIControl.Event.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.beginRefreshing()
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if (role == "parent") {
//            barBtn.isEnabled = true
//            barBtn.tintColor = nil
//        } else {
//            barBtn.isEnabled = false
//            barBtn.tintColor = UIColor.clear
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func handleKeyboardNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification

            if (isKeyboardShowing) {
                bottomConstraints?.constant = -keyboardFrame!.height
            } else {
                bottomConstraints?.constant = +keyboardFrame!.height
            }
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (true) in
                self.updateTableViewConstraints()
            }
        }
    }
}

// Functions
extension ChatVC {
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
    
    @IBAction func barBtnPressed(_ sender: Any) {

    }
    
    func updateTableViewConstraints() {
        tableView.autoPinEdge(.top, to: .top, of: view)
        tableView.autoPinEdge(.left, to: .left, of: view)
        tableView.autoPinEdge(.right, to: .right, of: view)
        tableView.autoPinEdge(.bottom, to: .top, of: bottomView)
        
        scrollToBottom()
    }
    
    func messageParse(_ jsonObject: NSDictionary) {
        let count = jsonObject.count - 1
        messages.removeAll()

        for i in 0..<count {
            let message = jsonObject["\(i)"] as? NSDictionary

            let id = message!["id"] as? String
            let date = message!["date"] as? String
            let sender_id = message!["parent_id"] as? String
            let receiver_id = message!["kid_id"] as? String
            let msg = message!["message"] as? String
            let type = message!["type"] as? String
            let name = message!["name"] as? String
            
            windowTitle.title = name
            let newMsg = MessageDetail(id!, sender_id!, receiver_id!, msg!, type!, date!)
            messages.append(newMsg)
        }
        messages.reverse()

        DispatchQueue.main.async {
            if (self.previusMsgCount != self.messages.count) {
                self.totalHeight = 0
                self.tableView.reloadData()
                self.previusMsgCount = self.messages.count
                self.updateTableViewConstraints()
            }
        }

        self.refreshControl.endRefreshing()
    }
    
    func scrollToBottom() {
        if (self.messages.count > 0) {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func getChildName(_ value: Any) {
        let jsonGetKidInfo = ["action": "get_kid_name", "kid_id": value]
        
        sendJson(jsonGetKidInfo) {
            print("MSG: Successfully sended")
            print(jsonGetKidInfo)
        }
    }
    
    @IBAction func sendBtnPressed() {
        if (self.textField.text != "") {
            self.jsonSendMessage = [
                "action": "send_message",
                "parent_id": self.parentID,
                "kid_id": self.kidID,
                "message": self.textField.text!,
                "type": "\(self.roleInt)"
            ]

            self.sendJson(self.jsonSendMessage) {}
            self.textField.text = ""
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
}

//TableView delegates and datasource
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageDetailCell", for: indexPath) as! MessageDetailCell
        
        cell.setVar(message)
        
        cell.messageLabel?.text = message.message
        cell.dateLabel?.text = message.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = messages[indexPath.row].message
        let height: CGFloat = estimateFrameForText(text: text).height + 45

        totalHeight = totalHeight + Int(height)

        return height
    }
}

// Delegations
extension ChatVC {
    func websocketDidConnect(socket: WebSocketClient) {
//        getChildName(kid!.kidID)
        updateInformation()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do {
            let data = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary

            if let action = jsonObject?["action"] as? String {
                if (action == "get_message") {
                    messageParse(jsonObject!)
                }
                
                if (action == "send_message") {
                    updateInformation()
                }
                
//                if (action == "get_kid_name") {
//                    let name = jsonObject!["name"] as? String
//                    windowTitle.title = name
//                }
            }
        } catch let error as NSError {
            print("MSG: json error \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}

