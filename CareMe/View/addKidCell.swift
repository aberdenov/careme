//
//  addChildCell.swift
//  CareMe
//
//  Created by baytoor on 9/19/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class addKidCell: UITableViewCell {
    
    @IBOutlet weak var addImg: UIImageView!
    @IBOutlet weak var lbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addImg.layer.cornerRadius = addImg.bounds.height/2
        addLineToView(view: self.contentView, position: .bottom, color: UIColor.init(hex: lightGrey), width: 0.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
