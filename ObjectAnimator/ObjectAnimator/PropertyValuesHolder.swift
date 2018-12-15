//
// Created by Ye He on 2018-12-15.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

class PropertyValuesHolder<T, U: TypeEvaluator> where U.valueType == T {
    var keyframes: KeyframeSet<T, U>

    public var animatedValue: T?

    init(values: [T], evaluator: U) {
        keyframes = KeyframeSet(values: values, evaluator: evaluator)
    }

    func calculateValue(fraction: Float) {
        animatedValue = keyframes.getValue(fraction: fraction)
    }
}
