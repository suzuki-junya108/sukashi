import SwiftUI

// MARK: - sukashi ガラス材質 / 識別色マーク (SwiftUI 版)
//
// CSS の `.sk-glass` を SwiftUI で再現する。backdrop blur は `.regularMaterial`
// (ライト/ダーク自動追従) で近似し、憲法の「実線ヘアライン2本」=
// 外周エッジ + 上辺スペキュラを overlay で足す (グラデーションは使わない)。
// 真の Liquid Glass (OS 26 の .glassEffect) を待たずに macOS 14 / iOS 17 で成立する静的近似。

private struct SukashiGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var radius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        // 外周リム: 白下地=黒の微エッジ / 暗下地=白の微光リム (どちらも実線・低アルファ)。
        let edge = scheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.16)
        // 上辺スペキュラ: CSS の inset 0 1px 0 相当。角丸を避けて水平に inset した 1px の実線。
        let specular = Color.white.opacity(scheme == .dark ? 0.22 : 0.55)
        let shadow = Color.black.opacity(scheme == .dark ? 0.40 : 0.16)

        return content
            .background(.regularMaterial, in: shape)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(specular)
                    .frame(height: 1)
                    .padding(.horizontal, radius)
                    .padding(.top, 0.5)
            }
            .clipShape(shape)
            .overlay { shape.strokeBorder(edge, lineWidth: 0.5) }
            .shadow(color: shadow, radius: 15, x: 0, y: 10)
    }
}

extension View {
    /// sukashi のガラス材質を合成する。クローム (ツールバー・フローティング操作) 専用。
    /// 長文・表・フォームの本体には使わない (憲法: ガラスはクロームに使う)。
    public func sukashiGlass(radius: CGFloat = Sukashi.Radius.l) -> some View {
        modifier(SukashiGlassModifier(radius: radius))
    }
}

// MARK: - 識別色マーク (面ではなくマーク/ヘアラインとして色を乗せる)

/// カテゴリ識別のドット (8px)。面ではなく点。index は 1 始まり。
public struct SukashiDot: View {
    @Environment(\.colorScheme) private var scheme
    private let index: Int
    public init(_ index: Int) { self.index = index }
    public var body: some View {
        Circle()
            .fill(Sukashi.category(index, scheme))
            .frame(width: 8, height: 8)
    }
}

/// カテゴリ識別のリードバー (3px の縦線)。行/カード左端の識別。面塗りの代替。
public struct SukashiCatBar: View {
    @Environment(\.colorScheme) private var scheme
    private let index: Int
    public init(_ index: Int) { self.index = index }
    public var body: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Sukashi.category(index, scheme))
            .frame(width: 3)
            .frame(maxHeight: .infinity)
    }
}

extension View {
    /// glyph (アイコン/短ラベル) を識別色で着色する。index は 1 始まり。
    public func sukashiCategory(_ index: Int) -> some View {
        modifier(SukashiCategoryTint(index: index))
    }
}

private struct SukashiCategoryTint: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    let index: Int
    func body(content: Content) -> some View {
        content.foregroundStyle(Sukashi.category(index, scheme))
    }
}

#if DEBUG
#Preview("sukashi glass / light") {
    SukashiPreviewCard()
        .padding(40)
        .frame(width: 340, height: 260)
        .background(Color.white)
        .environment(\.colorScheme, .light)
}

#Preview("sukashi glass / dark") {
    SukashiPreviewCard()
        .padding(40)
        .frame(width: 340, height: 260)
        .background(Color(skHex: 0x0E0F12))
        .environment(\.colorScheme, .dark)
}

/// プレビュー専用の確認カード。ガラス面 + 識別色 (ドット/バー/アイコン)。
private struct SukashiPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Sukashi.Space.s3) {
            Text("sukashi glass")
                .font(.headline)
            HStack(spacing: Sukashi.Space.s2) {
                ForEach(1...8, id: \.self) { SukashiDot($0) }
            }
            HStack(spacing: Sukashi.Space.s3) {
                SukashiCatBar(6).frame(height: 28)
                Image(systemName: "heart")
                    .sukashiCategory(6)
                Text("Design — 面は無彩・色は点と線だけ")
                    .font(.caption)
            }
        }
        .padding(Sukashi.Space.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sukashiGlass()
    }
}
#endif
