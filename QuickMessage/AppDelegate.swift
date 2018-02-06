//
//  AppDelegate.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/4/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var CDManager = CoreDataManager()
    var phoneNums = [String]()
    var messages = [String]()
    var contactNames = [String]()
    

    // TD: move all notification related stuff to a better spot
    // maybe the calendar view, so that when the message screen can
    // be dismissed properly 
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // get contact IDs from the dictionary
        var theseContactIDs = [String]()
        var i = 0
        while (i > 0) {
            let thisKey =  ("r" + String(i)) as String
            if let thisID = notification.request.content.userInfo[thisKey] {
                theseContactIDs.append(thisID as! String)
                i += 1
            } else {
                break
            }
        }
        
        // get phone numbers for these contacts
        let contacts = CoreDataManager.fetchContactsForIDs(contactIDs: theseContactIDs)
        for item in contacts {
            self.contactNames.append(item.givenName + " " + item.familyName)
        }
        self.phoneNums = CoreDataManager.getPhoneNumbersForContacts(contacts: contacts)
        
        
        // set messages
        i = 1
        while (i > 0) {
            let thisMessageKey = "messages" + String(i)
            if let thisMessage = notification.request.content.userInfo[thisMessageKey] {
                self.messages.append(thisMessage as! String)
            } else {
                break
            }
        
        }
        
        
        completionHandler([.alert, .sound])
    }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        // Notifications
        // https://code.tutsplus.com/tutorials/an-introduction-to-the-usernotifications-framework--cms-27250
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        let rootVC = self.window?.rootViewController! as! UINavigationController
        let thisVC = rootVC.topViewController as! ViewController
        
        center.delegate = thisVC
        
        // center.delegate = self
        
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("DEBUG: notifications permission given")
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            } else {
                print("DEBUG: notifications permissions not given")
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    // Notification center
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("DEBUG: did receive response called")
        
        let actionIdentifier = response.actionIdentifier
        
        let notDict = response.notification.request.content.userInfo
        let notID = response.notification.request.identifier
        
        // get contact IDs from the dictionary
        var theseContactIDs = [String]()
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
                self.contactNames.append(item.givenName + " " + item.familyName)
            }
            self.phoneNums = CoreDataManager.getPhoneNumbersForContacts(contacts: contacts)
        }
        
        // set messages
        i = 1
        while (i > 0) {
            let thisMessageKey = "messages" + String(i)
            if let thisMessage = notDict[thisMessageKey] {
                self.messages.append(thisMessage as! String)
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
            
            if self.messages.count == 4 {
                print("DEBUG: setting otherVC's messages to self.messages in App Delegate")
                otherVC.messages = self.messages
                otherVC.recipients = self.phoneNums
                otherVC.contactNames = self.contactNames
            }
            
            if self.phoneNums.count > 0 {
                otherVC.recipients = self.phoneNums
            }
            
            otherVC.eventID = notID
            
            window?.rootViewController = otherVC;
            // Do something
            completionHandler()
        default:
            completionHandler()
        }
        
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*e         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "QuickMessage")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

