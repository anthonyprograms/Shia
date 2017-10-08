//
//  ViewController.swift
//  Shia
//
//  Created by Anthony Williams on 10/8/17.
//  Copyright © 2017 Anthony Williams. All rights reserved.
//

import UIKit
import ShiaPlayer

class ViewController: UIViewController {

    lazy var youtubePlayer: YouTubePlayerView = {
        let youtubePlayer = YouTubePlayerView()
        youtubePlayer.translatesAutoresizingMaskIntoConstraints = false
        return youtubePlayer
    }()
    
    lazy var soundcloudPlayer: SoundCloudPlayerView = {
        let soundcloudPlayer = SoundCloudPlayerView()
        soundcloudPlayer.translatesAutoresizingMaskIntoConstraints = false
        return soundcloudPlayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(youtubePlayer)
        view.addSubview(soundcloudPlayer)
        youtubeConstraints()
        soundcloudConstraints()
        
        youtubePlayer.loadViewId("Tj7hRjl3sAY")
    }

    func youtubeConstraints() {
        let left = NSLayoutConstraint(item: youtubePlayer, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: youtubePlayer, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: youtubePlayer, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: youtubePlayer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraints([left, top, right, bottom])
    }
    
    func soundcloudConstraints() {
        let left = NSLayoutConstraint(item: soundcloudPlayer, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: soundcloudPlayer, attribute: .top, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: soundcloudPlayer, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: soundcloudPlayer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([left, top, right, bottom])
    }
}

