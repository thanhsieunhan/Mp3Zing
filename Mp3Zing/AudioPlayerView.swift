//
//  AudioPlayerView.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/8/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerView: UIViewController {
    
    let audioPlayer = AudioPlayer.sharedInstance
    @IBOutlet weak var btn_Play: UIButton!
    @IBOutlet weak var lbl_CurrentTime: UILabel!
    @IBOutlet weak var lbl_TotalTime: UILabel!
    @IBOutlet weak var sld_Duration: UISlider!
    //    @IBOutlet weak var sld_Volume: UISlider!
    //    @IBOutlet weak var lbl_title: UILabel!
    
    
    var checkAddObserverAudio = false
    override func viewDidLoad() {
        super.viewDidLoad()
        addThumbImgForSlider()
        btn_Play.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setupObserveAudio), name: "setupObserveAudio", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupObserveAudio()
        
    }
    
    func changeInfoView(){
        changeInfoSong()
        addThumbImgForButton()
        
    }
    
    func addThumbImgForSlider(){
        sld_Duration.setThumbImage(UIImage(named: "duration"), forState: UIControlState())
        
    }
    
    func changeInfoSong(){
    }
    
    func addThumbImgForButton(){
        if audioPlayer.playing == true {
            btn_Play.setBackgroundImage(UIImage(named: "pause.png"), forState: UIControlState())
        } else {
            btn_Play.setBackgroundImage(UIImage(named: "play.png"), forState: UIControlState())
        }
    }
    
    func setupObserveAudio(){
        if audioPlayer.playing && !checkAddObserverAudio{
            checkAddObserverAudio = true
            btn_Play.enabled = true
            let timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
            
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidReachend), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
    }
    
    func playerItemDidReachend(notification : NSNotification){
        if (audioPlayer.repeating) {
            audioPlayer.player.seekToTime(kCMTimeZero)
            audioPlayer.player.play()
        }
        
    }
    
    func timeUpdate(){
        //CMTime time, tim
//        print(audioPlayer.player.currentItem?.duration.value)
        audioPlayer.duration = Float((audioPlayer.player.currentItem?.duration.value)!)/Float((audioPlayer.player.currentItem?.duration.timescale)!)
        
        audioPlayer.currentTime = Float(audioPlayer.player.currentTime().value) / Float(audioPlayer.player.currentTime().timescale)
        
        let m = Int(floor(audioPlayer.currentTime/60))
        let s = Int(round(audioPlayer.currentTime - Float(m)*60))
        
        if audioPlayer.duration > 0 {
            let mduration = Int(floor(audioPlayer.duration/60))
            let sduration = Int(round(audioPlayer.duration - Float(mduration)*60))
            
            let currentTime = String(format: "%02d", m) + ":" + String(format: "%02d", s)
            let totalTime = String(format: "%02d", mduration) + ":" + String(format: "%02d", sduration)
            let valueSlider = Float(self.audioPlayer.currentTime/self.audioPlayer.duration)
            
            
            self.lbl_CurrentTime.text = currentTime
            self.lbl_TotalTime.text = totalTime
            self.sld_Duration.value = valueSlider
            
        }
    }
    
    var x = 0
    @IBAction func action_repeatSong(sender: UIButton) {
        if x == 0 {
            sender.setImage(UIImage(named: "repeat_active"), forState: UIControlState())
            x = 1
        } else {
            
            sender.setImage(UIImage(named: "repeat_deactive"), forState: UIControlState())
            x = 0
        }
    }
    
    @IBAction func action_PlayPause(sender: AnyObject){
        
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
    }
    
    @IBAction func sld_Duration(sender: UISlider){
        audioPlayer.action_sld_Duration(sender.value)
    }
}
