//
//  RecordingView.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 15/06/22.
//

import SwiftUI

struct RecordingView: View {
    
    // State Variables
    @StateObject var captureSession = CaptureSession()
    
    // Local
    let symblRealtime = SymblRealtime()
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .trailing) {
                // Recording Status
                Text("Mic Active - \(captureSession.isAudioRecording ? "True": "False")")
                
                HStack {
                    // Pause/Resume Recording
                    Button(
                        action: captureSession.isAudioRecording ? pauseAudioRecording : resumeAudioRecording,
                        label: {
                            captureSession.isAudioRecording ? Image("MicOn")
                                .foregroundColor(Color.white) : Image("MicOff")
                                .foregroundColor(Color.white)
                        }
                    )
                    .frame(width: 64, height: 64)
                    .background(Color.yellow)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(20)
        }
        .onReceive(captureSession.audioPublisher){ (data) in
            receivedAudioData(data: data)
        }
        .onAppear() {
            symblRealtime.initialize()
        }
    }
    
    func resumeAudioRecording() {
        print("Streaming resumed!")
        captureSession.startRecording()
        symblRealtime.startRequest()
    }
    
    func pauseAudioRecording() {
        print("Streaming paused!")
        captureSession.stopRecording()
        symblRealtime.stopRequest()
    }
    
    func stopStreaming() {
        print("Streaming stoped!")
        captureSession.stopRecording();
    }
    
    func receivedAudioData(data: Data) {
        print("Received data - \(data)")
        symblRealtime.streamAudio(data: data)
    }
}

struct RecordingView_Previews: PreviewProvider {

    static var previews: some View {
        RecordingView()
    }
}
