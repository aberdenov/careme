//
//  ChildOrParentVC.swift
//  CareMe
//
//  Created by baytoor on 9/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class ChildOrParentVC: UIViewController {
    
    @IBOutlet weak var parentBtn: UIButton!
    @IBOutlet weak var childBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        uiStuffs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Todo remove all count kidID
        defaults.removeObject(forKey: "role")
        defaults.removeObject(forKey: "sid")
        defaults.removeObject(forKey: "uid")
        defaults.removeObject(forKey: "kidID")
        defaults.removeObject(forKey: "parentID")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "pwd")
        let count = defaults.integer(forKey: "kidCount")
        
        if count > 0 {
            for i in 0..<count {
                defaults.removeObject(forKey: "kidID\(i)")
            }
            defaults.removeObject(forKey: "kidCount")
        }
        defaults.set(-1, forKey: "kidCount")
        
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func uiStuffs() {
        parentBtn.layer.cornerRadius = 5
        childBtn.layer.cornerRadius = 5
    }
    
    @IBAction func parentBtnPressed(_ sender: UIButton) {
        defaults.set("parent", forKey: "role")
        performSegue(withIdentifier: "LoginOrRegisterVCSegue", sender: self)
    }
    
    @IBAction func childBtnPressed(_ sender: UIButton) {
        defaults.set("kid", forKey: "role")
        performSegue(withIdentifier: "LoginVCSegue", sender: self)
    }
}
