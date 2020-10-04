//
//  CustomizedBaseViewController.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-29.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import Jukebox
import MediaPlayer
import JSSAlertView
import PhotosUI
import Photos
import MobileCoreServices

class CustomizedBaseViewController: UIViewController, PHLivePhotoViewDelegate {
    
    // MARK: - Delete this in subclass, already exists here
    let userPreferences = NSUserDefaults.standardUserDefaults()
    var spinner: UIActivityIndicatorView?
    
//    var jukebox = Jukebox()
    
    var mediaPickerController = MPMediaPickerController(mediaTypes: .AnyAudio)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - UI Setup
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let force = touch.force.description
        debugPrint(force)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor.clearColor()
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func startActivityIndicatorView(frame: CGRect) {
        spinner = UIActivityIndicatorView(frame: frame)
        view.bringSubviewToFront(spinner!)
        spinner?.startAnimating()
    }
    
    func stopActivityIndicatorView() {
        spinner?.stopAnimating()
    }
    
    func showBasicAlertController(title: String, text: String) {
        JSSAlertView().show(self, title: title, text: text, buttonText: "OK", color: UIColor.obsidianBlackMetallicLight())
    }
    
    func showWarningAlertController(title: String, text: String) {
        let alertView = JSSAlertView().show(self, title: title, text: text, buttonText: "OK", color: UIColor.teslaMotorsGenericRed(), iconImage: UIImage(named: "Warning Sign"))
        alertView.setTextTheme(.Light)
        alertView.setTitleFont("HelveticaNeue-Light")
        alertView.setTextFont("HelveticaNeue-Light")
        alertView.setButtonFont("HelveticaNeue-Light")
    }
    
    func showNoVehicleAlertController(title: String, text: String) {
        let alertView = JSSAlertView().show(self, title: title, text: text, buttonText: "OK", color: UIColor.teslaMotorsGenericRed(), iconImage: UIImage(named: "White Model X"))
        alertView.setTextTheme(.Light)
        alertView.setTitleFont("HelveticaNeue-Light")
        alertView.setTextFont("HelveticaNeue-Light")
        alertView.setButtonFont("HelveticaNeue-Light")
    }
    
    func showMainScreenTabBarViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarVCIdentifier")
        self.showViewController(tabBarViewController, sender: self)
    }
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginVCIdentifier")
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    // Live Photos Setup (Log In & Settings views)
    
    func configureLivePhotoBackground(livePhotoName: String, livePhotoVideoFileName: String, videoExtensionName: String, livePhotoView: PHLivePhotoView, var livePhotoPreviewImage: UIImage) {
        let imageURL = NSBundle.mainBundle().URLForResource(livePhotoName, withExtension: "JPG")! as NSURL
        debugPrint(imageURL)
        let movieURL = NSBundle.mainBundle().URLForResource(livePhotoVideoFileName, withExtension: videoExtensionName)! as NSURL
        debugPrint(movieURL)
        
        if let image = UIImage(named: "\(livePhotoName).JPG") {
            livePhotoPreviewImage = image
        }
        
        makeLivePhotoFromItems(imageURL, videoURL: movieURL, previewImage: livePhotoPreviewImage, completion: { (livePhoto) -> Void in
            livePhotoView.livePhoto = livePhoto
            livePhotoView.startPlaybackWithStyle(PHLivePhotoViewPlaybackStyle.Full)
        })
    }

    func makeLivePhotoFromItems(imageURL: NSURL, videoURL: NSURL, previewImage: UIImage, completion: (livePhoto: PHLivePhoto) -> Void) {
        PHLivePhoto.requestLivePhotoWithResourceFileURLs([imageURL, videoURL], placeholderImage: previewImage, targetSize: CGSizeZero, contentMode: PHImageContentMode.AspectFit, resultHandler: {
            (livePhoto, infoDict) -> Void in
            if let lp = livePhoto {
                completion(livePhoto: lp)
            }
        })
    }
}
