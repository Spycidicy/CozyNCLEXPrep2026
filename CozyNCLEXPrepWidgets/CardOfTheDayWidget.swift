import WidgetKit
import SwiftUI

struct CardOfTheDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> CardOfTheDayEntry {
        CardOfTheDayEntry(date: Date(), question: "What is the normal range for adult blood pressure?", category: "Fundamentals")
    }

    func getSnapshot(in context: Context, completion: @escaping (CardOfTheDayEntry) -> Void) {
        let data = WidgetDataManager.read()
        completion(CardOfTheDayEntry(date: Date(), question: data.cardOfTheDayQuestion, category: data.cardOfTheDayCategory))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CardOfTheDayEntry>) -> Void) {
        let data = WidgetDataManager.read()
        let entry = CardOfTheDayEntry(date: Date(), question: data.cardOfTheDayQuestion, category: data.cardOfTheDayCategory)

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }
}

struct CardOfTheDayEntry: TimelineEntry {
    let date: Date
    let question: String
    let category: String
}

struct CardOfTheDayWidgetEntryView: View {
    var entry: CardOfTheDayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.45))
                Text("Card of the Day")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
            }

            Text(entry.question)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            HStack {
                Text(entry.category)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.78, green: 0.71, blue: 0.86).opacity(0.3))
                    .clipShape(Capsule())

                Spacer()

                Text("Tap to study")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
        .widgetURL(URL(string: "cozynclex://cardoftheday"))
    }
}

struct CardOfTheDayWidget: Widget {
    let kind = "CardOfTheDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CardOfTheDayProvider()) { entry in
            CardOfTheDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Card of the Day")
        .description("See today's featured NCLEX question.")
        .supportedFamilies([.systemMedium])
    }
}
