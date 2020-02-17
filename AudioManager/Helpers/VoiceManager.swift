import Foundation
import AVFoundation

class VoiceManager {
    
    private static let AUDIO_PLAYER_QUEUE = "audioPlayerQueue"
    private static var instance : VoiceManager!
    
    public static func getIntance() -> VoiceManager{
        if(instance == nil){
            instance = VoiceManager()
        }
        return instance
    }
    
    var audioPlayerQueue = DispatchQueue(label: AUDIO_PLAYER_QUEUE, qos: DispatchQoS.userInteractive)
    var audioPlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    var inputFormat: AVAudioFormat?
    var engine : AVAudioEngine!
    var data : [NSData] = []
    var bufferArray : [AVAudioPCMBuffer] = []
    var input : AVAudioNode!
    var ezAudio = EZAudio()
    
    func setup(){
        engine = AVAudioEngine()
        guard nil != engine?.inputNode else {
            // @TODO: error out
            return
        }
        input = engine.inputNode
        engine.attach(audioPlayer)
        inputFormat = AVAudioFormat.init(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)
        engine.connect(audioPlayer, to: engine.mainMixerNode, format: input?.outputFormat(forBus: 0))
        do {
            engine.prepare()
            try engine.start()
        } catch (let error){
            print(error.localizedDescription)
        }
    }
    
    func recordVoice(){
        data.removeAll()
        installTap()
    }
    
    func playVoice(){
        //removeTap()
        setup()
        let format = input.inputFormat(forBus: 0)
        for nsdata in data{
            bufferArray.append(dataToPCMBuffer(format: format, data: nsdata))
        }
        audioPlayerQueue.async {
            do {
                if !self.engine.isRunning {
                    self.setup()
                    //try self.engine.start()
                }
                for buffer in self.bufferArray{
                    self.audioPlayer.scheduleBuffer(buffer, completionHandler: nil)
                    self.audioPlayer.play()
                }
                self.bufferArray.removeAll()
//                self.audioPlayer.scheduleBuffer(pcmBuffer, completionHandler: nil)
//                self.audioPlayer.play()
            }catch {
                print(error.localizedDescription)
            }
        }
        //play(dataArray: data)
    }
    
    private func play(dataArray: [NSData]){
        
        let format = input.inputFormat(forBus: 0)
        
        for data in dataArray{
            let pcmBuffer = dataToPCMBuffer(format: format, data: data)
            audioPlayerQueue.async {
                do {
                    if !self.engine.isRunning {
                        try self.engine.start()
                    }
                    self.audioPlayer.scheduleBuffer(pcmBuffer, completionHandler: nil)
                    self.audioPlayer.play()
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
//        do{
//           try engine.start()
//           audioPlayer.play()
//        }catch(let error){
//            print(error.localizedDescription)
//        }
    }

    private func initEngine(){
        engine = AVAudioEngine()
        input = engine.inputNode
    }
    
    
    private func installTap() {
        engine = AVAudioEngine()
        guard nil != engine?.inputNode else {
            // @TODO: error out
            return
        }
        input = engine.inputNode
        
        let format = input.inputFormat(forBus: 0)
        
        input.installTap(onBus: 0, bufferSize: 44100, format: format, block:
            { (buffer: AVAudioPCMBuffer, AVAudioTime) in

            let stream = self.audioBufferToNSData(format:format, PCMBuffer: buffer)
                print("stream:",stream)
            self.data.append(stream)
            
        })
        
        do {
            engine.prepare()
            try engine.start()
        } catch (let error){
            // @TODO: error out
            print(error.localizedDescription)
        }
    }
    
    private func removeTap(){
        engine.detach(input)
        input.removeTap(onBus: 0)
        engine.stop()
    }
    
    // **Edit: For Enable Lound Speaker**
    
    func speakerEnabled(_ enabled:Bool) -> Bool {
        let session = AVAudioSession.sharedInstance()
        var options = session.categoryOptions
        
        if (enabled) {
            options.insert(.defaultToSpeaker)
        } else {
            options.remove(.defaultToSpeaker)
        }
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default , options: .defaultToSpeaker)
        return true
    }
    
    func audioBufferToNSData(format: AVAudioFormat, PCMBuffer: AVAudioPCMBuffer) -> NSData {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength * format.streamDescription.pointee.mBytesPerFrame))
        return data
    }
    
    func dataToPCMBuffer(format: AVAudioFormat, data: NSData) -> AVAudioPCMBuffer {
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                           frameCapacity: UInt32(data.length) / format.streamDescription.pointee.mBytesPerFrame)
        
        audioBuffer!.frameLength = audioBuffer!.frameCapacity
        let channels = UnsafeBufferPointer(start: audioBuffer!.floatChannelData, count: Int(audioBuffer!.format.channelCount))
        data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
        return audioBuffer!
    }
    
    func toPCMBuffer(audioFormat:AVAudioFormat,data: NSData) -> AVAudioPCMBuffer {
        let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)  // given NSData audio format
        let PCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(data.length) / audioFormat!.streamDescription.pointee.mBytesPerFrame)
        PCMBuffer!.frameLength = PCMBuffer!.frameCapacity
        let channels = UnsafeBufferPointer(start: PCMBuffer!.floatChannelData, count: Int(PCMBuffer!.format.channelCount))
        data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
        return PCMBuffer!
    }
    
    
}
