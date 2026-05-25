//
//  RouletteHomeView.swift
//  simpleRulette
//

import SwiftUI

struct RouletteHomeView: View {
    @StateObject private var viewModel = RouletteHomeViewModel()
    @State private var isShowingHelp = false
    @State private var isShowingEditor = false
    @State private var isShowingHistory = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.99, green: 0.98, blue: 0.96), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    headerView
                    hintView
                    wheelSection
                    resultView
                    spinButton
                    bottomActions
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 30)
            }
        }
        .alert(isPresented: $isShowingHelp) {
            Alert(
                title: Text(NSLocalizedString("rouletteHelpTitle", comment: "")),
                message: Text(NSLocalizedString("rouletteHelpBody", comment: "")),
                dismissButton: .default(Text(NSLocalizedString("close", comment: "")))
            )
        }
        .sheet(isPresented: $isShowingEditor) {
            RouletteEditorView(items: viewModel.items) { items in
                viewModel.updateItems(items)
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            RouletteHistoryView(history: viewModel.history)
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()

            Text(viewModel.title)
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(Color(red: 0.19, green: 0.19, blue: 0.20))

            Spacer()

            Button(action: {
                isShowingHelp = true
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(Color.gray.opacity(0.78))
            }
        }
    }

    private var hintView: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(red: 0.67, green: 0.82, blue: 0.60))
                .frame(width: 10, height: 10)

            Text(NSLocalizedString("rouletteTapHint", comment: ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var wheelSection: some View {
        ZStack(alignment: .top) {
            RouletteWheelView(
                items: viewModel.items,
                rotationAngle: viewModel.rotationAngle,
                colors: viewModel.palette
            )
            .frame(width: 330, height: 330)
            .contentShape(Circle())
            .onTapGesture {
                viewModel.toggleSpin()
            }

            PointerTriangle()
                .fill(Color(red: 0.86, green: 0.30, blue: 0.27))
                .frame(width: 32, height: 40)
                .overlay(
                    PointerTriangle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
                .offset(y: -18)
        }
        .padding(.top, 10)
    }

    private var resultView: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Rectangle()
                    .fill(Color.gray.opacity(0.18))
                    .frame(height: 1)

                Text(NSLocalizedString("rouletteResultTitle", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)

                Rectangle()
                    .fill(Color.gray.opacity(0.18))
                    .frame(height: 1)
            }

            Text(viewModel.resultText)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0.19, green: 0.19, blue: 0.20))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
        .padding(.top, 2)
    }

    private var spinButton: some View {
        Button(action: {
            viewModel.toggleSpin()
        }) {
            HStack(spacing: 14) {
                Image(systemName: viewModel.isSpinning ? "pause.circle" : "arrow.clockwise")
                    .font(.system(size: 22, weight: .semibold))

                Text(viewModel.isSpinning ? NSLocalizedString("rouletteStopButton", comment: "") : NSLocalizedString("rouletteSpinButton", comment: ""))
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 84)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.86, green: 0.57, blue: 0.55), Color(red: 0.88, green: 0.64, blue: 0.59)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color(red: 0.81, green: 0.58, blue: 0.53).opacity(0.35), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 6)
    }

    private var bottomActions: some View {
        HStack(spacing: 0) {
            Button(action: {
                isShowingEditor = true
            }) {
                Label(NSLocalizedString("rouletteEditItems", comment: ""), systemImage: "pencil")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }

            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 1, height: 24)

            Button(action: {
                isShowingHistory = true
            }) {
                Label(NSLocalizedString("rouletteHistory", comment: ""), systemImage: "clock")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

final class RouletteHomeViewModel: ObservableObject {
    @Published var title: String
    @Published var items: [String]
    @Published var resultText: String
    @Published var history: [String] = []
    @Published var isSpinning = false
    @Published var rotationAngle = 0.0

    let palette: [Color] = [
        Color(red: 0.96, green: 0.85, blue: 0.80),
        Color(red: 0.96, green: 0.90, blue: 0.76),
        Color(red: 0.97, green: 0.89, blue: 0.67),
        Color(red: 0.87, green: 0.90, blue: 0.73),
        Color(red: 0.78, green: 0.89, blue: 0.84),
        Color(red: 0.75, green: 0.86, blue: 0.94),
        Color(red: 0.83, green: 0.80, blue: 0.92),
        Color(red: 0.95, green: 0.84, blue: 0.88)
    ]

    private var spinTimer: Timer?

    init() {
        let savedRoulette = RuletteViewModel().fetchAllData().first
        let savedItems = savedRoulette?.ruletteItems.map(\.item).filter { !$0.isEmpty }

        title = (savedRoulette?.title.isEmpty == false ? savedRoulette?.title : nil) ?? NSLocalizedString("rouletteScreenTitle", comment: "")
        items = (savedItems?.count ?? 0) >= 2 ? (savedItems ?? []) : ["映画", "カフェ", "散歩", "読書", "勉強", "運動", "昼寝", "買い物"]
        resultText = NSLocalizedString("rouletteInitialResult", comment: "")
    }

    func toggleSpin() {
        guard items.count >= 2 else {
            resultText = NSLocalizedString("setData", comment: "")
            return
        }

        if isSpinning {
            stopSpin()
        } else {
            startSpin()
        }
    }

    func updateItems(_ updatedItems: [String]) {
        let filtered = updatedItems
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard filtered.count >= 2 else {
            return
        }

        items = filtered
        resultText = NSLocalizedString("rouletteInitialResult", comment: "")
        history.removeAll()
        rotationAngle = 0
        stopTimer()
        isSpinning = false
    }

    private func startSpin() {
        stopTimer()
        isSpinning = true
        resultText = NSLocalizedString("tapRuletteToStop", comment: "")

        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.rotationAngle += 9
        }
    }

    private func stopSpin() {
        stopTimer()
        isSpinning = false

        let winningIndex = Int.random(in: 0..<items.count)
        let sectionAngle = 360.0 / Double(items.count)
        let targetAngle = 360.0 - (sectionAngle * (Double(winningIndex) + 0.5))
        let normalized = rotationAngle.truncatingRemainder(dividingBy: 360)
        var delta = targetAngle - normalized
        if delta < 0 {
            delta += 360
        }

        let finalRotation = rotationAngle + delta + 1440
        let winningItem = items[winningIndex]

        withAnimation(.easeOut(duration: 2.4)) {
            rotationAngle = finalRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.45) { [weak self] in
            self?.resultText = winningItem
            self?.history.insert(winningItem, at: 0)
        }
    }

    private func stopTimer() {
        spinTimer?.invalidate()
        spinTimer = nil
    }
}

struct RouletteWheelView: View {
    let items: [String]
    let rotationAngle: Double
    let colors: [Color]

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            let labelRadius = radius * 0.64
            let center = CGPoint(x: radius, y: radius)
            let sectionAngle = 360.0 / Double(max(items.count, 1))

            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)

                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let startAngle = Angle.degrees((Double(index) * sectionAngle) - 90)
                    let endAngle = Angle.degrees((Double(index + 1) * sectionAngle) - 90)
                    let middleAngle = Angle.degrees((Double(index) + 0.5) * sectionAngle - 90)
                    let point = CGPoint(
                        x: center.x + CGFloat(cos(middleAngle.radians)) * labelRadius,
                        y: center.y + CGFloat(sin(middleAngle.radians)) * labelRadius
                    )

                    SectorShape(startAngle: startAngle, endAngle: endAngle)
                        .fill(colors[index % colors.count])

                    SectorShape(startAngle: startAngle, endAngle: endAngle)
                        .stroke(Color.white, lineWidth: 2.5)

                    Text(item)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.25))
                        .position(point)
                }

                Circle()
                    .stroke(Color.white, lineWidth: 6)

                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color(red: 0.94, green: 0.93, blue: 0.90)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.16, height: size * 0.16)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.95), lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            .rotationEffect(.degrees(rotationAngle))
        }
    }
}

struct SectorShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct PointerTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct RouletteEditorView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var draftItems: [String]

    let onSave: ([String]) -> Void

    init(items: [String], onSave: @escaping ([String]) -> Void) {
        _draftItems = State(initialValue: items)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(draftItems.indices, id: \.self) { index in
                    TextField(NSLocalizedString("placeholder", comment: ""), text: $draftItems[index])
                }
                .onDelete { offsets in
                    draftItems.remove(atOffsets: offsets)
                }

                Button(action: {
                    draftItems.append("")
                }) {
                    Label(NSLocalizedString("rouletteAddItem", comment: ""), systemImage: "plus")
                }
            }
            .navigationBarTitle(NSLocalizedString("rouletteEditItems", comment: ""), displayMode: .inline)
            .navigationBarItems(
                leading: Button(NSLocalizedString("close", comment: "")) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(NSLocalizedString("save", comment: "")) {
                    onSave(draftItems)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct RouletteHistoryView: View {
    @Environment(\.presentationMode) private var presentationMode

    let history: [String]

    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 34, weight: .regular))
                            .foregroundColor(.gray)
                        Text(NSLocalizedString("rouletteHistoryEmptyTitle", comment: ""))
                            .font(.system(size: 20, weight: .semibold))
                        Text(NSLocalizedString("rouletteHistoryEmptyBody", comment: ""))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                } else {
                    List(history, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .navigationBarTitle(NSLocalizedString("rouletteHistory", comment: ""), displayMode: .inline)
            .navigationBarItems(trailing: Button(NSLocalizedString("close", comment: "")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}