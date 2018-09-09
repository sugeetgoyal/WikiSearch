//
//  WikiSearchLogic.swift
//  WikiSearch
//
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

class WikiSearchLogic: ApiCallBack {
    var apiCallback: ApiCallBack?

    func getWikiSearchData(for text: String, callBackObject: ApiCallBack) {
        self.apiCallback = callBackObject
        APIRouter().getWikiSearchData(for: text, callback: self)
    }
    
    //MARK: ApiCallBack Delegate
    
    public func onSuccess(_ data: AnyObject?, _ apiType: String) -> Void {
        if let aSearchAPIResponse = data as? SearchAPIResponse, let aQuery = aSearchAPIResponse.query{
            let aWikiSearch = WikiSearch()
            for aPage in aQuery.pages {
                let aSearchAPIAppModel = SearchAPIAppModel()
                aSearchAPIAppModel.title = aPage.title
                aSearchAPIAppModel.imageURL = aPage.thumbnail?.source
                aSearchAPIAppModel.description = aPage.terms?.description?.first
                aSearchAPIAppModel.id = aPage.pageid
                aWikiSearch.data.append(aSearchAPIAppModel)
            }
            
            apiCallback?.onSuccess?(aWikiSearch, apiType)
        }
    }
    
    public func onError(_ errorMessage: ErrorResponse, apiType: String) {
        apiCallback?.onError?(errorMessage, apiType: apiType)
    }
}
