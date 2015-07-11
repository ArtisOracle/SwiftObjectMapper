//
//  JSON.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

/**
    Describes type that can be serialized to and deserialized
    from its JSON representation.
*/
protocol JSONSerializable: Mappable {
    init(dictionary: [String : AnyObject])
    func toDictionary() -> [String : AnyObject]
}

/**
    Describes a type that can be literally reprsented in JSON.
*/
protocol JSONType {
    init(json: AnyObject)
    func toJSON() -> AnyObject
}
