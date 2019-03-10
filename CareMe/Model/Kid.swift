//
//  File.swift
//  CareMe
//
//  Created by baytoor on 9/19/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import Foundation

struct Kid {
    var kidID: String
    var name: String
    var surname: String
    var imgUrlString: String
    var kidInfo: KidInfo
    
    init(_ kidID: String, _ name: String,_ surname: String,_ imgUrlString: String,_ kidInfo: KidInfo) {
        self.name = name
        self.surname = surname
        self.imgUrlString = imgUrlString
        self.kidID = kidID
        self.kidInfo = kidInfo
    }
    
    init(_ kidID: String, _ name: String,_ surname: String,_ imgUrlString: String) {
        self.name = name
        self.surname = surname
        self.imgUrlString = imgUrlString
        self.kidID = kidID
        self.kidInfo = KidInfo()
    }

}
