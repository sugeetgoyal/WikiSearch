//
//  RequestTaskManager.swift
//  LyricFoundation
//
//  Created by Goyal, Sugeet on 23/03/17.
//  Copyright © 2017 Lokanatha Reddy J. All rights reserved.
//

import UIKit

public enum TaskDescription : String {
    case UNKNOWN = ""
    case DOWNLOAD = "Download"
}

open class RequestTaskManager: NSObject {
    open func cancelTask(whichHas taskDescription : TaskDescription) {
        RestClient.sharedInstance.cancelTask(whichHas: taskDescription.rawValue)
    }
}
