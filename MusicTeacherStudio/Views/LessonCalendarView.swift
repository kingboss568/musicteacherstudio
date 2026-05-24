import SwiftUI
import SwiftData

struct LessonCalendarView: View {
    @Query(sort: \Lesson.scheduledStart) private var lessons: [Lesson]
    @Query private var students: [Student]
    @State private var showAdd = false
    @State private var studentFilter: UUID?

    private var filtered: [Lesson] {
        if let sid = studentFilter { return lessons.filter { $0.studentID == sid } }
        return lessons
    }

    private var grouped: [(String, [Lesson])] {
        let dict = Dictionary(grouping: filtered) { DateFormatterUtility.dayKey($0.scheduledStart) }
        return dict.sorted { $0.key > $1.key }.map { ($0.key, $0.value.sorted { $0.scheduledStart < $1.scheduledStart }) }
    }

    var body: some View {
        Group {
            if filtered.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "還沒有任何課程",
                    subtitle: "新增單次課程，\n或從學生詳情頁設定固定課表。",
                    actionTitle: "新增課程",
                    action: {
                        Haptics.light()
                        showAdd = true
                    },
                    assetName: "EmptyLessons"
                )
            } else {
                lessonList
            }
        }
        .navigationTitle("課表")
        .toolbar { toolbarContent }
        .sheet(isPresented: $showAdd) {
            NavigationStack { LessonEditorView() }
        }
    }

    private var lessonList: some View {
        List {
            ForEach(grouped, id: \.0) { day, items in
                Section(day) {
                    ForEach(items) { lesson in
                        NavigationLink {
                            LessonNoteView(lesson: lesson)
                        } label: {
                            HStack(spacing: Brand.Space.m) {
                                if let s = student(for: lesson.studentID) {
                                    StudentAvatar(name: s.name, instrument: s.instrument, size: 40)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(studentName(for: lesson.studentID)).font(Brand.Font.bodyEmphasis)
                                    Text("\(DateFormatterUtility.timeString(lesson.scheduledStart)) – \(DateFormatterUtility.timeString(lesson.scheduledEnd))")
                                        .font(Brand.Font.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                statusBadge(lesson.status)
                            }
                        }
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button("全部") { studentFilter = nil }
                ForEach(students) { s in
                    Button(s.name) { studentFilter = s.id }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Haptics.light()
                showAdd = true
            } label: { Image(systemName: "plus") }
        }
    }

    private func statusBadge(_ status: LessonStatus) -> some View {
        let tint: Color = {
            switch status {
            case .scheduled: return Brand.primary
            case .attended:  return Brand.success
            case .cancelled: return .gray
            case .noShow:    return Brand.danger
            }
        }()
        return Text(status.displayName)
            .font(.system(size: 11, weight: .semibold))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(tint.opacity(0.15)))
            .foregroundStyle(tint)
    }

    private func student(for id: UUID) -> Student? {
        students.first { $0.id == id }
    }

    private func studentName(for id: UUID) -> String {
        students.first { $0.id == id }?.name ?? "未知學生"
    }
}

#Preview {
    NavigationStack { LessonCalendarView() }
        .modelContainer(PreviewData.makeContainer())
}
