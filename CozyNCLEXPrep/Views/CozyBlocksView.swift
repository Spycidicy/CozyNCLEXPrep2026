import SwiftUI

// MARK: - Blocks Session Progress

struct CodableGridCell: Codable {
    var isFilled: Bool
    var colorIndex: Int? // index into pieceColors
}

struct CodableBlockPiece: Codable {
    let shapeIndex: Int // index into BlockShape.allCases
    let colorIndex: Int // index into pieceColors
}

struct BlocksSessionProgress: Codable {
    let grid: [[CodableGridCell]]
    let pieces: [CodableBlockPiece?]
    let score: Int
    let linesCleared: Int
    let questionsAnswered: Int
    let questionsCorrect: Int
    let cardPoolIndex: Int
    let savedAt: Date

    var isValid: Bool {
        Date().timeIntervalSince(savedAt) < 86400
    }

    private static let key = "blocksSessionProgress"

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    static func load() -> BlocksSessionProgress? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? JSONDecoder().decode(BlocksSessionProgress.self, from: data),
              progress.isValid else { return nil }
        return progress
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Data Models

struct BlockPiece: Identifiable, Equatable {
    let id = UUID()
    let shape: [[Bool]]
    let color: Color

    var filledCells: [(row: Int, col: Int)] {
        var cells: [(row: Int, col: Int)] = []
        for r in shape.indices {
            for c in shape[r].indices {
                if shape[r][c] {
                    cells.append((row: r, col: c))
                }
            }
        }
        return cells
    }

    static func == (lhs: BlockPiece, rhs: BlockPiece) -> Bool {
        lhs.id == rhs.id
    }
}

enum BlockShape: CaseIterable {
    case single
    case dominoH
    case dominoV
    case lineH3
    case lineV3
    case square2x2
    case lShape
    case lShapeR
    case tShape

    var shape: [[Bool]] {
        switch self {
        case .single:
            return [[true]]
        case .dominoH:
            return [[true, true]]
        case .dominoV:
            return [[true], [true]]
        case .lineH3:
            return [[true, true, true]]
        case .lineV3:
            return [[true], [true], [true]]
        case .square2x2:
            return [[true, true], [true, true]]
        case .lShape:
            return [[true, false], [true, false], [true, true]]
        case .lShapeR:
            return [[false, true], [false, true], [true, true]]
        case .tShape:
            return [[true, true, true], [false, true, false]]
        }
    }
}

struct GridCell {
    var isFilled: Bool = false
    var color: Color? = nil
}

// MARK: - CozyBlocksView

struct CozyBlocksView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var statsManager: StatsManager
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared

    // Grid
    @State private var grid: [[GridCell]] = Array(repeating: Array(repeating: GridCell(), count: 8), count: 8)

    // Pieces
    @State private var availablePieces: [BlockPiece?] = [nil, nil, nil]
    @State private var selectedPieceIndex: Int? = nil

    // Drag state
    @State private var draggingPieceIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var gridOrigin: CGPoint = .zero
    @State private var gridCellSize: CGFloat = 0
    @State private var traySlotCenters: [Int: CGPoint] = [:]

    // Quiz
    @State private var showQuiz: Bool = false
    @State private var currentQuestion: Flashcard? = nil
    @State private var shuffledAnswers: [String] = []
    @State private var selectedAnswer: String? = nil
    @State private var answerRevealed: Bool = false
    @State private var wasCorrect: Bool = false

    // Score
    @State private var score: Int = 0
    @State private var highScore: Int = 0
    @State private var linesCleared: Int = 0
    @State private var questionsAnswered: Int = 0
    @State private var questionsCorrect: Int = 0

    // Game state
    @State private var isGameOver: Bool = false
    @State private var startTime: Date = Date()

    // Card pool
    @State private var cardPool: [Flashcard] = []
    @State private var cardPoolIndex: Int = 0

    // Animation
    @State private var clearingRows: Set<Int> = []
    @State private var clearingCols: Set<Int> = []

    private let gridSize = 8
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let pieceColors: [Color] = [.mintGreen, .pastelPink, .softLavender, .skyBlue, .peachOrange]

    // Computed: grid row/col the dragged piece would anchor at
    private var dragTargetCell: (row: Int, col: Int)? {
        guard let idx = draggingPieceIndex,
              let piece = availablePieces[idx],
              let center = traySlotCenters[idx] else { return nil }

        // The piece visual center during drag (global coords)
        let pieceCenterX = center.x + dragOffset.width
        let pieceCenterY = center.y + dragOffset.height

        // Convert to grid-local coords
        let localX = pieceCenterX - gridOrigin.x
        let localY = pieceCenterY - gridOrigin.y

        // Piece shape dimensions
        let rows = piece.shape.count
        let cols = piece.shape[0].count

        // We want the piece centered under the finger, so offset by half the piece size
        let anchorX = localX - (CGFloat(cols) * gridCellSize) / 2.0
        let anchorY = localY - (CGFloat(rows) * gridCellSize) / 2.0

        let col = Int(round(anchorX / gridCellSize))
        let row = Int(round(anchorY / gridCellSize))

        return (row: row, col: col)
    }

    private var dragIsValid: Bool {
        guard let target = dragTargetCell,
              let idx = draggingPieceIndex,
              let piece = availablePieces[idx] else { return false }
        return canPlace(piece: piece, row: target.row, col: target.col)
    }

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                headerView
                gridView
                pieceTrayView
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: horizontalSizeClass == .regular ? 700 : .infinity)
            .frame(maxWidth: .infinity)

            if showQuiz {
                quizOverlay
            }

            if isGameOver {
                gameOverOverlay
            }
        }
        .onAppear {
            setupGame()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button {
                HapticManager.shared.buttonTap()
                SoundManager.shared.buttonTap()
                saveStats()
                saveBlocksProgress()
                appManager.currentScreen = .menu
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primaryText)
                    .padding(10)
                    .background(Color.cardBackground)
                    .clipShape(Circle())
            }

            Spacer()

            Text("Cozy Blocks")
                .font(.title2.weight(.bold))
                .foregroundColor(.primaryText)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.peachOrange)
                        .font(.caption)
                    Text("\(score)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primaryText)
                }
                Text("Best: \(highScore)")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.top, 8)
    }

    // MARK: - Grid

    private var gridView: some View {
        GeometryReader { geo in
            let cellSize = geo.size.width / CGFloat(gridSize)

            VStack(spacing: 1) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            gridCellView(row: row, col: col, cellSize: cellSize)
                        }
                    }
                }
            }
            .padding(4)
            .background(Color.secondaryText.opacity(0.15))
            .cornerRadius(12)
            .background(
                GeometryReader { inner in
                    Color.clear
                        .onAppear {
                            let frame = inner.frame(in: .global)
                            gridOrigin = CGPoint(x: frame.minX + 4, y: frame.minY + 4)
                            gridCellSize = cellSize
                        }
                        .onChange(of: geo.size) { _ in
                            let frame = inner.frame(in: .global)
                            gridOrigin = CGPoint(x: frame.minX + 4, y: frame.minY + 4)
                            gridCellSize = cellSize
                        }
                }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func gridCellView(row: Int, col: Int, cellSize: CGFloat) -> some View {
        let cell = grid[row][col]
        let isClearing = clearingRows.contains(row) || clearingCols.contains(col)
        let isGhost = ghostContains(row: row, col: col)

        return RoundedRectangle(cornerRadius: 4)
            .fill(cellColor(cell: cell, isClearing: isClearing, isGhost: isGhost))
            .frame(width: cellSize - 1, height: cellSize - 1)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.secondaryText.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(isClearing ? 0.8 : 1.0)
            .opacity(isClearing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: isClearing)
    }

    private func cellColor(cell: GridCell, isClearing: Bool, isGhost: Bool) -> Color {
        if isClearing, let color = cell.color {
            return color.opacity(0.7)
        }
        if cell.isFilled, let color = cell.color {
            return color.opacity(0.85)
        }
        if isGhost {
            if let idx = draggingPieceIndex, let piece = availablePieces[idx] {
                return dragIsValid ? piece.color.opacity(0.35) : Color.coralPink.opacity(0.25)
            }
        }
        return Color.cardBackground
    }

    private func ghostContains(row: Int, col: Int) -> Bool {
        guard let target = dragTargetCell,
              let idx = draggingPieceIndex,
              let piece = availablePieces[idx] else { return false }

        for cell in piece.filledCells {
            let r = target.row + cell.row
            let c = target.col + cell.col
            if r == row && c == col {
                return true
            }
        }
        return false
    }

    // MARK: - Piece Tray

    private var pieceTrayView: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { index in
                pieceSlotView(index: index)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    private func pieceSlotView(index: Int) -> some View {
        let isDragging = draggingPieceIndex == index

        return Group {
            if let piece = availablePieces[index] {
                miniPieceView(piece: piece)
                    .padding(8)
                    .frame(width: 80, height: 80)
                    .background(Color.creamyBackground.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isDragging ? piece.color : Color.clear,
                                lineWidth: isDragging ? 3 : 0
                            )
                    )
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .opacity(isDragging ? 0.5 : 1.0)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    let frame = geo.frame(in: .global)
                                    traySlotCenters[index] = CGPoint(x: frame.midX, y: frame.midY)
                                }
                                .onChange(of: geo.size) { _ in
                                    let frame = geo.frame(in: .global)
                                    traySlotCenters[index] = CGPoint(x: frame.midX, y: frame.midY)
                                }
                        }
                    )
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                if draggingPieceIndex == nil && !showQuiz && !isGameOver {
                                    draggingPieceIndex = index
                                    HapticManager.shared.selection()
                                }
                                if draggingPieceIndex == index {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { _ in
                                guard draggingPieceIndex == index else { return }
                                handleDrop(pieceIndex: index)
                            }
                    )
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(.secondaryText.opacity(0.3))
                    .frame(width: 80, height: 80)
            }
        }
    }

    // Floating piece that follows the drag
    private var dragPieceOverlay: some View {
        Group {
            if let idx = draggingPieceIndex,
               let piece = availablePieces[idx],
               let center = traySlotCenters[idx] {
                miniPieceView(piece: piece, cellSize: gridCellSize)
                    .position(
                        x: center.x + dragOffset.width,
                        y: center.y + dragOffset.height
                    )
                    .allowsHitTesting(false)
            }
        }
    }

    private func miniPieceView(piece: BlockPiece, cellSize: CGFloat? = nil) -> some View {
        let rows = piece.shape.count
        let cols = piece.shape[0].count
        let maxDim = max(rows, cols)
        let miniSize: CGFloat = cellSize ?? (50 / CGFloat(maxDim))

        return VStack(spacing: 1) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 1) {
                    ForEach(0..<cols, id: \.self) { c in
                        if piece.shape[r][c] {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(piece.color.opacity(0.85))
                                .frame(width: miniSize, height: miniSize)
                        } else {
                            Color.clear
                                .frame(width: miniSize, height: miniSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quiz Overlay

    private var quizOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 20) {
                Text("Study Break")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primaryText)

                if let question = currentQuestion {
                    ScrollView {
                        Text(question.question)
                            .font(.body.weight(.medium))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxHeight: 120)

                    VStack(spacing: 10) {
                        ForEach(shuffledAnswers, id: \.self) { answer in
                            answerButton(answer: answer, correctAnswer: question.answer)
                        }
                    }

                    if answerRevealed {
                        HStack(spacing: 8) {
                            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(wasCorrect ? .mintGreen : .coralPink)
                                .font(.title3)
                            Text(wasCorrect ? "Correct! +5 bonus + 3 pieces" : "The answer is: \(question.answer)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(wasCorrect ? .mintGreen : .coralPink)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 4)

                        Button {
                            HapticManager.shared.buttonTap()
                            SoundManager.shared.buttonTap()
                            if wasCorrect {
                                generatePieces()
                            } else {
                                // Wrong answer: skip pieces, show next question
                                showNextQuestion()
                            }
                        } label: {
                            Text("Continue")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.adaptiveWhite)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(wasCorrect ? Color.mintGreen : Color.softLavender)
                                .cornerRadius(14)
                        }
                    }
                }
            }
            .padding(24)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            .padding(.horizontal, 28)
        }
        .transition(.opacity)
    }

    private func answerButton(answer: String, correctAnswer: String) -> some View {
        let isSelected = selectedAnswer == answer
        let isCorrect = answer == correctAnswer

        var bgColor: Color = .creamyBackground
        if answerRevealed {
            if isCorrect {
                bgColor = .mintGreen.opacity(0.3)
            } else if isSelected && !isCorrect {
                bgColor = .coralPink.opacity(0.3)
            }
        } else if isSelected {
            bgColor = .skyBlue.opacity(0.3)
        }

        var borderColor: Color = .secondaryText.opacity(0.15)
        if answerRevealed {
            if isCorrect {
                borderColor = .mintGreen
            } else if isSelected && !isCorrect {
                borderColor = .coralPink
            }
        } else if isSelected {
            borderColor = .skyBlue
        }

        return Button {
            guard !answerRevealed else { return }
            handleAnswer(answer)
        } label: {
            HStack {
                Text(answer)
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.leading)
                Spacer()
                if answerRevealed && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mintGreen)
                } else if answerRevealed && isSelected && !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.coralPink)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(bgColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
        }
    }

    // MARK: - Game Over Overlay

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primaryText)

                if score >= highScore && score > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("New High Score!")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.yellow)
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(12)
                }

                VStack(spacing: 12) {
                    statRow(icon: "star.fill", iconColor: .peachOrange, label: "Score", value: "\(score)")
                    statRow(icon: "line.3.horizontal", iconColor: .skyBlue, label: "Lines Cleared", value: "\(linesCleared)")
                    statRow(icon: "questionmark.circle.fill", iconColor: .softLavender, label: "Questions", value: "\(questionsCorrect)/\(questionsAnswered)")
                }
                .padding()
                .background(Color.creamyBackground)
                .cornerRadius(16)

                VStack(spacing: 12) {
                    Button {
                        HapticManager.shared.buttonTap()
                        SoundManager.shared.buttonTap()
                        restartGame()
                    } label: {
                        Text("Play Again")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.adaptiveWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.mintGreen)
                            .cornerRadius(14)
                    }

                    Button {
                        HapticManager.shared.buttonTap()
                        SoundManager.shared.buttonTap()
                        appManager.currentScreen = .menu
                    } label: {
                        Text("Home")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.cardBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.secondaryText.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(28)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            .padding(.horizontal, 28)
        }
        .transition(.opacity)
    }

    private func statRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.primaryText)
        }
    }

    // MARK: - Game Logic

    private func setupGame() {
        highScore = UserDefaults.standard.integer(forKey: "cozyBlocksHighScore")
        startTime = Date()

        let available = cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess)
        if available.isEmpty {
            cardPool = cardManager.sessionCards.shuffled()
        } else {
            cardPool = available.shuffled()
        }
        cardPoolIndex = 0

        // Check for saved progress to resume
        if let saved = BlocksSessionProgress.load() {
            restoreFromProgress(saved)
            BlocksSessionProgress.clear()
            SessionProgressManager.shared.clearProgress(for: .blocks)
        } else {
            showNextQuestion()
        }
    }

    private func restoreFromProgress(_ saved: BlocksSessionProgress) {
        // Restore grid
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                let cell = saved.grid[r][c]
                grid[r][c].isFilled = cell.isFilled
                grid[r][c].color = cell.colorIndex.map { pieceColors[$0 % pieceColors.count] }
            }
        }

        // Restore pieces
        let allShapes = BlockShape.allCases
        for i in 0..<3 {
            if let codable = saved.pieces[i] {
                let shape = allShapes[codable.shapeIndex % allShapes.count]
                let color = pieceColors[codable.colorIndex % pieceColors.count]
                availablePieces[i] = BlockPiece(shape: shape.shape, color: color)
            } else {
                availablePieces[i] = nil
            }
        }

        score = saved.score
        linesCleared = saved.linesCleared
        questionsAnswered = saved.questionsAnswered
        questionsCorrect = saved.questionsCorrect
        cardPoolIndex = min(saved.cardPoolIndex, cardPool.count)

        // If all pieces are used, show next question; otherwise resume play
        let allUsed = availablePieces.allSatisfy { $0 == nil }
        if allUsed {
            showNextQuestion()
        }
    }

    private func restartGame() {
        BlocksSessionProgress.clear()
        SessionProgressManager.shared.clearProgress(for: .blocks)

        grid = Array(repeating: Array(repeating: GridCell(), count: 8), count: 8)
        availablePieces = [nil, nil, nil]
        selectedPieceIndex = nil
        draggingPieceIndex = nil
        dragOffset = .zero
        score = 0
        linesCleared = 0
        questionsAnswered = 0
        questionsCorrect = 0
        isGameOver = false
        showQuiz = false
        clearingRows = []
        clearingCols = []
        startTime = Date()
        cardPoolIndex = 0
        cardPool.shuffle()

        showNextQuestion()
    }

    private func handleDrop(pieceIndex: Int) {
        defer {
            draggingPieceIndex = nil
            dragOffset = .zero
        }

        guard let piece = availablePieces[pieceIndex],
              let target = dragTargetCell else {
            HapticManager.shared.warning()
            return
        }

        if canPlace(piece: piece, row: target.row, col: target.col) {
            placePiece(pieceIndex: pieceIndex, at: target.row, col: target.col)
        } else {
            HapticManager.shared.warning()
        }
    }

    private func canPlace(piece: BlockPiece, row: Int, col: Int) -> Bool {
        for cell in piece.filledCells {
            let r = row + cell.row
            let c = col + cell.col
            if r < 0 || r >= gridSize || c < 0 || c >= gridSize {
                return false
            }
            if grid[r][c].isFilled {
                return false
            }
        }
        return true
    }

    private func placePiece(pieceIndex: Int, at row: Int, col: Int) {
        guard let piece = availablePieces[pieceIndex] else { return }

        HapticManager.shared.soft()
        SoundManager.shared.buttonTap()

        for cell in piece.filledCells {
            let r = row + cell.row
            let c = col + cell.col
            grid[r][c].isFilled = true
            grid[r][c].color = piece.color
        }

        score += piece.filledCells.count
        availablePieces[pieceIndex] = nil
        selectedPieceIndex = nil

        checkAndClearLines()

        let allUsed = availablePieces.allSatisfy { $0 == nil }
        if allUsed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showNextQuestion()
            }
        } else {
            checkGameOver()
        }
    }

    private func checkAndClearLines() {
        var rowsToClear: Set<Int> = []
        var colsToClear: Set<Int> = []

        for r in 0..<gridSize {
            let full = (0..<gridSize).allSatisfy { grid[r][$0].isFilled }
            if full { rowsToClear.insert(r) }
        }

        for c in 0..<gridSize {
            let full = (0..<gridSize).allSatisfy { grid[$0][c].isFilled }
            if full { colsToClear.insert(c) }
        }

        guard !rowsToClear.isEmpty || !colsToClear.isEmpty else { return }

        let totalLines = rowsToClear.count + colsToClear.count
        score += totalLines * 10
        linesCleared += totalLines

        withAnimation(.easeInOut(duration: 0.25)) {
            clearingRows = rowsToClear
            clearingCols = colsToClear
        }

        HapticManager.shared.medium()
        SoundManager.shared.achievement()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for r in rowsToClear {
                for c in 0..<gridSize {
                    grid[r][c].isFilled = false
                    grid[r][c].color = nil
                }
            }
            for c in colsToClear {
                for r in 0..<gridSize {
                    grid[r][c].isFilled = false
                    grid[r][c].color = nil
                }
            }
            clearingRows = []
            clearingCols = []
        }
    }

    private func checkGameOver() {
        for piece in availablePieces {
            guard let piece = piece else { continue }
            for r in 0..<gridSize {
                for c in 0..<gridSize {
                    if canPlace(piece: piece, row: r, col: c) {
                        return
                    }
                }
            }
        }

        let hasAnyPiece = availablePieces.contains(where: { $0 != nil })
        if hasAnyPiece {
            withAnimation(.easeInOut(duration: 0.3)) {
                isGameOver = true
            }
            saveStats()
            BlocksSessionProgress.clear()
            SessionProgressManager.shared.clearProgress(for: .blocks)
            HapticManager.shared.error()
            SoundManager.shared.celebration()
        }
    }

    private func showNextQuestion() {
        guard !cardPool.isEmpty else { return }

        if cardPoolIndex >= cardPool.count {
            cardPool.shuffle()
            cardPoolIndex = 0
        }

        let card = cardPool[cardPoolIndex]
        cardPoolIndex += 1

        currentQuestion = card
        shuffledAnswers = card.shuffledAnswers()
        selectedAnswer = nil
        answerRevealed = false
        wasCorrect = false

        withAnimation(.easeInOut(duration: 0.3)) {
            showQuiz = true
        }
    }

    private func handleAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }

        selectedAnswer = answer
        let correct = answer == question.answer
        wasCorrect = correct
        questionsAnswered += 1

        if correct {
            questionsCorrect += 1
            score += 5
            HapticManager.shared.correctAnswer()
            SoundManager.shared.correctAnswer()
        } else {
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.wrongAnswer()
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            answerRevealed = true
        }
    }

    private func generatePieces() {
        var newPieces: [BlockPiece?] = []
        for _ in 0..<3 {
            let randomShape = BlockShape.allCases.randomElement()!
            let randomColor = pieceColors.randomElement()!
            let piece = BlockPiece(shape: randomShape.shape, color: randomColor)
            newPieces.append(piece)
        }
        availablePieces = newPieces
        selectedPieceIndex = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            showQuiz = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            checkGameOver()
        }
    }

    private func saveStats() {
        let elapsed = Int(Date().timeIntervalSince(startTime))
        statsManager.recordSession(
            cardsStudied: questionsAnswered,
            correct: questionsCorrect,
            timeSeconds: elapsed,
            mode: "cozyBlocks"
        )

        dailyGoalsManager.recordStudySession(
            cardsStudied: questionsAnswered,
            correct: questionsCorrect,
            timeSeconds: elapsed
        )

        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "cozyBlocksHighScore")
        }
    }

    private func saveBlocksProgress() {
        // Only save if game is in progress (not over, has pieces or filled cells)
        guard !isGameOver else {
            BlocksSessionProgress.clear()
            SessionProgressManager.shared.clearProgress(for: .blocks)
            return
        }

        let hasPieces = availablePieces.contains(where: { $0 != nil })
        let hasFilledCells = grid.contains(where: { row in row.contains(where: { $0.isFilled }) })
        guard hasPieces || hasFilledCells else {
            BlocksSessionProgress.clear()
            SessionProgressManager.shared.clearProgress(for: .blocks)
            return
        }

        // Encode grid
        let codableGrid: [[CodableGridCell]] = grid.map { row in
            row.map { cell in
                let colorIdx: Int? = cell.color.flatMap { c in
                    pieceColors.firstIndex(of: c)
                }
                return CodableGridCell(isFilled: cell.isFilled, colorIndex: colorIdx)
            }
        }

        // Encode pieces
        let allShapes = BlockShape.allCases
        let codablePieces: [CodableBlockPiece?] = availablePieces.map { piece in
            guard let piece = piece else { return nil }
            let shapeIdx = allShapes.firstIndex(where: { $0.shape == piece.shape }) ?? 0
            let colorIdx = pieceColors.firstIndex(of: piece.color) ?? 0
            return CodableBlockPiece(shapeIndex: shapeIdx, colorIndex: colorIdx)
        }

        let progress = BlocksSessionProgress(
            grid: codableGrid,
            pieces: codablePieces,
            score: score,
            linesCleared: linesCleared,
            questionsAnswered: questionsAnswered,
            questionsCorrect: questionsCorrect,
            cardPoolIndex: cardPoolIndex,
            savedAt: Date()
        )
        progress.save()

        // Also save a SessionProgress so the resume prompt triggers
        // Need currentIndex > 0 && currentIndex < cardIDs.count to pass guard
        SessionProgressManager.shared.saveProgress(
            gameMode: .blocks,
            cardIDs: cardPool.prefix(2).map { $0.id },
            currentIndex: 1,
            score: score
        )
    }
}

// MARK: - Preview

#Preview {
    CozyBlocksView()
        .environmentObject(AppManager())
        .environmentObject(CardManager.shared)
        .environmentObject(SubscriptionManager())
        .environmentObject(StatsManager.shared)
}
