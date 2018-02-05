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
    var date = Date() // we need this to sort combined ek and app events
    var alarmTiedToUserEKEventID = "" // the unique identifier for the EKEVent, used to filter out duplicates
    
    
    
}



class DayViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedCell:CalendarCell!
    var calendarVC:ViewController! // So we can redraw when the window becomes active again
    let dateFormatterPrint = DateFormatter()
    
    @IBOutlet var newEventBarButton:UIBarButtonItem!
    
    // Table View
    @IBOutlet var tableView:UITableView!
    var tableViewItems = [TableViewItem]()
    
    override func viewDidLoad() {
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor

        // if this date is in the past, remove the add event button
        let thisDate = Date()
        let startOfCurrentDate = Calendar.current.startOfDay(for: thisDate)
        
        if self.selectedCell.beginDate < startOfCurrentDate {
            self.newEventBarButton!.isEnabled = false
        }
        
        
        // Load info from the selected cell if it's not nil
        if selectedCell != nil {
            // Set up info
            
            dateFormatterPrint.dateFormat = "MMM dd, yyyy"
            
            self.navigationItem.title = dateFormatterPrint.string(from: selectedCell.beginDate)
            dateFormatterPrint.dateFormat = "MMM dd, yyyy hh:mm"
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        // Keyboard hiding
        hideKeyboardWhenTappedAround()
        
        // draw table
        self.redrawTable()
        
    }
    
    // Utility
    func setGivenEKEventsToTableItems() {

        for ekEvent in self.selectedCell.ekEvents {
            let displayDate = dateFormatterPrint.string(from: ekEvent.startDate)
            let newTableViewItem = TableViewItem(title: ekEvent.title, dateString: displayDate, eventID: "", ekEventID: ekEvent.eventIdentifier, date: ekEvent.startDate, alarmTiedToUserEKEventID: "")
            
            self.tableViewItems.append(newTableViewItem)
        }
    
        
        
        
        
    }
    
    func setGivenEventsToTableItems() {

        if self.selectedCell.events.count == 0 {
            return
        } else {
            for event in selectedCell.events {
                let eventDate = event.alarmDate as Date?
                var alarmTiedToEkEvent = ""
                if event.tiedToEkEvent != nil {
                    alarmTiedToEkEvent = event.tiedToEkEvent!
                }
            
                let eventDateStr = dateFormatterPrint.string(from: eventDate!)
                let newTableItem = TableViewItem(title: event.title!, dateString: eventDateStr, eventID: event.uniqueID!, ekEventID: "", date: eventDate!, alarmTiedToUserEKEventID: alarmTiedToEkEvent)
                self.tableViewItems.append(newTableItem)
            }
            
        }
        
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
            thisCell.dotMarkerLbl.backgroundColor = UIColor.blue
        } else {
            thisCell.dotMarkerLbl.alpha = 0
            thisCell.backgroundColor = UIColor.yellow
        }
        
        thisCell.indexPath = indexPath
        thisCell.dateLbl.text = thisTableViewItem.dateString
        thisCell.titleLbl.text = thisTableViewItem.title
        
        return thisCell
    }
    
    
    func addNewEventToTableView(newEvent:Event) {
        self.selectedCell.events.append(newEvent) // Not necessary for now but might be later
        let thisDateString = dateFormatterPrint.string(from: newEvent.alarmDate! as Date)
        var thisEkID = ""
        if newEvent.tiedToEkEvent != nil {
            thisEkID = newEvent.tiedToEkEvent!
        }
        
        let newTableInfo = TableViewItem(title: newEvent.title!, dateString: thisDateString, eventID: newEvent.uniqueID!, ekEventID:"", date: newEvent.alarmDate! as Date, alarmTiedToUserEKEventID: thisEkID)
        
        self.tableViewItems.append(newTableInfo)
        self.tableView.reloadData()
    }
    
    func updateEventInTableView(newEvent:Event) {
        // we don't need to update the list of core data items because
        // we edit one of them in the edit event VC
        // just reset the list of table info items(can't update the one cell because
        // the date might've changed(and thus the ordering of the cells)
        
        self.redrawTable()
    }
    
    func redrawTable() {
        self.tableViewItems = []
        self.setGivenEventsToTableItems()
        self.setGivenEKEventsToTableItems()
        
        
        // order the table by date
        self.tableViewItems = self.tableViewItems.sorted(by: { $0.date.compare($1.date) == .orderedAscending})
        
        self.tableView.reloadData()
    }

    
    // IBActions
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        if self.calendarVC != nil {
            self.calendarVC.redrawCalendar(useDefaultInfo: false)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we're creating a new event from this window
        if segue.identifier == "NewEventFromDayViewSID" {
            // set the target VC's day view info to self, so it'll trigger
            // a redraw of the table view when a new event is saved
            let targetVC = segue.destination as! EditEventViewController
            targetVC.dayView = self
            targetVC.selectedDate = self.selectedCell.beginDate
            
            
        } else if segue.identifier == "EditEventFromDayViewSID" {
            // load info into the event
            let targetVC = segue.destination as! EditEventViewController
            targetVC.dayView = self
            targetVC.selectedDate = self.selectedCell.beginDate
            // we want to pull the event info from the day view, not
            // from the selected cell
            
            // get the selected table view cell, pull event from that,
            // then give it to the target VC
            // TD: instead of fetching again, assign events and EKEvents to cells
            // themselves
            let selectedTableCell = sender as! DayViewTableViewCell
            if self.tableViewItems[selectedTableCell.indexPath.row].eventID != "" {
                // this is a user created event
                let thisEventArr = CoreDataManager.fetchEventForID(eventID: self.tableViewItems[selectedTableCell.indexPath.row].eventID)
                targetVC.eventToEdit = thisEventArr[0]
            } else {
                // calendar event. TD: initialize view with countdown timer
                // to event time
            }
            
        }
    }
    
    
}
