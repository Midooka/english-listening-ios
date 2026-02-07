//
//  EnglishListeningAppApp.swift
//  EnglishListeningApp
//
//  Created by t-a-midooka on 2026/02/07.
//

import SwiftUI

@main
struct EnglishListeningAppApp: App {
    @State private var dataStore = DataStore()
    @State private var progressStore = ProgressStore()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(dataStore)
                .environment(progressStore)
        }
    }
}
