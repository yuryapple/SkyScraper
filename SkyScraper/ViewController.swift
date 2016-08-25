//
//  ViewController.swift
//  SkyScraper
//
//  Created by  Yury_apple_mini on 7/29/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

import UIKit
import AVFoundation



let MIN_FLOORS = 5
let MAX_FLOORS = 20
let MAX_PASSENGER_AT_FLOOR = 10


func randomInt(maxValue max: Int, minValue min: Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}





class ViewController: UIViewController {

    var maxFloorOfSkyScraper : Int!
    
    lazy var skyScraper = SkyScraper()
    
    var pas :Passenger?
    
    let faces = ["👶", "👦", "👧", "👨", "👩", "👱", "👴", "👵🏻", "👲🏾", "👳🏻", "👮🏻"]
    
    var elevatorSound : AVAudioPlayer!
    var urlElevatorSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Elevator_Ding", ofType: "wav")!)
    
    var elevatorMotorSound : AVAudioPlayer!
    var urlElevatorMotorSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("elevator_door", ofType: "wav")!)
    
    @IBOutlet var personInElevator1Label: UILabel!
    @IBOutlet var personInElevator2Label: UILabel!
    
    @IBOutlet var personsInFloor1Label: UILabel!
    @IBOutlet var personsInFloor2Label: UILabel!
    
    @IBOutlet var goButton: UIButton!
    
    @IBOutlet var currentFloorUpLabel: UILabel!
    @IBOutlet var currentFloorDownLabel: UILabel!
    
    @IBOutlet var time1Label: UILabel!
    @IBOutlet var time2Label: UILabel!
    
    @IBOutlet var getOutLabel: UILabel!
    @IBOutlet var getInLabel: UILabel!
    
    @IBOutlet var destination1Label: UILabel!
    @IBOutlet var destination2Label: UILabel!

    
    
    // MARK: - Override functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.prepareRoundButtonAndLabels()
        self.prepareSounds()
        
        // Skyscraper will has a N floors
        maxFloorOfSkyScraper = self.getMaxFloorOfSkyScraper(maxFloor: MAX_FLOORS, minFloor: MIN_FLOORS)
        print ("SkyScraper has  \(maxFloorOfSkyScraper) floors")
        
        // Populate floors
        self.populateFloors()
        
        // Print
        self.printSkyscraperFloors()
        
       // skyScraper.elevator = Elevator(queueUp: loadQueue)
        skyScraper.elevator = Elevator()
        

        // Before open the door of elevator
        self.time1Label.text = "Before"
        self.showPersonInFloorLabel (personsInFloor1Label)
        
        // Passenger who want come in an elevator
        let loadQueue = self.modifyQueue (&skyScraper.queues[0].queueUp)
        
        
        self.showPersonGetInLabel(loadQueue)
        
        skyScraper.elevator.loadElevator(loadQueue, curFloor: 1)
        
        print ("--------------------------")
        print ("Elevator start ")
        self.printInElevator()
        
        print ("Capacity \(skyScraper.elevator!.capacity) ")
     
     
        self.showCurrentFloorLabels ()
        
        // After close the door of elevator
        self.showStateAfter()

    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
   // MARK: - Main functions
    
    @IBAction func NewDestinationFloorForPassenger(sender: AnyObject) {
        
        // Enable and disable GoButtonLabel 
        self.goButton.enabled = false
        performSelector(Selector("goButtonEnabled"), withObject: self, afterDelay: 2)
        
        print ("------------- CLICK BUTTON ---------------")
        
        skyScraper.detectNextFloor()
        
        self.showCurrentFloorLabels()
        
        // Before open the door of elevator
        self.showStateBefore()
        
        // Passengers who want to get out of the elevator
        let passengersToGetOut = skyScraper.elevator.getPassengerToGetOut(currentFloor: skyScraper.currentFloor)
        
        // Skip floor or load new passenger
        if (skyScraper.elevator.capacity == 0  &&  passengersToGetOut.count == 0 ){
            
            print (" Skip floor ------------------ \(skyScraper.currentFloor) ")
            
            getOutLabel.text = "Skip this floor"
            getInLabel.text = "Skip this floor"
            
            elevatorMotorSound.play()
            
        } else {
            
            elevatorSound.play()
            
            print ("Floor ---- \(skyScraper.currentFloor)")
            print ("Elevator stop ")
            self.printInElevator()
            
            print ("--------------------------")
            print ("Old queue on floor ")
            self.printQueueFloor()
            
            
            self.showPersonGetOutLabel(passengersToGetOut)
            
            if (passengersToGetOut.count != 0) {
          
                // Set new destination floor for passengers
                passengersToGetOut.map { $0.setDestinationFloor (maxFloor: self.maxFloorOfSkyScraper, minFloor: 1, curFloor : skyScraper.currentFloor) }
                    
                
                // Sort passengers
                let newPassengersForQueueUp = passengersToGetOut.filter({ $0.destinationFloor > skyScraper.currentFloor })
                let newPassengersFornewQueueDown = passengersToGetOut.filter({ $0.destinationFloor < skyScraper.currentFloor })
                

                // Add new passenger to queues
                let floorCurrent = skyScraper.queues[skyScraper.currentFloor-1]
                floorCurrent.addNewPassengersToQueueUp(newPassengersForQueueUp)
                floorCurrent.addNewPassengersToQueueDown(newPassengersFornewQueueDown)
                
            }
            
            print ("--------------------------")
            print ("Remians in elevator ")
            self.printInElevator()
            
            // Elevator has some room  (Example in evevator 4 passengers , so one passenger can come in)
            // new passenger for elevator
            let loadQueue = self.queueForLoad()
            
            self.showPersonGetInLabel(loadQueue)
            
            // load new passenget to elevator
            skyScraper.elevator.loadElevator(loadQueue, curFloor: skyScraper.currentFloor)
            
            print ("--------------------------")
            print ("New queue on floor ")
            self.printQueueFloor()
            
            print ("--------------------------")
            print ("New passengers in elevator")
            self.printInElevator()
        }
        
        // After close the door of elevator
        self.showStateAfter()
    }
    
    
    
    func queueForLoad () -> [Passenger] {
        
        var passengerToGetIn = [Passenger]()
        
        // Evevator reach its a destination floor (End point of way)
        if (skyScraper.elevator.destinationFloor == skyScraper.currentFloor) {
            
            // Select more populeted queue
            passengerToGetIn += skyScraper.queues[skyScraper.currentFloor - 1].queueUp.count >= skyScraper.queues[skyScraper.currentFloor - 1].queueDown.count
              
                ? self.modifyQueue (&skyScraper.queues[skyScraper.currentFloor - 1].queueUp)
                : self.modifyQueue (&skyScraper.queues[skyScraper.currentFloor - 1].queueDown)
            
        } else if (skyScraper.elevator.destinationFloor > skyScraper.currentFloor)  {
            passengerToGetIn += self.modifyQueue (&skyScraper.queues[skyScraper.currentFloor - 1].queueUp)
            
        } else {
            passengerToGetIn += self.modifyQueue (&skyScraper.queues[skyScraper.currentFloor - 1].queueDown)
        }
        
        return passengerToGetIn
    }
    
    
    
    
    func  modifyQueue (inout queue:  [Passenger]) -> [Passenger] {
        
        let numberPassenger = skyScraper.elevator.capacity <= queue.count ? skyScraper.elevator.capacity  : queue.count
        let loadQueue = queue.extract(numberPassenger)
        
        return loadQueue
    }
    
    
    
    
    
    // MARK: - Show labels and button
    
    func prepareRoundButtonAndLabels () {
        
        goButton.layer.cornerRadius = 0.5 * goButton.bounds.size.width
        goButton.setTitle("⬆️", forState: .Normal)
        
        
        currentFloorUpLabel.layer.masksToBounds = true
        currentFloorUpLabel.layer.cornerRadius = 0.5 * currentFloorUpLabel.bounds.size.width
        currentFloorUpLabel.text = "2"
        
        currentFloorDownLabel.layer.masksToBounds = true
        currentFloorDownLabel.layer.cornerRadius = 0.5 * currentFloorDownLabel.bounds.size.width
        currentFloorDownLabel.text = "1"
        
        
        destination1Label.layer.masksToBounds = true
        destination1Label.layer.cornerRadius = 0.5 * destination1Label.bounds.size.width

        destination2Label.layer.masksToBounds = true
        destination2Label.layer.cornerRadius = 0.5 * destination2Label.bounds.size.width
    }
    
    
    func showCurrentFloorLabels () {
    
        // show current floor
        if ( skyScraper.elevator.destinationFloor == skyScraper.currentFloor  ) {
            currentFloorUpLabel.text = "\(skyScraper.currentFloor)"
            goButton.setTitle( "➡️", forState: .Normal)
            currentFloorDownLabel.text = "\(skyScraper.currentFloor)"
        } else if( skyScraper.elevator.destinationFloor > skyScraper.currentFloor  ) {
            currentFloorUpLabel.text = "\(skyScraper.currentFloor + 1)"
            goButton.setTitle("⬆️", forState: .Normal)
            currentFloorDownLabel.text = "\(skyScraper.currentFloor)"
        } else {
            destination1Label.hidden = true
            currentFloorUpLabel.text = "\(skyScraper.currentFloor)"
            goButton.setTitle("⬇️", forState: .Normal)
            currentFloorDownLabel.text = "\(skyScraper.currentFloor - 1)"
            
        }
    }
    
    
    
    func showStateBefore () {
        
        self.goButton.userInteractionEnabled = false

            self.time1Label.text = "Before"
            self.showPersonInElevatorLabel (personInElevator1Label)
            self.showPersonInFloorLabel (personsInFloor1Label)
      
            self.time2Label.text = "Before"
            self.showPersonInElevatorLabel (personInElevator2Label)
            self.showPersonInFloorLabel (personsInFloor2Label)
    }
    

    func showStateAfter () {
        
        self.goButton.userInteractionEnabled = true
        
        if( skyScraper.elevator.destinationFloor >= skyScraper.currentFloor) {
            self.time2Label.text = "After"
            self.showPersonInElevatorLabel (personInElevator2Label)
            self.showPersonInFloorLabel (personsInFloor2Label)
            
            self.destination2Label.hidden = false
            self.destination2Label.text = "\(skyScraper.elevator.destinationFloor!)"
            self.destination1Label.hidden = true
        } else {
            self.time1Label.text = "After"
            self.showPersonInElevatorLabel (personInElevator1Label)
            self.showPersonInFloorLabel (personsInFloor1Label)
            
            self.destination1Label.hidden = false
            self.destination1Label.text = "\(skyScraper.elevator.destinationFloor!)"
            self.destination2Label.hidden = true
        }
    }
    
    
    
    func showPersonInElevatorLabel (label : UILabel) {
    
        var passengerInElevator = ""
        
        for passenger in skyScraper.elevator.passengersInElevator.sort( { $0.destinationFloor  >  $1.destinationFloor} ) {
            passengerInElevator +=  "\(passenger.name!) \(passenger.destinationFloor!)" + "  "
        }
    
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    
        label.text = passengerInElevator
    }
    
    
    func showPersonInFloorLabel (label : UILabel) {
        var passengerInFlooor = "🔼"
        
        for passenger in skyScraper.queues[skyScraper.currentFloor - 1].queueUp {
            passengerInFlooor +=  "\(passenger.name!) \(passenger.destinationFloor!)" + "  "
        }
        
        passengerInFlooor += "\n🔽"
        
        for passenger in skyScraper.queues[skyScraper.currentFloor - 1].queueDown {
            passengerInFlooor +=  "\(passenger.name!) \(passenger.destinationFloor!)" + "  "
        }
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        label.text = passengerInFlooor
    }
    

    func showPersonGetOutLabel (getOutPassengers : [Passenger]) {
        var passengerGetOut = "   GET OUT \n"
        
        for passenger in getOutPassengers {
            passengerGetOut +=  "\(passenger.name!) \(passenger.destinationFloor!)" + "  "
        }
        
        getOutLabel.numberOfLines = 0
        getOutLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        getOutLabel.text = passengerGetOut
    }
    

    func showPersonGetInLabel (getInPassengers : [Passenger]) {
        var passengerGetIn = " GET IN   \n"
        
        for passenger in getInPassengers {
            passengerGetIn +=  "\(passenger.name!) \(passenger.destinationFloor!)" + "  "
        }
        
        getInLabel.numberOfLines = 0
        getInLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        getInLabel.text = passengerGetIn
    }
    
    
    
    func printSkyscraperFloors () {

        var f = 0
        
        for floor in skyScraper.queues {
            
            f+=1
            print ("Floor ----------- \(f) ")
            
            print ("      UP   ")
            for curUp in floor.queueUp {
                print ("\(curUp.destinationFloor!) ")
            }
            
            print ("      Down ")
            for curDown in floor.queueDown {
                print ("\(curDown.destinationFloor!) ")
            }
            
            print ("      ")
        }
    }
    
    
    func printInElevator () {
        
        print ("   In elevator   ")
        
        for out in skyScraper.elevator.passengersInElevator.sort( { $0.destinationFloor  >  $1.destinationFloor} ) {
            print ("\(out.destinationFloor!) ")
        }
        
        print ("   -------------   ")
    }
    
    
    func printQueueFloor () {
        
        let cF = skyScraper.currentFloor
        print ("Floor ----------- \(cF) ")
        
        print ("      UP   ")
        for curUp in skyScraper.queues[cF-1].queueUp {
            print ("\(curUp.destinationFloor!) ")
        }
        
        print ("      Down ")
        for curDown in skyScraper.queues[cF-1].queueDown {
            print ("\(curDown.destinationFloor!) ")
        }
        
        print ("      ")
    }
    
    
    
    
    
    // MARK: - Other functions
    
    func getMaxFloorOfSkyScraper(maxFloor max: Int, minFloor min: Int) -> Int {
        return randomInt(maxValue: max, minValue: min)
    }
    
    
    func prepareSounds() {
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOfURL: urlElevatorSound)
            elevatorSound = audioPlayer
        } catch {
            print("Couldn't load audio file")
        }
        
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOfURL: urlElevatorMotorSound)
            elevatorMotorSound = audioPlayer
        } catch {
            print("Couldn't load audio file")
        }
    }
    
    
    
    func populateFloors() {
        
        for currentFloor in 1...maxFloorOfSkyScraper {
            
            let newFloor = Floor()
            
            
            for numberInQueue in 1...randomInt(maxValue: MAX_PASSENGER_AT_FLOOR, minValue: 1)  {
                
                let newPasseger = Passenger(maxFloorSkyScraper: self.maxFloorOfSkyScraper)
                
                
                // The same floor
                if (currentFloor == newPasseger.destinationFloor) {
                    
                    // redirect a passenger to a new floor
                    newPasseger.setDestinationFloor(maxFloor: self.maxFloorOfSkyScraper , minFloor: 1, curFloor : currentFloor)
                    
                }
                
    
                // Set face and name for passenger
                let indexFace = randomInt(maxValue: self.faces.count - 1, minValue: 0)

                newPasseger.name = "\(self.faces[indexFace])" +  "\(currentFloor)" +  "\(numberInQueue)"
                
                // Add new passenger to  Up Or Donw queue
                if (currentFloor < newPasseger.destinationFloor  ) {
                    newFloor.queueUp.append(newPasseger)
                    
                } else {
                    newFloor.queueDown.append(newPasseger)
                }
            }
            
            // Add new floor to skyscraper
            skyScraper.queues.append(newFloor)
        }
    }

    
    
    func goButtonEnabled (){
        self.goButton.enabled = true
    }
    
    
    // MARK: - Prepare for seque
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SkyScraperFloors" {
            let tableViewController:MyTableViewController = segue.destinationViewController as! MyTableViewController
            tableViewController.queues = skyScraper.queues
            
        }
    }
  
    
}

