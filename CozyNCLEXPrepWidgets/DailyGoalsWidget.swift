import WidgetKit
import SwiftUI

struct DailyGoalsProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyGoalsEntry {
        DailyGoalsEntry(date: Date(), completed: 2, total: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyGoalsEntry) -> Void) {
        let data = WidgetDataManager.read()
        completion(DailyGoalsEntry(date: Date(), completed: data.dailyGoalsCompleted, total: data.dailyGoalsTotal))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyGoalsEntry>) -> Void) {
        let data = WidgetDataManager.read()
        let entry = DailyGoalsEntry(date: Date(), completed: data.dailyGoalsCompleted, total: data.dailyGoalsTotal)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct DailyGoalsEntry: TimelineEntry {
    let date: Date
    let completed: Int
    let total: Int
}

struct DailyGoalsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: DailyGoalsEntry

    var progress: Double {
        guard entry.total > 0 else { return 0 }
        return Double(entry.completed) / Double(entry.total)
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    var smallView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.71, green: 0.92, blue: 0.84).opacity(0.3), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color(red: 0.71, green: 0.92, blue: 0.84), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(entry.completed)/\(entry.total)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.71, green: 0.92, blue: 0.84))
                }
            }
            .frame(width: 80, height: 80)

            Text("Daily Goals")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }

    var mediumView: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.71, green: 0.92, blue: 0.84).opacity(0.3), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color(red: 0.71, green: 0.92, blue: 0.84), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(entry.completed)/\(entry.total)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Goals")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Goals")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                ForEach(0..<entry.total, id: \.self) { index in
                    HStack(spacing: 6) {
                        Image(systemName: index < entry.completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                            .foregroundStyle(index < entry.completed ? Color(red: 0.71, green: 0.92, blue: 0.84) : .secondary)
                        Text("Goal \(index + 1)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(index < entry.completed ? .primary : .secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct DailyGoalsWidget: Widget {
    let kind = "DailyGoalsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyGoalsProvider()) { entry in
            DailyGoalsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Goals")
        .description("Track your daily study goals.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
