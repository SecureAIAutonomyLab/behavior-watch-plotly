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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureAmplify()
        registerBackgroundTasks()
        return true
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        let _ = HealthDataManager.sharedInstance.initialize()
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
        
    func configureAmplify() {
//        let models = AmplifyModels()
//        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: models)
//        let apiPlugin = AWSAPIPlugin(modelRegistration: models)
       do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
//            try Amplify.add(plugin: apiPlugin)
//            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.configure()
            print("Initialized Amplify");
       } catch {
           // simplified error handling for the tutorial
           print("Could not initialize Amplify: \(error)")
       }
        Amplify.Logging.logLevel = .info
    }
    
    func registerBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        let backgroundAppRefreshTaskSchedulerIdentifier = "com.1-Aim-Industries.Cloud-VitalsBackgroundAppRefreshIdentifier"
        let backgroundProcessingTaskSchedulerIdentifier = "com.1-Aim-Industries.Cloud-VitalsBackgroundProcessingIdentifier"

        // Use the identifier which represents your needs
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppRefreshTaskSchedulerIdentifier, using: nil) { (task) in
           print("BackgroundAppRefreshTaskScheduler is executed NOW!")
           print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
           task.expirationHandler = {
             task.setTaskCompleted(success: false)
           }

           // Do some data fetching and call setTaskCompleted(success:) asap!
           let isFetchingSuccess = true
           task.setTaskCompleted(success: isFetchingSuccess)
         }
       }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        submitBackgroundTasks()
      }
      
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


