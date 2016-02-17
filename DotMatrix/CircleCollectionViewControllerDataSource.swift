//
//  CircleCollectionViewControllerDataSource.swift
//  DotMatrix
//
//  Created by Mark Vader on 2/15/16.
//  Copyright © 2016 VaderApps. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Photos
import CoreLocation

let circleCellIdentifier = "circleCellIdentifier"

protocol DataSourceObserver {
    
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _didRemoveItemsAtIndexPaths indexPaths: [NSIndexPath])
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _didInsertItemsAtIndexPaths indexPaths: [NSIndexPath])
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, didLoadContentWithError: NSError?)
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _performBatchUpdate update: dispatch_block_t , _completionHandler complete: dispatch_block_t?)
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _didRefreshSections sections: NSIndexSet)
    
}

typealias HandlerForCircleFetchAlias = ([Circle], CircleLayout, NSError?) -> Void

class CircleCollectionViewControllerDataSource: NSObject, UICollectionViewDataSource {
    
    let dataSourceObserver: DataSourceObserver

    var rowCount = 0
    var columnCount = 0
    var location: CLLocation?
    var delegate: DataSourceObserver?
    var circles = [Circle]()
    var pendingUpdateBlock: dispatch_block_t?
    var itemSize: CGSize?
    var loadingInstance: MVLoading?
    var loadingComplete = false
    var oldItemsValue = [Circle]()
    var newItemsValue = [Circle]()
    var circleHistory = [NSDate: [Circle]]()
    var stateMachine = VSAAPLLoadableContentStateMachine()
    var loadingState: String {
        set {
            let theStateMachine = stateMachine
            if newValue != theStateMachine.currentState {
                theStateMachine.currentState = newValue
            }
        }
        get {
            if stateMachine.currentState == nil {
                return MVLoadStateInitial
            } else {
                return stateMachine.currentState
            }
        }
    }
    
    required init(dataSourceObserver: DataSourceObserver) {
        self.dataSourceObserver = dataSourceObserver
        super.init()
    }

    func buildCircleArray(quantity: Int, colors: [CircleColor]) -> [CircleColor] {
        var index = 1
        var colorStream = [CircleColor]()
        
        switch quantity {
        case 1:
            if let first = colors.first {
                colorStream.append(first)
            }
        default:
            while index <= quantity {
                for color in colors {
                    if index <= quantity {
                        colorStream.append(color)
                    }
                    index+=1
                }
            }
        }
 
        return colorStream
    }
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return circles.count
    }
    
    func notifyItemsRemovedAtIndexPaths(removedIndexPaths: [NSIndexPath]) {
        assert(NSThread.isMainThread(), "Not Main Thread")
        dataSourceObserver.dataSource(self, _didRemoveItemsAtIndexPaths: removedIndexPaths)
    }
    
    func notifyItemsInsertedAtIndexPaths(insertedIndexPaths: [NSIndexPath]) {
        assert(NSThread.isMainThread(), "Not Main Thread")
        dataSourceObserver.dataSource(self, _didInsertItemsAtIndexPaths: insertedIndexPaths)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(circleCellIdentifier, forIndexPath: indexPath) as? CircleCell else {
            return UICollectionViewCell()
        }

        return configureCell(cell, indexPath: indexPath)
    }
    
    func layoutSectionMetrics(rows: Int, columns: Int, layoutSize: CGSize, colorInfo: ColorInfo) -> LayoutSectionMetrics {
        /// Layout information for section
        var layoutSectionMetricsStruct = LayoutSectionMetricsStruct(layoutSize: layoutSize, colorInfo: colorInfo)
        layoutSectionMetricsStruct.flagsForMetrics =  FlagsForMetrics(backgroundColor: UIColor.whiteColor(), selectedBackgroundColor: UIColor.whiteColor())
        layoutSectionMetricsStruct.backgroundColor = UIColor.clearColor()
        layoutSectionMetricsStruct.separatorColor = UIColor.clearColor()
        layoutSectionMetricsStruct.sectionSeparatorColor = UIColor.clearColor()
        layoutSectionMetricsStruct.headers = []
        layoutSectionMetricsStruct.footers = []
        
        return layoutSectionMetricsStruct
    }
    
    func snapshotMetrics(rows: Int, columns: Int, layoutSize: CGSize, colorInfo: ColorInfo) -> [Int: LayoutSectionMetrics] {
        return [0: layoutSectionMetrics(rows, columns: columns, layoutSize: layoutSize, colorInfo: colorInfo)]
    }
    
    func configureCell(cell: CircleCell, indexPath: NSIndexPath) -> CircleCell {
       // cell.backgroundColor = UIColor.whiteColor()
   
        
        return cell
    }
    
    func setCircles(circlesPassed: [Circle], animated: Bool) {
        circles = circlesPassed
        oldItemsValue = newItemsValue
        newItemsValue = circlesPassed
        dataSourceObserver.dataSource(self, _didRefreshSections: NSIndexSet(index: 0))
        updateLoadingStateFromItems()
    }
    
    func setCircleLayout(circleLayout: CircleLayout) {
        rowCount = circleLayout.getRowsValue()
        columnCount = circleLayout.getColumnsValue()
        dataSourceObserver.dataSource(self, _didRefreshSections: NSIndexSet(index: 0))
        updateLoadingStateFromItems()
    }
    
    func beginLoading() {
        loadingComplete = false
        loadingState = loadingState == MVLoadStateInitial || loadingState == MVLoadStateLoadingContent ? MVLoadStateLoadingContent: MVLoadStateRefreshingContent
    }
    
    func endLoadingWithState(state: String, error: NSError?, update: dispatch_block_t?) {
        loadingState = state
        notifyBatchUpdate {[weak self] in
            self?.executePendingUpdates()
            update?()
        }
        notifyContentLoadedWithError(error)
    }
    
    func notifyContentLoadedWithError(error: NSError?) {
        assert(NSThread.isMainThread(), "Not Main Thread")
        delegate?.dataSource(self, didLoadContentWithError: error)
    }
    
    func notifyBatchUpdate(update: dispatch_block_t) {
        notifyBatchUpdate(update, complete: nil)
    }
    
    func notifyBatchUpdate(update: dispatch_block_t, complete: dispatch_block_t?) {
        assert(NSThread.isMainThread(), "Not Main Thread")
        if let delegate = delegate {
            delegate.dataSource(self, _performBatchUpdate: update, _completionHandler: complete)
        }
    }
    
    func executePendingUpdates() {
        assert(NSThread.isMainThread(), "Not Main Thread")
        if let cookyPendingUpdateBlock = pendingUpdateBlock {
            let block: dispatch_block_t  = cookyPendingUpdateBlock
            pendingUpdateBlock = nil
            block()
        }
    }
    
    func loadContentWithBlock(block: MVLoadingBlock?) {
        beginLoading()
        // what is after loadingWithCompletionHandler is the loading.block from MVLoading
        let loading = MVLoading.loadingWithCompletionHandler {[weak self] newState, myError, update in
            if let newState = newState {
                self?.endLoadingWithState(newState, error: myError){
                    if let update123 = update, validSelf = self, update44 = update123  {
                        update44(validSelf)
                    }
                }
            }
        }
        
        loadingInstance?.current = false
        loadingInstance = loading
        if let block = block {
            block?(loading)
        }
    }
    
    @objc func loadContent() {
        loadContentWithBlock({ loading in
            let handler: (([Circle], CircleLayout, NSError?) -> Void) = { circleArray, circleLayout, myError in
                if myError == nil {
                    switch (loading.current, circleArray.count) {
                    case (false, _):
                        loading.ignore()
                    case (true, 0):
                        loading.updateWithNoContent({ dataSource in
                            if let dataSource = dataSource as? CircleCollectionViewControllerDataSource {
                                dataSource.setCircleLayout(circleLayout)
                                dataSource.setCircles([], animated: true)
                            }
                        })
                    case (true, 0...1000):
                        loading.updateWithContent({ content in
                            if let content = content as? CircleCollectionViewControllerDataSource {
                               // TODO: Fix the following line of code
                                content.setCircleLayout(circleLayout)
                                content.setCircles(circleArray, animated: true)
                            }
                        })
                    default:
                        break
                    }
                } else {
                    loading.doneWithError(myError)
                }
            }
            
        })
    }
    
    func updateLoadingStateFromItems() {
        let loadingStateHere = loadingState
        let numberOfItems: Int = circles.count
        if numberOfItems != 0 && loadingStateHere == "MVLoadStateNoContent" {
            loadingState = "MVLoadStateContentLoaded"
        } else if numberOfItems == 0 && loadingStateHere == "MVLoadStateContentLoaded" {
            loadingState = "MVLoadStateNoContent"
        }
    }
    
}
