//
//  moreFunctionsCell.swift
//  CareMe
//
//  Created by baytoor on 9/24/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class moreFunctionsCell: UITableViewCell {

    @IBOutlet weak var movementBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var soundAroundBtn: UIButton!
    @IBOutlet weak var sendSignalBtn: UIButton!
    
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stack2.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func movementBtnPressed(_ sender: Any) {
//        print("MSG: movement")
    }
    
    @IBAction func chatBtnPressed(_ sender: Any) {
//        print("MSG: chat")
    }
    
    @IBAction func soundAroundBtnPressed(_ sender: Any) {
//        print("MSG: sound")
    }
    
    @IBAction func sendSignalBtnPressed(_ sender: Any) {
//        print("MSG: signal")
    }

}
