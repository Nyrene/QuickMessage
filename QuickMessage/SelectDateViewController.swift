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
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        // Set up for date here, if loading from an existing window
        if self.selectedDateFromTarget != nil {
            self.datePicker.date = selectedDateFromTarget
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        if self.editEventVC == nil {
            print("ERROR: selectDateVC's editEvent attribute is nil, nothing to pass date back to")
            // TD: pop-up explaining the date couldn't be saved
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
    
}
