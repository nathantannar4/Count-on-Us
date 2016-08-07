//
//  AppDelegate.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private func createMenuView() {
        
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        let leftViewController = storyboard.instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        leftViewController.mainViewController = nvc
        
        let slideMenuController = ExSlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let navbar = UINavigationBar.appearance()
        navbar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        navbar.barTintColor = SAP_COLOR
        navbar.tintColor = UIColor.whiteColor()
        navbar.translucent = false
        self.window?.tintColor = SAP_COLOR
        
        self.createMenuView()
        
        Parse.setApplicationId("R7Sj5iHhGB4haFQaeT0yGOUQ6GdSIrLHNHnCoLPW", clientKey: "LdlitUyHdlS9LWfRAc2EJZDWBKSYgerxHUosEZPi")
        
        Parse.setLogLevel(PFLogLevel.Info);
        
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
            
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()


        return true
    }
    
    // Mark - Push Notification methods
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError")
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if let aps: AnyObject = userInfo["aps"] {
            if let apsDict = aps as? [String : AnyObject]{
                if let alert: AnyObject = apsDict["alert"] {
                    let index = (alert as? String)?.rangeOfString(":")?.endIndex
                    let name = (alert as? String)?.substringToIndex(index!)
                    let message = (alert as? String)?.substringFromIndex(index!.advancedBy(1))
                    let banner = Banner(title: name, subtitle: message, image: nil, backgroundColor: SAP_COLOR)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                }
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("reloadMessages", object: nil)
        UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

