import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            Text("Calendar Widget is ready")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 10) {
                row("1.circle.fill", "Click the clock / date in the menu bar to open Notification Center.")
                row("2.circle.fill", "Scroll to the bottom and click “Edit Widgets”.")
                row("3.circle.fill", "Find “Calendar” and add the Medium or Large size.")
                row("4.circle.fill", "Use ‹ › to change months, « » to jump years, and the dot to return to today.")
            }
            .padding(16)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

            Text("You can quit this app — the widget keeps working on its own.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Version \(Self.versionString)")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .textSelection(.enabled)
        }
        .padding(28)
        .frame(width: 460)
    }

    /// "0.1.4 (202611011219)": marketing version plus build number, both read
    /// from Info.plist so the window always matches what is installed.
    static var versionString: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }

    private func row(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .font(.callout)
    }
}
