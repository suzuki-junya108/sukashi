import SwiftUI

// MARK: - コード / 確認コード / ショートカット (.sk-code / .sk-code--l / .sk-kbd)
//
// 無彩フィル + ヘアラインのみ。等幅・tabular-nums。色は持たない。

/// インラインコード / 認証コード表示。`large: true` で大表示 (letter-spacing 付き)。
public struct SukashiCode: View {
    private let text: String
    private let large: Bool

    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast

    public init(_ text: String, large: Bool = false) {
        self.text = text
        self.large = large
    }

    public var body: some View {
        Text(text)
            .font(large
                  ? .system(size: 20, weight: .semibold, design: .monospaced)
                  : .system(size: 15, design: .monospaced))
            .monospacedDigit()
            .tracking(large ? 2.4 : 0)
            .foregroundStyle(Sukashi.ink(1, scheme, contrast))
            .padding(.horizontal, large ? Sukashi.Space.s4 : 7)
            .padding(.vertical, large ? Sukashi.Space.s2 : 2)
            .background(Sukashi.fill(1, scheme),
                        in: RoundedRectangle(cornerRadius: large ? Sukashi.Radius.s : 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: large ? Sukashi.Radius.s : 6, style: .continuous)
                    .strokeBorder(Sukashi.hairline(scheme, contrast), lineWidth: 0.5)
            }
    }
}

/// キーボードショートカット表示 (下辺に厚みのあるヘアライン)。
public struct SukashiKbd: View {
    private let text: String

    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(Sukashi.ink(2, scheme, contrast))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Sukashi.fill(1, scheme),
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(alignment: .bottom) {
                Rectangle().fill(Sukashi.hairline(scheme, contrast)).frame(height: 1.5)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Sukashi.hairline(scheme, contrast), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
