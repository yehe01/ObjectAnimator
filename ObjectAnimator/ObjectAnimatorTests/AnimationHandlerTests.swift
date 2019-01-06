//
//  AnimationHandlerTests.swift
//  ObjectAnimatorTests
//
//  Created by Ye He on 24/12/18.
//  Copyright © 2018 Ye He. All rights reserved.
//

import XCTest
@testable import ObjectAnimator

class AnimationHandlerTests: XCTestCase {
    var animator: ObjectAnimator<Float, FloatEvaluator>!
    var animator2: ObjectAnimator<Float, FloatEvaluator>!
    var provider: AnimationFrameCallbackProvider!
    
    override func setUp() {
        animator = ObjectAnimator(values: [11.0, 22.0, 121212.0], evaluator: FloatEvaluator())
        animator2 = ObjectAnimator(values: [11.0, 22.0, 121212.0], evaluator: FloatEvaluator())
        provider = ManualFrameCallbackProvider()
        AnimationHandler.shared.frameCallbackProvider = provider
    }

    override func tearDown() {
        animator.end()
        animator2.end()
    }

    func testSingleAnimatorCallbackRemovedWhenAnimationEnds() {
        let handler = AnimationHandler.shared
        animator.duration = 3
        
        animator.start()
        provider.setFrameTime(1)
        XCTAssertFalse(handler.animationCallbacks.isEmpty, "Animator callbacks should not be empty")
        
        provider.setFrameTime(5)
        XCTAssertTrue(handler.animationCallbacks.isEmpty, "Animator callbacks should be empty")
    }
    
    func testMultipleAnimatorCallbacksWhenAnimationEnds() {
        let handler = AnimationHandler.shared
        animator.duration = 3
        animator2.duration = 5
        
        animator.start()
        animator2.start()
        
        provider.setFrameTime(1)
        XCTAssertEqual(handler.animationCallbacks.count, 2, "Should have 2 animator callbacks")
        
        provider.setFrameTime(5)
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 1 animator callbacks")
        
        provider.setFrameTime(7)
        XCTAssertEqual(handler.animationCallbacks.count, 0, "Animator callbacks should be empty")
    }

    func testAnimatorCallbackRemovedWhenNextFrameArrivesAndAnimationIsPaused() {
        let handler = AnimationHandler.shared
        animator.duration = 3
        
        animator.start()
        provider.setFrameTime(0)
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 1 animator callbacks")
        animator.pause()
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 1 animator callbacks until next frame arrives")
        provider.setFrameTime(1)
        XCTAssertEqual(handler.animationCallbacks.count, 0, "Should have 0 animator callbacks")
    }
    
    func testAnimatorCallbackOnlyRemovedOnceWhenAnimationPausedTwice() {
        let handler = AnimationHandler.shared
        animator.duration = 3
        animator2.duration = 5
        
        animator.start()
        animator2.start()
        
        provider.setFrameTime(0)
        XCTAssertEqual(handler.animationCallbacks.count, 2, "Should have 2 animator callbacks")
        
        animator2.pause()
        provider.setFrameTime(1)
        animator2.pause()
        provider.setFrameTime(2)
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 2 animator callbacks")
    }
    
    func testAnimatorCallbackAddedWhenAnimationChangedFromPausedToResumed() {
        let handler = AnimationHandler.shared
        animator.duration = 3
        
        animator.start()
        provider.setFrameTime(0)
        animator.pause()
        provider.setFrameTime(1)
        XCTAssertEqual(handler.animationCallbacks.count, 0, "Should have 0 animator callback")
        
        animator.resume()
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 1 animator callback")
    }
    
    func testAnimatorCallbackOnlyAddedOnceWhenAnimationResumesTwice() {
        let handler = AnimationHandler.shared
        animator.duration = 3
        
        animator.start()
        provider.setFrameTime(0)
        animator.pause()
        provider.setFrameTime(1)
        XCTAssertEqual(handler.animationCallbacks.count, 0, "Should have 0 animator callback")
        
        animator.resume()
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 1 animator callback")
        
        animator.resume()
        XCTAssertEqual(handler.animationCallbacks.count, 1, "Should have 1 animator callback")
    }
}
