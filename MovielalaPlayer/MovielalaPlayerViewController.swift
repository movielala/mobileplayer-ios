//
//  MovielalaPlayerViewController.swift
//  MovielalaPlayer
//
//  Created by Baris Sencan on 12/02/15.
//  Copyright (c) 2015 MovieLaLa. All rights reserved.
//

import UIKit
import MediaPlayer

private var globalConfiguration = MovielalaPlayerConfig()

public class MovielalaPlayerViewController: MPMoviePlayerViewController {
  public class var globalConfig: MovielalaPlayerConfig { return globalConfiguration }
  public var config: MovielalaPlayerConfig
  
  // controller title |> player title
  public override var title: String? {
    didSet {
      controlsView.titleLabel.text = title
    }
  }
  // Subviews.
  private let controlsView: MovielalaPlayerControlsView
  // State management properties.
  private var previousStatusBarHiddenValue: Bool!
  private var previousStatusBarStyle: UIStatusBarStyle!
  private var isFirstPlay = true
  private var wasPlayingBeforeTimeShift = false
  private var playbackTimeInterfaceUpdateTimer = NSTimer()
  private var hideControlsTimer = NSTimer()
  
  // MARK: - Initialization
  
  struct controlbar {
    let image: String?
    let tintColor: UIColor?
  }
  
  public init(contentURL: NSURL, config: MovielalaPlayerConfig = globalConfiguration) {
    self.config = config
    controlsView = MovielalaPlayerControlsView(config: config)
    super.init(contentURL: contentURL)
    initializeMovielalaPlayerViewController()
  }
  
  public init(contentURL: NSURL, configFileURL: NSURL) {
    let config = SkinParser.parseConfigFromURL(configFileURL) ?? globalConfiguration
    self.config = config
    controlsView = MovielalaPlayerControlsView(config: config)
    super.init(contentURL: contentURL)
    initializeMovielalaPlayerViewController()
  }
  
  public required init(coder aDecoder: NSCoder) {
    fatalError("storyboards are incompatible with truth and beauty")
  }
  
  private func initializeMovielalaPlayerViewController() {
    edgesForExtendedLayout = .None
    moviePlayer.scalingMode = .AspectFit
    moviePlayer.controlStyle = .None
    initializeNotificationObservers()
    initializeControlsView()
  }
  
  private func initializeNotificationObservers() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(
      self,
      selector: "handleMoviePlayerPlaybackStateDidChangeNotification",
      name: MPMoviePlayerPlaybackStateDidChangeNotification,
      object: moviePlayer)
    // Override playback completion handling.
    
    notificationCenter.removeObserver(
      self,
      name: MPMoviePlayerPlaybackDidFinishNotification,
      object: moviePlayer)
    notificationCenter.addObserver(
      self,
      selector: "showPostrollOrDismissAtVideoEnd",
      name: MPMoviePlayerPlaybackDidFinishNotification,
      object: moviePlayer)
    
    notificationCenter.removeObserver(
      self,
      name: "playVideoPlayer",
      object: nil)
    notificationCenter.addObserver(
      self,
      selector: "playVideoPlayer",
      name: "playVideoPlayer",
      object: nil)
    
    notificationCenter.removeObserver(
      self,
      name: "pauseVideoPlayer",
      object: nil)
    notificationCenter.addObserver(
      self,
      selector: "pauseVideoPlayer",
      name: "pauseVideoPlayer",
      object: nil)
    
    notificationCenter.removeObserver(
      self,
      name: "goToCustomTimeSliderWithTime",
      object: nil)
    notificationCenter.addObserver(
      self,
      selector: "goToCustomTimeSliderWithTime:",
      name: "goToCustomTimeSliderWithTime",
      object: nil)
  }
  
  private func initializeControlsView() {
    controlsView.closeButton.addTarget(
      self,
      action: "dismiss",
      forControlEvents: .TouchUpInside)
    controlsView.shareButton.addTarget(
      self,
      action: "shareContent",
      forControlEvents: .TouchUpInside)
    controlsView.playButton.addTarget(
      self,
      action: "togglePlay",
      forControlEvents: .TouchUpInside)
    controlsView.customTimeSliderView.timeSlider.addTarget(
      self,
      action: "timeShiftDidBegin",
      forControlEvents: .TouchDown)
    controlsView.customTimeSliderView.timeSlider.addTarget(
      self,
      action: "goToTimeSliderTime",
      forControlEvents: .ValueChanged)
    controlsView.customTimeSliderView.timeSlider.addTarget(
      self,
      action: "timeShiftDidEnd",
      forControlEvents: .TouchUpInside | .TouchUpOutside | .TouchCancel)
    initializeControlsViewTapRecognizers()
  }
  
  private func initializeControlsViewTapRecognizers() {
    let singleTapRecognizer = UITapGestureRecognizer(
      target: self,
      action: "toggleControlVisibility")
    singleTapRecognizer.numberOfTapsRequired = 1
    controlsView.addGestureRecognizer(singleTapRecognizer)
    let doubleTapRecognizer = UITapGestureRecognizer(
      target: self,
      action: "toggleVideoScalingMode")
    doubleTapRecognizer.numberOfTapsRequired = 2
    controlsView.addGestureRecognizer(doubleTapRecognizer)
    singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
  }
  
  deinit {
    playbackTimeInterfaceUpdateTimer.invalidate()
    hideControlsTimer.invalidate()
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Overridden Methods
  public override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(controlsView)
    
    NSTimer.scheduledTimerWithTimeInterval(
      0.0,
      target: self,
      selector: "updateBufferInterface",
      userInfo: nil, repeats: true)
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Force hide status bar.
    previousStatusBarHiddenValue = UIApplication.sharedApplication().statusBarHidden
    UIApplication.sharedApplication().statusBarHidden = true
    setNeedsStatusBarAppearanceUpdate()
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    controlsView.frame = view.bounds
  }
  
  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    // Restore status bar appearance.
    UIApplication.sharedApplication().statusBarHidden = previousStatusBarHiddenValue
    setNeedsStatusBarAppearanceUpdate()
  }
  
  // MARK: - Event Handling
  
  func togglePlay() {
    let state = moviePlayer.playbackState
    if state == .Playing || state == .Interrupted {
      moviePlayer.pause()
    } else {
      moviePlayer.play()
    }
  }
  
  func pauseVideoPlayer() {
    moviePlayer.pause()
  }
  
  func playVideoPlayer() {
    moviePlayer.play()
  }
  
  final func handleMoviePlayerPlaybackStateDidChangeNotification() {
    let state = moviePlayer.playbackState
    updatePlaybackTimeInterface()
    if state == .Playing || state == .Interrupted {
      doFirstPlaySetupIfNeeded()
      controlsView.playButton.setImage(config.controlbarConfig.pauseButtonImage, forState: .Normal)
      if !controlsView.controlsHidden {
        resetHideControlsTimer()
      }
      if let pauseViewController = config.pauseViewController {
        dismissMovielalaPlayerOverlay(pauseViewController)
      }
    } else {
      controlsView.playButton.setImage(config.controlbarConfig.playButtonImage, forState: .Normal)
      hideControlsTimer.invalidate()
      controlsView.controlsHidden = false
      if let pauseViewController = config.pauseViewController {
        addChildViewController(pauseViewController)
        controlsView.overlayContainerView.addSubview(pauseViewController.view)
        pauseViewController.didMoveToParentViewController(self)
        pauseViewController.delegate = self
      }
    }
  }
  
  final func hideControlsIfPlaying() {
    let state = moviePlayer.playbackState
    if state == .Playing || state == .Interrupted {
      controlsView.controlsHidden = true
    }
  }
  
  final func showPostrollOrDismissAtVideoEnd() {
    if let postrollVC = config.postrollViewController {
      showOverlayViewController(postrollVC)
      if let endCallback = config.endCallback {
        endCallback(playerVC: self)
      }
    } else {
      dismiss()
    }
  }
  
  final func timeShiftDidBegin() {
    let state = moviePlayer.playbackState
    wasPlayingBeforeTimeShift = (state == .Playing || state == .Interrupted)
    moviePlayer.pause()
  }
  
  final func goToTimeSliderTime() {
    var timeVal = controlsView.customTimeSliderView.value
    moviePlayer.currentPlaybackTime = NSTimeInterval(controlsView.customTimeSliderView.value)
  }
  
  final func goToCustomTimeSliderWithTime(notification:NSNotification) {
    let userInfo:Dictionary<String,NSTimeInterval!> = notification.userInfo as! Dictionary<String,NSTimeInterval!>
    let messageString:NSTimeInterval = userInfo["time"]!
    var playbackTime:NSTimeInterval = messageString
    moviePlayer.currentPlaybackTime = playbackTime
    moviePlayer.play()
  }
  
  final func timeShiftDidEnd() {
    if wasPlayingBeforeTimeShift {
      moviePlayer.play()
    }
  }
  
  // MARK: - Public API
  
  public final func toggleVideoScalingMode() {
    if moviePlayer.scalingMode != .AspectFill {
      moviePlayer.scalingMode = .AspectFill
    } else {
      moviePlayer.scalingMode = .AspectFit
    }
  }
  
  public final func updateBufferInterface() {
    var d:NSTimeInterval = progressBarBufferPercentWithMoviePlayer(moviePlayer)
    var bufferRatio:CGFloat = CGFloat(d)
    var totalDuration:CGFloat = CGFloat(moviePlayer.duration)
    var videoRatio:CGFloat = CGFloat(moviePlayer.currentPlaybackTime)
    controlsView.customTimeSliderView.refreshBufferPercentRatio(bufferRatio: bufferRatio, totalDuration: totalDuration)
    controlsView.customTimeSliderView.refreshVideoProgressPercentRaito(videoRaito: videoRatio, totalDuration: totalDuration)
    controlsView.customTimeSliderView.refreshCustomTimeSliderPercentRatio()
  }
  
  public final func updatePlaybackTimeInterface() {
    updateTimeSlider()
    updateTimeLabel(controlsView.playbackTimeLabel, time: moviePlayer.currentPlaybackTime)
    controlsView.setNeedsLayout()
  }
  
  public final func toggleControlVisibility() {
    if controlsView.controlsHidden {
      controlsView.controlsHidden = false
      resetHideControlsTimer()
    } else {
      controlsView.controlsHidden = true
      hideControlsTimer.invalidate()
    }
  }
  
  public final func shareContent() {
    // TODO: Smarter sharing.
    if let shareCallback = config.shareConfig.shareCallback {
      moviePlayer.pause()
      shareCallback(playerVC: self)
    }
  }
  
  public final func dismiss() {
    moviePlayer.stop()
    if let nc = navigationController {
      nc.popViewControllerAnimated(true)
    } else {
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  // MARK: - Internal Helpers
  
  private func doFirstPlaySetupIfNeeded() {
    if isFirstPlay {
      isFirstPlay = false
      controlsView.activityIndicatorView.stopAnimating()
      updateTimeLabel(controlsView.durationLabel, time: moviePlayer.duration)
      playbackTimeInterfaceUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(
        0.0,
        target: self,
        selector: "updatePlaybackTimeInterface",
        userInfo: nil,
        repeats: true)
      playbackTimeInterfaceUpdateTimer.fire()
      if let firstPlayCallback = config.firstPlayCallback {
        firstPlayCallback(playerVC: self)
      }
    }
  }
  
  private func updateTimeSlider() {
    controlsView.customTimeSliderView.maximumValue = Float(moviePlayer.duration)
    controlsView.customTimeSliderView.value = Float(moviePlayer.currentPlaybackTime)
  }
  
  private func updateTimeLabel(label: UILabel, time: NSTimeInterval) {
    if time.isNaN || time == NSTimeInterval.infinity {
      return
    }
    let hours = UInt(time / 3600)
    let minutes = UInt((time / 60) % 60)
    let seconds = UInt(time % 60)
    var timeLabelText:NSString = NSString(format: "%02lu:%02lu", minutes, seconds) as String
    label.text = checkTimeLabelText(timeLabelText)
    if hours > 0 {
      label.text = NSString(format: "%02lu:%@", hours, label.text!) as String
    }
  }

  private func checkTimeLabelText(text:NSString) -> String {
    if text.length > 8 {
      return String("00:00")
    }
    return String(text)
  }

  // MARK: - MPMovieAccessLogEvent Bitrate Calculate
  
  final func progressBarBufferPercentWithMoviePlayer(player:MPMoviePlayerController) -> NSTimeInterval {
    var playerEvent:MPMovieAccessLogEvent = MPMovieAccessLogEvent()
    if var movieAccessLog:MPMovieAccessLog = moviePlayer.accessLog {
      var arrEvents = movieAccessLog.events
      if arrEvents != nil {
        for i in 0..<arrEvents.count {
          playerEvent = arrEvents[i] as! MPMovieAccessLogEvent
        }
      }
    }
    return playerEvent.segmentsDownloadedDuration
  }
  
  private func resetHideControlsTimer() {
    hideControlsTimer.invalidate()
    hideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(
      2,
      target: self,
      selector: "hideControlsIfPlaying",
      userInfo: nil,
      repeats: false)
  }
  
  private func showOverlayViewController(overlayVC: MovielalaPlayerOverlayViewController) {
    addChildViewController(overlayVC)
    overlayVC.view.clipsToBounds = true
    controlsView.overlayContainerView.addSubview(overlayVC.view)
    overlayVC.didMoveToParentViewController(self)
  }
}

// MARK: - MovielalaPlayerOverlayViewControllerDelegate
extension MovielalaPlayerViewController: MovielalaPlayerOverlayViewControllerDelegate {
  
  func dismissMovielalaPlayerOverlay(overlayVC: MovielalaPlayerOverlayViewController) {
    if overlayVC.view.superview == controlsView.overlayContainerView {
      overlayVC.willMoveToParentViewController(nil)
      overlayVC.view.removeFromSuperview()
      overlayVC.removeFromParentViewController()
    }
  }
}





