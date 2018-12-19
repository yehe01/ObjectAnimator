//
// Created by Ye He on 2018-12-15.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public class ObjectAnimator<T, U: TypeEvaluator>: AnimationFrameCallback where U.valueType == T {

    var startTime: TimeInterval = -1
    var isStarted = false
    private var isRunning = false
    private var currentFraction: Float = 0.0;

    public var duration: TimeInterval = -1
    var valueHolder: PropertyValuesHolder<T, U>?

    var updateListeners: Array<(ObjectAnimator) -> Void> = []
    var listeners: [AnimatorListener<T, U>] = []

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

    private func animateBasedOnTime(currentTime: TimeInterval) -> Bool {
        let fraction = (Float)((currentTime - startTime) / duration)
        let lastIterationFinished = fraction >= 1
        animateValue(fraction: fraction)
        return lastIterationFinished
    }

    public func doAnimationFrame(frameTime: TimeInterval) {
        if startTime < 0 {
            startTime = frameTime
        }
        let finished = animateBasedOnTime(currentTime: frameTime)

        if finished {
            end()
        }
    }

    public func start() {
        guard isStarted == false else {
            return
        }

        startTime = -1
        isStarted = true
        addAnimationCallback()
        notifyStartListeners()
        setCurrentPlayTime(0)
    }

    private func notifyStartListeners() {
        _ = listeners.map { l in
            l.onAnimationStart(animator: self)
        }
    }

    public func end() {
        startTime = -1
        isStarted = false
        removeAnimationCallback()
    }

    private func addAnimationCallback() {
        AnimationHandler.shared.addAnimationFrameCallback(self)
    }

    private func removeAnimationCallback() {
        AnimationHandler.shared.removeAnimationFrameCallback(self)
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

    public func addListener(_ v: AnimatorListener<T, U>) {
        listeners.append(v)
    }
}

public protocol AnimatorListenerProtocol {
    associatedtype myType
    associatedtype evaluatorType: TypeEvaluator where evaluatorType.valueType == myType

    func onAnimationStart(animator: ObjectAnimator<myType, evaluatorType>)
}

// https://stackoverflow.com/a/34584464
public struct AnimatorListener<T, E: TypeEvaluator>: AnimatorListenerProtocol where E.valueType == T {
    private let _onAnimationStart: (ObjectAnimator<T, E>) -> ()

    init<P: AnimatorListenerProtocol>(_ dep: P) where P.myType == T, P.evaluatorType == E {
        _onAnimationStart = dep.onAnimationStart
    }

    public func onAnimationStart(animator: ObjectAnimator<T, E>) {
        _onAnimationStart(animator)
    }
}

