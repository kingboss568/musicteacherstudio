import SwiftUI
import SwiftData
import Charts

/// v2.0 升級首頁：Hero + 今日 ring + KPI 卡 + 趨勢圖 + 行動快捷。
struct DashboardView: View {
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var store: StoreKitManager
    @Query private var students: [Student]
    @Query(sort: \Lesson.scheduledStart, order: .forward) private var lessons: [Lesson]
    @Query private var assignments: [Assignment]

    @State private var showStudentEditor = false
    @State private var showLessonEditor = false
    @State private var showPaywall = false

    private let analytics = AnalyticsService()

    private var daysBack: Int {
        store.hasEntitlement(.advancedAnalytics) ? 30 : FreeLimits.analyticsDaysBack
    }

    private var todayLessons: [Lesson] {
        let cal = Calendar.current
        return lessons.filter { cal.isDateInToday($0.scheduledStart) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Brand.Space.l) {
                heroCard
                kpiRow
                todayCard
                trendCard
                shortcutsCard
            }
            .padding(.horizontal, Brand.Space.l)
            .padding(.bottom, Brand.Space.xxxl)
        }
        .background(Brand.surface.ignoresSafeArea())
        .navigationTitle(Brand.Strings.productName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !store.isPro {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("升級 Pro", systemImage: "crown.fill")
                            .font(Brand.Font.captionEmphasis)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(Brand.goldGradient))
                    }
                }
            }
        }
        .sheet(isPresented: $showStudentEditor) { NavigationStack { StudentEditorView() } }
        .sheet(isPresented: $showLessonEditor) { NavigationStack { LessonEditorView() } }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    // MARK: - Hero

    private var heroCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Brand.Radius.xl, style: .continuous)
                .fill(Brand.heroGradient)
            VStack(alignment: .leading, spacing: Brand.Space.s) {
                Text(greeting())
                    .font(Brand.Font.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Text(Brand.Strings.tagline)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 16) {
                    heroMetric("今天", "\(todayLessons.count) 堂課")
                    Divider().frame(height: 26).overlay(.white.opacity(0.35))
                    heroMetric("本月學生", "\(students.filter(\.isActive).count) 位")
                }
                .padding(.top, 4)
            }
            .padding(Brand.Space.xl)
        }
        .shadow(color: Brand.primary.opacity(0.25), radius: 18, x: 0, y: 12)
    }

    private func heroMetric(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 11)).foregroundStyle(.white.opacity(0.8))
            Text(value).font(Brand.Font.bodyEmphasis).foregroundStyle(.white)
        }
    }

    private func greeting() -> String {
        let h = Calendar.current.component(.hour, from: .now)
        switch h {
        case 5..<11:  return "早安，老師"
        case 11..<14: return "午安，老師"
        case 14..<18: return "下午好，老師"
        case 18..<22: return "晚安，老師"
        default:      return "辛苦了，老師"
        }
    }

    // MARK: - KPI row

    private var kpiRow: some View {
        let outstanding = analytics.totalOutstandingCents(students: students, lessons: lessons)
        let openA = assignments.filter { $0.status == .open }.count
        let attendedThisWeek = lessons.filter {
            $0.status == .attended &&
            Calendar.current.isDate($0.scheduledStart, equalTo: .now, toGranularity: .weekOfYear)
        }.count
        return HStack(spacing: Brand.Space.m) {
            StatChip(icon: "checkmark.seal.fill", title: "本週出席", value: "\(attendedThisWeek)", tint: Brand.success)
            StatChip(icon: "doc.text.fill", title: "未完作業", value: "\(openA)", tint: Brand.primary)
            StatChip(icon: "exclamationmark.triangle.fill",
                     title: "待收款",
                     value: MoneyFormatter.string(fromCents: outstanding),
                     tint: outstanding > 0 ? Brand.danger : Brand.success)
        }
    }

    // MARK: - Today

    private var todayCard: some View {
        BrandCard {
            HStack(alignment: .center, spacing: Brand.Space.l) {
                ProgressRing(
                    progress: analytics.todayProgress(lessons: lessons),
                    label: "今日完成度",
                    value: "\(Int(analytics.todayProgress(lessons: lessons) * 100))%"
                )
                VStack(alignment: .leading, spacing: 6) {
                BrandSectionHeader(title: "今日課程", subtitle: "\(todayLessons.count) 堂")
                    if todayLessons.isEmpty {
                        Text("今天沒有課，可以整理一下學生進度。")
                            .font(Brand.Font.caption).foregroundStyle(.secondary)
                    } else {
                        ForEach(todayLessons.prefix(3)) { lesson in
                            HStack {
                                Text(DateFormatterUtility.timeString(lesson.scheduledStart))
                                    .font(Brand.Font.captionEmphasis)
                                    .foregroundStyle(Brand.primary)
                                Text(students.first { $0.id == lesson.studentID }?.name ?? "—")
                                    .font(Brand.Font.body)
                                Spacer()
                                Text(lesson.status.displayName)
                                    .font(Brand.Font.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if todayLessons.count > 3 {
                            Text("還有 \(todayLessons.count - 3) 堂…")
                                .font(Brand.Font.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Trend chart

    private var trendCard: some View {
        let series = analytics.dailySeries(lessons: lessons, daysBack: daysBack)
        return BrandCard {
            VStack(alignment: .leading, spacing: Brand.Space.s) {
                BrandSectionHeader(
                    title: "出席趨勢",
                    subtitle: store.isPro ? "最近 30 天" : "免費版顯示 7 天",
                    accessory: AnyView(
                        Group {
                            if !store.isPro { ProBadge() }
                        }
                    )
                )
                Chart {
                    ForEach(series) { p in
                        BarMark(
                            x: .value("日", p.day, unit: .day),
                            y: .value("出席", p.attended)
                        )
                        .foregroundStyle(Brand.primary)
                        BarMark(
                            x: .value("日", p.day, unit: .day),
                            y: .value("缺席", p.noShow)
                        )
                        .foregroundStyle(Brand.danger.opacity(0.8))
                        BarMark(
                            x: .value("日", p.day, unit: .day),
                            y: .value("取消", p.cancelled)
                        )
                        .foregroundStyle(Brand.warning.opacity(0.8))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, daysBack / 7))) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day(), centered: true)
                    }
                }
                .frame(height: 180)
                HStack(spacing: 14) {
                    Legend(color: Brand.primary, label: "出席")
                    Legend(color: Brand.danger.opacity(0.8), label: "缺席")
                    Legend(color: Brand.warning.opacity(0.8), label: "取消")
                }
                .font(Brand.Font.caption)
                .foregroundStyle(.secondary)
            }
        }
        .proLock(!store.isPro && daysBack < 30) { showPaywall = true }
    }

    // MARK: - Shortcuts grid

    private var shortcutsCard: some View {
        BrandCard {
            VStack(alignment: .leading, spacing: Brand.Space.m) {
                BrandSectionHeader(title: "快速操作")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ShortcutTile(icon: "person.badge.plus", title: "新增學生", tint: Brand.primary) {
                        guardStudentLimit { showStudentEditor = true }
                    }
                    ShortcutTile(icon: "calendar.badge.plus", title: "新增課程", tint: Brand.success) {
                        showLessonEditor = true
                    }
                    NavigationLink {
                        TunerMetronomeView()
                    } label: {
                        ShortcutTileLabel(icon: "tuningfork", title: "節拍器 / 調音", tint: Brand.accent)
                    }
                    NavigationLink {
                        BatchMessageView()
                    } label: {
                        ShortcutTileLabel(icon: "envelope.badge.fill", title: "批次家長訊息", tint: Brand.warning,
                                          locked: !store.isPro)
                    }
                }
            }
        }
    }

    private func guardStudentLimit(_ action: () -> Void) {
        if !store.isPro && students.count >= FreeLimits.maxStudents {
            showPaywall = true
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        action()
    }
}

// MARK: - Shortcuts

private struct ShortcutTile: View {
    let icon: String; let title: String; let tint: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            ShortcutTileLabel(icon: icon, title: title, tint: tint)
        }.buttonStyle(.plain)
    }
}

private struct ShortcutTileLabel: View {
    let icon: String; let title: String; let tint: Color
    var locked: Bool = false
    var body: some View {
        HStack(spacing: Brand.Space.m) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 10).fill(tint))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Brand.Font.bodyEmphasis).foregroundStyle(Brand.ink)
                if locked { ProBadge(label: "Pro").scaleEffect(0.85, anchor: .leading) }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
        }
        .padding(Brand.Space.m)
        .background(
            RoundedRectangle(cornerRadius: Brand.Radius.m, style: .continuous)
                .fill(Color(.tertiarySystemFill))
        )
    }
}

private struct Legend: View {
    let color: Color; let label: String
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }
}

#Preview {
    NavigationStack { DashboardView() }
        .modelContainer(PreviewData.makeContainer())
        .environmentObject(StoreKitManager.shared)
}
