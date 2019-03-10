//
//  ListOfChatsVC.swift
//  CareMe
//
//  Created by baytoor on 11/13/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class ListOfChatsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var kids: [Kid]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if kids?.count != 0 {
            //Update the kid's list
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (kids?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kidCell", for: indexPath) as! kidCell
        let kid = kids![indexPath.row]
        cell.setKid(kid)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "ChatControllerSegue", sender: self)
        performSegue(withIdentifier: "ChatVCSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destination = segue.destination as! ChatController
        let destination = segue.destination as! ChatVC
        destination.kid = kids![tableView.indexPathForSelectedRow!.row]
    }
    

}
