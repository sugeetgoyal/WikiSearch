
//
//  BaseModel.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

open class BaseModel {
    public init() {
        
    }
    
    open func getKey() -> String {
        return String(describing: type(of: self))
    }
}

open class BaseSerializedModel: BaseModel, Serializable {
    public override init() {
        
    }
    
    open func getData() -> NSDictionary {
        return NSDictionary()
    }
    
    open func setData(_ dictionary: NSDictionary) {
        
    }
}
