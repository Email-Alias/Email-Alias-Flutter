//
//  ModelContextExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 11.03.24.
//

import SwiftData

extension ModelContext {
    func save(emails: [Email]) throws {
        let cachedEmails = try fetch(FetchDescriptor<Email>())
        for email in emails {
            if let cachedEmail = cachedEmails.first(where: { $0.id == email.id }) {
                if cachedEmail != email {
                    cachedEmail.address = email.address
                    cachedEmail.goto = email.goto
                    cachedEmail.privateComment = email.privateComment
                    cachedEmail.active = email.active
                }
            }
            else {
                insert(email)
            }
        }
        
        let deleteEmails = cachedEmails.filter { email in
            !emails.contains { email.id == $0.id }
        }
        for email in deleteEmails {
            delete(email)
        }
    }
}
