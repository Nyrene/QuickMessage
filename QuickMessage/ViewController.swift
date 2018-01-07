//
//  ViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/4/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import UIKit



/*
 1) Load calendar view with current month and year
    -toggle for showing user calendar events set to no by default
 
 
 2) if the user toggles yes for including their calendar events
    1) request permission to do so
            if permission denied, display pop-up displaying info
            if permission granted, redraw table with user calendar events
 
 
 
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
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Calendar
        
        self.calendarView?.delegate = self
        self.calendarView?.dataSource = self

        self.setDaysInMonth(nil, givenYear: nil)
        self.setStartingDayOfWeek(givenMonth: nil, givenYear: nil)
 
        
        // TD: set placeholder text of month
        // and year fields to current
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.daysInMonth
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // first starting date is sunday, at 0
        // If the cell is past the starting day of the week, set the
        // if indexPath < startDay // leave blank
        // example: startDay = 3
        // if indexPath == startDay // cell.displayNum = 1
        // if indexPath > startDay // cell.displayNum = indexPath - startDay
        let thisCell = UICollectionViewCell()
        return thisCell
    }
    
    
    
    
    func setDaysInMonth(_ givenMonth:Int!, givenYear:Int!) {
        //note: months start at 1
        
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = self.currentCalendar
        
        
        // set days in the current month, otherwise IFF year and month are given,
        // set days in the given time range
        
        if (givenMonth == nil && givenYear == nil) {
            let currentDate = Date()
            //http://stackoverflow.com/questions/1179945/number-of-days-in-the-current-month-using-iphone-sdk
            let cal = Calendar(identifier:Calendar.Identifier.gregorian)
            let days:Int = (cal as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: currentDate).length
            self.daysInMonth = days
            // print("DEBUG: Days in current month: ", daysInMonth)
            
        } else if (givenMonth != nil && givenYear != nil) {
            if (givenMonth < 1 && givenMonth > 12) {
                self.daysInMonth = 0
                return
            }
            
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            
            let newDate = self.currentCalendar.date(from: dateComponents)
            let days:Int = (self.currentCalendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: newDate!).length
            self.daysInMonth = days
            // print("DEBUG: Days in given month: ", daysInMonth)
           
        } else {
            // TD: display error about requiring both values
            self.daysInMonth = 0
            print("Error: getDaysInMonth: Month OR date set; requires both or neither")
        }

    }
    
    // TD: error checking for this?
    func setStartingDayOfWeek(givenMonth:Int!, givenYear:Int!) {
        //if there's no given date, use current one
        
        if (givenMonth == nil && givenYear == nil) {
            let thisDate = Date()
            let startingDay:Int = (self.currentCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate)
            self.startingDayOfWeek = startingDay
            print("DEBUG: startingDayOfWeek with current date is: ", startingDay)
        } else {
            var dateComponents = DateComponents()
            (dateComponents as NSDateComponents).calendar = self.currentCalendar
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            dateComponents.day = 1
 
            let thisDate = self.currentCalendar.date(from: dateComponents as DateComponents)
            let startingDay:Int = (self.currentCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate!)
            self.startingDayOfWeek = startingDay
        }
    }

    
    // IBActions
    
    // TD: disable go button unless both text fields have values
    @IBAction func goBtnPressed(_ sender: UIButton) {
        // Only run if both fields have values
        // TD: put below into one function that handles errors/throws
        if (self.monthTxtFld.text! != "" && self.yearTxtFld.text! != "") {
            
            
            self.setDaysInMonth(Int(self.monthTxtFld.text!), givenYear: Int(self.yearTxtFld.text!))
            if self.daysInMonth == 0 {
                // Display error about invalid values given
                // TD: better checking for this
                return
            }
            //if the days in month info was valid, set the start day as well
            self.setStartingDayOfWeek(givenMonth:Int(self.monthTxtFld.text!), givenYear: Int(self.yearTxtFld.text!))
            // Redraw the calendar
            self.calendarView?.reloadData()
        }
        
    }


}



