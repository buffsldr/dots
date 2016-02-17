//
//  FetchRequestFactory.swift
//  VideoSlicer
//
//  Created by Mark Vader on 9/5/15.
//  Copyright (c) 2015 VaderApps.com. All rights reserved.
//

import Foundation
import CoreData

struct FetchRequestFactory {
    
    func provideFetchRequest(entity: String) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchRequest.includesPropertyValues = true
        fetchRequest.returnsObjectsAsFaults = false
        
        return fetchRequest
    }
    


}
