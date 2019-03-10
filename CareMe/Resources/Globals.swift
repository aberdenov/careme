//
//  Globals.swift
//  CareMe
//
//  Created by baytoor on 9/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import SwiftKeychainWrapper

let defaults = UserDefaults.standard
let keyUID = "careme9812112"
//defaults.set("sidtexnumber421887" forKey: "sid")
//let sid = defaults.string(forKey: "sid")

let preWhite = 0xFAFAFA
let navy = 0x35485D
let green = 0x22C1C3
let mapBlue = 0x2A8ECC
let yellow = 0xFFC000
let actionBlue = 0x007AFF
let lightGrey = 0xD8D8D8
let darkGrey = 0x979797
let msgGrey = 0xE5E5EA
let preBlack = 0x252525

let mapApi = "AIzaSyBlrYJ3j9_BsUDRv4yp25PeazJx9I0Q3g0"

enum linePosition {
    case top
    case bottom
}

func estimateFrameForText(text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
}

func addLineToView(view : UIView, position : linePosition, color: UIColor, width: Double) {
    let lineView = UIView()
    lineView.backgroundColor = color
    lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
    view.addSubview(lineView)
    
    let metrics = ["width" : NSNumber(value: width)]
    let views = ["lineView" : lineView]
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
    
    switch position {
    case .top:
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        break
    case .bottom:
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        break
    }
}

func isInternetAvailable() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}

func signOut() {
    defaults.set("no", forKey: "role")
    defaults.set("no", forKey: "sid")
    KeychainWrapper.standard.removeObject(forKey: keyUID)
    defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    print("MSG: Signed out")
}
