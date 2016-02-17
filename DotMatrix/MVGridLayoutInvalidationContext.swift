//
//  MVGridLayoutInvalidationContext.swift
//  Video Slicer
//
//  Created by Mark Vader on 3/26/15.
//  Copyright (c) 2015 Mark Vader. All rights reserved.
//

import UIKit

class MVGridLayoutInvalidationContext: UICollectionViewFlowLayoutInvalidationContext {
    
    var invalidateLayoutMetrics: Bool = true {
        willSet(newValue){
            if newValue == true {
                self.invalidateFlowLayoutDelegateMetrics = true
                self.invalidateFlowLayoutAttributes = true
            }
        }
    }
    var invalidateImageFilterType: Int?
    var invalidateLayoutOrigin: Bool = false
    
}
