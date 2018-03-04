//
//  Utility.swift
//  TextHelper
//
//  Created by Rachael Little on 2/20/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import EventKit
import Contacts


// General stuff for now

public class Utility {
    
    static func getBeginningDateOfMonthInYear(month:Int, year:Int) -> Date {
        var thisDateComponents = DateComponents()
        thisDateComponents.year = year
        thisDateComponents.month = month
        thisDateComponents.day = 1
        
        var beginningDate = Calendar.current.date(from: thisDateComponents)
        beginningDate = Calendar.current.startOfDay(for: beginningDate!)
        
        if beginningDate == nil { // TD: throw
            print("ERROR: couldn't get beginning date from components for month")
            return Date()
        }
        
        return beginningDate!
    }
    
    static func getEndingDateOfMonthInYear(month:Int, year:Int) -> Date{
        var thisDateComponents = DateComponents()
        thisDateComponents.year = year
        thisDateComponents.month = month
        thisDateComponents.day = getDaysInMonth(month, givenYear: year)
        thisDateComponents.hour = 23
        thisDateComponents.minute = 59
        
        let endingDate = Calendar.current.date(from: thisDateComponents)
        
        if endingDate == nil { // TD: throw
            print("ERROR: couldn't get beginning date from components for month")
            return Date()
        }
        return endingDate!
    }
    
    static func getDaysInMonth(_ givenMonth:Int!, givenYear:Int!) -> Int {
        //note: months start at 1
        
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = Calendar.current
        
        // set days in the current month, otherwise IFF year and month are given,
        // set days in the given time range
        
        if (givenMonth == nil && givenYear == nil) {
            let currentDate = Date()
            // http://stackoverflow.com/questions/1179945/number-of-days-in-the-current-month-using-iphone-sdk
            
            let days:Int = ( Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: currentDate).length
            return days
            // print("DEBUG: Days in current month: ", daysInMonth)
            
        } else if (givenMonth != nil && givenYear != nil) {
            if (givenMonth < 1 && givenMonth > 12) {
                return 0
            }
            
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            
            let newDate = Calendar.current.date(from: dateComponents)
            let days:Int = (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: newDate!).length
            
            return days
            // print("DEBUG: Days in given month: ", daysInMonth)
            
        } else {
            // TDAlert: display error about requiring both values
            print("ERROR: getDaysInMonth: Month OR date set; requires both or neither")
            return 0
            
        }
        
    }
    
    
    static func getEKEventsForMonthInYear(month:Int, year:Int, eventStore:EKEventStore) -> [EKEvent]{
        var ekEventsArray = [EKEvent]()
        if EKEventStore.authorizationStatus(for: EKEntityType.event) != .authorized {
            print("ERROR: can't get ek events for month, permission not authorized")
            return ekEventsArray
        }

        let beginDate = Utility.getBeginningDateOfMonthInYear(month: month, year: year)
        let endDate = Utility.getEndingDateOfMonthInYear(month: month, year: year)
        
        let thisPredicate = eventStore.predicateForEvents(withStart: beginDate, end: endDate, calendars: nil)
        ekEventsArray = eventStore.events(matching: thisPredicate)
        
        return ekEventsArray
    }
    
}
