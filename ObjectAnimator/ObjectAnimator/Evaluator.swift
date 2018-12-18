//
// Created by Ye He on 2018-12-14.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public protocol TypeEvaluator {
    associatedtype valueType
    func evaluate(fraction: Float, startValue: valueType, endValue: valueType) -> valueType
}

public class IntEvaluator: TypeEvaluator {
    public init() {

    }

    public func evaluate(fraction: Float, startValue: Int, endValue: Int) -> Int {
        print("asdf")

        return (Int)(Float(startValue) + fraction * (Float)(endValue - startValue))
    }
}

public class FloatEvaluator: TypeEvaluator {
    public init() {

    }

    public func evaluate(fraction: Float, startValue: Float, endValue: Float) -> Float {
        print("asdf")
        return Float(startValue) + fraction * (Float)(endValue - startValue)
    }
}