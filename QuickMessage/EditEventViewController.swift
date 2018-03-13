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



enum saveErrors:String {
    case noTitle = "Please add a title for this event."
    case noContacts = "No contacts entered"
    case noDate = "Please select a date for this event."
    case invalidDate = "Please select a valid date for this event."
    case noTimeInterval = "Please select how early before the event you'd like to be alerted."
    case noErrors = "No Errors"
}

class EditEventViewController:UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource, CNContactViewControllerDelegate {
    var selectedDate:Date!
    var selectedTimeInterval:TimeInterval!
    var selectedContactsIDs = [String]()
    var contactInfosForTable = [contactTableInfo]()
    
    var eventToEdit:Event!
    var givenEKEvent:EKEvent!
    
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
    
    // TD: clean up/revise, could have a function for each case
    // and a switch statement
    override func viewDidLoad() {
        
        hideKeyboardWhenTappedAround()
        
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor
        dateFormatterPrint.dateFormat = "MMM dd, yyyy, hh:mm"
        
        if self.givenEKEvent != nil {
            self.loadGivenEKEventInfo()
        }
        
        if self.eventToEdit != nil {
            self.loadGivenEventInfo()
        }
        
        if self.eventToEdit == nil && self.givenEKEvent == nil {
            self.setUIFor(editDate: true, newEvent: true)
        }
        
        if self.messages.count == 0 {
            self.messages = CoreDataManager.getDefaultMessages()
            self.reloadMessages()
        }
        
        // message label graphics
        let messageLblImage = UIImage(named:"whiteroundlabel")
        let imageSize = self.message1Lbl.frame.size
        UIGraphicsBeginImageContext(imageSize)
        messageLblImage?.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let resizedMessageLblImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.message1Lbl.backgroundColor = UIColor(patternImage: resizedMessageLblImage!)
        self.message2Lbl.backgroundColor = UIColor(patternImage: resizedMessageLblImage!)
        self.message3Lbl.backgroundColor = UIColor(patternImage: resizedMessageLblImage!)
        self.message4Lbl.backgroundColor = UIColor(patternImage: resizedMessageLblImage!)
        
    }

    // BRANCH: codecleanup
    func setUIFor(editDate:Bool, newEvent:Bool) {
        if editDate {
            self.editAlertBeforeBtn.alpha = 0
            self.alertBeforeEventLbl.alpha = 0
            self.editDateBtn.alpha = 1
            self.titleTxtFld!.isEnabled = true
        } else {
            self.editAlertBeforeBtn.alpha = 1
            self.alertBeforeEventLbl.alpha = 1
            self.editDateBtn.alpha = 0
            self.titleTxtFld!.isEnabled = false
        }
            
        if newEvent {
            self.deleteBtn!.alpha = 0
        }
    }
    
    func loadGivenEKEventInfo() {
        if self.givenEKEvent == nil {
            print("Error: tried to set UI for given EK info, but is nil")
            return
        }
        
        self.titleTxtFld!.text = self.givenEKEvent.title
        self.dateLbl!.text = self.dateFormatterPrint.string(from: self.givenEKEvent.startDate)
        self.selectedDate = self.givenEKEvent.startDate
        
        self.setUIFor(editDate: false, newEvent: true)
    }
    
    func loadGivenEventInfo() {
        if self.eventToEdit == nil {
            print("Error: tried to set UI for given event info, but is nil")
            return
        }
        
        self.selectedDate = self.eventToEdit!.alarmDate
        if self.eventToEdit!.title == nil {
            if self.eventToEdit!.title == "" {
            self.titleTxtFld!.text = "Untitled Event"
            }
        } else {
             self.titleTxtFld!.text = self.eventToEdit!.title!
        }
        
        if self.eventToEdit.contactIdentifiers != nil {
            self.selectedContactsIDs = self.eventToEdit.contactIdentifiers! as! [String]
            self.populateTableFromGivenContactsIDs()
        }
        
        if self.eventToEdit.messages != nil {
            self.messages = eventToEdit.messages as! [String]
            self.reloadMessages()
        } else {
            self.messages = CoreDataManager.getDefaultMessages()
        }
        self.dateLbl!.text = self.dateFormatterPrint.string(from: self.eventToEdit.alarmDate!)
        
        // if EKEvent info associated
        if self.eventToEdit!.tiedToEkEvent != nil && self.eventToEdit!.tiedToEkEvent != "" {
            guard let thisEKEvent = EKEventStore().event(withIdentifier: eventToEdit.tiedToEkEvent!) else {
                print("ERROR: no event with this identifier found")
                return
            }
            
            let dateCompsFormatter = DateComponentsFormatter()
            
            self.selectedDate = thisEKEvent.startDate!
            self.selectedTimeInterval = eventToEdit.alarmDate!.timeIntervalSince(self.selectedDate!)
            
            self.titleTxtFld!.text = thisEKEvent.title!
            self.dateLbl!.text = dateFormatterPrint.string(from: self.selectedDate!)
            if self.selectedTimeInterval > 0 {
                self.selectedTimeInterval = self.selectedTimeInterval * -1
            }
            self.alertBeforeEventLbl!.text = "Alert " + CoreDataManager.formatInterval(givenInterval:( -1 * self.selectedTimeInterval!)) + " before event"
            print("DEBUG: selected time interval is: ", self.selectedTimeInterval)
            
            self.setUIFor(editDate: false, newEvent: false)
        } else {
            self.setUIFor(editDate: true, newEvent: false)
        }
    }
    
    func setUpForNewEvent() {
        self.dateLbl!.text = "Please select a date."
        
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
        
        // let navigationController = UINavigationController(rootViewController: contactView)
        // self.present(navigationController, animated: false) {}
        
        self.navigationController?.present(contactView, animated: true, completion: nil)
        */
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func populateTableFromGivenContactsIDs() {
        if self.selectedContactsIDs.count != 0 {
            let store = CNContactStore()
            let predicate: NSPredicate = CNContact.predicateForContacts(withIdentifiers: self.selectedContactsIDs)
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey]
            let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as [CNKeyDescriptor])
            
            for item in contacts {
                let thisContactName = item.givenName + " " + item.familyName
                let thisContactInfo = contactTableInfo(nameToDisplay: thisContactName, identifier: item.identifier)
                self.contactInfosForTable.append(thisContactInfo)
                
            }
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
        
        self.message1Lbl!.text! = "  " + self.messages[0]
        self.message2Lbl!.text! = "  " + self.messages[1]
        self.message3Lbl!.text! = "  " + self.messages[2]
        self.message4Lbl!.text! = "  " + self.messages[3]
        
    }

    
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editAlertBeforeBtnPressed(_ sender:UIButton) {
        
    }
    
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
        
        if self.selectedContactsIDs.count == 0 {
            errorType = saveErrors.noContacts
            return errorType
        }
        
        if self.givenEKEvent != nil && self.selectedTimeInterval == nil {
            errorType = saveErrors.noTimeInterval
            return errorType
        }
        
        if self.eventToEdit != nil {
            if self.eventToEdit.tiedToEkEvent != nil && self.selectedTimeInterval == nil {
                errorType = saveErrors.noTimeInterval
                return errorType
            }
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
        
        if self.givenEKEvent != nil { // if EK info given, make sure it has an ID to use
            if self.givenEKEvent.eventIdentifier != nil {
                EKID = self.givenEKEvent.eventIdentifier
            } else {
                print("ERROR: given EKEvent does not have ID associated.")
            }
            
        }
        
        // 1) Validate user given info
        let saveError = self.validateCurrentSettingsBeforeSave()
        if saveError != .noErrors {
            let thisAlert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            // present(thisAlert, animated: true, completion: nil)
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
            case .noTimeInterval:
                thisAlert.title? = "No Alert Time Set"
                thisAlert.message? = saveErrors.noTimeInterval.rawValue
            default:
                thisAlert.title? = "Unable to save event"
                thisAlert.message? = "Please double check all settings and try again."
                break
            }
            self.present(thisAlert, animated: true, completion: nil)
            return
        } // validation done
        
        
        // time interval stuff - get the alarm date from the time interval
        if self.selectedTimeInterval != nil {
            if self.selectedTimeInterval > 0 {
                self.selectedTimeInterval = self.selectedTimeInterval! * -1
            }
            
            eventDate = self.selectedDate.addingTimeInterval((self.selectedTimeInterval!))
        } else {
            if self.selectedDate != nil {
                eventDate = self.selectedDate!
            }
        }
    
    
        
        // save event
        if self.eventToEdit == nil { // NEW event
            
            newSavedEvent = CoreDataManager.saveNewEventWithInformationAndReturn(title: eventTitle!, eventDate: eventDate!, contactIDs: self.selectedContactsIDs, tiedToEKID: EKID, uniqueID: nil, messages: self.messages)
            print ("Saving new event with EKID: ", EKID)
            
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
        
        if self.dayView != nil && !self.isCurrentSelectedDateSameAsPrecedingDayView() {
            if self.eventToEdit != nil { // editing a pre-existing event whose date has been changed
                self.dayView.removeEventFromTable(eventToRemove: self.eventToEdit!)
            }
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
            /*
            if self.eventToEdit != nil {
                targetVC.selectedDateFromTarget = self.eventToEdit.alarmDate! as Date
            }
 */
            
            if self.selectedDate != nil {
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
            if self.givenEKEvent != nil {
                targetVC.selectedDateFromTarget = self.givenEKEvent.startDate!
            } else if self.selectedDate != nil {
                targetVC.selectedDateFromTarget = self.selectedDate
            } else {
                print ("Error: not enough info to set the date for alert before interval")
            }
            
            
            if self.selectedTimeInterval != nil {
                targetVC.selectedTimeIntervalFromTarget = self.selectedTimeInterval!
            }
            
            targetVC.forEkEvent = true
            targetVC.editEventVC = self
            
            
        }
        
    }
    
    
    
}
