//
//  AppDelegate.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-20.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    var shortcutItem = UIApplicationShortcutItem.self

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SystemVariables.systemPreferences.setObject(true, forKey: "firstTimeShowingSongVC")
//        var performShortcutDelegate = true
        
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        UITabBar.appearance().barStyle = UIBarStyle.Black
        
        /**
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            performShortcutDelegate = false
            handleShortcut(shortcutItem)
        }
    */
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        SystemVariables.systemPreferences.setBool(false, forKey: "3DTouchUse")
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
        SystemVariables.systemPreferences.setObject(true, forKey: "firstTimeShowingSongVC")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - 3D Touch Implementation
    
    /**
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var succeeded = false
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let tabBarVC = storyboard.instantiateViewControllerWithIdentifier("TabBarVCIdentifier") as? UITabBarController
        
        switch shortcutItem.type {
        case "LB.Teslanimate.Settings":
            tabBarVC?.selectedIndex = 1
            succeeded = true
//        case "LB.Teslanimate.TestSong":
//            tabBarVC?.selectedIndex = 0
//            SystemVariables.setSongAction3DTouch(UIVariables.SongAction.TestSong)
//            succeeded = true
//        case "LB.Teslanimate.SelectSong":
//            tabBarVC?.selectedIndex = 0
//            SystemVariables.setSongAction3DTouch(UIVariables.SongAction.SelectSong)
//            succeeded = true
        default:
            tabBarVC?.selectedIndex = 0
            succeeded = true
        }
        
        self.window?.rootViewController = tabBarVC
        self.window?.makeKeyAndVisible()
        SystemVariables.notify3DTouchUse()
        
        return succeeded
    } */
}
