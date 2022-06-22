//
//  CaptureSession.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 15/06/22.
//

import Foundation
import AVFoundation
import Combine

class CaptureSession: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate, ObservableObject {
    var audioPublisher = PassthroughSubject<Data, Never>()
    var isAudioRecording = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    private var captureSession: AVCaptureSession!
    private var audioOutput: AVCaptureAudioDataOutput!
    
    override init() {
        super.init()
    }
    
    func startRecording() {
        print("Starting Capture Session")
        self.captureSession = AVCaptureSession()
        
        print("Fetching Audio Capture Device")
        // let queue = DispatchQueue(label: "AudioSessionQueue", attributes: [])
        let audioDevice = AVCaptureDevice.default(for: .audio)
        var audioInput : AVCaptureDeviceInput? = nil
        
        do {
            try audioDevice?.lockForConfiguration()
            audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            audioDevice?.unlockForConfiguration()
        } catch {
            print("Configuration failed. Handle error.")
        }
        
        print("Add Audio Input Device")
        if captureSession.canAddInput(audioInput!) {
            captureSession.addInput(audioInput!)
        } else {
            print("Audio inputs are invalid.")
        }
        
        
        print("Setting up audio data output")
        audioOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "test"))
        if captureSession.canAddOutput(audioOutput!) {
            captureSession.addOutput(audioOutput!)
        } else {
            print("Output is invalid")
        }
        
        captureSession.startRunning()
        isAudioRecording = true
    }
    
    func stopRecording() {
        print("Stop the capture session")
        captureSession.stopRunning()
        isAudioRecording = false
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var audioBufferList = AudioBufferList()
        var data = Data()
        var blockBuffer : CMBlockBuffer?
        
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, bufferListSizeNeededOut: nil, bufferListOut: &audioBufferList, bufferListSize: MemoryLayout<AudioBufferList>.size, blockBufferAllocator: nil, blockBufferMemoryAllocator: nil, flags: 0, blockBufferOut: &blockBuffer)
        
        let buffers = UnsafeBufferPointer<AudioBuffer>(start: &audioBufferList.mBuffers, count: Int(audioBufferList.mNumberBuffers))
        
        for audioBuffer in buffers {
            let frame = audioBuffer.mData?.assumingMemoryBound(to: UInt8.self)
            data.append(frame!, count: Int(audioBuffer.mDataByteSize))
        }
        
        audioPublisher.send(data)
    }
}
