import SwiftUI
import UIKit

/// SipNear design tokens — brand character constrained by Apple HIG.
enum SipTheme {
    enum ColorToken {
        static let burgundy = Color(red: 0.42, green: 0.114, blue: 0.165)
        static let burgundyDeep = Color(red: 0.29, green: 0.07, blue: 0.125)
        static let wine = Color(red: 0.608, green: 0.137, blue: 0.208)
        static let gold = Color(red: 0.788, green: 0.635, blue: 0.153)
        static let goldSoft = Color(red: 0.91, green: 0.83, blue: 0.545)

        static let canvas = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.07, blue: 0.07, alpha: 1)
                : UIColor(red: 0.984, green: 0.969, blue: 0.949, alpha: 1)
        })

        static let surface = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.11, blue: 0.11, alpha: 1)
                : UIColor(red: 1.0, green: 0.992, blue: 0.976, alpha: 1)
        })

        static let surfaceSecondary = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.18, green: 0.14, blue: 0.14, alpha: 1)
                : UIColor(red: 0.953, green: 0.922, blue: 0.882, alpha: 1)
        })

        static let ink = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1)
                : UIColor(red: 0.11, green: 0.08, blue: 0.07, alpha: 1)
        })

        static let inkSecondary = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.78, alpha: 1)
                : UIColor(red: 0.29, green: 0.25, blue: 0.23, alpha: 1)
        })

        static let muted = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.62, alpha: 1)
                : UIColor(red: 0.54, green: 0.49, blue: 0.46, alpha: 1)
        })

        static let border = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.10)
                : UIColor(red: 0.91, green: 0.87, blue: 0.82, alpha: 1)
        })
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 40
    }

    enum Radius {
        static let chip: CGFloat = 100
        static let card: CGFloat = 22
        static let panel: CGFloat = 28
        static let button: CGFloat = 26
    }

    enum Motion {
        static let gentle = Animation.spring(response: 0.45, dampingFraction: 0.86)
        static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.82)
        static let emphasized = Animation.spring(response: 0.55, dampingFraction: 0.78)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6: (r, g, b) = ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}

extension View {
    func sipCardStyle() -> some View {
        self
            .background(SipTheme.ColorToken.surface)
            .clipShape(RoundedRectangle(cornerRadius: SipTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SipTheme.Radius.card, style: .continuous)
                    .stroke(SipTheme.ColorToken.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, y: 6)
    }

    func sipCanvas() -> some View {
        background(SipTheme.ColorToken.canvas.ignoresSafeArea())
    }
}
