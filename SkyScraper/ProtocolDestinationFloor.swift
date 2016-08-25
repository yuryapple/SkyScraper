//
//  ProtocolDestinationFloor.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 8/8/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import Foundation


protocol DestinatioFloorProtocol {
    
    var destinationFloor : Int? {get}
    
    func setDestinationFloor (maxFloor max: Int, minFloor min: Int, curFloor curF: Int)
    
}