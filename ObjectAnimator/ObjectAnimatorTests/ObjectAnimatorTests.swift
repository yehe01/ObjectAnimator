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
    var provider: AnimationFrameCallbackProvider!

    override func setUp() {
        animator = ObjectAnimator(values: [11.0, 22.0, 121212.0], evaluator: FloatEvaluator())
        provider = ManualFrameCallbackProvider()
        AnimationHandler.shared.frameCallbackProvider = provider
    }

    override func tearDown() {
        animator.end()
    }

    func testSetStartTimeWhenFirstFrameArrived() {
        animator.duration = 3

        animator.start()
        XCTAssertEqual(animator.startTime, -1, "Start time should be -1")
        provider.setFrameTime(2)
        XCTAssertEqual(animator.startTime, 2, "Start time should be 2")
    }

    func testEndResetStartTime() {
        animator.duration = 3

        animator.start()
        provider.setFrameTime(0)
        animator.end()
        XCTAssertEqual(animator.startTime, -1, "Start time should be -1")
    }

    func testAnimationEndAfterDuration() {
        animator.duration = 3

        animator.start()
        XCTAssertEqual(animator.isStarted, true, "isStarted should be true")
        provider.setFrameTime(1)
        provider.setFrameTime(5)
        XCTAssertEqual(animator.isStarted, false, "isStarted should be false")
    }

    func testIntermediateAnimatedValue() {
        animator.duration = 5

        animator.start()
        provider.setFrameTime(0)
        provider.setFrameTime(1)
        XCTAssertEqual(animator.getAnimatedValue()!, 15.4, "Animated value should be 15.4")
    }

    func testStartAnimatedValue() {
        animator.duration = 5
        animator.start()
        provider.setFrameTime(0)
        XCTAssertEqual(animator.getAnimatedValue()!, 11.0, "Animated value should be 11.0")
    }

    func testFinalAnimatedValue() {
        animator.duration = 5

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
            var endCalled = false

            func onAnimationStart(animator: ObjectAnimator<Float, FloatEvaluator>) {
                startCalled = true
            }

            func onAnimationEnd(animator: ObjectAnimator<Float, FloatEvaluator>) {
                endCalled = true
            }
        }

        let testListener = TestFloatAnimatorListener()
        let listener = AnimatorListener<Float, FloatEvaluator>(testListener)
        animator.addListener(listener)

        XCTAssertEqual(testListener.startCalled, false, "startCalled should be false")
        XCTAssertEqual(testListener.startCalled, false, "endCalled should be false")

        animator.start()
        provider.setFrameTime(0)

        XCTAssertEqual(testListener.startCalled, true, "startCalled should be true")

        animator.end()
        XCTAssertEqual(testListener.endCalled, true, "endCalled should be true")
    }

    // MARK: Animator using system pulse provider

    func testAnimatorDrivenBySystemPulseProvider() {
        animator.duration = 1
        let expectation = self.expectation(description: "Animation")

        class TestFloatAnimatorListener: AnimatorListenerProtocol {
            var endCalled = false
            var expectation: XCTestExpectation!

            init(exp: XCTestExpectation) {
                self.expectation = exp
            }

            func onAnimationEnd(animator: ObjectAnimator<Float, FloatEvaluator>) {
                endCalled = true
                expectation.fulfill()
            }
        }

        AnimationHandler.shared.frameCallbackProvider = SystemFrameCallbackProvider()
        let testListener = TestFloatAnimatorListener(exp: expectation)
        let listener = AnimatorListener<Float, FloatEvaluator>(testListener)
        animator.addListener(listener)

        XCTAssertEqual(testListener.endCalled, false, "startCalled should be false")
        animator.start()

        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(testListener.endCalled, true, "startCalled should be true")
        XCTAssertEqual(animator.getAnimatedValue(), 121212.0, "Animated value should be 121212.0")
    }

    func testKeyframeAnimatedValues() {
        let intAnimator = ObjectAnimator(values: [1, 2, 3], evaluator: IntEvaluator())
        let expectation = self.expectation(description: "Animation")

        intAnimator.duration = 1

        class TestIntAnimatorListener: AnimatorListenerProtocol {
            var expectation: XCTestExpectation!

            init(exp: XCTestExpectation) {
                self.expectation = exp
            }

            func onAnimationEnd(animator: ObjectAnimator<Int, IntEvaluator>) {
                expectation.fulfill()
            }
        }
        
        AnimationHandler.shared.frameCallbackProvider = SystemFrameCallbackProvider()

        let expectedValues: Set = [1, 2, 3]
        var values: Set<Int> = []
        intAnimator.addUpdateListener() { a in
            guard let value = a.getAnimatedValue() else {
                return
            }
            values.insert(value)
        }

        let testListener = TestIntAnimatorListener(exp: expectation)
        let listener = AnimatorListener<Int, IntEvaluator>(testListener)
        intAnimator.addListener(listener)

        intAnimator.start()
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(values, expectedValues, "Should have all keyframe animated values")
    }

}
