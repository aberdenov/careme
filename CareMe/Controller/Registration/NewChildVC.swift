//
//  ChildOrParentVC.swift
//  CareMe
//
//  Created by baytoor on 9/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class NewChildVC: UIViewController {
    
    @IBOutlet weak var addChildBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    var boolRegister: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiStuffs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func uiStuffs() {
        addChildBtn.layer.cornerRadius = 5
        skipBtn.layer.cornerRadius = 5
    }
    
    @IBAction func addChildBtnPressed(_ sender: UIButton) {
        boolRegister = true
        performSegue(withIdentifier: "RegisterVCSegue", sender: self)
    }
    
    @IBAction func skipBtnPressed(_ sender: UIButton) {
        boolRegister = false
        performSegue(withIdentifier: "MainVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if boolRegister{
            let destination = segue.destination as! RegisterVC
            destination.parentOrChild = false
        }
    }
    
}
