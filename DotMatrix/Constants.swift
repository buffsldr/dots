//
//  Constants.swift
//  Temple52
//
//  Created by Mark Vader on 1/24/16.
//  Copyright © 2016 VaderApps. All rights reserved.
//

import Foundation
import UIKit

typealias MVLoadingBlock = (MVLoading -> Void)?
typealias MVLoadingUpdateBlock = (AnyObject->Void)?

func delay(delay: Double, closure: () -> ()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
}

enum CircleColor: UInt {
    
    case Blue = 0
    case Red
    case Green
    case Yellow
    case Default
    
    func color() -> UIColor {
        switch self {
        case .Blue:
            return .blueColor()
        case .Red:
            return .redColor()
        case .Green:
            return .greenColor()
        case .Yellow:
            return .yellowColor()
        case .Default:
            return .blackColor()
        }
      
    }
    
    func simpleDescription() -> String {
        switch self {
        case .Blue:
            return "blue"
        case .Red:
            return "red"
        case .Green:
            return "green"
        case .Yellow:
            return "yellow"
        case .Default:
            return "white"
        }
    }
    
}
