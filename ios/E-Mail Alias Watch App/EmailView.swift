//
//  EmailView.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import SwiftData

struct EmailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate { $0.active },
        sort: \Email.privateComment,
        animation: .default
    ) private var emails: [Email]

    @State private var reloading = false
    @State private var showReloadAlert = false
    @State private var showAddAlert = false
    @State private var showDeleteAlert = false
    @State private var showDeleteConfirmAlert = false
    @State private var emailsToDelete: IndexSet? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(emails) { email in
                    NavigationLink {
                        EmailDetailView(email: email)
                    } label: {
                        Text(email.privateComment)
                    }
                    .confirmationDialog("Do you really want to delete the email?", isPresented: $showDeleteConfirmAlert) {
                        Button("Yes", role: .destructive) {
                            if let emailsToDelete {
                                Task {
                                    await deleteEmail(indicies: emailsToDelete)
                                }
                            }
                        }
                        Button("No", role: .cancel) {}
                    }
                }
                .onDelete { indexSet in
                    emailsToDelete = indexSet
                    showDeleteConfirmAlert = true
                }
            }
            .toolbar {
                HStack {
                    Button {
                        Task {
                            reloading.toggle()
                            await reload()
                        }
                    } label: {
                        Image(systemName: "arrow.circlepath")
                            .symbolEffect(.rotate, options: .nonRepeating, value: reloading)
                            .accessibilityLabel(Text("Reload"))
                    }
                    NavigationLink {
                        AddView(emails: emails, addEmail: addEmail(address:comment:))
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel(Text("Add"))
                    }
                }
            }
            .navigationTitle("Emails")
        }
        .alert("Error at loading the emails", isPresented: $showReloadAlert) {
            EmptyView()
        }
        .alert("Error at adding an email", isPresented: $showAddAlert) {
            EmptyView()
        }
        .alert("Error at deleting the email", isPresented: $showDeleteAlert) {
            EmptyView()
        }
        .task {
            await reload()
        }
    }
    
    private func reload() async {
        if !API.testMode {
            do {
                let emails = try await API.getEmails()
                try modelContext.save(emails: emails)
            }
            catch {
                showReloadAlert = true
            }
        }
    }
    
    private func addEmail(address: String, comment: String) async {
        let goto = UserDefaults.standard.string(forKey: .email)!
        let id: Int?
        if API.testMode {
            id = UserDefaults.standard.integer(forKey: .nextID)
            UserDefaults.standard.set(id! &+ 1, forKey: .nextID)
        }
        else {
            do {
                id = try await API.addEmail(emails: emails, address: address, privateComment: comment, additionalGotos: [])
            }
            catch {
                id = nil
                showAddAlert = true
            }
        }
        if let id {
            let email = Email(id: id, address: address, privateComment: comment, goto: [goto])
            modelContext.insert(email)
        }
    }
    
    private func deleteEmail(indicies: IndexSet) async {
        do {
            if !API.testMode {
                if !(try await API.deleteEmails(emails: indicies.map { emails[$0] })) {
                    showDeleteAlert = true
                    return
                }
            }
            for i in indicies {
                modelContext.delete(emails[i])
            }
        }
        catch {
            showDeleteAlert = true
        }
    }
}

#Preview {
    EmailView()
        .modelContainer(for: Email.self, inMemory: true) { result in
            if let context = try? result.get().mainContext {
                insertTestEmails(into: context)
            }
        }
}
