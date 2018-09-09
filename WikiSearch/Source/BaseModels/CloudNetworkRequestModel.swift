//
//  CloudNetworkRequestModel.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//


import UIKit

public enum HttpRequestType:String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

open class CloudNetworkRequestModel {
    fileprivate let NO_OF_RETRIES = 1
    open var apiPath:String?
    open var bodyData:AnyObject?
    open var requestType:HttpRequestType?
    open var observer:BaseNetworkManager?
    open var retryCount = 0
    open var customURL = false
    
    init(extensionURL:String, bodyData:AnyObject?, requestType:HttpRequestType, observer:BaseNetworkManager) {
        self.apiPath = extensionURL
        self.bodyData = bodyData
        self.requestType = requestType
        self.observer = observer
    }
    
    init(extensionURL:String, requestType:HttpRequestType, observer:BaseNetworkManager) {
        self.apiPath = extensionURL
        self.requestType = requestType
        self.observer = observer
    }
    
    open func setRetry(){
        retryCount += 1
    }
    
    open func hasRetry() -> Bool {
        return (retryCount >= NO_OF_RETRIES)
    }
}
