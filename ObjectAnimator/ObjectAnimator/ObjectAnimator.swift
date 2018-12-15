//
// Created by Ye He on 2018-12-15.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public class ObjectAnimator<T, U: TypeEvaluator> where U.valueType == T {
    private var currentFraction: Float = 0.0;

    var valueHolder: PropertyValuesHolder<T, U>?

    public convenience init(values: [T], evaluator: U) {
        if values.count == 0 {
            self.init(valueHolder: nil)
            return;
        }
        self.init(valueHolder: PropertyValuesHolder<T, U>(values: values, evaluator: evaluator))
    }

    init(valueHolder: PropertyValuesHolder<T, U>?) {
        self.valueHolder = valueHolder
    }

    public func animateValue(fraction: Float) {
        currentFraction = fraction
        valueHolder?.calculateValue(fraction: fraction)
    }

    public func getAnimatedValue() -> T? {
        return valueHolder?.animatedValue
    }
}
