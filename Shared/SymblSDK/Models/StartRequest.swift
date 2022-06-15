//
//  StartRequest.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 15/06/22.
//

import Foundation

// MARK: - StartRequest
struct StartRequest: Codable {
    let type, meetingTitle: String
    let insightTypes: [String]
    let config: Config
    let speaker: Speaker
}

// MARK: - Config
struct Config: Codable {
    let confidenceThreshold: Double
    let languageCode: String
    let speechRecognition: SpeechRecognition
}

// MARK: - SpeechRecognition
struct SpeechRecognition: Codable {
    let encoding: String
    let sampleRateHertz: Int
}

// MARK: - Speaker
struct Speaker: Codable {
    let userID, name: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case name
    }
}

