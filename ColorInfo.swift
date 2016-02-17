//
//  ColorInfo.swift
//  DotMatrix
//
//  Created by Mark Vader on 2/16/16.
//  Copyright © 2016 vaderapps.com. All rights reserved.
//

import Foundation

internal struct ColorInfo {
    
    let rows: Int
    private let columns: Int
    private let colorPattern: [CircleColor]
    
    init(columns: Int, rows: Int, colorPattern: [CircleColor]) {
        self.rows = rows
        self.columns = columns
        self.colorPattern = colorPattern
    }

    internal func colorForIndexPath(indexPath: NSIndexPath) -> CircleColor {
        let actualIndex = convertIndexPathToIndex(indexPath.section, row: indexPath.row)
        let colorReturn = colorForIndex(actualIndex)
        return colorReturn
    }
    
    private func colorForIndex(actualIndex: Int) -> CircleColor {
        if colorPattern.count == 0 {
            return .Default
        }
        return colorPattern[actualIndex % colorPattern.count]
    }
    
    private func convertIndexPathToIndex(section: Int, row: Int) -> Int {
        var counter = row
        for _ in 0..<section {
            counter = counter + columns
        }
        
        return counter
    }
    
    func convertIndexToIndexPath(indexPassed: Int) -> NSIndexPath {
        var rowFound = 0
        var columnFound = 0
        columnFound = indexPassed / columns
        rowFound = indexPassed % columns
        
        return NSIndexPath(forItem: rowFound, inSection: columnFound)
    }
    
}
