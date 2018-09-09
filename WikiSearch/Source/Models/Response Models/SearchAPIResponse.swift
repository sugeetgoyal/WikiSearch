//
//  SearchAPIResponse.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import Foundation

public class SearchQueryPageTerms : BaseResponseModel {
    var alias: Array<String>?
    var description: Array<String>?
    var label: Array<String>?
    
    func updateData(_ data: Dictionary<String, Any>) -> SearchQueryPageTerms {
        if let anAlias = data["alias"] as? Array<String> {
            alias = anAlias
        }
        
        if let aDescription = data["description"] as? Array<String> {
            description = aDescription
        }
        
        if let aLabel = data["label"] as? Array<String> {
            label = aLabel
        }
        
        return self
    }
}

public class SearchQueryPageThumbnail : BaseResponseModel {
    var source: String?
    var width: Float?
    var height: Float?
    
    func updateData(_ data: Dictionary<String, Any>) -> SearchQueryPageThumbnail {
        if let aSource = data["source"] as? String {
            source = aSource
        }
        
        if let aWidth = data["width"] as? Float {
            width = aWidth
        }
        
        if let aHeight = data["height"] as? Float {
            height = aHeight
        }
        
        return self
    }
}

public class SearchQueryPage : BaseResponseModel {
    var pageid: Int?
    var ns: Int?
    var title: String?
    var thumbnail: SearchQueryPageThumbnail?
    var pageimage: String?
    var terms: SearchQueryPageTerms?

    func updateData(_ data: Dictionary<String, Any>) -> SearchQueryPage {
        if let aPageid = data["pageid"] as? Int {
            pageid = aPageid
        }
        
        if let aNS = data["ns"] as? Int {
            ns = aNS
        }
        
        if let aTitle = data["title"] as? String {
            title = aTitle
        }
        
        if let aThumbnail = data["thumbnail"] as? Dictionary<String, Any> {
            let t = SearchQueryPageThumbnail()
            thumbnail = t.updateData(aThumbnail)
        }
        
        if let aPageimage = data["pageimage"] as? String {
            pageimage = aPageimage
        }
        
        if let aTerms = data["terms"] as? Dictionary<String, Any> {
            let t = SearchQueryPageTerms()
            terms = t.updateData(aTerms)
        }
        
        return self
    }
}

public class SearchQueryModel: BaseResponseModel {
    var pages = [SearchQueryPage]()
    
    func updateData(_ data: Dictionary<String, Any>) -> SearchQueryModel {
        if let aPages = data["pages"] as? Dictionary<String, Any> {
            for aPage in aPages {
                let page = SearchQueryPage()
                pages.append(page.updateData(aPage.value as! Dictionary<String, Any>))
            }
        }
        
        return self
    }
}

public class SearchAPIResponse: BaseSerializedModel {
    var batchcomplete: Bool?
    var query: SearchQueryModel?

    func updateData(_ data: Dictionary<String, Any>) -> SearchAPIResponse {
        if let aBatchcomplete = data["batchcomplete"] as? Bool {
            batchcomplete = aBatchcomplete
        }
        
        if let aQuery = data["query"] as? Dictionary<String, Any> {
            let q = SearchQueryModel()
            query = q.updateData(aQuery)
        }
        
        return self
    }
}
