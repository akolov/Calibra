//
//  NSWindowExtensions.swift
//  Calibra
//
//  Created by Alexander Kolov on 12/14/15.
//  Copyright © 2015 Alexander Kolov. All rights reserved.
//

import Cocoa

extension NSWindow {

    func fadeIn(duration: NSTimeInterval = 0.1) {
        makeKeyAndOrderFront(nil)
        alphaValue = 0

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 1
        }, completionHandler: nil)
    }

    func fadeOut(duration: NSTimeInterval = 0.1) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 0
        }) {
            self.orderOut(nil)
            self.alphaValue = 1.0
        }
    }

}
