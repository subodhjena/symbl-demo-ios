//
//  SymblNativeRealtime.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 20/06/22.
//

import Foundation
import Combine

class SymblNativeRealtime: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    
    var urlSessionWebSocketTask: URLSessionWebSocketTask!
    var symblDataPublisher = PassthroughSubject<SymblDataResponse, Never>()
    
    let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
    let accessToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlFVUTRNemhDUVVWQk1rTkJNemszUTBNMlFVVTRRekkyUmpWQ056VTJRelUxUTBVeE5EZzFNUSJ9.eyJodHRwczovL3BsYXRmb3JtLnN5bWJsLmFpL3VzZXJJZCI6IjQ5NTYzMTYwODU3ODA0ODAiLCJpc3MiOiJodHRwczovL2RpcmVjdC1wbGF0Zm9ybS5hdXRoMC5jb20vIiwic3ViIjoibzZXM1BLdUg2cnAxVVBxY0VhQ2NHSnlwMXlLQ25MVFJAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vcGxhdGZvcm0ucmFtbWVyLmFpIiwiaWF0IjoxNjU1NzAyMTQ4LCJleHAiOjE2NTU3ODg1NDgsImF6cCI6Im82VzNQS3VINnJwMVVQcWNFYUNjR0p5cDF5S0NuTFRSIiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.BrA3NxYhIAhmpcg33_Ler4pS3_PQCLCoFdeLHAAR4hNBFflWQiPB0svKffZVHU2eCoFe3-Xy7LBW9avOpHd3YlVP5nZ71g7KZNqaFwvcg7WqVDEcRxJRGLkL3ZFzOKE2umSfexilTASVir1lmtCf1pBJ5_tXfppFyZQ7RxIAVv8c5ZDBIqlZkf1gsWm44VEMKlfxXIv0F5fIsN4NCmM1qvISEsN_NhpmG0ocT22g1zVRGtGcsekO5dFzmEJdvwbSMGxhuBtzHWKq2sMxzASpPvT1BfNFFn5mgLG476sckFvEYGSHqbrMrpuMrDgQAQVeNj9w0sCT10Y5zCoLONHyVw";
    
    var isConnected: Bool = false;
    
    func initialize() {
        let symblEndpoint = "wss://api.symbl.ai/v1/streaming/\(uniqueMeetingId)?access_token=\(accessToken)"
        
        let webSocketURLSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let webSocketURL = URL(string: symblEndpoint)!
        
        self.urlSessionWebSocketTask = webSocketURLSession.webSocketTask(with: webSocketURL)
        self.urlSessionWebSocketTask.resume()
    }
    
    func startRequest() {
        let startRequestObject = StartRequest(type: "start_request", meetingTitle: "iOS Websockets How-to", insightTypes: ["question", "action_item", "follow_up"], config: Config(confidenceThreshold: 0.5, languageCode: "en-US", speechRecognition: SpeechRecognition(encoding: "LINEAR16", sampleRateHertz: 44100)), speaker: Speaker(userID: "subodh.jena@symbl.ai", name: "Subodh Jena"))
        
        var startRequestJsonString: String!
        
        do {
            let data = try JSONEncoder().encode(startRequestObject)
            startRequestJsonString = String(data: data, encoding: .utf8)
        } catch let err {
            print("Failed to encode JSON \(err)")
        }
        
        if isConnected {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.urlSessionWebSocketTask.send(.string(startRequestJsonString)) { error in
                    if let error = error {
                        print("Error when sending a message \(error)")
                    }
                }
            }
        }
    }
    
    func stopRequest() {
        let stopRequestObject = StopRequest(type: "stop_request")
        var stopRequestJsonString: String!
        
        do {
            let data = try JSONEncoder().encode(stopRequestObject)
            stopRequestJsonString = String(data: data, encoding: .utf8)
        } catch let err {
            print("Failed to encode JSON \(err)")
        }
        
        if isConnected {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.urlSessionWebSocketTask.send(.string(stopRequestJsonString)) { error in
                    if let error = error {
                        print("Error when sending a message \(error)")
                    }
                }
            }
        }
    }
    
    func receive() {
        self.urlSessionWebSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data received \(data)")
                case .string(let string):
                    print("Text received \(string)")
                    do {
                        let data = string.data(using: .utf8)!
                        let jsonDecoder = JSONDecoder()
                        let message = try jsonDecoder.decode(SymblDataResponse.self,
                                                                     from: data)
                        self.symblDataPublisher.send(message)
                    } catch {
                        print(error)
                    }
                }
            case .failure(let error):
                print("Error when receiving \(error)")
            }
        }
    }
    
    func streamAudio(data: Data) {
        
        let message = URLSessionWebSocketTask.Message.data(data)
        
        if isConnected {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.urlSessionWebSocketTask.send(message) { error in
                    if let error = error {
                        print("Error when sending a message \(error)")
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket Connected")
        isConnected = true
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket Disconnceted")
        isConnected = false
    }
}

public enum Message {
    case data(Data)
    case string(String)
}
