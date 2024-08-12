import KeychainAccess

class KeychainManager {
    private let keychain = Keychain(service: "com.yourcompany.yourapp")

    func save(key: String, value: String) -> Bool {
        do {
            try keychain.set(value, key: key)
            return true
        } catch {
            print("Error saving to keychain: \(error)")
            return false
        }
    }

    func retrieve(key: String) -> String? {
        do {
            let value = try keychain.get(key)
            return value
        } catch {
            print("Error retrieving from keychain: \(error)")
            return nil
        }
    }

    func delete(key: String) -> Bool {
        do {
            try keychain.remove(key)
            return true
        } catch {
            print("Error deleting from keychain: \(error)")
            return false
        }
    }
}
