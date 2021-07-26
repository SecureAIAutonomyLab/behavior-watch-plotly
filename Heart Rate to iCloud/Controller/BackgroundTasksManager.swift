//
//  BackgroundTasksManager.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/29/21.
//

import Foundation
import BackgroundTasks

struct BackgroundTasksManager {
    
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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        submitBackgroundTasks()
        //        check if app went in the background and run background functions
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
