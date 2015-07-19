//
//  OldShit.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/14/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import Foundation

@objc public protocol Serializable {
    /// A list of strings ('keys') that serialize the object. Must be an
    /// in-order, one-to-one mapping of variable names to these keys.
    var serializationKeys: [String] { get }
    /// Initializes the object using its dictionary representation
    init(dictionary: [String : AnyObject])
    /// Returns a dictionary representation of this object
    func toDictionary() -> [String : AnyObject]
}

@objc class RootModel: NSObject, Serializable {
    var pk = Int.max
    var created = NSDate()
    var updated = NSDate()
    
    var serializationKeys: [String] {
        return ["id", "created", "updated"]
    }
    
    required init(dictionary: [String : AnyObject]) {
        super.init()
        
        serializable__dictInit(dictionary, model: self)
        
//        defaultJSONSerializableInitialization(self, dictionary: dictionary)
    }
    
    func toDictionary() -> [String : AnyObject] {
        var result = [String : AnyObject]()
        serializable__addToDict(&result, mirror: reflect(self), onObject: self)
        return result
        
//        return jsonObjectMaker(self)
    }
}

// MARK: - Global functions
func model__defaultHash<T where T: Hashable, T: RootModel>(model m: T) -> Int {
    return (31 &* m.created.hash) &+ m.updated.hash
}

func model__getDiffBetweenRootModels(modelOne m1: MirrorType, modelTwo m2: MirrorType) -> [String] {
    var results = [String]()
    for i in 0 ..< m1.count {
        let p = m1[i].0
        let c1 = m1[i].1
        let c2 = m2[i].1
        
        if p == "super" {
            return model__getDiffBetweenRootModels(modelOne: c1, modelTwo: c2)
        } else {
            var c1o = c1.value as? NSObject
            var c2o = c2.value as? NSObject
            
            if c1o != nil && c2o != nil {
                if c1o != c2o {
                    results.append(p)
                }
            }
        }
    }
    
    return results
}

typealias myType = NSObject

func getOptionalGenericType<T>(optional: Optional<T>.Type) -> T.Type {
    return T.self
}

func getArrayType<T>(arr: [T].Type) -> T.Type {
    return T.self
}

func model__setValue<T where T: NSObject, T: Serializable>(value: AnyObject!, forSerializationKey key: String, model m: T) {
    let varNames = object__getVarNames(mirror: reflect(m))
    if let i = find(m.serializationKeys, key) {
        let mrs = object__getAllMirrorValues(mirror: reflect(m))
        let mr = mrs[i]
        
        // This allows us to have nested dictionary representations
        // of Serializable constructs and have them init properly TODO: not generic :(
        if let dict = value as? [String : AnyObject] {
            let v = mr.1.value
            if let t1 = mr.1.value as? NSObject {
                if let t2 = t1 as? RootModel {
                    let finalObj = t2.dynamicType(dictionary: dict)
                    m.setValue(finalObj, forKey: varNames[i])
                } else {
                    m.setValue(value, forKey: varNames[i])
                }
            }
        } else if let arr = value as? [[String : AnyObject]] where arr.count > 0 {
            // Do stuff with arrays. Caveat: this will match ANY array even though the type annotation says dictionary, hence the `where` clause.
        } else if let s = value as? String {
            if let d = NSDate.parseDate(s) {
                m.setValue(d, forKey: varNames[i])
            } else {
                m.setValue(value, forKey: varNames[i])
            }
        } else {
            m.setValue(value, forKey: varNames[i])
        }
    }
}


//func model__update<T where T: CalendarType, T: NSObject>(currentRootModel cm: T, newRootModel nm: T) {
//    let diffs = model__getDiffBetweenRootModels(modelOne: reflect(cm), modelTwo: reflect(nm))
//    var newVals = [NSObject]()
//    for d in diffs {
//        let nv = nm.valueForKey(d) as NSObject
//        cm.setValue(nv, forKey: d)
//    }
//}

func nscoder__addToCoder<T: Serializable>(aCoder: NSCoder, mirror m: MirrorType, onObject o: T) {
    for i in 0 ..< m.count {
        let p = m[i].0
        let c = m[i].1
        
        if p == "super" {
            nscoder__addToCoder(aCoder, mirror: c, onObject: o)
        } else {
            let j = find(object__getVarNames(mirror: reflect(o)), p)
            aCoder.setValue(c.value as! NSObject, forKey: o.serializationKeys[j!])
        }
    }
}

func nscoder__initWithCoder<T where T: NSObject, T: Serializable>(aDecoder: NSCoder, mirror m: MirrorType, onObject o: T) {
    for i in 0 ..< o.serializationKeys.count {
        let keyName = o.serializationKeys[i]
        if let val: AnyObject = aDecoder.valueForKey(keyName) {
            model__setValue(val, forSerializationKey: keyName, model: o)
        }
    }
}

func nscopying__copyWithZone<T: NSObject where T: NSCopying>(fromMirror fm: MirrorType, inout toObject toObj: T) {
    for i in 0 ..< fm.count {
        let p = fm[i].0
        let c = fm[i].1
        
        if p == "super" {
            nscopying__copyWithZone(fromMirror: c, toObject: &toObj)
        } else {
            if let o = c.value as? NSObject {
                toObj.setValue(o, forKey: p)
            } else {
                println("Couldn't copy value for variable \(p)")
            }
        }
    }
}

func object__getVarNames(mirror m: MirrorType) -> [String] {
    var result = [String]()
    for i in 0 ..< m.count {
        if m[i].0 == "super" {
            let rs = object__getVarNames(mirror: m[i].1)
            for r in rs {
                result.append(r)
            }
        } else {
            result.append(m[i].0)
        }
    }
    
    return result
}

func object__getAllMirrorValues(mirror m: MirrorType) -> [(String, MirrorType)] {
    var result = [(String, MirrorType)]()
    for i in 0 ..< m.count {
        if m[i].0 == "super" {
            let rs = object__getAllMirrorValues(mirror: m[i].1)
            for r in rs {
                result.append(r)
            }
        } else {
            result.append(m[i])
        }
    }
    
    return result
}

public func serializable__dictInit<T where T: NSObject, T: Serializable>(dictionary: [String: AnyObject], model m: T) {
    for (key, value) in dictionary {
        if let i = find(m.serializationKeys, key) {
            model__setValue(value as! NSObject, forSerializationKey: key, model: m)
        }
    }
}

public func serializable__addToDict<T: Serializable>(inout dict: [String : AnyObject], mirror m: MirrorType, onObject o: T) {
    for i in 0 ..< m.count {
        let p = m[i].0
        let c = m[i].1
        
        if p == "super" {
            serializable__addToDict(&dict, mirror: c, onObject: o)
        } else {
            let j = find(object__getVarNames(mirror: reflect(o)), p)
            let ks = o.serializationKeys
            if j < o.serializationKeys.count {
                let k = o.serializationKeys[j!]
                if !k.isEmpty {
                    if let val = c.value as? String {
                        if val.isEmpty {
                            continue
                        }
                    }
                    
                    if let val = c.value as? NSObject {
                        if let cal = val as? RootModel {
                            let d = cal.toDictionary()
                            if d.count > 0 {
                                dict[k] = d
                            }
                        } else if let vals = val as? [RootModel] {
                            var arr = [[String : AnyObject]]()
                            for v in vals {
                                arr.append(v.toDictionary())
                            }
                            
                            if arr.count > 0 {
                                dict[k] = arr
                            }
                        } else if let safeVal: AnyObject = JSONify(val) {
                            dict[k] = safeVal
                        }
                    }
                }
            }
        }
    }
}

func JSONify(o: AnyObject) -> AnyObject? {
    if o is String {
        return o as! String
    } else if o is Int {
        return o as! Int
    } else if o is Double {
        return o as! Double
    } else if o is Bool {
        return o as! Bool
    } else if o is NSDate {
        return (o as! NSDate).toString(timezone: NSTimeZone(forSecondsFromGMT: 0))
    }
    
    return nil
}
