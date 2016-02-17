//
//  MVLoading.swift
//  Video Slicer
//
//  Created by Mark Vader on 12/13/14.
//  Copyright (c) 2014 Mark Vader. All rights reserved.
//

import UIKit

typealias HandlerTypeAlias = ((String?, NSError?, MVLoadingUpdateBlock?)->Void)?

class MVLoading: NSObject {

    var block123: ((String?, NSError?, MVLoadingUpdateBlock?) -> Void)?
    var current: Bool
    
    func doneWithNewState(newState: String?, error: NSError?, update: MVLoadingUpdateBlock?) {
        if let block123 = self.block123 {
            dispatch_async(dispatch_get_main_queue(), {
                block123(newState, error, update);
            });
        }
    }
    
    override init() {
        self.current = true
    }
    
    class func loadingWithCompletionHandler(alias: HandlerTypeAlias) -> MVLoading {
        let loading = MVLoading()
        loading.block123 = alias
        
        return loading
    }
    
    func ignore() {
        self.doneWithNewState(nil, error: nil, update: nil)
    }
    
    func done() {
        self.doneWithNewState(MVLoadStateContentLoaded, error: nil, update: nil)

    }
    
    func updateWithContent(update: MVLoadingUpdateBlock) {
        self.doneWithNewState(MVLoadStateContentLoaded, error: nil, update: update)
    }
    
    func doneWithError(error: NSError?) {
        var newState: String?
        if (error != nil) {
            newState = MVLoadStateError
        }
        
        let soldStateString = newState
        self.doneWithNewState(soldStateString, error: error, update: nil)
    }
    
    func updateWithNoContent(update: MVLoadingUpdateBlock) {
        self.doneWithNewState(MVLoadStateNoContent, error: nil, update: update)

    }

}
