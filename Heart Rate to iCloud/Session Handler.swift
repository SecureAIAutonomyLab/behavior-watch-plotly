//
//  Session Handler.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 2/6/21.
//

import Foundation
import WatchConnectivity

class SessionHandler: NSObject, WCSessionDelegate {
    
    static let sharedInstance = SessionHandler()
    
    private var session = WCSession.default
    
    override init() {
        super.init()
        
        if isWatchSessionSupported() {
            session.delegate = self
            session.activate()
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isWatchSessionSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        
        //Reactivate the session
        self.session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            print("heart rate from message: \(heartRate)")
            NotificationCenter.default.post(name: .newHeartRateWatch, object: heartRate)
        }
    }
}
