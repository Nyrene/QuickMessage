//
//  DayViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/7/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit


class DayViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    var selectedCell:CalendarCell!
    var calendarVC:ViewController! // So we can redraw when the window becomes active again
    
    override func viewDidLoad() {
        print("Day view was loaded")
        print("selected cell is: ")
        // Load info from the selected cell if it's not nil
        if selectedCell != nil {
            // Set up info
            
            let thisDateFormatter = DateFormatter()
            // thisDateFormatter.dateStyle = DateFormatter.Style.medium
            // thisDateFormatter.timeStyle = DateFormatter.Style.medium
            
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM, dd, yyyy"
            
            self.navigationItem.title = dateFormatterPrint.string(from: selectedCell.beginDate)
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisCell = UITableViewCell()
        return thisCell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    // IBActions
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
