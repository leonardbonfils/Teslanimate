//
//  SettingsViewController.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-27.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import Alamofire
import IBAnimatable
import Photos
import PhotosUI
import MobileCoreServices
import CoreMotion
import IBAnimatable
import Instructions

class SettingsViewController: CustomizedBaseViewController, CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    @IBOutlet var settingsView: AnimatableView!
    @IBOutlet weak var darkeningView: UIView!
    @IBOutlet weak var testLivePhotoView: PHLivePhotoView!
    @IBOutlet weak var settingBoxesCanvas: UIView!
    var livePhotoPreviewImage = UIImage()
//    @IBOutlet weak var whiteModelXImageView: AnimatableImageView!
    @IBOutlet weak var forceTouchValue: UILabel!
    @IBOutlet weak var signOutButton: AnimatableButton!
    
    @IBOutlet weak var deepPressableButton: DeepPressableButton!
    @IBOutlet weak var deepPressableImageView: AnimatableImageView!
    
    let coachMarksController = CoachMarksController()
    
//    var box : UIView?
    var animator: UIDynamicAnimator? = nil
    let gravity = UIGravityBehavior()
    let collider = UICollisionBehavior()
    var maxX : CGFloat = 320
    var maxY : CGFloat = 320
    let boxSize : CGFloat = 90.0
//    var boxes = [SettingsTile]()
//    var boxes = [UIView]()
    var boxes = [SettingsTile]()
    
//    let tapSelector: Selector = "tileWasTapped"

    let motionQueue = NSOperationQueue()
    let motionManager = CMMotionManager()
    
    // MARK: - Standard view functions
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // If view is being loaded after sign out and signing back in, show the 'Select Song' view (tabBar index 0)
        if SystemVariables.systemPreferences.boolForKey("tabBarControllerLoadedAfterSignout") == true {
            self.tabBarController?.selectedIndex = 0
        }
        if self.deepPressableButton.hidden == true {
            self.coachMarksController.stop()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        motionManager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: gravityUpdated)
        self.becomeFirstResponder()
        
        self.coachMarksController.startOn(self)
        
//        let launchedBefore = SystemVariables.systemPreferences.boolForKey("moreViewLaunchedBefore")
//        if launchedBefore {
//            self.coachMarksController.stop()
//            debugPrint("Not the first launch")
//        } else {
//            self.coachMarksController.startOn(self)
//            SystemVariables.systemPreferences.setBool(true, forKey: "moreViewLaunchedBefore")
//        }
        
//        if self.deepPressableButton.hidden {
//            
//        } else {
//            self.coachMarksController.startOn(self)
//        }
        
        /**
        switch self.deepPressableImageView.hidden {
        case false:
            self.coachMarksController.startOn(self)
        default:
            break
        } */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maxX = settingBoxesCanvas.bounds.size.width - boxSize
        maxY = settingBoxesCanvas.bounds.size.height - boxSize
        createAnimatorStuff()
        generateBoxes()
        configureView()
        
        self.coachMarksController.delegate = self
        self.coachMarksController.dataSource = self
        self.coachMarksController.overlayBackgroundColor = UIVariables.coachMarksOverlayBackgroundColor
        self.coachMarksController.allowOverlayTap = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        motionManager.stopDeviceMotionUpdates()
        self.coachMarksController.stop()
    }
    
    // View setup + Animations
    
    override func configureView() {
        super.configureView()
        
        configureLivePhotoBackground("Tesla Live Photo 2", livePhotoVideoFileName: "Tesla Live Photo 2 - Short", videoExtensionName: "mov", livePhotoView: testLivePhotoView, livePhotoPreviewImage: livePhotoPreviewImage)
        darkeningView.backgroundColor = UIVariables.darkeningViewBackgroundColor
//        UIVariables.applyCustomAnimationToImageView(whiteModelXImageView, animationType: "SlideInLeft", duration: 1.0, delay: 0.0, damping: 0.5, velocity: 1.0, force: 1.0)
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("animate3DTouchButtonOutro"))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGestureRecognizer)
        let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: self, action: #selector(self.animate3DTouchButtonOutro), threshold: 0.99)
        self.deepPressableButton.addGestureRecognizer(deepPressGestureRecognizer)
        self.deepPressableButton.setDeepPressAction(self, action: #selector(self.animate3DTouchButtonOutro))
    }
    
    func animate3DTouchButtonOutro() {
        UIVariables.applyCustomAnimationToButton(self.deepPressableButton, animationType: "SlideOutLeft", duration: 1.0, delay: 0.0, damping: 0.5, velocity: 1.0, force: 1.0)
        UIVariables.applyCustomAnimationToImageView(self.deepPressableImageView, animationType: "SlideOutLeft", duration: 1.0, delay: 0.0, damping: 0.5, velocity: 1.0, force: 1.0)
        self.deepPressableButton.hidden = true
        self.deepPressableImageView.hidden = true
        self.coachMarksController.stop()
        revealBoxes()
    }
    
    // MARK: - Boxes setup + Core Motion setup
    
    func randomColor(i: Int) -> UIColor {
//        let red = CGFloat(CGFloat(arc4random()%100000)/100000)
//        let green = CGFloat(CGFloat(arc4random()%100000)/100000)
//        let blue = CGFloat(CGFloat(arc4random()%100000)/100000)
        
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        let color = UIVariables.settingsTileColors[i]
        
        return color
    }
    
    func doesNotCollide(testRect: CGRect) -> Bool {
        for box : UILabel in boxes {
            var viewRect = box.frame
            if(CGRectIntersectsRect(testRect, viewRect)) {
                return false
            }
        }
        return true
    }
    
    func randomFrame() -> CGRect {
        var guess = CGRectMake(9, 9, 9, 9)
        
        repeat {
            let guessX = CGFloat(arc4random()) % maxX
            let guessY = CGFloat(arc4random()) % maxY
            guess = CGRectMake(guessX, guessY, boxSize, boxSize)
        } while(!doesNotCollide(guess))
        
        return guess
    }
    
    func addBox(i: Int, location: CGRect, color: UIColor) -> UIView {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: tapSelector)
//        tapGestureRecognizer.numberOfTapsRequired = 1
        
//        let newBox = UIView(frame: location)
//        let newBox = UILabel(frame: location)
        let newBox = SettingsTile(frame: location)
//        newBox.layer.cornerRadius = newBox.frame.size.height / 2
//        newBox.clipsToBounds = true
        newBox.text = UIVariables.settingsTileNames[i]
//        newBox.textColor = UIColor.whiteColor()
//        newBox.textAlignment = .Center
//        newBox.adjustsFontSizeToFitWidth = true
//        newBox.font = UIFont(name: UIVariables.helveticaNeueBaseFontName + "Light", size: 15.0)
//        newBox.userInteractionEnabled = true
//        let newBox = SettingsTile(frame: location)
//        newBox.settingName.text = "Example"
        newBox.backgroundColor = color
        
//        newBox.addGestureRecognizer(tapGestureRecognizer)
        
        newBox.hidden = true
        settingBoxesCanvas.addSubview(newBox)
        addBoxToBehaviours(newBox)
        boxes.append(newBox)
//        boxes.append(newBox)
        return newBox
//        settingBoxesCanvas.insertSubview(newBox, atIndex: 0) // On top of Live Photo view and Darkening view.
    }
    
    func generateBoxes() {
        for i in 0...5 {
            var frame = randomFrame()
            var color = randomColor(i)
            var newBox = addBox(i, location: frame, color: color)
        }
        self.coachMarksController.stop()
    }
    
    func revealBoxes() {
        for box in boxes {
            box.hidden = false
        }
        for subview in settingBoxesCanvas.subviews {
            subview.hidden = false
        }
        self.coachMarksController.stop()
    }
    
    func createAnimatorStuff() {
        animator = UIDynamicAnimator(referenceView: self.settingBoxesCanvas)
        
//        gravity.addItem(box!)
        gravity.gravityDirection = CGVectorMake(0, UIVariables.gravity)
        animator?.addBehavior(gravity)
        
//        collider.addItem(box!)
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
    }
    
    func addBoxToBehaviours(box: UIView) {
        gravity.addItem(box)
        collider.addItem(box)
    }
    
    func gravityUpdated(motion: CMDeviceMotion?, error: NSError?) {
        let grav : CMAcceleration = motion!.gravity
        let x = CGFloat(grav.x)
        let y = CGFloat(grav.y)
        var p = CGPointMake(x, y)
        
        var orientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch orientation {
        case UIInterfaceOrientation.LandscapeLeft:
            var t = p.x
            p.x = 0 - p.y
            p.y = t
        case UIInterfaceOrientation.LandscapeRight:
            var t = p.x
            p.x = p.y
            p.y = 0 - t
        case UIInterfaceOrientation.PortraitUpsideDown:
            p.x *= -1
            p.y *= -1
        default:
            break
        }
        
        var v = CGVectorMake(p.x, 0 - p.y)
        gravity.gravityDirection = v
    }
    
    // MARK: - Touch functions
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let force = touch.force.description
        debugPrint(force)
    }
    
    // MARK: - Instructions setup
    
    func numberOfCoachMarksForCoachMarksController(coachMarksController: CoachMarksController) -> Int {
        switch self.deepPressableImageView.hidden {
        case false:
            return 1
        default:
            return 0
        }
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex index: Int) -> CoachMark {
        return coachMarksController.coachMarkForView(self.deepPressableImageView, bezierPathBlock: { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(ovalInRect: CGRectInset(frame, -2, -2))
        })
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkWillLoadForIndex index: Int) -> Bool {
        if self.deepPressableButton.hidden {
            return false
        }
        switch self.deepPressableImageView.hidden {
        case false:
            return true
        default:
            return false
        }
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation, hintText: "Psst! 3D Touch the red shape for secret options!", nextText: "OK")
        
        coachViews.bodyView.hintLabel.text = "3D Touch me for secret options!"
        coachViews.bodyView.nextLabel.text = "OK"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    // MARK: - IBAction Outlets
    
    @IBAction func signOutFromTMServers(sender: AnyObject) {
        SystemVariables.clearCache()
        SystemVariables.setTabBarIndexBoolean(true)
        self.showLoginViewController()
    }
}