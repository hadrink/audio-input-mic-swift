//
//  ViewController.swift
//  Input mic
//
//  Created by Rplay on 24/04/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    //----------------//
    //-- Global var --//
    //----------------//
    
    var session: AVAudioSession?
    var engine: AVAudioEngine?
    var isInput: Bool?
    
    //-------------//
    //-- Outlets --//
    //-------------//

    @IBOutlet var audioInput: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession() //-- Create audio session when view is loading.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //-------------------//
    //-- Session Audio --//
    //-------------------//
    
    //-- Create a specific session to play audio
    func createSession() {
        
        session = AVAudioSession.sharedInstance()
        let startSessionError : NSError?
        
        do {
            try session?.setPreferredSampleRate(8000.00)                                //-- Try to set a spcific SampleRate.
            try session?.setCategory(AVAudioSessionCategoryPlayAndRecord)               //-- Set a recording category.
            try session?.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)    //-- Active loud speaker mic.
        } catch let err as NSError {
            startSessionError = err
            print("An error on starting session: \(startSessionError)")
        }
    }
    
    //-----------------//
    //-- Audio input --//
    //-----------------//
    
    //-- Add audio input.
    func startAudioInput() {
        
        engine = AVAudioEngine()                                    //-- Get AVaudioEngine object.
        let input =  engine?.inputNode!                             //-- Init mic input.
        let mixer = engine?.mainMixerNode                           //-- mainMixerNode have to be called for it works.
        let inputFormat = input?.inputFormatForBus(0)               //-- Get the correct format.
        let startEngineError : NSError?
        
        engine?.connect(input!, to: mixer!, format: inputFormat)    //-- To test if I hear me.
        
        do {
            try engine?.start()                                     //-- Start Engine Vroooooouuum !! :).
            isInput = true                                          //-- Set isInput to True.
        } catch let err as NSError {
            startEngineError = err
            print("Starting engine failed \(startEngineError)")
            isInput = false                                         //-- starting engine failed : set isInput to false.
        }
        
        //-- Get the buffer on every sound received in the input.
        input?.installTapOnBus(0, bufferSize: 2048, format: inputFormat) {
            (buffer : AVAudioPCMBuffer!, when : AVAudioTime!) in
            
            let floatChannelData = buffer.floatChannelData          //-- Get the low sound values for filter them.
            let memory = floatChannelData.memory                    //-- Get memory.
            let memoryValue = memory[Int(buffer.frameLength) - 1]   //-- Get value.
            
            //-- If the value is too low -> return.
            if fabs(memoryValue) < 0.0005 {
                return
            }
            
            print("Buffer \(buffer)")                               //-- We can send or record the buffer here.
        }
    }
    
    //-- Stop audio input.
    func stopAudioInput() {
        engine?.stop()      //-- Stop the engine.
        isInput = false     //-- isInput to false.
    }
    
    //------------//
    //-- Action --//
    //------------//
    
    //-- Called when we tap on the "Add audio input"
    @IBAction func audioInputAction(sender: UIButton) {
        
        isInput = isInput == nil ? false : isInput  //-- Set false if isInput value is nil.
        
        //-- Check statement for isInput.
        if !isInput! {
            startAudioInput()
            audioInput.setTitle("Stop audio input", forState: .Normal)
        } else {
            stopAudioInput()
            audioInput.setTitle("Start audio input", forState: .Normal)
        }
    }
}

