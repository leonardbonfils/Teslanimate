//
//  Extensions.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-29.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import IBAnimatable
import JSSAlertView
import SwiftyJSON
import ObjectMapper

// MARK: "View Controller"-level typealiases (UI layer)

typealias VCLevelLoginCompletion = (success: Bool) -> ()

// MARK: "Global" structs

struct NetworkingVariables {
    // Tesla Motors API - Model S/X interaction
    static var loginURL = "https://owner-api.teslamotors.com/oauth/token" // "Get An Access Token" endpoint (Login action)
    static var baseURL = "https://owner-api.teslamotors.com/api/1/vehicles" // Base URL for everything except the "Get An Access Token" endpoint.
    static var baseFlashLightsURL = "https://owner-api.teslamotors.com/api/1/vehicles/"
    
    static var grantType = "password"
    static var clientID = "e4a9949fcfa04068f59abb5a658f2bac0a3428e4652315490b659d5ab3f35a9e"
    static var clientSecret = "c75f14bbadc8bee3a7594412c31416f8300256d7668ea7e6e7f06727bfb9d220"
    
    static var initialLoginParameters = [
        "grant_type": NetworkingVariables.grantType,
        "client_id": NetworkingVariables.clientID,
        "client_secret": NetworkingVariables.clientSecret,
        "email": "",
        "password": ""
    ]
    
    static var authorizationHeader = [
        "Authorization": ""
    ]
    
    // Sonic API - Audio analysis
    
    static var sonicAPIAccessIDLabel = "default"
    static var sonicAPIAccessIDValue = "db7b4aff-1f23-49e8-8933-bdcd63e10e87"
    static var sonicAPIBlocking = true
    static var sonicAPIFormat = "json"
    
//    static var initialSonicParameters = [
//        "access_id": NetworkingVariables.sonicAPIAccessIDValue,
//        "input_file": "",
//        "blocking": NetworkingVariables.sonicAPIBlocking,
//        "format": NetworkingVariables.sonicAPIFormat
//    ]
    
    // Valid Email Check function
    
    static func inputLoginParametersAreValid(emailAddress: String, password: String) -> (Bool) {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let validEmailAddress = emailTest.evaluateWithObject(emailAddress)
        
        if (validEmailAddress == true && emailAddress != "" && password != "") {
            return true
        } else {
            return false
        }
    }
    
    
    // TODO: Really messy function.. should be way more efficient. Make it so that clickMarks parsing works perfectly inside TempoAnalysis parsing.
    static func openAnalyzeTempoJSONFile(fileName: String) -> ([ClickMark]?, [Float]?) {
        var mappedClickMarks = [ClickMark]()
        var downbeatsTimePositions = [Float]()
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                /** if let json = JSON(data: data).dictionaryObject {
                    let tempoAnalysis = Mapper<TempoAnalysisJSONResponse>().map(json)
                } */
                if let clickMarks = JSON(data: data)["auftakt_result"]["click_marks"].arrayObject as? [[String:AnyObject]] {
                    for clickmark in clickMarks {
                        let mappedCM = Mapper<ClickMark>().map(clickmark)
                        if let unwrappedMappedCM = mappedCM {
                            if unwrappedMappedCM.downbeat == "true" {
                                downbeatsTimePositions.append(unwrappedMappedCM.clickMarkTimePosition!)
                            }
                            mappedClickMarks.append(unwrappedMappedCM)
                        }
                    }
                    return (mappedClickMarks, downbeatsTimePositions)
                }
                //
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            } catch {
                debugPrint("Some weird error was caught")
            }
        } else {
            debugPrint("Invalid filename/path")
        }
        // Generic return statement
        return ([ClickMark](), [Float]())
    }
    
    
    
    static func openAnalyzeMelodyJSONFile(fileName: String) -> ([Notes]?, [Float]?, [Float]?) {
        var mappedNotes = [Notes]()
        var durations = [Float]()
        var volumes = [Float]()
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                if let notes = JSON(data: data)["melody_result"]["notes"].arrayObject as? [[String:AnyObject]] {
                    for note in notes {
                        let mappedNote = Mapper<Notes>().map(note)
                        if let unwrappedMappedNote = mappedNote {
                            if let duration = unwrappedMappedNote.duration, volume = unwrappedMappedNote.volume {
                                durations.append(duration)
                                volumes.append(volume)
                            }
                            mappedNotes.append(unwrappedMappedNote)
                        }
                    }
                    return (mappedNotes, durations, volumes)
                }
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            } catch {
                debugPrint("Some weird error was caught")
            }
        } else {
            debugPrint("Invalid filename/path")
        }
        return([Notes](), [Float](), [Float]())
    }
}

struct UIVariables {
    
    enum SongAction {
        case SelectSong
        case TestSong
    }
    
    static let keyboardAppearance = UIKeyboardAppearance.Dark
    static let textFieldPlaceholderColor = UIColor.whiteColor()
    static let textFieldForegroundColor = UIColor.clearColor()
    static let loginViewBorderColor = UIColor.clearColor().CGColor
    static let highlightedButtonTitleTextColor = UIColor.whiteColor()
    static let darkeningViewBackgroundColor = UIColor(white: 0, alpha: 0.8)
    static let selectASongViewBorderColor = UIColor.whiteColor().CGColor
    
    static let loginButtonNormalTextColor = UIColor.whiteColor()
    static let alternateLoginButtonTextColor = UIColor.blackColor()
    static let alternateLoginButtonBackgroundColor = UIColor.whiteColor()
    
    static let failedLoginAnimationType = "Shake"
    static let selectSongButtonIntroAnimationType = "FadeInDown"
    static let testSongButtonIntroAnimationType = "FadeInUp"
    static let testSongButtonOutroAnimationType = "MoveBy"
    static let playButtonIntroAnimationType = "SlideInLeft"
    static let stopButtonIntroAnimationType = "SlideInRight"
    static let songInfoLabelsIntroAnimationType = "FadeInUp"
    static let playbackStatusUpdateIntroAnimationType = "FadeIn"
    static let playbackStatusUpdateOutroAnimationType = "FadeOut"
    
    static let selectAnotherSongButtonText = "Select Other Song"
    
    static let settingTileBorderColor = UIColor.whiteColor().CGColor
    static let settingsTileBorderWidth: CGFloat = 1.0
    static let gravity: CGFloat = 10.0
    static let settingsTileColors = [UIColor.iOSRed(), UIColor.iOSOrange(), UIColor.lightBrown(), UIColor.midnightSilverDark(), UIColor.deepBlueMetallic(), UIColor.iOSLightBlue()]
    static let helveticaNeueBaseFontName = "HelveticaNeue-"
    static let settingsTileNames = ["Unlock Car", "Flash Lights", "Honk Horn", "HVAC", "Remote Start", "Open Roof"]
    
    static let coachMarksOverlayBackgroundColor = UIColor(red: 0.886275, green: 0.886275, blue: 0.886275, alpha: 0.2)
    
    static let volumeChartBackgroundColor = UIColor.clearColor()
    static let volumeChartAnimationDuration = 2.0
    
    static let viewTransitionDurationTime = 0.5
    static let imageTransitionType = UIViewAnimationOptions.TransitionCrossDissolve
    
    static let testSongTitle = "Half the Man"
    static let testSongAuthor = "Methodic Doubt Music"
    static let analyzeTempoTestJSON = "Half The Man - AT"
    static let analyzeMelodyTestJSON = "Half The Man - AM"
    
    static func applyCustomAnimation(view: AnimatableView, animationType: String, duration: Double, delay: Double, damping: CGFloat, velocity: CGFloat, force: CGFloat, x: CGFloat?=nil, y: CGFloat?=nil) {
        view.animationType = animationType
        view.duration = duration
        view.delay = delay
        view.damping = damping
        view.velocity = velocity
        view.force = force
        
        if let xDisplacement = x, let yDisplacement = y {
            view.x = xDisplacement
            view.y = yDisplacement
        }
        
        view.animate()
    }
    
    static func applyCustomAnimationToLabels(labels: [AnimatableLabel], animationTypes: [String], duration: Double, delay: Double, damping: CGFloat, velocity: CGFloat, force: CGFloat) {
        var index = 0
        for label in labels {
            label.animationType = animationTypes[index]
            label.duration = duration
            label.delay = delay
            label.damping = damping
            label.velocity = velocity
            label.force = force
            
            label.animate()
            
            index += 1
        }
    }
    
    static func applyCustomAnimationToImageView(imageView: AnimatableImageView, animationType: String, duration: Double, delay: Double, damping: CGFloat, velocity: CGFloat, force: CGFloat) {
        imageView.animationType = animationType
        imageView.duration = duration
        imageView.delay = delay
        imageView.damping = damping
        imageView.velocity = velocity
        imageView.force = force
        
        imageView.animate()
    }
    
    static func applyCustomAnimationToButton(button: AnimatableButton, animationType: String, duration: Double, delay: Double, damping: CGFloat, velocity: CGFloat, force: CGFloat) {
        button.animationType = animationType
        button.duration = duration
        button.delay = delay
        button.damping = damping
        button.velocity = velocity
        button.force = force
        
        button.animate()
    }
    
    static func applyCustomAnimationTo3DButton(button: DeepPressableButton, animationType: String, duration: Double, delay: Double, damping: CGFloat, velocity: CGFloat, force: CGFloat) {
        button.animationType = animationType
        button.duration = duration
        button.delay = delay
        button.damping = damping
        button.velocity = velocity
        button.force = force
        
        button.animate()
    }
    
    // Image Functions
    
    static func configureImageView(imageView: AnimatableImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIVariables.selectASongViewBorderColor
        imageView.clipsToBounds = true
    }
    
    static func changeImage(imageView: AnimatableImageView, newImageName: String) {
        imageView.image = UIImage(named: newImageName)
    }
    
    static func changeImageWithAnimation(imageView: AnimatableImageView, duration: NSTimeInterval, transitionOptions: UIViewAnimationOptions, newImageName: String) {
        let newImage = UIImage(named: newImageName)
        UIView.transitionWithView(imageView, duration: duration, options: transitionOptions, animations: { imageView.image = newImage }, completion: nil)
    }
    
    // Label Functions
    
    static func unhideAndConfigureLabels(labelArray: [AnimatableLabel], labelTexts: [String]) { // NOT USED
        var index = 0
        for label in labelArray {
            label.hidden = false
            label.text = labelTexts[index]
            index += 1
        }
    }
    
}

struct SystemVariables {
    static let systemPreferences = NSUserDefaults.standardUserDefaults()
    static let debuggingSeparator = "------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    static func updateSystemPreferences(userEmail: String, userPassword: String?, teslaMotorsAuthToken: String, userIsLoggedIn: Bool) {
        SystemVariables.systemPreferences.setObject(userEmail, forKey: "userEmail")
        if let password = userPassword {
            SystemVariables.systemPreferences.setObject(password, forKey: "userPassword")
        }
        SystemVariables.systemPreferences.setObject(teslaMotorsAuthToken, forKey: "teslaMotorsAuthToken")
        SystemVariables.systemPreferences.setBool(userIsLoggedIn, forKey: "isLoggedIn")
        SystemVariables.systemPreferences.synchronize()
    }
    
    static func updateVehicleDetails(colour: String?=nil, displayName: String?=nil, generalID: String?=nil, optionCodes: String?=nil, userID: Int?=nil, vehicleID: Int?=nil, vin: String?=nil, tokens: [String]?=nil, state: String?=nil, count: Int) {
        SystemVariables.systemPreferences.setObject(colour, forKey: "teslaVehicleColour")
        SystemVariables.systemPreferences.setObject(displayName, forKey: "teslaVehicleDisplayName")
        SystemVariables.systemPreferences.setObject(generalID, forKey: "teslaVehicleID")
        SystemVariables.systemPreferences.setObject(optionCodes, forKey: "teslaVehicleOptionCodes")
        SystemVariables.systemPreferences.setObject(userID, forKey: "teslaVehicleUserID")
        SystemVariables.systemPreferences.setObject(vehicleID, forKey: "teslaVehicleID")
        SystemVariables.systemPreferences.setObject(vin, forKey: "teslaVehicleVIN")
        SystemVariables.systemPreferences.setObject(tokens, forKey: "teslaVehicleTokens")
        SystemVariables.systemPreferences.setObject(state, forKey: "teslaVehicleState")
    }
    
    static func clearCache() {
        SystemVariables.systemPreferences.removeObjectForKey("userEmail")
        SystemVariables.systemPreferences.removeObjectForKey("userPassword")
        SystemVariables.systemPreferences.removeObjectForKey("teslaMotorsAuthToken")
        SystemVariables.systemPreferences.setObject(false, forKey: "isLoggedIn")
        SystemVariables.systemPreferences.synchronize()
    }
    
    static func resetSongVC() {
        SystemVariables.systemPreferences.setObject(true, forKey: "firstTimeShowingSongVC")
    }
    
    // Determines if the tab bar was loaded after logging out and logging back in
    static func setTabBarIndexBoolean(viewLoadedAfterSignout: Bool) {
        SystemVariables.systemPreferences.setBool(viewLoadedAfterSignout, forKey: "tabBarControllerLoadedAfterSignout")
    }
    
    static func notify3DTouchUse() {
        SystemVariables.systemPreferences.setBool(true, forKey: "3DTouchUse")
    }
    
//    // Determines if "Select Song" or "Test Song" should be enabled after 3D Touch
//    static func setSongAction3DTouch(action: UIVariables.SongAction) {
//        switch action {
//        case .SelectSong:
//            SystemVariables.systemPreferences.setObject("SelectSong", forKey: "songTypeFrom3DTouch")
//        case .TestSong:
//            SystemVariables.systemPreferences.setObject("TestSong", forKey: "songTypeFrom3DTouch")
//        }
//    }
}

// MARK: - Extensions (UI)

extension UIColor {
    // MARK: - Tesla Colors
    class func teslaMotorsGenericRed() -> UIColor {
        return UIColor(red: 224.0/255.0, green: 0, blue: 0, alpha: 1.0)
    }
    
    class func appIconDarkBlue() -> UIColor {
        return UIColor(red: 14.0/255.0, green: 16.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    }
    
    class func titaniumMetallicLight() -> UIColor {
        return UIColor(red: 94.0/255.0, green: 86.0/255.0, blue: 78.0/255.0, alpha: 1.0)
    }
    
    class func titaniumMetallicDark() -> UIColor {
        return UIColor(red: 55.0/255.0, green: 50.0/255.0, blue: 45.0/255.0, alpha: 1.0)
    }
    
    class func solidWhite() -> UIColor {
        return UIColor(red: 228.0/255.0, green: 225.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }
    
    class func redMultiCoatFierce() -> UIColor {
        return UIColor(red: 212.0/255.0, green: 0, blue: 0, alpha: 1.0)
    }
    
    class func redMultiCoatPale() -> UIColor {
        return UIColor(red: 226.0/255.0, green: 10.0/255.0, blue: 30.0/255.0, alpha: 1.0)
    }
    
    class func pearlWhiteMultiCoatNormal() -> UIColor {
        return UIColor(red: 220.0/255.0, green: 221.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    }
    
    class func pearlWhiteMultiCoatDark() -> UIColor {
        return UIColor(red: 190.0/255.0, green: 187.0/255.0, blue: 186.0/255.0, alpha: 1.0)
    }
    
    class func pearlWhiteMultiCoatLight() -> UIColor {
        return UIColor(red: 233.0/255.0, green: 234.0/255.0, blue: 235.0/255.0, alpha: 1.0)
    }
    
    class func obsidianBlackMetallicDark() -> UIColor {
        return UIColor(red: 8.0/255.0, green: 7.0/255.0, blue: 7.0/255.0, alpha: 1.0)
    }
    
    class func obsidianBlackMetallicLight() -> UIColor {
        return UIColor(red: 27.0/255.0, green: 28.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }
    
    class func midnightSilverDark() -> UIColor {
        return UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 30.0/255.0, alpha: 1.0)
    }
    
    class func midnightSilverLight() -> UIColor {
        return UIColor(red: 70.0/255.0, green: 74.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    }
    
    class func deepBlueMetallic() -> UIColor {
        return UIColor(red: 14.0/255.0, green: 16.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    }
    
    // MARK: - iOS Color Palette
    class func iOSPink() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 0.0, blue: 57.0/255.0, alpha: 1.0)
    }
    
    class func iOSRed() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    class func iOSOrange() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 145.0/255.0, blue: 0.0, alpha: 1.0)
    }
    
    class func iOSYellow() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 209.0/255.0, blue: 0.0, alpha: 1.0)
    }
    
    class func iOSGreen() -> UIColor {
        return UIColor(red: 0.0, green: 231.0/255.0, blue: 97.0/255.0, alpha: 1.0)
    }
    
    class func iOSLightBlue() -> UIColor {
        return UIColor(red: 0.0, green: 199.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    class func iOSMediumLightBlue() -> UIColor {
        return UIColor(red: 0.0, green: 169.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    }
    
    class func iOSMediumDarkBlue() -> UIColor {
        return UIColor(red: 0.0, green: 99.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    class func iOSDarkBlue() -> UIColor {
        return UIColor(red: 103.0/255.0, green: 50.0/255.0, blue: 220.0/255.0, alpha: 1.0)
    }
    
    // MARK: - Other colors
    class func lightBrown() -> UIColor {
        return UIColor(red: 139.0/255.0, green: 87.0/255.0, blue: 42.0/255.0, alpha: 1.0)
    }
    class func lightPurple() -> UIColor {
        return UIColor(red: 189.0/255.0, green: 16.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, forState: forState)
    }
}
