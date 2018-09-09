//
//  BaseNetworkManager.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

enum ErrorResponseCode : Int {
    case UserAlreadyRegisteredNotActivated, Unknown
}

open class ErrorResponse : NSObject {
    open var errorCode: Int = 0
    open var errorMessage: String?
    open var error: NSError?
    open var obj: AnyObject?
    open var stringErrorCode: String?
}

public protocol NetworkCallBack {
    func onComplete(_ obj: AnyObject) -> Void
    func onError(_ errorMessage: ErrorResponse) -> Void
}

@objc public protocol ApiCallBack {
    @objc optional func onError(_ errorMessage: ErrorResponse, apiType: String) -> Void
    @objc optional func onSuccess(_ data: AnyObject?, _ apiType: String) -> Void
}

open class NetworkEnvironment {
    open static let sharedInstance = NetworkEnvironment()
    
    open var baseURLString = "https://en.wikipedia.org/w/api.php?"
    open var isTest = false
    open var isTestSuccess = false
    
    open var sessionID = String()
    open var CSRFToken = String()
    open var Cookie = String()
    open var userId = 0
	open var userName: String?
	open var password: String?

    open let baseHeader: NSMutableDictionary = ["Accept" : "application/json", "Content-Type" : "application/json"]
    
    lazy var anAcceptLanguages: [String] = {
        var aLanguageList = [String]()
        
        for (anIndex, aLanguage) in Locale.preferredLanguages.enumerated() {
            let anQualityIndex = 1 - (0.1*Double(anIndex))
            aLanguageList.append("\(aLanguage);q=\(anQualityIndex)")
            
            if anQualityIndex < 0.5 {
                break
            }
        }
        
        return aLanguageList
    }()
}

open class BaseNetworkManager: NSObject, NetworkCallBack {
    let networkEnvironment = NetworkEnvironment.sharedInstance

    open func execute(_ requestModel: CloudNetworkRequestModel, taskDescription: TaskDescription = .UNKNOWN, contentType: String = "application/json; charset=utf-8") -> Void {
        self.networkEnvironment.baseHeader["Content-Type"] = contentType
        let aHeaders = self.networkEnvironment.baseHeader.mutableCopy() as? NSMutableDictionary
        
        if requestModel.customURL {
            RestClient.sharedInstance.baseURLString = ""

        } else {
            RestClient.sharedInstance.baseURLString = networkEnvironment.baseURLString
        }
        
        RestClient.sharedInstance.createRequestAndExecuteCall(requestModel.apiPath!, httpMethod: (requestModel.requestType?.rawValue)!, headerData: aHeaders, bodyData: requestModel.bodyData, taskDescription: taskDescription.rawValue, requestContainsBaseURL: false, completionBlock: {(isRequestSuccessful: Bool, result: Any?, response: HTTPURLResponse?, error: NSError?) -> Void in
            
            self.handleResponse(requestModel: requestModel, isRequestSuccessful: isRequestSuccessful, result: result, response: response, error: error)
        })
    }
    
    //MARK: - Call back Handlers

    fileprivate func handleResponse(requestModel: CloudNetworkRequestModel, isRequestSuccessful: Bool, result: Any?, response: HTTPURLResponse?, error: NSError?) {
        DispatchQueue.main.async(execute: {
            if isRequestSuccessful &&  result != nil {
                if (result is NSArray == true) {
                    requestModel.observer?.onComplete(result! as AnyObject)
                } else if (result is NSDictionary == true) {
                    requestModel.observer?.onComplete(result! as AnyObject)
                } else if result is UIImage {
                    requestModel.observer?.onComplete(result! as! UIImage)
                } else if result is Bool == true {
                    requestModel.observer?.onComplete(result! as AnyObject)
                } else {
                    let anErrorResponse = ErrorResponse()
                    let (aCode, aMessage, aStringErrorCode) = self.getErrorMessageAndCode(withResult: result as AnyObject?, withError: error, andResponse: response)
                    anErrorResponse.errorMessage = aMessage
                    anErrorResponse.error = error
                    anErrorResponse.errorCode = aCode
                    anErrorResponse.obj = result as AnyObject
                    anErrorResponse.stringErrorCode = aStringErrorCode
                    requestModel.observer?.onError(anErrorResponse)
                }
            } else {
                let anErrorResponse = ErrorResponse()
                let (aCode, aMessage, aStringErrorCode) = self.getErrorMessageAndCode(withResult: result as AnyObject?, withError: error, andResponse: response)
                anErrorResponse.errorMessage = aMessage
                anErrorResponse.error = error
                anErrorResponse.errorCode = aCode
                anErrorResponse.obj = result as AnyObject
                anErrorResponse.stringErrorCode = aStringErrorCode
                requestModel.observer?.onError(anErrorResponse)
            }
        })
    }
    
    open func onComplete(_ obj: AnyObject) -> Void {}
    
    open func onError(_ errorMessage: ErrorResponse) -> Void {}
    
    //MARK: - Support methode
    
    func getErrorMessageAndCode(withResult aResult: AnyObject?, withError anError: NSError?, andResponse aResponse: HTTPURLResponse?) -> (Int, String, String) {
        var anErrorMessage = NSLocalizedString("Unknown_Error_Occured_Message", comment: "Unknown Error Occurred")
        var anErrorCode = ErrorResponseCode.Unknown.rawValue
        var aStringErrorCode = ""

        if aResult != nil {
            if aResult is NSDictionary {
                if let anErrorDictionary = aResult as? NSDictionary {
                    if (anErrorDictionary["fields"] != nil) {
                        if let anArrayObj = anErrorDictionary["fields"] as? NSArray {
                            if let aDictObj = anArrayObj[0] as? NSDictionary {
                                if aDictObj["field"] as? String == "OldPassword" || aDictObj["field"] as? String == "passwordinfo.oldPassword"{
                                    anErrorMessage = anErrorDictionary["message"] as? String ?? NSLocalizedString("Unknown_Error_Occured_Message", comment: "Unknown Error Occurred")
                                } else {
                                    anErrorMessage = aDictObj["code"] as? String ?? NSLocalizedString("Unknown_Error_Occured_Message", comment: "Unknown Error Occurred")
                                }
                                
                                anErrorCode = self.getAnErrorCode(from: anErrorDictionary)
                                aStringErrorCode = self.getAStringErrorCode(from: anErrorDictionary)
                            }
                        }
                    } else {
                        if (anErrorDictionary["message"] != nil) {
                            anErrorMessage = anErrorDictionary["message"] as? String ?? NSLocalizedString("Unknown_Error_Occured_Message", comment: "Unknown Error Occurred")
                        }
                        
                        anErrorCode = self.getAnErrorCode(from: anErrorDictionary)
                        aStringErrorCode = self.getAStringErrorCode(from: anErrorDictionary)
                    }
                }
            }
        } else if anError != nil {
            anErrorMessage = anError?.localizedDescription ?? NSLocalizedString("Unknown_Error_Occured_Message", comment: "Unknown Error Occurred")
            anErrorCode = anError?.code ?? ErrorResponseCode.Unknown.rawValue
        } else {
            anErrorCode = aResponse?.statusCode ?? ErrorResponseCode.Unknown.rawValue
        }
        
        return (anErrorCode, anErrorMessage, aStringErrorCode)
    }
    
    fileprivate func getAnErrorCode(from anErrorDictionary : NSDictionary) -> Int {
        var anErrorCode : Int
        
        if let anErrorCodeStr = anErrorDictionary["code"] as? String {
            switch anErrorCodeStr {
            case "UserAlreadyRegisteredNotActivated":
                anErrorCode =  ErrorResponseCode.UserAlreadyRegisteredNotActivated.rawValue
            default:
                anErrorCode =  ErrorResponseCode.Unknown.rawValue
            }
        } else {
            anErrorCode = ErrorResponseCode.Unknown.rawValue
        }
        
        return anErrorCode
    }
    
    fileprivate func getAStringErrorCode(from anErrorDictionary : NSDictionary) -> String {
        if let anErrorCodeString = anErrorDictionary["code"] as? String {
            return anErrorCodeString
        }
        
        return ""
    }
}
