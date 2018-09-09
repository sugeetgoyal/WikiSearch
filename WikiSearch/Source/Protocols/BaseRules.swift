//
//  SingletonType.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

public protocol SingleInstancible{
    associatedtype T
    static var sharedInstance : T {get}
}

public protocol Configurable {
    func config()
}

public protocol Serializable {
    func getData() -> NSDictionary
    func setData(_ data: NSDictionary)
}
