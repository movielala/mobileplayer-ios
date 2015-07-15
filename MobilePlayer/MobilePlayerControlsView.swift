//
//  MobilePlayerControlsView.swift
//  MobilePlayer
//
//  Created by Baris Sencan on 12/02/15.
//  Copyright (c) 2015 MovieLaLa. All rights reserved.
//

import Foundation
import MediaPlayer

final class MobilePlayerControlsView: UIView {
  var controlsHidden: Bool = false {
    // Hide/show controls animated.
    didSet(oldValue) {
      if oldValue != controlsHidden {
        UIView.animateWithDuration(0.0, animations: {
          self.layoutSubviews()
        })
      }
    }
  }
  var volumeView = VolumeControlView(frame: CGRectZero)
  var volumeButton = UIButton(frame: CGRectZero)
  var customTimeSliderView = CustomTimeSliderView(frame: CGRectZero)
  let headerView = UIView(frame: CGRectZero)
  let backgroundImageView = UIImageView(frame: CGRectZero)
  let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
  let overlayContainerView = UIView(frame: CGRectZero)
  let footerView = UIView(frame: CGRectZero)
  let closeButton = UIButton(frame: CGRectZero)
  let titleLabel = UILabel(frame: CGRectZero)
  let shareButton = UIButton(frame: CGRectZero)
  let playButton = UIButton(frame: CGRectZero)
  let playbackTimeLabel = UILabel(frame: CGRectZero)
  let durationLabel = UILabel(frame: CGRectZero)
  private let config: MobilePlayerConfig

  init(config: MobilePlayerConfig) {
    self.config = config
    super.init(frame: CGRectZero)
    initializeHeaderViews()
    initializeOverlayViews()
    initializeFooterViews()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("storyboards are incompatible with truth and beauty")
  }

  private func initializeHeaderViews() {
    headerView.backgroundColor = config.headerBackgroundColor
    addSubview(headerView)
    closeButton.setImage(config.closeButtonConfig.imageName, forState: .Normal)
    closeButton.tintColor = config.closeButtonConfig.tintColor
    closeButton.backgroundColor = config.closeButtonConfig.backgroundColor
    headerView.addSubview(closeButton)
    titleLabel.font = config.titleConfig.textFont
    titleLabel.textColor = config.titleConfig.textColor
    titleLabel.backgroundColor = config.titleConfig.backgroundColor
    headerView.addSubview(titleLabel)
    shareButton.setImage(config.shareButtonConfig.imageName, forState: .Normal)
    shareButton.tintColor = config.shareButtonConfig.tintColor
    shareButton.backgroundColor = config.shareButtonConfig.backgroundColor
    headerView.addSubview(shareButton)
  }

  private func initializeOverlayViews() {
    addSubview(backgroundImageView)
    activityIndicatorView.hidesWhenStopped = true
    addSubview(activityIndicatorView)
    activityIndicatorView.startAnimating()
    overlayContainerView.backgroundColor = UIColor.clearColor()
    overlayContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(overlayContainerView)
  }

  private func initializeFooterViews() {
    footerView.backgroundColor = config.controlbarConfig.backgroundColor
    playButton.setImage(config.controlbarConfig.playButtonImage, forState: .Normal)
    playButton.tintColor = config.controlbarConfig.playButtonTintColor
    playButton.backgroundColor = config.controlbarConfig.playButtonBackgroundColor
    playbackTimeLabel.text = "-:-"
    playbackTimeLabel.textAlignment = .Center
    playbackTimeLabel.font = config.controlbarConfig.timeTextFont
    playbackTimeLabel.textColor = config.controlbarConfig.timeTextColor
    playbackTimeLabel.backgroundColor = config.controlbarConfig.timeBackgroundColor
    durationLabel.text = "-:-"
    durationLabel.textAlignment = .Center
    durationLabel.font = config.controlbarConfig.durationTextFont
    durationLabel.textColor = config.controlbarConfig.durationTextColor
    durationLabel.backgroundColor = config.controlbarConfig.durationBackgroundColor
    customTimeSliderView.backgroundColor = config.controlbarConfig.timeSliderBackgroundColor
    customTimeSliderView.railView.backgroundColor = config.controlbarConfig.timeSliderRailTintColor
    customTimeSliderView.bufferView.backgroundColor =
      config.controlbarConfig.timeSliderBufferTintColor
    customTimeSliderView.progressView.backgroundColor =
      config.controlbarConfig.timeSliderProgressTintColor
    customTimeSliderView.thumbView.backgroundColor =
      config.controlbarConfig.timeSliderThumbTintColor
    volumeButton.setImage(config.controlbarConfig.volumeButtonImage, forState: .Normal)
    volumeButton.backgroundColor = config.controlbarConfig.volumeBackgroundColor
    volumeButton.tintColor = config.controlbarConfig.volumeTintColor
    volumeView.hidden = true
    volumeView.increaseVolumeImage.tintColor = config.controlbarConfig.volumeTintColor
    volumeView.reduceVolumeImage.tintColor = config.controlbarConfig.volumeTintColor
    volumeView.backgroundColor = config.controlbarConfig.backgroundColor
    addSubview(volumeView)
    if let components = config.controlbarConfig.getComponents() as [String]? {
      if components.count > 0 {
        addSubview(footerView)
        var checkValue = contains(components, "playButton")
        if checkValue {
          footerView.addSubview(playButton)
        }
        checkValue = contains(components, "timeLabel")
        if checkValue {
          footerView.addSubview(playbackTimeLabel)
        }
        checkValue = contains(components, "durationLabel")
        if checkValue {
          footerView.addSubview(durationLabel)
        }
        checkValue = contains(components, "timeSlider")
        if checkValue {
          footerView.addSubview(customTimeSliderView)
        }
        checkValue = contains(components, "volumeSlider")
        if checkValue {
          footerView.addSubview(volumeButton)
        }
      }
    }
  }

  override func layoutSubviews() {
    let size = bounds.size
    backgroundImageView.sizeToFit()
    backgroundImageView.center = overlayContainerView.center
    sendSubviewToBack(backgroundImageView)
    headerView.frame = CGRect(
      x: 0,
      y: controlsHidden ? -config.headerHeight : 0,
      width: size.width,
      height: config.headerHeight)
    headerView.alpha = controlsHidden ? 0 : 1
    overlayContainerView.frame = CGRect(
      x: 0,
      y: controlsHidden ? 0 : config.headerHeight,
      width: size.width,
      height: controlsHidden ? size.height: size.height - config.headerHeight - config.footerHeight)
    if let arrOverlays = overlayContainerView.subviews as? [UIView] {
      for overlayView in arrOverlays {
        overlayView.frame = overlayContainerView.bounds
      }
    }
    footerView.frame = CGRect(
      x: 0,
      y: size.height - (controlsHidden ? 0 : config.footerHeight),
      width: size.width,
      height: config.footerHeight)
    footerView.alpha = controlsHidden ? 0 : 1
    activityIndicatorView.sizeToFit()
    activityIndicatorView.center = overlayContainerView.center
    layoutHeaderSubviews()
    layoutFooterSubviews()
    volumeView.frame = CGRect(
      x: volumeButton.frame.origin.x,
      y: footerView.frame.origin.y - 155.0,
      width: 35.0,
      height: 150.0)
  }

  func toggleVolumeView() {
    volumeView.hidden = !volumeView.hidden
    layoutSubviews()
  }

  private func layoutHeaderSubviews() {
    let size = headerView.bounds.size
    closeButton.sizeToFit()
    let closeButtonSize = CGSize(
      width: config.headerHeight * closeButton.bounds.aspectRatio + 16,
      height: config.headerHeight)
    closeButton.frame = CGRect(origin: CGPointZero, size: closeButtonSize)
    shareButton.sizeToFit()
    let shareButtonSize = CGSize(
      width: config.headerHeight * shareButton.bounds.aspectRatio + 16,
      height: config.headerHeight)
    shareButton.frame = CGRect(
      origin: CGPoint(x: size.width - shareButtonSize.width, y: 0),
      size: shareButtonSize)
    titleLabel.frame = CGRect(
      x: closeButton.bounds.size.width,
      y: 0,
      width: size.width - closeButton.bounds.width - shareButton.bounds.width,
      height: size.height)
  }

  private func layoutFooterSubviews() {
    let size = footerView.bounds.size
    playButton.sizeToFit()
    let playButtonSize = CGSize(
      width: config.footerHeight * playButton.bounds.aspectRatio + 16,
      height: config.footerHeight)
    playButton.frame = CGRect(origin: CGPointZero, size: playButtonSize)
    playbackTimeLabel.sizeToFit()
    let playbackTimeLabelSize = CGSize(
      width: playbackTimeLabel.bounds.width + 16,
      height: config.footerHeight)
    playbackTimeLabel.frame = CGRect(
      origin: CGPoint(x: playButton.bounds.width, y: 0),
      size: playbackTimeLabelSize)
    customTimeSliderView.sizeToFit()
    let customTimeSliderSize = CGSize(
      width: size.width - playButton.bounds.width -
        playbackTimeLabel.bounds.width -
        durationLabel.bounds.width - volumeButton.bounds.width - 10,
      height: config.footerHeight)
    customTimeSliderView.frame = CGRect(
      origin: CGPoint(x: playButton.bounds.width + playbackTimeLabel.bounds.width + 10, y: 0),
      size: customTimeSliderSize)
    self.customTimeSliderView.timeSlider.sizeToFit()
    let timeSliderSize = CGSize(
      width: size.width - playButton.bounds.width -
        playbackTimeLabel.bounds.width - durationLabel.bounds.width,
      height: config.footerHeight)
    self.customTimeSliderView.timeSlider.frame = CGRect(
      origin: CGPoint(x: playButton.bounds.width + playbackTimeLabel.bounds.width, y: 0),
      size: timeSliderSize)
    durationLabel.sizeToFit()
    let durationLabelSize = CGSize(
      width: durationLabel.bounds.width + 16,
      height: config.footerHeight)
    durationLabel.frame = CGRect(
      origin: CGPoint(
        x: playButton.bounds.width +
          playbackTimeLabel.bounds.width +
          customTimeSliderView.bounds.width + 10,
        y: 0),
      size: durationLabelSize)
    volumeButton.sizeToFit()
    let volumeButtonSize = CGSize(
      width: config.footerHeight * volumeButton.bounds.aspectRatio + 16,
      height: config.footerHeight)
    volumeButton.frame = CGRect(
      origin: CGPoint(
        x: playButton.bounds.width +
          playbackTimeLabel.bounds.width +
          customTimeSliderView.bounds.width +
          durationLabel.bounds.width + 10,
        y: 0),
      size: volumeButtonSize)
  }
}
