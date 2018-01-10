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
    
    
    
    static func saveNewEventWithInformation(title:String, eventDate:Date, contactIDs:[String], tiedToEKID:String, uniqueID:String!) {
        // TD: NOTE FOR LATER: 
        /* "
         When you save changes in a context, the changes are only committed “one store up.” If you save a child context, changes are pushed to its parent. Changes are not saved to the persistent store until the root context is saved.
 */
        
        // create new event: requires NSEntityDescription and NSManagedObjectContext
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
        newEvent.title = title
        newEvent.alarmDate = eventDate
        newEvent.contactIdentifiers = contactIDs
        
        
        
        // if no uniqueID given, create a new one
        if uniqueID == nil || uniqueID == "" {
            let uniqueID = self.randomString(length: 6)
        }
        

        
        /*
 var TiedToUserEKEventID = ""
 var title = ""
 var startDate:Date!
 var uniqueID = ""
 var contactIdentifiers = [String]()*/
        
        /*
 let newEntry:EventEntryModel = EventEntryModel(entity:entityDescription, insertInto: moc)
 //set the entry object's values
 newEntry.eventTitle = entryInfo?.eventTitle
 newEntry.isCalEvent = (entryInfo?.isCalEvent)!
 newEntry.occurrenceDate = (entryInfo?.occurrenceDate)! as NSDate
 newEntry.uniqueID = (entryInfo?.uniqueID)!
*/
 
    }
 
 
 
    static func saveChangesToEvent() {
        
        
    }
    
    static func deleteEvent() {
        
        
    }
    
    static func loadEventWithID(uniqueID:String) {
        
    }
    
    /*
    static func createNewEvent(title:String, startDate:Date, contactIdentifiers:[String], tiedToUserEKEventID:String) {
        //create new unique ID for event
        let thisStringID = randomString(length: 8)
        
        
        "
    }
 */
    
    
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
