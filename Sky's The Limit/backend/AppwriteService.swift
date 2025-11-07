//
//  AppwriteService.swift
//  Sky's The Limit
//
//  Created by Chris  on 7/11/25.
//

import Foundation
import Appwrite

/// Reads a configuration value from Info.plist
/// Ensure the key exists in your target's Info.plist under `Information Property List`.
func getConfigValue(for key: String) -> String {
    if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty {
        return value
    }
    fatalError("Missing or invalid Info.plist value for key: \(key)")
}

func grabApiKey() -> String {
    return getConfigValue(for: "API_KEY")
}


class AppwriteService {
    static let shared = AppwriteService()
    
    let client = Client()
    
    private init() {
        let apiKey = grabApiKey()
        print(apiKey)
        client
            .setEndpoint("https://sgp.cloud.appwrite.io/v1") // Replace with your endpoint
            .setProject("690d951a00110f06cd0f")              // Replace with your project ID
        // NOTE: Appwrite iOS Client no longer supports setKey for API keys in client apps.
        // Use authentication via sessions (Account.createEmailPasswordSession) or setJWT for a server-issued JWT.
        // .setJWT(apiKey)
    }
}

