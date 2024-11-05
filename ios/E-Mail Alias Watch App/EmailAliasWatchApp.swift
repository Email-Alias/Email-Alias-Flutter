//
//  EmailAliasWatchApp.swift
//  E-Mail Alias Watch App
//
//  Created by Sven on 29.10.24.
//

import SwiftUI

import SwiftUI
import WatchConnectivity
import SwiftData

private let container = try! ModelContainer(
    for: Email.self,
    configurations: ModelConfiguration(for: Email.self, isStoredInMemoryOnly: false)
)

final class AppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    let session = WCSession.default
    
    func applicationDidFinishLaunching() {
        session.delegate = self
        session.activate()
    }
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        switch applicationContext["type"] as? String {
        case "register":
            UserDefaults.standard.setValue(applicationContext[.domain], forKey: .domain)
            UserDefaults.standard.setValue(applicationContext[.email], forKey: .email)
            let _ = save(valueToKeychain: applicationContext[.apiKey] as! String, withKey: .apiKey)
            
            Task {
                if await API.testMode {
                    UserDefaults.standard.set(7, forKey: .nextID)
                    await MainActor.run {
                        insertTestEmails(into: container.mainContext)
                    }
                }
                
                UserDefaults.standard.setValue(true, forKey: .registered)
            }
        case "logout":
            Task {
                do {
                    try await MainActor.run {
                        try container.mainContext.delete(model: Email.self)
                    }
                    UserDefaults.standard.removeObject(forKey: .domain)
                    UserDefaults.standard.removeObject(forKey: .email)
                    let _ = removeFromKeychain(withKey: .apiKey)
                    UserDefaults.standard.removeObject(forKey: .nextID)
                    UserDefaults.standard.setValue(false, forKey: .registered)
                }
                catch {}
            }
        case "settings":
            UserDefaults.standard.setValue(applicationContext[.language], forKey: .language)
        case "clearCache":
            Task {
                await MainActor.run {
                    try? container.mainContext.delete(model: Email.self)
                }
            }
        default:
            break
        }
    }
}

@main
struct EmailAliasWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @AppStorage(.language) private var language: Language = .system
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .language(language)
        }
    }
}

