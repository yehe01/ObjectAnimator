//
// Created by Ye He on 2018-12-14.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public protocol Keyframes {
    associatedtype myType
    associatedtype evaluatorType: TypeEvaluator where evaluatorType.valueType == myType

    var evaluator: evaluatorType { get set }

    func getValue(fraction: Float) -> myType
    func getKeyframes() -> [Keyframe<myType>]
//    func setEvaluator<T: TypeEvaluator>(evaluator: T)
}

public class KeyframeSet<T, U: TypeEvaluator>: Keyframes where U.valueType == T {
    var keyframes: [Keyframe<T>]
    public var evaluator: U

    init(keyframes: [Keyframe<T>], evaluator: U) {
        self.keyframes = keyframes
        self.evaluator = evaluator
    }

    public convenience init(values: [T], evaluator: U) {
        let numKeyframes = values.count
        var keyframes: [Keyframe<T>] = []
        if numKeyframes == 1 {
            keyframes.append(Keyframe<T>(fraction: 0.0))
            keyframes.append(Keyframe<T>(value: values[0], fraction: 1.0))
        } else {
            keyframes.append(Keyframe<T>(value: values[0], fraction: 0.0))
            for i in 1..<values.count {
                let fraction = Float(i) / Float(numKeyframes - 1)
                keyframes.append(Keyframe<T>(value: values[i], fraction: fraction))
            }
        }
        self.init(keyframes: keyframes, evaluator: evaluator)
    }

    public func getValue(fraction: Float) -> T {
        var prevKeyframe = keyframes[0]
        for i in 1..<keyframes.count {
            let nextKeyframe = keyframes[i]
            if fraction < nextKeyframe.fraction {
                let prevFraction = prevKeyframe.fraction
                let intervalFraction = (fraction - prevFraction) / (nextKeyframe.fraction - prevFraction)
                return evaluator.evaluate(fraction: intervalFraction, startValue: prevKeyframe.value!, endValue: nextKeyframe.value!)
            } else {
                prevKeyframe = nextKeyframe
            }
        }
        return prevKeyframe.value!
    }

    public func getKeyframes() -> [Keyframe<T>] {
        return keyframes
    }
}

extension Keyframes {
    public func getValue(fraction: Float) -> myType {
        fatalError("getValue(fraction:) has not been implemented")
    }

    public func getKeyframes() -> [Keyframe<myType>] {
        fatalError("getKeyframes() has not been implemented")
    }
}