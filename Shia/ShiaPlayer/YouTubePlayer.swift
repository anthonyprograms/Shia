//
//  YouTubePlayer.swift
//  Shia
//
//  Created by Anthony Williams on 10/8/17.
//  Copyright © 2017 Anthony Williams. All rights reserved.
//

import UIKit

public enum YouTubePlayerState: String {
    case ready = "-1"
    case ended = "0"
    case playing = "1"
    case paused = "2"
    case buffering = "3"
    case queued = "4"
}

public enum YouTubePlayerEvents: String {
    case youtubeIframeAPIReady = "onYouTubeIframeAPIReady"
    case ready = "onReady"
    case stateChange = "onStateChange"
    case playbackQualityChange = "onPlaybackQualityChange"
}

public enum YoutubePlaybackQuality: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case hd720 = "hd720"
    case hd1080 = "hd1080"
    case highResolution = "highres"
}

public protocol YouTubePlayerDelegate: class {
    func playerReady(_ videoPlayer: YouTubePlayerView)
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, state: YouTubePlayerState)
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, quality: YoutubePlaybackQuality)
}

public extension YouTubePlayerDelegate {
    func playerReady(_ videoPlayer: YouTubePlayerView) {}
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, state: YouTubePlayerState) {}
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, quality: YoutubePlaybackQuality) {}
}

open class YouTubePlayerView: UIView {
    
    public typealias Parameters = [String: Any]
    public var baseUrl = "about:blank"
    
    fileprivate var webView: UIWebView!
    
    fileprivate(set) open var ready = false
    fileprivate(set) open var state = YouTubePlayerState.ready
    fileprivate(set) open var quality = YoutubePlaybackQuality.small
    
    open var playerVars = Parameters()
    
    open weak var delegate: YouTubePlayerDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildWebView(playerVars)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildWebView(playerVars)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        webView.removeFromSuperview()
        webView.frame = bounds
        addSubview(webView)
    }
}

fileprivate extension WebViewInitialization {
    fileprivate func buildWebView(_ parameters: Parameters) {
        webView = UIWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = false
        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
    }
}

extension LoadPlayer {
    open func loadViewUrl(_ videoUrl: URL) {
        if let videoId = videoId(from: videoUrl) {
            loadViewId(videoId)
        }
    }
    
    open func loadViewId(_ videoId: String) {
        var parameters = Parameters()
        parameters["videoId"] = videoId as Any?
        loadWebView(with: parameters)
    }
}

fileprivate extension Helpers {
    fileprivate func videoId(from youtubeUrl: URL) -> String? {
        if youtubeUrl.pathComponents.count > 1 && (youtubeUrl.host?.hasSuffix("youtu.be"))! {
            return youtubeUrl.pathComponents[1]
        } else if youtubeUrl.pathComponents.contains("embed") {
            return youtubeUrl.pathComponents.last
        }
        return youtubeUrl.queryStringComponents()["v"] as? String
    }
    
    fileprivate func evaluate(command: String) -> String? {
        let fullCommand = "player." + command + ";"
        return webView.stringByEvaluatingJavaScript(from: fullCommand)
    }
}

extension PlayerControls {
    open func mute() {
        _ = evaluate(command: "mute()")
    }
    
    open func unMute() {
        _ = evaluate(command: "unMute()")
    }
    
    open func play() {
        _ = evaluate(command: "playVideo()")
    }
    
    open func pause() {
        _ = evaluate(command: "pauseVideo()")
    }
    
    open func stop() {
        _ = evaluate(command: "stopVideo()")
    }
    
    open func clear() {
        _ = evaluate(command: "clearVideo()")
    }
    
    open func seek(to seconds: Float, seekAhead: Bool) {
        _ = evaluate(command: "seekTo(\(seconds), \(seekAhead))")
    }
    
    open func duration() -> String? {
        return evaluate(command: "getDuration()")
    }
    
    open func currentTime() -> String? {
        return evaluate(command: "getCurrentTime()")
    }
}

fileprivate extension PlayerSetup {
    fileprivate func htmlString(with filePath: String) -> String? {
        do {
            let htmlString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
            return htmlString as String
        } catch {
            print("File not found for path")
            return nil
        }
    }
    
    fileprivate func htmlPath() -> String? {
        return Bundle(for: YouTubePlayerView.self).path(forResource: "YouTubePlayer", ofType: "html") ?? nil
    }
    
    fileprivate func loadWebView(with parameters: Parameters) {
        guard let path = htmlPath(),
            let rawString: String = htmlString(with: path),
            let jsonParameters = serializedJson(parameters as Any)  else { return }
        
        let HTMLString = rawString.replacingOccurrences(of: "%@", with: jsonParameters)
        webView.loadHTMLString(HTMLString, baseURL: URL(string: baseUrl))
    }
}

fileprivate extension ParametersAndDefaults {
    fileprivate func parameters() -> Parameters {
        return [
            "height": "100%" as Any,
            "width": "100%" as Any,
            "events": callbacks() as Any,
            "playerVars":  playerVars as Any
        ]
    }
    
    fileprivate func callbacks() -> Parameters {
        return [
            "onReady": "onReady" as Any,
            "onStateChange": "onStateChange" as Any,
            "onPlaybackQualityChange": "onPlaybackQualityChange" as Any,
            "onError": "onPlayerError" as Any
        ]
    }
    
    fileprivate func serializedJson(_ object: Any) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
        } catch let error {
            print("Error parsing json: \(error)")
            return nil
        }
    }
}

fileprivate extension JSEventHandling {
    func handle(event url: URL) {
        guard let data: String = url.queryStringComponents()["data"] as? String else { return }
        
        if let host = url.host, let event = YouTubePlayerEvents(rawValue: host) {
            switch event {
            case .youtubeIframeAPIReady:
                ready = true
                break
            case .ready:
                delegate?.playerReady(self)
                break
            case .stateChange:
                if let newState = YouTubePlayerState(rawValue: data) {
                    state = newState
                    delegate?.playerStateChanged(self, state: newState)
                }
                break
            case .playbackQualityChange:
                if let newQuality = YoutubePlaybackQuality(rawValue: data) {
                    quality = newQuality
                    delegate?.playerQualityChanged(self, quality: newQuality)
                }
                break
            }
        }
    }
}

extension YouTubePlayerView: UIWebViewDelegate {
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url

        if let url = url, url.scheme == "ytplayer" {
            handle(event: url)
            
        }
        
        return true
    }
}

private typealias WebViewInitialization = YouTubePlayerView
private typealias LoadPlayer = YouTubePlayerView
private typealias PlayerControls = YouTubePlayerView
private typealias Helpers = YouTubePlayerView
private typealias PlayerSetup = YouTubePlayerView
private typealias ParametersAndDefaults = YouTubePlayerView
private typealias JSEventHandling = YouTubePlayerView
