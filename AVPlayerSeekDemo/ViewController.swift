//
//  ViewController.swift
//  AVPlayerSeekDemo
//
//  Created by Eric Richardson on 8/11/15.
//  Copyright © 2015 Eric Richardson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var playhead: UILabel!
    @IBOutlet weak var lastTarget: UILabel!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var back30: UIButton!
    @IBOutlet weak var jumpLive: UIButton!
    
    @IBOutlet weak var autoPlay: UISwitch!
    
    let _dateF = NSDateFormatter()
    
    let _player:AVPlayer = AVPlayer(URL: NSURL(string:"http://streammachine-test.scprdev.org:8020/sg/test.m3u8")!)
    var _observer:AVObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add our player observer
        self._observer = AVObserver(player: self._player) { (status,msg,object) in
            switch status {
            case .PlayerFailed:
                print("Player failed. We don't have logic to recover from this.")
            case .ItemFailed:
                print("Item failed. We don't have logic to recover from this.")
            case .Stalled:
                print("Playback stalled at \(self._player.currentItem!.currentDate())")
            case .AccessLog:
                print("New Access log")
            case .ErrorLog:
                print("New Error log")
            case .Playing:
                print("Status: Playing")
            case .Paused:
                print("Status: Paused")
            case .LikelyToKeepUp:
                print("playback should keep up")
            case .UnlikelyToKeepUp:
                print("playback unlikely to keep up")
            case .TimeJump:
                print("Player reports that time jumped.")
            default:
                true
            }
        }
        
        self.playPause.addTarget(self, action: "playPauseTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.back30.addTarget(self, action: "backTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.jumpLive.addTarget(self, action: "liveTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self._dateF.dateFormat = "YYYY-MM-dd hh:mm:ss"
        
        self._player.addPeriodicTimeObserverForInterval(CMTimeMake(1,1), queue: nil,
            usingBlock: {(time:CMTime) in
                let curDate = self._player.currentItem!.currentDate()
                
                if curDate != nil {
                    self._updateTimeDisplay(curDate)
                }
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------
    
    func playPauseTapped(sender:UIButton!) {
        if self._player.rate > 0 {
            self._player.pause()
        } else {
            self._player.play()
        }
    }
    
    //----------
    
    func backTapped(sender:UIButton!) {
        let curDate = self._player.currentItem!.currentDate()
        
        let offsetSecs:Double = -1 * 30 * 60
        
        let targetDate = curDate?.dateByAddingTimeInterval(offsetSecs)
        
        print("Seeking to \(targetDate)")
        self._updateTargetDisplay(targetDate)
        
        let curTime = self._player.currentItem!.currentTime()
        let targetTime = CMTimeAdd(curTime,CMTimeMakeWithSeconds(offsetSecs, 1))

        //self._player.seekToDate(targetDate!) {(finished) in
        self._player.seekToTime(targetTime) {(finished) in
            print("Seek completed. Landed at \(self._player.currentItem!.currentDate())")
            
            if self._player.rate != 1.0 && self.autoPlay.on {
                self._player.play()
            }
        }
    }
    
    //----------
    
    func liveTapped(sender:UIButton!) {
        self._updateTargetDisplay(nil)
        self._player.currentItem!.seekToTime(kCMTimePositiveInfinity) { finished in
            print("Seek to Live landed at \(self._player.currentItem!.currentDate())")
        }
    }
    
    //----------
    
    func _updateTimeDisplay(date:NSDate?) -> Void {
        var val:String
        
        if date != nil {
            val = self._dateF.stringFromDate(date!)
        } else {
            val = "---"
        }
        
        self.playhead.text = val
    }
    
    //----------
    
    func _updateTargetDisplay(date:NSDate?) -> Void {
        var val:String
        
        if date != nil {
            val = self._dateF.stringFromDate(date!)
        } else {
            val = "---"
        }
        
        self.lastTarget.text = val
    }


}

