//
//  EZAudioManager.swift
//  VoiceTets
//
//  Created by Maryam Chaharsooghi on 2/8/20.
//  Copyright © 2020 Maryam Chaharsooghi. All rights reserved.
//

import Foundation

class EZAudioManager {
    
    var ezaUdio = EZAudio()
    let inputDevices = EZAudioDevice.inputDevices()
    let currentInputDevice = EZAudioDevice.currentInput()//this will default to the headset device or bottom microphone
    let outputDevices = EZAudioDevice.outputDevices()
    let currentOutputDevice = EZAudioDevice.currentOutput()//this will default to the headset speake
    var microphone : EZMicrophone?
   
    func setupMic(micDelegate : EZMicrophoneDelegate){
        microphone?.delegate = micDelegate
        
    }
    
   
}

