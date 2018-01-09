//
//  DayViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/7/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit
import EventKit

struct TableViewItem {
    var title:String = ""
    var dateString = ""
    var eventID = ""
    var ekEventID = ""
    var alarmTiedToUserEKEventID = "" // the unique identifier for the EKEVent, used to filter out duplicates
    
    
    
}



class DayViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedCell:CalendarCell!
    var calendarVC:ViewController! // So we can redraw when the window becomes active again
    var tableViewItems = [TableViewItem]()
    let dateFormatterPrint = DateFormatter()

    
    override func viewDidLoad() {
        print("Day view was loaded")
        print("selected cell is: ")
        // Load info from the selected cell if it's not nil
        if selectedCell != nil {
            // Set up info
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM, dd, yyyy"
            
            self.navigationItem.title = dateFormatterPrint.string(from: selectedCell.beginDate)
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
        // prepare table view items
        
    }
    
    // Utility
    func addGivenEKEventsToTableItems() {
        // If an event and an ekevent have the same id in event's "added to calendar" id, 
        // then only show the alarm event, with yellow shading and the dot. Don't include
        // the calendar event as well.
        // TD: implement that^
        
        for ekEvent in self.selectedCell.ekEvents {
            let thisEkID = ekEvent.eventIdentifier
            for item in self.tableViewItems {
                if thisEkID == item.alarmTiedToUserEKEventID {
                    // don't include it
                } else {
                    let displayDate = dateFormatterPrint.string(from: ekEvent.startDate)
                    let newTableViewItem = TableViewItem(title: ekEvent.title, dateString: displayDate, eventID: "", ekEventID: ekEvent.eventIdentifier, alarmTiedToUserEKEventID: "")
                    
                    self.tableViewItems.append(newTableViewItem)
                }
            }

        }

    }
    
    func addGivenEventsToTableItems() {
        
    }

    
    
    // TableView
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Delete this when ready to implement - don't implement data transfer here, but in prepareForSegue instead.
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let thisCell = UITableViewCell()
        return thisCell
    }
    
    
    
    // IBActions
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
