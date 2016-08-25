//
//  MyTableViewController.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 8/14/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController {

    var queues = [Floor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queues = queues.reverse()
    }
        
    
    
    // MARK: - Table view data source
    
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
   }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        
       return 100
    }
    
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queues.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    
 
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as UITableViewCell
        cell.layer.cornerRadius = 10
        
        
        //Floor's number
        let  numberFloorLabel = cell.viewWithTag(100) as? UILabel
        numberFloorLabel!.text = "Floor \(queues.count -  indexPath.row)"
    
        
        let StringForQueues = self.getStringForQueues(indexPath.row)
    

        // UP
        let  upLabel = cell.viewWithTag(101) as? UILabel
        upLabel?.numberOfLines = 0
        upLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        upLabel?.text = StringForQueues.passengersUp
        
        // Down
        let  downLabel = cell.viewWithTag(102) as? UILabel
        downLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        downLabel?.numberOfLines = 0
        downLabel?.text = StringForQueues.passengersDown
        
        return cell
    }
    

    
    
    // MARK: - Other functions
    
   private  func getStringForQueues(index: Int) -> (passengersUp: String,  passengersDown: String) {
        var passengersUp = "🔼"
        var passengersDown = "🔽"
        
        // UP
        for passenger in self.queues[index].queueUp {
            passengersUp +=  "\(passenger.name!)☝︎\(passenger.destinationFloor!)" + "  "
        }
        
        // DOWN
        for passenger in self.queues[index].queueDown {
            passengersDown +=  "\(passenger.name!)☟\(passenger.destinationFloor!)" + "  "
        }

    
        return (passengersUp, passengersDown)
    }
    
    
    
}
    
    

