//
//  Lazy.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 20.01.22.
//

import Foundation

@propertyWrapper
struct Lazy<Value> {
    
    lazy var wrappedValue: Value = computation()
    
    private let computation: () -> Value
    
    init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.computation = wrappedValue
    }
    
}


struct ThrowingLazy<Value> {
    
    var value: Value {
        mutating get throws {
            try result.get()
        }
    }
    
    private(set) lazy var result: Result<Value, Error> = {
        Result {
            try computation()
        }
    }()
    
    private let computation: () throws -> Value
    
    init(_ computation: @autoclosure @escaping () throws -> Value) {
        self.computation = computation
    }
    
}
