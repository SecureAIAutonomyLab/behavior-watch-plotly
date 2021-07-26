//
//  File.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 7/1/21.
//

import Foundation

struct DayChangeManager {
    let userDayDefaults = UserDefaults.standard
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
    func resetValues() {
        userDayDefaults.set(0, forKey: "Day")
    }
}
