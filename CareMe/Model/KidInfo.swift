//
//  File.swift
//  CareMe
//
//  Created by baytoor on 10/23/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import Foundation

struct KidInfo {
    
    var kidID: String
    var batteryLevel: String
    var batteryState: String
    var longitude: String
    var latitude: String
    var course: String
    var time: String
    var accuracy: String
    
    init(_ kidID: String,_ batteryLevel: String,_ batteryState: String,_ longitude: String,_ latitude: String,_ course: String,_ time: String,_ accuracy: String ) {
        self.kidID = kidID
        self.batteryLevel = batteryLevel
        self.batteryState = batteryState
        self.longitude = longitude
        self.latitude = latitude
        self.course = course
        self.time = time
        self.accuracy = accuracy
    }
    
    init() {
        self.kidID = "0"
        self.batteryLevel = "0.95"
        self.batteryState = "batteryState"
        self.longitude = "32"
        self.latitude = "17"
        self.course = "0"
        self.time = "time"
        self.accuracy = "150"
    }
    
}
