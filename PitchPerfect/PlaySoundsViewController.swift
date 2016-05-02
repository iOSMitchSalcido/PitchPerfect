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
    
    // ref to AVAudio classes used to play audio
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    
    // enum for sounds. Also used to mask which effect button was pressed
    enum SoundEffect: Int {
        case Snail = 0, Rabbit, Chipmunk, Vader, Echo, Reverb
    }
    
    // enum for play state. Used when setting state of buttons in view
    enum PlayState {
        case Ready, NotReady, Broken
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // test for valid audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
            configurePlayUIState(.Ready)
        }
        catch {
            // bad file. Player is "broken"..disable all buttons
            configurePlayUIState(.Broken)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop playing when view disappears
        stopAudioPlayback()
    }
    
    // function to play audio
    func playAudio(effect: SoundEffect) {
        
        // place buttons in not ready state
        configurePlayUIState(.NotReady)
        
        // configure AVAudio classes
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioEngine.attachNode(audioPlayerNode)
        
        // declare AVAudioNode. Will be assigned in switch statement
        var audioNode: AVAudioNode!
        
        // create sound effect
        switch effect {
        case .Snail:
            let node = AVAudioUnitTimePitch()
            node.rate = 0.5
            audioNode = node
        case .Rabbit:
            let node = AVAudioUnitTimePitch()
            node.rate = 1.5
            audioNode = node
        case .Chipmunk:
            let node = AVAudioUnitTimePitch()
            node.pitch = 1000
            audioNode = node
        case .Vader:
            let node = AVAudioUnitTimePitch()
            node.pitch = -1000
            audioNode = node
        case .Echo:
            let node = AVAudioUnitDistortion()
            node.loadFactoryPreset(.MultiEcho1)
            audioNode = node
        case .Reverb:
            let node = AVAudioUnitReverb()
            node.loadFactoryPreset(.Cathedral)
            node.wetDryMix = 50
            audioNode = node
        }
        
        // configure engine and player, attach/connect nodes
        audioEngine.attachNode(audioNode)
        audioEngine.connect(audioPlayerNode, to: audioNode, format: nil)
        audioEngine.connect(audioNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) { () -> Void in
            
            // place UI update on main thread
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.configurePlayUIState(.Ready)
            }
        }
        
        // play audio
        do {
            try audioEngine.start()
            audioPlayerNode.play()
        }
        catch {
            print("unable to play audio")
        }
    }
    
    // action for sound effect buttons
    @IBAction func playSoundForButton(sender: UIButton) {
        
        // use button tag to create a SoundEffect enum
        switch(SoundEffect(rawValue: sender.tag)!) {
        case .Snail:
            playAudio(.Snail)
        case .Rabbit:
            playAudio(.Rabbit)
        case .Chipmunk:
            playAudio(.Chipmunk)
        case .Vader:
            playAudio(.Vader)
        case .Echo:
            playAudio(.Echo)
        case .Reverb:
            playAudio(.Reverb)
        }
    }
    
    // action for stop button
    @IBAction func stopButtonPressed(sender: AnyObject) {
        
        // stop audio
        stopAudioPlayback()
        
        // update UI to ready state
        configurePlayUIState(.Ready)
    }
    
    // helper function, stop audio playback
    func stopAudioPlayback() {
        
        // verify audioPlayerNode, stop
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        // verify audioEngine, stop and reset
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // helper function to enable/disable buttons in view
    func configurePlayUIState(state: PlayState) {
        
        switch state {
        case .Ready:
            snailButton.enabled = true
            chipmunkButton.enabled = true
            rabbitButton.enabled = true
            vaderButton.enabled = true
            echoButton.enabled = true
            reverbButton.enabled = true
            stopButton.enabled = false
        case .NotReady:
            snailButton.enabled = false
            chipmunkButton.enabled = false
            rabbitButton.enabled = false
            vaderButton.enabled = false
            echoButton.enabled = false
            reverbButton.enabled = false
            stopButton.enabled = true
        case .Broken:
            configurePlayUIState(.NotReady)
            stopButton.enabled = false
        }
    }
}
