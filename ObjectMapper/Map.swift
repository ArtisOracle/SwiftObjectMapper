//
//  Map.swift
//  ObjectMapper
//
//  Created by Stefan Arambasich on 7/10/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

/**
    Describes a two-way transformation between a type and
    the implementing protocol.
*/
class Map {
    typealias T = Any
    var source: () -> T?
    var to: (T?) -> Void
    
    init(source: () -> T?, to: (T?) -> Void) {
        self.source = source
        self.to = to
    }
}

/**
    A mappable type provides how its 'serialization keys' map to its
    actual properties.
*/
protocol Mappable {
    var mappings: [String : Map] { get }
}
