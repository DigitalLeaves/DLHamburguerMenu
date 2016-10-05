//
//  DLHamburguerContainerViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 4/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kDLHamburguerInitialContainerViewWidth: CGFloat = 250

/**
 * This class contains the container view for the hamburguer main elements: the menu and the content.
 */
class DLHamburguerContainerViewController: UIViewController {
    // structure
    weak var hamburguerViewController: DLHamburguerViewController!      // root hamburguer view controller
    var containerView: UIView!                                          // view containing the main content
    var containerOrigin = CGPoint.zero                                   // origin of container view
    var shouldAnimatePresentation = false                               // true if menu presentation should be animated.
    var backgroundFadingView: UIView!                                   // background view that fades content when menu shows up
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // prepare background fading view
        backgroundFadingView = UIView(frame: CGRect.null)
        backgroundFadingView.backgroundColor = UIColor.black
        backgroundFadingView.alpha = 0.0
        self.view.addSubview(backgroundFadingView)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DLHamburguerContainerViewController.tapGestureRecognized(_:)))
        backgroundFadingView.addGestureRecognizer(gestureRecognizer)

        // prepare container view
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: kDLHamburguerInitialContainerViewWidth, height: view.frame.size.height))
        containerView.clipsToBounds = true
        self.view.addSubview(containerView)
        
        // We need to set a toolbar so the menu controller's content won't overlap the topbar.
        let toolbar = UIToolbar(frame: self.view.bounds)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolbar.barStyle = self.hamburguerViewController.menuBackgroundStyle.toBarStyle()
        self.containerView.addSubview(toolbar)
        
        // add menu view controller
        if self.hamburguerViewController.menuViewController != nil {
            self.addChildViewController(self.hamburguerViewController.menuViewController)
            self.hamburguerViewController.menuViewController.view.frame = self.containerView.bounds
            self.containerView.addSubview(self.hamburguerViewController.menuViewController.view)
            self.hamburguerViewController.menuViewController.didMove(toParentViewController: self)
        }

        self.view.addGestureRecognizer(self.hamburguerViewController.gestureRecognizer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hamburguerViewController.menuVisible {
            hamburguerViewController.menuViewController.view.frame = containerView.bounds
            switch (hamburguerViewController.menuDirection) {
            case .left:
                self.setContainerFrame(CGRect(x: -self.hamburguerViewController.actualMenuViewSize.width, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height))
            case .right:
                self.setContainerFrame(CGRect(x: self.view.frame.size.width, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height))
            case .top:
                self.setContainerFrame(CGRect(x: 0, y: -self.hamburguerViewController.actualMenuViewSize.height, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height))
            case .bottom:
                self.setContainerFrame(CGRect(x: 0, y: self.view.frame.size.height, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height))
            }
        }
        // If we should animate the presentation, show it now.
        if self.shouldAnimatePresentation { self.show() }
    }
    
    
    // MARK: - Frame, appearance and size adjustments
    
    func setContainerFrame(_ frame: CGRect) {
        var x:CGFloat = 0
        var y:CGFloat = 0
        var w:CGFloat = 0
        var h:CGFloat = 0

        // calculate overlay alpha background view frame
        switch (hamburguerViewController.menuDirection) {
        case .left:
            x = frame.origin.x + frame.size.width
            y = 0
            w = self.view.frame.width - frame.size.width - frame.origin.x
            h = self.view.frame.size.height
        case .right:
            x = 0
            y = 0
            w = frame.origin.x
            h = self.view.frame.size.height
        case .top:
            x = frame.origin.x
            y = frame.origin.y + frame.size.height
            w = frame.size.width
            h = self.view.frame.size.height
        case .bottom:
            x = frame.origin.x
            y = 0
            w = frame.size.width
            h = frame.origin.y
        }

        // assign overlay and container view
        let shadowFrame = CGRect(x: x, y: y, width: w, height: h)
        self.backgroundFadingView.frame = shadowFrame
        self.containerView.frame = frame
    }
    
    func resizeToSize(_ size: CGSize) {
        var newFrame = CGRect.zero
        // adjust size depending on menu direction.
        switch (self.hamburguerViewController.menuDirection) {
        case .left:
            newFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        case .right:
            newFrame = CGRect(x: self.view.frame.size.width - size.width, y: 0, width: size.width, height: size.height)
        case .top:
            newFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        case .bottom:
            newFrame = CGRect(x: 0, y: self.view.frame.size.height - size.height, width: size.width, height: size.height)
        }
        
        // animated resizing.
        UIView.animate(withDuration: self.hamburguerViewController.animationDuration, animations: { () -> Void in
            self.setContainerFrame(newFrame)
            self.backgroundFadingView.alpha = self.hamburguerViewController.overlayAlpha
        })
    }
    
    // MARK: - Show and Hide the menu.

    /** Shows the menu. */
    func show() {
        // calculate the final frame for the menu
        var finalFrame = CGRect.zero
        switch (self.hamburguerViewController.menuDirection) {
        case .left:
            finalFrame = CGRect(x: 0, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .right:
            finalFrame = CGRect(x: self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .top:
            finalFrame = CGRect(x: 0, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .bottom:
            finalFrame = CGRect(x: 0, y: self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        }
        
        // set final frame animated
        UIView.animate(withDuration: self.hamburguerViewController.animationDuration, animations: { () -> Void in
            self.setContainerFrame(finalFrame)
            self.backgroundFadingView.alpha = self.hamburguerViewController.overlayAlpha
        }, completion: { (success) -> Void in
            // inform the delegate.
            if self.hamburguerViewController.delegate != nil {
                self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, didShowMenuViewController: self.hamburguerViewController.menuViewController)
            }
        }) 
    }
    
    /** Hides the menu. */
    func hide() {
        hideWithCompletion(nil)
    }
    
    /** Hides the menu with a completion closure. */
    func hideWithCompletion(_ completion: ((Void) -> Void)?) {
        // inform the delegate that the menu will hide
        self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, willHideMenuViewController: self.hamburguerViewController.menuViewController)
        
        // calculate new frame depending on menu direction
        var newFrame = CGRect.zero
        switch (hamburguerViewController.menuDirection) {
        case .left:
            newFrame = CGRect(x: -self.hamburguerViewController.actualMenuViewSize.width, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .right:
            newFrame = CGRect(x: self.view.frame.size.width, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .top:
            newFrame = CGRect(x: 0, y: -self.hamburguerViewController.actualMenuViewSize.height, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .bottom:
            newFrame = CGRect(x: 0, y: self.view.frame.size.height, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        }
        
        // animate hiding.
        UIView.animate(withDuration: self.hamburguerViewController.animationDuration, animations: { () -> Void in
            self.setContainerFrame(newFrame)
            self.backgroundFadingView.alpha = 0
        }, completion: { (success) -> Void in
            self.hamburguerViewController.menuVisible = false
            self.hamburguerViewController.hamburguerHideController(self)
            self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, didHideMenuViewController: self.hamburguerViewController.menuViewController)
            completion?()
        }) 
    }
    
    // MARK: - Gesture recognizer
    // TAP: hide the menu
    func tapGestureRecognized(_ recognizer: UITapGestureRecognizer) {
        self.hide()
    }
    
    // PAN: animate menu appearance/dissapearace with the menu.
    func panGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        // inform the delegate
        self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, didPerformPanGesture: recognizer)
        // is the gesture recognizer enabled?
        if !self.hamburguerViewController.gestureEnabled { return }
        
        // React to recognizer
        let point = recognizer.translation(in: self.view)
        
        // start: set initial container origin
        if recognizer.state == .began {
            self.containerOrigin = self.containerView.frame.origin
        }
        // changed: adjust frame
        else if recognizer.state == .changed {
            var frame = self.containerView.frame
            
            switch (hamburguerViewController.menuDirection) {
            case .left:
                frame.origin.x = self.containerOrigin.x + point.x
                if frame.origin.x > 0 {
                    frame.origin.x = 0
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.size.width = self.hamburguerViewController.actualMenuViewSize.width + self.containerOrigin.x + point.x
                        if frame.size.width > self.view.frame.size.width { frame.size.width = self.view.frame.size.width }
                    }
                }
            case .right:
                frame.origin.x = self.containerOrigin.x + point.x
                if frame.origin.x < self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width {
                    frame.origin.x = self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.origin.x = self.containerOrigin.x + point.x
                        if frame.origin.x < 0 { frame.origin.x = 0 }
                        frame.size.width = self.view.frame.size.width - frame.origin.x
                    }
                }
            case .top:
                frame.origin.y = self.containerOrigin.y + point.y
                if frame.origin.y > 0 {
                    frame.origin.y = 0
                    
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.size.height = self.hamburguerViewController.actualMenuViewSize.height + self.containerOrigin.y + point.y
                        if frame.size.height > self.view.frame.size.height { frame.size.height = self.view.frame.size.height }
                    }
                }
            case .bottom:
                frame.origin.y = self.containerOrigin.y + point.y
                if frame.origin.y < self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height {
                    frame.origin.y = self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height
                    
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.origin.y = self.containerOrigin.y + point.y
                        if frame.origin.y < 0 { frame.origin.y = 0 }
                        frame.size.height = self.view.frame.size.height - frame.origin.y
                    }
                }
            }
            self.setContainerFrame(frame)
        }
        
        // end: decide whether to open or close the menu based on the position
        else if recognizer.state == .ended {
            switch (hamburguerViewController.menuDirection) {
            case .left:
                if recognizer.velocity(in: self.view).x < 0 { self.hide() }
                else { self.show() }
            case .right:
                if recognizer.velocity(in: self.view).x < 0 { self.show() }
                else { self.hide() }
            case .top:
                if recognizer.velocity(in: self.view).y < 0 { self.hide() }
                else { self.show() }
            case .bottom:
                if recognizer.velocity(in: self.view).y < 0 { self.show() }
                else { self.hide() }
            }
        }
    }
    
    // MARK: - Rotation and transition reacting.
    
    func fixLayoutWithDuration(_ duration: TimeInterval) {
        var newFrame = CGRect.zero
        switch (hamburguerViewController.menuDirection) {
        case .left:
            newFrame = CGRect(x: 0, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .right:
            newFrame = CGRect(x: self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .top:
            newFrame = CGRect(x: 0, y: 0, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        case .bottom:
            newFrame = CGRect(x: 0, y: self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height, width: self.hamburguerViewController.actualMenuViewSize.width, height: self.hamburguerViewController.actualMenuViewSize.height)
        }
        self.setContainerFrame(newFrame)
        backgroundFadingView.alpha = hamburguerViewController.overlayAlpha
    }
    
    // iOS7 Rotation legacy support.
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)
        self.fixLayoutWithDuration(duration)
    }
    
    // iOS 8 Transition.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if #available(iOS 8.0, *) {
            super.viewWillTransition(to: size, with: coordinator)
        } else {
            // Fallback on earlier versions
        }
        self.fixLayoutWithDuration(coordinator.transitionDuration)
    }
    
    
}









