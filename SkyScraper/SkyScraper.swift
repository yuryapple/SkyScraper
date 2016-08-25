//
//  SkyScraper.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 8/8/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import Foundation

class SkyScraper {
    
    var queues = [Floor]()
    var elevator = Elevator!()
    var currentFloor :Int = 1
    
    func detectNextFloor () {
    
        if (self.elevator.destinationFloor > self.currentFloor) {
            self.currentFloor += 1
        } else {
            self.currentFloor -= 1
        }
    }
    
}