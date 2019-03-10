//
//  MessageDetail.swift
//  CareMe
//
//  Created by baytoor on 11/13/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import Foundation

struct MessageDetail {
    
    var id: String
    var date: String
    var parentID: String
    var kidID: String
    var message: String
    var type: String
    
    init(_ id: String,_ parentID: String,_ kidID: String,_ message: String,_ type: String,_ date: String) {
        self.id = id
        self.parentID = parentID
        self.kidID = kidID
        self.message = message
        self.type = type
        self.date = date
    }
    
}

