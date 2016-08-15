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

        self.showMenu(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMenu(sender: AnyObject) {
        let vc = PieOverlayMenu()
        let menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewControllerID")
        vc.displayContentController(menuVC)

        let triggerTime = (Int64(NSEC_PER_SEC) * 3)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            let aVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AViewControllerID")
            vc.displayContentController(aVC)
        })

        let triggerTime2 = (Int64(NSEC_PER_SEC) * 6)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime2), dispatch_get_main_queue(), { () -> Void in
            vc.displayContentController(menuVC)
        })

        self.presentViewController(vc, animated: true, completion: nil)
    }

}

