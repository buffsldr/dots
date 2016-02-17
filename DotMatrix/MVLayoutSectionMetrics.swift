//
//  LayoutSectionMetrics.swift
//  VideoSlicer
//
//  Created by Mark Vader on 8/29/15.
//  Copyright (c) 2015 VaderApps.com. All rights reserved.
//

import UIKit

protocol LayoutSectionMetrics {
    
    var flagsForMetrics: FlagsForMetrics? { get set }
    var backgroundColor: UIColor? { get set }
    var separatorColor: UIColor? { get set }
    var sectionSeparatorColor: UIColor? { get set }
    var rowHeight: CGFloat? { get set }
    var headers: [UICollectionReusableView]? { get set }
    var footers: [UICollectionReusableView]? { get set }
    var colorInfo: ColorInfo { get set }
    
}

protocol LayoutItemMetrics: LayoutSectionMetrics {
    
    var frame: CGRect { get set }
    var alpha: CGFloat { get set }
    var hidden: Bool { get set }
    
}

struct LayoutSectionMetricsStruct: LayoutSectionMetrics {
    
    init(layoutSize: CGSize, colorInfo: ColorInfo) {
 
        self.layoutSize = layoutSize
        self.colorInfo = colorInfo
    }
    
    var flagsForMetrics: FlagsForMetrics? =  FlagsForMetrics(backgroundColor: UIColor.blackColor(), selectedBackgroundColor: UIColor.blackColor())
    var backgroundColor: UIColor? = UIColor.blackColor()
    var separatorColor: UIColor? = UIColor.blackColor()
    var sectionSeparatorColor: UIColor? = UIColor.blackColor()
    var rowHeight: CGFloat?
    var headers: [UICollectionReusableView]? = []
    var footers: [UICollectionReusableView]? = []
    var layoutSize = CGSizeZero
    var colorInfo: ColorInfo
}
