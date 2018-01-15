//
//  EditEventViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/7/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import ContactsUI

struct contactTableInfo {
    var nameToDisplay:String
    var identifier:String
}


class EditEventViewController:UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    var selectedDate:Date!
    var selectedContactsIDs = [String]()
    var contactInfosForTable = [contactTableInfo]()
    
    var eventToEdit:Event!
    
    // for triggering redraws when events have been changed/added
    var calendarView:ViewController!
    var dayView:DayViewController!
    
    @IBOutlet weak var titleTxtFld: UITextField!
    
    @IBOutlet var dateLbl: UILabel!
    
    @IBOutlet weak var addContactBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editLocationInfoBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        
        hideKeyboardWhenTappedAround()
        
         let thisImage = UIImage(named: "background_3.jpg")
         let backgroundColor = UIColor(patternImage: thisImage!)
         self.view.backgroundColor = backgroundColor
        
        if self.eventToEdit != nil {
            // editing an existing event, fill in info
            self.titleTxtFld.text = eventToEdit.title!
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd, yyyy, hh:mm"
            self.dateLbl.text = dateFormatterPrint.string(from: eventToEdit.alarmDate! as Date)
            self.selectedContactsIDs = self.eventToEdit.contactIdentifiers! as! [String]
            self.populateTableFromGivenContactsIDs()
            
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        // TD2: later on, will implement more for choosing specific numbers
        
        // add contact identifier info
        let thisContactID = contact.identifier
        self.selectedContactsIDs.append(thisContactID)
        
        // convert to contactInfo for table and add it
        let contactName = contact.givenName + " " + contact.familyName
        let contactID = contact.identifier
        let newContactInfo = contactTableInfo(nameToDisplay: contactName, identifier: contactID)
        self.selectedContactsIDs.append(contact.identifier)
        self.contactInfosForTable.append(newContactInfo)
        
        
        self.tableView.reloadData()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func populateTableFromGivenContactsIDs() {
        let store = CNContactStore()
        let predicate: NSPredicate = CNContact.predicateForContacts(withIdentifiers: self.selectedContactsIDs)
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey]
        let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as [CNKeyDescriptor])
        
        for item in contacts {
            let thisContactName = item.givenName + " " + item.familyName
            let thisContactInfo = contactTableInfo(nameToDisplay: thisContactName, identifier: item.identifier)
            self.contactInfosForTable.append(thisContactInfo)
            
        }
        
        self.tableView.reloadData()
    }
    
    // Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactInfosForTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableCell") as! ContactsTableCell
        
        // make self the target for the delete button on the contact cell
        thisCell.deleteBtn.addTarget(self, action: #selector(EditEventViewController.deleteContactBtnPressed(_:)), for:UIControlEvents.touchUpInside)
        
        // now set up rest of contact info
        let cellInfo = self.contactInfosForTable[indexPath.row]
        thisCell.contactNameLbl.text = cellInfo.nameToDisplay
        
        // include indexPath info of the contact so that if the delete button is pressed,
        // the delete function knows which cell was selected
        thisCell.deleteBtn.indexPath = indexPath
        
        return thisCell
    }
    
    func deleteContactBtnPressed(_ sender:ContactsTableCellButton) {
        // delete contact info and redraw table
        let indexForDeletedItem = sender.indexPath
        self.contactInfosForTable.remove(at: (indexForDeletedItem?.row)!)
        self.selectedContactsIDs.remove(at:(indexForDeletedItem?.row)!)
        self.tableView.reloadData()
    }

    
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender:UIBarButtonItem) {
        // Uncomment when saving functions are finished
        let eventTitle = self.titleTxtFld.text
        
        // TD: switch these to guard statements	
        // https://thatthinginswift.com/guard-statement-swift/
        
        if self.titleTxtFld!.text == "" {
            // TD2: add alert to alert controller
            let thisAlert = UIAlertController(title: "No Title Given", message: "Please add a title for this event.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
            if self.calendarView != nil {
                self.calendarView.redrawCalendar(useDefaultInfo: false)
            }
            return
        }
        
        
        if self.selectedDate == nil {
            // TD2: add popup to popup controller later
            let thisAlert = UIAlertController(title: "No Date Selected", message: "Please select a date for this event.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
            return
        }
        
        if self.selectedContactsIDs.count == 0 || self.contactInfosForTable.count == 0 {
            let thisAlert = UIAlertController(title: "No contacts selected", message: "Please select one or more contacts for this event.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
            return
        }
        
        var haveSaved = false
        // cases:
        // 1) editing same event, changed date, remove it from table
        // 2) editing same event, didn't change date, don't remove it from table but
        //      redraw the table
        // 3) new event, same date, add to table/redraw
        // 4) new event, different date, don't add to table
        
        // day view always comes from selecting a cell, so we can use
        // selectedCell.date to check the date (compare it with Calendar.current.startOfDay(for: eventToEdit.alarmDate! as Date) == Calendar.current.startOfDay(for: self.eventToEdit.alarmDate! as Date)
        
        // test if the date has changed:
        if self.dayView != nil {
            if Calendar.current.startOfDay(for:self.selectedDate) == Calendar.current.startOfDay(for:self.dayView.selectedCell.beginDate) {
                if self.eventToEdit != nil {
                    // redraw the table view
                    // save the existing event
                    CoreDataManager.saveEventInformation(givenEvent: self.eventToEdit, eventTitle: self.titleTxtFld.text!, alarmDate: self.selectedDate, eventContactIDs: self.selectedContactsIDs)
                    self.dayView.redrawTable()
                    haveSaved = true
                    
                } else {
                    // it's a new event, add it to the day view's list of events
                    let thisNewEvent = CoreDataManager.saveNewEventWithInformationAndReturn(title: eventTitle!, eventDate: self.selectedDate, contactIDs: self.selectedContactsIDs, tiedToEKID: "", uniqueID: nil)
                    self.dayView.addNewEventToTableView(newEvent: thisNewEvent)
                    haveSaved = true
                }
                
            } else {
                // the new event's date doesn't match the day view. Save, but 
                // don't update the table view
                if self.eventToEdit == nil {
                    // new event
                    CoreDataManager.saveNewEventWithInformation(title: eventTitle!, eventDate: self.selectedDate, contactIDs: self.selectedContactsIDs, tiedToEKID: "", uniqueID: nil)
                    haveSaved = true
                } else {
                    // save existing event
                    CoreDataManager.saveEventInformation(givenEvent: self.eventToEdit, eventTitle: self.titleTxtFld.text!, alarmDate: self.selectedDate, eventContactIDs: self.selectedContactsIDs)
                    haveSaved = true
                }
            }
        }
        
        if self.calendarView != nil {
            if self.eventToEdit != nil {
                CoreDataManager.saveEventInformation(givenEvent: self.eventToEdit, eventTitle: self.titleTxtFld.text!, alarmDate: self.selectedDate, eventContactIDs: self.selectedContactsIDs)
            } else {
                CoreDataManager.saveNewEventWithInformation(title: eventTitle!, eventDate: self.selectedDate, contactIDs: self.selectedContactsIDs, tiedToEKID: "", uniqueID: nil)
            }
            self.calendarView.redrawCalendar(useDefaultInfo: false)
            haveSaved = true
        }
        
        
        if haveSaved == false {
            print("ERROR: saveBtnPressed, but no case occurred where saved")
        }
        self.navigationController?.popViewController(animated: true)
        // end of savebtnpressed
        
    }
    
    @IBAction func addContactBtnPressed(_ sender: UIButton) {
        let contactsVC = CNContactPickerViewController()
        contactsVC.delegate = self

        self.present(contactsVC, animated: true, completion: nil)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // user is editing a date
        if segue.identifier == "EditDateSID" {
            // set self to the VC's attribute, so that this view will be updated when a date is saved
            let targetVC = segue.destination as! SelectDateViewController
            targetVC.editEventVC = self
            
            // load the date with the current one if we have one
            if self.selectedDate != nil {
                targetVC.selectedDateFromTarget = self.selectedDate
            }
        }
        
    }
    
    
    
}
