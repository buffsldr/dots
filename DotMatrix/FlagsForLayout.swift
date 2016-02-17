//
//  FlagsForLayout.swift
//  VideoSlicer
//
//  Created by Mark Vader on 8/29/15.
//  Copyright (c) 2015 VaderApps.com. All rights reserved.
//

import Foundation

struct FlagsForLayout  {
    var dataSourceHasSnapshotMetrics: Bool
    var layoutDataIsValid: Bool
    var layoutMetricsAreValid: Bool
    var useCollectionViewContentOffset: Bool

    init(dataSourceHasSnapshotMetrics: Bool = false, layoutDataIsValid: Bool = false, layoutMetricsAreValid: Bool = false, useCollectionViewContentOffset: Bool = true) {
        self.dataSourceHasSnapshotMetrics = dataSourceHasSnapshotMetrics
        self.layoutDataIsValid = layoutDataIsValid
        self.layoutMetricsAreValid = layoutMetricsAreValid
        self.useCollectionViewContentOffset = true
    }
    
}
