//
//  Slider.swift
//  Calibra
//
//  Created by Alexander Kolov on 12/15/15.
//  Copyright © 2015 Alexander Kolov. All rights reserved.
//

import Cocoa

class Slider: NSSlider {

    override func scrollWheel(theEvent: NSEvent) {
        let range = maxValue - minValue

        var delta: CGFloat = 0
        if abs(theEvent.deltaX) > abs(theEvent.deltaY) {
            delta = theEvent.deltaX
        }
        else {
            delta = -theEvent.deltaY
        }

        let increment = (range * Double(delta)) / 1000.0
        var value = doubleValue + increment

        if value < minValue {
            value = maxValue - abs(increment)
        }

        if value > maxValue {
            value = minValue - abs(increment)
        }

        doubleValue = value
        sendAction(action, to: target)
    }

}
