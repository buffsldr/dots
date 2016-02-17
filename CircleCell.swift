//
//  CircleCell.swift
//  DotMatrix
//
//  Created by Mark Vader on 2/15/16.
//  Copyright © 2016 vaderapps.com. All rights reserved.
//

import UIKit

class CircleCell: UICollectionViewCell {

    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var circleMaskImageView: UIImageView!
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        if let layoutAttributes = layoutAttributes as? CircleCollectionViewLayoutAttributes {
            circleView?.backgroundColor = layoutAttributes.backgroundColor
        }
    }
    
    override func prepareForReuse() {
        circleView?.backgroundColor = UIColor.blackColor()
    }
 
}
