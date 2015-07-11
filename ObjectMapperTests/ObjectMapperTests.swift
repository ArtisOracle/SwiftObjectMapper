//
//  ObjectMapperTests.swift
//  ObjectMapperTests
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit
import XCTest

enum System: Int, JSONType {
    case iOS = 1
    case Android = 5
    
    init(json: AnyObject) {
        self = enumerationParser(json as? Int) ?? .iOS
    }
    
    func toJSON() -> AnyObject {
        return rawValue
    }
}

enum College: Int, JSONType {
    case Michigan
    case MichiganState
    case Ohio
    case Illinois
    case Minnesota
    
    init(json: AnyObject) {
        self = enumerationParser(json as? Int) ?? .Michigan
    }
    
    func toJSON() -> AnyObject {
        return rawValue
    }
}

class ExtraUserInfo: JSONSerializable {
    var system: System = .iOS
    var num = 10.93
    var colleges = [College]()
    
    var mappings: [String : Map] {
        return [
            "system": Map(source: { self.system.rawValue }, to: { self.system = enumerationParser($0 as? Int) ?? self.system }),
            "number": Map(source: { self.num }, to: { self.num = valueParser($0) ?? self.num }),
            "unis": Map(source: { self.colleges.map { $0.rawValue } }, to: { self.colleges = enumerationArrayParser($0 as? [Int]) ?? self.colleges })
        ]
    }
    
    required init(dictionary: [String : AnyObject]) {
        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
}

class ExampleUser: JSONSerializable {
    var username = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var age: Int?
    var active = true
    var extraUserInfos = [ExtraUserInfo]()
    var dateTime = NSDate()
    var loginDates = [NSDate]()
    
    
    var mappings: [String : Map] {
        return [
            "user_name": Map(source: { self.username }, to: { self.username = valueParser($0) ?? self.username }),
            "email_address": Map(source: { self.email }, to: { self.email = valueParser($0) ?? self.email }),
            "first_name": Map(source: { self.firstName }, to: { self.firstName = valueParser($0) ?? self.firstName }),
            "last_name": Map(source: { self.lastName }, to: { self.lastName = valueParser($0) ?? self.lastName }),
            "years": Map(source: { self.age }, to: { self.age = valueParser($0) }),
            "is_active": Map(source: { self.active }, to: { self.active = valueParser($0) ?? false }),
            "extra_user_infos": Map(source: { self.extraUserInfos.map { $0.toDictionary() } }, to: { self.extraUserInfos = modelArrayParser($0) ?? self.extraUserInfos }),
            "date_time": Map(source: { self.dateTime.toString() }, to: { self.dateTime = dateParser($0) ?? self.dateTime }),
            "login_date_times": Map(source: { self.loginDates.map { $0.toString() } }, to: { self.loginDates = dateArrayParser($0) ?? self.loginDates })
        ]
    }
    
    required init(dictionary: [String : AnyObject]) {
        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
}

let exUserInfos: [[String : AnyObject]] = [
    [
        "system": 5,
        "number": 99.5,
        "unis": [1, 4, 2, 3]
    ],
    [
        "system": 1,
        "number": 94.5,
        "unis": [4, 1]
    ],
    [
        "system": 5,
        "number": -19.5042,
        "unis": [0]
    ],
]

let exampleUserDict: [String : AnyObject] = [
    "user_name": "sarambasich",
    "email_address": "ArtisOracle@gmail.com",
    "first_name": "Stefan",
    "last_name": "Arambasich",
    "years": 24,
    "is_active": false,
    "extra_user_infos": exUserInfos,
    "date_time": "2015-07-11T11:58:25-04:00",
    "login_date_times": [
        "2015-07-08T04:58:27-04:00",
        "2015-07-09T17:36:54-04:00",
        "2015-07-10T13:21:11-04:00"
    ]
]

class ObjectMapperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateExampleUser() {
        let u = ExampleUser(dictionary: exampleUserDict)
        
        XCTAssert(u.username == "sarambasich", "Unexpected username, got: \(u.username)")
        XCTAssert(u.email == "ArtisOracle@gmail.com", "Unexpected email, got: \(u.email)")
        XCTAssert(u.firstName == "Stefan", "Unexpected firstName, got: \(u.firstName)")
        XCTAssert(u.lastName == "Arambasich", "Unexpected lastName, got: \(u.lastName)")
        XCTAssert(u.age == 24, "Unexpected age, got: \(u.age)")
        XCTAssert(!u.active, "Unexpected active, got: \(u.active)")
        XCTAssert(u.extraUserInfos.count == 3, "Unexpected extraUserInfos count, got: \(u.extraUserInfos.count)")
        XCTAssert(u.dateTime.timeIntervalSinceReferenceDate == 458323105.0, "Unexpected dateTime, got: \(u.dateTime.timeIntervalSinceReferenceDate)")
        XCTAssert(u.loginDates.count == 3, "Unexepcted loginDates: got \(u.loginDates)")
        
        for i in 0 ..< u.extraUserInfos.count {
            let e = u.extraUserInfos[i]
            switch i {
            case 0:
                XCTAssert(e.system == .Android, "Unexpected system")
                XCTAssert(e.num == 99.5, "Unexpected num")
                XCTAssert(e.colleges.count == 4, "Unexpected colleges")
            case 1:
                XCTAssert(e.system == .iOS, "Unexpected system")
                XCTAssert(e.num == 94.5, "Unexpected num")
                XCTAssert(e.colleges.count == 2, "Unexpected colleges")
            case 2:
                XCTAssert(e.system == .Android, "Unexpected system")
                XCTAssert(e.num == -19.5042, "Unexpected num")
                XCTAssert(e.colleges.count == 1, "Unexpected colleges")
            default:
                XCTFail("Default should not be hit")
            }
        }
    }
    
    func testCreateExampleUserPerformance() {
        self.measureBlock() {
            for i in 0 ..< 1000 {
                let u = ExampleUser(dictionary: exampleUserDict)
            }
        }
    }
    
    func testForJSON() {
        let u = ExampleUser(dictionary: exampleUserDict)
        let dict = u.toDictionary()
        XCTAssert(NSJSONSerialization.isValidJSONObject(dict), "Not valid JSON object")
    }
}
