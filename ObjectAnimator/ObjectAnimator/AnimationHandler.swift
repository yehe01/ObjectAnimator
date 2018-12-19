//
// Created by Ye He on 2018-12-16.
// Copyright (c) 2018 Ye He. All rights reserved.
//

import Foundation

public class AnimationHandler {
    static let shared = AnimationHandler()
    public var frameCallbackProvider = ManualFrameCallbackProvider()

    class DefaultFrameCallback: FrameCallback {
        func doFrame(frameTimeNanos: TimeInterval) {
            shared.doAnimationFrame(frameTime: frameTimeNanos)
        }
    }

    var frameCallback = DefaultFrameCallback()

    var animationCallbacks: [AnimationFrameCallback] = []

    func addAnimationFrameCallback(_ animator: AnimationFrameCallback) {
        if animationCallbacks.isEmpty {
            frameCallbackProvider.postFrameCallback(frameCallback);
        }
        if !animationCallbacks.contains(where: { $0 === animator }) {
            animationCallbacks.append(animator);
        }
    }

    func removeAnimationFrameCallback(_ animator: AnimationFrameCallback) {
        frameCallbackProvider.callback = nil

        animationCallbacks = animationCallbacks.filter() { $0 !== animator }
    }


    func doAnimationFrame(frameTime: TimeInterval) {
        _ = animationCallbacks.map { c in
            c.doAnimationFrame(frameTime: frameTime)
        }
    }

}

public class ManualFrameCallbackProvider: AnimationFrameCallbackProvider {
    var callback: FrameCallback?

    func postFrameCallback(_ callback: FrameCallback) {
        self.callback = callback
    }

    public func setFrameTime(_ frameTime: TimeInterval) {
        callback?.doFrame(frameTimeNanos: frameTime)
//        callback = nil
    }
}


protocol AnimationFrameCallback: AnyObject {
    func doAnimationFrame(frameTime: TimeInterval)
}

protocol AnimationFrameCallbackProvider {
    // Posts a frame callback to run on the next frame.
    // The callback runs once then is automatically removed.
    func postFrameCallback(_ callback: FrameCallback)
}

protocol FrameCallback {
    func doFrame(frameTimeNanos: TimeInterval)
}