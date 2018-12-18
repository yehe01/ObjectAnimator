//
// Created by Ye He on 2018-12-15.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public class ObjectAnimator<T, U: TypeEvaluator>: AnimationFrameCallback where U.valueType == T {

    private var startTime: TimeInterval = -1
    private var isStarted = false
    private var isRunning = false
    private var currentFraction: Float = 0.0;

    public var duration: TimeInterval = -1
    var valueHolder: PropertyValuesHolder<T, U>?

    var updateListeners: Array<(ObjectAnimator) -> Void> = []

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

    public func addUpdateListener(_ listener: @escaping (ObjectAnimator) -> Void) {
        updateListeners.append(listener)
    }

    public func removeAllUpdateListeners() {
        updateListeners.removeAll()
    }

    public func animateValue(fraction: Float) {
        currentFraction = fraction
        valueHolder?.calculateValue(fraction: fraction)

        _ = updateListeners.map { l in
            l(self)
        }
    }

    public func animateBasedOnTime(currentTime: TimeInterval) {
        let fraction = (Float)((currentTime - startTime) / duration)
        animateValue(fraction: fraction)
    }

    public func doAnimationFrame(frameTime: TimeInterval) {
        animateBasedOnTime(currentTime: frameTime)
    }

    public func start() {
        guard isStarted == false else {
            return
        }
        startTime = 0
        isStarted = true
        addAnimationCallback()
        setCurrentPlayTime(0)
    }

    public func end() {
        startTime = -1
        isStarted = false
//        removeAnimationCallback()
    }

    private func addAnimationCallback() {
        AnimationHandler.shared.addAnimationFrameCallback(self)
    }

    public func getAnimationHandler() -> AnimationHandler {
        return AnimationHandler.shared
    }

    public func getAnimatedValue() -> T? {
        return valueHolder?.animatedValue
    }

    private func setCurrentPlayTime(_ playTime: TimeInterval) {
        let fraction = duration > 0 ? (Float)(playTime / duration) : 1
        currentFraction = fraction
    }
}
