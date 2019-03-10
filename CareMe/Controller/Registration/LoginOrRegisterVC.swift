//
//  ViewController.swift
//  CareMe
//
//  Created by baytoor on 9/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class LoginOrRegisterVC: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var register: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiStuffs()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func uiStuffs() {
        loginBtn.layer.cornerRadius = 5
        registerBtn.layer.cornerRadius = 5
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        register = false
        performSegue(withIdentifier: "LoginVCSegue", sender: self)
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        register = true
        performSegue(withIdentifier: "RegisterVCSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if register {
            let destination = segue.destination as! RegisterVC
            destination.parentOrChild = true
        }
    }
    
}
