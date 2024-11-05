//
//  Email.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 07.02.24.
//

import SwiftData
import Foundation

actor EmailsSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [Email.self]

    @Model
    final class Email: Identifiable, Codable, Equatable {
        #Index<Email>([\.address], [\.privateComment], [\.gotos], [\.active])
        #Unique<Email>([\.privateComment], [\.address])
        var id: Int
        var address: String
        var privateComment: String
        private var gotos: [String] = []
        var active: Bool = true
        
        var goto: [String] {
            get {
                gotos
            }
            set {
                gotos = newValue
            }
        }
        
        init(id: Int, address: String, privateComment: String, goto: [String], active: Bool = true) {
            self.id = id
            self.address = address
            self.privateComment = privateComment
            self.gotos = goto
            self.active = active
        }
        
        convenience init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                id: container.decode(Int.self, forKey: .id),
                address: container.decode(String.self, forKey: .address),
                privateComment: container.decode(String?.self, forKey: .privateComment) ?? "",
                goto: container.decode(String.self, forKey: .goto).split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }),
                active: Bool(truncating: container.decode(Int.self, forKey: .active) as NSNumber)
            )
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(address, forKey: .address)
            try container.encode(privateComment, forKey: .privateComment)
            try container.encode(goto.joined(separator: ","), forKey: .goto)
            try container.encode(active, forKey: .active)
        }
        
        static func == (lhs: Email, rhs: Email) -> Bool {
            lhs.id == rhs.id &&
            lhs.address == rhs.address &&
            lhs.privateComment == rhs.privateComment &&
            lhs.goto == rhs.goto &&
            lhs.active == rhs.active
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case address
            case privateComment
            case goto
            case active
        }
    }
}

typealias Email = EmailsSchemaV1.Email
