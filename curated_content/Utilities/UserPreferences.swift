import SwiftUI

// MARK: - UserPreferences
class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    private let interestsKey = "userInterests"
    
    var interests: Set<String> {
        get {
            Set(defaults.stringArray(forKey: interestsKey) ?? [])
        }
        set {
            defaults.set(Array(newValue), forKey: interestsKey)
        }
    }
    
    func updateInterests(_ newInterests: Set<String>) {
        interests = interests.union(newInterests)
    }
}
