//
//  Floor.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 8/8/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import Foundation

class Floor {
    
    var queueUp = [Passenger]()
    var queueDown = [Passenger]()
    
    
    func addNewPassengersToQueueUp (queue :[Passenger]) {
       self.queueUp.appendContentsOf(queue)
    }

    
    func addNewPassengersToQueueDown (queue :[Passenger]) {
        self.queueDown.appendContentsOf(queue)
    }
    
}