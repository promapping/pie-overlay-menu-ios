//
//  PieOverlayMenu.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 15/08/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

// MARK: - Protocols -

@objc public protocol PieOverlayMenuDelegate {
    optional func overlayMenuCloseButtonPressed()
}

public protocol PieOverlayMenuDataSource {
    func overlayMenuTitleForFooter(currentViewController: UIViewController?) -> String?
    func overlayMenuTitleForHeader(currentViewController: UIViewController?) -> String?
}

public protocol PieOverlayMenuContentView: class {
    var overlayMenu: PieOverlayMenu? { get set }
}

public class PieOverlayMenu: UIViewController {

    // MARK: - Public properties -
    public var dataSource : PieOverlayMenuDataSource? {
        didSet {
            dataSourceUpdate()
        }
    }
    weak public var delegate : PieOverlayMenuDelegate?
    public private(set) var viewControllers: [UIViewController]
    public private(set) var topViewController: UIViewController?

    // MARK: - Private properties -
    private let headerView : UIView = UIView()
    private let closeButton : UIButton = UIButton()
    private let headerLabel : UILabel = UILabel()
    private let contentView : UIView = UIView()
    private let footerView : UIView = UIView()
    private let footerLabel : UILabel = UILabel()
    private var viewsDictionary : [String:AnyObject]!

    // MARK: - Init methods -
    public init(rootViewController: UIViewController) {
        self.viewControllers = [rootViewController]
        super.init(nibName: nil, bundle: nil)

        self.changeContentController(viewControllers.last!, animated: false)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides -
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    // MARK: - Public methods -
    public func close() {
        delegate?.overlayMenuCloseButtonPressed?()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    public func pushViewController(viewController: UIViewController, animated: Bool) {
        // TODO: Maybe append only if it's not in the stack already otherwise throw exception
        self.viewControllers.append(viewController)
        self.changeContentController(viewControllers.last!, animated: animated)
    }

    public func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        if self.viewControllers.count > 1 {
            let poppedViewController = self.viewControllers.popLast()
            self.changeContentController(viewControllers.last!, animated: animated)
            return poppedViewController
        }
        return nil
    }

    // MARK: - Internal methods -
    private func changeContentController(viewController: UIViewController, animated : Bool = true) {
        topViewController?.willMoveToParentViewController(nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(viewController)
        self.addSubview(viewController.view, toView:self.contentView)

        if animated {
            self.topViewController?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            viewController.view.alpha = 1
            viewController.view.transform = CGAffineTransformMakeScale(1.0, 0.01)
            viewController.view.layoutIfNeeded()
            UIView
                .animateWithDuration(1.0,
                                     delay: 0.0,
                                     usingSpringWithDamping: 0.6,
                                     initialSpringVelocity: 10.0,
                                     options: UIViewAnimationOptions.CurveEaseInOut,
                                     animations: {
                                        self.topViewController?.view.transform = CGAffineTransformMakeScale(1.0, 0.01)
                                        viewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
                                        viewController.view.alpha = 1
                }) { _ in
                    self.replaceCurrentViewController(viewController)
            }
        } else {
            self.replaceCurrentViewController(viewController)
        }
    }

    private func replaceCurrentViewController(viewController: UIViewController) {
        self.topViewController?.view.removeFromSuperview()
        self.topViewController?.removeFromParentViewController()
        (viewController as? PieOverlayMenuContentView)?.overlayMenu = self
        self.topViewController = viewController
        self.dataSourceUpdate()
        viewController.didMoveToParentViewController(self)
    }

    private func dataSourceUpdate() {
        guard let dataSource = self.dataSource else { return }

        headerLabel.text = dataSource.overlayMenuTitleForHeader(self.topViewController)
        footerLabel.text = dataSource.overlayMenuTitleForFooter(self.topViewController)
    }

    private func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)

        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }

    // MARK: UI Setup
    private func setupViews() {
        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.view.backgroundColor = UIColor(red: 67/255, green: 75/255, blue: 90/255, alpha: 1.0)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        viewsDictionary = [
            "topLayoutGuide": self.topLayoutGuide,
            "headerView":headerView,
            "closeButton": closeButton,
            "headerLabel": headerLabel,
            "contentView": contentView,
            "footerView": footerView,
            "footerLabel": footerLabel
        ]

        self.view.accessibilityIdentifier = "vcView"

        setupHeaderView()
        setupContentAndFooterViews()
    }

    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        //        headerView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.2)
        self.view.addSubview(headerView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let menuCloseImage = UIImage(named: "menu_close_button")
        closeButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        closeButton.setImage(menuCloseImage, forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(PieOverlayMenu.close), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(closeButton)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.boldSystemFontOfSize(25)
        headerLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(headerLabel)

        let closeButtonConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[closeButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let closeButtonConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-18-[closeButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        headerView.addConstraints(closeButtonConstraintsV)
        headerView.addConstraints(closeButtonConstraintsH)

        let headerLabelConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[headerLabel]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let headerLabelConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:[closeButton]-32-[headerLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        headerView.addConstraints(headerLabelConstraintsV)
        headerView.addConstraints(headerLabelConstraintsH)

        let headerViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-[headerView(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let headerViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[headerView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        view.addConstraints(headerViewConstraintsV)
        view.addConstraints(headerViewConstraintsH)
    }

    private func setupContentAndFooterViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        //        contentView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
//        contentView.clipsToBounds = true
        contentView.accessibilityIdentifier = "contentView"
        self.view.addSubview(contentView)

        footerView.translatesAutoresizingMaskIntoConstraints = false
        //        footerView.backgroundColor = UIColor.magentaColor().colorWithAlphaComponent(0.2)
        footerView.accessibilityIdentifier = "footerView"
        self.view.addSubview(footerView)

        footerLabel.translatesAutoresizingMaskIntoConstraints = false
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

        let contentViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[headerView]-50-[contentView]-75-[footerView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let contentViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[contentView]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        view.addConstraints(contentViewConstraintsV)
        view.addConstraints(contentViewConstraintsH)
        let footerViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[footerView(50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let footerViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[footerView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        view.addConstraints(footerViewConstraintsV)
        view.addConstraints(footerViewConstraintsH)
    }
    
}







