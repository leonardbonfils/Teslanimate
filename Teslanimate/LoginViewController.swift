//
//  LoginViewController.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-29.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import TextFieldEffects
import IBAnimatable
import SwiftyJSON
import JSSAlertView
import Photos
import PhotosUI
import MobileCoreServices

class LoginViewController: CustomizedBaseViewController {
    
    @IBOutlet weak var teslaMotorsLogo: AnimatableImageView!
    @IBOutlet weak var emailTextField: KaedeTextField!
    @IBOutlet weak var passwordTextField: KaedeTextField!
    @IBOutlet weak var loginButton: AnimatableButton!
    @IBOutlet var loginView: AnimatableView!
    @IBOutlet weak var teslaMotorsWhiteLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var darkeningView: UIView!
    @IBOutlet weak var testLivePhotoView: PHLivePhotoView!
    
    var loginJSONResponse: AnyObject?
    var keyboardPresent = false
    var teslaMotorsLogoConstraint = NSLayoutConstraint()
    var livePhotoPreviewImage = UIImage()
    
    override func viewWillAppear(animated: Bool) {
        self.loginButton.setTitleColor(UIVariables.loginButtonNormalTextColor, forState: .Selected)
        self.loginButton.setTitleColor(UIVariables.alternateLoginButtonTextColor, forState: .Highlighted)
        
        if let isLoggedIn: Bool = SystemVariables.systemPreferences.boolForKey("isLoggedIn") {
            if isLoggedIn {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - API test calls
    
    // MARK: - UI Setup
    
    override func configureView() {
        super.configureView()
        
        configureLivePhotoBackground("Tesla Live Photo", livePhotoVideoFileName: "Tesla Live Photo", videoExtensionName: "MOV", livePhotoView: self.testLivePhotoView, livePhotoPreviewImage: self.livePhotoPreviewImage)
    
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        emailTextField.autocorrectionType = .No
        emailTextField.keyboardAppearance = UIVariables.keyboardAppearance
        emailTextField.placeholderColor = UIVariables.textFieldPlaceholderColor
        emailTextField.foregroundColor = UIVariables.textFieldForegroundColor
        emailTextField.layer.borderColor = UIVariables.loginViewBorderColor
        
        passwordTextField.keyboardType = UIKeyboardType.Default
        passwordTextField.autocorrectionType = .No
        passwordTextField.keyboardAppearance = UIVariables.keyboardAppearance
        passwordTextField.placeholderColor = UIVariables.textFieldPlaceholderColor
        passwordTextField.foregroundColor = UIVariables.textFieldForegroundColor
        passwordTextField.layer.borderColor = UIVariables.loginViewBorderColor
        
        loginButton.backgroundColor = UIVariables.textFieldForegroundColor
        loginButton.layer.borderColor = UIVariables.loginViewBorderColor
        loginButton.titleLabel?.textColor = UIVariables.loginButtonNormalTextColor
        
        darkeningView.backgroundColor = UIVariables.darkeningViewBackgroundColor
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

        let tapOutsideKeyboard = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapOutsideKeyboard)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        teslaMotorsLogoConstraint = teslaMotorsWhiteLogoTopConstraint
        debugPrint(teslaMotorsLogoConstraint)
        self.view.removeConstraint(teslaMotorsWhiteLogoTopConstraint)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if self.keyboardPresent == false {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        self.keyboardPresent = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.addConstraint(teslaMotorsLogoConstraint)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if self.keyboardPresent == true {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
        self.keyboardPresent = false
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    // MARK: - IBAction functions
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        dismissKeyboard()
        UIView.animateWithDuration(UIVariables.viewTransitionDurationTime * 0.5, animations: {
            self.loginButton.backgroundColor = UIVariables.textFieldForegroundColor
        })
        
        let emailAddress = self.emailTextField.text as String!
        let password     = self.passwordTextField.text as String!
        var parameters = NetworkingVariables.initialLoginParameters
        parameters["email"]    = emailAddress
        parameters["password"] = password
        
        let validParameters = NetworkingVariables.inputLoginParametersAreValid(emailAddress, password: password)
        if validParameters {
            loginToTeslaMotorsServers(emailAddress, password: password, parameters: parameters) {
                (let success) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.showBasicAlertController("Login Failed", text: "Connection to Tesla Motors servers failed")
                }
            }
        } else {
            self.showBasicAlertController("Login Failed", text: "Email address/password combination is not valid")
        }
    }
    
    // Login Button - Touch Down
    @IBAction func displayPressedInLoginButton(sender: AnimatableButton) {
        self.loginButton.backgroundColor = UIVariables.alternateLoginButtonBackgroundColor
    }
    
    // Login Button - Touch Drag Exit
    @IBAction func resetLoginButtonAppearance(sender: AnimatableButton) {
        UIView.animateWithDuration(UIVariables.viewTransitionDurationTime * 0.5, animations: {
            self.loginButton.backgroundColor = UIVariables.textFieldForegroundColor
        })
    }
    
    // MARK: - Networking Log In Operation
    
    func loginToTeslaMotorsServers(emailAddress: String, password: String, parameters: [String: String], completion: VCLevelLoginCompletion) {
        Networking.sendPOSTRequestToTeslaServers(TeslaMotorsAPIRequestType.POST.Login, parameters: parameters, completion: {
           (let jsonResponse, let success) in
            if success == true {
                debugPrint(jsonResponse)
                if let uJSONResponse = jsonResponse as? LoginJSONResponse {
                  if let authToken = uJSONResponse.loginAuthToken, let authTokenType = uJSONResponse.loginAuthTokenType, let authTokenExpirationTimer = uJSONResponse.loginAuthTokenExpirationTimer, let authTokenCreationTime = uJSONResponse.loginAuthTokenCreationTime where authToken.characters.count > 0 {
                    debugPrint("\(authToken, authTokenType, authTokenExpirationTimer, authTokenCreationTime)")
                    SystemVariables.updateSystemPreferences(emailAddress, userPassword: password, teslaMotorsAuthToken: authToken, userIsLoggedIn: true)
                    completion(success: true)
                    }
                }
            } else {
                completion(success: false)
            }
        })
    }
}
