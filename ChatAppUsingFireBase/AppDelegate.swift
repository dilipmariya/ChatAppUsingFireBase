//
//  AppDelegate.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 19/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        var checkCase = 1
        if UserDefaults.standard.bool(forKey: "GupShupFirstTime") == false
        {
            UserDefaults.standard.set(true, forKey: "GupShupFirstTime")
            UserDefaults.standard.set(false, forKey: "UserLogin")
            UserDefaults.standard.set(false, forKey: "RememberMe")
        }
        if UserDefaults.standard.bool(forKey: "RememberMe") == true
        {
            checkCase = 2;
        }

        if FIRAuth.auth()?.currentUser?.uid != nil && checkCase == 2
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
            self.window?.rootViewController = nextViewController
            self.window?.makeKeyAndVisible()
        }
        else
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let navigation = UINavigationController.init(rootViewController: nextViewController)
            self.window?.rootViewController = navigation
            self.window?.makeKeyAndVisible()
        }
        
        // Override point for customization after application launch.
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
    }


}

