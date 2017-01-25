import UIKit

// MARK: - Protocols -

@objc public protocol PieOverlayMenuDelegate {
    @objc optional func overlayMenuCloseButtonPressed()
}

public protocol PieOverlayMenuDataSource {
    func overlayMenuTitleForFooter(_ currentViewController: UIViewController?) -> String?
    func overlayMenuTitleForHeader(_ currentViewController: UIViewController?) -> String?
}

open class PieOverlayMenuContentViewController: UIViewController {

    // MARK: - Public properties -
    open var blurEffectStyle: UIBlurEffectStyle? = nil
    open var dataSource : PieOverlayMenuDataSource? {
        didSet {
            dataSourceUpdate()
        }
    }
    weak open var delegate : PieOverlayMenuDelegate?
    open fileprivate(set) var viewControllers: [UIViewController]
    open fileprivate(set) var topViewController: UIViewController?

    // MARK: - Private properties -
    fileprivate var backgroundImage : UIImageView = UIImageView()
    fileprivate let headerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate let closeButton : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        btn.alpha = 0.8
        let image = UIImage(named: "menu_close_button", in: PieOverlayMenuContentViewController.getPieOverlayMenuResourcesBundle(), compatibleWith: nil)
        btn.setImage(image, for: UIControlState())
        return btn
    }()
    fileprivate let headerLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 25)
        lbl.textColor = UIColor.white
        return lbl
    }()
    fileprivate let contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate let footerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate let footerLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.white
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textAlignment = NSTextAlignment.center
        return lbl
    }()
    fileprivate var viewsDictionary : [String:AnyObject]!

    // MARK: - Init methods -
    public init() {
        self.viewControllers = []
        super.init(nibName: nil, bundle: nil)
    }

    public init(rootViewController: UIViewController) {
        self.viewControllers = [rootViewController]
        super.init(nibName: nil, bundle: nil)

        self.changeContentController(viewControllers.last!, animated: false)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.viewControllers = []
        super.init(coder: aDecoder)
    }

    // MARK: - Overrides -
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.view.backgroundColor = UIColor(red: 67/255, green: 75/255, blue: 90/255, alpha: 1.0)
        // You need to set UIViewControllerBasedStatusBarAppearance to NO in your info.plist
        UIApplication.shared.statusBarStyle = .lightContent

        setupViews()

        if let blurEffectStyle = blurEffectStyle {
            // Set up blur effect
            backgroundImage.image = snapshot()
            let blurEffect = UIBlurEffect(style: blurEffectStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = backgroundImage.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyEffectView.frame = backgroundImage.bounds
            vibrancyEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            blurEffectView.contentView.addSubview(vibrancyEffectView)
            backgroundImage.addSubview(blurEffectView)
        } else {
            self.view.backgroundColor = UIColor(red: 67/255, green: 75/255, blue: 90/255, alpha: 1.0)
        }
    }

    // MARK: - Internal methods -
    fileprivate func changeContentController(_ viewController: UIViewController, animated : Bool = true) {
        topViewController?.willMove(toParentViewController: nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(viewController)
        self.contentView.addSubview(viewController.view)
        let viewsDict : [String : Any] = ["subView":viewController.view]
        [NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", options: [], metrics: nil, views: viewsDict),
         NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: [], metrics: nil, views: viewsDict)
            ].forEach { NSLayoutConstraint.activate($0) }
        viewController.viewWillAppear(animated)
        if animated {
            animateChangeContentViewController(viewController)
        } else {
            self.replaceCurrentViewController(viewController)
            viewController.viewDidAppear(false)
        }
    }

    fileprivate func animateChangeContentViewController(_ viewController: UIViewController) {
        self.topViewController?.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        viewController.view.alpha = 1
        viewController.view.transform = CGAffineTransform(scaleX: 1.0, y: 0.01)
        viewController.view.layoutIfNeeded()
        UIView
            .animate(withDuration: 1.0,
                     delay: 0.0,
                     usingSpringWithDamping: 0.6,
                     initialSpringVelocity: 10.0,
                     options: UIViewAnimationOptions(),
                     animations: {
                        self.topViewController?.view.transform = CGAffineTransform(scaleX: 1.0, y: 0.01)
                        viewController.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        viewController.view.alpha = 1
            }) { _ in
                self.replaceCurrentViewController(viewController)
                viewController.viewDidAppear(true)
        }
    }

    fileprivate func replaceCurrentViewController(_ viewController: UIViewController) {
        self.topViewController?.view.removeFromSuperview()
        self.topViewController?.removeFromParentViewController()
        // TODO: Reimplement this.
        //        (viewController as? PieOverlayMenuContentView)?.overlayMenu = self
        self.topViewController = viewController
        // TODO: Call this dataSourceUpdate earlier
        self.dataSourceUpdate()
        viewController.didMove(toParentViewController: self)
    }

    fileprivate func dataSourceUpdate() {
        guard let dataSource = self.dataSource else { return }

        headerLabel.text = dataSource.overlayMenuTitleForHeader(self.topViewController)
        footerLabel.text = dataSource.overlayMenuTitleForFooter(self.topViewController)
    }

    fileprivate func snapshot() -> UIImage? {
        guard let window = UIApplication.shared.keyWindow else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, window.screen.scale)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }

    // MARK: UI Setup
    fileprivate func setupViews() {
        self.view.subviews.forEach{ $0.removeFromSuperview() }
        self.backgroundImage.subviews.forEach{ $0.removeFromSuperview() }
        
        viewsDictionary = [
            "topLayoutGuide": self.topLayoutGuide,
            "headerView":headerView,
            "closeButton": closeButton,
            "headerLabel": headerLabel,
            "contentView": contentView,
            "footerView": footerView,
            "footerLabel": footerLabel
        ]

        // Set up background image
        if blurEffectStyle != nil {
            self.backgroundImage.frame = self.view.bounds
            self.backgroundImage.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.view.addSubview(backgroundImage)
        }

        self.view.addSubview(headerView)
        closeButton.addTarget(self, action: #selector(PieOverlayMenuContentViewController.close), for: UIControlEvents.touchUpInside)
        headerView.addSubview(closeButton)
        headerView.addSubview(headerLabel)

        self.view.addSubview(contentView)
        self.view.addSubview(footerView)
        footerView.addSubview(footerLabel)

        setupHeaderViewConstraints()
        setupContentAndFooterViewsConstraints()
    }

    fileprivate func setupHeaderViewConstraints() {
        [NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[closeButton]-0-|", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[closeButton]", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-0-|", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton]-32-[headerLabel]", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-[headerView(50)]", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerView]-0-|", options: [], metrics: nil, views: viewsDictionary)
            ].forEach { NSLayoutConstraint.activate($0) }
    }

    fileprivate func setupContentAndFooterViewsConstraints() {
        [NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerLabel]-0-|", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footerLabel]-0-|", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "V:[headerView]-50-[contentView]-75-[footerView]", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[contentView]-100-|", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "V:[footerView(50)]-0-|", options: [], metrics: nil, views: viewsDictionary),
         NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerView]-0-|", options: [], metrics: nil, views: viewsDictionary)
            ].forEach { NSLayoutConstraint.activate($0) }
    }

    fileprivate static func getPieOverlayMenuResourcesBundle() -> Bundle? {
        let podBundle = Bundle(for: PieOverlayMenuContentViewController.self)
        let bundle : Bundle?
        if let bundleURL = podBundle.url(forResource: "PieOverlayMenu", withExtension: "bundle") {
            bundle = Bundle(url: bundleURL)
        } else {
            bundle = podBundle
        }
        return bundle
    }
}

extension PieOverlayMenuContentViewController {
    // MARK: - Public methods -
    public func close() {
        delegate?.overlayMenuCloseButtonPressed?()
        self.pieOverlayMenu()?.closeMenu(false)
    }

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // TODO: Maybe append only if it's not in the stack already otherwise throw exception
        self.viewControllers.append(viewController)
        self.changeContentController(viewControllers.last!, animated: animated)
    }

    public func popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        if self.viewControllers.count > 1 {
            let poppedViewController = self.viewControllers.popLast()
            self.changeContentController(viewControllers.last!, animated: animated)
            return poppedViewController
        }
        return nil
    }

    public func popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        guard viewControllers.count > 1 else { return nil }
        var ret: [UIViewController] = []
        for _ in 0..<viewControllers.count-1 {
            ret.append(viewControllers.popLast()!)
        }
        self.changeContentController(viewControllers.last!, animated: animated)
        return ret
    }

    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.count > 0 {
            self.viewControllers = viewControllers
            self.changeContentController(viewControllers.last!, animated: animated)
        }
    }
}

