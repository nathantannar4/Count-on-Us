//
//  ExSlideMenuController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/11/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//

import UIKit

class ExSlideMenuController : SlideMenuController {

    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is MainViewController ||
            vc is ProfileViewController ||
            vc is FoodViewController ||
            vc is ServicesViewController ||
            vc is GoodsViewController ||
            vc is ColleaguesViewController ||
            vc is ScheduleViewController ||
            vc is MessagesViewController {
                return true
            }
        }
        return false
    }
}
