import Foundation

enum PracticeRecordingError: Error {
    case cannotAccessResource
    case copyFailed
}

struct PracticeRecordingService {
    static let supportedExtensions: Set<String> = ["m4a", "mp3", "wav", "caf"]
    static let subdirectory = "Recordings"

    func importRecording(
        sourceURL: URL,
        studentID: UUID,
        assignmentID: UUID? = nil
    ) throws -> PracticeRecording {
        let needsScope = sourceURL.startAccessingSecurityScopedResource()
        defer { if needsScope { sourceURL.stopAccessingSecurityScopedResource() } }

        let recordingsDir = try FileStorageUtility.ensureSubdirectory(Self.subdirectory)
        let ext = sourceURL.pathExtension.lowercased()
        let safeExt = Self.supportedExtensions.contains(ext) ? ext : "m4a"
        let destFileName = "\(UUID().uuidString).\(safeExt)"
        let destURL = recordingsDir.appendingPathComponent(destFileName)

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
        } catch {
            throw PracticeRecordingError.copyFailed
        }

        return PracticeRecording(
            studentID: studentID,
            assignmentID: assignmentID,
            localFilePath: "\(Self.subdirectory)/\(destFileName)",
            originalFileName: sourceURL.lastPathComponent
        )
    }

    func fileURL(for recording: PracticeRecording) -> URL {
        FileStorageUtility.documentsURL().appendingPathComponent(recording.localFilePath)
    }
}
