//
//  ObjectAnimatorTests.swift
//  ObjectAnimatorTests
//
//  Created by Ye He on 11/12/18.
//  Copyright © 2018 Ye He. All rights reserved.
//

import XCTest
@testable import ObjectAnimator

class ObjectAnimatorTests: XCTestCase {

    var animator: ObjectAnimator<Float, FloatEvaluator>!

    override func setUp() {
        animator = ObjectAnimator(values: [11.0, 22.0, 121212.0], evaluator: FloatEvaluator())
    }

    override func tearDown() {
        animator.end()
    }

    func testStartTimeSetToWhenFirstFrameArrived() {
        animator.duration = 3
        let provider = animator.getAnimationHandler().frameCallbackProvider

        animator.start()
        XCTAssertEqual(animator.startTime, -1, "Start time should be -1")
        provider.setFrameTime(2)
        XCTAssertEqual(animator.startTime, 2, "Start time should be 2")
    }

    func testEndResetStartTime() {
        animator.duration = 3
        let provider = animator.getAnimationHandler().frameCallbackProvider

        animator.start()
        provider.setFrameTime(0)
        animator.end()
        XCTAssertEqual(animator.startTime, -1, "Start time should be -1")
    }

    func testAnimationEndAfterDuration() {
        animator.duration = 3
        let provider = animator.getAnimationHandler().frameCallbackProvider

        animator.start()
        provider.setFrameTime(1)
        XCTAssertEqual(animator.startTime, 1, "Start time should be -1")
        XCTAssertEqual(animator.isStarted, true, "isStarted should be true")
        provider.setFrameTime(4)
        XCTAssertEqual(animator.startTime, -1, "Start time should be -1")
        XCTAssertEqual(animator.isStarted, false, "isStarted should be false")
    }

    func testIntermediateAnimatedValue() {
        animator.duration = 5
        let provider = animator.getAnimationHandler().frameCallbackProvider

        animator.start()
        provider.setFrameTime(0)
        provider.setFrameTime(1)
        XCTAssertEqual(animator.getAnimatedValue()!, 15.4, "Animated value should be 15.4")
    }

    func testStartAnimatedValue() {
        animator.duration = 5
        let provider = animator.getAnimationHandler().frameCallbackProvider

        animator.start()
        provider.setFrameTime(0)
        XCTAssertEqual(animator.getAnimatedValue()!, 11.0, "Animated value should be 11.0")
    }

    func testFinalAnimatedValue() {
        animator.duration = 5
        let provider = animator.getAnimationHandler().frameCallbackProvider

        animator.start()
        // first frame arrives at 3
        provider.setFrameTime(3)
        provider.setFrameTime(8)
        XCTAssertEqual(animator.getAnimatedValue()!, 121212.0, "Animated value should be 121212.0")
    }

    func testAnimatorListener() {
        animator.duration = 5

        class TestFloatAnimatorListener: AnimatorListenerProtocol {
            var startCalled = false

            func onAnimationStart(animator: ObjectAnimator<Float, FloatEvaluator>) {
                startCalled = true
            }
        }

        let testListener = TestFloatAnimatorListener()
        let listener = AnimatorListener<Float, FloatEvaluator>(testListener)
        animator.addListener(listener)

        XCTAssertEqual(testListener.startCalled, false, "startCalled should be false")
        animator.start()
        XCTAssertEqual(testListener.startCalled, true, "startCalled should be true")
    }
}
