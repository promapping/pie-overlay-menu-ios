//
//  MenuViewController.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 15/08/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.layer.cornerRadius = 13
    }
}


extension MenuViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let pieOverlayMenu = self.pieOverlayMenu()?.getMenuViewController() {
            print("item selected \(indexPath.row)")
            if indexPath.row == 4 {
                pieOverlayMenu.popToRootViewControllerAnimated(true)
            } else {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let aVC = storyboard.instantiateViewControllerWithIdentifier("AViewControllerID")
                pieOverlayMenu.pushViewController(aVC, animated: true)
            }
        }
    }
}

extension MenuViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCellID", forIndexPath: indexPath)
        return cell
    }
    
}
