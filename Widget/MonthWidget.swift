import WidgetKit
import SwiftUI

struct MonthCalendarWidget: Widget {
    let kind = "MonthCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MonthWidgetView(entry: entry)
                .containerBackground(for: .widget) { WidgetCardBackground() }
        }
        .configurationDisplayName("Calendar")
        .description("A month at a glance. Page through months and years right from Notification Center.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

/// The card behind the calendar.
///
/// Widgets never get the live Liquid Glass material that notification cards
/// use: WidgetKit renders a static image and the host draws it on the standard
/// widget background, which in dark mode is a near-black gradient (about
/// 30 → 13 grey) while the notification cards next to it sit at about 50 grey.
/// A translucent tint over the system background lifts the widget to the same
/// tone without going opaque, so the wallpaper still shows through on the
/// desktop. In light mode the system card is already white; a faint dark tint
/// brings it down to the notification cards' light grey.
struct WidgetCardBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        if #available(macOS 26, *) {
            // Accented / vibrant styles are tinted by the system; leave them alone.
            if renderingMode == .fullColor {
                tint
            } else {
                Color.clear
            }
        } else {
            Rectangle().fill(.background)
        }
    }

    @ViewBuilder
    private var tint: some View {
        if colorScheme == .dark {
            // The system card darkens towards the bottom; tint it a little more
            // there so the card ends up as flat as the notification cards.
            LinearGradient(
                colors: [Color.white.opacity(0.12), Color.white.opacity(0.17)],
                startPoint: .top, endPoint: .bottom
            )
        } else {
            Color.black.opacity(0.05)
        }
    }
}

@main
struct CalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        MonthCalendarWidget()
    }
}
