//
//  ViewController.swift
//  PIPDemo
//
//  Created by lavanille on 2023/4/6.
//

import UIKit
import AVKit
import WebKit
import IJKMediaFrameworkWithSSL
import CoreVideo

// 视频资源测试：https://images.apple.com/media/cn/apple-events/2016/5102cb6c_73fd_4209_960a_6201fdb29e6e/keynote/apple-event-keynote-tft-cn-20160908_1536x640h.mp4

class ViewController: UIViewController, WKNavigationDelegate, AVPictureInPictureControllerDelegate, AVPictureInPictureSampleBufferPlaybackDelegate {
    
    var player:IJKFFMoviePlayerController!
    
    var timer: CADisplayLink?
    
    var fetcher = PixelBufferFetcher()
    
    var displayView: UIView = UIView()
    
    var displayLayer: AVSampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    
    var pipCtr: AVPictureInPictureController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player.prepareToPlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.shutdown()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mediaIsPreparedToPlayDidChange),
            name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange,
            object: nil
        )
        
        view.addSubview(displayView)
        displayView.frame = view.frame
        displayView.backgroundColor = UIColor.red
        displayView.layer.addSublayer(displayLayer)
        displayLayer.frame = view.frame
        displayLayer.videoGravity = .resizeAspect

        let url = NSURL(string: "rtmp://stream-ali1.csslcloud.net/src/F9614DF271B497DB9C33DC5901307461")
        let options = IJKFFOptions.byDefault()
        player = IJKFFMoviePlayerController(contentURL: url as URL?, with: options)
        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue |
        UIView.AutoresizingMask.flexibleHeight.rawValue
        player.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
        
        if AVPictureInPictureController.isPictureInPictureSupported() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true, options: [])
            } catch {
                print("AVAudioSession发生错误")
            }
            pipCtr = AVPictureInPictureController(contentSource: .init(sampleBufferDisplayLayer: displayLayer, playbackDelegate: self))
            pipCtr?.delegate = self
        }
        
        if pipCtr?.isPictureInPictureActive == true {
            pipCtr?.stopPictureInPicture()
        } else {
            pipCtr?.startPictureInPicture()
        }

        player.view.frame = self.view.bounds
        player.scalingMode = .aspectFit
        player.shouldAutoplay = true //开启自动播放
        
    }
    
    @objc func fetchSampleBuffer() {
        fetcher.fetchPixelBuffer(by: player, sampleBufferLayer: displayLayer)
    }
    
    @objc func mediaIsPreparedToPlayDidChange() {
        self.timer = CADisplayLink(target: self, selector: #selector(self.fetchSampleBuffer))
        self.timer?.add(to: RunLoop.main, forMode: .default)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        
    }
    
    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRangeMake(start: .zero, duration: CMTimeMake(value: 10 * 1000, timescale: 1000))
    }
    
    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        return false
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
        
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime) async {
        
    }
}
