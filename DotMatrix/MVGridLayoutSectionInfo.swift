//
//  MVGridLayoutSectionInfo.swift
//  Video Slicer
//
//  Created by Mark Vader on 11/30/15.
//  Copyright © 2015 Mark Vader. All rights reserved.
//

import UIKit

struct MVGridLayoutSectionInfo {
    
    let itemCount: Int
    var frame: CGRect?
    var items = [MVGridLayoutItemInfo]()
    var rowHeight: CGFloat?
    var backgroundColor: UIColor?
    var width: CGFloat?
    var height: CGFloat?
    var contentOffsetX: CGFloat?
    let frameFunction: NSIndexPath -> CGRect
    
    
    init(minHorizontalSpace: CGFloat, minVerticalSpace: CGFloat, rows: Int, columns: Int, layoutSize: CGSize) {
        frameFunction = FrameFunction(minHorizontalSpace: minHorizontalSpace, minVerticalSpace: minVerticalSpace, rows: rows, columns: columns, layoutSize: layoutSize).frameFunction()
        itemCount = rows * columns
    }
    
}
