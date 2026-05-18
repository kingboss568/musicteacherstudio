import Foundation

enum FileStorageUtility {
    static func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    @discardableResult
    static func ensureSubdirectory(_ name: String) throws -> URL {
        let url = documentsURL().appendingPathComponent(name, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
}
