//
//  ViewController.swift
//  ObjectAnimatorExamples
//
//  Created by Ye He on 11/12/18.
//  Copyright © 2018 Ye He. All rights reserved.
//

import UIKit
import ObjectAnimator
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    private var polyline: MKPolyline?
    private var points: [CLLocationCoordinate2D] = []
    private var mapView: MKMapView!
    private var startAnnotation: MKPointAnnotation?
    private var endAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView(frame: .zero)
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: mapView, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0)
        })
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        recognizer.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(recognizer)
        mapView.delegate = self
        
        let initLocation = CLLocationCoordinate2D(latitude: -37.812115, longitude: 144.962625)
        let viewRegion = MKCoordinateRegion(center: initLocation, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        
        if startAnnotation == nil {
            startAnnotation = annotation
            mapView.addAnnotation(annotation)
        } else if endAnnotation == nil {
            endAnnotation = annotation
            mapView.addAnnotation(annotation)
            showRouteOnMap(start: startAnnotation!.coordinate, end: endAnnotation!.coordinate)
        } else {
            mapView.removeAnnotations([startAnnotation!, endAnnotation!])
            if let polyline = polyline {
                mapView.removeOverlay(polyline)
                self.polyline = nil
            }
            endAnnotation = nil
            startAnnotation = annotation
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func showRouteOnMap(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: end, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.polyline = route.polyline
//            self.mapView.addOverlay(route.polyline)
            
            let rect = route.polyline.boundingMapRect
            let padding = CGFloat(20.0)
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), animated: true)
            
            self.animateRouteDrawing()
        }
        
    }
    
    func animateRouteDrawing() {
        guard let polyline = self.polyline else {
            return
        }
        
        points = []
        let coordinates = polyline.coordinates
        
        // Adjust keyframe fraction based on distance to achive uniform speed
       let animator = getUniformSpeedAnimator(coordinates)
        
//         let animator = ObjectAnimator(values: coordinates, evaluator: LatLngEvaluator())
        
        animator.duration = 3
        animator.addUpdateListener { [weak self] animator in
            guard let coordinate = animator.getAnimatedValue() else {
                return
            }
            
            self?.points.append(coordinate)
            guard let points = self?.points, let polyline = self?.polyline else {
                return
            }
            
            let newPolyline = MKPolyline(coordinates: points, count: points.count)
            self?.polyline = newPolyline
            self?.mapView.addOverlay(newPolyline)
            self?.mapView.removeOverlay(polyline)
        }
        
        animator.start()
    }
    
    func getUniformSpeedAnimator(_ coordinates: [CLLocationCoordinate2D]) -> ObjectAnimator<CLLocationCoordinate2D, LatLngEvaluator> {
        var totalDistance = 0.0
        for i in 1..<coordinates.count {
            let coordinate = coordinates[i]
            let prevCoordinate = coordinates[i - 1]
            let distance = coordinate.distance(from: prevCoordinate)
            totalDistance += distance
        }
        
        var keyframes: [Keyframe<CLLocationCoordinate2D>] = []
        
        keyframes.append(Keyframe(value: coordinates[0], fraction: 0.0))
        
        var currentDistance = 0.0
        for i in 1..<coordinates.count {
            let coordinate = coordinates[i]
            let prevCoordinate = coordinates[i - 1]
            let distance = coordinate.distance(from: prevCoordinate)
            currentDistance += distance
            
            var fraction: Float
            if i == coordinates.count - 1 {
                fraction = 1.0
            } else {
                fraction = Float(currentDistance / totalDistance)
            }
            
            keyframes.append(Keyframe(value: coordinates[i], fraction: fraction))
        }
        
        let valueHolder = PropertyValuesHolder(keyframes: keyframes, evaluator: LatLngEvaluator())
        return ObjectAnimator(valueHolder: valueHolder)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
    }
}

extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)
        
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        
        return coords
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
