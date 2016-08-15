//
//  PieOverlayMenu.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 15/08/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

class PieOverlayMenu: UIViewController {

    let topView : UIView = UIView()
    let closeButton : UIButton = UIButton()
    let titleLabel : UILabel = UILabel()
    let contentView : UIView = UIView()
    let footerView : UIView = UIView()
    let footerLabel : UILabel = UILabel()
    var viewsDictionary : [String:AnyObject]!

    weak var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    //MARK: - Views setup
    func setupViews() {
        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.view.backgroundColor = UIColor(red: 67/255, green: 75/255, blue: 90/255, alpha: 1.0)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        viewsDictionary = [
            "topLayoutGuide": self.topLayoutGuide,
            "topView":topView,
            "closeButton": closeButton,
            "titleLabel": titleLabel,
            "contentView": contentView,
            "footerView": footerView,
            "footerLabel": footerLabel
        ]

        self.view.accessibilityIdentifier = "vcView"

        setupTopView()
        setupContentAndFooterViews()
    }

    func setupTopView() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        //        topView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.2)
        self.view.addSubview(topView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let menuCloseImage = UIImage(named: "menu_close_button")
        closeButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        closeButton.setImage(menuCloseImage, forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(PieOverlayMenu.close), forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(closeButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Menu"
        titleLabel.font = UIFont.boldSystemFontOfSize(25)
        titleLabel.textColor = UIColor.whiteColor()
        topView.addSubview(titleLabel)

        let closeButtonConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[closeButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let closeButtonConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-18-[closeButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        topView.addConstraints(closeButtonConstraintsV)
        topView.addConstraints(closeButtonConstraintsH)

        let titleLabelConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[titleLabel]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let titleLabelConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:[closeButton]-32-[titleLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        topView.addConstraints(titleLabelConstraintsV)
        topView.addConstraints(titleLabelConstraintsH)

        let topViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-[topView(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let topViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[topView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        view.addConstraints(topViewConstraintsV)
        view.addConstraints(topViewConstraintsH)
    }

    func setupContentAndFooterViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        //        contentView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
        contentView.clipsToBounds = true
        contentView.accessibilityIdentifier = "contentView"
        self.view.addSubview(contentView)

        footerView.translatesAutoresizingMaskIntoConstraints = false
        //        footerView.backgroundColor = UIColor.magentaColor().colorWithAlphaComponent(0.2)
        footerView.accessibilityIdentifier = "footerView"
        self.view.addSubview(footerView)

        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "Pie for Drivers Version 1.0(7)"
        footerLabel.textColor = UIColor.whiteColor()
        footerLabel.font = UIFont.systemFontOfSize(12)
        footerLabel.textAlignment = NSTextAlignment.Center
        footerView.addSubview(footerLabel)

        footerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[footerLabel]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary))
        footerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[footerLabel]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary))

        let contentViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[topView]-50-[contentView]-75-[footerView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let contentViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[contentView]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        view.addConstraints(contentViewConstraintsV)
        view.addConstraints(contentViewConstraintsH)
        let footerViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[footerView(50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let footerViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[footerView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        view.addConstraints(footerViewConstraintsV)
        view.addConstraints(footerViewConstraintsH)
    }

    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func displayContentController(viewController: UIViewController) {
        currentViewController?.willMoveToParentViewController(nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(viewController)
        self.addSubview(viewController.view, toView:self.contentView)
        self.currentViewController?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        viewController.view.alpha = 1
        viewController.view.transform = CGAffineTransformMakeScale(1.0, 0.01)
        viewController.view.layoutIfNeeded()

        UIView.animateWithDuration(0.5, animations: {
//            self.currentViewController?.view.alpha = 0
            self.currentViewController?.view.transform = CGAffineTransformMakeScale(1.0, 0.01)
            viewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            viewController.view.alpha = 1
        }) { _ in
//            UIView.animateWithDuration(0.5, animations: {
//
//                }, completion: { finished in
                    self.currentViewController?.view.removeFromSuperview()
                    self.currentViewController?.removeFromParentViewController()
                    viewController.didMoveToParentViewController(self)
                    self.currentViewController = viewController
//            })
        }
    }

    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)

        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
}







