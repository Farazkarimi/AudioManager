//
//  RecordAndPlayViewController.swift
//  VoiceTets
//
//  Created by Maryam Chaharsooghi on 1/15/20.
//  Copyright © 2020 Maryam Chaharsooghi. All rights reserved.
//

import UIKit
import Accelerate

class RecordAndPlayViewController: UIViewController{

    var ezaUdio = EZAudio()
    var output : EZOutput? = nil
    let inputDevices = EZAudioDevice.inputDevices()
    let currentInputDevice = EZAudioDevice.currentInput()//this will default to the headset device or bottom microphone
    let outputDevices = EZAudioDevice.outputDevices()
    let currentOutputDevice = EZAudioDevice.currentOutput()//this will default to the headset speake
    var microphone = EZMicrophone()
    var audioPlot = EZAudioPlot()
    //var recorder = EZRecorder()
    var audioArray : [NSData] = []
    var buffers: [UnsafeMutablePointer<AudioBufferList>] = []
    var audioBufferArray : [AudioBufferList] = []
    var audioMutableBufferArray : [UnsafeMutablePointer<AudioBufferList>] = []
    var audioFile = EZAudioFile()
    var circularBuffer : TPCircularBuffer?
    var opus = CSIOpusEncoder(sampleRate: 8000, channels: 1, frameDuration: 2)
    var opusHelper = OpusHelper()
    
    @IBOutlet weak var plot: EZAudioPlot!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var streamDescription:AudioStreamBasicDescription=AudioStreamBasicDescription()
//        streamDescription.mSampleRate       = 16000.0
//        streamDescription.mFormatID         = kAudioFormatLinearPCM
//        streamDescription.mFramesPerPacket  = 1
//        streamDescription.mChannelsPerFrame = 1
//        streamDescription.mBytesPerFrame    = streamDescription.mChannelsPerFrame * 2
//        streamDescription.mBytesPerPacket   = streamDescription.mFramesPerPacket * streamDescription.mBytesPerFrame
//        streamDescription.mBitsPerChannel   = 16
//        streamDescription.mFormatFlags      = kAudioFormatFlagIsSignedInteger
//        microphone = EZMicrophone(microphoneDelegate: self, with: streamDescription, startsImmediately: false)
        //VoiceManager.getIntance().setup()
        output = EZOutput(dataSource: self)
        microphone = EZMicrophone(delegate: self)
        microphone.device = inputDevices?.last as! EZAudioDevice
        output!.device = currentOutputDevice
        let monoFloatFormat = EZAudioUtilities.monoFloatFormat(withSampleRate: 44100.0)
        output!.inputFormat = monoFloatFormat
        //EZAudioManager.getIntance().showInfo()
        //microphone.delegate = self
//        output!.delegate = self
        
        
    }
    
   
    
    @IBAction func recordButton(_ sender: Any) {
        microphone.microphoneOn = true
        microphone.startFetchingAudio()
        
        //VoiceManager.getIntance().recordVoice()
//
    }
    
    @IBAction func stop(_ sender: Any) {
        microphone.stopFetchingAudio()
        microphone.microphoneOn = false
        output?.startPlayback()
        //VoiceManager.getIntance().playVoice()
        print(opus?.encode(buffers[0]))
        //print(opusHelper.encode(audioArray[0], frameSize: 5))
        VoiceManager.getIntance().data = audioArray
        _=VoiceManager.getIntance().speakerEnabled(true)
        VoiceManager.getIntance().playVoice()
        audioArray.removeAll()
        
    }
    
    
    
}

extension RecordAndPlayViewController : EZMicrophoneDelegate, EZOutputDataSource, EZOutputDelegate, EZAudioPlayerDelegate
{
    func output(_ output: EZOutput!,
                shouldFill audioBufferList: UnsafeMutablePointer<AudioBufferList>!,
                withNumberOfFrames frames: UInt32,
                timestamp: UnsafePointer<AudioTimeStamp>!) -> OSStatus {
        
        //audioFile.readFrames(frames, audioBufferList: audioBufferList, bufferSize: bufferSize, eof: eof)
        
        
//        print("frames : \(frames)")
//        let blist : AudioBufferList = audioBufferList[0]
//        let buffer:AudioBuffer = blist.mBuffers
//        let audio = ["audio": NSData(bytes: buffer.mData, length: Int(buffer.mDataByteSize))];
//        print("audio: \(audio)")
////        DispatchQueue.main.async {
////            if self.audioArray.count > 0 {
////
////                let data = UnsafeMutablePointer<Float>(buffer.mData)
////                return
////            }
//            //let blist : AudioBufferList = audioBufferList[0]
//            //let buffer:AudioBuffer = blist.mBuffers
////            //let audio = ["audio": NSData(bytes: buffer.mData, length: Int(buffer.mDataByteSize))];
////            //print("p : -------> \(audio)")
////        }
//        let data = audioBufferList.pointee.mBuffers.mData
//
//        for audioBuffer in audioBufferArray {
//
////            let audio =  NSData(bytes: audioBuffer.mBuffers.mData,
////                                length: Int(audioBuffer.mBuffers.mDataByteSize))
//
//            data?.copyMemory(from: audioBuffer.mBuffers.mData!, byteCount: Int(audioBuffer.mBuffers.mDataByteSize))
//
//
//        }
        return noErr
    }
    
    func renderCallback(ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        
        let abl = UnsafeMutableAudioBufferListPointer(ioData)
        
        for buffer in abl {
            
            memset(buffer.mData, 0, Int(buffer.mDataByteSize))
        }
        
        return noErr
    }

//    func output(_ output: EZOutput!, changedDevice device: EZAudioDevice!) {
//        print("p : -------> device :\(device)")
//    }
//
//    func microphone(_ microphone: EZMicrophone!, changedDevice device: EZAudioDevice!) {
//        DispatchQueue.main.async {
//            print("p : -------> changedDevice :\(device)")
//        }
//    }
//
//    func microphone(_ microphone: EZMicrophone!, changedPlayingState isPlaying: Bool) {
//        print("p : -------> isPlaying :\(isPlaying)")
//        if(!isPlaying){
//            output?.stopPlayback()
//        }
//    }
//
//    func output(_ output: EZOutput!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//        print("p : -------> play")
//    }
//
    
    func microphone(_ microphone: EZMicrophone!,
                    hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>!,
                    withBufferSize bufferSize: UInt32,
                    withNumberOfChannels numberOfChannels: UInt32) {
        let audio =  NSData(bytes: bufferList.pointee.mBuffers.mData,
                                     length: Int(bufferList.pointee.mBuffers.mDataByteSize))
        //print("audio :\(audio)")
        audioArray.append(audio)
        buffers.append(bufferList)

        audioBufferArray.append(bufferList.pointee)
        audioMutableBufferArray.append(bufferList)
        //audioPlot.updateBuffer(T##buffer: UnsafeMutablePointer<Float>!##UnsafeMutablePointer<Float>!, withBufferSize: <#T##UInt32#>)
    }
    
    func microphone(_ microphone: EZMicrophone!,
                    hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!,
                    withBufferSize bufferSize: UInt32,
                    withNumberOfChannels numberOfChannels: UInt32) {
        if let value = buffer.pointee?.pointee{
            print(value)
        }
        plot.updateBuffer(buffer[0], withBufferSize: bufferSize)
    }
    
    func outputShouldUseCircularBuffer(_ output: EZOutput?) -> TPCircularBuffer? {
        return circularBuffer
    }
    
    
}
