//
//  BeRealCloneApp.swift
//  BeRealClone
//
//  Created by Elias Woldie on 3/8/24.
//

import SwiftUI
import Parse

@main
struct BeRealCloneApp: App {
    init() {
        let parseConfig = ParseClientConfiguration {
                $0.applicationId = "yoxxrJEN1GDJECR9N2YKMTLp9vFxDEqA2I9IZw6J"
                $0.clientKey = "rrxEXt38q09ZddiezUN2qKwJzB002hd68BGzk7J8"
                $0.server = "https://parseapi.back4app.com/"
        }
        Parse.initialize(with: parseConfig)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
