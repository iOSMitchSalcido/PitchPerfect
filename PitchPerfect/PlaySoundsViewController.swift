//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Online Training on 4/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About PlaySoundsViewController.swift:
 Handle audio play back. Using audio retrieved using recordedAudioURL, audio is played by by pressing one
 of the effects buttons.
 */

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    // ref to buttons and labels
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: NSTimer!
    
    enum ButtonType: Int {case Slow = 0, Fast, Chipmunk, Vader, Echo, Reverb}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI(.NotPlaying)
    }
    
    @IBAction func playSoundForButton(sender: UIButton) {
        
        switch(ButtonType(rawValue: sender.tag)!) {
        case .Slow:
            playSound(rate: 0.5)
        case .Fast:
            playSound(rate: 1.5)
        case .Chipmunk:
            playSound(pitch: 1000)
        case .Vader:
            playSound(pitch: -1000)
        case .Echo:
            playSound(echo: true)
        case .Reverb:
            playSound(reverb: true)
        }
    }
    
    @IBAction func stopButtonPressed(sender: AnyObject) {
        stopAudio()
    }
}
