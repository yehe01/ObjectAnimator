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
        // Do any additional setup after loading the view, typically from a nib.

        let keyframe = Keyframe<Int>(value: 3, fraction: 0.3)
        print(keyframe)
        let keyframes = KeyframeSet<Int, IntEvaluator>(values: [11, 22, 121212], evaluator: IntEvaluator())
//        print(keyframes.getKeyframes())

//        keyframes.setEvaluator(evaluator: IntEvaluator())
        print(keyframes.getValue(fraction: 0.0))
        print(keyframes.getValue(fraction: 0.5))
        print(keyframes.getValue(fraction: 1.0))

        let animator = ObjectAnimator(values: [11, 22, 121212], evaluator: IntEvaluator())
        print(animator.getAnimatedValue())
        animator.animateValue(fraction: 0.5)
        print((animator.getAnimatedValue()))
    }


}

