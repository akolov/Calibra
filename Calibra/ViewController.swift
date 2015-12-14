//
//  ViewController.swift
//  Calibra
//
//  Created by Alexander Kolov on 11/15/15.
//  Copyright © 2015 Alexander Kolov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // 0.414059 is 180 cd/m²
    let oneCandel: Float = 0.414059 / 180.0

    var activationObserver: AnyObject?
    var deactivationObserver: AnyObject?
    var eventMonitor: AnyObject?
    weak var timer: NSTimer?

    deinit {
        timer?.invalidate()

        let center = NSNotificationCenter.defaultCenter()

        if activationObserver != nil {
            center.removeObserver(activationObserver!)
        }

        if deactivationObserver != nil {
            center.removeObserver(deactivationObserver!)
        }

        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let center = NSNotificationCenter.defaultCenter()

        activationObserver = center.addObserverForName(NSWindowDidBecomeKeyNotification, object: nil, queue: nil) { [weak self] notification in
            self?.updateCurrentBrightnessValue()

            if let strongSelf = self {
                let timer = NSTimer(timeInterval: 0.25, target: strongSelf, selector: Selector("onTimer:"), userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
                strongSelf.timer = timer
            }
        }

        deactivationObserver = center.addObserverForName(NSWindowDidResignKeyNotification, object: nil, queue: nil) { [weak self] notification in
            self?.timer?.invalidate()
        }

        eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { [weak self] event -> NSEvent? in
            self?.keyDown(event)
            return event
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        updateCurrentBrightnessValue()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // MARK: Brightness control

    func enumerateDisplays(execute: (display: io_object_t) -> Void) throws {
        var iterator = io_iterator_t()
        let result = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"), &iterator)

        guard result == kIOReturnSuccess else {
            throw NSError(domain: "com.alexkolov.Calibra", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get display list"])
        }

        var service: io_object_t
        repeat {
            service = IOIteratorNext(iterator)
            guard service != 0 else {
                break
            }

            execute(display: service)
        } while service != 0
    }

    func getDisplaysBrightness() throws -> [Float] {
        let brightnessPtr = UnsafeMutablePointer<Float>.alloc(1)
        var brightness = [Float]()

        try enumerateDisplays { display in
            IODisplayGetFloatParameter(display, 0, kIODisplayBrightnessKey, brightnessPtr)
            brightness.append(brightnessPtr.memory)
        }

        return brightness
    }

    func setDisplaysBrightness(brightness: Float) throws {
        try enumerateDisplays { display in
            IODisplaySetFloatParameter(display, 0, kIODisplayBrightnessKey, brightness)
        }
    }

    // MARK: Interface

    @IBOutlet weak var blurView: NSVisualEffectView! {
        didSet {
            blurView.material = .Popover
            blurView.maskImage = createMaskImage(cornerRadius: 4)
        }
    }

    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var brightnessValue: NSTextField!
    @IBOutlet weak var minusButton: NSButton!
    @IBOutlet weak var plusButton: NSButton!

    @IBOutlet weak var saveButton: NSButton! {
        didSet {
            let color = NSColor(red:0.25, green:0.61, blue:0.98, alpha:1.0)
            saveButton.setTitle(saveButton.title, withColor: color)
        }
    }

    @IBAction func sliderDidChangeValue(sender: NSSlider) {
        do {
            try setDisplaysBrightness(sender.floatValue)

            if Device.platformName == "iMac15,1" {
                brightnessValue.stringValue = "\(convertBrightnessToCandels(sender.floatValue)) cd/m²"//
            }
            else {
                brightnessValue.stringValue = "\(sender.floatValue)"
            }
        }
        catch let error as NSError {
            print("Could not set display brightness: \(error.localizedDescription)")
        }
    }

    @IBAction func onMinusButtonAction(sender: NSButton) {
        decrementBrightness()
    }

    @IBAction func onPlusButtonAction(sender: NSButton) {
        incrementBrightness()
    }

    func onTimer(timer: NSTimer) {
        updateCurrentBrightnessValue()
    }

    override func keyDown(theEvent: NSEvent) {
        switch theEvent.keyCode {
        case 27, 123, 125:
            decrementBrightness()
        case 24 where theEvent.modifierFlags.contains(.ShiftKeyMask), 124, 126:
            incrementBrightness()
        default:
            break
        }
    }

    private func createMaskImage(cornerRadius cornerRadius: CGFloat) -> NSImage {
        let edgeLength = 2.0 * cornerRadius + 1.0
        let maskImage = NSImage(size: NSSize(width: edgeLength, height: edgeLength), flipped: false) { rect in
            let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            NSColor.blackColor().set()
            bezierPath.fill()
            return true
        }

        maskImage.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        maskImage.resizingMode = .Stretch
        return maskImage
    }
    
    // MARK: -
    
    func convertBrightnessToCandels(brightness: Float) -> Int {
        return Int(round(brightness / oneCandel))
    }

    private func updateCurrentBrightnessValue() {
        do {
            if let brightness = try getDisplaysBrightness().first {
                brightnessSlider.floatValue = brightness
                sliderDidChangeValue(brightnessSlider)
            }
        }
        catch let error as NSError {
            print("Could not set display brightness: \(error.localizedDescription)")
        }
    }

    private func decrementBrightness() {
        let newValue = brightnessSlider.floatValue - oneCandel
        if newValue > 0 {
            brightnessSlider.floatValue = newValue
        }
        else {
            brightnessSlider.floatValue = 0
        }

        sliderDidChangeValue(brightnessSlider)
    }

    private func incrementBrightness() {
        let newValue = brightnessSlider.floatValue + oneCandel
        if newValue < 1 {
            brightnessSlider.floatValue = newValue
        }
        else {
            brightnessSlider.floatValue = 1
        }

        sliderDidChangeValue(brightnessSlider)
    }
    
}
