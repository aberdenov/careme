//
//  childCell.swift
//  CareMe
//
//  Created by baytoor on 9/19/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import PureLayout

class kidCell: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var noImgView: UIView!
    @IBOutlet weak var noImgLbl: UILabel!
    @IBOutlet weak var nameAndSurname: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var batteryImg: UIImageView!
    @IBOutlet weak var batteryPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.layer.cornerRadius = imgView.bounds.height/2
        addLineToView(view: lineView, position: .bottom, color: UIColor.init(hex: lightGrey), width: 0.5)
        imgView.backgroundColor = UIColor.clear
        noImgView.layer.cornerRadius = noImgView.bounds.height/2
        noImgView.layer.borderColor = UIColor(hex: navy).cgColor
        noImgView.layer.borderWidth = 1.5
        
    }
    
    func setKid(_ kid: Kid) {
        self.nameAndSurname.text = "\(kid.name) \(kid.surname)"
        self.desc.text = kid.kidInfo.time
        self.batteryPercentage.text = "\(kid.kidInfo.batteryLevel) %"
        if let percentage = Int(kid.kidInfo.batteryLevel) {
            if percentage > 80 {
                self.batteryImg.image = UIImage(named: "Battery100")
            } else if percentage > 60 {
                self.batteryImg.image = UIImage(named: "Battery75")
            } else if percentage > 40 {
                self.batteryImg.image = UIImage(named: "Battery60")
            } else if percentage > 20 {
                self.batteryImg.image = UIImage(named: "Battery40")
            } else if percentage > 10 {
                self.batteryImg.image = UIImage(named: "Battery20")
            } else {
                self.batteryImg.image = UIImage(named: "Battery5")
            }
        }
        
        self.imgView.image = UIImage(named: kid.imgUrlString)
        self.noImgLbl.text = kid.name[0..<2]
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
