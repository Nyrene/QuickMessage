//
//  ViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/4/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import UIKit
import EventKit


/*
 Next steps:
 
*/



// TD: things to look up:
// weak vs strong, atomic vs nonatomic, optionals



//This contains the calendar view and is the starting point for the app
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    // Calendar
    @IBOutlet var calendarView:UICollectionView?
    @IBOutlet weak var monthTxtFld: UITextField!
    @IBOutlet weak var yearTxtFld: UITextField!
    
    var daysInMonth:Int = 0
    var startingDayOfWeek:Int = 0 //this is for which cell to begin displaying the date on
    var includeUserEKEvents:Bool = false
    var selectedCell:CalendarCell! = nil
    
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
        if (indexPath.item) < (self.startingDayOfWeek - 1) {
            thisCell.alpha = 0
        } else {
            thisCell.displayNum.text = String(indexPath.item - self.startingDayOfWeek + 2)
        }
        
        // Add EKEvents if required
        if self.includeUserEKEvents == true && thisCell.displayNum.text != "" && thisCell.alpha != 0 {
            // Get start and end date for this cell
            var thisDateComponents = DateComponents()
            thisDateComponents.year = self.year
            thisDateComponents.month = self.month
            thisDateComponents.day = Int(thisCell.displayNum.text!)
            thisDateComponents.hour = 0
            thisDateComponents.minute = 0
            
            let beginDate = Calendar.current.date(from: thisDateComponents)
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
            let thisPredicate = self.eventStore.predicateForEvents(withStart: beginDate!, end: endDate!, calendars: nil)
            
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
        
        
        return thisCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCell = self.calendarView?.cellForItem(at: indexPath)
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
                        print("granted")
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
        if segue.identifier == "EventViewSID" {
            // Load the calendar events for that day into the window
            //let thisViewController = DayViewCon
            
            let targetVC = segue.destination as! DayViewController
            //targetVC.navigationController.title = "Event Date"
            
        }
    }
    
    


}



