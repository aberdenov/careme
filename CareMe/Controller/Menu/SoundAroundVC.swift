//
//  SoundAroundVC.swift
//  CareMe
//
//  Created by baytoor on 9/24/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class SoundAroundVC: UIViewController {
    
    var kids: [Kid]?
    var kid: Kid?
    
    @IBOutlet weak var btn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        btn.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
