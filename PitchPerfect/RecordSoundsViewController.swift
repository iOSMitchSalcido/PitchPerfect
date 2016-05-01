//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Online Training on 4/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//

import UIKit
import AVFoundation

/*
 About RecordSoundsViewController.swift:
 Handle recording audio thru iOS device. Provide "record" button to initiate recording, and "stop" button
 to cease recording. Also show label to indicate recording status
 */

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // constants for recording label states
    let READY_TO_RECORD = "Tap Mic to Record"
    let RECORDING_IN_PROGRESS = "Recording in Progress"
    
    // ref to buttons and labels
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // for timing record length
    var elapsedTime = 0.0
    var timer: NSTimer!
    
    // ref to recorder
    var audioRecorder:AVAudioRecorder!

    override func viewWillAppear(animated: Bool) {
        
        // disable stopRecordingButton when view appears
        stopRecordingButton.enabled = false
        playButton.enabled = false
        recordingLabel.text = READY_TO_RECORD
        elapsedTimeLabel.text = "0'00.0"
    }
    
    // AVAudioRecorder delegate function
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        playButton.enabled = true
        stopRecordingButton.enabled = false
        recordingLabel.text = READY_TO_RECORD
        recordButton.enabled = true
        /*
        if (flag) {
            self.performSegueWithIdentifier("stopRecordingSegue", sender: audioRecorder.url)
        }
        else {
            print("saving of recording failed")
        }
 */
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "playAudioSegue" {
            
            if let url = sender as? NSURL {
              
                let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
                let recordAudioURL = url
                print(recordAudioURL)
                playSoundsVC.recordedAudioURL = recordAudioURL
            }
            else {
                print("bad URL")
            }
        }
    }
    
    func timerFired(sender: AnyObject) {

        // increment timer, counts in tenths of a second
        elapsedTime += 1
        
        // form elapsed time string
        var timeString = "\(Int(elapsedTime % 10))"
        let seconds = Int(elapsedTime / 10.0)
        if seconds < 10 {
            timeString = "0\(seconds)." + timeString
        }
        else {
            timeString = "\(seconds)." + timeString
        }

        // test for greater than 599 tenths of a second..limit to one minutes of recording
        if elapsedTime > 599 {
            
            // at max record time.
            elapsedTimeLabel.text = "1'00.0"
            timer.invalidate()
        }
        else {
            elapsedTimeLabel.text = "0'" + timeString
        }
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        
        playButton.enabled = false
        elapsedTime = 0
        timer = NSTimer(timeInterval: 0.1, target: self, selector: #selector(RecordSoundsViewController.timerFired(_:)), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        recordingLabel.text = RECORDING_IN_PROGRESS
        recordButton.enabled = false
        stopRecordingButton.enabled = true
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        
        timer.invalidate()
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("playAudioSegue", sender: audioRecorder.url)
    }
}

