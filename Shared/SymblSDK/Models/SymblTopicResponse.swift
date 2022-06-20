//
//  SymblTopicResponse.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 20/06/22.
//

import Foundation

// MARK: - SymblTopicResponse
struct SymblTopicResponse: Codable {
    let type: String
    let topics: [Topic]
}

// MARK: - Topic
struct Topic: Codable {
    let id: String
    let messageReferences: [TopicMessageReference]
    let phrases: String
    let rootWords: [RootWord]
    let score: Double
    let type: String
    let messageIndex: Int
}

// MARK: - MessageReference
struct TopicMessageReference: Codable {
    let id: String
    let relation: String?
}

// MARK: - RootWord
struct RootWord: Codable {
    let text: String
}

