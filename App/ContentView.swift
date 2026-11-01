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
        }
        .padding(28)
        .frame(width: 460)
    }

    private func row(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
            Text(text)
            Spacer(minLength: 0)
        }
        .font(.callout)
    }
}
