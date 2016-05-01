//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Online Training on 4/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // ref to buttons and labels
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    // ref to recorder
    var audioRecorder:AVAudioRecorder!

    override func viewWillAppear(animated: Bool) {
        
        // disable stopRecordingButton when view appears
        stopRecordingButton.enabled = false
    }
    
    // delegate function
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if (flag) {
            self.performSegueWithIdentifier("stopRecordingSegue", sender: audioRecorder.url)
        }
        else {
            print("saving of recording failed")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "stopRecordingSegue" {
            
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let recordAudioURL = sender as! NSURL
            print(recordAudioURL)
            playSoundsVC.recordedAudioURL = recordAudioURL
        }
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        
        recordingLabel.text = "Recording in Progress"
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
        
        stopRecordingButton.enabled = false
        recordingLabel.text = "Tap to Record"
        recordButton.enabled = true
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
}

