import SwiftUI

// NSColorWell wrapper for SwiftUI
struct ColorWell: NSViewRepresentable {
    @Binding var selectedColor: NSColor
    var style: NSColorWell.Style = .minimal

    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell(style: style)
        colorWell.color = selectedColor
        colorWell.target = context.coordinator
        colorWell.action = #selector(Coordinator.colorChanged(_:))

        return colorWell
    }

    func updateNSView(_ nsView: NSColorWell, context: Context) {
        nsView.color = selectedColor

        // Update continuous property if changed
        if nsView.target == nil {
            nsView.target = context.coordinator
            nsView.action = #selector(Coordinator.colorChanged(_:))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ColorWell

        init(_ parent: ColorWell) {
            self.parent = parent
        }

        @objc func colorChanged(_ sender: NSColorWell) {
            parent.selectedColor = sender.color
        }
    }
}
