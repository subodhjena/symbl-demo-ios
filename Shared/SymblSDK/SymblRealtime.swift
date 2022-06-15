//
//  SymblRealtime.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 15/06/22.
//

import Foundation
import Starscream

class SymblRealtime: WebSocketDelegate {
    
    var socket: WebSocket!
    var isConnected: Bool = false;
    
    let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
    let accessToken = "CHANGE_THIS";
    
    func initialize() {
        let symblEndpoint = "wss://api.symbl.ai/v1/streaming/\(uniqueMeetingId)?access_token=\(accessToken)"
        var request = URLRequest(url: URL(string: symblEndpoint)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func startRequest() {
        let startRequestObject = StartRequest(type: "start_request", meetingTitle: "iOS Websockets How-to", insightTypes: ["question", "action_item"], config: Config(confidenceThreshold: 0.5, languageCode: "en-US", speechRecognition: SpeechRecognition(encoding: "LINEAR16", sampleRateHertz: 44100)), speaker: Speaker(userID: "subodh.jena@symbl.ai", name: "Subodh Jena"))
        
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
                let message = try jsonDecoder.decode(Message.self,
                                                             from: data)
                print("Transcript: \(message.message.punctuated.transcript)")
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

