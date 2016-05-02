//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Online Training on 4/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About RecordSoundsViewController.swift:
 Handle recording audio thru iOS device. Provide "record" button to initiate recording, and "stop" button
 to cease recording. Also show label to indicate recording status
 */

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // constants for recording label states
    let READY_TO_RECORD = "Tap Mic to Record"
    let RECORDING_IN_PROGRESS = "Recording in Progress"
    let BAD_RECORDING_MESSAGE = "Bad Recording. Retry"
    
    // ref to buttons and labels
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var elapsedTimeTitleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playLabel: UILabel!
    
    // elapsed time recording length
    var elapsedTime: Int = 0    // counts in tenths of a second
    var timer: NSTimer!         // fires every tenth second
    
    // ref to recorder
    var audioRecorder:AVAudioRecorder!
    
    // enum for record state
    enum RecordState {
        case Ready, Recording, Failed
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // set buttons and label to ready to record
        configureRecordUIState(.Ready)
    }
    
    // AVAudioRecorder delegate function
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        /*
         audioRecorder has finished recording. This delegate function is used to place the buttons/labels
         into a ready to record state.
         */
        
        // stop recording disabled, not used when not recording
        stopRecordingButton.enabled = false
        
        // OK to record since not currently recording
        recordButton.enabled = true
        
        // test success flag
        if flag {
            
            // recording was successful. Play button and label are enabled/highlighted
            // ..return to a ready to record state
            configureRecordUIState(.Ready)
        }
        else {
            
            // recording was not successful. Play button and label are disabled/dimmed
            configureRecordUIState(.Failed)
        }
    }
    
    // action for timer
    func timerFired(sender: AnyObject) {

        // increment timer, counts in tenths of a second
        elapsedTime += 1
        
        // form elapsed time string
        var timeString = "\(Int(elapsedTime % 10))"
        let seconds = Int(Float(elapsedTime) / 10.0)
        if seconds < 10 {
            timeString = "0\(seconds)." + timeString
        }
        else {
            timeString = "\(seconds)." + timeString
        }

        // test for greater than 599 tenths of a second..limit to one minute of recording
        if elapsedTime > 599 {
            
            // at maximum record time.
            elapsedTimeLabel.text = "1'00.0"
            ceaseRecording()
        }
        else {
            
            // update elapsedTimeLabel with final string
            elapsedTimeLabel.text = "0'" + timeString
        }
    }
    
    // action for recordButton
    @IBAction func recordAudio(sender: AnyObject) {
        
        // disable playButton when recording
        playButton.enabled = false
        
        // highlight elapsedTime labels
        elapsedTimeLabel.alpha = 1.0
        elapsedTimeTitleLabel.alpha = 1.0
        
        // update recording label to show status, disable recordButton and enable stopRecordingButton
        recordingLabel.text = RECORDING_IN_PROGRESS
        recordButton.enabled = false
        stopRecordingButton.enabled = true
        
        // create path to store audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // retrieve session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        // create and config audioRecorder
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        // preset elapsed time, create timer and add to run loop to start
        elapsedTime = 0
        timer = NSTimer(timeInterval: 0.1, target: self, selector: #selector(RecordSoundsViewController.timerFired(_:)), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    // action for stopRecording button
    @IBAction func stopRecording(sender: AnyObject) {
        
        ceaseRecording()
    }
    
    // function to handle the ceasing of recording
    func ceaseRecording() {
        
        // stop/remove time from runloop
        timer.invalidate()
        
        // stop recording
        audioRecorder.stop()
        
        // deactivate session
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // action for playButton
    @IBAction func playButtonPressed(sender: AnyObject) {
        
        // initiate segue to PlaySoundsVC
        performSegueWithIdentifier("playAudioSegue", sender: sender)
    }
    
    // notification for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // test for segue
        if segue.identifier == "playAudioSegue" {
            
            // get VC and set URL for recorded audio
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let recordAudioURL = audioRecorder.url
            playSoundsVC.recordedAudioURL = recordAudioURL
        }
    }
    
    // helper function to set UI elements
    func configureRecordUIState(state: RecordState) {
        
        switch state {
        case .Ready:
            // ready to record
            recordButton.enabled = true
            recordingLabel.text = READY_TO_RECORD
            stopRecordingButton.enabled = false
            
            // test for non-nil audioRecorder
            if audioRecorder != nil {
                // ..valid audio still present
                elapsedTimeTitleLabel.alpha = 1.0
                elapsedTimeLabel.alpha = 1.0
                playButton.enabled = true
                playLabel.alpha = 1.0
            }
            else {
                // no audio yet, nothing to play back
                elapsedTimeTitleLabel.alpha = 0.5
                elapsedTimeLabel.text = "0'00.0"
                elapsedTimeLabel.alpha = 0.5
                playButton.enabled = false
                playLabel.alpha = 0.5
            }
        case .Recording:
            // currently recording
            recordButton.enabled = false
            recordingLabel.text = RECORDING_IN_PROGRESS
            stopRecordingButton.enabled = true
            elapsedTimeTitleLabel.alpha = 1.0
            elapsedTimeLabel.alpha = 1.0
            playButton.enabled = false
            playLabel.alpha = 0.5
        case .Failed:
            // recording failed
            configureRecordUIState(.Ready)
            recordingLabel.text = BAD_RECORDING_MESSAGE
        }
    }
}

