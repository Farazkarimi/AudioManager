//
//  OpusHelper.swift
//  OpusAudio
//
//  Created by raika3 on 17/02/2020.
//  Copyright © 2020 raikak. All rights reserved.
//

import Foundation

class OpusHelper{
    var encoder: OpaquePointer = OpaquePointer(bitPattern: 16 * 5)!
    
    
    func encode(_ pcmData: NSData?, frameSize: Int32) -> Data? {

        let data = pcmData!.bytes.assumingMemoryBound(to: opus_int16.self)
        let outBuffer = malloc((pcmData?.count ?? 0) * MemoryLayout<UInt8>.size).assumingMemoryBound(to: UInt8.self)

        // The length of the encoded packet
        let encodedByteCount = opus_encode(encoder, data, frameSize, outBuffer, opus_int32(pcmData?.count ?? 0))

        if (Int(encodedByteCount) < 0) {
            print("encoding error \(String(describing: opusErrorMessage(encodedByteCount)))")
            return nil
        }

        // Opus data initialized with size in the first byte
        var outputData = Data(capacity: Int(frameSize * 2))
        // Append Opus data
        outputData.append(Data(bytes: outBuffer, count: Int(encodedByteCount)))

        return outputData
    }
    
    func opusErrorMessage(_ errorCode: Int32) -> String? {
        switch errorCode {
            case OPUS_BAD_ARG:
                return "One or more invalid/out of range arguments"
            case OPUS_BUFFER_TOO_SMALL:
                return "The mode struct passed is invalid"
            case OPUS_INTERNAL_ERROR:
                return "The compressed data passed is corrupted"
            case OPUS_INVALID_PACKET:
                return "Invalid/unsupported request number"
            case OPUS_INVALID_STATE:
                return "An encoder or decoder structure is invalid or already freed."
            case OPUS_UNIMPLEMENTED:
                return "Invalid/unsupported request number."
            case OPUS_ALLOC_FAIL:
                return "Memory allocation has failed."
            default:
                return nil
        }
    }
}

//- (NSData*) encode:(NSData*) pcmData frameSize:(int) frameSize{
//
//    opus_int16 *data  = (opus_int16*) [pcmData bytes];
//    uint8_t *outBuffer  = malloc(pcmData.length * sizeof(uint8_t));
//
//    // The length of the encoded packet
//    opus_int32 encodedByteCount = opus_encode(_encoder, data, frameSize, outBuffer, (opus_int32)pcmData.length);
//
//    if (encodedByteCount < 0) {
//        NSLog(@"encoding error %@",[self opusErrorMessage:encodedByteCount]);
//        return nil;
//    }
//
//    // Opus data initialized with size in the first byte
//    NSMutableData *outputData = [[NSMutableData alloc] initWithCapacity:frameSize*2];
//    // Append Opus data
//    [outputData appendData:[NSData dataWithBytes:outBuffer length:encodedByteCount]];
//
//    return outputData;
//}
