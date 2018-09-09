//
//  WikiSearchNetworkManager.swift
//  WikiSearch
//
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

class WikiSearchNetworkManager: BaseNetworkManager {
    fileprivate var aCallBackObject: ApiCallBack?
    
    open func getWikiSearchData(for text: String, callBackObject: ApiCallBack) {
        aCallBackObject = callBackObject
        let urlString = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let anAPIPath = "https://en.wikipedia.org/w/api.php?action=query&format=json&generator=prefixsearch&gpssearch=\(urlString ?? "")&prop=pageimages%7Cpageterms&piprop=thumbnail&pithumbsize=50&pilimit=5&redirects=&wbptterms=description"
        
        let networkRequestModel = CloudNetworkRequestModel.init(extensionURL: anAPIPath, bodyData: nil, requestType: HttpRequestType.GET, observer: self)
        networkRequestModel.customURL = true
        super.execute(networkRequestModel)
    }
    
    open override func onComplete(_ data: AnyObject ) -> Void {
        print("WikiSearchNetworkManager onComplete-> \(data)")
        
        let aSearchAPIResponse = SearchAPIResponse()
        
        if let aDataArray = data as? Array<Any>, let aData = aDataArray[0] as? Dictionary<String, Any> {
            let _ = aSearchAPIResponse.updateData(aData)
        }

        if let aData = data as? Dictionary<String, Any> {
            let _ = aSearchAPIResponse.updateData(aData)
        }

        aCallBackObject?.onSuccess?(aSearchAPIResponse, "getWikiSearchData")
    }
    
    open override func onError(_ errorMessage: ErrorResponse ) -> Void {
        print("WikiSearchNetworkManager onError-> \(errorMessage)")
        aCallBackObject?.onError?(errorMessage, apiType: "getWikiSearchData")
    }
}
