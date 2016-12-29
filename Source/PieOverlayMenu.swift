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

    public init(contentViewController: UIViewController, menuViewController: PieOverlayMenuContentViewController) {
        super.init(nibName: nil, bundle: nil)

        self.contentViewController = contentViewController
        self.menuViewController = menuViewController
        self.changeVisibleViewController(menuViewController)
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
        self.contentViewController = viewController
        self.changeVisibleViewController(self.contentViewController!)
    }

    public func showMenu(animated: Bool) {
        //TODO: Implement animated
        self.changeVisibleViewController(self.menuViewController!)
    }

    public func closeMenu(animated: Bool) {
        //TODO: Implement animated
        self.changeVisibleViewController(self.contentViewController!)
        self.menuViewController?.popToRootViewControllerAnimated(false)
    }

    public func getMenuViewController() -> PieOverlayMenuContentViewController? {
        return self.menuViewController
    }
}

extension UIViewController {
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
