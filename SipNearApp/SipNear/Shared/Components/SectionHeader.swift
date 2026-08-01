import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: SipTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(SipTheme.ColorToken.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(SipTheme.ColorToken.muted)
                }
            }
            Spacer(minLength: 8)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(SipTheme.ColorToken.burgundy)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct EmptyStateCard: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: SipTheme.Spacing.xs) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(SipTheme.ColorToken.burgundy)
                .symbolRenderingMode(.hierarchical)
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(SipTheme.ColorToken.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(SipTheme.ColorToken.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SipTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sipCardStyle()
        .accessibilityElement(children: .combine)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? .white : SipTheme.ColorToken.inkSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? SipTheme.ColorToken.burgundy : SipTheme.ColorToken.surface)
                .overlay(
                    Capsule().stroke(
                        isSelected ? SipTheme.ColorToken.burgundy : SipTheme.ColorToken.border,
                        lineWidth: 1
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
