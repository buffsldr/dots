//
//  FlowLayout.swift
//  Video Slicer
//
//  Created by Mark Vader on 11/27/15.
//  Copyright © 2015 Mark Vader. All rights reserved.
//

import UIKit

let spaceBetweenCells: CGFloat = 15

extension Array {
    func mapFilter<V>(mapFunction map: (Element) -> (V)?) -> [V] {
        var mapped = [V]()
        let _ = self.map { value in
            if let mappedValue = map(value) {
                mapped.append(mappedValue)
            }
        }
        
        return mapped
    }
}

class FlowLayout: UICollectionViewFlowLayout {
    
    var indexPathToItemAttributes = [NSIndexPath: CircleCollectionViewLayoutAttributes]()
    var layoutAttributes = [CircleCollectionViewLayoutAttributes]()
    var flagsForLayout = FlagsForLayout(dataSourceHasSnapshotMetrics: false, layoutDataIsValid: false, layoutMetricsAreValid: false, useCollectionViewContentOffset: true)
    var layoutItemInfo: MVGridLayoutItemInfo?
    var preparingLayout = false
    var oldIndexPathToItemAttributes = [NSIndexPath: CircleCollectionViewLayoutAttributes]()
    var oldLayoutSize = CGSizeZero
    var layoutSize = CGSizeZero
    var sectionMetrics: LayoutSectionMetrics?
    var gridLayoutSectionInfo: MVGridLayoutSectionInfo?
    var insertedIndexPaths = [NSIndexPath]()
    var removedIndexPaths = [NSIndexPath]()
    var verticalSizeClass: UIUserInterfaceSizeClass
    
    required init(coder aDecoder: NSCoder) {
        
        verticalSizeClass = .Regular
        super.init(coder: aDecoder)!
        minimumInteritemSpacing = 5
        
        if let collectionView = collectionView {
            switch collectionView.traitCollection.verticalSizeClass {
            case .Regular:
                itemSize = CGSizeMake(150, 150)
            case .Compact:
                itemSize = CGSizeMake(50, 50)
            case .Unspecified:
                itemSize = CGSizeMake(50, 50) 
            }
        }
    }
    
    override func prepareLayout() {
        if ((collectionView?.window) == nil) {
            flagsForLayout.layoutMetricsAreValid = false
            flagsForLayout.layoutDataIsValid = false
        }
        if let bounds = collectionView?.bounds {
            
            if !CGRectIsEmpty(bounds) {
                do {
                    try buildLayout()
                } catch {
                    assertionFailure()
                }
            }
        }
        super.prepareLayout()
    }
    
    func createLayoutInfoFromDataSource(rows: Int, columns: Int, layoutSize: CGSize, colorInfo: ColorInfo) throws {
        resetLayoutInfo()
        if let delegate = collectionView?.delegate as? GridCollectionViewDelegateFlowLayout, layoutMetrics = snapshotMetrics(rows, columns: columns, layoutSize: layoutSize, colorInfo: colorInfo), metrics = layoutMetrics[0]   {
            do {
                
                try self.gridLayoutSectionInfo = createSectionFromMetrics(metrics, sectionIndex: 0, colorInfo: delegate.provideColorInfo())
            } catch {
                throw NSError(domain: "no metrics", code: 23232, userInfo: nil)
            }
        }
    }
    
    func createSectionFromMetrics(metrics: LayoutSectionMetrics, sectionIndex: Int, colorInfo: ColorInfo) throws -> MVGridLayoutSectionInfo? {
        guard let delegate = collectionView?.delegate as? GridCollectionViewDelegateFlowLayout else {
            return nil
        }
        let rows = delegate.provideRowCount()
        let columns = delegate.provideColumnCount()
        var gridLayoutSectionInfo = MVGridLayoutSectionInfo(minHorizontalSpace: delegate.minHorizontalSpace() , minVerticalSpace: delegate.minVerticalSpace(), rows: rows, columns: columns, layoutSize: delegate.provideLayoutSize())
        gridLayoutSectionInfo.backgroundColor = UIColor.blackColor()
        
        
        for i in 0..<gridLayoutSectionInfo.itemCount {
            let indexPath = metrics.colorInfo.convertIndexToIndexPath(i)
            let circleColor = metrics.colorInfo.colorForIndexPath(indexPath)
            var itemInfo = MVGridLayoutItemInfo(indexPath: indexPath, circleColor: circleColor.color())
            itemInfo.backgroundColor = metrics.backgroundColor ?? UIColor.blackColor()
            gridLayoutSectionInfo.items.append(itemInfo)
        }
        
        return gridLayoutSectionInfo
    }
    
    func buildLayout() throws {
        guard let delegate = collectionView?.delegate as? GridCollectionViewDelegateFlowLayout else {
            return
        }
        
        if flagsForLayout.layoutMetricsAreValid {
            return
        }
        
        if preparingLayout {
            return
        }
        preparingLayout = true
        updateFlagsFromCollectionView()
        if flagsForLayout.layoutDataIsValid == false {
            do {
                try createLayoutInfoFromDataSource(delegate.provideRowCount(), columns: delegate.provideColumnCount(), layoutSize: delegate.provideLayoutSize(), colorInfo: delegate.provideColorInfo())
            } catch {
                throw NSError(domain: "no layout", code: 121, userInfo: nil)
            }
            flagsForLayout = FlagsForLayout(dataSourceHasSnapshotMetrics: true, layoutDataIsValid: true, layoutMetricsAreValid: true, useCollectionViewContentOffset: true)
        }

        guard var gridLayoutSectionInfo = gridLayoutSectionInfo else {
   
           throw NSError(domain: "no gridLayoutSectionInfo", code: 321, userInfo: nil)
        }
        
        if let collectionView = collectionView {
            let contentInset = collectionView.contentInset
            let width = CGRectGetWidth(collectionView.bounds) - contentInset.left - contentInset.right
            let height = CGRectGetHeight(collectionView.bounds) - contentInset.bottom - contentInset.top
            
            
            oldLayoutSize = layoutSize
            layoutSize = CGSizeZero

            
            gridLayoutSectionInfo.width = width
            gridLayoutSectionInfo.height = height
            gridLayoutSectionInfo.contentOffsetX = collectionView.contentOffset.x + contentInset.left

            layoutAttributes = []
            flagsForLayout = FlagsForLayout(dataSourceHasSnapshotMetrics: true, layoutDataIsValid: false, layoutMetricsAreValid: false, useCollectionViewContentOffset: true)
            addLayoutAttributesForSection(gridLayoutSectionInfo)

            if let rightHandMostAttribute = layoutAttributes.last {
                let maxRight = CGRectGetMaxX(rightHandMostAttribute.frame)
                let layoutWidth = maxRight
                layoutSize = CGSizeMake(layoutWidth, height)
            } else {
                layoutSize = CGSizeZero
            }
            preparingLayout = false
        }
        
    }
    
    func addLayoutAttributesForSection(gridLayoutSectionInfo: MVGridLayoutSectionInfo) {
        let someItems = gridLayoutSectionInfo.items
        
        for (index, item) in someItems.enumerate() {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            let framePath = NSIndexPath(forRow: item.row, inSection: item.column)
            let frame = gridLayoutSectionInfo.frameFunction(framePath)
            let newAttribute: CircleCollectionViewLayoutAttributes =  CircleCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            newAttribute.frame = frame
            newAttribute.backgroundColor = item.circleColor
            layoutAttributes.append(newAttribute)
            indexPathToItemAttributes[indexPath] = newAttribute
        }
    }
    
    func snapshotMetrics(rows: Int, columns: Int, layoutSize: CGSize, colorInfo: ColorInfo) -> [Int: LayoutSectionMetrics]? {
        if let dataSource = collectionView?.dataSource as? CircleCollectionViewControllerDataSource {
            if flagsForLayout.dataSourceHasSnapshotMetrics {
                return dataSource.snapshotMetrics(rows, columns: columns, layoutSize: layoutSize, colorInfo: colorInfo)
            }
        }
        
        return nil
    }
    
    func updateFlagsFromCollectionView() {
        flagsForLayout.dataSourceHasSnapshotMetrics = true
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return CircleCollectionViewLayoutAttributes.self
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let itemIndex = indexPath.item
        if let attributes = indexPathToItemAttributes[indexPath] where indexPathToItemAttributes.count > 0 && itemIndex < self.indexPathToItemAttributes.count {
            if self.preparingLayout == true {
               // attributes.hidden = true
            }
            
            return attributes
        }
         if let gridLayoutSectionInfo = gridLayoutSectionInfo where indexPath.row >= 0  && gridLayoutSectionInfo.items.count > indexPath.row {
            let itemInfo = gridLayoutSectionInfo.items[indexPath.row]
            let attributes = CircleCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            let framePath = NSIndexPath(forRow: itemInfo.row, inSection: itemInfo.column)

            attributes.frame = gridLayoutSectionInfo.frameFunction(framePath)
            //attributes.hidden = itemInfo.hidden
            attributes.backgroundColor = itemInfo.backgroundColor
            if self.preparingLayout == true {
               // attributes.hidden = true
            }
            indexPathToItemAttributes[indexPath] = attributes
            layoutAttributes.append(attributes)
            return attributes
        }
        
        return nil
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.mapFilter(mapFunction: { attributes -> UICollectionViewLayoutAttributes? in
            if CGRectIntersectsRect(attributes.frame, rect) {
                return attributes
            }
            return nil
        })
        
    }
    
    func resetLayoutInfo() {
        let tmp = oldIndexPathToItemAttributes
        oldIndexPathToItemAttributes = indexPathToItemAttributes
        indexPathToItemAttributes = tmp
        indexPathToItemAttributes = [: ]
    }
    
    override func collectionViewContentSize() -> CGSize {
        return layoutSize
    }
    
    internal override func invalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [NSIndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        return super.invalidationContextForInteractivelyMovingItems(targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
    }
    
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        if let contextHere = context as? MVGridLayoutInvalidationContext {
            let invalidateDataSourceCounts = contextHere.invalidateDataSourceCounts
            let invalidateEverything = contextHere.invalidateEverything
            let invalidateLayoutMetrics = contextHere.invalidateLayoutMetrics
            let newFlags = FlagsForLayout(dataSourceHasSnapshotMetrics: true, layoutDataIsValid: true, layoutMetricsAreValid: !invalidateLayoutMetrics, useCollectionViewContentOffset: true)
            flagsForLayout = newFlags
            if invalidateEverything {
                flagsForLayout = FlagsForLayout(dataSourceHasSnapshotMetrics: false, layoutDataIsValid: false, layoutMetricsAreValid: false, useCollectionViewContentOffset: false)
            }
            
            if invalidateDataSourceCounts {
                flagsForLayout.layoutDataIsValid = false
            }
            
            if flagsForLayout.layoutDataIsValid {
                let fakeLayoutMetricsAreValid = !(invalidateDataSourceCounts || invalidateLayoutMetrics)
                flagsForLayout = FlagsForLayout(dataSourceHasSnapshotMetrics: true, layoutDataIsValid: true, layoutMetricsAreValid: fakeLayoutMetricsAreValid, useCollectionViewContentOffset: true)
            }
        }
        super.invalidateLayoutWithContext(context)
    }
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        if (updateItems.last != nil)  {
            for updateItem in updateItems {
                let realUpdateItem = updateItem as UICollectionViewUpdateItem
                let indexPathHere = updateItem.indexPathAfterUpdate;
                let indexPathBefore = updateItem.indexPathBeforeUpdate
                if let indexPathBefore = indexPathBefore, indexPathHere = indexPathHere {
                    switch realUpdateItem.updateAction {
                    case .Delete:
                        removedIndexPaths.append(indexPathBefore)
                    case .Insert:
                        insertedIndexPaths.append(indexPathHere)
                    case .Reload:
                        break
                    default:
                        break
                    }
                }
            }
            super.prepareForCollectionViewUpdates(updateItems)
        }
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let result = indexPathToItemAttributes[itemIndexPath]
        if insertedIndexPaths.contains(itemIndexPath) {
            // TODO: Consider adding intro animation
        }
        return result
    }
    
    override func finalizeCollectionViewUpdates() {
        insertedIndexPaths = []
        removedIndexPaths = []
        super.finalizeCollectionViewUpdates()
    }

    override func finalizeAnimatedBoundsChange() {
        let invalidationContext = MVGridLayoutInvalidationContext()
        invalidationContext.invalidateItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
    }
    
    override class func invalidationContextClass() -> AnyClass {
        return MVGridLayoutInvalidationContext.self
    }
    
}
