import WidgetKit
import SwiftUI

struct StudyStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StudyStatsEntry {
        StudyStatsEntry(date: Date(), data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (StudyStatsEntry) -> Void) {
        completion(StudyStatsEntry(date: Date(), data: WidgetDataManager.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StudyStatsEntry>) -> Void) {
        let entry = StudyStatsEntry(date: Date(), data: WidgetDataManager.read())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct StudyStatsEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct StudyStatsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: StudyStatsEntry

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            mediumView
        }
    }

    var mediumView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCell(icon: "square.stack.fill", title: "Cards Studied", value: "\(entry.data.totalCardsStudied)", color: Color(red: 0.78, green: 0.71, blue: 0.86))
            StatCell(icon: "target", title: "Accuracy", value: String(format: "%.0f%%", entry.data.accuracy), color: Color(red: 0.71, green: 0.92, blue: 0.84))
            StatCell(icon: "star.fill", title: "Level", value: "\(entry.data.level)", color: Color(red: 0.68, green: 0.85, blue: 0.9))
            xpCell
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }

    var xpCell: some View {
        VStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 1.0, green: 0.72, blue: 0.7))
            Text("\(entry.data.totalXP) XP")
                .font(.system(size: 14, weight: .bold, design: .rounded))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 1.0, green: 0.72, blue: 0.7).opacity(0.3))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 1.0, green: 0.72, blue: 0.7))
                        .frame(width: geo.size.width * entry.data.xpProgress)
                }
            }
            .frame(height: 6)
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground).cornerRadius(10))
    }

    var largeView: some View {
        VStack(spacing: 12) {
            HStack {
                Text(entry.data.levelTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.data.streak) day streak")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCell(icon: "square.stack.fill", title: "Cards Studied", value: "\(entry.data.totalCardsStudied)", color: Color(red: 0.78, green: 0.71, blue: 0.86))
                StatCell(icon: "target", title: "Accuracy", value: String(format: "%.0f%%", entry.data.accuracy), color: Color(red: 0.71, green: 0.92, blue: 0.84))
                StatCell(icon: "star.fill", title: "Level \(entry.data.level)", value: "\(entry.data.totalXP) XP", color: Color(red: 0.68, green: 0.85, blue: 0.9))
                StatCell(icon: "checkmark.circle.fill", title: "Daily Goals", value: "\(entry.data.dailyGoalsCompleted)/\(entry.data.dailyGoalsTotal)", color: Color(red: 1.0, green: 0.72, blue: 0.7))
            }

            VStack(spacing: 4) {
                HStack {
                    Text("XP Progress")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.0f%%", entry.data.xpProgress * 100))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.68, green: 0.85, blue: 0.9).opacity(0.3))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.68, green: 0.85, blue: 0.9))
                            .frame(width: geo.size.width * entry.data.xpProgress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct StatCell: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground).cornerRadius(10))
    }
}

struct StudyStatsWidget: Widget {
    let kind = "StudyStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyStatsProvider()) { entry in
            StudyStatsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Study Stats")
        .description("View your study statistics at a glance.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
