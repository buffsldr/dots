//
//  CircleCollectionViewController.swift
//  TempleAttendance
//
//  Created by Mark Vader on 11/15/15.
//  Copyright © 2015 VaderApps. All rights reserved.
//

import UIKit
import Photos
import CoreData

private let reuseIdentifier = "Cell"
let circleDetailSegueIdentifier = "circleDetailSegueIdentifier"

protocol GridCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    
    func provideRowCount() -> Int
    func provideColumnCount() -> Int
    func provideLayoutSize() -> CGSize
    func minHorizontalSpace() -> CGFloat
    func minVerticalSpace() -> CGFloat
    func provideColorPattern() -> [CircleColor]
    func provideColorInfo() -> ColorInfo
    
}

class CircleCollectionViewController: UICollectionViewController, DataSourceObserver, GridCollectionViewDelegateFlowLayout {
    
    let minimumVerticalSpace: CGFloat = 0
    let minimumHorizontalSpace: CGFloat = 0
    var colorPattern = [CircleColor]()
    lazy var dataSource: CircleCollectionViewControllerDataSource = {
        let dataSource = CircleCollectionViewControllerDataSource(dataSourceObserver: self)
        
        return dataSource
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView?.dataSource = dataSource
        dataSource.loadContent()
        super.viewWillAppear(animated)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) { /* no op */ }
    
    func performSegueWithIdentifierAndTempleVisit(identifier: String, item: Circle) {
        performSegueWithIdentifier(circleDetailSegueIdentifier, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataSource.delegate = self
        registerForNotifications()
    }
    
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _didRemoveItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        collectionView?.deleteItemsAtIndexPaths(indexPaths)
    }
    
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _didInsertItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        collectionView?.insertItemsAtIndexPaths(indexPaths)
        
    }
    
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, didLoadContentWithError: NSError?) {
        dataSource.notifyBatchUpdate({ [weak self] in
            self?.dataSource.executePendingUpdates()
            })
    }
    
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _performBatchUpdate update: dispatch_block_t , _completionHandler complete: dispatch_block_t?) {
        collectionView?.performBatchUpdates({
            update()
            }, completion: { _ in
                
                complete?()
        })
    }
    
    func dataSource(dataSource: CircleCollectionViewControllerDataSource, _didRefreshSections sections: NSIndexSet) {
        collectionView?.reloadData()
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
    }
    
    func registerForNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: nil)
        notificationCenter.addObserver(self, selector: "processDidSaveNotification1775:", name: NSManagedObjectContextDidSaveNotification, object: nil)
        notificationCenter.removeObserver(self, name: rowsColumnsChangedNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handlerRowsColumnsChangedNotification:", name: rowsColumnsChangedNotification, object: nil)
        notificationCenter.removeObserver(self, name: resetPressedNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleResetPressedNotification:", name: resetPressedNotification, object: nil)
        notificationCenter.removeObserver(self, name: photoNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handlePhotoNotification:", name: photoNotification, object: nil)
    }
    
    func deleteAllCircles(circlesPassed: [Circle]? = nil) {
        dataSource.setCircles([], animated: false)
        
    }
    
    func savePhoto() {
        if let collectionView = collectionView {
            let image = UIImage(view: collectionView)
            var changeRequest: PHAssetChangeRequest?
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                changeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                }, completionHandler: { (success, error) -> Void in
            })
        }
    }
    
    func handlePhotoNotification(notification: NSNotification) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .NotDetermined:
            dispatch_async(dispatch_get_main_queue()) {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .Authorized {
                        self.savePhoto()
                    }
                }
            }
        default:
            savePhoto()
        }
        
        
        
    }
    
    func handleResetPressedNotification(notification: NSNotification) {
        deleteAllCircles()
        if let layout = collectionView?.collectionViewLayout as? FlowLayout {
            layout.resetLayoutInfo()
        }
    }
    
    func handlerRowsColumnsChangedNotification(notification: NSNotification) {
        deleteAllCircles()
        if let userInfo = notification.userInfo as? [String: [UInt]], rows = userInfo["rows"]?.first, columns = userInfo["columns"]?.first, colors = userInfo["colors"]  {
            let reset = userInfo["reset"]
            if colors.count == 0 && (reset == nil) {
                return
            }
            
            if let dataSource = collectionView?.dataSource as? CircleCollectionViewControllerDataSource {
                let circleColorPattern = colors.map({ (rawValue) -> CircleColor in
                    
                    return CircleColor(rawValue: rawValue) ?? .Default
                })
                colorPattern = circleColorPattern
                var newCircles = [Circle]()
                var newCircleLayout = [CircleLayout]()
                let completeCircleArray = dataSource.buildCircleArray(Int(columns * rows), colors: circleColorPattern)
                let circleLayout = CircleLayout()
                circleLayout.setRowsValue(Int(rows))
                circleLayout.setColumnsValue(Int(columns))
                circleLayout.blue = colors.contains(CircleColor.Blue.rawValue)
                circleLayout.red = colors.contains(CircleColor.Red.rawValue)
                circleLayout.green = colors.contains(CircleColor.Green.rawValue)
                circleLayout.yellow = colors.contains(CircleColor.Yellow.rawValue)
                newCircleLayout.append(circleLayout)
                
                for (index, circleColor) in completeCircleArray.enumerate() {
                    let circle = Circle()
                    circle.color = circleColor.simpleDescription()
                    circle.presentationOrder = Int64(index)
                    newCircles.append(circle)
                }
                dataSource.setCircles(newCircles, animated: true)
                dataSource.setCircleLayout(newCircleLayout.first!)
            }
            
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: GridCollectionViewDelegateFlowLayout Functions
    
    func provideRowCount() -> Int {
        return dataSource.rowCount
    }
    
    func provideColumnCount() -> Int {
        return dataSource.columnCount
    }
    
    func provideLayoutSize() -> CGSize {
        let actualSize = CGRectInset(collectionView?.bounds ?? CGRectZero, 0, navigationController?.navigationBar.frame.size.height ?? 0).size
        
        return actualSize
    }
    
    func minHorizontalSpace() -> CGFloat {
        return minimumVerticalSpace
    }
    
    func minVerticalSpace() -> CGFloat {
        return minimumVerticalSpace
    }
    
    func provideColorPattern() -> [CircleColor] {
        return colorPattern
    }
    
    func provideColorInfo() -> ColorInfo {
        return ColorInfo(columns: provideColumnCount(), rows: provideRowCount(), colorPattern: provideColorPattern())
    }
    
    
    
}
