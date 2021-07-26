//
//  AppDelegate.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 2/6/21.
//

import UIKit
import Amplify
import AmplifyPlugins
import AuthenticationServices
import BackgroundTasks
import GoogleSignIn
 
/// DESCRIPTION: The AppDelegate class handles objects that need to be initialized before the app screen is present to the user. The connection to AWS and the S3 bucket is established through here as well as setting up the Google Sign in feature. The ability for the app to run in the background is also configured here.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let userLoginDefaults = UserDefaults.standard
    let loginDataManager = LoginDataManager()
    let AWS = AWSDataManager()

    /// DESCRIPTION: The redeclaration of the application method is called when the app launches. Everytime the app is launched the connection to Amplify is established as well as the ability for the app to run in the background. The configuration for the notifications is also created here so that the notifications sent include an alert, banner, and sound.
    /// PARAMS: The parameters for this method are the application itself, and the options for launching the application in the fom of a .LaunchOptionsKey.
    /// RETURNS: When the application opens this method is called and it always returns true indicating that the app was successful in its launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AWS.configureAmplify()
        registerBackgroundTasks()
        //        Initialize sign-in
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted \(granted)")
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    /// DESCRIPTION: This redeclaration of the application method is called when a new scene session is being created. Use this method to select a configuration to create the new scene with.
    /// PARAMS: The parameters for this method are the application that is running, the session that is being connected to and the the options for connecting to that scene.
    /// RETURNS: Once the method is called it returns a scene with the configuration that was set when the method was called.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        let _ = HealthDataManager.sharedInstance.initialize()
        //      initialize Health Data Manager class
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    /// DESCRIPTION: This redeclaration of the application method is called when the user discards a scene session. If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions. Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    /// PARAMS: The parameters for this method are the current application serving as the UIApplication parameter and the scenes that were discarded serving as the UISceneSession parameter
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        applicationDidEnterBackground(application)
        print("EXIT")
    }
///  DESCRIPTION: Use background task identifiers to register the app to run with background tasks. The app will now enable background tasks an give the user the option to disbale the feature in the settings of the app in the phone's settings.
    func registerBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        let backgroundAppRefreshTaskSchedulerIdentifier = "com.1-Aim-Industries.Cloud-VitalsBackgroundAppRefreshIdentifier"
        //        identifiers for background app refresh
        let backgroundProcessingTaskSchedulerIdentifier = "com.1-Aim-Industries.Cloud-VitalsBackgroundProcessingIdentifier"
        //        identifiers for background processing
        
        // Use the identifier which represents your needs
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppRefreshTaskSchedulerIdentifier, using: nil) { (task) in
            print("BackgroundAppRefreshTaskScheduler is executed NOW!")
            print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            //       set up background tasks and processes
            
            // Do some data fetching and call setTaskCompleted(success:) asap!
            let isFetchingSuccess = true
            task.setTaskCompleted(success: isFetchingSuccess)
        }
    }
///    DESCRIPTION: Checks if the app went into the background an calls the submitBackgroundTasks() method to call background tasks to run.
///    PARAMS: The parameters are the application itself as a data type and whether or not the app went into background mode.
    func applicationDidEnterBackground(_ application: UIApplication) {
        submitBackgroundTasks()
        //        check if app went in the background and run background functions
    }
///    DESCRIPTION: If the app was detected entering the background mode this method will be called where the app will begin to run in the background.
    func submitBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        let backgroundAppRefreshTaskSchedulerIdentifier = "com.1-Aim-Industries.Cloud-VitalsBackgroundAppRefreshIdentifier"
        let timeDelay = 10.0
        
        do {
            let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppRefreshTaskSchedulerIdentifier)
            backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
            try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
            print("Submitted task request")
        } catch {
            print("Failed to submit BGTask")
        }
    }
}


