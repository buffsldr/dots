//
//  CircleLayout.swift
//  DotMatrix
//
//  Created by Mark Vader on 2/16/16.
//  Copyright © 2016 vaderapps.com. All rights reserved.
//

import Foundation
import CoreData

class CircleLayout: NSObject {
    
    func getRowsValue() -> Int {
        return Int(rows ?? 0)
    }
    
    func setRowsValue(rowCount: Int) {
        rows = Int64(rowCount)
    }
    
    func getColumnsValue() -> Int {
        return Int(columns ?? 0)
    }
    
    func setColumnsValue(columnsCount: Int) {
        columns = Int64(columnsCount)
    }
    
    
     var blue: Bool!
     var columns: Int64!
     var green: Bool!
     var red: Bool!
     var rows: Int64!
     var yellow: Bool!
     var firstColor: String?
     var secondColor: String?
     var thirdColor: String?
     var fourthColor: String?
    
}
