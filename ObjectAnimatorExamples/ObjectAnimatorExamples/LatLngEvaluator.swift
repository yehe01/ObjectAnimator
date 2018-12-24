//
//  MkMapPointEvaluator.swift
//  ObjectAnimatorExamples
//
//  Created by Ye He on 24/12/18.
//  Copyright © 2018 Ye He. All rights reserved.
//

import Foundation
import MapKit
import ObjectAnimator

public class LatLngEvaluator: TypeEvaluator {
    public init() {
        
    }
    
    public func evaluate(fraction: Float, startValue: CLLocationCoordinate2D, endValue: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat = startValue.latitude + Double(fraction) * (endValue.latitude - startValue.latitude);
        let lng = startValue.longitude + Double(fraction) * (endValue.longitude - startValue.longitude);

        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
