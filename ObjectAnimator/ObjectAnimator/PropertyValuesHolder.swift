//
// Created by Ye He on 2018-12-15.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public class PropertyValuesHolder<T, U: TypeEvaluator> where U.valueType == T {
    var keyframes: KeyframeSet<T, U>

    public var animatedValue: T?

    public init(values: [T], evaluator: U) {
        keyframes = KeyframeSet(values: values, evaluator: evaluator)
    }
    
    public init(keyframes: [Keyframe<T>], evaluator: U) {
        self.keyframes = KeyframeSet(keyframes: keyframes, evaluator: evaluator)
    }

    func calculateValue(fraction: Float) {
        animatedValue = keyframes.getValue(fraction: fraction)
    }
}
