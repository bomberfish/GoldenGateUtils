//
//  GlobalDefaults.swift
//  FlexiGlassTuner
//
//  Created on 2026-06-15.
//

import Foundation

struct GlobalDefaults {
    static func read(_ key: String) -> Any? {
        CFPreferencesCopyValue(key as CFString, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost) as Any?
    }
    static func write(_ val: Any?, forKey key: String) {
        CFPreferencesSetValue(key as CFString, val == nil ? nil : val as CFPropertyList, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
    }
}
