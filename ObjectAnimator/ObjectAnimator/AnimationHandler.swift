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
        frameCallbackProvider.reset()

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

    func reset() {
        callback = nil
    }

    public func setFrameTime(_ frameTime: TimeInterval) {
        callback?.doFrame(frameTimeNanos: frameTime)
    }
}

// Provides system pulse using CADisplayLink
public class SystemFrameCallbackProvider: AnimationFrameCallbackProvider {
    var callback: FrameCallback?
    private var displayLink: CADisplayLink? = nil
    
    @objc func step(displaylink: CADisplayLink) {
        print(displaylink.timestamp)
    }
    
    func postFrameCallback(_ callback: FrameCallback) {
        self.callback = callback

        displayLink = CADisplayLink(target: self,
                                    selector: #selector(step))
        
        displayLink?.add(to: .current, forMode: .common)
    }

    func reset() {
        callback = nil
        
        displayLink?.invalidate()
        displayLink = nil
    }

    public func setFrameTime(_ frameTime: TimeInterval) {
        callback?.doFrame(frameTimeNanos: frameTime)
    }
}


protocol AnimationFrameCallback: AnyObject {
    func doAnimationFrame(frameTime: TimeInterval)
}

protocol AnimationFrameCallbackProvider {
    // Set frame callback to run on upcoming frames.
    func postFrameCallback(_ callback: FrameCallback)

    func reset()
}

protocol FrameCallback {
    func doFrame(frameTimeNanos: TimeInterval)
}
