//
//  UIViewController+Extensions.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 22/08/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

extension UIViewController {
    public var pieOverlayMenu : PieOverlayMenu {
        return PieOverlayMenu.sharedInstance
    }

    public func openPieOverlayMenu() {
        self.presentViewController(self.pieOverlayMenu, animated: true, completion: nil)
    }
}
