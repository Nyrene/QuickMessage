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
    var date:Date // we need this to sort combined ek and app events
    var event:Event!
    var ekEvent:EKEvent!
}



class DayViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedCell:CalendarCell!
    var calendarVC:ViewController! // So we can redraw when the window becomes active again
    let dateFormatterPrint = DateFormatter()
    
    var ekEventStore:EKEventStore!
    
    @IBOutlet var newEventBarButton:UIBarButtonItem!
    
    // Table View
    @IBOutlet var tableView:UITableView!
    var tableViewItems = [TableViewItem]()
    
    override func viewDidLoad() {
        self.setViewColors()
        
        // Load info from the selected cell if it's not nil
        if selectedCell != nil {
            // Set up info
            
            dateFormatterPrint.dateFormat = "MMM dd, yyyy"
            self.navigationItem.title = dateFormatterPrint.string(from: selectedCell.beginDate)
            dateFormatterPrint.dateFormat = "MMM dd, yyyy hh:mm"
            
        } else {
            print ("ERROR: no cell given to day view, popping VC")
            self.navigationController?.popViewController(animated: true)
        }
        
        // Keyboard hiding
        hideKeyboardWhenTappedAround()
        
        // draw table
        self.redrawTable()
        
        // if this date is in the past, remove the add event button
        let thisDate = Date()
        let startOfCurrentDate = Calendar.current.startOfDay(for: thisDate)
        if self.selectedCell.beginDate < startOfCurrentDate {
            self.newEventBarButton!.isEnabled = false
        }
    }
    
    // Utility
    func setGivenEKEventsToTableItems() {

        for ekEvent in self.selectedCell.ekEvents {
            var ekEventTitle = "Untitled Calendar Event"
            if ekEvent.title != nil {
                ekEventTitle = ekEvent.title
            }
            
            if ekEvent.startDate == nil {
                print("ERROR: Attempted to add EKEvent to day view table, but date is nil, skipping")
                continue
            }
    
            let newTableViewItem = TableViewItem(title: ekEventTitle, date: ekEvent.startDate!, event: nil, ekEvent: ekEvent)
            self.tableViewItems.append(newTableViewItem)
        }
    
    }
    
    func setGivenEventsToTableItems() {

        for event in selectedCell.events {
            guard let eventDate = event.alarmDate as Date? else {
                print("ERROR: Day view given event does not have a date, skipping")
                continue
            }
            
            var eventTitle = "Untitled event"
            if event.title != nil {
                eventTitle = event.title!
            }
        
            // let newTableItem = TableViewItem(title: event.title!, dateString: eventDateStr, eventID: event.uniqueID!, ekEventID: "", date: eventDate!, alarmTiedToUserEKEventID: alarmTiedToEkEvent)
            let newTableItem = TableViewItem(title: eventTitle, date: eventDate, event: event, ekEvent: nil)
            self.tableViewItems.append(newTableItem)
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
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "DayViewTableViewCell") as! DayViewTableViewCell
        
        let thisTableViewItem = self.tableViewItems[indexPath.row]
        if thisTableViewItem.event != nil {
            thisCell.eventTypeLbl.backgroundColor = UIColor.yellow
        } else {
            thisCell.eventTypeLbl.backgroundColor = UIColor.yellow
        }
        
        thisCell.indexPath = indexPath
        thisCell.dateLbl.text = self.dateFormatterPrint.string(from: thisTableViewItem.date)
        thisCell.titleLbl.text = thisTableViewItem.title
        
        return thisCell
    }
    
    func addNewEventToTableView(newEvent:Event) {
        self.selectedCell.events.append(newEvent)
        var eventTitle = "Untitled Event"
        if newEvent.title != nil {
            eventTitle = newEvent.title!
        }
        
        if newEvent.alarmDate == nil {
            print("ERROR: attempted to add new event to table view, but no date given, skipping")
            return
        }
        
        let newTableInfo = TableViewItem(title: eventTitle, date: newEvent.alarmDate!, event: newEvent, ekEvent: nil)
        
        // insert the new table view item at the current spot
        self.tableViewItems.append(newTableInfo)
        self.sortTableViewItemsByDate()
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
        // Completely refresh/reload the table
        if self.tableViewItems.count != 0 {
            self.tableViewItems = []
        }
        
        self.setGivenEventsToTableItems()
        self.setGivenEKEventsToTableItems()
        
        
        // order the table by date
        self.sortTableViewItemsByDate()
        
        self.tableView.reloadData()
    }
    
    func sortTableViewItemsByDate() {
        if self.tableViewItems.count != 0 {
            self.tableViewItems = self.tableViewItems.sorted(by: { $0.date.compare($1.date) == .orderedAscending})
        }
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
           
            let selectedTableCell = sender as! DayViewTableViewCell
            let thisInfoItem = self.tableViewItems[selectedTableCell.indexPath.row]
            
            
            if thisInfoItem.event != nil {
                targetVC.eventToEdit = self.tableViewItems[selectedTableCell.indexPath.row].event
            }
            
            if thisInfoItem.ekEvent != nil {
                targetVC.ekEvent = thisInfoItem.ekEvent
            }
            
        
            
            
            // TD: figure out why was I doing it this way instead of just assigning the
            // tableViewItem to the cell??
            
            
            
            if thisInfoItem.eventID != "" && thisInfoItem.alarmTiedToUserEKEventID == "" {
                // this is a user created, standalone event
                let thisEventArr = CoreDataManager.fetchEventForID(eventID: thisInfoItem.eventID)
                targetVC.eventToEdit = thisEventArr[0]
            } else if thisInfoItem.ekEventID != "" {
                // calendar event - we're not editing the actual calendar event at all
                // so don't bother fetching and assigning the event
                let ekEventTitle = thisInfoItem.title
                let ekEventDate = thisInfoItem.date
                let ekEventIdentifier = thisInfoItem.ekEventID
                
                targetVC.selectedDate! = thisInfoItem.date
                targetVC.setEKEventInfo(title: ekEventTitle, startDate: ekEventDate, identifier:ekEventIdentifier)
            } else if thisInfoItem.alarmTiedToUserEKEventID != "" {
                let thisEventArr = CoreDataManager.fetchEventForID(eventID: thisInfoItem.eventID)
                targetVC.eventToEdit = thisEventArr[0]
            }
            
        }
    }
    
    func setViewColors() {
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor
    }
    
    
}
