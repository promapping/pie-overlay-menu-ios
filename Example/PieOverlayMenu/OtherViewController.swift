//
//  OtherViewController.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 17/08/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

class OtherViewController: UIViewController, PieOverlayMenuContentView {

    var overlayMenu: PieOverlayMenu?

    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 13
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func previousView(sender: AnyObject) {
        overlayMenu?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
