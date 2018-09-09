//
//  HUD.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import Foundation
import JGProgressHUD

struct HUD {
    static func show() {
        if let v = AppDelegate.shared.window {
            AppDelegate.shared.HUD.show(in: v, animated: true)
        }
    }
    static func hide() {
        AppDelegate.shared.HUD.dismiss(animated: true)
    }
    
    static func show(in view: UIView) {
        AppDelegate.shared.HUD.show(in: view, animated: true)
    }
    
    static func toggle(to shouldShow: Bool) {
        if shouldShow {
            HUD.show()
        }else {
            HUD.hide()
        }
    }
}
