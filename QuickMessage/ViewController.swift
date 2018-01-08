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
    
    
    var currentCalendar = Calendar.current
    var daysInMonth:Int = 0
    var startingDayOfWeek:Int = 0 //this is for which cell to begin displaying the date on
    var includeUserEKEvents:Bool = false
    
    let eventStore = EKEventStore()
    
    
    // Menu area
    @IBOutlet weak var userEventsToggle: UISwitch!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        
        let dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = self.currentCalendar
        let currentDate = Date()
        self.monthTxtFld.placeholder = String(currentCalendar.component(.month, from: currentDate))
        self.yearTxtFld.placeholder = String(currentCalendar.component(.year, from: currentDate))
    
        
        // Calendar
        
        self.calendarView?.delegate = self
        self.calendarView?.dataSource = self
        
        self.setCalendarInfo(givenMonth: currentCalendar.component(.month, from: currentDate), givenYear: currentCalendar.component(.year, from: currentDate))

        // Event info
        // if we already have access, go ahead and load user events in
        // TD2: load toggle setting from previous run automatically
        if EKEventStore.authorizationStatus(for: EKEntityType.event) == .authorized {
            // TD: draw calendar with user events
        }

 
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
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
        
        
        return thisCell
    }
    
    
    
    // Calendar info set up
    func setCalendarInfo(givenMonth:Int!, givenYear:Int!) {
        self.daysInMonth = getDaysInMonth(givenMonth, givenYear:givenYear!)
        self.startingDayOfWeek = getStartingDayOfWeek(givenMonth:givenMonth, givenYear:givenYear)
        
    }
    
    func redrawCalendar(useDefaultInfo:Bool) {
        if (useDefaultInfo == true) {
            self.setCalendarInfo(givenMonth: nil, givenYear: nil)
            
        }
        
        if self.includeUserEKEvents == true {
            // TD: do stuff to facilitate that
        }
        
        self.calendarView?.reloadData()
        
        
    }
    
    
    func getDaysInMonth(_ givenMonth:Int!, givenYear:Int!) -> Int {
        //note: months start at 1
        
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = self.currentCalendar
        
        // set days in the current month, otherwise IFF year and month are given,
        // set days in the given time range
        
        if (givenMonth == nil && givenYear == nil) {
            let currentDate = Date()
            // http://stackoverflow.com/questions/1179945/number-of-days-in-the-current-month-using-iphone-sdk
            
            let days:Int = (currentCalendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: currentDate).length
            return days
            // print("DEBUG: Days in current month: ", daysInMonth)
            
        } else if (givenMonth != nil && givenYear != nil) {
            if (givenMonth < 1 && givenMonth > 12) {
                return 0
            }
            
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            
            let newDate = self.currentCalendar.date(from: dateComponents)
            let days:Int = (self.currentCalendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: newDate!).length
            
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
            let startingDay:Int = (self.currentCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate)
            print("DEBUG: startingDayOfWeek with current date is: ", startingDay)
            return startingDay
        } else {
            var dateComponents = DateComponents()
            (dateComponents as NSDateComponents).calendar = self.currentCalendar
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            dateComponents.day = 1
 
            let thisDate = self.currentCalendar.date(from: dateComponents as DateComponents)
            let startingDay:Int = (self.currentCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate!)
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
    
    
    @IBAction func toggleSwitched(_ sender: UISwitch) {
 
        if (self.userEventsToggle.isOn) {
            // Depending on the permissions status, redraw the calendar with events
            switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
            case .authorized:
                self.includeUserEKEvents = true
                self.redrawCalendar(useDefaultInfo: false)
                break;
            case .notDetermined:
                // TD: display pop-up
                func completionHandler(_ granted: Bool, error: Error?) -> Void{
                    if granted == true {
                        print("granted")
                    } else {
                        self.userEventsToggle.isOn = false
                        // User has said no to calendar access; display alert
                        // TD: display alert
                        print("not granted")
                    }
                    
                }
                eventStore.requestAccess(to: EKEntityType.event, completion: completionHandler as EKEventStoreRequestAccessCompletionHandler)
                break;
            case .denied:
                // TD: display pop-up
                self.userEventsToggle.isOn = false
                break;
            case .restricted:
                // TD: display pop-up about restricted status
                self.userEventsToggle.isOn = false
                break;
            }
            
            
        } else { //user has toggled it off
            self.includeUserEKEvents = false
            self.redrawCalendar(useDefaultInfo: false)
            
        }
 
         /*
 
         
         adding events to current calendar:
         if switch is on, grab list of events for the currently shown month
         if list  !ordered by dates
            order it by date
            for each cell loaded
                put events for that date in table cell
                    find first instance of event with that day
                    while day matches int(displayNum), add to
         
         
 */
        
        

    }
    


}



