//
//  ChatMessageCell.swift
//  CareMe
//
//  Created by baytoor on 11/18/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import PureLayout

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.text = "Some example text"
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor(hex: preWhite)
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: green)
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 16
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bubbleView)
        addSubview(textView)



        bubbleView.autoSetDimensions(to: CGSize(width: 208, height: self.bounds.height))
        bubbleView.autoPinEdge(.right, to: .right, of: self)
        bubbleView.autoPinEdge(.top, to: .top, of: self)

        textView.autoSetDimensions(to: CGSize(width: 200, height: self.bounds.height))
        textView.autoPinEdge(.right, to: .right, of: bubbleView)
        textView.autoPinEdge(.left, to: .left, of: bubbleView, withOffset: 8)
        textView.autoPinEdge(.top, to: .top, of: self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessage(_ msg: MessageDetail) {
        var role: Int {
            if defaults.string(forKey: "role") == "parent" {
                return 0
            } else {
                return 1
            }
        }
        
        let myID = defaults.string(forKey: "uid")
        
        var backgroundColor: UIColor {
            
            if role == Int(msg.type) {
                return UIColor(hex: green)
            } else {
                return UIColor(hex: msgGrey)
            }
        }
        
        var textColor: UIColor {
            if role == Int(msg.type) {
                return UIColor(hex: preWhite)
            } else {
                return UIColor(hex: preBlack)
            }
        }
        
//        if Int(msg.type)! == role {
//            
//        } else {
//            
//        }
        
        
    }
    
    
    
}
