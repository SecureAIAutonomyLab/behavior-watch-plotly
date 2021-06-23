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
 

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    let userLoginDefaults = UserDefaults.standard
    let alphabetArray : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let numberArray : [String] = ["1","2","3","4","5","6","7","8","9","0"]
    let symbolArray : [String] = ["!","@","#","$","%","^","&","*","(",")"]
//    arrays for random key creation

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureAmplify()
        registerBackgroundTasks()
        //        Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "149269937983-ntln6k81a4c9ms969ssqs33o6ppq2e4s.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        return true
        
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        let _ = HealthDataManager.sharedInstance.initialize()
        //      initialize Health Data Manager class
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
                let email = userLoginDefaults.string(forKey: "Email")
                if email == nil {
                let alphaRando = alphabetArray.randomElement()!
                let numRando = numberArray.randomElement()!
                let symbRando = symbolArray.randomElement()!
                let alphaRando1 = alphabetArray.randomElement()!
                let numRando1 = numberArray.randomElement()!
                let symbRando1 = symbolArray.randomElement()!
                let alphaRando2 = alphabetArray.randomElement()!
                let numRando2 = numberArray.randomElement()!
                let symbRando2 = symbolArray.randomElement()!
                let alphaRando3 = alphabetArray.randomElement()!
                let numRando3 = numberArray.randomElement()!
                let symbRando3 = symbolArray.randomElement()!
            //        create random string of variables to act as a secret key once the user has logged in for the first and only time
                let randomKey = ("\(alphaRando)\(alphaRando1)\(alphaRando2)\(numRando)\(numRando1)\(numRando2)\(symbRando)\(symbRando1)\(symbRando2)\(alphaRando3)\(numRando3)\(symbRando3)")
            //              random key format: aaa111!!!a1!
            //        create random key
                userLoginDefaults.setValue("IN", forKey: "Sign In")
                userLoginDefaults.setValue(randomKey, forKey: "Random Key")
                userLoginDefaults.setValue("False", forKey: "Apple Sign In")
                    
                }
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        // Perform any operations on signed in user here.
//        let userId = user.userID                  // For client-side use only!
//        let idToken = user.authentication.idToken // Safe to send to the server
//        let fullName = user.profile.name
        let email2 = userLoginDefaults.string(forKey: "Email")
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        if email != email2 {
        let alphaRando = alphabetArray.randomElement()!
        let numRando = numberArray.randomElement()!
        let symbRando = symbolArray.randomElement()!
        let alphaRando1 = alphabetArray.randomElement()!
        let numRando1 = numberArray.randomElement()!
        let symbRando1 = symbolArray.randomElement()!
        let alphaRando2 = alphabetArray.randomElement()!
        let numRando2 = numberArray.randomElement()!
        let symbRando2 = symbolArray.randomElement()!
        let alphaRando3 = alphabetArray.randomElement()!
        let numRando3 = numberArray.randomElement()!
        let symbRando3 = symbolArray.randomElement()!
    //        create random string of variables to act as a secret key once the user has logged in for the first and only time
        let randomKey = ("\(alphaRando)\(alphaRando1)\(alphaRando2)\(numRando)\(numRando1)\(numRando2)\(symbRando)\(symbRando1)\(symbRando2)\(alphaRando3)\(numRando3)\(symbRando3)")
    //              random key format: aaa111!!!a1!
    //        create random key
        userLoginDefaults.setValue(randomKey, forKey: "Random Key")
        // ...
        }
        userLoginDefaults.setValue("IN", forKey: "Sign In")
        userLoginDefaults.setValue("False", forKey: "Apple Sign In")
    let fullNameString = "\(givenName!) \(familyName!)"
        userLoginDefaults.setValue(email, forKey: "Email")
        userLoginDefaults.setValue(fullNameString, forKey: "Full Name")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func configureAmplify() {
        //        let models = AmplifyModels()
        //        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: models)
        //        let apiPlugin = AWSAPIPlugin(modelRegistration: models)
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            //        add Amplify cognito plug in
            try Amplify.add(plugin: AWSS3StoragePlugin())
            //         add S3 storage plugin
            //            try Amplify.add(plugin: apiPlugin)
            //            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.configure()
            //        configure AWS Amplify services
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
    //    run specified background tasks
}


