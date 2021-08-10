//
//  TimeStampCreator.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/25/21.
//

import Foundation
import UIKit

/// DESCRIPTION: The TimeStampCreator class creates timestamps of various formats since some functions of the app require specific formats of timestamps like graph data and data that is being uploaded to the cloud.
class TimeStampCreator {
    
    //MARK: Simple Timestamp (w/o millis)
    ///    DESCRIPTION: When called the getDateOnly method uses Apples services to retrieve the current data. The data is formatted in a specific way and then returned as a string showing the current timestamp.
    ///    PARAMS: The input paramater is of data type TimeInterval and is used to determine what date the timestamp should be created for by using the TimeInterval to specify how long ago from today to make the timestamp for.
    ///    RETURNS: Returns three different timestamps with different formats depending on what they are going to be used for.
        class func getDateOnly(fromTimeStamp timestamp: TimeInterval) -> (String, String, String, String) {
            let dayTimePeriodFormatter = DateFormatter()
            let dayTimePeriodFormatter2 = DateFormatter()
            let dayTimePeriodFormatter3 = DateFormatter()
            let dayTimePeriodFormatter4 = DateFormatter()
            dayTimePeriodFormatter.timeZone = TimeZone.current
            dayTimePeriodFormatter.dateFormat = "zMMMM/dd/yyyy HH:mm:ss:"
            dayTimePeriodFormatter2.timeZone = TimeZone.current
            dayTimePeriodFormatter2.dateFormat = "MM/dd/yy-HH:mm:ss"
            dayTimePeriodFormatter3.timeZone = TimeZone.current
            dayTimePeriodFormatter3.dateFormat = "HH:mm:ss:"
            dayTimePeriodFormatter4.timeZone = TimeZone.current
            dayTimePeriodFormatter4.dateFormat = "MM/dd/yy"
            let timeStamp1 = dayTimePeriodFormatter.string(from: Date(timeIntervalSinceNow: timestamp))
            let timeStamp2 = dayTimePeriodFormatter2.string(from: Date(timeIntervalSinceNow: timestamp))
            let timeStamp3 = dayTimePeriodFormatter3.string(from: Date(timeIntervalSinceNow: timestamp))
            let timeStamp4 = dayTimePeriodFormatter4.string(from: Date(timeIntervalSinceNow: timestamp))
            return (timeStamp1, timeStamp2, timeStamp3, timeStamp4)
            //        get the current data and time with a specificied format
        }
    
    // MARK: Complex Timestamp (w/ millis)
    /// DESCRIPTION: When called returnFinalTimeStamp returns a string with a modified timestamp from getDateOnly. This new timestamp calls the getDateOnly method to retrieve the current timestamp and then add the current milliseconds to the timestamp in order to increase the time accuracy of the timestamp. Since you can't the timestamp down to the milliseconds using Apple's timestamp services, a separate method was produced to append the milliseconds to the original timestamp. When this method calls getDateOnly it inputs a TimeInterval of 0.0 to tell getDateOnly to create a timestamp for right now.
    /// RETURNS: Returns two different timestamps of different formats depending on what they are being used for.
        func returnFinalTimeStamp() -> (String, String) {
            let timeStamp = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).0
            let timeStamp2 = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).2
            //    set variable to return timestamp variable
            var currentTime: Double
            currentTime = CACurrentMediaTime()
            let truncatedMilliseconds = currentTime.truncatingRemainder(dividingBy: 1)
            let finalMilliseconds = Int(truncatedMilliseconds * 1000)
            let finalTimeStamp = "\(timeStamp)\(finalMilliseconds)"
            let finalTimeStamp2 = "\(timeStamp2)\(finalMilliseconds)"
            return(finalTimeStamp, finalTimeStamp2)
            //        get the milliseconds to add to the timestamp
        }
        
}
