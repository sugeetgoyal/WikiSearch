//
//  APIRouter.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

class APIRouter: NSObject {
    func getWikiSearchData(for text: String, callback: ApiCallBack) {
        WikiSearchNetworkManager().getWikiSearchData(for: text, callBackObject: callback)
    }
}
