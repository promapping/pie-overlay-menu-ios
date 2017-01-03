//
//  ViewController.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 15/08/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        self.showMenu(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMenu(sender: AnyObject) {
        self.pieOverlayMenuContent()?.dataSource = self
        self.pieOverlayMenu()?.showMenu(false)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let menuVC = storyboard.instantiateViewControllerWithIdentifier("MenuViewControllerID")
//
//        self.pieOverlayMenu.pushViewController(menuVC, animated: false)
//        self.pieOverlayMenu.dataSource = self
//
//        self.openPieOverlayMenu()
    }

}

extension ViewController : PieOverlayMenuDataSource {

    func overlayMenuTitleForFooter(currentViewController: UIViewController?) -> String? {
        if let dict = NSBundle.mainBundle().infoDictionary {
            if let version = dict["CFBundleShortVersionString"] as? String,
                let bundleVersion = dict["CFBundleVersion"] as? String,
                let appName = dict["CFBundleName"] as? String {
                return "\(appName) v\(version) (Build \(bundleVersion))."
            }
        }
        return nil
    }

    func overlayMenuTitleForHeader(currentViewController: UIViewController?) -> String? {
        switch currentViewController {
        case is MenuViewController:
            return "Menu"
        default:
            return "N/A"
        }
    }

}
