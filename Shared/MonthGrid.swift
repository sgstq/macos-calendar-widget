import Foundation

/// One cell in the 6x7 month grid.
struct DayCell: Identifiable, Hashable {
    let id: Int
    let date: Date
    let day: Int
    let isInCurrentMonth: Bool
    let isToday: Bool
    let isWeekend: Bool
}

/// Pure date math for rendering a month view. No state, no UI.
enum MonthGrid {
    private static var calendar: Calendar { Calendar.current }

    /// How far from the current month the widget may be paged (±100 years).
    static let maxOffset = 12 * 100

    static func clampedOffset(_ offset: Int) -> Int {
        min(max(offset, -maxOffset), maxOffset)
    }

    /// First day of the month that is `offset` months from the month containing `now`.
    static func month(forOffset offset: Int, now: Date = Date()) -> Date {
        let cal = calendar
        let startOfThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
        return cal.date(byAdding: .month, value: offset, to: startOfThisMonth) ?? startOfThisMonth
    }

    /// Localized "June 2026" style title.
    static func title(for month: Date) -> String {
        let df = DateFormatter()
        df.calendar = calendar
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("yMMMM")
        return df.string(from: month)
    }

    /// Weekday header symbols ordered by the locale's first weekday.
    static func weekdaySymbols() -> [String] {
        let cal = calendar
        let symbols = cal.veryShortStandaloneWeekdaySymbols
        let first = max(0, min(symbols.count - 1, cal.firstWeekday - 1))
        return Array(symbols[first...] + symbols[..<first])
    }

    /// 42 cells (6 weeks) covering the given month, padded with adjacent days.
    /// `now` decides which cell is "today" so entries can be precomputed for a
    /// future date (e.g. the midnight rollover).
    static func cells(for month: Date, now: Date = Date()) -> [DayCell] {
        let cal = calendar
        let comps = cal.dateComponents([.year, .month], from: month)
        guard let firstOfMonth = cal.date(from: comps) else { return [] }

        let weekday = cal.component(.weekday, from: firstOfMonth)
        let leading = (weekday - cal.firstWeekday + 7) % 7
        guard let gridStart = cal.date(byAdding: .day, value: -leading, to: firstOfMonth) else { return [] }

        var result: [DayCell] = []
        result.reserveCapacity(42)
        for i in 0..<42 {
            guard let date = cal.date(byAdding: .day, value: i, to: gridStart) else { continue }
            result.append(DayCell(
                id: i,
                date: date,
                day: cal.component(.day, from: date),
                isInCurrentMonth: cal.isDate(date, equalTo: firstOfMonth, toGranularity: .month),
                isToday: cal.isDate(date, inSameDayAs: now),
                isWeekend: cal.isDateInWeekend(date)
            ))
        }
        return result
    }
}
