//
//  RouletteHomeView.swift
//  simpleRulette
//

import SwiftUI

struct RouletteHomeView: View {
    @StateObject private var viewModel = RouletteHomeViewModel()
    @State private var isShowingHelp = false
    @State private var isShowingEditor = false
    @State private var isShowingTemplatePicker = false

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
        .fullScreenCover(isPresented: $isShowingEditor) {
            RouletteEditorView(items: viewModel.items, weights: viewModel.itemWeights, currentTitle: viewModel.title) { items, weights in
                viewModel.updateConfiguration(items: items, weights: weights)
            }
        }
        .sheet(isPresented: $isShowingTemplatePicker) {
            RouletteTemplatePickerView(
                currentTitle: viewModel.title,
                currentItems: viewModel.items,
                currentWeights: viewModel.itemWeights
            ) { template in
                viewModel.applyTemplate(template)
            }
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
                weights: viewModel.itemWeights,
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
                isShowingTemplatePicker = true
            }) {
                Label(NSLocalizedString("selectFromTemplates", comment: ""), systemImage: "square.stack")
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
    @Published var itemWeights: [Double]
    @Published var resultText: String
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
    private let ruletteViewModel = RuletteViewModel()

    init() {
        let savedRoulette = ruletteViewModel.fetchCurrentData() ?? ruletteViewModel.fetchAllData().first
        let savedEntries = (savedRoulette?.ruletteItems ?? []).compactMap { entry -> (String, Double)? in
            let trimmedItem = entry.item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedItem.isEmpty else {
                return nil
            }
            return (trimmedItem, Double(entry.weight))
        }
        let savedItems = savedEntries.map(\.0)

        let resolvedItems = savedItems.count >= 2 ? savedItems : ["映画", "カフェ", "散歩", "読書", "勉強", "運動", "昼寝", "買い物"]
        title = (savedRoulette?.title.isEmpty == false ? savedRoulette?.title : nil) ?? NSLocalizedString("rouletteScreenTitle", comment: "")
        items = resolvedItems
        let savedWeights = savedEntries.map(\.1)
        itemWeights = savedItems.count >= 2 ? Self.normalizedWeights(savedWeights, count: savedItems.count) : RouletteEditorView.defaultWeights(for: resolvedItems.count)
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

    func updateConfiguration(items updatedItems: [String], weights updatedWeights: [Double]) {
        let filtered = updatedItems
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard filtered.count >= 2 else {
            return
        }

        items = filtered
        itemWeights = Self.normalizedWeights(updatedWeights, count: filtered.count)
        resultText = NSLocalizedString("rouletteInitialResult", comment: "")
        rotationAngle = 0
        stopTimer()
        isSpinning = false
        ruletteViewModel.saveCurrentData(
            title: title,
            items: items,
            weights: itemWeights.map { Int($0.rounded()) }
        )
    }

    func applyTemplate(_ rulette: Rulette) {
        let entries = rulette.ruletteItems.compactMap { entry -> (String, Double)? in
            let trimmedItem = entry.item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedItem.isEmpty else {
                return nil
            }
            return (trimmedItem, Double(entry.weight))
        }

        guard entries.count >= 2 else {
            return
        }

        title = rulette.title.isEmpty ? NSLocalizedString("rouletteScreenTitle", comment: "") : rulette.title
        items = entries.map(\.0)
        itemWeights = Self.normalizedWeights(entries.map(\.1), count: entries.count)
        resultText = NSLocalizedString("rouletteInitialResult", comment: "")
        rotationAngle = 0
        stopTimer()
        isSpinning = false
        ruletteViewModel.saveCurrentData(
            title: title,
            items: items,
            weights: itemWeights.map { Int($0.rounded()) }
        )
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

        let winningIndex = weightedWinningIndex() ?? Int.random(in: 0..<items.count)
        let segments = rouletteWheelSegments(weights: itemWeights, itemCount: items.count)
        let targetAngle = segments[safe: winningIndex]?.targetRotationDegrees ?? 0
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
        }
    }

    private func stopTimer() {
        spinTimer?.invalidate()
        spinTimer = nil
    }

    private func weightedWinningIndex() -> Int? {
        let normalized = Self.normalizedWeights(itemWeights, count: items.count)
        guard normalized.count == items.count else {
            return nil
        }

        let totalWeight = normalized.reduce(0, +)
        guard totalWeight > 0 else {
            return nil
        }

        let winningValue = Double.random(in: 0..<totalWeight)
        var cumulativeWeight = 0.0

        for (index, weight) in normalized.enumerated() {
            cumulativeWeight += weight
            if winningValue < cumulativeWeight {
                return index
            }
        }

        return normalized.indices.last
    }

    private static func normalizedWeights(_ weights: [Double], count: Int) -> [Double] {
        rouletteResolvedWeights(weights, itemCount: count)
    }
}

struct RouletteWheelView: View {
    let items: [String]
    let weights: [Double]
    let rotationAngle: Double
    let colors: [Color]

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            let center = CGPoint(x: radius, y: radius)
            let segments = rouletteWheelSegments(weights: weights, itemCount: items.count)

            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)

                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let segment = segments[safe: index] ?? RouletteWheelSegment(
                        startDegrees: -90,
                        endDegrees: 270,
                        middleDegrees: 90,
                        targetRotationDegrees: 0,
                        spanDegrees: 360
                    )
                    let startAngle = Angle.degrees(segment.startDegrees)
                    let endAngle = Angle.degrees(segment.endDegrees)
                    let middleAngle = Angle.degrees(segment.middleDegrees)
                    let adjustedLabelRadius = labelRadius(for: segment.spanDegrees, baseRadius: radius)
                    let point = CGPoint(
                        x: center.x + CGFloat(cos(middleAngle.radians)) * adjustedLabelRadius,
                        y: center.y + CGFloat(sin(middleAngle.radians)) * adjustedLabelRadius
                    )

                    SectorShape(startAngle: startAngle, endAngle: endAngle)
                        .fill(colors[index % colors.count])

                    SectorShape(startAngle: startAngle, endAngle: endAngle)
                        .stroke(Color.white, lineWidth: 2.5)

                    Text(item)
                        .font(.system(size: labelFontSize(for: segment.spanDegrees), weight: .bold))
                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.25))
                        .multilineTextAlignment(.center)
                        .lineLimit(segment.spanDegrees < 26 ? 1 : 2)
                        .minimumScaleFactor(segment.spanDegrees < 26 ? 0.42 : 0.58)
                        .frame(width: labelWidth(for: segment.spanDegrees, radius: radius))
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

    private func labelFontSize(for spanDegrees: Double) -> Double {
        switch spanDegrees {
        case ..<18:
            return 10
        case ..<28:
            return 11
        case ..<40:
            return 12
        case ..<58:
            return 14
        default:
            return 17
        }
    }

    private func labelWidth(for spanDegrees: Double, radius: CGFloat) -> CGFloat {
        let arcLength = radius * CGFloat(spanDegrees * .pi / 180) * 0.78
        return max(32, min(110, arcLength))
    }

    private func labelRadius(for spanDegrees: Double, baseRadius: CGFloat) -> CGFloat {
        switch spanDegrees {
        case ..<20:
            return baseRadius * 0.76
        case ..<32:
            return baseRadius * 0.72
        case ..<48:
            return baseRadius * 0.68
        default:
            return baseRadius * 0.62
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

private struct RouletteWheelSegment {
    let startDegrees: Double
    let endDegrees: Double
    let middleDegrees: Double
    let targetRotationDegrees: Double
    let spanDegrees: Double
}

private func rouletteResolvedWeights(_ weights: [Double], itemCount: Int) -> [Double] {
    let trimmed = Array(weights.prefix(itemCount))
    guard trimmed.count == itemCount, trimmed.contains(where: { $0 > 0 }) else {
        return RouletteEditorView.defaultWeights(for: itemCount)
    }
    return RouletteEditorView.normalizedWeights(from: trimmed)
}

private func rouletteWheelSegments(weights: [Double], itemCount: Int) -> [RouletteWheelSegment] {
    guard itemCount > 0 else {
        return []
    }

    let resolvedWeights = rouletteResolvedWeights(weights, itemCount: itemCount)
    let totalWeight = max(resolvedWeights.reduce(0, +), 1)
    var cumulativeDegrees = 0.0

    return resolvedWeights.map { weight in
        let spanDegrees = (weight / totalWeight) * 360
        let middleRelativeDegrees = cumulativeDegrees + (spanDegrees / 2)
        let segment = RouletteWheelSegment(
            startDegrees: cumulativeDegrees - 90,
            endDegrees: cumulativeDegrees + spanDegrees - 90,
            middleDegrees: middleRelativeDegrees - 90,
            targetRotationDegrees: (360 - middleRelativeDegrees).truncatingRemainder(dividingBy: 360),
            spanDegrees: spanDegrees
        )
        cumulativeDegrees += spanDegrees
        return segment
    }
}

struct RouletteEditorView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var draftItems: [String]
    @State private var draggingItem: String?
    @State private var isShowingWeightSettings = false
    @State private var itemWeights: [Double]
    @State private var templateTitle: String
    @State private var templateAlertTitle = ""
    @State private var templateAlertMessage = ""
    @State private var isShowingTemplateAlert = false

    let onSave: ([String], [Double]) -> Void

    init(items: [String], weights: [Double], currentTitle: String, onSave: @escaping ([String], [Double]) -> Void) {
        _draftItems = State(initialValue: items)
        _itemWeights = State(initialValue: weights.isEmpty ? Self.defaultWeights(for: items.count) : Self.normalizedWeights(from: weights))
        let initialTemplateTitle = currentTitle == NSLocalizedString("rouletteScreenTitle", comment: "") ? "" : currentTitle
        _templateTitle = State(initialValue: initialTemplateTitle)
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text(NSLocalizedString("rouletteEditorDescription", comment: ""))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.gray)
                            .padding(.top, 20)

                        itemsCard
                        addButton
                        reorderHint
                        templateSection
                        optionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingWeightSettings) {
            RouletteWeightSettingsView(
                items: cleanedItemsForDisplay,
                weights: itemWeights
            ) { updatedWeights in
                itemWeights = updatedWeights
            }
        }
        .alert(isPresented: $isShowingTemplateAlert) {
            Alert(
                title: Text(templateAlertTitle),
                message: Text(templateAlertMessage),
                dismissButton: .default(Text(NSLocalizedString("close", comment: "")))
            )
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(NSLocalizedString("rouletteEditItems", comment: ""))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Button(action: {
                let savedItems = cleanedItems.filter { !$0.isEmpty }
                let savedWeights = Self.normalizedWeights(from: Array(itemWeights.prefix(savedItems.count)))
                onSave(savedItems, savedWeights)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text(NSLocalizedString("rouletteDone", comment: ""))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.blue)
                    .frame(width: 60, height: 44)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)
        }
    }

    private var itemsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(draftItems.enumerated()), id: \.offset) { index, item in
                editorRow(index: index, item: item)

                if index < draftItems.count - 1 {
                    Divider()
                        .padding(.leading, 74)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)
    }

    private func editorRow(index: Int, item: String) -> some View {
        HStack(spacing: 14) {
            Text("\(index + 1)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 28, alignment: .leading)

            TextField(NSLocalizedString("placeholder", comment: ""), text: $draftItems[index])
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.black)

            Image(systemName: "line.3.horizontal")
                .font(.system(size: 21, weight: .regular))
                .foregroundColor(Color.gray.opacity(0.65))
                .padding(.horizontal, 4)
                .onDrag {
                    draggingItem = item
                    return NSItemProvider(object: NSString(string: item))
                }

            Button(action: {
                removeItem(at: index)
            }) {
                Text(NSLocalizedString("delete", comment: ""))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.red)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 92)
        .background(Color.white)
        .onDrop(of: [.text], delegate: RouletteReorderDropDelegate(
            item: item,
            items: $draftItems,
            draggingItem: $draggingItem
        ))
    }

    private var addButton: some View {
        Button(action: {
            draftItems.append("")
        }) {
            Label(NSLocalizedString("rouletteAddItem", comment: ""), systemImage: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 68)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var reorderHint: some View {
        Text(NSLocalizedString("rouletteReorderHint", comment: ""))
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Color.gray)
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(NSLocalizedString("rouletteTemplateSectionTitle", comment: ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.gray)

            VStack(alignment: .leading, spacing: 16) {
                TextField(NSLocalizedString("rouletteTemplateTitlePlaceholder", comment: ""), text: $templateTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .frame(height: 56)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: saveAsTemplate) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 18, weight: .semibold))

                        Text(NSLocalizedString("rouletteTemplateSaveButton", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Color(red: 0.17, green: 0.53, blue: 0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 8)
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(NSLocalizedString("rouletteOptions", comment: ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.gray)

            VStack(spacing: 0) {
                optionRow(
                    icon: "chart.bar.xaxis",
                    title: NSLocalizedString("rouletteWeightOption", comment: ""),
                    trailingText: weightOptionStatus,
                    action: {
                        syncWeightsWithItems()
                        isShowingWeightSettings = true
                    }
                )

                Divider()
                    .padding(.leading, 56)

                optionRow(
                    icon: "paintpalette",
                    title: NSLocalizedString("rouletteColorOption", comment: "")
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 8)
        }
    }

    private func optionRow(icon: String, title: String, trailingText: String? = nil, action: (() -> Void)? = nil) -> some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.black)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)

                Spacer()

                if let trailingText {
                    Text(trailingText)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding(.horizontal, 18)
            .frame(height: 72)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var cleanedItems: [String] {
        draftItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private var cleanedItemsForDisplay: [String] {
        let items = cleanedItems.filter { !$0.isEmpty }
        return items.count >= 2 ? items : draftItems.enumerated().map { index, item in
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? String(format: NSLocalizedString("rouletteItemFallback", comment: ""), index + 1) : trimmed
        }
    }

    private var weightOptionStatus: String {
        guard !itemWeights.isEmpty else {
            return NSLocalizedString("rouletteOff", comment: "")
        }
        let defaultWeights = Self.defaultWeights(for: itemWeights.count)
        return itemWeights == defaultWeights ? NSLocalizedString("rouletteOff", comment: "") : NSLocalizedString("rouletteOn", comment: "")
    }

    private func removeItem(at index: Int) {
        guard draftItems.indices.contains(index), draftItems.count > 2 else {
            return
        }
        draftItems.remove(at: index)
        syncWeightsWithItems()
    }

    private func syncWeightsWithItems() {
        let count = max(cleanedItemsForDisplay.count, 2)
        if itemWeights.count == count {
            itemWeights = Self.normalizedWeights(from: itemWeights)
            return
        }

        if itemWeights.isEmpty {
            itemWeights = Self.defaultWeights(for: count)
            return
        }

        let total = max(itemWeights.reduce(0, +), 1)
        let scaled = Array(itemWeights.prefix(count)).map { ($0 / total) * 100 }
        if scaled.count == count {
            itemWeights = Self.normalizedWeights(from: scaled)
        } else {
            itemWeights = Self.defaultWeights(for: count)
        }
    }

    private func saveAsTemplate() {
        let trimmedTitle = templateTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedItems = cleanedItems.filter { !$0.isEmpty }

        guard !trimmedTitle.isEmpty else {
            templateAlertTitle = NSLocalizedString("error", comment: "")
            templateAlertMessage = NSLocalizedString("rouletteTitleNotEntered", comment: "")
            isShowingTemplateAlert = true
            return
        }

        guard savedItems.count >= 2 else {
            templateAlertTitle = NSLocalizedString("error", comment: "")
            templateAlertMessage = NSLocalizedString("setData", comment: "")
            isShowingTemplateAlert = true
            return
        }

        let savedWeights = Self.normalizedWeights(from: Array(itemWeights.prefix(savedItems.count)))
        RuletteViewModel().addData(
            title: trimmedTitle,
            items: savedItems,
            weights: savedWeights.map { Int($0.rounded()) }
        )
        templateTitle = trimmedTitle
        templateAlertTitle = NSLocalizedString("rouletteTemplateSavedTitle", comment: "")
        templateAlertMessage = String(format: NSLocalizedString("rouletteTemplateSavedBody", comment: ""), trimmedTitle)
        isShowingTemplateAlert = true
    }

    static func defaultWeights(for count: Int) -> [Double] {
        guard count > 0 else {
            return []
        }

        let minimum = minimumWeight(for: count)
        var weights = Array(repeating: minimum, count: count)
        let remaining = max(100 - (minimum * count), 0)

        guard remaining > 0 else {
            return weights.map(Double.init)
        }

        let baseExtra = remaining / count
        let remainder = remaining % count

        for index in weights.indices {
            weights[index] += baseExtra
            if index < remainder {
                weights[index] += 1
            }
        }

        return weights.map(Double.init)
    }

    static func normalizedWeights(from weights: [Double]) -> [Double] {
        guard !weights.isEmpty else {
            return []
        }

        let count = weights.count
        let minimum = minimumWeight(for: count)
        let normalized = distribute(total: 100, basedOn: weights.map { Int($0.rounded()) }, minimum: minimum)
        return normalized.map(Double.init)
    }

    static func minimumWeight(for count: Int) -> Int {
        guard count > 0 else {
            return 0
        }
        return count <= 100 ? 1 : 0
    }

    static func maximumWeight(for count: Int) -> Int {
        guard count > 0 else {
            return 0
        }

        let minimum = minimumWeight(for: count)
        return max(minimum, 100 - (minimum * (count - 1)))
    }

    static func distribute(total: Int, basedOn weights: [Int], minimum: Int) -> [Int] {
        guard !weights.isEmpty else {
            return []
        }

        let count = weights.count
        var distributed = Array(repeating: minimum, count: count)
        let remaining = total - (minimum * count)

        guard remaining > 0 else {
            return distributed
        }

        let priorities = weights.map { max($0 - minimum, 0) }
        let prioritySum = priorities.reduce(0, +)

        guard prioritySum > 0 else {
            for offset in 0..<remaining {
                distributed[offset % count] += 1
            }
            return distributed
        }

        let exactExtras = priorities.map { Double($0) / Double(prioritySum) * Double(remaining) }
        let flooredExtras = exactExtras.map { Int(floor($0)) }
        let remainder = remaining - flooredExtras.reduce(0, +)
        let rankedIndices = exactExtras.indices.sorted {
            let lhsFraction = exactExtras[$0] - Double(flooredExtras[$0])
            let rhsFraction = exactExtras[$1] - Double(flooredExtras[$1])
            if lhsFraction == rhsFraction {
                return priorities[$0] > priorities[$1]
            }
            return lhsFraction > rhsFraction
        }

        for index in distributed.indices {
            distributed[index] += flooredExtras[index]
        }

        if remainder > 0 {
            for offset in 0..<remainder {
                distributed[rankedIndices[offset % rankedIndices.count]] += 1
            }
        }

        return distributed
    }
}

struct RouletteWeightSettingsView: View {
    @Environment(\.presentationMode) private var presentationMode

    let items: [String]
    let onSave: ([Double]) -> Void

    @State private var weights: [Double]

    init(items: [String], weights: [Double], onSave: @escaping ([Double]) -> Void) {
        self.items = items
        self.onSave = onSave
        _weights = State(initialValue: weights.isEmpty ? RouletteEditorView.defaultWeights(for: items.count) : RouletteEditorView.normalizedWeights(from: weights))
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                weightTopBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        descriptionBlock
                        totalWeightCard
                        itemWeightsCard
                        noteCard
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    private var weightTopBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(NSLocalizedString("rouletteWeightTitle", comment: ""))
                .font(.system(size: 20, weight: .bold))

            Spacer()

            Button(action: {
                weights = RouletteEditorView.defaultWeights(for: items.count)
            }) {
                Text(NSLocalizedString("rouletteReset", comment: ""))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 70, height: 44)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)
        }
    }

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(NSLocalizedString("rouletteWeightDescriptionTitle", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Text(NSLocalizedString("rouletteWeightDescriptionBody", comment: ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var totalWeightCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(NSLocalizedString("rouletteWeightTotal", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Text(totalSummary)
                    .font(.system(size: 18, weight: .bold))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.blue.opacity(0.15))
                        .frame(height: 12)
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: proxy.size.width * min(totalWeight / 100.0, 1.0), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)
    }

    private var itemWeightsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                weightRow(index: index, item: item)

                if index < items.count - 1 {
                    Divider()
                        .padding(.leading, 86)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)
    }

    private func weightRow(index: Int, item: String) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(rowBadgeColor(index: index))
                    Text("\(index + 1)")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)

                Text(emoji(for: item))
                    .font(.system(size: 32))
                    .frame(width: 42)

                Text(item)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Text(weightSummary(for: index))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.65))
            }

            Slider(
                value: Binding(
                    get: { weights[safe: index] ?? 0 },
                    set: { newValue in updateWeight(newValue, at: index) }
                ),
                in: Double(RouletteEditorView.minimumWeight(for: items.count))...Double(RouletteEditorView.maximumWeight(for: items.count)),
                step: 1
            )
            .tint(.blue)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private var noteCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.blue)

            Text(NSLocalizedString("rouletteWeightHint", comment: ""))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black.opacity(0.75))
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var saveButton: some View {
        Button(action: {
            onSave(normalizedWeights)
            presentationMode.wrappedValue.dismiss()
        }) {
            Text(NSLocalizedString("rouletteSaveWeights", comment: ""))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 74)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 10)
    }

    private var totalWeight: Double {
        normalizedWeights.reduce(0, +)
    }

    private var totalSummary: String {
        let total = Int(totalWeight)
        return "\(total)% (\(total))"
    }

    private var normalizedWeights: [Double] {
        RouletteEditorView.normalizedWeights(from: weights)
    }

    private func weightSummary(for index: Int) -> String {
        let value = Int(normalizedWeights[safe: index] ?? 0)
        return "\(value)% (\(value))"
    }

    private func rowBadgeColor(index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors[index % colors.count]
    }

    private func emoji(for item: String) -> String {
        let lowercased = item.lowercased()
        if item.contains("ラーメン") || lowercased.contains("ramen") { return "🍜" }
        if item.contains("寿司") || lowercased.contains("sushi") { return "🍣" }
        if item.contains("ピザ") || lowercased.contains("pizza") { return "🍕" }
        if item.contains("ハンバーガー") || lowercased.contains("burger") { return "🍔" }
        if item.contains("ケーキ") || lowercased.contains("cake") { return "🍰" }
        if item.contains("ドリンク") || lowercased.contains("drink") { return "🥤" }
        if item.contains("おまかせ") || lowercased.contains("random") { return "❓" }
        return "🎯"
    }

    private func updateWeight(_ value: Double, at index: Int) {
        guard weights.indices.contains(index) else {
            return
        }

        let count = weights.count
        let minimum = RouletteEditorView.minimumWeight(for: count)
        let maximum = RouletteEditorView.maximumWeight(for: count)
        let target = min(max(Int(value.rounded()), minimum), maximum)

        guard count > 1 else {
            weights[index] = 100
            return
        }

        let remainingIndices = weights.indices.filter { $0 != index }
        let rebalancedOthers = RouletteEditorView.distribute(
            total: 100 - target,
            basedOn: remainingIndices.map { Int((weights[safe: $0] ?? 0).rounded()) },
            minimum: minimum
        )

        var updatedWeights = Array(repeating: 0.0, count: count)
        updatedWeights[index] = Double(target)

        for (offset, otherIndex) in remainingIndices.enumerated() {
            updatedWeights[otherIndex] = Double(rebalancedOthers[offset])
        }

        weights = updatedWeights
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct RouletteReorderDropDelegate: DropDelegate {
    let item: String
    @Binding var items: [String]
    @Binding var draggingItem: String?

    func dropEntered(info: DropInfo) {
        guard let draggingItem, draggingItem != item,
              let fromIndex = items.firstIndex(of: draggingItem),
              let toIndex = items.firstIndex(of: item) else {
            return
        }

        if items[toIndex] != draggingItem {
            withAnimation(.easeInOut(duration: 0.2)) {
                items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }
}

struct RouletteTemplatePickerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var templates: [Rulette]

    let currentTitle: String
    let currentItems: [String]
    let currentWeights: [Double]
    let onSelect: (Rulette) -> Void

    private let ruletteViewModel = RuletteViewModel()

    init(currentTitle: String, currentItems: [String], currentWeights: [Double], onSelect: @escaping (Rulette) -> Void) {
        _templates = State(initialValue: RuletteViewModel().fetchAllData())
        self.currentTitle = currentTitle
        self.currentItems = currentItems
        self.currentWeights = currentWeights
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationView {
            Group {
                if templates.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 34, weight: .regular))
                            .foregroundColor(.gray)
                        Text(NSLocalizedString("rouletteTemplatesEmptyTitle", comment: ""))
                            .font(.system(size: 20, weight: .semibold))
                        Text(NSLocalizedString("rouletteTemplatesEmptyBody", comment: ""))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                } else {
                    List(templates, id: \.id) { template in
                        Button(action: {
                            onSelect(template)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(template.title.isEmpty ? NSLocalizedString("templates", comment: "") : template.title)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)

                                Text(template.ruletteItems.map(\.item).joined(separator: " / "))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTemplate(template)
                            } label: {
                                Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                overwriteTemplate(template)
                            } label: {
                                Label(NSLocalizedString("rouletteTemplateOverwrite", comment: ""), systemImage: "arrow.triangle.2.circlepath")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationBarTitle(NSLocalizedString("selectFromTemplates", comment: ""), displayMode: .inline)
            .navigationBarItems(trailing: Button(NSLocalizedString("close", comment: "")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func deleteTemplate(_ template: Rulette) {
        ruletteViewModel.deleteRuletteData(rulette: template)
        templates.removeAll { $0.id == template.id }
    }

    private func overwriteTemplate(_ template: Rulette) {
        let trimmedItems = currentItems
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard trimmedItems.count >= 2 else {
            return
        }

        let normalizedWeights = RouletteEditorView.normalizedWeights(from: Array(currentWeights.prefix(trimmedItems.count)))
        let resolvedTitle = currentTitle == NSLocalizedString("rouletteScreenTitle", comment: "") ? template.title : currentTitle

        ruletteViewModel.updateRuletteData(
            rulette: template,
            title: resolvedTitle,
            items: trimmedItems,
            weights: normalizedWeights.map { Int($0.rounded()) }
        )

        templates = ruletteViewModel.fetchAllData()
    }
}