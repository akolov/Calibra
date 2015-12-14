//
//  MyButton.swift
//  Calibra
//
//  Created by Alexander Kolov on 12/14/15.
//  Copyright © 2015 Alexander Kolov. All rights reserved.
//

import Cocoa

extension NSButton {

    func setTitle(title: String, withColor color: NSColor) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center

        let titleFont = font ?? NSFont.controlContentFontOfSize(0)
        let string = NSAttributedString(string: title, attributes: [
            NSFontAttributeName: titleFont,
            NSFontSizeAttribute: titleFont.pointSize,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraph
        ])

        attributedTitle = string
    }
    
}
