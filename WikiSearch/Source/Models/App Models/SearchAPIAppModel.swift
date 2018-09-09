//
//  SearchAPIAppModel.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import Foundation

open class WikiSearch: BaseSerializedModel {
    open var data = [SearchAPIAppModel]()
}

open class SearchAPIAppModel: BaseSerializedModel {
    open var id: Int?
    open var title: String?
    open var description: String?
    open var imageURL: String?

    open override func setData(_ dictionary: NSDictionary) {
        if let anId = dictionary["id"] as? Int {
            id = anId
        }
        
        if let aTitle = dictionary["title"] as? String {
            title = aTitle
        }
        
        if let aDescription = dictionary["description"] as? String {
            description = aDescription
        }
        
        if let anImageURL = dictionary["imageURL"] as? String {
            imageURL = anImageURL
        }
    }
    
    open override func getData() -> NSDictionary {
        let aData = NSMutableDictionary()
        
        if let anId = self.id {
            aData.setValue(anId, forKey: "id")
        }
        
        if let aTitle = self.title {
            aData.setValue(aTitle, forKey: "title")
        }
        
        if let aDescription = self.description {
            aData.setValue(aDescription, forKey: "description")
        }
        
        if let anImageURL = self.imageURL {
            aData.setValue(anImageURL, forKey: "imageURL")
        }
        
        return aData
    }
}
