//
//  HandGestureProcessor.swift
//  MorseTalkiOSClub
//
//  Created by Rahul Narayanan on 10/11/22.
//

import Foundation
import CoreGraphics

class HandGestureModel {
    // Distance
    // The current state of the hand
    // The time of contact
    typealias PointsPair = (thumbTip: CGPoint, indexTip: CGPoint)
    let pinchThreshold: CGFloat
    let countThreshold = 3
    
    enum HandState {
        case pinched, apart, inProgress, unknown
    }
    
    var timePinchedCount = 0.0
    var timePinchedTimer: Timer?
    var isPinchedCount = 0
    var isApartCount = 0
    var currentState: HandState = .unknown {
        didSet {
            if (currentState == .pinched) {
                timePinchedTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.timePinchedCount += 1
                }
            }
        }
    }
    
    init(pinchThreshold: CGFloat = 40) {
        self.pinchThreshold = pinchThreshold
    }
    
    func updatePoints(pointsPair: PointsPair) {
        let distance = pointsPair.indexTip.distance(from: pointsPair.thumbTip)
        if distance < pinchThreshold {
            isPinchedCount += 1
            isApartCount = 0
            currentState = (isPinchedCount > countThreshold && currentState != .pinched) ? .pinched : .inProgress
        } else {
            isApartCount += 1
            isPinchedCount = 0
            // timePinchedTimer = 0
            currentState = (isApartCount > countThreshold) ? .apart : .inProgress
            timePinchedTimer?.invalidate()
            timePinchedCount = 0
        }
    }
}

extension CGPoint {
    
    func distance(from otherPoint: CGPoint) -> CGFloat {
        return hypot(self.x - otherPoint.x, self.y - otherPoint.y)
    }
    
}
