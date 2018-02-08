//
//  SelectDateViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/9/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit

class SelectDateViewController:UIViewController {
    
    var editEventVC:EditEventViewController!
    var selectedDateFromTarget:Date!
    var forEkEvent = false
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        // background view
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor
        
        // Set up for date here, if loading from an existing window
        if self.selectedDateFromTarget != nil {
            self.datePicker.date = selectedDateFromTarget
        }
        
        // TD: continue implementation for selecting a calendar event
        if self.forEkEvent {
            if self.selectedDateFromTarget == nil {
                print("ERROR: selectedDate loaded for EKEvent, but no startDate given")
                self.navigationController?.popViewController(animated: true)
            }
            self.datePicker.datePickerMode = UIDatePickerMode.countDownTimer
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        if self.editEventVC == nil {
            print("ERROR: selectDateVC's editEvent attribute is nil, nothing to pass date back to")
            self.navigationController?.popViewController(animated: true)
            // TD: pop-up explaining the date couldn't be saved
        }
        
        // TD: create a function for this, since it's being done in multiple locations
        // determine whether selected date is in the past
        let currentDate = Date()
        
        if (currentDate > datePicker!.date) {
            let thisAlert = UIAlertController(title: "Invalid date", message: "Please select a date and time that takes place in the future.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)

            print ("DEBUG: user tried to save a date that was in the past")
            
        } else {
            // Pass the selected date back to the previous window
            self.editEventVC.selectedDate = self.datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.short
            self.editEventVC.dateLbl.text = dateFormatter.string(from: self.datePicker.date)
            
            // Now that we have a valid date selected, pop this view controller
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func isValidCountdownDate() -> Bool {
        return false
    }
    
}
