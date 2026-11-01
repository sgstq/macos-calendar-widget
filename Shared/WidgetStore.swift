import Foundation

/// Tiny persistence layer shared between the App Intents (which write) and the
/// timeline provider (which reads). Both run inside the widget extension, so
/// the extension's standard defaults are a reliable shared store — no App Group
/// (and thus no paid developer account) required for v1.
enum WidgetStore {
    private static let defaults = UserDefaults.standard
    private static let monthOffsetKey = "monthOffset"

    /// Number of months away from the current month being displayed (0 = today's month).
    /// Clamped so repeated clicks can never page into a range the calendar can't represent.
    static var monthOffset: Int {
        get { MonthGrid.clampedOffset(defaults.integer(forKey: monthOffsetKey)) }
        set { defaults.set(MonthGrid.clampedOffset(newValue), forKey: monthOffsetKey) }
    }
}
