//
//  Config.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation


enum Config {

    enum Key: String {
        case apiKey = "apikey"
    }

    static func getValue(forKey key: Key) -> String {
        guard let value = Bundle.main.infoDictionary?[key.rawValue] as? String else {
            return ""
        }
        return value
    }

}
