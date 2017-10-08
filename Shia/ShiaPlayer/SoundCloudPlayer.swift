//
//  SoundCloudPlayer.swift
//  ShiaPlayer
//
//  Created by Anthony Williams on 10/8/17.
//  Copyright © 2017 Anthony Williams. All rights reserved.
//

import UIKit

public enum SoundCloudPlayerState {
    case ready
    case ended
    case playing
    case paused
    case buffering
    case error
}

public enum SoundCloundPlayerEvent: String {
    case playerReady = "onPlayerReady"
    case mediaStart = "onMediaStart"
    case mediaPlay = "onMediaPlay"
    case mediaPause = "onMediaPause"
    case mediaBuffering = "onMediaBuffering"
    case mediaDoneBuffering = "onMediaDoneBuffering"
    case mediaEnd = "onMediaEnd"
    case mediaSeek = "onMediaSeek"
    case playerError = "onPlayerError"
}

public protocol SoundCloudPlayerDelegate: class {
    func playerReady(_ videoPlayer: SoundCloudPlayerView)
    func playerStateChanged(_ videoPlayer: SoundCloudPlayerView, state: SoundCloudPlayerState)
}

public extension SoundCloudPlayerDelegate {
    func playerReady(_ videoPlayer: SoundCloudPlayerView) {}
    func playerStateChanged(_ videoPlayer: SoundCloudPlayerView, state: SoundCloudPlayerState) {}
}

public class SoundCloudPlayerView: UIView {
    
    fileprivate var webView: UIWebView!
    private var baseUrl = "about:blank"
    
    fileprivate(set) open var ready = false
    fileprivate(set) open var state = SoundCloudPlayerState.ready {
        didSet {
            delegate?.playerStateChanged(self, state: state)
        }
    }
    
    public typealias Parameters = [String: Any]
    
    open var playerParams = Parameters()
    
    public weak var delegate: SoundCloudPlayerDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildWebView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildWebView()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        webView.removeFromSuperview()
        webView.frame = bounds
        addSubview(webView)
    }
}

extension SoundCloudPlayerView: UIWebViewDelegate {
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}

fileprivate extension WebViewInitialization {
    fileprivate func buildWebView() {
        webView = UIWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = false
        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
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
        return Bundle(for: SoundCloudPlayerView.self).path(forResource: "SoundCloudPlayer", ofType: "html") ?? nil
    }
    
    fileprivate func loadWebView() {
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
            "color": "009898",
            "theme_color": "1e1e1e",
            "buying": false,
            "sharing": true,
            "download": false,
            "auto_play": false,
            "show_comments": false,
            "enable_api": true,
            "show_user": false,
            "show_playcount": false,
        ]
    }
    
    fileprivate func callbacks() -> Parameters {
        return [
            "onPlayerReady": "onPlayerReady" as Any,
            "onMediaStart": "onMediaStart" as Any,
            "onMediaPlay": "onMediaPlay" as Any,
            "onMediaPause": "onMediaPause" as Any,
            "onMediaBuffering": "onMediaBuffering" as Any,
            "onMediaDoneBuffering": "onMediaDoneBuffering" as Any,
            "onMediaEnd": "onMediaEnd" as Any,
            "onMediaSeek": "onMediaSeek" as Any,
            "onPlayerError": "onPlayerError" as Any
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

fileprivate extension EventHandling {
    func handle(event url: URL) {        
        if let host = url.host, let event = SoundCloundPlayerEvent(rawValue: host) {
            switch event {
            case .playerReady:
                ready = true
                state = .ready
                delegate?.playerReady(self)
                break
            case .mediaStart:
                state = .playing
                break
            case .mediaPlay:
                state = .playing
                break
            case .mediaPause:
                state = .paused
                break
            case .mediaBuffering:
                state = .buffering
                break
            case .mediaDoneBuffering:
                state = .ready
                break
            case .mediaEnd:
                state = .ended
                break
            case .mediaSeek:
                break
            case .playerError:
                state = .error
                break
            }
        }
    }
}


private typealias WebViewInitialization = SoundCloudPlayerView
private typealias PlayerSetup = SoundCloudPlayerView
private typealias ParametersAndDefaults = SoundCloudPlayerView
private typealias EventHandling = SoundCloudPlayerView
