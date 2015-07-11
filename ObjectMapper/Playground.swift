import Foundation

//println("Hello, world!")

//
//  JSONSerializable.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

protocol JSONType {
    init(json: AnyObject)
    func toJSON() -> AnyObject
}

protocol JSONSerializable: Mappable {
    init(dictionary: [String : AnyObject])
    func toDictionary() -> [String : AnyObject]
}

//
//  Map.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

class Map {
    typealias T = Any?
    var source: () -> T
    var to: (T) -> Void
    
    init(source: () -> T, to: (T) -> Void) {
        self.source = source
        self.to = to
    }
}

protocol Mappable {
    var mappings: [String : Map] { get }
}

//
//  ObjectMapper.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

func defaultCoderInitialization<T where T: NSCoding, T: Mappable>(object: T, aDecoder coder: NSCoder) {
    for (key, map) in object.mappings {
        if let value: AnyObject = coder.decodeObjectForKey(key) {
            let f = map.to
            f(value)
        }
    }
}

func defaultEncoder<T where T: NSCoding, T: Mappable>(object: T, aCoder coder: NSCoder) {
    for (key, map) in object.mappings {
        let f = map.source
        if let o: AnyObject = f() as? AnyObject {
            coder.encodeObject(o, forKey: key)
        } else {
            coder.encodeObject(nil, forKey: key)
        }
    }
}

func defaultJSONSerializableInitialization<T: JSONSerializable>(object: T, #dictionary: [String : AnyObject]) {
    for (key, value) in dictionary {
        if let m = object.mappings[key] {
            let f = m.to
            f(value)
        }
    }
}

func enumerationParser<T: RawRepresentable>(rawValue: T.RawValue?) -> T? {
    if let r = rawValue {
        return T(rawValue: r)
    }
    
    return nil
}

func jsonObjectMaker<T: JSONSerializable>(object: T) -> [String : AnyObject] {
    var result = [String : AnyObject]()
    
    for (k, v) in object.mappings {
        let value = v.source()
        
        if let obj = value as? NSObject {
            result[k] = obj
        } else if let json = value as? JSONType {
            result[k] = json.toJSON()
        } else if let ser = value as? JSONSerializable {
            result[k] = ser.toDictionary()
        }
    }
    
    return result
}

//func jsonTypeParser<T: JSONType>(input: AnyObject?) -> T? {
//    var result: T? = nil
//
//    if let t = input as? T {
//        result = t
//    } else if let json: AnyObject = input as? AnyObject {
//        result = T(json: json)
//    }
//
//    return result
//}

func modelParser<T where T: JSONSerializable, T: NSCoding>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    } else if let dictionary = input as? [String : AnyObject] {
        result = T(dictionary: dictionary)
    } else if let aDecoder = input as? NSCoder {
        result = T(coder: aDecoder)
    }
    
    return result
}

func modelArrayParser<T: JSONSerializable>(input: Any?) -> [T]? {
    var result: [T]? = nil
    
    if let t = input as? [T] {
        result = t
    } else if let array = input as? [[String : AnyObject]] {
        result = [T]()
        for dict in array {
            let t = T(dictionary: dict)
            result!.append(t)
        }
    }
    
    return result
}

func valueParser<T>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    }
    
    return result
}

func valueArrayParser<T>(input: Any?) -> [T]? {
    var result: [T]? = nil
    
    if let t = input as? [T] {
        result = t
    }
    
    return result
}
