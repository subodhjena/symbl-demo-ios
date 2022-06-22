//
//  NewRecordingView.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 22/06/22.
//

import SwiftUI
import CoreData
import SymblSwiftSDK

struct NewRecordingView: View {
    private var _memo: Memo
    
    @State private var formattedTranscription: String = ""
    @State private var activeTranscription: String = ""

    private var symblRealtime: SymblRealtimeApi?
    @State private var symblRealtimeDelegate = SymblRealtimeDataDelegate()
    @StateObject var captureSession = CaptureSession()

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
                
                Text("Topics: \(symblRealtimeDelegate.symblTopics.count), Questions: \(symblRealtimeDelegate.symblInsightQuestions.count)")
                
                Text("Follow ups: \(symblRealtimeDelegate.symblInsightFollowUps.count), Actions Items: \(symblRealtimeDelegate.symblInsightActionItems.count)")
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 80 ,alignment: .topLeading)
            .padding(20)
            
            TextEditor(text: $formattedTranscription)
                .foregroundColor(Color.gray)
                .padding()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(activeTranscription)
                    recordButton
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .trailing)
            .padding(20)
        }
        .onAppear {
            let symbl = Symbl(accessToken: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlFVUTRNemhDUVVWQk1rTkJNemszUTBNMlFVVTRRekkyUmpWQ056VTJRelUxUTBVeE5EZzFNUSJ9.eyJodHRwczovL3BsYXRmb3JtLnN5bWJsLmFpL3VzZXJJZCI6IjQ5NTYzMTYwODU3ODA0ODAiLCJpc3MiOiJodHRwczovL2RpcmVjdC1wbGF0Zm9ybS5hdXRoMC5jb20vIiwic3ViIjoibzZXM1BLdUg2cnAxVVBxY0VhQ2NHSnlwMXlLQ25MVFJAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vcGxhdGZvcm0ucmFtbWVyLmFpIiwiaWF0IjoxNjU1OTAxNjcyLCJleHAiOjE2NTU5ODgwNzIsImF6cCI6Im82VzNQS3VINnJwMVVQcWNFYUNjR0p5cDF5S0NuTFRSIiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.xEuaaCCGoPTVJllUpucIiez9X3U3wON2EcljrnTyZ8aRo7-bQYNPFmXfhVrq3uLxJKpXDQ8tAoo9mdQg0M2U1gxb2-TG6QbyYvvPgZYKX8JUrfwmRKnDtWCsOj2difnM-l45EhgwsHFjrhOxkfnpvobf18pL0yboZZxLPUUMKlemCkVYTKBitnGA512-RNORn1QqLIB8T5zn61a55vOPBHjxe2NmjkjQUiJsZ13aQqyp_jVVD6uAxE8UOY4Vu2vNvDlB6McfGJnALnGuNgmkQnedUMgBDzNNqv0nPbighpZMZ2elw0T_1BKagwF4xMcRC3EV2pBK7PpGOJX_O1i02A")
            let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
            symbl.initializeRealtimeSession(meetingId: uniqueMeetingId, delegate: symblRealtimeDelegate)
            symbl.realtimeSession?.connect()
        }
        .onReceive(captureSession.audioPublisher){ (data) in
            receivedAudioData(data: data)
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
            stopRequest()
        }
        else {
            captureSession.startRecording()
            startRquest()
        }
    }
    
    private func startRquest() {
        // symblRealtime.startRequest()
    }
    
    private func stopRequest() {
        // symblRealtime.stopRequest()
    }
    
    private func receivedAudioData(data: Data) {
        // symblRealtime.streamAudio(data: data)
    }
}

class SymblRealtimeDataDelegate: SymblRealtimeDelegate {
    private var _symblTopics: [Topic] = []
    private var _symblInsights: [Insight] = []
    
    public var symblTopics: [Topic] {
        get {
            return _symblTopics
        }
    }
    public var symblInsights: [Insight] {
        get {
            return _symblInsights
        }
    }
    public var symblInsightQuestions: [Insight] {
        get {
            return _symblInsights.filter { $0.type == "question" }
        }
    }
    public var symblInsightActionItems: [Insight] {
        get {
            return _symblInsights.filter { $0.type == "action_item" }
        }
    }
    public var symblInsightFollowUps: [Insight] {
        get {
            return _symblInsights.filter { $0.type == "follow_up" }
        }
    }
    
    func symblRealtimeConnected() {
        print("SymblRealtimeDelegateClass: Conncted")
    }
    
    func symblRealtimeDisonnected() {
        print("SymblRealtimeDelegateClass: Disconncted")
    }
}

struct NewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        let previewViewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
        
        let memo = try? previewViewContext.fetch(fetchRequest).last! as Memo
        NewRecordingView(memo: memo!)
    }
}
