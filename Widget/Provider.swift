import WidgetKit
import Foundation

struct MonthEntry: TimelineEntry {
    let date: Date
    let title: String
    let weekdays: [String]
    let cells: [DayCell]
    let isCurrentMonth: Bool
}

struct Provider: TimelineProvider {
    /// Build the entry as it should look at `now` for the stored month offset.
    private func makeEntry(at now: Date = Date()) -> MonthEntry {
        let offset = WidgetStore.monthOffset
        let monthStart = MonthGrid.month(forOffset: offset, now: now)
        return MonthEntry(
            date: now,
            title: MonthGrid.title(for: monthStart),
            weekdays: MonthGrid.weekdaySymbols(),
            cells: MonthGrid.cells(for: monthStart, now: now),
            isCurrentMonth: offset == 0
        )
    }

    func placeholder(in context: Context) -> MonthEntry { makeEntry() }

    func getSnapshot(in context: Context, completion: @escaping (MonthEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MonthEntry>) -> Void) {
        let now = Date()
        let cal = Calendar.current
        let nextMidnight = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)

        // Two entries: the current view, and a precomputed one for midnight so the
        // "today" marker moves on time even if WidgetKit delays the reload.
        // Keep the current month offset (relative to the new "now") the same.
        let entries = [makeEntry(at: now), makeEntry(at: nextMidnight)]
        completion(Timeline(entries: entries, policy: .after(nextMidnight)))
    }
}
