import Foundation

struct Environment {
    static func variable(_ key: String) -> String? {
        if let value = ProcessInfo.processInfo.environment[key] {
            return value
        }
        do {
            let envContents = try String(contentsOfFile: ".env", encoding: .utf8)
            let lines = envContents.components(separatedBy: .newlines)
            
            for line in lines {
                let parts = line.components(separatedBy: "=")
                if parts.count >= 2 && parts[0].trimmingCharacters(in: .whitespacesAndNewlines) == key {
                    return parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }

            return nil
        } catch {
            print("Error loading .env file: \(error)")
            return "no key available"
        }

    }
}
