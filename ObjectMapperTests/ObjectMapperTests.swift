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

class ExtraUserInfo: JSONSerializable {//RootModel {
    var system: System = .iOS
    var num = 10.93
    var colleges = [College]()
    
    private lazy var systemMap: Map = { return Map(source: { self.system.rawValue }, to: { self.system = enumerationParser($0 as? Int) ?? self.system }) }()
    private lazy var numMap: Map = { return Map(source: { self.num }, to: { self.num = valueParser($0) ?? self.num }) }()
    private lazy var collegesMap: Map = { return Map(source: { self.colleges.map { $0.rawValue } }, to: { self.colleges = enumerationArrayParser($0 as? [Int]) ?? self.colleges }) }()
    
    private var _mappings: [String : Map]!
    private func getMappings() -> [String : Map] {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self._mappings = [
                "system": self.systemMap,
                "number": self.numMap,
                "unis": self.collegesMap,
            ]
        }
        
        return _mappings
    }
    
    var mappings: [String : Map] {
        return getMappings()
    }
    
//    var mappings: [String : Map] {
//        return [
//            "system": systemMap,
//            "number": numMap,
//            "unis": collegesMap,
//        ]
//    }
    
//    override var serializationKeys: [String] {
//        return super.serializationKeys + ["", "number", ""]
//    }
    
    required init(dictionary: [String : AnyObject]) {
        system = enumerationParser(dictionary["system"] as? Int) ?? system
        num = valueParser(dictionary["number"]) ?? num
        colleges = enumerationArrayParser(dictionary["unis"] as? [Int]) ?? colleges
        
//        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
}

class Group: JSONSerializable {
    var groupID = String.Empty
    var name = String.Empty
    var users = [ExampleUser]()
    
    private lazy var groupIDMap: Map = { return Map(source: { self.groupID }, to: { self.groupID = valueParser($0) ?? self.groupID }) }()
    private lazy var nameMap: Map = { return Map(source: { self.name }, to: { self.name = valueParser($0) ?? self.name }) }()
    private lazy var usersMap: Map = { return Map(source: { self.users }, to: { self.users = modelArrayParser($0) ?? self.users }) }()
    
    // Mappable
    private var _mappings: [String : Map]!
    private func getMappings() -> [String : Map] {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self._mappings = [
                "name": self.groupIDMap,
                "friendly": self.nameMap,
                "users": self.usersMap
            ]
        }
        
        return _mappings
    }
    
    var mappings: [String : Map] {
        return getMappings()
    }
    
//    var mappings: [String : Map] {
//        return [
//            "name": groupIDMap,
//            "friendly": nameMap,
//            "users": usersMap
//        ]
//    }
    
    // JSONSerializable
    required init(dictionary: [String : AnyObject]) {
        groupID = valueParser(dictionary["name"]) ?? groupID
        name = valueParser(dictionary["friendly"]) ?? name
        users = valueParser(dictionary["users"]) ?? users

//        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        return jsonObjectMaker(self)
    }
}

class ExampleUser: JSONSerializable { //RootModel {
    var username = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var age: Int? = 10
    var active = true
    var oneExtraUserInfo: ExtraUserInfo = {
        let result = ExtraUserInfo(dictionary: [:])
        return result
    }()
    var extraUserInfos = [ExtraUserInfo]()
    var dateTime = NSDate()
    var loginDates = [NSDate]()
    
    private lazy var usernameMap: Map = { Map(source: { self.username }, to: { self.username = valueParser($0) ?? self.username }) }()
    private lazy var emailMap: Map = { Map(source: { self.email }, to: { self.email = valueParser($0) ?? self.email }) }()
    private lazy var firstNameMap: Map = { Map(source: { self.firstName }, to: { self.firstName = valueParser($0) ?? self.firstName }) }()
    private lazy var lastNameMap: Map = { Map(source: { self.lastName }, to: { self.lastName = valueParser($0) ?? self.lastName }) }()
    private lazy var ageMap: Map = { Map(source: { self.age }, to: { self.age = valueParser($0) }) }()
    private lazy var activeMap: Map = { Map(source: { self.active }, to: { self.active = valueParser($0) ?? false }) }()
    private lazy var extraUserInfosMap: Map = { Map(source: { self.extraUserInfos }, to: { self.extraUserInfos = modelArrayParser($0) ?? self.extraUserInfos }) }()
    private lazy var oneExtraUserInfoMap: Map = { Map(source: { self.oneExtraUserInfo }, to: { self.oneExtraUserInfo = modelParser($0) ?? self.oneExtraUserInfo }) }()
    private lazy var dateTimeMap: Map = { Map(source: { self.dateTime }, to: { self.dateTime = dateParser($0) ?? self.dateTime }) }()
    private lazy var loginDatesMap: Map = { Map(source: { self.loginDates }, to: { self.loginDates = dateArrayParser($0) ?? self.loginDates }) }()
    
    private var _mappings: [String : Map]!
    private func getMappings() -> [String : Map] {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self._mappings = [
                "user_name": self.usernameMap,
                "email_address": self.emailMap,
                "first_name": self.firstNameMap,
                "last_name": self.lastNameMap,
                "years": self.ageMap,
                "is_active": self.activeMap,
                "extra_user_info": self.oneExtraUserInfoMap,
                "extra_user_infos": self.extraUserInfosMap,
                "date_time": self.dateTimeMap,
                "login_date_times": self.loginDatesMap,
            ]
        }
        
        return _mappings
    }
    
    var mappings: [String : Map] {
        return getMappings()
    }
    
//    override var serializationKeys: [String] {
//        return super.serializationKeys + ["user_name", "email_address", "first_name", "last_name", "years", "is_active", "extra_user_info", "extra_user_infos", "date_time", "login_date_times"]
//    }
    
    required init(dictionary: [String : AnyObject]) {
        username = valueParser(dictionary["user_name"]) ?? username
        email = valueParser(dictionary["email_address"]) ?? email
        firstName = valueParser(dictionary["first_name"]) ?? firstName
        lastName = valueParser(dictionary["last_name"]) ?? lastName
        age = valueParser(dictionary["years"]) ?? age
        active = valueParser(dictionary["is_active"]) ?? active
        oneExtraUserInfo = modelParser(dictionary["extra_user_info"]) ?? oneExtraUserInfo
        extraUserInfos = modelArrayParser(dictionary["date_time"]) ?? extraUserInfos
        dateTime = dateParser(dictionary["login_date_times"]) ?? dateTime
        loginDates = dateArrayParser(dictionary["user_name"]) ?? loginDates
        
//        defaultJSONSerializableInitialization(self, dictionary: dictionary)
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
    "extra_user_info": [
        "system": 5,
        "number": 99.5,
        "unis": [1, 4, 2, 3]
    ],
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
    
    func testParseExampleGroup() {
        var err: NSError?
        if let path = NSBundle(forClass: self.dynamicType).pathForResource("input", ofType: "json"),
          let data = NSData(contentsOfFile: path),
          let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as? [[String : AnyObject]] {
            for gDict in json {
                measureBlock {
                    for i in 0 ..< 100 {
                        let g = Group(dictionary: gDict)
                        if i % 10 == 0 { println("Parsed \(i) groups") }
                    }
                }
            }
        }
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
                if i % 100 == 0 { println("Parsed \(i) users") }
            }
        }
    }
    
    func testForJSON() {
        let u = ExampleUser(dictionary: exampleUserDict)
        let dict = u.toDictionary()
        XCTAssert(NSJSONSerialization.isValidJSONObject(dict), "Not valid JSON object")
    }
}
