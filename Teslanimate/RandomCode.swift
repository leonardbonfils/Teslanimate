//
//  RandomCode.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-03-23.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//
/*
import Foundation
import UIKit

case .TeslaMotorsAPICommandWithoutParameters:
break
// complete the request without parameters ---- headers
case .TeslaMotorsAPICommandWithParameters:
// complete the request ------ headers + parameters
debugPrint(".TeslaMotorsAPICommandWithParameters")
}

// ------------------


 static func sendRequestToTeslaServers(requestType: APIRequestActionType, headers: [String: String]?=nil, parameters: [String: String]?=nil, fileURL: NSURL?=nil, completion: GeneralCompletion<APIRequestActionType>.generalCompletion) {
 switch requestType {
 case .TeslaMotorsAPILogin:
 // log in to Tesla servers --- parameters
 Alamofire.request(.POST, "https://owner-api.teslamotors.com/oauth/token", parameters: parameters)
 .validate()
 .responseJSON() { response in
 switch response.result {
 case .Success:
 if let jsonResult = response.result.value as? [String: AnyObject] {
 let loginJSONResponse = Mapper<LoginJSONResponse>().map(jsonResult)
 GeneralCompletion<requestType>.generalCompletion(jsonResponse: loginJSONResponse, success: true)
 }
 case .Failure:
 completion(jsonResponse: LoginJSONResponse() , success: false)
 }
 }
 case .TeslaMotorsAPIGETRequestWithoutParameters:
 // Send GET Request to Tesla servers ---- headers
 Alamofire.request(.GET, "https://owner-api.teslamotors.com/api/1/vehicles", headers: headers)
 .validate()
 .responseJSON() { response in
 switch response.result {
 case .Success:
 if let jsonResult = response.result.value as? [String: AnyObject] {
 
 }
 case .Failure: break
 }
 }
 case .TeslaMotorsAPICommandWithoutParameters:
 break
 // complete the request without parameters ---- headers
 case .TeslaMotorsAPICommandWithParameters:
 // complete the request ------ headers + parameters
 debugPrint(".TeslaMotorsAPICommandWithParameters")
 case.SonicAPIRequest:
 debugPrint(".SonicAPIRequest")
 // send the audio file for analysis ----- parameters + file (Alamofire separates the file from the parameters)
 }
 }
 


 static func sendRequestToTeslaServers(requestType: APIRequestActionType, headers: [String: String]?=nil, parameters: [String: String]?=nil, fileURL: NSURL?=nil, completion: GeneralCompletion) {
 switch requestType {
 case .TeslaMotorsAPILogin:
 // log in to Tesla servers --- parameters
 Alamofire.request(.POST, "https://owner-api.teslamotors.com/oauth/token", parameters: parameters)
 .validate()
 .responseJSON() { response in
 switch response.result {
 case .Success:
 if let jsonResult = response.result.value as? [String: AnyObject] {
 let loginJSONResponse = Mapper<LoginJSONResponse>().map(jsonResult)
 completion(jsonResponse: loginJSONResponse!, success: true)
 }
 case .Failure:
 completion(jsonResponse: LoginJSONResponse() , success: false)
 }
 }
 case .TeslaMotorsAPIGETRequestWithoutParameters:
 // Send GET Request to Tesla servers ---- headers
 Alamofire.request(.GET, "https://owner-api.teslamotors.com/api/1/vehicles", headers: headers)
 .validate()
 .responseJSON() { response in
 switch response.result {
 case .Success:
 if let jsonResult = response.result.value as? [String: AnyObject] {
 
 }
 case .Failure: break
 }
 }
 case .TeslaMotorsAPICommandWithoutParameters:
 break
 // complete the request without parameters ---- headers
 case .TeslaMotorsAPICommandWithParameters:
 // complete the request ------ headers + parameters
 debugPrint(".TeslaMotorsAPICommandWithParameters")
 }
 }

 
if let index = mappedCM?.clickIndex, let bpm = mappedCM?.localTempoEstimate, let reliability = mappedCM?.clickMarkReliability, let time = mappedCM?.clickMarkTimePosition, let downbeat = mappedCM?.downbeat {
    //                            debugPrint(index, bpm, reliability, time, downbeat)
}
 ------------
 
 class SettingsTile: UIView {
 
 var settingsTitleView = UIView()
 
 required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 }
 
 override init(frame: CGRect) {
 super.init(frame: frame)
 
 settingsTitleView = (UINib(nibName: "SettingsTile", bundle: nil).instantiateWithOwner(self, options: nil)[0] as? SettingsTile)!
 self.addSubview(settingsTitleView)
 
 self.backgroundColor = UIColor.redColor()
 self.layer.cornerRadius = frame.size.width / 2.0
 self.layer.borderWidth = 3.0
 self.layer.borderColor = UIVariables.settingTileBorderColor
 self.clipsToBounds = true
 }
 }