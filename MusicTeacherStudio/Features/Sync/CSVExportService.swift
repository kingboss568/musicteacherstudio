import Foundation

/// Pro 功能：把所有資料匯出成 CSV，方便老師備份或匯入到 Excel / Google Sheets。
struct CSVExportService {

    func exportAll(students: [Student], lessons: [Lesson],
                   assignments: [Assignment], payments: [PaymentRecord]) throws -> URL {
        let dir = try FileStorageUtility.ensureSubdirectory("Exports")
        let stamp = DateFormatterUtility.fileDateString(.now)
        let csvURL = dir.appendingPathComponent("MusicTeacherStudio_\(stamp).csv")
        let nameByID = Dictionary(uniqueKeysWithValues: students.map { ($0.id, $0.name) })

        var lines: [String] = []
        lines.append("=== STUDENTS ===")
        lines.append("id,name,instrument,level,parent,contact,defaultFee,isActive,createdAt")
        for s in students {
            lines.append([
                s.id.uuidString,
                Self.escape(s.name),
                Self.escape(s.instrument),
                Self.escape(s.level ?? ""),
                Self.escape(s.parentName ?? ""),
                Self.escape(s.parentContact ?? ""),
                String(s.defaultLessonFeeCents),
                String(s.isActive),
                ISO8601DateFormatter().string(from: s.createdAt)
            ].joined(separator: ","))
        }
        lines.append("")

        lines.append("=== LESSONS ===")
        lines.append("id,student,scheduledStart,scheduledEnd,status,feeCents,paid,note")
        for l in lessons {
            lines.append([
                l.id.uuidString,
                Self.escape(nameByID[l.studentID] ?? l.studentID.uuidString),
                ISO8601DateFormatter().string(from: l.scheduledStart),
                ISO8601DateFormatter().string(from: l.scheduledEnd),
                l.status.rawValue,
                String(l.feeCents),
                String(l.paid),
                Self.escape(l.teacherNote ?? "")
            ].joined(separator: ","))
        }
        lines.append("")

        lines.append("=== ASSIGNMENTS ===")
        lines.append("id,student,title,instruction,dueDate,status")
        for a in assignments {
            lines.append([
                a.id.uuidString,
                Self.escape(nameByID[a.studentID] ?? a.studentID.uuidString),
                Self.escape(a.title),
                Self.escape(a.instruction),
                a.dueDate.map { ISO8601DateFormatter().string(from: $0) } ?? "",
                a.status.rawValue
            ].joined(separator: ","))
        }
        lines.append("")

        lines.append("=== PAYMENTS ===")
        lines.append("id,student,amountCents,paidAt,method,note")
        for p in payments {
            lines.append([
                p.id.uuidString,
                Self.escape(nameByID[p.studentID] ?? p.studentID.uuidString),
                String(p.amountCents),
                ISO8601DateFormatter().string(from: p.paidAt),
                Self.escape(p.method ?? ""),
                Self.escape(p.note ?? "")
            ].joined(separator: ","))
        }

        try lines.joined(separator: "\n").write(to: csvURL, atomically: true, encoding: .utf8)
        return csvURL
    }

    private static func escape(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") {
            return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return s
    }
}
