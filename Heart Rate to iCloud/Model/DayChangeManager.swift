//
//  File.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 7/1/21.
//

import Foundation

/// DESCRIPTION: The DayChangeManager struct is used to detect if there has been a day change since the last time the checkDayChange() method was called. This struct is exclusively used for uploading sleep data to the cloud. If there has been a day change since the last time sleep data was uploaded another sleep sample will be uploaded. If there has not been a day change no data will be uplaoded or added to the sleep bar graph.
struct DayChangeManager {
    // MARK: Data Properties
    
    let userDayDefaults = UserDefaults.standard
    
    // MARK: Monitor Day Change
    /// DESCRIPTION: Uses the current day and compares it to the day that was saved when the method was called last if they are not the same then the device will internally save a boolean value of true if they are the same day then a false boolean value is saved.
    func checkDayChange() {
        let currentDay = Calendar.current.component(.day, from: Date())
        let savedDay = userDayDefaults.integer(forKey: "Day") // default is 0
        if currentDay != savedDay {
            resetValues()
            userDayDefaults.set(currentDay, forKey: "Day")
            userDayDefaults.set(true, forKey: "Day Change")
        }
        else {
            userDayDefaults.set(false, forKey: "Day Change")
        }
    }
    /// DESCRIPTION: The resetValues() method changes the integer representing the day back to zero so that the day check method can work again. Only called when a day change is detected.
    func resetValues() {
        userDayDefaults.set(0, forKey: "Day")
    }
}
