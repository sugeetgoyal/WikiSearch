//
//  RequestCreator.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//

import UIKit

class RequestCreator: NSObject {
	func createRequest(_ baseURLString: String?, requestString: String, httpMethod: String, headerData: NSDictionary?, bodyData: AnyObject?) -> URLRequest {
		let anURL: URL?
			
		if let baseURL = baseURLString {
            if !requestString.contains(baseURL) {
                anURL = URL(string: requestString, relativeTo: URL(string: baseURL))
            } else {
                anURL = URL(string: requestString)
            }
		} else {
			anURL = URL(string: requestString)
		}
			
		let anURLRequest = NSMutableURLRequest(url: anURL!)
		anURLRequest.httpMethod = httpMethod

		if let aHeaderData = headerData {
			anURLRequest.allHTTPHeaderFields = aHeaderData as? [String : String]
		}

		if let aBodyData = bodyData {
            if aBodyData is Data {
                anURLRequest.httpBody = aBodyData as? Data
            } else {
                anURLRequest.httpBody = try! JSONSerialization.data(withJSONObject: aBodyData, options:[])
                
                if let dataString = String(data:anURLRequest.httpBody!, encoding:String.Encoding.utf8), anURLRequest.url?.absoluteString.contains("session") == false {
                    print(dataString)
                }
            }
		}

		return anURLRequest as URLRequest
	}
}
