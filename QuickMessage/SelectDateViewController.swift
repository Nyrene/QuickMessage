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
    var selectedTimeIntervalFromTarget:TimeInterval!
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
        } else {
            self.datePicker.date = Date()
        }
        
        if self.forEkEvent {
            if self.selectedDateFromTarget == nil {
                print("ERROR: selectedDate loaded for EKEvent, but no startDate given")
                self.navigationController?.popViewController(animated: true)
            }
            self.datePicker.datePickerMode = UIDatePickerMode.countDownTimer
            
            if self.selectedTimeIntervalFromTarget != nil {
                self.datePicker.countDownDuration = self.selectedTimeIntervalFromTarget!
            }
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        if self.editEventVC == nil {
            print("ERROR: selectDateVC's editEvent attribute is nil, nothing to pass date back to")
            self.navigationController?.popViewController(animated: true)
            return
            // TD: pop-up explaining the date couldn't be saved
        }
        
        
        if self.forEkEvent {
            if !self.isValidSelectedCountdownDate() {
                let thisAlert = UIAlertController(title: "Invalid Selection", message: "Please select a valid time interval.", preferredStyle: UIAlertControllerStyle.alert)
                thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(thisAlert, animated: true, completion: nil)
                return
            }
            
            // Valid selection, switch to edit screen
            self.editEventVC.selectedTimeInterval = self.datePicker!.countDownDuration
            let thisDateComponentsFormatter = DateComponentsFormatter()
            self.editEventVC.alertBeforeEventLbl!.text = "Alert " + thisDateComponentsFormatter.string(from: self.datePicker!.countDownDuration)! + " before event"
            
            
        } else { // Proceed for standalone alerts
            if !self.isValidSelectedDate() {
                let thisAlert = UIAlertController(title: "Invalid Selection", message: "Please select a valid date.", preferredStyle: UIAlertControllerStyle.alert)
                thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(thisAlert, animated: true, completion: nil)
                return
            }
            
            // Valid selection, switch to edit event screen
            self.editEventVC.selectedDate = self.datePicker.date
            // TD: move this code into the editDateVC
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.short
            self.editEventVC.dateLbl.text = dateFormatter.string(from: self.datePicker.date)
            
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    func isValidSelectedCountdownDate() -> Bool {
        if self.datePicker!.datePickerMode != .countDownTimer {
            print("ERROR: Attempted to see if datePicker interval was valid, but is in date mode")
            return false
        }
        
        let interval = self.datePicker!.countDownDuration
        // see if the interval before the date gives a date that is in the past
        if self.selectedDateFromTarget.addingTimeInterval(-1 * interval) < Date() {
            print("DEBUG: User tried to save an EK event time interval in the past")
            return false
        }
        
        return true
    }
    
    func isValidSelectedDate() -> Bool {
        if self.datePicker!.datePickerMode != .dateAndTime {
            print("ERROR: Attempted to see if datePicker date was valid, but is in countdown mode")
            return false
        }
        
        if self.datePicker!.date < Date() { // Invalid
            return false
        }
        
        return true
    }
}
