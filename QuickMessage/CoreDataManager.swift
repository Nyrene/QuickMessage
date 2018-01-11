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

public class CoreDataManager {
    /*
        steps for creating an object: create the NSManagedObject
        steps for saving:
            
 
 
     */
    
    
    // most of below function's code pulled from
    // https://www.raywenderlich.com/173972/getting-started-with-core-data-tutorial-2
    static func saveNewEventWithInformation(title:String, eventDate:Date, contactIDs:[String], tiedToEKID:String, uniqueID:String!) {
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
        
        print("DEBUG: at end of save function")
        
        // TD: associate alarm/notification with this event
        
        
        // DEBUG: attempting to fetch immediately after saving
        var events = [Event]()
        
        /*guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return events
        }
 */
        
        guard let appDelegate2 =
            UIApplication.shared.delegate as? AppDelegate else {
                print ("ERROR: unable to get app delegate instance in saveNewEventWithInformation")
                return
        }
        
        // create new event
        let thisMOC2 = appDelegate2.persistentContainer.viewContext

        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        do {
            events = try thisMOC2.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Event]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for item in events {
            let thisEvent = item as! Event
            print("item title in same func as fetch is: ", thisEvent.title)
            print("item with key value printing is: ", thisEvent.value(forKey:"title") as! String)
        }

    }
 
 
 
    static func saveChangesToEvent() {
        
        
    }
    
    static func deleteEventWithID(eventID:String) {
        // TD: delete event
        
        
        // TD: delete notification/alarm associated with event
        
        
        
    }
    
    static func loadEventWithID(uniqueID:String) {
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
        let thisEntityDescription = NSEntityDescription.entity(forEntityName: "Event", in: thisMOC)
        
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
    
    
    
    
}
