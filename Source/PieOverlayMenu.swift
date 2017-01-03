//
//  PieOverlayMenu2.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 28/12/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

public protocol PieOverlayMenuProtocol {
    func setContentViewController(viewController: UIViewController, animated: Bool)
    func showMenu(animated: Bool)
    func closeMenu(animated: Bool)
    func getMenuViewController() -> PieOverlayMenuContentViewController?
}

public class PieOverlayMenu: UIViewController, PieOverlayMenuProtocol {

    public private(set) var contentViewController: UIViewController?
    public private(set) var menuViewController: PieOverlayMenuContentViewController?
    private var visibleViewController: UIViewController?

    // MARK: - Init methods -
    public init() {
        super.init(nibName: nil, bundle: nil)
        print("this is not handled yet")
    }

    public init(contentViewController: UIViewController, menuViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        self.contentViewController = contentViewController
        self.menuViewController = PieOverlayMenuContentViewController(rootViewController: menuViewController)
        self.changeVisibleViewController(contentViewController)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func changeVisibleViewController(viewController: UIViewController) {
        visibleViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        visibleViewController?.view.removeFromSuperview()
        visibleViewController?.removeFromParentViewController()
        viewController.didMoveToParentViewController(self)
    }

    public func setContentViewController(viewController: UIViewController, animated: Bool) {
        //TODO: Implement animated
        self.contentViewController?.viewWillDisappear(animated)
        viewController.viewWillAppear(animated)
        self.changeVisibleViewController(viewController)
        self.contentViewController?.viewDidDisappear(animated)
        viewController.viewDidAppear(animated)
        self.contentViewController = viewController
    }

    public func showMenu(animated: Bool) {
        //TODO: Implement animated
        self.menuViewController?.viewWillAppear(animated)
        self.changeVisibleViewController(self.menuViewController!)
        self.menuViewController?.viewDidAppear(animated)
    }

    public func closeMenu(animated: Bool) {
        //TODO: Implement animated
        self.menuViewController?.viewWillDisappear(animated)
        self.changeVisibleViewController(self.contentViewController!)
        self.menuViewController?.viewDidDisappear(animated)
        self.menuViewController?.popToRootViewControllerAnimated(true)
    }

    public func getMenuViewController() -> PieOverlayMenuContentViewController? {
        return self.menuViewController
    }
}

extension UIViewController {
    public func pieOverlayMenuContent() -> PieOverlayMenuContentViewController? {
        return self.pieOverlayMenu()?.getMenuViewController()
    }

    public func pieOverlayMenu() -> PieOverlayMenuProtocol? {
        var iteration : UIViewController? = self.parentViewController
        if (iteration == nil) {
            return topMostController()
        }
        repeat {
            if (iteration is PieOverlayMenuProtocol) {
                return iteration as? PieOverlayMenuProtocol
            } else if (iteration?.parentViewController != nil && iteration?.parentViewController != iteration) {
                iteration = iteration!.parentViewController
            } else {
                iteration = nil
            }
        } while (iteration != nil)

        return iteration as? PieOverlayMenuProtocol
    }

    internal func topMostController () -> PieOverlayMenuProtocol? {
        var topController : UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
        if (topController is UITabBarController) {
            topController = (topController as! UITabBarController).selectedViewController
        }
        var lastMenuProtocol : PieOverlayMenuProtocol?
        while (topController?.presentedViewController != nil) {
            if(topController?.presentedViewController is PieOverlayMenuProtocol) {
                lastMenuProtocol = topController?.presentedViewController as? PieOverlayMenuProtocol
            }
            topController = topController?.presentedViewController
        }

        if (lastMenuProtocol != nil) {
            return lastMenuProtocol
        }
        else {
            return topController as? PieOverlayMenuProtocol
        }
    }
}
