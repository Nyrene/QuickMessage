//
//  EditMessagesViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/16/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit


class EditMessagesViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet var tableView:UITableView!
    @IBOutlet var textView:UITextView!
    @IBOutlet var saveMsgBtn:UIButton!
    @IBOutlet var cancelEditMsgBtn:UIButton!
    
    var messages:[String] = ["On my way", "Almost there", "Just got delayed", "I've arrived"]
    var selectedIndexPath:IndexPath = IndexPath()
    var editEventWindow:EditEventViewController!
    
    override func viewDidLoad() {
        
        if self.messages.count < 4 { // remove this restriction later?
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndexPath = indexPath
        self.cancelEditMsgBtn.alpha = 1
        self.saveMsgBtn.alpha = 1
        let thisCell = self.tableView.cellForRow(at: indexPath) as! MessagesTableViewCell
        if thisCell.messageLbl.text != nil {
            self.textView.text! = thisCell.messageLbl.text!
        }
        
        self.textView.becomeFirstResponder()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let thisCell = self.tableView.dequeueReusableCell(withIdentifier: "messagesTableViewCell") as! MessagesTableViewCell
        
        thisCell.messageLbl.text! = self.messages[indexPath.row]
        
        
        return thisCell
    }
    
    
    // IBActions
    
    @IBAction func saveMsgBtnPressed(_ sender:UIButton) {
        // update the table view
        let thisCell = self.tableView.cellForRow(at: self.selectedIndexPath) as! MessagesTableViewCell
        
        thisCell.messageLbl.text! = self.textView.text!
        
        self.textView.resignFirstResponder()
        
        self.saveMsgBtn.alpha = 0
        self.cancelEditMsgBtn.alpha = 0
        self.textView.text! = "Tap on a message to edit it, or hit save to preserve your choices and return to editing your event."
        
        
        
        
    }
    
    @IBAction func cancelEditMsgBtnPressed(_ sender:UIButton) {
        self.textView.text! = ""
        self.textView.resignFirstResponder()
        
        
        self.cancelEditMsgBtn.alpha = 0
        self.saveMsgBtn.alpha = 0
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        // save the contents of each table cell to the messages array
        var i = 0
        var thisIndexPath = IndexPath(row: 0, section: 0)
        while i < 4 {
            thisIndexPath.row = i
            guard let thisCell = self.tableView.cellForRow(at: thisIndexPath) else {
                print("ERROR: couldn't get table cell to edit in messages view")
                return
            }
            
            //(thisCell as! MessagesTableViewCell).messageLbl.text! = self.messages[i]
            self.messages[i] = (thisCell as! MessagesTableViewCell).messageLbl.text!
            i += 1
            
        }
        
        self.editEventWindow.messages = self.messages
        self.editEventWindow.reloadMessages()

        
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
}
