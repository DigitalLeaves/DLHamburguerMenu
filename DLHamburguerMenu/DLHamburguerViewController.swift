//
//  DLHamburguerViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 4/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

/** Direction of menu appearance */
enum DLHamburguerMenuPlacement: Int {
    case left = 0, right, top, bottom
}

/** Visual style of the menu */
enum DLHamburguerMenuBackgroundStyle: Int {
    case light = 0, dark = 1
    
    func toBarStyle() -> UIBarStyle {
        return UIBarStyle(rawValue: self.rawValue)!
    }
}

// Constants
private let kDLHamburguerMenuSpan: CGFloat = 50.0

/**
 * The DLHamburguerViewController is the main VC managing the content view controller and the menu view controller.
 * These view controllers will be contained in the main container view controller.
 * The menuViewController will be shown when panning or invoking the showMenuViewController method.
 * The contentViewController will contain the application main content VC, probably a UINavigationController.
 */
class DLHamburguerViewController: UIViewController {
    // pan gesture recognizer.
    var gestureRecognizer: UIPanGestureRecognizer?
    var gestureEnabled = true
    
    // appearance
    var overlayAlpha: CGFloat = 0.3                                // % of dark fading of the background (0.0 - 1.0)
    var animationDuration: TimeInterval = 0.35                    // duration of the menu animation.
    var desiredMenuViewSize: CGSize?                                // if set, menu view size will try to adhere to these limits
    var actualMenuViewSize: CGSize = CGSize.zero                     // Actual size of the menu view
    var menuVisible = false                                         // Is the hamburguer menu currently visible?
    
    // delegate
    var delegate: DLHamburguerViewControllerDelegate?
    
    // settings
    var menuDirection: DLHamburguerMenuPlacement = .left
    var menuBackgroundStyle: DLHamburguerMenuBackgroundStyle = .dark
    
    // structure & hierarchy
    var containerViewController: DLHamburguerContainerViewController!
    fileprivate var _contentViewController: UIViewController!
    var contentViewController: UIViewController! {
        get {
            return _contentViewController
        }
        set {
            if _contentViewController == nil {
                _contentViewController = newValue
                return
            }
            // remove old links to previous hierarchy
            _contentViewController.removeFromParentViewController()
            _contentViewController.view.removeFromSuperview()
            
            // update hierarchy
            if newValue != nil {
                self.addChildViewController(newValue)
                newValue.view.frame = self.containerViewController.view.frame
                self.view.insertSubview(newValue.view, at: 0)
                newValue.didMove(toParentViewController: self)
            }
            _contentViewController = newValue
            
            // update status bar appearance
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    fileprivate var _menuViewController: UIViewController!
    var menuViewController: UIViewController! {
        get {
            return _menuViewController
        }
        set {
            // remove old links to previous hierarchy
            if _menuViewController != nil {
                _menuViewController.view.removeFromSuperview()
                _menuViewController.removeFromParentViewController()
            }
            _menuViewController = newValue
            
            // update hierarchy
            let frame = _menuViewController.view.frame
            _menuViewController.willMove(toParentViewController: nil)
            _menuViewController.removeFromParentViewController()
            _menuViewController.view.removeFromSuperview()
            _menuViewController = newValue
            if _menuViewController == nil { return }
            
            // add menu to container view hierarchy
            self.containerViewController.addChildViewController(newValue)
            newValue.view.frame = frame
            self.containerViewController?.containerView?.addSubview(newValue.view)
            newValue.didMove(toParentViewController: self)
        }
    }
    
    // MARK: - Lifecycle
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupHamburguerViewController()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupHamburguerViewController()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupHamburguerViewController()
    }
    
    convenience init(contentViewController: UIViewController, menuViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
        self.menuViewController = menuViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hamburguerDisplayController(contentViewController, inFrame: self.view.bounds)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - VC management
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return self.contentViewController
    }
    
    override var childViewControllerForStatusBarHidden : UIViewController? {
        return self.contentViewController
    }
    
    // MARK: - Setup DLHamburguerViewController
    
    internal func setupHamburguerViewController() {
        // initialize container view controller
        containerViewController = DLHamburguerContainerViewController()
        containerViewController.hamburguerViewController = self
        
        // initialize gesture recognizer
        gestureRecognizer = UIPanGestureRecognizer(target: containerViewController!, action: #selector(DLHamburguerViewController.panGestureRecognized(_:)))
        
    }
    
    // MARK: - Presenting and managing menu.
    /** Main function for presenting the menu */
    func showMenuViewController() { self.showMenuViewControllerAnimated(true, completion: nil) }
    
    /** Detailed function for presenting the menu, with options */
    func showMenuViewControllerAnimated(_ animated: Bool, completion:  (() -> Void)? = nil) {
        // inform that the menu will show
        delegate?.hamburguerViewController?(self, willShowMenuViewController: self.menuViewController)
        
        self.containerViewController.shouldAnimatePresentation = animated
        // calculate menu size
        adjustMenuSize()
        
        // present menu controller
        self.hamburguerDisplayController(self.containerViewController, inFrame: self.contentViewController.view.frame)
        self.menuVisible = true
        
        // call completion handler.
        completion?()
    }
    
    func adjustMenuSize(_ forRotation: Bool = false) {
        var w: CGFloat = 0.0
        var h: CGFloat = 0.0
        
        if desiredMenuViewSize != nil { // Try to adjust to desired values
            w = desiredMenuViewSize!.width > 0 ? desiredMenuViewSize!.width : contentViewController.view.frame.size.width
            h = desiredMenuViewSize!.height > 0 ? desiredMenuViewSize!.height : contentViewController.view.frame.size.height
        } else { // Calculate menu size based on direction.
            var span: CGFloat = 0.0
            if self.menuDirection == .left || self.menuDirection == .right {
                span = kDLHamburguerMenuSpan
            }
            if forRotation { w = self.contentViewController.view.frame.size.height - span; h = self.contentViewController.view.frame.size.width }
            else { w = self.contentViewController.view.frame.size.width - span; h = self.contentViewController.view.frame.size.height }

        }
        self.actualMenuViewSize = CGSize(width: w, height: h)
        
    }

    /** Hides the menu controller */
    func hideMenuViewControllerWithCompletion(_ completion: (() -> Void)?) {
        if !self.menuVisible { completion?(); return }
        self.containerViewController.hideWithCompletion {
            completion!()
        }
    }

    func resizeMenuViewControllerToSize(_ size: CGSize) {
        self.containerViewController.resizeToSize(size)
    }
    
    // MARK: - Gesture recognizer
    
    @objc func panGestureRecognized (_ recognizer: UIPanGestureRecognizer) {
        self.delegate?.hamburguerViewController?(self, didPerformPanGesture: recognizer)
        if self.gestureEnabled {
            if recognizer.state == .began && shouldStartShowingMenu(recognizer) { self.showMenuViewControllerAnimated(true, completion: nil) }
            self.containerViewController.panGestureRecognized(recognizer)
        }
    }
    
    func shouldStartShowingMenu(_ recognizer: UIPanGestureRecognizer) -> Bool {
        switch self.menuDirection {
        case .bottom:
            return recognizer.velocity(in: self.containerViewController.view).y < 0
        case .left:
            return recognizer.velocity(in: self.containerViewController.view).x > 0
        case .top:
            return recognizer.velocity(in: self.containerViewController.view).y > 0
        case .right:
            return recognizer.velocity(in: self.containerViewController.view).x < 0
        }
    }
    
    // MARK: - Rotation legacy support (iOS 7)
    
    override var shouldAutorotate : Bool { return self.contentViewController.shouldAutorotate }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // call super and inform delegate
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)
        self.delegate?.hamburguerViewController?(self, willAnimateRotationToInterfaceOrientation: toInterfaceOrientation, duration: duration)
        // adjust size of menu if visible only.
        self.containerViewController.setContainerFrame(self.menuViewController.view.frame)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        if !self.menuVisible { self.actualMenuViewSize = CGSize.zero }
        adjustMenuSize(true)
    }
    
    // MARK: - Rotation (iOS 8)
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // call super and inform delegate
        if #available(iOS 8.0, *) {
            super.viewWillTransition(to: size, with: coordinator)
        } else {
            // Fallback on earlier versions
        }
        delegate?.hamburguerViewController?(self, willTransitionToSize: size, withTransitionCoordinator: coordinator)
        // adjust menu size if visible
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.containerViewController.setContainerFrame(self.menuViewController.view.frame)
        }, completion: {(finalContext) -> Void in
            if !self.menuVisible { self.actualMenuViewSize = CGSize.zero }
            self.adjustMenuSize(true)
        })
    }

}


/** Extension for presenting and hiding view controllers from the Hamburguer container. */
extension UIViewController {
    func hamburguerDisplayController(_ controller: UIViewController, inFrame frame: CGRect) {
        self.addChildViewController(controller)
        controller.view.frame = frame
        self.view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func hamburguerHideController(_ controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    func findHamburguerViewController() -> DLHamburguerViewController? {
        var vc = self.parent
        while vc != nil {
            if let dlhvc = vc as? DLHamburguerViewController { return dlhvc }
            else if vc != nil && vc?.parent != vc { vc = vc!.parent }
            else { vc = nil }
        }
        return nil
    }
}

@objc protocol DLHamburguerViewControllerDelegate {
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, didPerformPanGesture gestureRecognizer: UIPanGestureRecognizer)
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, willShowMenuViewController menuViewController: UIViewController)
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, didShowMenuViewController menuViewController: UIViewController)
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, willHideMenuViewController menuViewController: UIViewController)
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, didHideMenuViewController menuViewController: UIViewController)
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, willTransitionToSize size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    // Support for legacy iOS 7 rotation.
    @objc optional func hamburguerViewController(_ hamburguerViewController: DLHamburguerViewController, willAnimateRotationToInterfaceOrientation toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval)
}
