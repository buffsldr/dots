//
//  FrameFunction.swift
//  DotMatrix
//
//  Created by Mark Vader on 2/16/16.
//  Copyright © 2016 vaderapps.com. All rights reserved.
//

import Foundation
import UIKit

struct FrameFunction {
    
    let minHorizontalSpace: CGFloat
    let minVerticalSpace: CGFloat
    let rows: Int
    let columns: Int
    let layoutSize: CGSize
    
    init(minHorizontalSpace: CGFloat, minVerticalSpace: CGFloat, rows: Int, columns: Int, layoutSize: CGSize) {
        self.minHorizontalSpace = minHorizontalSpace
        self.minVerticalSpace = minVerticalSpace
        self.rows = rows
        self.columns = columns
        self.layoutSize = layoutSize
    }
    
    func frameFunction() -> (NSIndexPath -> CGRect) {
        let f: NSIndexPath -> CGRect = {indexPath -> CGRect in
            // determine column width
            // determine rowHeight
            // subtract spacing in appropriate direction
            // use minimum(width, height) for square size of view
            let maxW = self.maxWidth(self.columns, layoutWidth: self.layoutSize.width)
            let maxH = self.maxHeight(self.rows, layoutHeight: self.layoutSize.height)
            let sideDim = min(maxW, maxH)
            let xOrigin = self.minHorizontalSpace + (self.minHorizontalSpace + sideDim) * CGFloat(indexPath.row)
            let yOrigin = self.minVerticalSpace + (self.minVerticalSpace + sideDim) * CGFloat(indexPath.section)
            let rect = CGRectMake(xOrigin, yOrigin, sideDim, sideDim)
            
            return rect
        }
        
        return f
    }
    
    func maxWidth(columns: Int, layoutWidth: CGFloat) -> CGFloat {
        let usableWidth = layoutWidth - CGFloat(columns + 1) * minHorizontalSpace
        let initialSpacing = usableWidth / CGFloat(columns)
        
        return initialSpacing
    }
    
    func maxHeight(rows: Int, layoutHeight: CGFloat) -> CGFloat {
        let usableHeight = layoutHeight - CGFloat(rows + 1) * minVerticalSpace
        let initialSpacing = usableHeight / CGFloat(rows)
        
        return initialSpacing
    }
    
}
