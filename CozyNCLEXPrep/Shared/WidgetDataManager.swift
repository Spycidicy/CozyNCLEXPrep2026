import Foundation

struct WidgetData: Codable {
    var streak: Int
    var level: Int
    var levelTitle: String
    var totalXP: Int
    var xpProgress: Double
    var totalCardsStudied: Int
    var accuracy: Double
    var dailyGoalsCompleted: Int
    var dailyGoalsTotal: Int
    var cardOfTheDayQuestion: String
    var cardOfTheDayCategory: String
    var lastUpdated: Date

    static let empty = WidgetData(
        streak: 0, level: 1, levelTitle: "Nursing Newbie",
        totalXP: 0, xpProgress: 0, totalCardsStudied: 0,
        accuracy: 0, dailyGoalsCompleted: 0, dailyGoalsTotal: 3,
        cardOfTheDayQuestion: "Start studying to see your Card of the Day!",
        cardOfTheDayCategory: "General",
        lastUpdated: Date()
    )
}

class WidgetDataManager {
    static let suiteName = "group.EthanLong.CozyNCLEXPrep"
    private static let key = "widgetData"

    static let affirmations: [String] = [
        "You are going to pass the NCLEX. Believe it.",
        "Every card you study brings you closer to your RN.",
        "You didn't come this far to only come this far.",
        "Future nurses don't quit. Neither will you.",
        "Your patients are waiting for you. Keep going.",
        "Difficult roads lead to beautiful destinations \u{2014} like your nursing career.",
        "You are more prepared than you think.",
        "One question at a time. One day at a time. You've got this.",
        "The NCLEX is just one test. You are a whole nurse.",
        "Your dedication today is tomorrow's confidence.",
        "Nursing school didn't break you. The NCLEX won't either.",
        "You're not just studying \u{2014} you're building a career that saves lives.",
        "Every expert was once a beginner. You're almost there.",
        "Trust your preparation. Trust yourself.",
        "You are capable of hard things \u{2014} and passing the NCLEX is one of them.",
        "The world needs more nurses like you.",
        "Progress, not perfection. You're doing great.",
        "This time next year, you'll be glad you didn't give up today.",
        "You have the knowledge. You have the heart. You will pass.",
        "CozyBear believes in you. Now believe in yourself."
    ]

    static var todaysAffirmation: String {
        // Prefer cached remote affirmations from the main app, fall back to hardcoded
        let pool: [String]
        if let defaults = UserDefaults(suiteName: suiteName),
           let cached = defaults.stringArray(forKey: "cachedAffirmations"),
           !cached.isEmpty {
            pool = cached
        } else {
            pool = affirmations
        }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % pool.count
        return pool[index]
    }

    static func update(
        streak: Int, level: Int, levelTitle: String,
        totalXP: Int, xpProgress: Double,
        totalCardsStudied: Int, accuracy: Double,
        dailyGoalsCompleted: Int, dailyGoalsTotal: Int,
        cardOfTheDayQuestion: String, cardOfTheDayCategory: String
    ) {
        let data = WidgetData(
            streak: streak, level: level, levelTitle: levelTitle,
            totalXP: totalXP, xpProgress: xpProgress,
            totalCardsStudied: totalCardsStudied, accuracy: accuracy,
            dailyGoalsCompleted: dailyGoalsCompleted, dailyGoalsTotal: dailyGoalsTotal,
            cardOfTheDayQuestion: cardOfTheDayQuestion,
            cardOfTheDayCategory: cardOfTheDayCategory,
            lastUpdated: Date()
        )
        guard let defaults = UserDefaults(suiteName: suiteName),
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: key)
    }

    static func read() -> WidgetData {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }
}
