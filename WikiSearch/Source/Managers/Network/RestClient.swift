//
//  RestClient.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

let RESTCLIENT_LOG_TAG = "REST_CLIENT_LOG"

open class RestClient: NSObject,URLSessionDownloadDelegate {
    
    open static let sharedInstance = RestClient()
    open var baseURLString : String?
    
    private var downloadCompletionHandler: ((_ downloadState: Int,_ progressInPercentage: String,_ result: String?,_ response: HTTPURLResponse?, _ error: NSError?)->Void)? //downloadState 1 == progress, 2 == cancel, 3 == finished

    lazy var session: URLSession = {
        let aSessionConfiguration = URLSessionConfiguration.default
        aSessionConfiguration.httpMaximumConnectionsPerHost = 6
        
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        let session = URLSession(configuration: aSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()

    public override init() {
      super.init()
    }

    open func createRequestAndExecuteCall(_ requestString: String, httpMethod: String, headerData: NSDictionary?, bodyData: AnyObject?, taskDescription: String, requestContainsBaseURL: Bool, completionBlock:@escaping (_ isRequestSuccessful: Bool, _ result: Any?, _ response: HTTPURLResponse?, _ error: NSError?) -> Void) -> Void {
		let aRequestCreator = RequestCreator()
        let baseURL = requestContainsBaseURL ? nil : self.baseURLString
		let anURLRequest = aRequestCreator.createRequest(baseURL, requestString: requestString, httpMethod: httpMethod, headerData: headerData, bodyData:bodyData)
        self.executeServerCall(anURLRequest, taskDescription: taskDescription, completionBlock:completionBlock)
	}
    
    open func createDIYRequestAndExecuteCall(_ requestString: String, httpMethod: String, headerData: NSDictionary?, bodyData: NSDictionary?, taskDescription: String, requestContainsBaseURL: Bool, completionBlock:@escaping (_ isRequestSuccessful: Bool, _ result: Any?, _ response: HTTPURLResponse?, _ error: NSError?) -> Void) -> Void {
        let aRequestCreator = RequestCreator()
        let baseURL = requestContainsBaseURL ? nil : self.baseURLString
        var anURLRequest = aRequestCreator.createRequest(baseURL, requestString: requestString, httpMethod: httpMethod, headerData: headerData, bodyData:bodyData)
        anURLRequest.cachePolicy = .reloadIgnoringLocalCacheData
		anURLRequest.timeoutInterval = 60
        anURLRequest.allowsCellularAccess = false
        self.executeServerCall(anURLRequest, taskDescription: taskDescription, completionBlock:completionBlock)
    }
    
    open func createDownloadRequestAndExecuteCall(_ requestString: String, httpMethod: String, headerData: NSDictionary?, bodyData: NSDictionary?, taskDescription: String, requestContainsBaseURL: Bool, completionBlock:@escaping (_ downloadState: Int,_ progressInPercentage: String,_ result: String?,_ response: HTTPURLResponse?, _ error: NSError?) -> Void) -> Void {
        let aRequestCreator = RequestCreator()
        let baseURL = requestContainsBaseURL ? nil : self.baseURLString
        let anURLRequest = aRequestCreator.createRequest(baseURL, requestString: requestString, httpMethod: httpMethod, headerData: headerData, bodyData:bodyData)
        
        if self.downloadCompletionHandler != nil {
            self.downloadCompletionHandler = nil
        }
        
        self.downloadCompletionHandler = completionBlock
        self.executeDownloadCall(anURLRequest, taskDescription: taskDescription)
    }
    
    open func executeDownloadCall(_ urlRequest: URLRequest, taskDescription:String) -> Void {
        print("network call initiated")
        print(urlRequest)
        
        let task = self.session.downloadTask(with: urlRequest)
        
        task.taskDescription = taskDescription
        task.resume()
        
        print("**************** taskDescription : \(taskDescription)**************")
    }

    open func executeServerCall(_ urlRequest: URLRequest, taskDescription:String, completionBlock:@escaping (_ isRequestSuccessful: Bool, _ result: Any?, _ response: HTTPURLResponse?, _ error: NSError?) -> Void) -> Void {
        print("network call initiated")
        print(urlRequest)

        let aSessionDataTask = self.session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            if let anHTTPURLResponse = response as? HTTPURLResponse {
				print(anHTTPURLResponse)

                if (anHTTPURLResponse.statusCode >= 200 && anHTTPURLResponse.statusCode < 300 && error == nil) {
                    if data?.count > 0 {
                        
						do {
							var aResult: Any?
							
							if let anImage = UIImage(data: data!) {
								aResult = anImage
							} else {
								aResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
								print(aResult as Any)
								//ToDo: Dont Remove,Need to get Raw Jason(to create mock data)s
								/* if let aData:NSData = data! as NSData? {
								NSLog(NSString(data: aData as Data, encoding: String.Encoding.utf8.rawValue)! as String)
								}*/
							}
							
							completionBlock(true, aResult as Any?, anHTTPURLResponse, nil)
						} catch let JSONError as NSError {
							print("ERROR: Unable to serialize json, error: \(JSONError)")
							completionBlock(false, nil, anHTTPURLResponse, JSONError as NSError)
						}
                    } else {
						print("\(RESTCLIENT_LOG_TAG) -> message: Request Succesful")
                        completionBlock(true, nil, anHTTPURLResponse, nil)
                    }
                } else {
                    if error != nil {
                        print("executeServerCall failed")
						print(error!)
                        completionBlock(false, nil, anHTTPURLResponse, error as NSError?)
                    } else if (anHTTPURLResponse.statusCode >= 500 && anHTTPURLResponse.statusCode < 600) {
                        completionBlock(false, nil, anHTTPURLResponse, nil)
                    } else {
                        if data != nil {
                            do {
                                let aResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
                                print(aResult)
                                completionBlock(false, aResult as Any?, anHTTPURLResponse, nil)
                            } catch {
                                if anHTTPURLResponse.statusCode == 404  || anHTTPURLResponse.statusCode == 400 {
                                    print("Request Failed with error 404/400")
                                    completionBlock(false, ["message":"Unable to process your request. Please try again."], anHTTPURLResponse, nil)
                                } else {
                                    completionBlock(false, ["message":"Invalid response. Please try again."], anHTTPURLResponse, nil)
                                }
                            }
                        } else {
                            print("Request Failed")
                            completionBlock(false, nil, anHTTPURLResponse, nil)
                        }
                    }
                }

            } else {
                if error != nil {
                    print("executeServerCall failed")
                    print(error!)
                    completionBlock(false, nil, nil, error as NSError?)
                } else {
					print("Request Failed")
                    completionBlock(false, nil, nil, nil)
                }
            }
        })
        
        print("**************** taskDescription : \(taskDescription)**************")
        aSessionDataTask.taskDescription = taskDescription
        aSessionDataTask.resume()
    }
    
    open func cancelTask(whichHas taskDescription : String) {
        print("Task Canceled")
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            print("**************** downloadTasks : \(downloadTasks)**************")

            for dataTask in dataTasks {
                if (dataTask.state == .running || dataTask.state == .suspended) && dataTask.taskDescription == taskDescription {
                    dataTask.cancel()
                    print("**************** cancelled **************")
                }
            }
            
            for downloadTask in downloadTasks {
                if (downloadTask.state == .running || downloadTask.state == .suspended) && downloadTask.taskDescription == taskDescription {
                    downloadTask.cancel()
                    print("**************** cancelled **************")
                }
            }
        }
    }
    
    // MARK:- URLSessionDownloadDelegate
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("File download task completed")

        if let anHTTPURLResponse = downloadTask.response as? HTTPURLResponse {
            if (anHTTPURLResponse.statusCode >= 200 && anHTTPURLResponse.statusCode < 300 ) {
                print("File download task completed")
                let fileManager = FileManager.default
                let tempFolderPath = NSTemporaryDirectory()
                
                let destinationFilename: String? = downloadTask.originalRequest?.url?.lastPathComponent
                let destinationPath: String = URL(fileURLWithPath: tempFolderPath).appendingPathComponent("\(String(describing: destinationFilename!)).mp4").path
                
                if fileManager.fileExists(atPath: destinationPath) {
                    do {
                        try fileManager.removeItem(atPath: destinationPath)
                    } catch let error as NSError {
                        if let downloadCallback = self.downloadCompletionHandler {
                            downloadCallback(3,"", nil,nil, error as NSError?)
                        }
                    }
                }
                
                do {
                    try fileManager.copyItem(atPath: location.path, toPath: destinationPath)
                    
                    if let downloadCallback = self.downloadCompletionHandler {
                        downloadCallback(3,"", destinationPath,nil, nil)
                    }
                } catch let error as NSError {
                    if let downloadCallback = self.downloadCompletionHandler {
                        downloadCallback(4,"", nil,nil, error as NSError?)
                    }
                }
            } else {
                if let downloadCallback = self.downloadCompletionHandler {
                    downloadCallback(4,"",nil,anHTTPURLResponse,nil)
                }
            }
        } else {
            
            if let downloadCallback = self.downloadCompletionHandler {
                downloadCallback(4, "",nil,nil,nil)
            }
            
            print("Request Failed")
        }
        
        if self.downloadCompletionHandler != nil {
            self.downloadCompletionHandler = nil
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
            print("Unknown transfer size")
        } else {
            
           let downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            let progressInPercentage = String(format: "%.01f", downloadProgress*100) + "%"
  
            if let downloadCallback = self.downloadCompletionHandler {
                downloadCallback(1, progressInPercentage,nil,nil, nil)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error != nil){
            print("Session failed")
            print("didCompleteWithError \(String(describing: error?.localizedDescription))")
            
            if let error = error as NSError? {
                if error.code == NSURLErrorCancelled {
                    // canceled
                    if let downloadCallback = self.downloadCompletionHandler {
                        downloadCallback(2, "", nil,nil,nil)
                    }
                } else {
                    // some other error
                    if let downloadCallback = self.downloadCompletionHandler {
                        downloadCallback(3, "", nil,nil, error as NSError?)
                    }
                }
            }
        } else {
            print("The task finished successfully")
        }
        
        if self.downloadCompletionHandler != nil {
            self.downloadCompletionHandler = nil
        }
    }
}
