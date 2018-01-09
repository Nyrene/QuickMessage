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


class EditEventViewController:UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    var selectedDate:Date!
    var selectedContactsIDs = [String]()
    
    @IBOutlet weak var titleTxtFld: UITextField!
    
    @IBOutlet var dateLbl: UILabel!
    
    @IBOutlet weak var addContactBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editLocationInfoBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet var contactsTableView:UITableView!
    
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender:UIBarButtonItem) {
        // Uncomment when saving functions are finished
        // let eventTitle = self.titleTxtFld.text
        
        
        if self.selectedDate != nil {
            //let eventDate = self.selectedDate
        } else {
            // TD2: add popup to popup controller later
            let thisAlert = UIAlertController(title: "No Date Selected", message: "Please select a date for this alarm.", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(thisAlert, animated: true, completion: nil)
        }

        
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
                targetVC.datePicker.date = self.selectedDate
            }
        }
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // get id for contact
        // later on, will implement more for choosing specific numbers
        let thisContactID = contact.identifier
        self.selectedContactsIDs.append(thisContactID)
        
        // self.reloadTableViewData
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedContactsIDs.count
    }
    
    
    
}
