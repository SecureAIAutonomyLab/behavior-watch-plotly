//
//  SignInInterfaceController.swift
//  Heart Rate to iCloud WatchKit Extension
//
//  Created by vctrg on 3/25/21.
//

import Foundation
import WatchKit
import WatchConnectivity
import AuthenticationServices
import UIKit

class SignInInterfaceController: WKInterfaceController {
    
    @IBOutlet var signedInButton: WKInterfaceButton!
    let endIFC = InterfaceController()
    var watchSession = WCSession.default //watch session variable
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        configureWatchKitSession()
        signedInButton.setEnabled(false)
        signedInButton.setTitle("Not Signed In")
//      show that user is not signed in when first opening the app
    }
    
    override func willActivate() {
        super.willActivate()
        DispatchQueue.main.async {
        let data: [String: Any] = ["Watch Display Activated": "Activated"  as Any]
        self.watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//            send message to phone indicating active watch display
        }
    }
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    func loggedIn(){
        pushController(withName:"Interface Storyboard", context: self)
//        change to main interface controller after signing in
    }
    
}
extension SignInInterfaceController: WCSessionDelegate {
    

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let IDLabel = message["Name Label"] as? String {
                self.signedInButton.setEnabled(true)
                self.signedInButton.setBackgroundColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
                self.signedInButton.setTitle("Signed In!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    //.2 second code delay
                self.loggedIn()
//                    check if iPhone app was logged in to login the apple watch app
            }
        }
    }
        if (message["Load Main Watch Screen"] as? String) != nil {
                self.loggedIn()
//                iPhone message telling apple watch to login if user has already logged in previously
            }
        }
}

