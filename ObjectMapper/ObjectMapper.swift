//
//  ObjectMapper.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import Foundation

/**
    Parses the input to an `NSDate` if possible.
    
    :return: An `NSDate` if one could be parsed or nil otherwise.
*/
func dateParser(input: Any?) -> NSDate? {
    var result: NSDate? = nil
    
    if let d = input as? NSDate {
        result = d
    } else if let str = input as? String {
        result = NSDate.parseDate(str)
    }
    
    return result
}

/**
    Parses the input to an Array of `NSDate`s if possible.

    :return: An `NSDate` array if one could be parsed or nil otherwise.
*/
func dateArrayParser(input: Any?) -> [NSDate]? {
    var result: [NSDate]? = nil
    
    if let dts = input as? [NSDate] {
        result = dts
    } else if let strs = input as? [String] {
        for s in strs {
            if let d = NSDate.parseDate(s) {
                if result == nil { result = [NSDate]() }
                result!.append(d)
            }
        }
    }
    
    return result
}

/**
    Default implementation of `init(:coder)` for `Mappable` types.
*/
func defaultCoderInitialization<T where T: NSCoding, T: Mappable>(object: T, aDecoder coder: NSCoder) {
    for (key, map) in object.mappings {
        if let value: AnyObject = coder.decodeObjectForKey(key) {
            let f = map.to
            f(value)
        }
    }
}

/**
    Default implementation of `encode(:coder` for `Mappable` types.
*/
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

/**
    Default implementation of `init(:dictionary)` for `JSONSerializable` types.
*/
func defaultJSONSerializableInitialization<T: JSONSerializable>(object: T, #dictionary: [String : AnyObject]) {
    for (key, value) in dictionary {
        if let m = object.mappings[key] {
            let f = m.to
            f(value)
        }
    }
}

/**
    Attempts to parse an enumeration of type `T`.

    :return: An instance of `T` if it could be constructed or nil otherwise.
*/
func enumerationParser<T: RawRepresentable>(rawValue: T.RawValue?) -> T? {
    if let r = rawValue {
        return T(rawValue: r)
    }
    
    return nil
}

/**
    Attempts to parse an array of enumerations of type `T`.

    :return: An array of `T`s if it could be constructed or nil otherwise.
*/
func enumerationArrayParser<T: RawRepresentable>(rawValues: [T.RawValue]?) -> [T]? {
    var result: [T]? = nil
    
    if let rs = rawValues {
        for r in rs {
            if let e = T(rawValue: r) {
                if result == nil { result = [T]() }
                result!.append(e)
            }
        }
    }
    
    return result
}

/**
    Default implementation of `toDictionary()` for `JSONSerializable` types.
*/
func jsonObjectMaker<T: JSONSerializable>(object: T) -> [String : AnyObject] {
    var result = [String : AnyObject]()
    
    for (k, v) in object.mappings {
        let value = v.source()
        if let json = value as? JSONType {
            result[k] = json.toJSON()
        } else if let jsonArr = value as? [JSONType] {
            result[k] = {
                var result = [AnyObject]()
                for v in jsonArr {
                    result.append(v.toJSON())
                }
                return result
            }()
        } else if let ser = value as? JSONSerializable {
            result[k] = ser.toDictionary()
        } else if let serArr = value as? [JSONSerializable] {
            result[k] = {
                var result = [[String : AnyObject]]()
                for v in serArr {
                    result.append(v.toDictionary())
                }
                return result
            }()
        } else if let objArr = value as? [NSObject] {
            result[k] = value as? [AnyObject]
        } else if let obj = value as? NSObject {
            result[k] = obj
        }
    }
    
    return result
}

/**
    Attempt to parse a type (one that is `NSCoding` and `JSONSerializable`).

    :return: An instance of `T` if it could be constructed or nil otherwise.
*/
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

/**
    Attempt to parse an array of a type (one that is `NSCoding` and `JSONSerializable`).

    :return: An array of `T`s if it could be constructed or nil otherwise.
*/
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

/**
    Attempt to parse the input to `T`.

    :return: An instance of `T` if it could be constructed or nil otherwise.
*/
func valueParser<T>(input: Any?) -> T? {
    var result: T? = nil
    
    if let t = input as? T {
        result = t
    }
    
    return result
}

/**
    Attempt to parse the input to `[T]`.

    :return: An array of `T`s if it could be constructed or nil otherwise.
*/
func valueArrayParser<T>(input: Any?) -> [T]? {
    var result: [T]? = nil
    
    if let t = input as? [T] {
        result = t
    }
    
    return result
}
