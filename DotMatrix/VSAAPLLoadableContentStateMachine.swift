//
//  VSAAPLLoadableContentStateMachine.swift
//  Temple52
//
//  Created by Mark Vader on 1/24/16.
//  Copyright © 2016 VaderApps. All rights reserved.
//

import UIKit

let MVLoadStateInitial = "MVInitial";
let MVLoadStateLoadingContent = "MVLoadingState";
let MVLoadStateRefreshingContent = "MVRefreshingState";
let MVLoadStateContentLoaded = "MVLoadedState";
let MVLoadStateNoContent = "MVNoContentState";
let MVLoadStateError = "MVErrorState";

class VSAAPLLoadableContentStateMachine: AAPLStateMachine {
    
    override init() {
        super.init()
        self.currentState = MVLoadStateInitial
        self.validTransitions =   [
            MVLoadStateInitial: [MVLoadStateLoadingContent],
            MVLoadStateLoadingContent: [MVLoadStateContentLoaded, MVLoadStateNoContent, MVLoadStateError],
            MVLoadStateRefreshingContent: [MVLoadStateContentLoaded, MVLoadStateNoContent, MVLoadStateError],
            MVLoadStateContentLoaded: [MVLoadStateRefreshingContent, MVLoadStateNoContent, MVLoadStateError],
            MVLoadStateNoContent: [MVLoadStateRefreshingContent, MVLoadStateContentLoaded, MVLoadStateError],
            MVLoadStateError: [MVLoadStateLoadingContent, MVLoadStateRefreshingContent, MVLoadStateNoContent, MVLoadStateContentLoaded],
        ]
    }
    
}
