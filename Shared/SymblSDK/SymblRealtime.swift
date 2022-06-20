//
//  SymblRealtime.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 15/06/22.
//

import Foundation
import Starscream
import Combine

class SymblRealtime: WebSocketDelegate, ObservableObject {
    
    let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
    let accessToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlFVUTRNemhDUVVWQk1rTkJNemszUTBNMlFVVTRRekkyUmpWQ056VTJRelUxUTBVeE5EZzFNUSJ9.eyJodHRwczovL3BsYXRmb3JtLnN5bWJsLmFpL3VzZXJJZCI6IjQ5NTYzMTYwODU3ODA0ODAiLCJpc3MiOiJodHRwczovL2RpcmVjdC1wbGF0Zm9ybS5hdXRoMC5jb20vIiwic3ViIjoibzZXM1BLdUg2cnAxVVBxY0VhQ2NHSnlwMXlLQ25MVFJAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vcGxhdGZvcm0ucmFtbWVyLmFpIiwiaWF0IjoxNjU1NzAyMTQ4LCJleHAiOjE2NTU3ODg1NDgsImF6cCI6Im82VzNQS3VINnJwMVVQcWNFYUNjR0p5cDF5S0NuTFRSIiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.BrA3NxYhIAhmpcg33_Ler4pS3_PQCLCoFdeLHAAR4hNBFflWQiPB0svKffZVHU2eCoFe3-Xy7LBW9avOpHd3YlVP5nZ71g7KZNqaFwvcg7WqVDEcRxJRGLkL3ZFzOKE2umSfexilTASVir1lmtCf1pBJ5_tXfppFyZQ7RxIAVv8c5ZDBIqlZkf1gsWm44VEMKlfxXIv0F5fIsN4NCmM1qvISEsN_NhpmG0ocT22g1zVRGtGcsekO5dFzmEJdvwbSMGxhuBtzHWKq2sMxzASpPvT1BfNFFn5mgLG476sckFvEYGSHqbrMrpuMrDgQAQVeNj9w0sCT10Y5zCoLONHyVw";
    
    var symblDataPublisher = PassthroughSubject<SymblDataResponse, Never>()
    
    var socket: WebSocket!
    var isConnected: Bool = false;
    
    func initialize() {
        let symblEndpoint = "wss://api.symbl.ai/v1/streaming/\(uniqueMeetingId)?access_token=\(accessToken)"
        var request = URLRequest(url: URL(string: symblEndpoint)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
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
            print(startRequestJsonString!)
            socket.write(string: startRequestJsonString)
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
            socket.write(string: stopRequestJsonString)
        }
    }
    
    func streamAudio(data: Data) {
        if (isConnected) {
            socket.write(data: data)
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            startRequest()
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            do {
                let data = string.data(using: .utf8)!
                let jsonDecoder = JSONDecoder()
                let message = try jsonDecoder.decode(SymblDataResponse.self,
                                                             from: data)
                symblDataPublisher.send(message)
            } catch {
                print(error)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print("Error \(error.debugDescription)")
        }
    }
}

