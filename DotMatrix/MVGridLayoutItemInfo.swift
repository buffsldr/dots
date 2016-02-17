//
//  MVGridLayoutItemInfo.swift
//  VideoSlicer
//
//  Created by Mark Vader on 8/29/15.
//  Copyright (c) 2015 VaderApps.com. All rights reserved.
//

import UIKit

struct MVGridLayoutItemInfo {
    
    var backgroundColor = UIColor.blackColor()
    let circleColor: UIColor
    var hidden = false
    var shouldShowFilmStrip = false
    let row: Int
    let column: Int
    let indexPath: NSIndexPath
    
    init(indexPath: NSIndexPath, circleColor: UIColor) {
        self.indexPath = indexPath
        self.row = indexPath.row
        self.column = indexPath.section
        self.circleColor = circleColor
    }

}
