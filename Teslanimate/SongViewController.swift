//
//  SongViewController.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-02-27.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer
import MobileCoreServices
import Jukebox
import IBAnimatable
import ObjectMapper
import JSSAlertView
import SwiftyJSON
import EasyTimer
import Charts
import Instructions

class SongViewController: CustomizedBaseViewController, MPMediaPickerControllerDelegate, JukeboxDelegate, ChartViewDelegate, CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    @IBOutlet var selectSongView: AnimatableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var darkeningView: UIView!
    
    // "Select Song" Button Outlets
    @IBOutlet weak var selectSongButtonView: AnimatableView!
    @IBOutlet weak var selectSongButtonButton: AnimatableButton!
    @IBOutlet weak var selectSongButtonLabel: AnimatableLabel!
    @IBOutlet weak var selectSongButtonImageView: AnimatableImageView!
    
    @IBOutlet weak var testSongButtonView: AnimatableView!
    @IBOutlet weak var testSongButtonButton: AnimatableButton!
    @IBOutlet weak var testSongButtonLabel: AnimatableLabel!
    @IBOutlet weak var testSongButtonImageView: AnimatableImageView!
    
    @IBOutlet weak var playButtonView: AnimatableView!
    @IBOutlet weak var playButtonButton: AnimatableButton!
    @IBOutlet weak var playButtonLabel: AnimatableLabel!
    @IBOutlet weak var playButtonImageView: AnimatableImageView!
    
    @IBOutlet weak var stopButtonView: AnimatableView!
    @IBOutlet weak var stopButtonButton: AnimatableButton!
    @IBOutlet weak var stopButtonLabel: AnimatableLabel!
    @IBOutlet weak var stopButtonImageView: AnimatableImageView!
    
    // "Select Song" Label Outlets
    @IBOutlet weak var songNameLabel: AnimatableLabel!
    @IBOutlet weak var authorNameLabel: AnimatableLabel!
    
    @IBOutlet weak var playbackStatusUpdateImageView: AnimatableImageView!
    
    @IBOutlet weak var volumeChart: LineChartView!
    
    let coachMarksController = CoachMarksController()
    var showVehicleCountAlertController = false
    var showCoachMarksView = true
    
    // Jukebox variables
    var selectedSong = MPMediaItem()
    var testSongURL = NSURL()
    var audioAsset: AVAsset!
    var jukebox = Jukebox()
    
    // Test song variables
    var clickMarks: [ClickMark]?
    var downbeatTimePositions: [Float]?
    var nonCumulativeDownbeatTimePositions = [Double]()
    var timeArrayIndex = 1
    var notes: [Notes]?
    var durations : [Float]?
    var volumes : [Float]?
    
    // Test variables
    var authentificationJSON = [String: AnyObject]()
    var authentificationToken: String?
    var loginJSON = [String: AnyObject]()
    var vehicleCount: String?
    var teslaVehicleID: Int?
    
    // MARK: Standard view functions

    override func viewWillAppear(animated: Bool) {
        configureMediaPickerController()
        
        if SystemVariables.systemPreferences.boolForKey("isLoggedIn") == true {
            self.playTeslaAccelerationSound()
        }

        if SystemVariables.systemPreferences.boolForKey("isLoggedIn") == false {
            dispatch_async(dispatch_get_main_queue(), {
                self.showLoginViewController()
            })
        }
        
        // Getting click marks and downbeat time positions for test song
        (clickMarks, downbeatTimePositions) = NetworkingVariables.openAnalyzeTempoJSONFile(UIVariables.analyzeTempoTestJSON)
//        (notes, durations, volumes) = NetworkingVariables.openAnalyzeMelodyJSONFile(UIVariables.analyzeMelodyTestJSON)
//        configureChart()
//        setChart(volumes!, values: durations!)
        
        if let uDTPositions = downbeatTimePositions {
            var previousItem: Float = 0
            nonCumulativeDownbeatTimePositions = uDTPositions.map({ item in
                defer { previousItem = item }
                return Double(item-previousItem)
            })
            debugPrint(self.nonCumulativeDownbeatTimePositions, self.nonCumulativeDownbeatTimePositions.count)
        }
        
        retrieveVehicleData()
        animateDownbeats(0, timePositions: self.nonCumulativeDownbeatTimePositions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
        // FIXME: - These statements aren't being executed. They need to be executed to make 3D Touch work correctly
        if SystemVariables.systemPreferences.boolForKey("3DTouchUse") == true {
            let songType = SystemVariables.systemPreferences.valueForKey("songTypeFrom3DTouch") as! String
            switch songType {
            case "SelectSong":
                selectSongButtonView.hidden = true
                selectASongButton(self)
            case "TestSong":
                testSongButtonView.hidden = true
                playTestSong()
            default:
                break
            }
        }
        */
        
        self.coachMarksController.delegate = self
        self.coachMarksController.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.playButtonView.hidden == true {
            self.coachMarksController.startOn(self)
        }

//        let launchedBefore = SystemVariables.systemPreferences.boolForKey("songViewLaunchedBefore")
//        if launchedBefore {
//            self.coachMarksController.stop()
//            debugPrint("Not the first launch")
//        } else {
//            self.coachMarksController.startOn(self)
//            SystemVariables.systemPreferences.setBool(true, forKey: "songViewLaunchedBefore")
//            debugPrint("First launch")
//        }
    }
    
    // MARK: - UI Setup
    
    override func configureView() {
        super.configureView()
        
        darkeningView.backgroundColor = UIVariables.darkeningViewBackgroundColor
        
        UIVariables.configureImageView(selectSongButtonImageView)
        UIVariables.configureImageView(testSongButtonImageView)
        UIVariables.configureImageView(playButtonImageView)
        UIVariables.configureImageView(stopButtonImageView)
        UIVariables.configureImageView(playbackStatusUpdateImageView)
    }
    
    override func viewDidLayoutSubviews() {
        if self.selectSongButtonView.hidden == true && self.testSongButtonView.hidden == true {
            animateIntroButtons()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        SystemVariables.systemPreferences.setBool(false, forKey: "firstTimeShowingSongVC")
        self.coachMarksController.stop()
    }
    
    func configureMediaPickerController() {
        mediaPickerController.delegate = self
        mediaPickerController.allowsPickingMultipleItems = false
        //        mediaPickerController.prompt = "Select a song to animate on your Tesla"
    }
    
    func animateIntroButtons() {
        self.selectSongButtonView.hidden = false
        self.testSongButtonView.hidden = false
        UIVariables.applyCustomAnimation(selectSongButtonView, animationType: UIVariables.selectSongButtonIntroAnimationType , duration: 1.0, delay: 0.1, damping: 0.85, velocity: 0.5, force: 0.5)
        UIVariables.applyCustomAnimation(testSongButtonView, animationType: UIVariables.testSongButtonIntroAnimationType, duration: 1.0, delay: 0.1, damping: 0.85, velocity: 0.5, force: 0.5)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        switch motion {
        case .MotionShake:
            self.coachMarksController.stop()
            self.playTestSong()
        default:
            break
        }
    }
    
    // MARK: - Chart setup
    
    func configureChart() {
        self.volumeChart.noDataText = ""
        self.volumeChart.descriptionText = ""
        self.volumeChart.xAxis.labelPosition = .Bottom
        self.volumeChart.backgroundColor = UIVariables.volumeChartBackgroundColor
    }
    
    func setChart(dataPoints: [Float], values: [Float]) {
        var dataEntries: [ChartDataEntry] = []
        
        // FIXME: Not 100% sure about this "dataPoints[i]" expression for the xIndex
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: Double(values[i]), xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Song analysis")
        lineChartDataSet.colors = [UIColor.iOSMediumDarkBlue()]
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        volumeChart.data = lineChartData
        volumeChart.animate(xAxisDuration: UIVariables.volumeChartAnimationDuration, yAxisDuration: UIVariables.volumeChartAnimationDuration, easingOption: .EaseInCubic)
    }
    
    // MARK: - API test calls
    
    // MARK: Sonic API currently offline
    func runSonicAPITestRequest(songURL: NSURL) {
        Alamofire.upload(.POST, "https://api.sonicAPI.com/analyze/tempo", multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: NetworkingVariables.sonicAPIAccessIDValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)! , name: "access_id")
            multipartFormData.appendBodyPart(fileURL: songURL, name: "input_file")
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response.result.value)
                        debugPrint(response.response)
                        debugPrint(response.request)
                }
                case .Failure(let encodingError): break
        }
    })
}
    
    // MARK: - IBAction functions
    
    // Select Song Button - Touch Up Inside
    @IBAction func selectASongButton(sender: AnyObject) {
        UIVariables.changeImage(selectSongButtonImageView, newImageName: "Select Song Button")
        self.presentViewController(mediaPickerController, animated: true, completion: nil)
    }
    
    // Test Song Button - Touch Up Inside
    @IBAction func testSongButton(sender: AnyObject) {
        UIVariables.changeImage(testSongButtonImageView, newImageName: "Test Song Button")
        playTestSong()
        // TODO: Load the test song ("Big Things" by Nas) into memory and start playing it.
        // Its JSON will be analyzed on a background thread when loading the app.
    }
    
    // Play Button - Touch Up Inside
    @IBAction func resumePlayingButton(sender: AnyObject) {
        UIVariables.changeImage(playButtonImageView, newImageName: "Play Button")
        presentPlaybackStatusImageView(self.playbackStatusUpdateImageView, imageName: "'Play' Subview")
        resumePlayingJukebox()
    }
    
    // Stop Button - Touch Up Inside
    @IBAction func stopPlayingSongButton(sender: AnyObject) {
        UIVariables.changeImage(stopButtonImageView, newImageName: "Stop Button")
        presentPlaybackStatusImageView(self.playbackStatusUpdateImageView, imageName: "'Pause' Subview")
        stopPlayingJukebox()
    }
    
    // Any Button - Touch Down
    @IBAction func displayPressedInImage(sender: AnyObject) {
        switch sender.tag {
        case 1:
            UIVariables.changeImage(selectSongButtonImageView, newImageName: "Select Song Button - Pressed")
        case 2:
            UIVariables.changeImage(playButtonImageView, newImageName: "Play Button - Pressed")
        case 3:
            UIVariables.changeImage(stopButtonImageView, newImageName: "Stop Button - Pressed")
        case 4:
            UIVariables.changeImage(testSongButtonImageView, newImageName: "Test Song Button - Pressed")
        default:
            UIVariables.changeImage(selectSongButtonImageView, newImageName: "Select Song Button - Pressed")
        }
    }
    
    // Any Button - Touch Drag Exit
    @IBAction func resetImageViewImage(sender: AnyObject) {
        switch sender.tag {
        case 1:
            UIVariables.changeImageWithAnimation(selectSongButtonImageView, duration: UIVariables.viewTransitionDurationTime, transitionOptions: UIVariables.imageTransitionType , newImageName: "Select Song Button")
        case 2:
            UIVariables.changeImageWithAnimation(playButtonImageView, duration: UIVariables.viewTransitionDurationTime, transitionOptions: UIVariables.imageTransitionType, newImageName: "Play Button")
        case 3:
            UIVariables.changeImageWithAnimation(stopButtonImageView, duration: UIVariables.viewTransitionDurationTime, transitionOptions: UIVariables.imageTransitionType, newImageName: "Stop Button")
        case 4:
            UIVariables.changeImageWithAnimation(testSongButtonImageView, duration: UIVariables.viewTransitionDurationTime, transitionOptions: UIVariables.imageTransitionType, newImageName: "Test Song Button")
        default:
            UIVariables.changeImageWithAnimation(selectSongButtonImageView, duration: UIVariables.viewTransitionDurationTime, transitionOptions: UIVariables.imageTransitionType, newImageName: "Select Song Button")
        }
    }
    
    // MARK: - MKMediaPickerControllerDelegate setup
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.coachMarksController.stop()
        let selectedSongs = mediaItemCollection.items
        if selectedSongs.count > 0 {
            if let song = selectedSongs[0] as? MPMediaItem {
                self.selectedSong = song
                if let songURL = song.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL {
//                    self.runSonicAPITestRequest(songURL)
                    if let asset = AVAsset(URL: songURL) as? AVAsset {
                        audioAsset = asset
                        configureAndPlayJukebox(songURL)
                        
                    }
                        dismissViewControllerAnimated(true, completion: {
                            self.presentPlaybackButtonsAndLabel(false)
                            self.presentPlaybackStatusImageView(self.playbackStatusUpdateImageView, imageName: "'Play' Subview")
                        })
                    debugPrint("Asset loaded")
                } else {
                    dismissViewControllerAnimated(true, completion: nil)
                    debugPrint("Asset failed to load properly")
                }
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        self.coachMarksController.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - MPMediaQuery setup
    
    func playTestSong() {
        if let halfTheManPath = NSBundle.mainBundle().pathForResource("Half the Man", ofType: "mp3") {
            testSongURL = NSURL(fileURLWithPath: halfTheManPath)
            jukebox.stop()
            if let currentItemURL = jukebox.currentItem?.URL {
                jukebox.removeItem(JukeboxItem(URL: currentItemURL))
            }
            configureAndPlayJukebox(testSongURL)
            if let asset = AVAsset(URL: self.testSongURL) as? AVAsset {
                audioAsset = asset
            }
            self.presentPlaybackButtonsAndLabel(true)
            self.presentPlaybackStatusImageView(self.playbackStatusUpdateImageView, imageName: "'Play' Subview")
        }
        /**
        var query = MPMediaQuery.songsQuery()
        let specificSongPredicate = MPMediaPropertyPredicate(value: UIVariables.testSongTitle, forProperty: MPMediaItemPropertyTitle)
        query.filterPredicates = NSSet(object: specificSongPredicate) as! Set<MPMediaPredicate>
        let mediaCollection = MPMediaItemCollection(items: query.items!)
        if let testMediaItem = mediaCollection.items[0] as? MPMediaItem {
            self.selectedSong = testMediaItem
            if let testSongURL = testMediaItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL {
                configureAndPlayJukebox(testSongURL)
                if let asset = AVAsset(URL: testSongURL) as? AVAsset {
                    audioAsset = asset
                }
                self.presentPlaybackButtonsAndLabel()
                self.presentPlaybackStatusImageView(self.playbackStatusUpdateImageView, imageName: "'Play' Subview")
            }
        } */
    }
    
    // MARK: - UI Helper functions
    
    func presentPlaybackButtonsAndLabel(testSong: Bool) {
        
        if testSong {
            self.songNameLabel.text = UIVariables.testSongTitle
            self.authorNameLabel.text = UIVariables.testSongAuthor
        } else {
            self.songNameLabel.text = selectedSong.title
            self.authorNameLabel.text = selectedSong.artist
        }
        
        if self.playButtonView.hidden == true {
            
            self.playButtonView.hidden = false
            self.stopButtonView.hidden = false
            self.songNameLabel.hidden = false
            self.authorNameLabel.hidden = false
            
            UIVariables.applyCustomAnimation(self.playButtonView, animationType: UIVariables.playButtonIntroAnimationType , duration: 0.5, delay: 0.5, damping: 0.75, velocity: 0.5, force: 0.5)
            UIVariables.applyCustomAnimation(self.stopButtonView, animationType: UIVariables.stopButtonIntroAnimationType, duration: 0.5, delay: 0.5, damping: 0.75, velocity: 0.5, force: 0.5)
        }

        UIVariables.applyCustomAnimationToLabels([self.songNameLabel, self.authorNameLabel], animationTypes: ["FadeInLeft", "FadeInRight"], duration: 1, delay: 0.5, damping: 0.75, velocity: 0.5, force: 0.5)
    }
    
    func presentPlaybackStatusImageView(imageView: AnimatableImageView, imageName: String) {
        imageView.hidden = false
        imageView.image = UIImage(named: imageName)
        UIVariables.applyCustomAnimationToImageView(imageView, animationType: UIVariables.playbackStatusUpdateIntroAnimationType , duration: 0.3, delay: 0, damping: 0.75, velocity: 0.5, force: 0.5)
        UIVariables.applyCustomAnimationToImageView(imageView, animationType: UIVariables.playbackStatusUpdateOutroAnimationType , duration: 0.5, delay: 0.3, damping: 0.75, velocity: 0.5, force: 0.5)
    }
    
    // MARK: - Jukebox setup
    
    func configureAndPlayJukebox(songURL: NSURL) {
        if jukebox.state == JukeboxState.Playing {
            jukebox.stop()
            let currentItemURL = jukebox.currentItem?.URL
            jukebox.removeItem(JukeboxItem(URL: currentItemURL!))
        }
        jukebox = Jukebox(delegate: self, items: [JukeboxItem(URL: songURL)])
        jukebox.play()
    }
    
    func resumePlayingJukebox() {
        jukebox.play()
    }
    
    func stopPlayingJukebox() {
        jukebox.pause()
    }
    
    func jukeboxStateDidChange(jukebox: Jukebox) {
        debugPrint("Jukebox state is now \(jukebox.state).")
        switch jukebox.state {
        case JukeboxState.Ready:
            UIVariables.applyCustomAnimationToLabels([self.songNameLabel, self.authorNameLabel], animationTypes: ["FadeOutRight", "FadeOutLeft"], duration: 0.5, delay: 0.0, damping: 0.75, velocity: 0.5, force: 0.5)
        case JukeboxState.Loading:
            let yDifference = self.view.frame.size.height - (self.tabBarController?.tabBar.frame.size.height)! - self.testSongButtonView.frame.maxY
            UIVariables.applyCustomAnimation(self.testSongButtonView, animationType: UIVariables.testSongButtonOutroAnimationType, duration: 0.5, delay: 0.5, damping: 0.75, velocity: 0.5, force:  0.5, x: 0, y: yDifference * 0.925)
        default:
            break
        }
    }
    
    func jukeboxPlaybackProgressDidChange(jukebox: Jukebox) {
        
    }
    
    func jukeboxDidLoadItem(jukebox: Jukebox, item: JukeboxItem) {
        
    }
    
    // MARK: - Instructions setup
    
    func numberOfCoachMarksForCoachMarksController(coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex index: Int) -> CoachMark {
        return coachMarksController.coachMarkForView(self.selectSongButtonImageView, bezierPathBlock: { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(ovalInRect: CGRectInset(frame, 0, 0))
        })
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkWillLoadForIndex index: Int) -> Bool {
        return true
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation, hintText: "Shake the device to animate a test song!", nextText: "OK")
        
        coachViews.bodyView.hintLabel.text = "Shake me to animate a test song!"
        coachViews.bodyView.nextLabel.text = "OK"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkWillDisappear coachMark: CoachMark, forIndex index: Int) {
        if self.showVehicleCountAlertController {
            1.second.delay({
                self.showNoVehicleAlertController("No vehicles found!", text: "This application requires you to own a Tesla!")
            })
        }
    }
    
    // MARK: - Tesla Motors
    
    func playTeslaAccelerationSound() {
        if let accelerationSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Tesla Engine Sound", ofType: "mp3")!) as? NSURL {
            configureAndPlayJukebox(accelerationSoundURL)
        }
    }
    
    func retrieveVehicleData() {
        Networking.sendGETRequestToTeslaServers(TeslaMotorsAPIRequestType.GET.ListAllVehicles, headers: ["Authorization": "Bearer 234e453d5d9eba73ab91b594a500c4f1750c22acca3c30cbe4cb37782bf94a27"], completion: { (let jsonResponse, let success) in
            if let uJSONResponse = jsonResponse as? [String:AnyObject] {
                let vehicleCount = uJSONResponse["count"] as? Int
                if vehicleCount == 0 {
                    if SystemVariables.systemPreferences.boolForKey("firstTimeShowingSongVC") == true {
                        self.showVehicleCountAlertController = true
//                        self.showNoVehicleAlertController("No vehicles found!", text: "This application requires you to own a Tesla!")
                    }
                    let mappedResponse = Mapper<NegativeListAllVehiclesJSONResponse>().map(uJSONResponse)
                    if let count = mappedResponse?.vehicleCount {
                        SystemVariables.updateVehicleDetails(count: count)
                    }
                } else {
                    let mappedResponse = Mapper<ListAllVehiclesJSONResponse>().map(uJSONResponse)
                    self.showBasicAlertController("Vehicles found!", text: "\(mappedResponse?.vehicleCount) vehicles are available to be animated!")
                    if let colour = mappedResponse?.vehicleColor, let name = mappedResponse?.vehicleDisplayName, let generalID = mappedResponse?.generalID, optionCodes = mappedResponse?.vehicleOptionCodes, let userID = mappedResponse?.vehicleUserID, let vehicleID = mappedResponse?.vehicleID, vin = mappedResponse?.vehicleVIN, let tokens = mappedResponse?.vehicleTokens, let state = mappedResponse?.vehicleState, let count = mappedResponse?.vehicleCount where colour.characters.count > 0 {
                        SystemVariables.updateVehicleDetails(colour, displayName: name, generalID: generalID, optionCodes: optionCodes, userID: userID, vehicleID: vehicleID, vin: vin, tokens: tokens, state: state, count: count)
                        self.teslaVehicleID = vehicleID
                    }
                }
            }
        })
    }
    
    func animateDownbeats(index: Int, timePositions: [Double]) {
        sendHeadlightRequest()
        if index + 1 < timePositions.count {
            Double(timePositions[index]).second.delay {
                self.animateDownbeats(index + 1, timePositions: timePositions)
            }
        }
    }
    
    func sendHeadlightRequest() {
        Networking.sendPOSTRequestToTeslaServers(TeslaMotorsAPIRequestType.POST.FlashLights, headers: ["Authorization": "Bearer 20e3bcf55cae997b20cbddd4b6946a734198f92f631e273486950d89ff6e5f47"], vehicleID: self.teslaVehicleID , completion: { (let jsonResponse, let success) in
            if let uJSONResponse = jsonResponse as? GenericCommandJSONResponse {
                debugPrint(uJSONResponse.result, uJSONResponse.reason)
            }
        })
    }
}
