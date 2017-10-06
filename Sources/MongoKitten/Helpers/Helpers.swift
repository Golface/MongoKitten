//
// This source file is part of the MongoKitten open source project
//
// Copyright (c) 2016 - 2017 OpenKitten and the MongoKitten project authors
// Licensed under MIT
//
// See https://github.com/OpenKitten/MongoKitten/blob/mongokitten31/LICENSE.md for license information
// See https://github.com/OpenKitten/MongoKitten/blob/mongokitten31/CONTRIBUTORS.md for the list of MongoKitten project authors
//

import Foundation

enum Commands {}
public enum Reply {}

public enum Errors {}

extension Errors {
    public struct Write: Codable, Error {
        public var index: Int
        public var code: Int
        public var errmsg: String // TODO: errorMessage?
    }
    
    public struct WriteConcern: Codable, Error {
        public var code: Int
        public var errmsg: String // TODO: errorMessage?
    }
}

public protocol DocumentCodable: Codable {
    init(from document: Document)
    
    var document: Document { get }
}

public func +<T: DocumentCodable>(lhs: T, rhs: T) -> T {
    return T(from: lhs.document + rhs.document)
}

extension DocumentCodable {
    public func encode(to encoder: Encoder) throws {
        try self.document.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        self.init(from: try Document(from: decoder))
    }
}

postfix operator *

/// Will convert an ArraySlice<Byte> to [Byte]
internal postfix func * (slice: ArraySlice<Byte>) -> Bytes {
    return Array(slice)
}

protocol WeakProtocol {
    associatedtype Element : AnyObject
    weak var value: Element? { get set }
}

/// Helper for capturing something as weak
struct Weak<Element : AnyObject> : WeakProtocol {
    weak var value: Element?
    init(_ v: Element) {
        self.value = v
    }
}

extension Dictionary where Value : WeakProtocol {
    /// Removes deallocated weak values
    mutating func clean() {
        for (key, value) in self {
            if value.value == nil {
                self.removeValue(forKey: key)
            }
        }
    }
}

extension Array where Element : WeakProtocol {
    /// Removes deallocated weak values
    mutating func clean() {
        for (index, value) in self.enumerated() {
            if value.value == nil {
                self.remove(at: index)
            }
        }
    }
}

