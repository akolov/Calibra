//
//  WindowController.swift
//  Calibra
//
//  Created by Alexander Kolov on 12/14/15.
//  Copyright © 2015 Alexander Kolov. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.movableByWindowBackground = true
        window?.level = Int(CGWindowLevelForKey(CGWindowLevelKey.ModalPanelWindowLevelKey))

        if let screenFrame = window?.screen?.visibleFrame, windowFrame = window?.frame {
            var startFrame = screenFrame
            startFrame.origin.x += screenFrame.width / 2 - windowFrame.width / 2
            startFrame.origin.y += screenFrame.height / 2 - windowFrame.height / 2
            startFrame.size.width = windowFrame.width
            startFrame.size.height = windowFrame.height
            window?.setFrame(startFrame, display: true)
        }

        window?.fadeIn()
    }

}
