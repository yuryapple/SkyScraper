//
//  Array+Exstract.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 8/11/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func extract(numberElemebts : Int) -> ([Element]) {
        
        let extractElements = self[0 ..< numberElemebts]
        
        self.removeFirst(numberElemebts)
      
        return  Array(extractElements)
    }
}