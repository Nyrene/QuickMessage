//
//  SendMessageViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/16/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Messages
import Contacts
import ContactsUI

class SendMessageViewController:UIViewController, MFMessageComposeViewControllerDelegate {
    var recipients = [String]()
    var messages = [String]()
    var contactNames = [String]()
    
    
    @IBOutlet var messageBtn1:UIButton!
    @IBOutlet var messageBtn2:UIButton!
    @IBOutlet var messageBtn3:UIButton!
    @IBOutlet var messageBtn4:UIButton!
    
    @IBOutlet var noticeLbl:UILabel!
    @IBOutlet var contactsLbl:UILabel!
    var eventID:String!
    
    override func viewDidLoad() {
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor
        
        // add contacts from recipients
        // TD: put this in a better spot/dedicated
        
        self.setMessageBtnsFromGivenInfo()
        let authStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        if authStatus != .authorized {
            self.contactsLbl.text! = "Permission to access user contacts has not been granted. You may still select a message and add contacts from there."
        } else {
            self.setContactsLblFromGivenInfo()
        }
        
        self.setMessageBtnsFromGivenInfo()
    }
    
    func setContactsLblFromGivenInfo() {
        var thisContactStr = ""
        for item in self.contactNames {
            thisContactStr.append((", " + item))
        }
        
        self.contactsLbl.text!.append(thisContactStr)
        
    }
    
    func setMessageBtnsFromGivenInfo() {
        if self.messages.count < 4 {
            self.messages = CoreDataManager.getDefaultMessages()
        }
        
        self.messageBtn1.setTitle(self.messages[0], for: UIControlState.normal)
        self.messageBtn2.setTitle(self.messages[1], for: UIControlState.normal)
        self.messageBtn3.setTitle(self.messages[2], for: UIControlState.normal)
        self.messageBtn4.setTitle(self.messages[3], for: UIControlState.normal)
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // cases: cancelled, sent, failed
        
        print("Controller didFinishWithResult called")
        switch result {
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
            break
        case .sent:
            self.noticeLbl.text! = "Message sent! You can continue sending messages by tapping on more options."
            controller.dismiss(animated: true, completion: nil)
            break
        case .failed:
            self.noticeLbl.text! = "Message failed to send. Tap one of the message buttons to try again."
            controller.dismiss(animated: true, completion: nil)
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageBtnPressed(_ sender: UIButton) {
        let messageComposeVC = MFMessageComposeViewController()
        if self.recipients.count < 1 {
            //self.recipients.append("invalid number")
            self.noticeLbl.text! = "No contacts have been selected. You will need to add them in the message window after selecting a message option."
        }
        
        messageComposeVC.recipients = self.recipients
        messageComposeVC.body = sender.titleLabel?.text!
        messageComposeVC.messageComposeDelegate = self
        self.present(messageComposeVC, animated: true, completion: nil)
        }
    
    
    @IBAction func exitBtnPressed(_ sender: UIButton) {
        // delete the event associated with this window
        
        if self.eventID != nil {
            CoreDataManager.deleteEventWithID(eventID: eventID)
        }
        
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
    
    }
    
    }



