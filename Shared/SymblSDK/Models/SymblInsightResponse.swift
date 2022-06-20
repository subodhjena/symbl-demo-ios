//
//  SymblInsightResponse.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 20/06/22.
//

import Foundation

// MARK: - SymblInsightResponse
struct SymblInsightResponse: Codable {
    let type: String
    let insights: [Insight]
    let sequenceNumber: Int
}

// MARK: - Insight
struct Insight: Codable {
    let id: String
    let confidence: Double
    let hints: [Hint]
    let type: String
    let assignee: Assignee
    let tags: [JSONAny]
    let dismissed: Bool
    let payload: PayloadInsightResponseClass
    let from: Assignee
    let entities: JSONNull?
    let messageReference: MessageReference
}

// MARK: - Assignee
struct Assignee: Codable {
    let id, name, userID: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case userID = "userId"
    }
}

// MARK: - Hint
struct Hint: Codable {
    let key, value: String
}

// MARK: - MessageReference
struct MessageReference: Codable {
    let id: String
}

// MARK: - Payload

struct PayloadInsightResponseClass: Codable {
    let content, contentType: String
}
