import SwiftUI
import AVFoundation

/// 內建節拍器 + 調音音叉。免費版：節拍器 60–160 BPM、四種音 (A/D/G/E)。
/// Pro：自訂拍號、子拍切換、A4 微調、所有十二音。
struct TunerMetronomeView: View {
    @EnvironmentObject private var store: StoreKitManager
    @State private var bpm: Double = 90
    @State private var isRunning = false
    @State private var tickToggle = false
    @State private var timer: Timer?
    @State private var beatsPerBar: Int = 4
    @State private var currentBeat: Int = 0
    @State private var tunerNote: String = "A4"
    @State private var a4Hz: Double = 440
    @State private var showPaywall = false

    private let freeNotes = ["A4", "D4", "G3", "E4"]
    private let allNotes = ["C4","C#4","D4","D#4","E4","F4","F#4","G4","G#4","A4","A#4","B4"]

    var body: some View {
        ScrollView {
            VStack(spacing: Brand.Space.l) {
                metronomeCard
                tunerCard
            }
            .padding(Brand.Space.l)
        }
        .background(Brand.surface.ignoresSafeArea())
        .navigationTitle("節拍器 / 調音")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .onDisappear { stop() }
    }

    // MARK: - Metronome

    private var metronomeCard: some View {
        BrandCard {
            VStack(spacing: Brand.Space.l) {
                BrandSectionHeader(title: "節拍器", subtitle: "\(Int(bpm)) BPM · \(beatsPerBar)/4 拍")

                // Beat dots
                HStack(spacing: 8) {
                    ForEach(0..<beatsPerBar, id: \.self) { i in
                        Circle()
                            .fill(i == currentBeat && isRunning ? Brand.primary : Brand.primary.opacity(0.18))
                            .frame(width: 16, height: 16)
                            .scaleEffect(i == currentBeat && isRunning ? 1.4 : 1.0)
                            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: currentBeat)
                    }
                }

                // BPM ring control
                ZStack {
                    Circle().stroke(Brand.primary.opacity(0.15), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: max(0.001, (bpm - 40) / (240 - 40)))
                        .stroke(Brand.heroGradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack {
                        Text("\(Int(bpm))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Brand.ink)
                        Text("BPM").font(Brand.Font.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(width: 180, height: 180)

                Slider(value: $bpm,
                       in: store.isPro ? 40...240 : 60...160,
                       step: 1) {
                    Text("BPM")
                } onEditingChanged: { _ in
                    if isRunning { restart() }
                }
                .tint(Brand.primary)

                HStack(spacing: 12) {
                    ForEach([2, 3, 4, 6], id: \.self) { n in
                        Button("\(n)/4") {
                            if !store.isPro && n != 4 {
                                showPaywall = true
                                return
                            }
                            beatsPerBar = n; currentBeat = 0
                        }
                        .font(Brand.Font.captionEmphasis)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(
                            Capsule().fill(beatsPerBar == n ? Brand.primary.opacity(0.2) : Color.clear)
                        )
                        .foregroundStyle(beatsPerBar == n ? Brand.primary : .secondary)
                    }
                }

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if isRunning { stop() } else { start() }
                } label: {
                    Label(isRunning ? "停止" : "開始", systemImage: isRunning ? "stop.fill" : "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    // MARK: - Tuner

    private var tunerCard: some View {
        BrandCard {
            VStack(spacing: Brand.Space.m) {
                BrandSectionHeader(title: "調音音叉", subtitle: "標準 A4 = \(Int(a4Hz)) Hz")
                let notes = store.isPro ? allNotes : freeNotes
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(notes, id: \.self) { note in
                        Button {
                            tunerNote = note
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            playTone(noteName: note, durationMs: 1500)
                        } label: {
                            Text(note)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(tunerNote == note ? Brand.primary : Color(.tertiarySystemFill))
                                )
                                .foregroundStyle(tunerNote == note ? .white : Brand.ink)
                        }
                        .buttonStyle(.plain)
                    }
                }
                if !store.isPro {
                    HStack {
                        ProBadge()
                        Text("Pro 解鎖 12 音 + A4 微調")
                            .font(Brand.Font.caption).foregroundStyle(.secondary)
                        Spacer()
                        Button("升級") { showPaywall = true }
                            .font(Brand.Font.captionEmphasis)
                            .foregroundStyle(Brand.primary)
                    }
                } else {
                    HStack {
                        Text("A4 微調").font(Brand.Font.caption).foregroundStyle(.secondary)
                        Slider(value: $a4Hz, in: 415...466, step: 0.5).tint(Brand.accent)
                        Text("\(Int(a4Hz)) Hz").font(.caption.monospacedDigit())
                    }
                }
            }
        }
    }

    // MARK: - Audio engine

    private func start() {
        isRunning = true
        scheduleTimer()
    }
    private func stop() {
        isRunning = false
        timer?.invalidate(); timer = nil
        currentBeat = 0
    }
    private func restart() { stop(); start() }

    private func scheduleTimer() {
        let interval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            currentBeat = (currentBeat + 1) % beatsPerBar
            playClick(accent: currentBeat == 0)
        }
        playClick(accent: true)
    }

    private static var audioPlayers: [AVAudioPlayer] = []

    private func playClick(accent: Bool) {
        AudioServicesPlaySystemSound(accent ? 1057 : 1104) // built-in short clicks
    }

    private func playTone(noteName: String, durationMs: Int) {
        guard let freq = Self.frequency(for: noteName, a4: a4Hz) else { return }
        Self.playSineTone(frequency: freq, durationMs: durationMs)
    }

    // MARK: - Tone synthesis

    private static func frequency(for note: String, a4: Double) -> Double? {
        // Note semitone offsets from A4
        let map: [String: Int] = [
            "C": -9, "C#": -8, "D": -7, "D#": -6, "E": -5, "F": -4,
            "F#": -3, "G": -2, "G#": -1, "A": 0, "A#": 1, "B": 2
        ]
        guard let octIdx = note.firstIndex(where: { $0.isNumber }) else { return nil }
        let pitchName = String(note[..<octIdx])
        let oct = Int(note[octIdx...]) ?? 4
        guard let semis = map[pitchName] else { return nil }
        let n = semis + (oct - 4) * 12
        return a4 * pow(2.0, Double(n) / 12.0)
    }

    /// Generates a short sine-wave AVAudioPlayer and plays it.
    static func playSineTone(frequency: Double, durationMs: Int = 1200) {
        let sampleRate = 44_100.0
        let totalSamples = Int(sampleRate * Double(durationMs) / 1000.0)
        let attack = min(2_000, totalSamples / 8)
        let release = min(6_000, totalSamples / 3)

        var samples = [Int16](repeating: 0, count: totalSamples)
        for i in 0..<totalSamples {
            var env: Double = 1
            if i < attack { env = Double(i) / Double(attack) }
            else if i > totalSamples - release { env = Double(totalSamples - i) / Double(release) }
            let v = sin(2 * .pi * frequency * Double(i) / sampleRate) * env * 0.4
            samples[i] = Int16(v * Double(Int16.max))
        }

        // Build a minimal WAV in memory
        var data = Data()
        let byteRate: UInt32 = UInt32(sampleRate) * 2
        let dataSize: UInt32 = UInt32(samples.count * 2)
        let chunkSize: UInt32 = 36 + dataSize
        func appendStr(_ s: String) { data.append(contentsOf: s.utf8) }
        func appendU32LE(_ v: UInt32) {
            var le = v.littleEndian
            withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
        }
        func appendU16LE(_ v: UInt16) {
            var le = v.littleEndian
            withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
        }
        appendStr("RIFF"); appendU32LE(chunkSize); appendStr("WAVE")
        appendStr("fmt "); appendU32LE(16); appendU16LE(1); appendU16LE(1)
        appendU32LE(UInt32(sampleRate)); appendU32LE(byteRate); appendU16LE(2); appendU16LE(16)
        appendStr("data"); appendU32LE(dataSize)
        samples.withUnsafeBufferPointer { buf in
            data.append(UnsafeBufferPointer(start: UnsafePointer<UInt8>(OpaquePointer(buf.baseAddress)),
                                            count: buf.count * 2))
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
            let player = try AVAudioPlayer(data: data)
            player.prepareToPlay()
            player.play()
            audioPlayers.append(player)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationMs)/1000 + 0.5) {
                audioPlayers.removeAll { $0 === player }
            }
        } catch {
            // ignore
        }
    }
}

#Preview {
    NavigationStack { TunerMetronomeView() }
        .environmentObject(StoreKitManager.shared)
}
