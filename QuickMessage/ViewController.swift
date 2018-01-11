//
//  ViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/4/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import UIKit
import EventKit
import CoreData

//SKU little_QuickMessage_SKU

/*
 Next steps:
 - load saved events/alarms into table view
 -
 
*/



// TD: things to look up:
// weak vs strong, atomic vs nonatomic, optionals



//This contains the calendar view and is the starting point for the app
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // DEBUG:
    var events = [Event]()
    
    // Calendar
    @IBOutlet var calendarView:UICollectionView?
    @IBOutlet weak var monthTxtFld: UITextField!
    @IBOutlet weak var yearTxtFld: UITextField!
    
    var daysInMonth:Int = 0
    var startingDayOfWeek:Int = 0 //this is for which cell to begin displaying the date on
    var includeUserEKEvents:Bool = false
    
    // Only used for the collection view...
    // TD: find some way to not have these as attributes
    var year:Int = 0
    var month:Int = 0
    
    let eventStore = EKEventStore()
    
    
    // Menu area
    @IBOutlet weak var userEventsToggle: UISwitch!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        
        let dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = Calendar.current
        let currentDate = Date()
        self.monthTxtFld.placeholder = String(Calendar.current.component(.month, from: currentDate))
        self.yearTxtFld.placeholder = String(Calendar.current.component(.year, from: currentDate))
    
        // Calendar
        
        self.calendarView?.delegate = self
        self.calendarView?.dataSource = self
        
        self.setCalendarInfo(givenMonth: Calendar.current.component(.month, from: currentDate), givenYear: Calendar.current.component(.year, from: currentDate))

        // Event info
        // if we already have access, go ahead and load user events in
        // TD2: load toggle setting from previous run automatically
        /*if EKEventStore.authorizationStatus(for: EKEntityType.event) == .authorized {
            // TD2: and if the toggle was switched on when the app was closed
            self.includeUserEKEvents = true
        }
 */

        // DEBUG: attempting to fetch all events to see if there's any getting saved
        // let events = CoreDataManager.fetchAllEvents()
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return
        }
        
        // create new event
        let thisMOC = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        do {
            events = try thisMOC.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Event]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        print("DEBUG: attempting to print saved events")
        for item in events {
            let thisEvent = item as! Event
            print("item title in viewDidLoad is: ", thisEvent.title)
            print("item with key value printing in viewDidLoad is: ", thisEvent.value(forKey:"title") as! String)

            // print("date: ", dateFormatter.string(from: item.alarmDate))
            
        }
       
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Calendar delegate and source functions
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.daysInMonth + self.startingDayOfWeek
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // first starting date is sunday, at 1
        let thisCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        var thisDateComponents = DateComponents()
        
        if (indexPath.item) < (self.startingDayOfWeek - 1) { // if it's before the start date
            thisCell.alpha = 0
        } else { // cell is an active calendar item. Give it a date and display
            thisCell.displayNum.text = String(indexPath.item - self.startingDayOfWeek + 2)

            thisDateComponents.year = self.year
            thisDateComponents.month = self.month
            thisDateComponents.day = Int(thisCell.displayNum.text!)
            thisDateComponents.hour = 0
            thisDateComponents.minute = 0
            
            thisCell.beginDate = Calendar.current.date(from: thisDateComponents)!
            
            thisDateComponents.hour = 23
            thisDateComponents.minute = 59
            let endDate = Calendar.current.date(from: thisDateComponents)

            
        
        
        // Add EKEvents if required
            if self.includeUserEKEvents == true
            {
                // Get start and end date for this cell
                /*print("DEBUG: beginDate is: ", beginDate)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                dateFormatter.timeStyle = DateFormatter.Style.medium
                let dateString = dateFormatter.string(from: beginDate!)
                print("datestring for begin date is: ", dateString)
                */
                
                
                thisDateComponents.hour = 23
                thisDateComponents.minute = 59
                let endDate = Calendar.current.date(from: thisDateComponents)
                //print("DEBUG: endDate is: ", endDate)
                
                // predicate for that day
                // TD2: allow user to choose which calendars
                let thisPredicate = self.eventStore.predicateForEvents(withStart: thisCell.beginDate, end: endDate!, calendars: nil)
                
                // set the cell's color if there's events
                let fetchedEvents = eventStore.events(matching: thisPredicate)
                if fetchedEvents.count != 0 {
                    thisCell.backgroundColor = UIColor.yellow
                } else {
                    thisCell.backgroundColor = UIColor.white
                }
                
                thisCell.ekEvents = fetchedEvents
        
                
            } else {
                thisCell.backgroundColor = UIColor.white
            }
            
            // now add saved events
            let fetchedEvents = CoreDataManager.fetchEventsForDate(givenDate: thisCell.beginDate) as [Event]
            if fetchedEvents.count > 0 {
                print("DEBUG: saved events retrieved in cell")
                thisCell.dotMarkerLbl.alpha = 1
                thisCell.dotMarkerLbl.backgroundColor = UIColor.blue
                thisCell.events = fetchedEvents
            } else {
                print("DEBUG: no saved events retrieved in cell")
                thisCell.dotMarkerLbl.alpha = 0
            }
            
        
        } // end of if calendar date
        return thisCell
    }
    
    // Calendar info set up
    
        // Utility
    
    func setCalendarInfo(givenMonth:Int!, givenYear:Int!) {
        self.daysInMonth = getDaysInMonth(givenMonth, givenYear:givenYear!)
        self.startingDayOfWeek = getStartingDayOfWeek(givenMonth:givenMonth, givenYear:givenYear)
        self.year = givenYear
        self.month = givenMonth
        
        if (givenMonth == nil && givenYear == nil) {
            // use current information
            let thisDate = Date()
            if (self.year == 0) {self.year = Calendar.current.component(.year, from: thisDate)}
            if (self.month == 0) {self.month = Calendar.current.component(.month, from: thisDate)}
        }
        
    }
    
    func redrawCalendar(useDefaultInfo:Bool) {
        
        if (useDefaultInfo == true) {
            self.setCalendarInfo(givenMonth: nil, givenYear: nil)
            
        }
        
        self.calendarView?.reloadData()
        
        
    }
    
    
    func getDaysInMonth(_ givenMonth:Int!, givenYear:Int!) -> Int {
        //note: months start at 1
        
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = Calendar.current
        
        // set days in the current month, otherwise IFF year and month are given,
        // set days in the given time range
        
        if (givenMonth == nil && givenYear == nil) {
            let currentDate = Date()
            // http://stackoverflow.com/questions/1179945/number-of-days-in-the-current-month-using-iphone-sdk
            
            let days:Int = ( Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: currentDate).length
            return days
            // print("DEBUG: Days in current month: ", daysInMonth)
            
        } else if (givenMonth != nil && givenYear != nil) {
            if (givenMonth < 1 && givenMonth > 12) {
                return 0
            }
            
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            
            let newDate = Calendar.current.date(from: dateComponents)
            let days:Int = (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: newDate!).length
            
            return days
            // print("DEBUG: Days in given month: ", daysInMonth)
           
        } else {
            // TDAlert: display error about requiring both values
            print("Error: getDaysInMonth: Month OR date set; requires both or neither")
            return 0

        }

    }
    
    // TD: error checking for this?
    func getStartingDayOfWeek(givenMonth:Int!, givenYear:Int!) -> Int {
        //if there's no given date, use current one
        
        if (givenMonth == nil && givenYear == nil) {
            let thisDate = Date()
            let startingDay:Int = (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate)
            print("DEBUG: startingDayOfWeek with current date is: ", startingDay)
            return startingDay
        } else {
            var dateComponents = DateComponents()
            (dateComponents as NSDateComponents).calendar = Calendar.current
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            dateComponents.day = 1
 
            let thisDate = Calendar.current.date(from: dateComponents as DateComponents)
            let startingDay:Int = (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate!)
            return startingDay
        }
    }
    
    // User calendar info - EKEvent
    

    
    // IBActions
    
    // TD2: disable go button unless both text fields have values
    @IBAction func goBtnPressed(_ sender: UIButton) {
        // Only run if both fields have values
        if (self.monthTxtFld.text! != "" && self.yearTxtFld.text! != "") {
            self.setCalendarInfo(givenMonth: Int(self.monthTxtFld.text!), givenYear: Int(self.yearTxtFld.text!))
            
            // Redraw the calendar
            self.redrawCalendar(useDefaultInfo: false)
        } else {
            print("Error: both month and year text fields must have values")
        }
        
    }
    
    // TD2: move this to a separate area for alerts
    func displayEventsAlerts() {
        // Create and present an alert
        let thisAlert = UIAlertController(title: "Calendar Access Required", message: "Please allow access to the calendar to display your calendar events in-app. You can do this by going to your phone settings.", preferredStyle: UIAlertControllerStyle.alert)
        thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(thisAlert, animated: true, completion: nil)

    }
    
    @IBAction func toggleSwitched(_ sender: UISwitch) {
 
        if (self.userEventsToggle.isOn) {
            // Depending on the permissions status, redraw the calendar with events
            switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
            case .authorized:
                self.includeUserEKEvents = true
                self.redrawCalendar(useDefaultInfo: false)
                break;
            case .notDetermined:
                func completionHandler(_ granted: Bool, error: Error?) -> Void{
                    if granted == true {
                        userEventsToggle.isOn = true
                        self.includeUserEKEvents = true
                        self.redrawCalendar(useDefaultInfo: false)
                    } else {
                        self.userEventsToggle.isOn = false
                        self.includeUserEKEvents = false
                        // User has said no to calendar access; display alert
                        self.displayEventsAlerts()
                        print("not granted")
                    }
                    
                }
                eventStore.requestAccess(to: EKEntityType.event, completion: completionHandler as EKEventStoreRequestAccessCompletionHandler)
                break;
            case .denied:
                self.userEventsToggle.isOn = false
                self.includeUserEKEvents = false
                self.displayEventsAlerts()
                break;
            case .restricted:
                self.userEventsToggle.isOn = false
                // Create and present an alert
                let thisAlert = UIAlertController(title: "Calendar Access Restricted", message: "Calendar access is restricted. This may be caused by parental controls or another setting.", preferredStyle: UIAlertControllerStyle.alert)
                thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                present(thisAlert, animated: true, completion: nil)
                self.includeUserEKEvents = false
                break;
            }
            
            
        } else { //user has toggled it off
            self.includeUserEKEvents = false
            self.redrawCalendar(useDefaultInfo: false)
            
            
        }
 
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue ID for displaying event: EventViewSID
        if segue.identifier == "DayViewSID" {
            
            let senderCell = sender as! CalendarCell
            let targetVC = segue.destination as! DayViewController
            // try to wait for self's selected cell to be set before switching windows
            
            targetVC.selectedCell = senderCell
            targetVC.calendarVC = self
            
            print("DEBUG: selected cell in prepare for segue's target VC is: ", targetVC)
            
        }
        if segue.identifier == "EditEventViewSID" {
            let targetVC = segue.destination as! EditEventViewController
            
            targetVC.calendarView = self
            
        }
    }
    
    


}



