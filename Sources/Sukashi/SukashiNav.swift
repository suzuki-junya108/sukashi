import SwiftUI

// MARK: - メニュー / サイドナビ (.sk-menu / .sk-sidenav)
//
// CSS 同様、見た目のみ提供する。開閉・フォーカストラップ・Esc・外側クリックは
// ホスト側の責務 (SwiftUI では Menu / popover / NavigationSplitView 等に載せる)。

extension View {
    /// ドロップダウン/コンテキストメニューの面 (ガラス + 内側パディング)。
    /// 中身は `Button(...).buttonStyle(SukashiMenuItemStyle())` を縦に並べる。
    public func sukashiMenuSurface() -> some View {
        self
            .padding(Sukashi.Space.s2)
            .sukashiGlass(radius: Sukashi.Radius.m)
    }
}

/// メニュー項目。ホバーで無彩フィル。`danger: true` で削除系。
public struct SukashiMenuItemStyle: ButtonStyle {
    private let danger: Bool
    public init(danger: Bool = false) { self.danger = danger }

    public func makeBody(configuration: Configuration) -> some View {
        StyleBody(danger: danger, configuration: configuration)
    }

    private struct StyleBody: View {
        let danger: Bool
        let configuration: Configuration
        @Environment(\.colorScheme) private var scheme
        @Environment(\.colorSchemeContrast) private var contrast
        @State private var hovering = false

        var body: some View {
            configuration.label
                .font(Sukashi.font(.sub))
                .foregroundStyle(danger ? Sukashi.danger(scheme) : Sukashi.ink(1, scheme, contrast))
                .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                .padding(.horizontal, Sukashi.Space.s3)
                .background(
                    (hovering || configuration.isPressed) ? Sukashi.fill(1, scheme) : .clear,
                    in: RoundedRectangle(cornerRadius: Sukashi.Radius.m - Sukashi.Space.s2, style: .continuous)
                )
                .contentShape(Rectangle())
                .onHover { hovering = $0 }
        }
    }
}

/// デスクトップ用サイドナビ項目。選択状態は「塗りでなく形」(seg / tabbar と同公式)。
public struct SukashiSideNavItem: View {
    private let title: String
    private let systemImage: String?
    private let isOn: Bool
    private let action: () -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast
    @State private var hovering = false

    public init(_ title: String,
                systemImage: String? = nil,
                isOn: Bool,
                action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isOn = isOn
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Sukashi.Space.s3) {
                if let systemImage {
                    Image(systemName: systemImage).frame(width: 20)
                }
                Text(title).font(Sukashi.font(.sub).weight(.semibold))
                Spacer(minLength: 0)
            }
            .foregroundStyle(isOn ? Sukashi.ink(1, scheme, contrast) : Sukashi.ink(2, scheme, contrast))
            .frame(minHeight: 40)
            .padding(.horizontal, Sukashi.Space.s3)
            .background {
                if isOn {
                    let shape = RoundedRectangle(cornerRadius: Sukashi.Radius.l - Sukashi.Space.s2, style: .continuous)
                    shape
                        .fill(scheme == .dark ? Color.white.opacity(0.10) : Color.white.opacity(0.6))
                        .overlay(alignment: .top) {
                            Rectangle().fill(.white.opacity(scheme == .dark ? 0.18 : 0.5))
                                .frame(height: 1).padding(.horizontal, 6)
                        }
                        .clipShape(shape)
                        .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
                } else if hovering {
                    // 非選択項目の hover: 無彩フィル(CSS .sk-sidenav__item:hover と同じ)
                    RoundedRectangle(cornerRadius: Sukashi.Radius.l - Sukashi.Space.s2, style: .continuous)
                        .fill(Sukashi.fill(1, scheme))
                }
            }
            .contentShape(Rectangle())
            .onHover { hovering = $0 }
        }
        .buttonStyle(.plain)
    }
}
