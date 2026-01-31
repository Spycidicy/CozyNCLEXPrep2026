import WidgetKit
import SwiftUI

struct AffirmationProvider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: Date(), affirmation: "You are going to pass the NCLEX. Believe it.")
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        completion(AffirmationEntry(date: Date(), affirmation: WidgetDataManager.todaysAffirmation))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let entry = AffirmationEntry(date: Date(), affirmation: WidgetDataManager.todaysAffirmation)

        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }
}

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
}

struct AffirmationWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: AffirmationEntry

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
            Image(systemName: "heart.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color(red: 1.0, green: 0.59, blue: 0.59))

            Text(entry.affirmation)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.93, blue: 0.93),
                    Color(red: 0.95, green: 0.9, blue: 1.0)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var mediumView: some View {
        HStack(spacing: 12) {
            Image("NurseBear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color(red: 1.0, green: 0.72, blue: 0.7), lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.affirmation)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\u{2014} CozyBear")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.59, blue: 0.59))
            }

            Spacer()
        }
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.93, blue: 0.93),
                    Color(red: 0.95, green: 0.9, blue: 1.0)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

struct AffirmationWidget: Widget {
    let kind = "AffirmationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AffirmationProvider()) { entry in
            AffirmationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Affirmation")
        .description("A daily dose of encouragement from CozyBear.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
