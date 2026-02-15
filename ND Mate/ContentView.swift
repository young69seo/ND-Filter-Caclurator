//
//  ContentView.swift
//  ND Mate
//
//  Created by Young Joo Seo on 15/2/2026.
//

import SwiftUI
import UserNotifications
import AudioToolbox

// 지원 언어 설정 (케이스 순서가 메뉴에 반영됨)
enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case korean = "ko"
    case chinese = "zh"
    case japanese = "ja"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .korean: return "한국어"
        case .chinese: return "简体中文"
        case .japanese: return "日本語"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .korean: return "🇰🇷"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        }
    }
}

// 지역화 텍스트 관리
struct Localized {
    static func string(_ key: String, lang: Language) -> String {
        let dict: [String: [Language: String]] = [
            "navTitle": [.english: "ND Mate", .korean: "ND Mate", .spanish: "ND Mate", .chinese: "ND Mate", .japanese: "ND Mate"],
            "currentSettings": [.english: "Current Settings", .korean: "현재 설정", .spanish: "Ajustes actuales", .chinese: "当前设置", .japanese: "現在の設定"],
            "ndFiltersTitle": [.english: "ND Filters (Up to 2)", .korean: "ND 필터 (최대 2개)", .spanish: "Filtros ND (máx. 2)", .chinese: "ND滤镜 (最多2个)", .japanese: "NDフィルター (最大2個)"],
            "calcResults": [.english: "Calculation Results", .korean: "계산 결과", .spanish: "Resultados", .chinese: "计算结果", .japanese: "計算結果"],
            "exposureTimer": [.english: "Exposure Timer", .korean: "노출 타이머", .spanish: "Temporizador", .chinese: "曝光计时器", .japanese: "露光タイマー"],
            "currentSpeed": [.english: "Current Shutter Speed", .korean: "현재 셔터 스피드", .spanish: "Vel. obturación", .chinese: "当前快门速度", .japanese: "現在のシャッタース피ード"],
            "firstFilter": [.english: "First Filter", .korean: "첫 번째 필터", .spanish: "Primer filtro", .chinese: "第一个滤镜", .japanese: "1番目のフィルター"],
            "secondFilter": [.english: "Second Filter", .korean: "두 번째 필터", .spanish: "Segundo filtro", .chinese: "第二个滤镜", .japanese: "2번目のフィルター"],
            "recSpeed": [.english: "Recommended Shutter Speed", .korean: "권장 셔터 스피드", .spanish: "Vel. recomendada", .chinese: "建议快门速度", .japanese: "推奨シャッタースピード"],
            "totalStops": [.english: "Total Reduction: %d Stops", .korean: "총 노출 감소: %d Stops", .spanish: "Reducción total: %d pasos", .chinese: "总减光: %d 档", .japanese: "合計減光量: %d 段"],
            "timerStart": [.english: "Start Timer", .korean: "타이머 시작", .spanish: "Iniciar", .chinese: "开始计时", .japanese: "타이머 시작"],
            "timerStop": [.english: "Stop", .korean: "중지", .spanish: "Detener", .chinese: "停止", .japanese: "停止"],
            "alertTitle": [.english: "Timer Finished", .korean: "타이머 종료", .spanish: "Tiempo agotado", .chinese: "计时结束", .japanese: "타이머 종료"],
            "alertMsg": [.english: "Exposure finished!", .korean: "설정된 노출 시간이 끝났습니다!", .spanish: "¡Exposición finalizada!", .chinese: "曝光完成！", .japanese: "露光가 완료되었습니다！"],
            "notUsed": [.english: "Not Used", .korean: "사용 안 함", .spanish: "No usado", .chinese: "不使用", .japanese: "使用하지 않는"],
            "minute": [.english: "min", .korean: "분", .spanish: "min", .chinese: "分", .japanese: "分"],
            "second": [.english: "sec", .korean: "초", .spanish: "seg", .chinese: "秒", .japanese: "秒"],
            "confirm": [.english: "OK", .korean: "확인", .spanish: "Aceptar", .chinese: "确定", .japanese: "確認"]
        ]
        return dict[key]?[lang] ?? key
    }
}

struct ShutterSpeed: Hashable {
    let name: String
    let seconds: Double
}

struct NDFilter: Hashable {
    let name: String
    let stops: Int
    var multiplier: Double { pow(2, Double(stops)) }
}

struct ContentView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: Language = .english
    
    let bgColor = Color(red: 0.95, green: 0.96, blue: 1.0) // pastel blueish
    let accentBlue = Color(red: 0.65, green: 0.78, blue: 0.98) // soft pastel blue
    let lightMint = Color(red: 0.85, green: 0.98, blue: 0.93) // pastel mint (lighter)
    
    let shutterSpeeds: [ShutterSpeed] = [
        ShutterSpeed(name: "1/8000", seconds: 1/8000),
        ShutterSpeed(name: "1/4000", seconds: 1/4000),
        ShutterSpeed(name: "1/2000", seconds: 1/2000),
        ShutterSpeed(name: "1/1000", seconds: 1/1000),
        ShutterSpeed(name: "1/500", seconds: 1/500),
        ShutterSpeed(name: "1/250", seconds: 1/250),
        ShutterSpeed(name: "1/125", seconds: 1/125),
        ShutterSpeed(name: "1/60", seconds: 1/60),
        ShutterSpeed(name: "1/30", seconds: 1/30),
        ShutterSpeed(name: "1/15", seconds: 1/15),
        ShutterSpeed(name: "1/8", seconds: 1/8),
        ShutterSpeed(name: "1/4", seconds: 1/4),
        ShutterSpeed(name: "1/2", seconds: 1/2),
        ShutterSpeed(name: "1\"", seconds: 1),
        ShutterSpeed(name: "2\"", seconds: 2),
        ShutterSpeed(name: "5\"", seconds: 5),
        ShutterSpeed(name: "10\"", seconds: 10),
        ShutterSpeed(name: "30\"", seconds: 30)
    ]
    
    var ndFilters: [NDFilter] {
        [
            NDFilter(name: Localized.string("notUsed", lang: selectedLanguage), stops: 0),
            NDFilter(name: "ND2 (1 Stop)", stops: 1),
            NDFilter(name: "ND4 (2 Stops)", stops: 2),
            NDFilter(name: "ND8 (3 Stops)", stops: 3),
            NDFilter(name: "ND16 (4 Stops)", stops: 4),
            NDFilter(name: "ND32 (5 Stops)", stops: 5),
            NDFilter(name: "ND64 (6 Stops)", stops: 6),
            NDFilter(name: "ND128 (7 Stops)", stops: 7),
            NDFilter(name: "ND256 (8 Stops)", stops: 8),
            NDFilter(name: "ND512 (9 Stops)", stops: 9),
            NDFilter(name: "ND1000 (10 Stops)", stops: 10),
            NDFilter(name: "ND32000 (15 Stops)", stops: 15),
            NDFilter(name: "ND1000000 (20 Stops)", stops: 20)
        ]
    }
    
    @State private var selectedShutterSpeed: ShutterSpeed
    @State private var selectedNDFilter1: NDFilter
    @State private var selectedNDFilter2: NDFilter
    
    @State private var remainingTime: Double = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var showAlert = false
    
    init() {
        let defaultSpeed = ShutterSpeed(name: "1/125", seconds: 1/125)
        let defaultND1 = NDFilter(name: "ND1000 (10 Stops)", stops: 10)
        let defaultND2 = NDFilter(name: "Not Used", stops: 0)
        _selectedShutterSpeed = State(initialValue: defaultSpeed)
        _selectedNDFilter1 = State(initialValue: defaultND1)
        _selectedNDFilter2 = State(initialValue: defaultND2)
    }
    
    var resultSeconds: Double {
        selectedShutterSpeed.seconds * selectedNDFilter1.multiplier * selectedNDFilter2.multiplier
    }
    
    var calculatedSpeedLabel: String {
        let totalSeconds = max(0, Int(round(resultSeconds)))
        let minText = Localized.string("minute", lang: selectedLanguage)
        let secText = Localized.string("second", lang: selectedLanguage)
        
        if totalSeconds >= 60 {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return seconds > 0 ? "\(minutes)\(minText) \(seconds)\(secText)" : "\(minutes)\(minText)"
        } else {
            return "\(totalSeconds)\(secText)"
        }
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView {
                Spacer()
                
                VStack(alignment: .leading, spacing: 22) {
                    // 헤더 (아이콘 + 제목)
                    HStack(spacing: 10) {
                        Image(systemName: "camera.shutter.button")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.15, green: 0.17, blue: 0.27))
                        
                        Text("ND Mate")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.15, green: 0.17, blue: 0.27)) // much darker pastel navy for contrast
                            .fontWeight(.heavy)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(Language.allCases) { lang in
                                Button(lang.displayName) { selectedLanguage = lang }
                            }
                        } label: {
                            Text(selectedLanguage.flag)
                                .font(.title2)
                                .padding(6)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 4)

                    Spacer()

                    // 현재 설정
                    VStack(alignment: .leading, spacing: 6) {
                        SectionHeader(title: Localized.string("currentSettings", lang: selectedLanguage))
                        CardView {
                            HStack {
                                Text(Localized.string("currentSpeed", lang: selectedLanguage))
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.22, green: 0.26, blue: 0.36)) // stronger secondary text
                                Spacer()
                                Menu {
                                    ForEach(shutterSpeeds, id: \.self) { speed in
                                        Button(speed.name) { selectedShutterSpeed = speed }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "camera.shutter.button.fill")
                                            .font(.caption)
                                        Text(selectedShutterSpeed.name)
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 0.17, green: 0.25, blue: 0.30)) // strong contrast for main functional text
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 10))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.05))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    // ND 필터
                    VStack(alignment: .leading, spacing: 6) {
                        SectionHeader(title: Localized.string("ndFiltersTitle", lang: selectedLanguage))
                        CardView {
                            VStack(spacing: 12) {
                                FilterRow(label: Localized.string("firstFilter", lang: selectedLanguage), 
                                          selection: $selectedNDFilter1, 
                                          filters: ndFilters, 
                                          icon: "camera.filters")
                                Divider()
                                FilterRow(label: Localized.string("secondFilter", lang: selectedLanguage), 
                                          selection: $selectedNDFilter2, 
                                          filters: ndFilters, 
                                          icon: "camera.filters")
                            }
                        }
                    }
                    
                    // 결과
                    VStack(alignment: .leading, spacing: 6) {
                        SectionHeader(title: Localized.string("calcResults", lang: selectedLanguage))
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(Localized.string("recSpeed", lang: selectedLanguage))
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.22, green: 0.26, blue: 0.36)) // stronger secondary
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "timer")
                                            .foregroundColor(Color(red: 0.17, green: 0.25, blue: 0.30))
                                        Text(calculatedSpeedLabel)
                                            .foregroundColor(Color(red: 0.17, green: 0.25, blue: 0.30))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(lightMint)
                                    .clipShape(Capsule())
                                    .font(.callout.bold())
                                }
                                
                                let totalStops = selectedNDFilter1.stops + selectedNDFilter2.stops
                                if totalStops > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text(String(format: Localized.string("totalStops", lang: selectedLanguage), totalStops))
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.33, green: 0.36, blue: 0.43)) // updated lighter pastel secondary
                                    }
                                }
                            }
                        }
                    }
                    
                    // 타이머
                    if resultSeconds >= 30 {
                        VStack(alignment: .leading, spacing: 6) {
                            SectionHeader(title: Localized.string("exposureTimer", lang: selectedLanguage))
                            CardView {
                                VStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.03))
                                            .frame(height: 100)
                                        
                                        Text(formatTime(remainingTime > 0 ? remainingTime : resultSeconds))
                                            .font(.system(size: 50, weight: .medium, design: .monospaced))
                                            .foregroundColor(Color(red: 0.17, green: 0.25, blue: 0.30)) // stronger contrast
                                    }
                                    
                                    Button(action: toggleTimer) {
                                        Text(isTimerRunning ? Localized.string("timerStop", lang: selectedLanguage) : Localized.string("timerStart", lang: selectedLanguage))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(isTimerRunning ? Color.red.opacity(0.7) : accentBlue)
                                            .clipShape(Capsule())
                                            .shadow(color: accentBlue.opacity(0.2), radius: 8, x: 0, y: 4)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal)
                .padding(.top, 5)
            }
        }
        .onAppear(perform: requestNotificationPermission)
        .alert(Localized.string("alertTitle", lang: selectedLanguage), isPresented: $showAlert) {
            Button(Localized.string("confirm", lang: selectedLanguage), role: .cancel) { }
        } message: {
            Text(Localized.string("alertMsg", lang: selectedLanguage))
        }
    }
    
    // MARK: - Helper Views
    
    private func SectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color(red: 0.25, green: 0.29, blue: 0.43)) // darker pastel lavender-gray
            .fontWeight(.bold)
            .padding(.leading, 4)
    }
    
    private func CardView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color(red: 0.98, green: 0.99, blue: 1.0)) // near-white pastel
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
    
    private func FilterRow(label: String, selection: Binding<NDFilter>, filters: [NDFilter], icon: String) -> some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundColor(Color(red: 0.15, green: 0.17, blue: 0.27)) // unified strong pastel navy color
            Spacer()
            Menu {
                ForEach(filters, id: \.self) { filter in
                    Button(filter.name) { selection.wrappedValue = filter }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.caption)
                    Text(selection.wrappedValue.name)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.17, green: 0.25, blue: 0.30)) // strong contrast for main text
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(lightMint)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Functions
    func formatTime(_ seconds: Double) -> String {
        let totalSeconds = max(0, Int(round(seconds)))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    func toggleTimer() { if isTimerRunning { stopTimer() } else { startTimer() } }
    
    func startTimer() {
        remainingTime = resultSeconds
        isTimerRunning = true
        scheduleNotification(after: resultSeconds)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime >= 1.0 { remainingTime -= 1.0 } else { timerFinished() }
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        remainingTime = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func timerFinished() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        remainingTime = 0
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        showAlert = true
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func scheduleNotification(after seconds: Double) {
        let content = UNMutableNotificationContent()
        content.title = Localized.string("navTitle", lang: selectedLanguage)
        content.body = Localized.string("alertMsg", lang: selectedLanguage)
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)
        let request = UNNotificationRequest(identifier: "ExposureFinished", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    ContentView()
}

