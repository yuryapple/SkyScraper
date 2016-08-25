//
//  Elevator.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 8/8/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import Foundation

class Elevator: DestinatioFloorProtocol {
    
    var capacity : Int {
        
        return 5 - passengersInElevator.count

    }
    
    var destinationFloor : Int?
    
    var passengersInElevator = Set<Passenger>()
    
    
    func loadElevator (queue : [Passenger], curFloor curF: Int) {
    
        queue.map {passengersInElevator.insert($0)}
        
        let maxFloor = passengersInElevator.maxElement( {$0.destinationFloor < $1.destinationFloor})!.destinationFloor
        
        let minFloor = passengersInElevator.minElement( {$0.destinationFloor < $1.destinationFloor})!.destinationFloor
        
        setDestinationFloor(maxFloor: maxFloor! , minFloor: minFloor! , curFloor: curF )
    
    }
    
    
    func setDestinationFloor (maxFloor max: Int, minFloor min: Int, curFloor curF: Int)  {
        
       if (curF < min ) {
            
            self.destinationFloor = max
            
        } else {
          
            self.destinationFloor = min
        
        }
        
        print ("Elevator was loeded. Set destination  \(self.destinationFloor!) ")
        
        
    }
    
    
    func getPassengerToGetOut(currentFloor floor :Int) -> [Passenger] {
        let passengersToGetOut = self.passengersInElevator.filter({ $0.destinationFloor == floor })
        
        // Remians passengers in an elevator
        self.passengersInElevator = self.passengersInElevator.subtract(passengersToGetOut)
        
        return passengersToGetOut
    }
    
}
