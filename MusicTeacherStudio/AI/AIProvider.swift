import Foundation

protocol AIProvider {
    func complete(prompt: String) async throws -> String
}
