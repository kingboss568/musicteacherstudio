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
        List {
            ForEach(grouped, id: \.0) { day, items in
                Section(day) {
                    ForEach(items) { lesson in
                        NavigationLink {
                            LessonNoteView(lesson: lesson)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(studentName(for: lesson.studentID)).font(.headline)
                                    Text("\(DateFormatterUtility.timeString(lesson.scheduledStart)) – \(DateFormatterUtility.timeString(lesson.scheduledEnd))")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(lesson.status.displayName).font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("課表")
        .toolbar {
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
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack { LessonEditorView() }
        }
    }

    private func studentName(for id: UUID) -> String {
        students.first { $0.id == id }?.name ?? "未知學生"
    }
}

#Preview {
    NavigationStack { LessonCalendarView() }
        .modelContainer(PreviewData.makeContainer())
}
