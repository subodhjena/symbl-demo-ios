//
//  NewRecordingView.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 22/06/22.
//

import SwiftUI
import CoreData
import SymblSwiftSDK

struct RecordingView: View {
    
    
    private var _memo: Memo
    var memo: Memo {
        get { return _memo }
    }
    
    @State private var formattedTranscription: String = ""
    @State private var activeTranscription: String = ""
    
    @State private var symbl: Symbl?
    @StateObject var captureSession = CaptureSession()
    @StateObject var symblRealtimeDelegate = SymblRealtimeDataDelegate()
    
    init(memo: Memo) {
        _memo = memo
    }
    
    var body: some View {
        VStack (){
            VStack(alignment: .leading, spacing: 8) {
                Text(_memo.timestamp!, formatter: itemFormatter)
                    .fontWeight(.bold)
                    .font(.headline)
                
                Text("00:00:00")
                    .fontWeight(.light)
                    .font(.subheadline)
                
                Text("Topics: \(0), Questions: \(0)")
                Text("Follow ups: \(0), Actions Items: \(0)")
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 80 ,alignment: .topLeading)
            .padding(20)
            
            TextEditor(text: $formattedTranscription)
                .foregroundColor(Color.gray)
                .padding()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(symblRealtimeDelegate.punctuatedTranscript)
                    recordButton
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .trailing)
            .padding(20)
        }
        .onReceive(captureSession.audioPublisher){ (data) in
            receivedAudioData(data: data)
        }
        .onAppear {
            let accessToken = "CHANGE_THIS"
            let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
            
            symbl = Symbl(accessToken: accessToken)
            symbl!.initializeRealtimeSession(meetingId: uniqueMeetingId, delegate: symblRealtimeDelegate)
            symbl!.realtimeSession?.connect()
        }
        .onDisappear {
            captureSession.stopRecording()
            symbl!.realtimeSession?.disconnect()
        }
    }
    
    var recordButton: some View {
        Button(action: startOrStopRecording, label: {
            captureSession.isAudioRecording ? Image("MicOn")
                .foregroundColor(Color.white) : Image("MicOff")
                .foregroundColor(Color.white)
        })
        .frame(width: 64, height: 64)
        .background(Color.blue)
        .cornerRadius(10)
    }
    
    private func startOrStopRecording() {
        if(captureSession.isAudioRecording) {
            captureSession.stopRecording()
        }
        else {
            captureSession.startRecording()
        }
    }
    
    private func startRquest() {
        let startRequest = SymblStartRequest(
            insightTypes: [ "question","action_item","follow_up"],
            meetingTitle: itemFormatter.string(from: memo.timestamp!),
            config: SymblConfig(speechRecognition: SymblSpeechRecognition(encoding: "LINEAR16", sampleRateHertz: 44100),
                                confidenceThreshold: 0.5, languageCode: "en-US"),
            speaker: SymblSpeaker(name: "Subodh Jena", userID: "subodh.jena@symbl.ai"), type: "start_request")
        
        symbl!.realtimeSession?.startRequest(startRequest: startRequest)
    }
    
    private func stopRequest() {
        symbl!.realtimeSession!.stopRequest()
    }
    
    private func receivedAudioData(data: Data) {
        symbl!.realtimeSession!.streamAudio(data: data)
    }
}

class SymblRealtimeDataDelegate:NSObject, ObservableObject, SymblRealtimeDelegate {
    @State var punctuatedTranscript: String = ""
    
    func symblRealtimeConnected() {
        print("SymblRealtimeDelegateClass: Conncted")
    }
    
    func symblRealtimeDisonnected() {
        print("SymblRealtimeDelegateClass: Disconncted")
    }
    
    func symblReceivedMessage(message: SymblMessage) {
        print("SymblRealtimeDelegateClass: Message")
        self.punctuatedTranscript = message.punctuated!.transcript
    }
    
    func symblReceivedMessageResponse(messageResponse: SymblMessageResponse) {
        print("SymblRealtimeDelegateClass: MessageResponse")
    }
    
    func symblReceivedToipcResponse(topicResponse: SymblTopicResponse) {
        print("SymblRealtimeDelegateClass: TopicResponse")
    }
    
    func symblReceivedActionItems(actionItems: [SymblInsight]) {
        print("SymblRealtimeDelegateClass: Action Items")
    }
    
    func symblReceivedQuestions(questions: [SymblInsight]) {
        print("SymblRealtimeDelegateClass: Questions")
    }
    
    func symblReceivedFollowUps(followUps: [SymblInsight]) {
        print("SymblRealtimeDelegateClass: Follow ups")
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        let previewViewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
        
        let memo = try? previewViewContext.fetch(fetchRequest).last! as Memo
        RecordingView(memo: memo!)
    }
}
