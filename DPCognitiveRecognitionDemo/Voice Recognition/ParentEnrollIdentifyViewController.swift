//
//  ParentEnrollIdentifyViewController.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit
import AVFoundation

class ParentEnrollIdentifyViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Instance variable
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    // MARK: Custom Methods
    // -------------------------------------------------------------------------------------------------------------------------
    // getPlistDocumentDirectory
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as  NSString
        return documentsDirectory
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // startRecording
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let audioURL = URL(fileURLWithPath: audioFilename)
        let settings: [String : AnyObject] = [
            AVFormatIDKey:Int(kAudioFormatLinearPCM) as AnyObject,
            AVSampleRateKey:16000.0 as AnyObject,
            AVNumberOfChannelsKey:1 as AnyObject,
            AVLinearPCMBitDepthKey:16 as NSNumber,
            AVLinearPCMIsBigEndianKey: false as NSNumber,
            AVLinearPCMIsFloatKey: false as NSNumber,
            AVEncoderBitRateKey: 16000.0 as NSNumber,
            AVEncoderBitRatePerChannelKey: 16 as NSNumber,
            AVEncoderBitDepthHintKey:16 as NSNumber
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL as URL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            finishRecording(false)
        }
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // finishRecording
    
    func finishRecording(_ success: Bool) {
        
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            
        } else {
            // recording failed :(
        }
    }
    
    // MARK: ViewController Life cycle methods
    // -------------------------------------------------------------------------------------------------------------------------
    // ViewDidLoad
    
    override func viewDidLoad() {
        // Call super
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------------
    // viewDidAppear
    
    override func viewWillAppear(_ animated:Bool) {
        // Call Super
        super.viewWillAppear(animated)
        
        // Take permission to record
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    // MARK: Audio Recording Delegate
    
    // ------------------------------------------------------------------------------------------------------
    // audioRecorderDidFinishRecording
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            //finishRecording(false)
        }
        else{
            // Enroll Voice for indetification
            
        }
    }
    
}
