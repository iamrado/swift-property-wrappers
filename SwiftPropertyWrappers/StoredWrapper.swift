//
//  StoredWrapper.swift
//  SwiftPropertyWrappers
//
//  Created by Radoslav Blasko on 24/02/2020.
//  Copyright © 2020 Radoslav Blasko. All rights reserved.
//

import Foundation

@propertyWrapper
struct Stored<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let storage: KeyValueStorage

    init(key: String, defaultValue: T, storage: KeyValueStorage = UserDefaults.standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: T {
        set { set(value: newValue, for: key) }
        get { return get(key) ?? defaultValue }
    }

    private func get<T: Decodable>(_ key: String) -> T? {
        guard let data = storage.object(forKey: key) as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func set<T: Encodable>(value: T?, for key: String) {
        guard let value = value else {
            storage.set(nil, forKey: key)
            return
        }

        do {
            let data = try JSONEncoder().encode(value)
            storage.set(data, forKey: key)
        } catch {
            assertionFailure("Could not encode value: \(value)")
        }
    }
}

protocol KeyValueStorage {
    func set(_ value: Any?, forKey key: String)
    func object(forKey key: String) -> Any?
}

extension UserDefaults: KeyValueStorage {

}

// EXAMPLE:
//
//struct SimpleStorage {
//    @Stored(key: "token", defaultValue: nil)
//    var token: String?
//
//    @Stored(key: "useTwelveHoursFormat", defaultValue: false)
//    var useTwelveHoursFormat: Bool
//}
