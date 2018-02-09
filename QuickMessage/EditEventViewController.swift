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
import EventKit

struct contactTableInfo {
    var nameToDisplay:String
    var identifier:String
}

struct EKEventInfo { // this is here until events are assigned to cells
                    // so that new fetches aren't required every time this view
    // is loaded to edit an existing event or create one for a calendar event.
    // purely here to avoid a fetch unnecessarily
    var title:String = ""
    var startDate = Date()
    var identifier = ""
}

enum saveErrors:String {
    case noTitle = "Please add a title for this event."
    case noContacts = "No contacts entered"
    case noDate = "Please select a date for this event."
    case invalidDate = "Please select a valid date for this event."
    case noErrors = "No Errors"
}

class EditEventViewController:UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource, CNContactViewControllerDelegate {
    var selectedDate:Date!
    var selectedTimeInterval:TimeInterval!
    var selectedContactsIDs = [String]()
    var contactInfosForTable = [contactTableInfo]()
    
    var eventToEdit:Event!
    var givenEKEventInfo:EKEventInfo!
    
    var messages:[String] = []// don't edit the messages on the event directly. use an extra
    // string so if the user hits cancel and does some other editing later, the
    // save doesn't incorrectly save the new messages on the event
    
    // for triggering redraws when events have been changed/added
    var calendarView:ViewController!
    var dayView:DayViewController!
    
    @IBOutlet weak var titleTxtFld: UITextField!
    @IBOutlet weak var addContactBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editLocationInfoBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // date/time info
    @IBOutlet weak var editDateBtn:UIButton!
    @IBOutlet weak var alertBeforeEventLbl:UILabel!
    @IBOutlet weak var editAlertBeforeBtn:UIButton!
    @IBOutlet var dateLbl: UILabel!
    let dateFormatterPrint = DateFormatter()
    
    
    // messages
    @IBOutlet var message1Lbl:UILabel!
    @IBOutlet var message2Lbl:UILabel!
    @IBOutlet var message3Lbl:UILabel!
    @IBOutlet var message4Lbl:UILabel!
    
    
    override func viewDidLoad() {
        
        hideKeyboardWhenTappedAround()
        
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor
        dateFormatterPrint.dateFormat = "MMM dd, yyyy, hh:mm"
        
        if self.eventToEdit != nil && self.givenEKEventInfo != nil {
            print("ERROR: too much info given to edit event view")
            self.navigationController?.popViewController(animated: true)
        }
        
        
        if self.eventToEdit != nil {
            // editing an existing event, fill in info
            self.titleTxtFld.text = eventToEdit.title!
            self.dateLbl.text = dateFormatterPrint.string(from: eventToEdit.alarmDate! as Date)
            self.selectedContactsIDs = self.eventToEdit.contactIdentifiers! as! [String]
            self.populateTableFromGivenContactsIDs()
            
            if self.eventToEdit.messages != nil {
                self.messages = self.eventToEdit.messages as! [String]
            } else {
                self.messages = CoreDataManager.getDefaultMessages()
            }
            
            self.deleteBtn.alpha = 1

        } else { // there's no event to delete, so hide the delete button
            self.deleteBtn.alpha = 0
            self.messages = CoreDataManager.getDefaultMessages()
            
        }
        
        if self.givenEKEventInfo != nil {
            // remove the edit button from the date/time selection field
            // make visible the "time before" label and the edit button for that
            print("DEBUG: edit event view was given EKEvent info")
            self.titleTxtFld!.text = givenEKEventInfo.title
            self.dateLbl.text! = self.dateFormatterPrint.string(from: (self.selectedDate))
            self.editDateBtn.alpha = 0
            self.alertBeforeEventLbl.alpha = 1
            self.editAlertBeforeBtn.alpha = 1
        } else {
            self.alertBeforeEventLbl.alpha = 0
            self.editAlertBeforeBtn.alpha = 0
        }
        
        self.reloadMessages()
    }
    
    func setEKEventInfo(title:String, startDate:Date, identifier:String) {
        self.givenEKEventInfo = EKEventInfo()
        self.givenEKEventInfo.title = title
        self.givenEKEventInfo.startDate = startDate
        self.givenEKEventInfo.identifier = identifier
        
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
        self.contactInfosForTable.append(newContactInfo)
        self.tableView.reloadData()
       
        
        /* The below doesn't work, potential iOS bug - returning to this later
        let contactView = CNContactViewController(for: contact)
        contactView.delegate = self
        
        // this is because trying to present the view from this window or
        // self.navigationController doesn't work - possible iOS bug
        // let navigationController = UINavigationController(rootViewController: contactView)
        // self.present(navigationController, animated: false) {}
        
        self.navigationController?.present(contactView, animated: true, completion: nil)
        */
        
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
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        // if a phone number was selected, grab it for messaging info. Otherwise do nothing
        print("DEBUG: value of selected property is: ", contactProperty.value as! String)
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
    
    @objc func deleteContactBtnPressed(_ sender:ContactsTableCellButton) {
        // delete contact info and redraw table
        let indexForDeletedItem = sender.indexPath
        self.contactInfosForTable.remove(at: (indexForDeletedItem?.row)!)
        self.selectedContactsIDs.remove(at:(indexForDeletedItem?.row)!)

        self.tableView.reloadData()
    }
    
    func reloadMessages() {
        if self.messages.count == 0 {
            print("ERROR: no messages in edit event view")
            return
        }
        
        if self.messages.count < 0 {
            print("ERROR: not enough messages to load")
            return
        }
        
        self.message1Lbl!.text! = self.messages[0]
        self.message2Lbl!.text! = self.messages[1]
        self.message3Lbl!.text! = self.messages[2]
        self.message4Lbl!.text! = self.messages[3]
        
    }

    
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editAlertBeforeBtnPressed(_ sender:UIButton) {
        
    }
    
    // TD: this needs soooooo much cleanup
    // cases:
    // 1) editing same event, changed date, remove it from table
    // 2) editing same event, didn't change date, don't remove it from table but
    //      redraw the table
    // 3) new event, same date, add to table/redraw
    // 4) new event, different date, don't add to table
    /*
     if new {
     -save newEvent
     if time interval, calculate the alarm date
        -if tiedToCalendarEvent, calculate time interval here
     
     
     // for now
     if self.calendarView != nil { reload calendar view }
     if self.dayView != nil { reload day view }
    
     } else {
     editing:
     if time interval, calculate the alarm date
        -save with update info (pull updated info)
     
     
     }
     
 
    */
    func validateCurrentSettingsBeforeSave() -> saveErrors {
        var errorType = saveErrors.noErrors
        
       if self.titleTxtFld!.text == nil || self.titleTxtFld!.text == "" {
            errorType = saveErrors.noTitle
            return errorType
        }
        
        // right now the date is checked for validity when it is selected in the
        // SelectDateVC, hence not checking that here.
        if self.selectedDate == nil && self.selectedTimeInterval == nil {
            // TD: make another error type for no selected time interval
            errorType = saveErrors.noDate
            return errorType
        }
        
        return errorType
    }
    
    func isCurrentSelectedDateSameAsPrecedingDayView() -> Bool {
        if self.dayView != nil {
            if Calendar.current.startOfDay(for:self.selectedDate) == Calendar.current.startOfDay(for:self.dayView.selectedCell.beginDate) {
                return true
            } else {
                return false
            }
        } else {
            // TD: throw here - no dayView exists
            print("ERROR: in \(#function), self.dayView is nil")
            return false
        }
    }
    
    @IBAction func saveBtnPressed(_ sender:UIBarButtonItem) {
        let eventTitle = self.titleTxtFld.text
        var newSavedEvent:Event!
        var EKID = ""
        var eventDate:Date!
        
        if self.givenEKEventInfo != nil {EKID = givenEKEventInfo.identifier}
        
        // 1) Validate user given info
        let saveError = self.validateCurrentSettingsBeforeSave()
        if saveError != .noErrors {
            let thisAlert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
            switch saveError {
            case .noDate:
                thisAlert.title? = "No Date Given"
                thisAlert.message? = saveError.rawValue
                break
            case .noContacts:
                thisAlert.title? = "No Contacts Given"
                thisAlert.message? = saveError.rawValue
                break
            case .invalidDate:
                thisAlert.title? = "No Alert Time Given"
                thisAlert.message? = "Please complete the necessary alert time information."
                break
            default:
                thisAlert.title? = "Unable to save event"
                thisAlert.message? = "Please double check all settings and try again."
                break
            }
            return
        } // validation done
        
        
        // some setup
        if self.selectedTimeInterval != nil {
            eventDate = self.givenEKEventInfo!.startDate.addingTimeInterval((-1 * self.selectedTimeInterval!))
        } else {
            if self.selectedDate != nil {
                eventDate = self.selectedDate!
            }
        }
    
    
        
        // save event
        if self.eventToEdit == nil { // NEW event
            
            newSavedEvent = CoreDataManager.saveNewEventWithInformationAndReturn(title: eventTitle!, eventDate: eventDate!, contactIDs: self.selectedContactsIDs, tiedToEKID: EKID, uniqueID: nil, messages: self.messages)
            
        } else { // EXISTING event editing
            // Don't bother saving EKID here (if there is one) because that shouldn't change
            CoreDataManager.saveEventInformation(givenEvent: self.eventToEdit, eventTitle: self.titleTxtFld.text!, alarmDate: eventDate!, eventContactIDs: self.selectedContactsIDs, messages: self.messages)
        }
        
        
        
        
        // Reloading views - event has been saved at this point
        if self.dayView != nil && self.isCurrentSelectedDateSameAsPrecedingDayView() {
                // add an event to the day view table
                print("DEBUG: new event to be saved with same date on day view")
            if newSavedEvent != nil {
                self.dayView.addNewEventToTableView(newEvent: newSavedEvent)
            }
            self.dayView.redrawTable()
        }
           
        
        if self.calendarView != nil {
            self.calendarView.redrawCalendar(useDefaultInfo: false)
        }
       
        print("DEBUG: selectedContactsIDs.count is: ", self.selectedContactsIDs.count)
        self.navigationController?.popViewController(animated: true)
        // end of savebtnpressed
        
    }
    
    // TD: this could be cleaned up a lot
    @IBAction func addContactBtnPressed(_ sender: UIButton) {
        let authStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        func completionHandler(_ granted: Bool, error: Error?) -> Void {
            if granted == false {
                let thisAlert = UIAlertController(title: "Permission Denied", message: "Please enable accessing contacts in your settings to add contacts.", preferredStyle: UIAlertControllerStyle.alert)
                thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                present(thisAlert, animated: true, completion: nil)
                return

            } else {
                let contactsVC = CNContactPickerViewController()
                contactsVC.delegate = self
                self.present(contactsVC, animated: true, completion: nil)
            }
        }
        switch authStatus {
        case .authorized:
            let contactsVC = CNContactPickerViewController()
            contactsVC.delegate = self
            self.present(contactsVC, animated: true, completion: nil)
            break
        case .denied:
            let thisAlert = UIAlertController(title: "Permission Denied", message: "Please enable accessing contacts in your settings to add contacts.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
            return
        case .notDetermined:
            let thisContactStore = CNContactStore()
            thisContactStore.requestAccess(for: CNEntityType.contacts, completionHandler: completionHandler(_:error:))
            break
        case .restricted:
            let thisAlert = UIAlertController(title: "Permission Restricted", message: "Please enable accessing contacts in your settings to add contacts.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
            break
        }


    }
    
    @IBAction func deleteBtnPressed(_ sender:UIButton) {
        CoreDataManager.deleteObject(givenEvent: self.eventToEdit)
        
        // reload table view - remove the core data object from the list and
        // redraw table
        if self.dayView != nil {
            self.dayView.selectedCell.events = self.dayView.selectedCell.events.filter { $0 != eventToEdit }
            self.dayView.redrawTable()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // user is editing a date
        if segue.identifier == "EditDateSID" {
            // set self to the VC's attribute, so that this view will be updated when a date is saved
            let targetVC = segue.destination as! SelectDateViewController
            targetVC.editEventVC = self
            
            // load the date with the current one if we have one
            if self.eventToEdit != nil {
                targetVC.selectedDateFromTarget = self.eventToEdit.alarmDate! as Date
            }
            
            else if self.selectedDate != nil {
                targetVC.selectedDateFromTarget = self.selectedDate
            }
        }
        
        if segue.identifier == "EditMessagesSID" {
            let targetVC = segue.destination as! EditMessagesViewController
            targetVC.editEventWindow = self
            targetVC.messages = self.messages
            
        }
        
        if segue.identifier == "EditAlertBeforeSID" {
            let targetVC = segue.destination as! SelectDateViewController
            if self.givenEKEventInfo != nil && self.selectedDate != nil {
                targetVC.selectedDateFromTarget = self.givenEKEventInfo.startDate
                targetVC.forEkEvent = true
                targetVC.selectedDateFromTarget = self.selectedDate
                targetVC.editEventVC = self
            }
        }
        
    }
    
    
    
}
