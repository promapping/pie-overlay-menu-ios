//
//  PieOverlayMenu2.swift
//  PieOverlayMenu
//
//  Created by Anas Ait Ali on 28/12/2016.
//  Copyright © 2016 Pie mapping. All rights reserved.
//

import UIKit

public protocol PieOverlayMenuProtocol {
    func setContentViewController(_ viewController: UIViewController, animated: Bool)
    func showMenu(_ animated: Bool)
    func closeMenu(_ animated: Bool)
    func getMenuViewController() -> PieOverlayMenuContentViewController?
}

open class PieOverlayMenu: UIViewController, PieOverlayMenuProtocol {

    open fileprivate(set) var contentViewController: UIViewController?
    open fileprivate(set) var menuViewController: PieOverlayMenuContentViewController?
    fileprivate var visibleViewController: UIViewController?

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

    fileprivate func changeVisibleViewController(_ viewController: UIViewController) {
        visibleViewController?.willMove(toParentViewController: nil)
        self.addChildViewController(viewController)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        visibleViewController?.view.removeFromSuperview()
        visibleViewController?.removeFromParentViewController()
        viewController.didMove(toParentViewController: self)
        visibleViewController = viewController
        setNeedsStatusBarAppearanceUpdate()
    }

    open func setContentViewController(_ viewController: UIViewController, animated: Bool) {
        //TODO: Implement animated
        self.contentViewController?.viewWillDisappear(animated)
        viewController.viewWillAppear(animated)
        self.changeVisibleViewController(viewController)
        self.contentViewController?.viewDidDisappear(animated)
        viewController.viewDidAppear(animated)
        self.contentViewController = viewController
    }

    open func showMenu(_ animated: Bool) {
        //TODO: Implement animated
        self.menuViewController?.viewWillAppear(animated)
        self.changeVisibleViewController(self.menuViewController!)
        self.menuViewController?.viewDidAppear(animated)
    }

    open func closeMenu(_ animated: Bool) {
        //TODO: Implement animated
        self.menuViewController?.viewWillDisappear(animated)
        self.changeVisibleViewController(self.contentViewController!)
        self.menuViewController?.viewDidDisappear(animated)
        _ = self.menuViewController?.popToRootViewControllerAnimated(true)
    }

    open func getMenuViewController() -> PieOverlayMenuContentViewController? {
        return self.menuViewController
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.visibleViewController?.preferredStatusBarStyle ?? .default
    }

}

extension UIViewController {
    public func pieOverlayMenuContent() -> PieOverlayMenuContentViewController? {
        return self.pieOverlayMenu()?.getMenuViewController()
    }

    public func pieOverlayMenu() -> PieOverlayMenuProtocol? {
        var iteration : UIViewController? = self.parent
        if (iteration == nil) {
            return topMostController()
        }
        repeat {
            if (iteration is PieOverlayMenuProtocol) {
                return iteration as? PieOverlayMenuProtocol
            } else if (iteration?.parent != nil && iteration?.parent != iteration) {
                iteration = iteration!.parent
            } else {
                iteration = nil
            }
        } while (iteration != nil)

        return iteration as? PieOverlayMenuProtocol
    }

    internal func topMostController () -> PieOverlayMenuProtocol? {
        var topController : UIViewController? = UIApplication.shared.keyWindow?.rootViewController
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
