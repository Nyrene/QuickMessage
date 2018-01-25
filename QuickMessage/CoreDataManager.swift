//
//  CoreDataManager.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/9/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import CoreData
import UIKit // required to get app delegate
import UserNotifications
import UserNotificationsUI
import Contacts
import ContactsUI

public class CoreDataManager {
    

    
    // most of below function's code pulled from
    // https://www.raywenderlich.com/173972/getting-started-with-core-data-tutorial-2
    static func saveNewEventWithInformation(title:String, eventDate:Date, contactIDs:[String], tiedToEKID:String, uniqueID:String!, messages:[String]!) {
        // TD2: NOTE FOR LATER:
        /* "
         When you save changes in a context, the changes are only committed “one store up.” If you save a child context, changes are pushed to its parent. Changes are not saved to the persistent store until the root context is saved.
 */
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return
        }
        
        // create new event
        let thisMOC = appDelegate.persistentContainer.viewContext
        let thisEntityDescription = NSEntityDescription.entity(forEntityName: "Event", in: thisMOC)
        let newEvent = NSManagedObject(entity: thisEntityDescription!, insertInto: thisMOC) as! Event
        
        
        // set event attributes
        // newEvent.title = title
        // newEvent.alarmDate = eventDate
        // newEvent.contactIdentifiers = contactIDs
        
        newEvent.setValue(title, forKey : "title")
        newEvent.setValue(eventDate, forKey: "alarmDate")
        newEvent.setValue(contactIDs, forKey: "contactIdentifiers")
        
        if messages != nil {
            newEvent.setValue(messages, forKey: "messages")
        }
        
        
        // if no uniqueID given, create a new one
        if uniqueID == nil || uniqueID == "" {
            newEvent.uniqueID = self.randomString(length: 6)
        } else {
            newEvent.uniqueID = uniqueID
        }
        
        do {
            try thisMOC.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // TD: associate alarm/notification with this event
        self.scheduleNotificationForEventIdentifier(identifier: newEvent.uniqueID!, notDate: newEvent.alarmDate! as Date, withEvent:newEvent)

    }
    
    static func saveNewEventWithInformationAndReturn(title:String, eventDate:Date, contactIDs:[String], tiedToEKID:String, uniqueID:String!, messages:[String]!) -> Event {
        // TD2: NOTE FOR LATER:
        /* "
         When you save changes in a context, the changes are only committed “one store up.” If you save a child context, changes are pushed to its parent. Changes are not saved to the persistent store until the root context is saved.
         */
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error: could not get app delegate")
            return Event()
        }
        
        // create new event
        let thisMOC = appDelegate.persistentContainer.viewContext
        let thisEntityDescription = NSEntityDescription.entity(forEntityName: "Event", in: thisMOC)
        let newEvent = NSManagedObject(entity: thisEntityDescription!, insertInto: thisMOC) as! Event
        
        
        // set event attributes
        // newEvent.title = title
        // newEvent.alarmDate = eventDate
        // newEvent.contactIdentifiers = contactIDs
        
        newEvent.setValue(title, forKey : "title")
        newEvent.setValue(eventDate, forKey: "alarmDate")
        newEvent.setValue(contactIDs, forKey: "contactIdentifiers")
        
        if messages != nil {
            newEvent.setValue(messages, forKey: "messages")
        }
        
        
        
        // if no uniqueID given, create a new one
        if uniqueID == nil || uniqueID == "" {
            newEvent.uniqueID = self.randomString(length: 6)
        } else {
            newEvent.uniqueID = uniqueID
        }
        
        do {
            try thisMOC.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // TD: associate alarm/notification with this event
        // create new notification with time: alarm date
        // message: "Text <recipient1> <recipient 2> and # of others?
        self.scheduleNotificationForEventIdentifier(identifier: newEvent.uniqueID!, notDate: newEvent.alarmDate! as Date, withEvent:newEvent)
        
        return newEvent
        
    }
    
    
    // TD: cut back on parameters - only need event
    static func scheduleNotificationForEventIdentifier(identifier:String, notDate:Date, withEvent:Event) {
        // https://code.tutsplus.com/tutorials/an-introduction-to-the-usernotifications-framework--cms-27250
        let notDateComps = Calendar.current.dateComponents([.hour,.minute,.second,], from: notDate)
        let thisUNTrigger = UNCalendarNotificationTrigger(dateMatching: notDateComps, repeats: false)
        
        let notContent = UNMutableNotificationContent()
        notContent.title = "Message Helper"
        notContent.subtitle = "Alert"
        notContent.sound = UNNotificationSound.default()
        notContent.body = "Tap this alert to send a message."
        notContent.badge = 0
        notContent.categoryIdentifier = "test"
        // save contact IDs
        var i = 0
        let thisContactIDsArray = withEvent.contactIdentifiers as! Array<String>
        for ID in thisContactIDsArray {
            let keyStr = "r" + String(i) as String
            notContent.userInfo[keyStr] = ID
            i += 1
        }
        // save messages - for now, we know we have exactly 4
        let messagesArray = withEvent.messages as! Array<String>
        notContent.userInfo["messages1"] = messagesArray[0]
        notContent.userInfo["messages2"] = messagesArray[1]
        notContent.userInfo["messages3"] = messagesArray[2]
        notContent.userInfo["messages4"] = messagesArray[3]
        
        notContent.launchImageName = ""
        
        
        
        let request = UNNotificationRequest(identifier: identifier, content: notContent, trigger: thisUNTrigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                // Do something with error
                print("ERROR: unable to schedule notification.")
                
            } else {
                // Request was added successfully
                print("DEBUG: Notification scheduled!")
            }
        }
        
        
        
    }
    
    static func deleteEventWithID(eventID:String) {
        // TD: delete event
        let theseEvents = fetchEventForID(eventID: eventID)
        if theseEvents.count == 1 {
            deleteObject(givenEvent: theseEvents[0])
        } else {
            print("Error: no object with that ID to delete")
        }
        
    }
    
    
    static func fetchAllEvents() -> [Event] {
        var events = [Event]()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return events
        }
        
        // create new event
        let thisMOC = appDelegate.persistentContainer.viewContext
        // let thisEntityDescription = NSEntityDescription.entity(forEntityName: "Event", in: thisMOC)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        do {
            events = try thisMOC.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Event]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        return events
        
    }
    
    static func fetchEventsForDate(givenDate:Date) -> [Event] {
        
        var events = [Event]()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return events
        }
        
        // create new event
        let thisMOC = appDelegate.persistentContainer.viewContext
        
        // create predicate, below code copied from
        // https://stackoverflow.com/questions/40312105/core-data-predicate-filter-by-todays-date
        // TD: modify calendar view cellForItem code to use startOfDay instead of manual components
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: givenDate) // eg. 2016-10-10 00:00:00
        // left off here
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let datePredicate = NSPredicate(format: "(%@ <= alarmDate) AND (alarmDate < %@)", argumentArray: [dateFrom, dateTo])
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        fetchRequest.predicate = datePredicate
        
        // fetch all events for that date
        do {
           events = try thisMOC.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Event]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return events
        
    }
    
    static func saveEventInformation(givenEvent:Event, eventTitle:String, alarmDate:Date, eventContactIDs:[String], messages:[String]!) {
        // set event information
        givenEvent.title! = eventTitle
        givenEvent.alarmDate! = alarmDate as NSDate
        givenEvent.contactIdentifiers! = eventContactIDs as NSObject
        
        if (messages != nil) {
            givenEvent.setValue(messages, forKey: "messages")
        }
        
        // save info
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return
        }
        
        let thisMOC = appDelegate.persistentContainer.viewContext
        
        do {
            try thisMOC.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    // TD: make this throw instead of returning an empty array
    static func fetchEventForID(eventID:String) -> [Event] {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return [Event]()
        }
        
        // create new event
        let thisMOC = appDelegate.persistentContainer.viewContext
        let thisFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        let thisPredicate = NSPredicate(format:"%K == %@", "uniqueID", eventID)
        thisFetchRequest.predicate = thisPredicate
        
        var events:[Event] = []
        
        do {
            events = try thisMOC.fetch(thisFetchRequest ) as! [Event]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if events.count == 0 { // TDL should throw here
            print("Error: no returned events")
            return events
        }
        
        if events.count > 1 {
            print("Error: duplicate events with unique IDs")
            return events
        } else {
            return events
        }
        
        // return Event() // commented out to silence warning as this line is never executed
    }
    
    
    static func getDefaultMessages() -> [String] {
        let messages = ["On my way.", "Just arrived.", "Currently delayed.",  "Almost there."]
        
        return messages
    }
    

    static func deleteObject(givenEvent:Event) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [givenEvent.uniqueID!])
        
        moc.delete(givenEvent)
        appDelegate.saveContext()
    }
    
    static func deleteNotification(notID:String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notID])
        
    }

    // Utility
    
    // https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    // copied straight from above link, iAhmed's answer
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func fetchContactsForIDs(contactIDs:[String]) -> [CNContact] {
        // TD: move this to another class, maybe a general utility one
        let store = CNContactStore()
        let predicate: NSPredicate = CNContact.predicateForContacts(withIdentifiers: contactIDs)
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey, CNContactPhoneNumbersKey]
        let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as [CNKeyDescriptor])
        
        return contacts
    }
    
    static func getPhoneNumbersForContacts(contacts:[CNContact]) -> [String] {
        var numbers = [String]()
        for person in contacts {
            let thisNumber = (person.phoneNumbers[0].value ).value(forKey: "digits") as! String
            numbers.append(thisNumber)
        }
        
        return numbers
    }
    
    
    
}
