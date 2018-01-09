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
    let dateFormatterPrint = DateFormatter()
    
    // Table View
    @IBOutlet var tableView:UITableView!
    var tableViewItems = [TableViewItem]()
    
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
        self.addGivenEKEventsToTableItems()
        self.tableView.reloadData()
        
    }
    
    // Utility
    func addGivenEKEventsToTableItems() {
        // If an event and an ekevent have the same id in event's "added to calendar" id, 
        // then only show the alarm event, with yellow shading and the dot. Don't include
        // the calendar event as well.
        // TD: implement that^
        
        
        if (self.selectedCell.events.count > 0) {
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

        } else { // nothing to compare to, add all events to the table view items
            for ekEvent in self.selectedCell.ekEvents {
                let displayDate = dateFormatterPrint.string(from: ekEvent.startDate)
                let newTableViewItem = TableViewItem(title: ekEvent.title, dateString: displayDate, eventID: "", ekEventID: ekEvent.eventIdentifier, alarmTiedToUserEKEventID: "")
                
                self.tableViewItems.append(newTableViewItem)
            }
        }
        
        
        
        
    }
    
    func addGivenEventsToTableItems() {
        
        
    }

    
    
    // TableView
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Delete this when ready to implement - don't implement data transfer here, but in prepareForSegue instead (because the segue won't wait for this function to finish
        // before switching views.
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewItems.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TD: sort by date
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "DayViewTableViewCell") as! DayViewTableViewCell
        
        let thisTableViewItem = self.tableViewItems[indexPath.row]
        if thisTableViewItem.eventID == "" {
            thisCell.dotMarkerLbl.alpha = 0
        }
        
        thisCell.dateLbl.text = thisTableViewItem.dateString
        thisCell.titleLbl.text = thisTableViewItem.title
        
        return thisCell
    }
    
    
    
    // IBActions
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
