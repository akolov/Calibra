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
        let increment = (range * Double(theEvent.deltaY)) / 1000.0
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
