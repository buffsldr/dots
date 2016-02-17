//
//  CircleView.swift
//  SecondAnimation
//
//  Created by Mark Vader on 2/9/16.
//  Copyright © 2016 vaderapps.com. All rights reserved.
//

import UIKit

extension UIView {
    
    func makeCircular() {
        let cntr: CGPoint = self.center
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.center = cntr
    }
    
}

class CircleView: UIView {

    override func drawRect(rect: CGRect) {
        makeCircular()
    }
    
}
