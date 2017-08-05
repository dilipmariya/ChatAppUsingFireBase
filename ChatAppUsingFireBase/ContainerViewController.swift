//
//  ContainerViewController.swift
//  ToPointPassenger
//
//  Created by Sanjeet Verma on 29/06/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import Foundation
import UIKit
import SlideMenuControllerSwift
class ContainerViewController: SlideMenuController {
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") {
            let navigation = UINavigationController.init(rootViewController: controller)
            self.mainViewController = navigation
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") {
            self.leftViewController = controller
        }
        SlideMenuOptions.panGesturesEnabled = false
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.leftViewWidth = self.view.frame.size.width - 80
        SlideMenuOptions.hideStatusBar = false
        super.awakeFromNib()
    }
    
}
