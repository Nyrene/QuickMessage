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
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Calendar
        
        self.calendarView?.delegate = self
        self.calendarView?.dataSource = self

        self.setDaysInMonth(nil, givenYear: nil)
        //DEBUG: try setting it to february 2018
        self.setDaysInMonth(2, givenYear:2018)
 
        
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
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            print("DEBUG: Days in current month: ", daysInMonth)
            
        } else if (givenMonth != nil && givenYear != nil) {
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            
            let newDate = self.currentCalendar.date(from: dateComponents)
            let days:Int = (self.currentCalendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: newDate!).length
            self.daysInMonth = days
            print("DEBUG: Days in given month: ", daysInMonth)
           
        } else {
            // TD: display error about requiring both values
            print("Error: getDaysInMonth: Month OR date set; requires both or neither")
        }

    }

    
    // IBActions
    
    // TD: disable go button unless both text fields have values
    @IBAction func goBtnPressed(_ sender: UIButton) {
        // Only run if both fields have values
        if (self.monthTxtFld.text! != "" && self.yearTxtFld.text! != "") {
            
            //Check that values are valid
            
            self.setDaysInMonth(Int(self.monthTxtFld.text!), givenYear: Int(self.monthTxtFld.text!))
            
            //Redraw the calendar
            self.calendarView?.reloadData()
        }

        
        
        
    }


}



