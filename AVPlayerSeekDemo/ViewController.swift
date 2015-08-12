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
    
    let _dateF = NSDateFormatter()
    
    let _player:AVPlayer = AVPlayer(URL: NSURL(string:"http://streammachine-test.scprdev.org:8020/sg/test.m3u8")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

        self._player.seekToTime(targetTime) {(finished) in
            print("Seek to time completed. Landed at \(self._player.currentItem!.currentDate())")
        }
//        self._player.seekToDate(targetDate!) {(finished) in
//            print("Seek completed. Landed at \(self._player.currentItem!.currentDate())")
//        }
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

