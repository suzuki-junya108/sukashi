import SwiftUI

// MARK: - ボタンスタイル (.sk-btn の各種)
//
// CSS の .sk-btn--primary / --danger / --quiet と、ガラスボタン(.sk-glass .sk-btn) を
// SwiftUI の ButtonStyle として提供する。確定系(primary/danger)は透けさせない不透明面。

public struct SukashiButtonStyle: ButtonStyle {
    public enum Kind { case primary, danger, quiet, glass }

    private let kind: Kind
    public init(_ kind: Kind) { self.kind = kind }

    public func makeBody(configuration: Configuration) -> some View {
        StyleBody(kind: kind, configuration: configuration)
    }

    private struct StyleBody: View {
        let kind: Kind
        let configuration: Configuration
        @Environment(\.colorScheme) private var scheme
        @Environment(\.sukashiAccent) private var accent
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var hovering = false

        var body: some View {
            let label = configuration.label
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, Sukashi.Space.s6)
                .frame(minHeight: 44)

            // マイクロインタラクション: press で沈み(scale)、hover で 1px 浮く(ポインタ環境のみ)。
            // reduce-motion 時はアニメーションを外す(状態変化は即時反映)。
            let anim: Animation? = reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.7)
            styled(label)
                .opacity(configuration.isPressed ? 0.92 : 1)
                .scaleEffect(configuration.isPressed ? 0.96 : 1)
                .offset(y: (hovering && !configuration.isPressed) ? -1 : 0)
                .animation(anim, value: configuration.isPressed)
                .animation(anim, value: hovering)
                .onHover { hovering = $0 }
        }

        @ViewBuilder
        private func styled(_ label: some View) -> some View {
            switch kind {
            case .primary:
                label
                    .foregroundStyle(accent.on(scheme))
                    .background(accent.color(scheme), in: Capsule())
                    .overlay { Capsule().strokeBorder(.white.opacity(0.35), lineWidth: 0.5).blendMode(.plusLighter) }
                    .shadow(color: .black.opacity(scheme == .dark ? 0.4 : 0.16), radius: 12, y: 6)
            case .danger:
                label
                    .foregroundStyle(Color.white)
                    .background(Sukashi.danger(scheme), in: Capsule())
                    .shadow(color: .black.opacity(scheme == .dark ? 0.4 : 0.16), radius: 12, y: 6)
            case .quiet:
                label.foregroundStyle(accent.color(scheme))
            case .glass:
                label
                    .foregroundStyle(Sukashi.ink(1, scheme))
                    .sukashiGlass(radius: 22)   // pill (min-height 44 / 2)
            }
        }
    }
}

extension ButtonStyle where Self == SukashiButtonStyle {
    /// 主操作 (不透明・accent 面)。
    public static var sukashiPrimary: SukashiButtonStyle { .init(.primary) }
    /// 破壊的な確定操作 (不透明・danger 面)。
    public static var sukashiDanger: SukashiButtonStyle { .init(.danger) }
    /// 補助操作 (透明・accent 文字)。
    public static var sukashiQuiet: SukashiButtonStyle { .init(.quiet) }
    /// ガラス面のボタン。
    public static var sukashiGlass: SukashiButtonStyle { .init(.glass) }
}
