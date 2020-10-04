//
//  NetworkingModels.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-29.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import SwiftyJSON

/**
struct GeneralCompletion<APIRequestActionType> {
    typealias generalCompletion = (jsonResponse: APIRequestActionType, success: Bool) -> ()
}
*/

struct Networking {
    
    typealias GeneralCompletion =           (jsonResponse: AnyObject?, success: Bool) -> ()
    typealias LoginCompletion =             (jsonResponse: LoginJSONResponse, success: Bool) -> ()
    typealias ListAllVehiclesCompletion =   (jsonResponse: ListAllVehiclesJSONResponse, success: Bool) -> ()
    typealias MobileAccessCompletion =      (jsonResponse: MobileAccessJSONResponse, success: Bool) -> ()
    typealias VehicleStateCompletion =      (jsonResponse: VehicleStateJSONResponse, success: Bool) -> ()
    typealias GenericCommandCompletion =    (jsonResponse: GenericCommandJSONResponse, success: Bool) -> ()
    typealias TempoAnalysisCompletion =     (jsonResponse: TempoAnalysisJSONResponse, success: Bool) -> ()
    
    enum Router: URLRequestConvertible {
        static var baseRequestURL = ""
        
        case GetAnAccessToken
        case ListAllVehicles
        case MobileAccess
        
        var URLRequest: NSMutableURLRequest {
            var result: String = {
                switch self {
                case .GetAnAccessToken:
                    Router.baseRequestURL = NetworkingVariables.loginURL
                    return ("")
                case .ListAllVehicles:
                    Router.baseRequestURL = NetworkingVariables.baseURL
                    return ("")
                case .MobileAccess:
                    Router.baseRequestURL = NetworkingVariables.baseURL
                    return ("/vehicle_id/mobile_enabled")
                }
            }()
            
            let baseEndpointURL = NSURL(string: Router.baseRequestURL)
            let endpointRequest = NSMutableURLRequest(URL: baseEndpointURL!.URLByAppendingPathComponent(result))
            return endpointRequest
        }
    }
    
    static func sendPOSTRequestToTeslaServers(requestType: TeslaMotorsAPIRequestType.POST, headers: [String: String]?=nil, parameters: [String: String]?=nil, fileURL: NSURL?=nil, vehicleID: Int?=nil, completion: GeneralCompletion) {
        switch requestType {
        case TeslaMotorsAPIRequestType.POST.Login:
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
        case TeslaMotorsAPIRequestType.POST.FlashLights:
            let flashLightURL = "\(NetworkingVariables.baseFlashLightsURL)\(vehicleID)/command/flash_lights"
            Alamofire.request(.POST, flashLightURL, headers: headers)
                .validate()
                .responseJSON() { response in
                    switch response.result {
                    case .Success:
                        if let jsonResult = response.result.value as? [String: AnyObject] {
                            let commandJSONResponse = Mapper<GenericCommandJSONResponse>().map(jsonResult)
                            completion(jsonResponse: commandJSONResponse!, success: true)
                        }
                    case .Failure:
                        completion(jsonResponse: GenericCommandJSONResponse(), success: false)
                    }
            }
        default:
            break
        }
    }
    
    static func sendGETRequestToTeslaServers(requestType: TeslaMotorsAPIRequestType.GET, headers: [String: String]?=nil, parameters: [String: String]?=nil, fileURL: NSURL?=nil, completion: GeneralCompletion) {
        switch requestType {
        case TeslaMotorsAPIRequestType.GET.ListAllVehicles:
            Alamofire.request(.GET, "https://owner-api.teslamotors.com/api/1/vehicles", headers: headers)
                .validate()
                .responseJSON() { response in
                    switch response.result {
                    case .Success:
                        if let jsonResult = response.result.value as? [String: AnyObject] {
                            completion(jsonResponse: jsonResult, success: true)
                        }
                    case .Failure:
                        // goes to here
//                        completion(jsonResponse: ListAllVehiclesJSONResponse(), success: false)
                        completion(jsonResponse: nil, success: false)
                    }
                }
        default:
            break
        }
    }
}

enum APIRequestActionType: String {
    case TeslaMotorsAPILogin = "TeslaMotorsAPILogin"                                    // parameters (POST)
    case TeslaMotorsAPIGETRequestWithoutParameters = "TeslaMotorsAPIGETRequestWithoutParameters"
    case TeslaMotorsAPICommandWithoutParameters = "TeslaMotorsAPICommandWithoutHeaders" // headers (POST)
    case TeslaMotorsAPICommandWithParameters = "TeslaMotorsAPICommandWithParameters"    // headers + parameters (POST)
}

// TODO: - Group requests with similar responses together (e.g.
enum TeslaMotorsAPIRequestType {
    enum POST {
        case Login
        case WakeUpCar
        case FlashLights
        case HonkHorn
        case UnlockDoors
        case RemoteStart
        case OpenTrunkOrFrunk
    }
    enum GET {
        case ListAllVehicles
        case MobileAccess
        case VehicleState
    }
}

enum SonicAPIRequestType {
    case AnalyzeTempo   // parameters + file (POST)
}

class LoginJSONResponse: Mappable { // This is the object class used to store the JSON object from the login
    var loginAuthToken:                 String?
    var loginAuthTokenType:             String?
    var loginAuthTokenExpirationTimer:  Int?
    var loginAuthTokenCreationTime:     NSDate?
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        loginAuthToken                  <- map["access_token"]
        loginAuthTokenType              <- map["token_type"]
        loginAuthTokenExpirationTimer   <- map["expires_in"]
        loginAuthTokenCreationTime      <- (map["created_at"], DateTransform())
    }
    
}

// TODO: - Format all my variable declaration paragraphs like the one below

class ListAllVehiclesJSONResponse: NegativeListAllVehiclesJSONResponse {
    var vehicleColor:           String?
    var vehicleDisplayName:     String?
    var generalID:              String?
    var vehicleOptionCodes:     String?
    var vehicleUserID:          Int?
    var vehicleID:              Int?
    var vehicleVIN:             String?
    var vehicleTokens:          [String]?
    var vehicleState:           String?
    
    override func mapping(map: Map) {
        vehicleColor                    <- map["response.0.color"]
        vehicleDisplayName              <- map["response.0.display_name"]
        generalID                       <- map["response.0.id"]
        vehicleOptionCodes              <- map["response.0.option_codes"]
        vehicleUserID                   <- map["response.0.user_id"]
        vehicleID                       <- map["response.0.vehicle_id"]
        vehicleVIN                      <- map["response.0.vin"]
        vehicleTokens                   <- map["response.0.tokens"]
        vehicleState                    <- map["response.0.state"]
    }
}

class NegativeListAllVehiclesJSONResponse: Mappable {
    var vehicleCount:   Int?
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        vehicleCount                    <- map["count"]
    }
}

class MobileAccessJSONResponse: Mappable {
    var responseValue:          String?
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        responseValue                   <- map["response"]
    }
}

class VehicleStateJSONResponse: Mappable {
    var driverSideFrontDoorOpen:    Bool?
    var driverSideRearDoorOpen:     Bool?
    var passengerSideFrontDoorOpen: Bool?
    var passengerSideRearDoorOpen:  Bool?
    var frontTrunkOpen:             Bool?
    var rearTrunkOpen:              Bool?
    var carFirmwareVersion:         String?
    var carIsLocked:                Bool?
    var panoramicRoofInstalled:     Bool?
    var panoramicRoofState:         String?
    var panoramicRoofPercentOpen:   Int?
    var darkRimsInstalled:          Bool?
    var wheelType:                  String?
    var spoilerInstalled:           Bool?
    var roofColor:                  String?
    var performanceConfiguration:   String?
    
    // Feature : Have some fun slide-in views (discrete, non-intrusive) say things like "Those dark rims on your Model S look sexy!)
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        driverSideFrontDoorOpen         <- map["response.df"]
        driverSideRearDoorOpen          <- map["response.dr"]
        passengerSideFrontDoorOpen      <- map["response.pf"]
        passengerSideRearDoorOpen       <- map["response.pr"]
        frontTrunkOpen                  <- map["response.ft"]
        rearTrunkOpen                   <- map["response.rt"]
        carFirmwareVersion              <- map["response.car_version"] // could be a typo, it said "car_verson" in the Apiary doc
        carIsLocked                     <- map["response.locked"]
        panoramicRoofInstalled          <- map["response.sun_roof_installed"]
        panoramicRoofState              <- map["response.sun_roof_state"]
        panoramicRoofPercentOpen        <- map["response.sun_roof_percent_open"]
        darkRimsInstalled               <- map["response.dark_rims"]
        wheelType                       <- map["response.wheel_type"]
        spoilerInstalled                <- map["response.has_spoiler"]
        roofColor                       <- map["response.roof_color"]
        performanceConfiguration        <- map["response.perf_config"]
    }
}

class GenericCommandJSONResponse: Mappable {
    var result:     Bool?
    var reason:     String?
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        result                          <- map["response.result"]
        reason                          <- map["response.reason"]
    }
}

class TempoAnalysisJSONResponse: Mappable {
    var statusCode:             Int?
    var clicksPerBar:           Int?
    var overallTempo:           Float?
    var overallTempoStraight:   Float?
    var clickMarksUnmapped =    [[String: AnyObject]]()
    var clickMarks:             [ClickMark]?
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        statusCode                      <- map["status.code"]
        clicksPerBar                    <- map["auftakt_result.clicks_per_bar"]
        overallTempo                    <- map["auftakt_result.overall_tempo"]
        overallTempoStraight            <- map["auftakt_result.overall_tempo_straight"]
        clickMarksUnmapped              <- map["auftakt_result.click_marks"]
        
        if let unwrappedClickMarks = clickMarksUnmapped as? [[String: AnyObject]] {
            for clickMark in unwrappedClickMarks {
                if let objectMappedClickMark = Mapper<ClickMark>().map(clickMark) {
                    clickMarks?.append(objectMappedClickMark)
                    debugPrint(objectMappedClickMark)
                }
            }
        }
    }
}

class ClickMark: Mappable {
    var clickIndex:             Int?      // The index of the click mark.
    var localTempoEstimate:     Float?    // The local tempo estimate in BPM.
    var clickMarkReliability:   Float?    // An estimate of the reliability of this click mark estimate.
    var clickMarkTimePosition:  Float?    // The time position of the click mark.
    var downbeat:               String?   // "true" for the first beat of a bar, "false" otherwise.
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        clickIndex                      <- map["index"]
        localTempoEstimate              <- map["bpm"]
        clickMarkReliability            <- map["probability"]
        clickMarkTimePosition           <- map["time"]
        downbeat                        <- map["downbeat"]
    }
}

class Notes: Mappable {
    var midiPitch:              Float?
    var onsetTime:              Float?
    var duration:               Float?
    var volume:                 Float?
    
    required init?(_ map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {
        midiPitch                       <- map["midi_pitch"]
        onsetTime                       <- map["onset_time"]
        duration                        <- map["duration"]
        volume                          <- map["volume"]
    }
}