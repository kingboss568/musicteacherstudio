import Foundation
import UIKit

struct StudentProgressReportRenderer {
    /// Free / Pro toggles. Free users get a discreet watermark; Pro can add brand color + bilingual.
    var includeWatermark: Bool = true
    var brandColor: UIColor = UIColor(red: 0.31, green: 0.18, blue: 0.85, alpha: 1)
    var teacherStudioName: String? = nil
    var bilingual: Bool = false

    /// Renders a learning-history PDF to `Documents/Reports/`.
    /// MVP: payment / outstanding balance info is NOT included by default.
    func renderProgressReport(
        student: Student,
        lessons: [Lesson],
        assignments: [Assignment],
        recordings: [PracticeRecording]
    ) throws -> URL {
        let reportsDir = try FileStorageUtility.ensureSubdirectory("Reports")
        let dateStr = DateFormatterUtility.fileDateString(Date())
        let safeName = student.name.replacingOccurrences(of: "/", with: "_")
        let fileName = "\(safeName)_\(dateStr).pdf"
        let outURL = reportsDir.appendingPathComponent(fileName)

        let pageSize = CGSize(width: 612, height: 792) // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        try renderer.writePDF(to: outURL) { ctx in
            ctx.beginPage()
            // Top brand bar
            let barH: CGFloat = 36
            brandColor.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: pageSize.width, height: barH)).fill()
            let barAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let studio = teacherStudioName ?? "音律手帳 · MusicTeacher Studio"
            NSAttributedString(string: studio, attributes: barAttrs)
                .draw(in: CGRect(x: 40, y: 10, width: pageSize.width - 80, height: 20))

            let margin: CGFloat = 40
            var y: CGFloat = barH + 20
            let contentWidth = pageSize.width - margin * 2

            func draw(_ text: String, font: UIFont, color: UIColor = .label) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let str = NSAttributedString(string: text, attributes: attrs)
                let bounds = str.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )
                if y + bounds.height > pageSize.height - margin {
                    ctx.beginPage()
                    y = margin
                }
                str.draw(in: CGRect(x: margin, y: y, width: contentWidth, height: bounds.height))
                y += bounds.height + 6
            }

            draw(bilingual ? "學生學習歷程 / Learning Progress Report" : "學生學習歷程",
                 font: .systemFont(ofSize: 22, weight: .bold))
            draw(bilingual ? "學生姓名 / Student: \(student.name)" : "學生姓名：\(student.name)",
                 font: .systemFont(ofSize: 14))
            draw(bilingual ? "樂器 / Instrument: \(student.instrument)" : "樂器：\(student.instrument)",
                 font: .systemFont(ofSize: 14))
            if let level = student.level {
                draw(bilingual ? "程度 / Level: \(level)" : "程度：\(level)",
                     font: .systemFont(ofSize: 14))
            }
            draw(bilingual ? "報表日期 / Report date: \(DateFormatterUtility.dateString(Date()))" : "報表日期：\(DateFormatterUtility.dateString(Date()))",
                 font: .systemFont(ofSize: 14))
            y += 8

            draw(bilingual ? "最近課程 / Recent Lessons" : "最近課程",
                 font: .systemFont(ofSize: 18, weight: .semibold))
            let sortedLessons = lessons
                .filter { $0.studentID == student.id }
                .sorted { $0.scheduledStart > $1.scheduledStart }
                .prefix(10)
            if sortedLessons.isEmpty {
                draw("（尚無課程紀錄）", font: .systemFont(ofSize: 13, weight: .regular), color: .secondaryLabel)
            } else {
                for lesson in sortedLessons {
                    let line = "\(DateFormatterUtility.dateTimeString(lesson.scheduledStart))・\(lesson.status.displayName)"
                    draw(line, font: .systemFont(ofSize: 13))
                    if let note = lesson.teacherNote, !note.isEmpty {
                        draw(bilingual ? "　筆記 / Note: \(note)" : "　筆記：\(note)",
                             font: .systemFont(ofSize: 12), color: .secondaryLabel)
                    }
                }
            }
            y += 8

            draw(bilingual ? "作業 / Assignments" : "作業",
                 font: .systemFont(ofSize: 18, weight: .semibold))
            let studentAssignments = assignments.filter { $0.studentID == student.id }
            if studentAssignments.isEmpty {
                draw("（尚無作業）", font: .systemFont(ofSize: 13), color: .secondaryLabel)
            } else {
                for a in studentAssignments {
                    draw("・\(a.title)（\(a.status.displayName)）", font: .systemFont(ofSize: 13))
                    if !a.instruction.isEmpty {
                        draw("　\(a.instruction)", font: .systemFont(ofSize: 12), color: .secondaryLabel)
                    }
                }
            }
            y += 8

            draw(bilingual ? "錄音回饋 / Recording Feedback" : "錄音回饋",
                 font: .systemFont(ofSize: 18, weight: .semibold))
            let studentRecordings = recordings.filter { $0.studentID == student.id }
            if studentRecordings.isEmpty {
                draw("（尚無錄音）", font: .systemFont(ofSize: 13), color: .secondaryLabel)
            } else {
                for r in studentRecordings {
                    draw("・\(DateFormatterUtility.dateString(r.recordedAt))・\(r.originalFileName ?? "錄音")",
                         font: .systemFont(ofSize: 13))
                    if let fb = r.teacherFeedback, !fb.isEmpty {
                        draw("　回饋：\(fb)", font: .systemFont(ofSize: 12), color: .secondaryLabel)
                    }
                }
            }

            // Watermark (free tier)
            if includeWatermark {
                let wmAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 56, weight: .heavy),
                    .foregroundColor: UIColor.systemGray.withAlphaComponent(0.10)
                ]
                let wm = NSAttributedString(string: "音律手帳 試用版", attributes: wmAttrs)
                let size = wm.size()
                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: pageSize.width / 2, y: pageSize.height / 2)
                ctx.cgContext.rotate(by: -.pi / 6)
                wm.draw(at: CGPoint(x: -size.width / 2, y: -size.height / 2))
                ctx.cgContext.restoreGState()
            }
        }
        return outURL
    }
}
