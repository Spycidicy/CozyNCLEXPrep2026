import WidgetKit
import SwiftUI

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 7)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let data = WidgetDataManager.read()
        completion(StreakEntry(date: Date(), streak: data.streak))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let data = WidgetDataManager.read()
        let entry = StreakEntry(date: Date(), streak: data.streak)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
}

struct StreakWidgetEntryView: View {
    var entry: StreakEntry

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.35, blue: 0.35)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            Text("\(entry.streak)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("day streak")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.75),
                    Color(red: 1.0, green: 0.72, blue: 0.7)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Study Streak")
        .description("Track your daily study streak.")
        .supportedFamilies([.systemSmall])
    }
}
