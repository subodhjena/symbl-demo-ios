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
    
    @State private var symblRealtime: SymblRealtimeApi?
    
    @State private var symblTopics: [Topic] = []
    @State private var symblInsights: [Insight] = []
    private var symblInsightQuestions: [Insight] {
        get {
            return symblInsights.filter { $0.type == "question" }
        }
    }
    private var symblInsightActionItems: [Insight] {
        get {
            return symblInsights.filter { $0.type == "action_item" }
        }
    }
    private var symblInsightFollowUps: [Insight] {
        get {
            return symblInsights.filter { $0.type == "follow_up" }
        }
    }
    
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
                    
                    Button(action: startOrPauseRecording, label: {
                        Image("MicOff")
                            .foregroundColor(Color.white)
                    })
                    .frame(width: 64, height: 64)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .trailing)
            .padding(20)
        }
        .onAppear {
            let symbl = Symbl(accessToken: "ACCESS_TOKEN")
            let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
            symbl.initializeRealtimeSession(meetingId: uniqueMeetingId)
            symbl.realtimeSession?.connect()
        }
    }
    
    private func startOrPauseRecording() {}
}

struct NewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        let previewViewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
        
        let memo = try? previewViewContext.fetch(fetchRequest).first! as Memo
        NewRecordingView(memo: memo!)
    }
}
