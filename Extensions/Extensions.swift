//
//  Extensions.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import Foundation

private let DefaultDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

// MARK: - Swift language extensions
extension String {
    /// The empty string. Has no characters and is length 0.
    static let Empty = ""
    
    var length: Int {
        return count(self)
    }
}


// MARK: - Cocoa extensions
extension NSDate {
    class func parseDate(string: String, format: String? = nil) -> NSDate? {
        var date: NSDate?
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = format ?? DefaultDateFormat
        
        date = formatter.dateFromString(string)
        
        return date
    }
    
    func toString(dateFormat: String = DefaultDateFormat, timezone: NSTimeZone = NSTimeZone.localTimeZone()) -> String {
        let df = NSDateFormatter()
        
        df.locale = NSLocale.currentLocale()
        df.timeZone = timezone
        df.dateFormat = dateFormat
        
        return df.stringFromDate(self)
    }
}


// MARK: - Conformances
extension String: JSONType {
    init(json: AnyObject) {
        if let s = json as? String {
            self = s
        } else {
            self = String.Empty
        }
    }
    
    func toJSON() -> AnyObject {
        return self
    }
}
