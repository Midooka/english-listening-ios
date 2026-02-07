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

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(dataStore)
        }
    }
}
