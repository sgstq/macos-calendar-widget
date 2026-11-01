import AppIntents

/// Move the displayed month by `delta` months. Bound to the ◀ / ▶ buttons.
/// Runs in the widget extension; after `perform` returns, WidgetKit reloads the
/// timeline (interaction-initiated reloads are guaranteed), so the grid updates.
struct ShiftMonthIntent: AppIntent {
    static let title: LocalizedStringResource = "Change Month"
    /// Widget-only: keep it out of Shortcuts and Spotlight.
    static let isDiscoverable = false

    @Parameter(title: "Delta")
    var delta: Int

    init() {}
    init(delta: Int) { self.delta = delta }

    func perform() async throws -> some IntentResult {
        WidgetStore.monthOffset += delta
        return .result()
    }
}

/// Jump back to the current month.
struct GoToTodayIntent: AppIntent {
    static let title: LocalizedStringResource = "Go to Today"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        WidgetStore.monthOffset = 0
        return .result()
    }
}
