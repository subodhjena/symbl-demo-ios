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
    @State var activeTranscription: String = ""
    
    @State var symblTopics: [Topic] = []
    @State var symblInsights: [Insight] = []
    
    var symblInsightQuestions: [Insight] {
        get {
            return symblInsights.filter { $0.type == "question" }
        }
    }
    var symblInsightActionItems: [Insight] {
        get {
            return symblInsights.filter { $0.type == "action_item" }
        }
    }
    var symblInsightFollowUps: [Insight] {
        get {
            return symblInsights.filter { $0.type == "follow_up" }
        }
    }
    
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
                
                Text("Topics: \(symblTopics.count), Questions: \(symblInsightQuestions.count)")
                
                Text("Follow ups: \(symblInsightFollowUps.count), Actions Items: \(symblInsightActionItems.count)")
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 80 ,alignment: .topLeading)
            .padding(20)
            
            TextEditor(text: $formattedTranscription)
                .foregroundColor(Color.gray)
                .padding()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(activeTranscription)
                    
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
            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .trailing)
            .padding(20)
        }
        .onReceive(captureSession.audioPublisher){ (data) in
            receivedAudioData(data: data)
        }
        .onReceive(symblRealtime.symblMessagePublisher) {(data) in
            receivedMessage(data: data)
        }
        .onReceive(symblRealtime.symblMessageResponsePublisher) {(data) in
            print("Symbl - Message Response: \(data)")
            var text: String = ""
            for sentence in data.messages {
                text = text + "\n" + sentence.payload.content
            }
            formattedTranscription = formattedTranscription + text + "\n"
        }
        .onReceive(symblRealtime.symblTopicResponsePublisher) {(data) in
            for topic in data.topics {
                symblTopics.append(topic)
            }
        }
        .onReceive(symblRealtime.symblInsightResponsePublisher) {(data) in
            for insight in data.insights {
                symblInsights.append(insight)
            }
        }
        .onAppear() {
            symblRealtime.connect()
        }
        .onDisappear() {
            
            captureSession.stopRecording()
            symblRealtime.disconnect()
            
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
    
    func receivedMessage(data: SymblMessage) {
        let message = data.message
        activeTranscription = message.punctuated.transcript
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
