//
//  MessageDetailCell.swift
//  CareMe
//


import UIKit
import PureLayout

class MessageDetailCell: UITableViewCell {
    @IBOutlet weak var elementView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var elementViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var elementViewHeightConstraint: NSLayoutConstraint!
    //    var messageDetail: MessageDetail?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setVar(_ msg: MessageDetail) {
        let height = estimateFrameForText(text: msg.message).height
        let width = estimateFrameForText(text: msg.message).width
        let type = Int(msg.type)!
        
        var role: Int {
            if (defaults.string(forKey: "role") == "parent") {
                return 0
            } else {
                return 1
            }
        }
        
        var backgroundColor: UIColor {
            if (role == type) {
                return UIColor(hex: green)
            } else {
                return UIColor(hex: msgGrey)
            }
        }
        
        var textColor: UIColor {
            if (role == type) {
                return UIColor(hex: preWhite)
            } else {
                return UIColor(hex: preBlack)
            }
        }
        
        elementView.layer.masksToBounds = true
        elementView.backgroundColor = backgroundColor
//        elementView.frame = CGRect (x: 100, y: 150, width: 150, height: 150)
        elementView.autoSetDimensions(to: CGSize(width: width + 25, height: height + 20))
        elementView.layer.cornerRadius = 15
        
        messageLabel.textColor = textColor
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0

        elementView.autoPinEdge(.top, to: .top, of: self)
        elementView.addSubview(messageLabel)
        
        dateLabel.textColor = UIColor(hex: darkGrey)
        dateLabel.font = UIFont(name: "Montserrat", size: 10)

        if (type != role) {
            elementView.autoPinEdge(.left, to: .left, of: self, withOffset: 8)
            dateLabel.autoPinEdge(.left, to: .left, of: elementView, withOffset: 8)
        } else {
            elementView.autoPinEdge(.right, to: .right, of: self, withOffset: -8)
            dateLabel.autoPinEdge(.right, to: .right, of: elementView, withOffset: -8)
        }

        dateLabel.autoPinEdge(.bottom, to: .bottom, of: elementView, withOffset: 14)

        messageLabel.autoPinEdge(.leading, to: .leading, of: elementView, withOffset: 8)
        messageLabel.autoPinEdge(.trailing, to: .trailing, of: elementView, withOffset: -8)
        messageLabel.autoPinEdge(.top, to: .top, of: elementView)
        messageLabel.autoPinEdge(.bottom, to: .bottom, of: elementView)
    }
    
//    func setMsg(_ msg: MessageDetail) {
//        let height = estimateFrameForText(text: msg.message).height
//        let width = estimateFrameForText(text: msg.message).width
//        let type = Int(msg.type)!
//        let myID = defaults.string(forKey: "uid")
//
//        var role: Int {
//            if (defaults.string(forKey: "role") == "parent") {
//                return 0
//            } else {
//                return 1
//            }
//        }
//
//        var backgroundColor: UIColor {
//            if (role == type) {
//                return UIColor(hex: green)
//            } else {
//                return UIColor(hex: msgGrey)
//            }
//        }
//
//        var textColor: UIColor {
//            if (role == type) {
//                return UIColor(hex: preWhite)
//            } else {
//                return UIColor(hex: preBlack)
//            }
//        }
//
//        let bubbleView: UIView = {
//            let bv = UIView()
//            bv.layer.masksToBounds = true
//            bv.backgroundColor = backgroundColor
//            bv.autoSetDimensions(to: CGSize(width: width + 25, height: height + 20))
//            bv.layer.cornerRadius = 15
//            return bv
//        }()
//
//        let msgLbl: UILabel = {
//            let lbl = UILabel()
//            lbl.text = msg.message
//            lbl.textColor = textColor
//            lbl.font = UIFont.systemFont(ofSize: 14)
//            lbl.numberOfLines = 0
//            return lbl
//        }()
//
//        let dateLbl: UILabel = {
//            let lbl = UILabel()
//            lbl.text = msg.date
//            lbl.textColor = UIColor(hex: darkGrey)
//            lbl.font = UIFont(name: "Montserrat", size: 10)
//            return lbl
//        }()
//
//        self.addSubview(bubbleView)
//        self.addSubview(dateLbl)
//        bubbleView.addSubview(msgLbl)
//
//        bubbleView.autoPinEdge(.top, to: .top, of: self)
//
//        if (type != role) {
//            bubbleView.autoPinEdge(.left, to: .left, of: self, withOffset: 8)
//            dateLbl.autoPinEdge(.leading, to: .leading, of: bubbleView, withOffset: 7)
//        } else {
//            bubbleView.autoPinEdge(.right, to: .right, of: self, withOffset: -8)
//            dateLbl.autoPinEdge(.trailing, to: .trailing, of: bubbleView, withOffset: -7)
//        }
//
//        msgLbl.autoPinEdge(.leading, to: .leading, of: bubbleView, withOffset: 8)
//        msgLbl.autoPinEdge(.trailing, to: .trailing, of: bubbleView, withOffset: -8)
//        msgLbl.autoPinEdge(.top, to: .top, of: bubbleView)
//        msgLbl.autoPinEdge(.bottom, to: .bottom, of: bubbleView)
//
//        dateLbl.autoPinEdge(.top, to: .bottom, of: bubbleView, withOffset: 5)
//    }
}

