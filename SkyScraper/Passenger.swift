//
//  Passenger.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 7/29/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import Foundation


class Passenger: DestinatioFloorProtocol, Hashable {
 
    var destinationFloor : Int?
   
    var name : String?
    
    // MARK: Hashable protocol
    var hashValue: Int {
        return destinationFloor!
    }
    
    
    init (maxFloorSkyScraper max: Int) {
        setDestinationFloor(maxFloor: max, minFloor: 1, curFloor: 1)
    }
    

    func setDestinationFloor (maxFloor max: Int , minFloor min: Int, curFloor curF : Int)  {
    
        var newDestinationFloor : Int
        
       repeat {
        newDestinationFloor = randomInt(maxValue: max, minValue: min)
        }  while newDestinationFloor == curF
        
        
          self.destinationFloor = newDestinationFloor
    }
    
}



// MARK: Equatable protocol  When compare Passenger Set
func == (a: Passenger, b: Passenger) -> Bool {

    return a.destinationFloor == b.destinationFloor && a.name == b.name
    
}