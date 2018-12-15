//
//  Keyframe.swift
//  ObjectAnimator
//
//  Created by Ye He on 11/12/18.
//  Copyright © 2018 Ye He. All rights reserved.
//

import Foundation

public struct Keyframe<T> {
    let value: T?
    let fraction: Float

    public init(value: T? = nil, fraction: Float) {
        self.value = value
        self.fraction = fraction
    }
}
