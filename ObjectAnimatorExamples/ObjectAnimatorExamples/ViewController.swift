//
//  ViewController.swift
//  ObjectAnimatorExamples
//
//  Created by Ye He on 11/12/18.
//  Copyright © 2018 Ye He. All rights reserved.
//

import UIKit
import ObjectAnimator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let keyframe = Keyframe<Int>(value: 3, fraction: 0.3)
//        print(keyframe)
//        let keyframes = KeyframeSet<Int, IntEvaluator>(values: [11, 22, 121212], evaluator: IntEvaluator())
//        print(keyframes.getKeyframes())

//        keyframes.setEvaluator(evaluator: IntEvaluator())
//        print(keyframes.getValue(fraction: 0.0))
//        print(keyframes.getValue(fraction: 0.5))
//        print(keyframes.getValue(fraction: 1.0))

        let animator = ObjectAnimator(values: [11.0, 22.0, 121212.0], evaluator: FloatEvaluator())
        animator.duration = 5

        print(animator.getAnimatedValue())

        let provider = animator.getAnimationHandler().frameCallbackProvider as! ManualFrameCallbackProvider

        animator.addUpdateListener() { a in
            print("In listener")
            print(a.getAnimatedValue())
        }

        animator.start()
        provider.setFrameTime(1)
//
//        animator.animateValue(fraction: 0.5)
//        print((animator.getAnimatedValue()))
    }


}

