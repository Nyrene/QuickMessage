//
//  ViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/4/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import UIKit
import EventKit
import CoreData
import Contacts
import UserNotifications

//SKU little_QuickMessage_SKU


// copied straight from https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift, esqqarrouth's answer
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}




//This contains the calendar view and is the starting point for the app
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UNUserNotificationCenterDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // DEBUG:
    var events = [Event]()
    var ekevents = [EKEvent]()
    
    // Calendar
    @IBOutlet var calendarView:UICollectionView?
    @IBOutlet weak var monthLbl:UILabel!
    @IBOutlet weak var yearLbl:UILabel!
    @IBOutlet weak var lastMonthBtn: UIButton!
    @IBOutlet weak var nextMonthBtn: UIButton!
    
    
    var daysInMonth:Int = 0
    var startingDayOfWeek:Int = 0 //this is for which cell to begin displaying the date on
    var includeUserEKEvents:Bool = false
    var dateComponents = DateComponents()
    
    let months: [Int:String] = [1: "January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 7:"July", 8:"August", 9:"September", 10:"October", 11:"November", 12:"December"]
    
    // Images
    var calendarDotIcon:UIImage!
    var alarmIcon:UIImage!
    
    
    // Only used for the collection view...
    // TD: find some way to not have these as attributes
    var year:Int = 0
    var month:Int = 0
    
    let eventStore = EKEventStore()
    
    
    // Menu area
    @IBOutlet weak var userEventsToggle: UISwitch!
    
    // Calendar list/selection table view
    @IBOutlet var calListTableView:UITableView!
    var listCalendars:[EKCalendar]!
    
    

    override func viewDidLoad() {
        // background image
        self.setViewColors()
        
        // Keyboard dismissal
        hideKeyboardWhenTappedAround()
        super.viewDidLoad()
        // View
        
        // Set default/starting month and date placeholders
        let dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = Calendar.current
        let currentDate = Date()
        
        self.nextMonthBtn!.layer.cornerRadius = 5
        self.lastMonthBtn!.layer.cornerRadius = 5
    
        // Calendar
        // TD: make a dedicated calendar class
        self.calendarView?.delegate = self
        self.calendarView?.dataSource = self
        
        self.month = Calendar.current.component(.month, from: currentDate)
        self.year = Calendar.current.component(.year, from: currentDate)
        
        self.monthLbl.tag = self.year
        self.monthLbl.text = months[self.month]
        self.yearLbl.text = String(self.year)
        self.yearLbl.tag = self.year
        
        self.setCalendarInfo(givenMonth: Calendar.current.component(.month, from: currentDate), givenYear: Calendar.current.component(.year, from: currentDate))
        
        if let calendarToggleSetting = UserDefaults.standard.value(forKey: "includeCalendarEvents") as! Bool? {
            if calendarToggleSetting == true && EKEventStore.authorizationStatus(for: EKEntityType.event) == .authorized {
                self.includeUserEKEvents = true
                self.userEventsToggle.isOn = true
                self.calListTableView.alpha = 1
                self.reloadCalendarListTable()
            } else {
                self.userEventsToggle.isOn = false
                self.includeUserEKEvents = false
                self.calListTableView.alpha = 0
            }
        }
        
        self.redrawCalendar(useDefaultInfo: false)
        
        
        // Calendar list table view
        self.calListTableView.delegate = self
        self.calListTableView.dataSource = self
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Calendar list table view functions
    open func numberOfSections(in tableView: UITableView) -> Int {
        if self.listCalendars != nil {
            if self.listCalendars.count > 0 {
                return 1
            }
        }
        
        return 0
    }
    
    func getListOfCalendarsForTableView() {
        if EKEventStore.authorizationStatus(for: EKEntityType.event) != .authorized {
            print("ERROR: Can't load calendars; user permission not granted")
            return
        }
        
        self.listCalendars = self.eventStore.calendars(for: EKEntityType.event)
        
        
    }
    
    func reloadCalendarListTable() {
        if self.includeUserEKEvents != true && EKEventStore.authorizationStatus(for: EKEntityType.event) != .authorized {
            print("ERROR: couldn't load table view list of calendars, conditions not met")
            return
        }
        
        getListOfCalendarsForTableView()
        self.calListTableView.alpha = 1
        
        if self.listCalendars != nil {
            if self.listCalendars.count > 0 {
                self.calListTableView.reloadData()
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.listCalendars != nil {
            if self.listCalendars.count > 0 {
                return listCalendars.count
            }
        }
        
        return 0
    }
    
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "CalendarListCell") as! CalendarListCell
        
        thisCell.calendarName.text = self.listCalendars[indexPath.row].title
        return thisCell
    }

    // Calendar delegate and source functions
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // return self.daysInMonth + self.startingDayOfWeek // why??
        return self.daysInMonth
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        dateComponents.year = self.year
        dateComponents.month = self.month
        
        // first starting date is sunday, at 1
        let thisCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        if (indexPath.item) < (self.startingDayOfWeek - 1) { // if it's before the start date
            thisCell.alpha = 0
        } else { // cell is an active calendar item. Give it a date and display
            // new code
            dateComponents.day = indexPath.item - self.startingDayOfWeek + 2
            let cellDate = Calendar.current.date(from: dateComponents)
            let cellStartDate = Calendar.current.startOfDay(for: cellDate!)
            dateComponents.day = dateComponents.day! + 1
            var nextDate = Calendar.current.date(from: dateComponents)
            nextDate = Calendar.current.startOfDay(for: nextDate!)
            
            thisCell.beginDate = cellStartDate
            let eventsMatchingDate = self.events.filter {$0.alarmDate! > cellStartDate && $0.alarmDate! < nextDate! }
            
            let thisDateFormatter = DateFormatter()
            thisDateFormatter.timeStyle = DateFormatter.Style.short
            thisDateFormatter.dateStyle = DateFormatter.Style.short
            

            
            thisCell.displayNum.text = String(indexPath.item - self.startingDayOfWeek + 2)
            thisCell.beginDate = cellStartDate
            if eventsMatchingDate.count != 0 {
                thisCell.events = eventsMatchingDate
                thisCell.alarmMarkerLbl.alpha = 1
                
                let thisImage = UIImage(named:"alarmicon.png")
                let imageSize = thisCell.alarmMarkerLbl.frame.size
                UIGraphicsBeginImageContext(imageSize)
                thisImage?.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                thisCell.alarmMarkerLbl.backgroundColor = UIColor(patternImage: newImage!)
                
            }
            
            if self.includeUserEKEvents == true {
                let ekEventsMatchingDate = self.ekevents.filter {$0.startDate! >= cellStartDate && $0.startDate! <= nextDate! }
                if ekEventsMatchingDate.count != 0 {
                    thisCell.ekEvents = ekEventsMatchingDate
                    thisCell.dotMarkerLbl.alpha = 1
                    
                    // icon
                    let thisImage = UIImage(named:"calendardot.png")
                    let imageSize = thisCell.dotMarkerLbl.frame.size
                    UIGraphicsBeginImageContext(imageSize)
                    thisImage?.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
                    let newImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    thisCell.dotMarkerLbl.backgroundColor = UIColor(patternImage: newImage!)
                }
            }
        
        } // end of if calendar date
        return thisCell
    }
    
    
    // Calendar info set up
    
        // Utility
    
    func setCalendarInfo(givenMonth:Int!, givenYear:Int!) {
        var year:Int! = givenYear
        var month:Int! = givenMonth
        
        if (givenMonth == nil && givenYear == nil) {
            // use current information
            let thisDate = Date()
            month = Calendar.current.component(.month, from: thisDate)
            year = Calendar.current.component(.year, from: thisDate)
        }
        
        self.daysInMonth = Utility.getDaysInMonth(month, givenYear:year)
        self.startingDayOfWeek = self.getStartingDayOfWeek(givenMonth:month, givenYear:year)
        self.year = year!
        self.month = month!
        
        self.setCalendarLabels()
        
        self.events = CoreDataManager.fetchEventsForMonthInYear(month: month!, year: year!)
        
        if self.includeUserEKEvents {//TD: fetch all EKEvents for month
            self.ekevents = Utility.getEKEventsForMonthInYear(month: month, year:year, eventStore:self.eventStore)
        }
    }
    
    func setCalendarLabels() {
        if self.year == 0 || self.month == 0 {
            print("ERROR: not enough information to set calendar labels")
            return
        }
        
        self.monthLbl.text = months[self.month]
        self.yearLbl.text = String(self.year)
        self.monthLbl.tag = self.month
        self.yearLbl.tag = self.year
        
        
    }
    
    func redrawCalendar(useDefaultInfo:Bool) {
        print("DEBUG: redrawCalendar called")
        if (useDefaultInfo == true) {
            self.setCalendarInfo(givenMonth: nil, givenYear: nil)
        } else {
            self.setCalendarInfo(givenMonth: self.month, givenYear: self.year)
        }
        
        self.calendarView?.reloadData()
    }
    
    
    func getDaysInMonth(_ givenMonth:Int!, givenYear:Int!) -> Int {
        // note: months start at 1
        
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
            print("Error: getDaysInMonth: Month OR date set; requires both or neither")
            return 0

        }

    }
    
    // TD: error checking for this?
    func getStartingDayOfWeek(givenMonth:Int!, givenYear:Int!) -> Int {
        //if there's no given date, use current one
        
        if (givenMonth == nil && givenYear == nil) {
            let thisDate = Date()
            let startingDay:Int = (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate)
            print("DEBUG: startingDayOfWeek with current date is: ", startingDay)
            return startingDay
        } else {
            var dateComponents = DateComponents()
            (dateComponents as NSDateComponents).calendar = Calendar.current
            dateComponents.month = givenMonth
            dateComponents.year = givenYear
            dateComponents.day = 1
 
            let thisDate = Calendar.current.date(from: dateComponents as DateComponents)
            let startingDay:Int = (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekday, from: thisDate!)
            return startingDay
        }
    }
    
    
    
    func setEKEventsForMonth(month:Int, year:Int) {
        // get permissions
        if EKEventStore.authorizationStatus(for: EKEntityType.event) != .authorized {
            print("ERROR: user tried to get calendar events, but permission not granted")
            self.userEventsToggle.isOn = false
            return
        }
        
        // fetch events
        let thisStore = EKEventStore()
        
        
        let beginningOfMonth = Utility.getBeginningDateOfMonthInYear(month: month, year:year)
        let endOfMonth = Utility.getEndingDateOfMonthInYear(month: month, year: year)
        
        
        // let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        let eventsPredicate = thisStore.predicateForEvents(withStart: beginningOfMonth, end: endOfMonth, calendars: nil)
        let theseEvents = thisStore.events(matching: eventsPredicate)
        self.ekevents = theseEvents
    }
    
   
    
    // TD: clean this up or move someplace where it makes more sense
    func getPermissionsForContacts() {
        func completionHandler(_ granted: Bool, error: Error?) -> Void {
            // for now, don't need to do anything with this
        }

        CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: completionHandler(_:error:))
    }
    
    

    
    // IBActions
    
    // TD2: move this to a separate area for alerts
    func displayEventsAlerts() {
        // Create and present an alert
        let thisAlert = UIAlertController(title: "Calendar Access Required", message: "Please allow access to the calendar to display your calendar events in-app. You can do this by going to your phone settings.", preferredStyle: UIAlertControllerStyle.alert)
        thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(thisAlert, animated: true, completion: nil)

    }
    
    func setUserEventsToggle(isOn:Bool) {
        self.userEventsToggle.isOn = true
    }
    
    @IBAction func toggleSwitched(_ sender: UISwitch) {
 
        if (self.userEventsToggle.isOn) {
            UserDefaults.standard.set(true, forKey: "includeCalendarEvents")
            
            // Depending on the permissions status, redraw the calendar with events
            switch (EKEventStore.authorizationStatus(for: EKEntityType.event)) {
            case .authorized:
                self.includeUserEKEvents = true
                self.redrawCalendar(useDefaultInfo: false)
                self.reloadCalendarListTable()
                break;
            case .notDetermined:
                func completionHandler(_ granted: Bool, error: Error?) -> Void{
                    if granted == true {
                        print("DEBUG: calendar permissions granted")
                        self.setUserEventsToggle(isOn:true)
                        self.includeUserEKEvents = true
                        self.redrawCalendar(useDefaultInfo: false)
                        self.reloadCalendarListTable()
                    } else {
                        self.userEventsToggle.isOn = false
                        self.includeUserEKEvents = false
                        // User has said no to calendar access; display alert
                        self.displayEventsAlerts()
                        print("not granted")
                    }
                    
                }
                eventStore.requestAccess(to: EKEntityType.event, completion: completionHandler as EKEventStoreRequestAccessCompletionHandler)
                break;
            case .denied:
                self.userEventsToggle.isOn = false
                if self.includeUserEKEvents == true {
                    
                }
                self.displayEventsAlerts()
                break;
            case .restricted:
                self.userEventsToggle.isOn = false
                // Create and present an alert
                let thisAlert = UIAlertController(title: "Calendar Access Restricted", message: "Calendar access is restricted. This may be caused by parental controls or another setting.", preferredStyle: UIAlertControllerStyle.alert)
                thisAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                present(thisAlert, animated: true, completion: nil)
                self.includeUserEKEvents = false
                break;
            }
            
            
        } else { //user has toggled it off
            self.includeUserEKEvents = false
            self.redrawCalendar(useDefaultInfo: false)
            self.calListTableView.alpha = 0
            UserDefaults.standard.set(false, forKey: "includeCalendarEvents")
            
            
        }
 
        
    }
    
    // TD: can probably combine these next two functions into one
    @IBAction func nextMonthBtnPressed(_ sender: UIButton) {
        if self.monthLbl.tag == 0 || self.yearLbl.tag == 0 {
            print("ERROR: can't move to next month because the month and year labels haven't been set")
            return
        }
        var thisMonth = monthLbl!.tag + 1
        var thisYear = yearLbl!.tag
        if self.monthLbl!.tag == 12 {
            thisMonth = 1
            thisYear = thisYear + 1
        }
        
        self.setCalendarInfo(givenMonth: thisMonth, givenYear: thisYear)
        self.redrawCalendar(useDefaultInfo: false)
    }
    
    @IBAction func previousMonthBtnPressed(_ sender: UIButton) {
        if self.monthLbl.tag == 0 || self.yearLbl.tag == 0 {
            print("ERROR: can't move to previous month because the month and year labels haven't been set")
            return
        }
        
        var thisMonth = monthLbl!.tag - 1
        var thisYear = yearLbl!.tag
        if self.monthLbl!.tag == 1 {
            thisMonth = 12
            thisYear = thisYear - 1
        }
        
        self.setCalendarInfo(givenMonth: thisMonth, givenYear: thisYear)
        self.redrawCalendar(useDefaultInfo: false)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue ID for displaying event: EventViewSID
        if segue.identifier == "DayViewSID" {
            
            let senderCell = sender as! CalendarCell
            let targetVC = segue.destination as! DayViewController
            // try to wait for self's selected cell to be set before switching windows
            
            targetVC.selectedCell = senderCell
            targetVC.calendarVC = self
            
        }
        if segue.identifier == "EditEventViewSID" {
            let targetVC = segue.destination as! EditEventViewController
            
            targetVC.calendarView = self
            
        }
    }
    
    // Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("DEBUG: did receive response called")
        
        // TD: streamline this a bit - could use a dictionary, [contactName:contactPhoneNum]
        var contactNames:[String] = []
        var theseContactIDs:[String] = []
        var messages:[String] = []
        var phoneNums:[String] = []
        
        let actionIdentifier = response.actionIdentifier
        
        let notDict = response.notification.request.content.userInfo
        let notID = response.notification.request.identifier
        
        // get contact IDs from the dictionary
        var i = 0
        while (i > -1) {
            let thisKey =  ("r" + String(i)) as String
            print("thisKey is: ", thisKey)
            if let thisID = notDict[thisKey] {
                theseContactIDs.append(thisID as! String)
                i += 1
            } else {
                break
            }
        }
        
        // get phone numbers for these contacts
        if theseContactIDs.count > 0 {
            let contacts = CoreDataManager.fetchContactsForIDs(contactIDs: theseContactIDs)
            for item in contacts {
                contactNames.append(item.givenName + " " + item.familyName)
            }
            phoneNums = CoreDataManager.getPhoneNumbersForContacts(contacts: contacts)
        }
        
        // set messages
        i = 1
        while (i > 0) {
            let thisMessageKey = "messages" + String(i)
            if let thisMessage = notDict[thisMessageKey] {
                messages.append(thisMessage as! String)
                i += 1
            } else {
                break
            }
            
        }
        
        
        
        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
            // Do nothing TD2: leave notification available in home app screen
            completionHandler()
        case UNNotificationDefaultActionIdentifier: // App was opened from notification
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let otherVC = sb.instantiateViewController(withIdentifier: "SendMessageViewController") as! SendMessageViewController
            
            if messages.count == 4 {
                print("DEBUG: setting otherVC's messages to self.messages in App Delegate")
                otherVC.messages = messages
                otherVC.recipients = phoneNums
                otherVC.contactNames = contactNames
            }
            
            if phoneNums.count > 0 {
                otherVC.recipients = phoneNums
            }
            
            otherVC.eventID = notID
            
            self.navigationController?.pushViewController(otherVC, animated: true)
            completionHandler()
        default:
            completionHandler()
        }
        
    }

    
    
    func setViewColors() {
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor
        self.calendarView?.backgroundColor = backgroundColor
    }

}



