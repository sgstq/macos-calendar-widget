import AppIntents
import SwiftUI
import WidgetKit

/// Month calendar styled after the macOS 26 (Tahoe) system look: a bold month
/// title, navigation controls grouped in a single capsule, quiet weekday
/// captions, and a single accent-colored "today" marker.
struct MonthWidgetView: View {
    let entry: MonthEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    private var isLarge: Bool { family == .systemLarge }

    // MARK: Metrics

    private var titleSize: CGFloat { isLarge ? 17 : 14 }
    private var daySize: CGFloat { isLarge ? 15 : 12 }
    private var weekdaySize: CGFloat { isLarge ? 11 : 9 }
    private var todayCircle: CGFloat { isLarge ? 30 : 22 }
    private var controlIconSize: CGFloat { isLarge ? 11 : 9 }
    private var controlButtonWidth: CGFloat { isLarge ? 26 : 21 }
    private var controlHeight: CGFloat { isLarge ? 26 : 21 }
    private var sectionSpacing: CGFloat { isLarge ? 8 : 4 }

    /// Split the flat 42-cell list into weeks of 7.
    private var weeks: [[DayCell]] {
        stride(from: 0, to: entry.cells.count, by: 7).map {
            Array(entry.cells[$0 ..< min($0 + 7, entry.cells.count)])
        }
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: sectionSpacing) {
            header
            weekdayRow
            monthGrid
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 6) {
            Text(entry.title)
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 4)

            controls
        }
    }

    /// Navigation controls in one capsule, like the segmented pills in Tahoe
    /// toolbars: « ‹ ● › ».
    private var controls: some View {
        HStack(spacing: 0) {
            controlButton(intent: ShiftMonthIntent(delta: -12), label: "Previous year") {
                Image(systemName: "chevron.left.2")
            }
            controlButton(intent: ShiftMonthIntent(delta: -1), label: "Previous month") {
                Image(systemName: "chevron.left")
            }
            controlButton(intent: GoToTodayIntent(), label: "Go to today") {
                Circle()
                    .fill(entry.isCurrentMonth ? AnyShapeStyle(.tertiary) : AnyShapeStyle(todayColor))
                    .frame(width: controlIconSize - 1, height: controlIconSize - 1)
                    .widgetAccentable()
            }
            controlButton(intent: ShiftMonthIntent(delta: 1), label: "Next month") {
                Image(systemName: "chevron.right")
            }
            controlButton(intent: ShiftMonthIntent(delta: 12), label: "Next year") {
                Image(systemName: "chevron.right.2")
            }
        }
        .font(.system(size: controlIconSize, weight: .bold))
        .foregroundStyle(.secondary)
        .frame(height: controlHeight)
        .background(.fill.tertiary, in: Capsule())
        .overlay(Capsule().strokeBorder(.separator.opacity(0.4), lineWidth: 0.5))
    }

    private func controlButton<I: AppIntent, Content: View>(
        intent: I,
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Button(intent: intent) {
            content()
                .frame(width: controlButtonWidth, height: controlHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: Weekdays

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(entry.weekdays.enumerated()), id: \.offset) { _, symbol in
                Text(symbol.uppercased())
                    .font(.system(size: weekdaySize, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Grid

    private var monthGrid: some View {
        ZStack {
            // Week rows expand to share all remaining height -> grid fills the widget.
            VStack(spacing: 0) {
                ForEach(weeks.indices, id: \.self) { i in
                    HStack(spacing: 0) {
                        ForEach(weeks[i]) { cell in
                            dayView(cell)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // Broad click zones: left half pages back, right half pages forward.
            HStack(spacing: 0) {
                pageZone(delta: -1, label: "Previous month")
                pageZone(delta: 1, label: "Next month")
            }
        }
    }

    private func pageZone(delta: Int, label: String) -> some View {
        Button(intent: ShiftMonthIntent(delta: delta)) {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func dayView(_ cell: DayCell) -> some View {
        Text(verbatim: "\(cell.day)")
            .font(.system(size: daySize, weight: cell.isToday ? .bold : .medium, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(dayStyle(cell))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if cell.isToday {
                    // Full disc in today's month; a quiet ring when today shows up
                    // as an adjacent-month day while browsing another month.
                    Group {
                        if cell.isInCurrentMonth {
                            Circle().fill(todayColor)
                        } else {
                            Circle().strokeBorder(todayColor.opacity(0.7), lineWidth: 1.5)
                        }
                    }
                    .frame(width: todayCircle, height: todayCircle)
                    .widgetAccentable()
                }
            }
    }

    // MARK: Colors

    /// Red like the system Calendar; in accented/vibrant desktop modes the
    /// system recolors it, so keep it a plain color.
    private var todayColor: Color { .red }

    private func dayStyle(_ cell: DayCell) -> AnyShapeStyle {
        if cell.isToday {
            if !cell.isInCurrentMonth { return AnyShapeStyle(todayColor) }
            // In vibrant/accented rendering the circle is recolored by the system,
            // so black-on-tint reads better than forcing white.
            return renderingMode == .fullColor ? AnyShapeStyle(.white) : AnyShapeStyle(.black)
        }
        if !cell.isInCurrentMonth { return AnyShapeStyle(.quaternary) }
        return cell.isWeekend ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary)
    }
}

// MARK: - Previews

#if DEBUG
private func previewEntry(offset: Int = 0) -> MonthEntry {
    let now = Date()
    let month = MonthGrid.month(forOffset: offset, now: now)
    return MonthEntry(
        date: now,
        title: MonthGrid.title(for: month),
        weekdays: MonthGrid.weekdaySymbols(),
        cells: MonthGrid.cells(for: month, now: now),
        isCurrentMonth: offset == 0
    )
}

#Preview("Large", as: .systemLarge) {
    MonthCalendarWidget()
} timeline: {
    previewEntry()
    previewEntry(offset: 3)
}

#Preview("Medium", as: .systemMedium) {
    MonthCalendarWidget()
} timeline: {
    previewEntry()
}
#endif
