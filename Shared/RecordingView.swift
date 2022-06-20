//
//  RecordingView.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 15/06/22.
//

import SwiftUI
import CoreData

struct RecordingView: View {
    var memo: Memo
    
    @State var formattedTranscription: String = ""
    
    @StateObject var captureSession = CaptureSession()
    @StateObject var symblRealtime = SymblRealtime()
    
    var body: some View {
        VStack (){
            VStack(alignment: .leading, spacing: 8) {
                Text(memo.timestamp!, formatter: itemFormatter)
                    .fontWeight(.bold)
                    .font(.headline)
                
                Text("00:00:00")
                    .fontWeight(.light)
                    .font(.subheadline)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .padding(20)
            
            TextEditor(text: $formattedTranscription)
                .padding()
            
            VStack(alignment: .trailing) {
                HStack {
                    Button(
                        action: captureSession.isAudioRecording ? pauseAudioRecording : resumeAudioRecording,
                        label: {
                            captureSession.isAudioRecording ? Image("MicOn")
                                .foregroundColor(Color.white) : Image("MicOff")
                                .foregroundColor(Color.white)
                        }
                    )
                    .frame(width: 64, height: 64)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(20)
        }
        .onReceive(captureSession.audioPublisher){ (data) in
            receivedAudioData(data: data)
        }
        .onReceive(symblRealtime.symblDataPublisher) {(data) in
            receivedMessage(data: data)
        }
        .onAppear() {
            symblRealtime.connect()
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
    
    func receivedMessage(data: SymblDataResponse) {
        let message = data.message
        
        print("Message type: \(message.type)")
        switch (message.type)  {
        case "recognition_result":
            formattedTranscription = message.punctuated.transcript
        case "insight_response":
            print("Response: Insight - \(message)")
        case "topic_response":
            print("Response: Topic - \(message)")
        case "message_response":
            print("Response: Message - \(message)")
        default:
            print("Response: Default - \(message)")
        }
    }
}

struct RecordingView_Previews: PreviewProvider {
    
    static var previews: some View {
        let previewViewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
        
        let memo = try? previewViewContext.fetch(fetchRequest).first! as Memo
        RecordingView(memo: memo!)
    }
}
