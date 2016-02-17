//
//  CircleCollectionViewLayoutAttributes.swift
//  Video Slicer
//
//  Created by Mark Vader on 12/18/14.
//  Copyright (c) 2014 Mark Vader. All rights reserved.
//

import UIKit
import Foundation

class CircleCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var movable: Bool = true
    var backgroundColor: UIColor = UIColor.blackColor()
    var horizontalSizeClass: UIUserInterfaceSizeClass?
    
    override init() {
        super.init()
        hidden = false
    }
    
    required init(horizontalSizeClass: UIUserInterfaceSizeClass) {
        self.horizontalSizeClass = horizontalSizeClass
        super.init()
        size = CGSizeMake(50, 50)
        hidden = false
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let attributes: CircleCollectionViewLayoutAttributes = super.copyWithZone(zone) as! CircleCollectionViewLayoutAttributes
        let attributesStruct = MyAttributes(movable: movable, backgroundColor: backgroundColor)
        attributes.movable = attributesStruct.movable
        attributes.backgroundColor = attributesStruct.backgroundColor
        
        return attributes
    }
    
    override var hash: Int {
        let prime = 31
        var result = 1
        result = prime * result + super.hash
        result = prime * result + movable.hashValue
        result = prime * result + backgroundColor.hashValue + 13
        
        return result
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? CircleCollectionViewLayoutAttributes {
            let yAttributes = (movable: movable,  backgroundColor: backgroundColor)
            let otherMyAttributes = (movable: attributes.movable, backgroundColor: backgroundColor)
            if yAttributes.backgroundColor != otherMyAttributes.backgroundColor {
                return false
            }
            
           // return super.isEqual(object)
        }
        
        return false
    }
    
}
