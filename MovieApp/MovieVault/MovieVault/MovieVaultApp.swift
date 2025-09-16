//
//  MovieVaultApp.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 11/09/25.
//

import SwiftUI

@main
struct MovieVaultApp: App {
    
    @StateObject private var router = Router()
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(router)
                .onOpenURL { url in
                    router.handle(url: url)
                }
        }
    }
}
