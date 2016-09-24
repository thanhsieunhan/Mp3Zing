//
//  AudioPlayer.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/8/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer: NSObject {
    
    class var sharedInstance: AudioPlayer {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AudioPlayer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = AudioPlayer()
        }
        return Static.instance!
    }
    
    var pathString = ""
    var repeating = false
    var playing = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = ""
    var player = AVPlayer()
    var artistName = ""
    
    var lyric = [Lyric]()
    
    func setupAudio(){
        var url = NSURL()
        if let checkURL = NSURL(string: pathString) {
            url = checkURL
        } else {
            url = NSURL(fileURLWithPath: pathString)
        }
        
        let playerItem = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.volume = 0.5
        player.play()
        playing = true
        repeating = true
        
    }
    
    // Action
    
    func repeateSong(repeateSong: Bool){
        if repeating == true {
            repeating = true
        } else {
            repeating = false
        }
    }
    
    func action_PlayPause(){
        if playing == false {
            player.play()
            playing = true
        } else {
            player.pause()
            playing = false
        }
    }
    
    func action_sld_Duration(value: Float){
        let timeToSeek = value * duration
        let time = CMTimeMake(Int64(timeToSeek), 1)
        player.seekToTime(time)
    }
    
    func action_sld_Volume(value: Float){
        player.volume = value
    }
    
}
