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
    public static let sharedInstance = PieOverlayMenu()
    public var dataSource : PieOverlayMenuDataSource? {
        didSet {
            dataSourceUpdate()
        }
    }
    weak public var delegate : PieOverlayMenuDelegate?
    public private(set) var viewControllers: [UIViewController]
    public private(set) var topViewController: UIViewController?

    // MARK: - Private properties -
    private let headerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let closeButton : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        let image = UIImage(named: "menu_close_button", inBundle: PieOverlayMenu.getPieOverlayMenuResourcesBundle(), compatibleWithTraitCollection: nil)
        btn.setImage(image, forState: UIControlState.Normal)
        return btn
    }()
    private let headerLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFontOfSize(25)
        lbl.textColor = UIColor.whiteColor()
        return lbl
    }()
    private let contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let footerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let footerLabel : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.whiteColor()
        lbl.font = UIFont.systemFontOfSize(12)
        lbl.textAlignment = NSTextAlignment.Center
        return lbl
    }()
    private var viewsDictionary : [String:AnyObject]!

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
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides -
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.view.backgroundColor = UIColor(red: 67/255, green: 75/255, blue: 90/255, alpha: 1.0)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

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

    public func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        guard viewControllers.count > 1 else { return nil }
        var ret: [UIViewController] = []
        for _ in 0..<viewControllers.count-1 {
            ret.append(viewControllers.popLast()!)
        }
        self.changeContentController(viewControllers.last!, animated: animated)
        return ret
    }

    // MARK: - Internal methods -
    private func changeContentController(viewController: UIViewController, animated : Bool = true) {
        topViewController?.willMoveToParentViewController(nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(viewController)
        self.contentView.addSubview(viewController.view)
        let viewsDict = ["subView":viewController.view]
        [NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|", options: [], metrics: nil, views: viewsDict),
            NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|", options: [], metrics: nil, views: viewsDict)
            ].forEach { NSLayoutConstraint.activateConstraints($0) }
        if animated {
            animateChangeContentViewController(viewController)
        } else {
            self.replaceCurrentViewController(viewController)
        }
    }

    private func animateChangeContentViewController(viewController: UIViewController) {
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

    // MARK: UI Setup
    private func setupViews() {
        viewsDictionary = [
            "topLayoutGuide": self.topLayoutGuide,
            "headerView":headerView,
            "closeButton": closeButton,
            "headerLabel": headerLabel,
            "contentView": contentView,
            "footerView": footerView,
            "footerLabel": footerLabel
        ]

        self.view.addSubview(headerView)
        closeButton.addTarget(self, action: #selector(PieOverlayMenu.close), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(closeButton)
        headerView.addSubview(headerLabel)

        self.view.addSubview(contentView)
        self.view.addSubview(footerView)
        footerView.addSubview(footerLabel)

        setupHeaderViewConstraints()
        setupContentAndFooterViewsConstraints()
    }

    private func setupHeaderViewConstraints() {
        [NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[closeButton]-0-|", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-18-[closeButton]", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[headerLabel]-0-|", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("H:[closeButton]-32-[headerLabel]", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-[headerView(50)]", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[headerView]-0-|", options: [], metrics: nil, views: viewsDictionary)
            ].forEach { NSLayoutConstraint.activateConstraints($0) }
    }

    private func setupContentAndFooterViewsConstraints() {
        [NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[footerLabel]-0-|", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[footerLabel]-0-|", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("V:[headerView]-50-[contentView]-75-[footerView]", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[contentView]-100-|", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("V:[footerView(50)]-0-|", options: [], metrics: nil, views: viewsDictionary),
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[footerView]-0-|", options: [], metrics: nil, views: viewsDictionary)
            ].forEach { NSLayoutConstraint.activateConstraints($0) }
    }

    private static func getPieOverlayMenuResourcesBundle() -> NSBundle? {
        let podBundle = NSBundle(forClass: PieOverlayMenu.self)
        let bundle : NSBundle?
        if let bundleURL = podBundle.URLForResource("PieOverlayMenu", withExtension: "bundle") {
            bundle = NSBundle(URL: bundleURL)
        } else {
            bundle = podBundle
        }
        return bundle
    }
}

