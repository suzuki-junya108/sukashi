import SwiftUI

// MARK: - sukashi デザインシステム (SwiftUI 版)
//
// Web 版 sukashi.css v2.1 の SwiftUI への転写。
// 憲法: モノクローム / グラデ無し / ガラスはクローム / 面に色を塗らない。
// ライト/ダークは `@Environment(\.colorScheme)` 追従。AppKit/UIKit には依存しない。

public enum Sukashi {

    /// 4px グリッドの余白段階 (CSS の --sk-sp-* に対応)。
    public enum Space {
        public static let s1: CGFloat = 4
        public static let s2: CGFloat = 8
        public static let s3: CGFloat = 12
        public static let s4: CGFloat = 16
        public static let s6: CGFloat = 24
        public static let s8: CGFloat = 32
    }

    /// 同心円半径 12 / 18 / 26 (pill は Capsule を使う)。
    public enum Radius {
        public static let s: CGFloat = 12
        public static let m: CGFloat = 18
        public static let l: CGFloat = 26
    }

    /// モノクロームのプライマリー。黒(light) ↔ 近白(dark) へ反転する。
    public static func accent(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0xF5F6F8) : Color(skHex: 0x111418)
    }

    /// プライマリー面上の図 (スイッチのつまみ・チェック等)。反転時も消えない色。
    public static func onAccent(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0x16181D) : .white
    }

    /// カテゴリ識別色 (8色)。状態色とは別枠の識別専用色。
    /// glyph / ドット / リードバーにのみ使い、面 (background) には塗らない。
    /// index は 1 始まり。範囲外は巡回させる。
    public static func category(_ index: Int, _ scheme: ColorScheme) -> Color {
        let light: [UInt32] = [0x2F7FF0, 0x14B8A6, 0x1AA860, 0xE0A020,
                               0xF0691E, 0xE5396B, 0x8B5CF6, 0x64748B]
        let dark: [UInt32] = [0x5AA0FF, 0x3FD3C1, 0x46C46E, 0xF0BC4E,
                              0xFF8A4C, 0xFF6088, 0xA98BFF, 0x94A3B8]
        let table = scheme == .dark ? dark : light
        let wrapped = ((index - 1) % table.count + table.count) % table.count
        return Color(skHex: table[wrapped])
    }

    /// 意味色 (状態表示に限定)。暗背景では一段明るい値へ差し替える。
    /// 警告(注意・要確認)は amber を持たず danger に集約する(憲法)。
    public static func danger(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0xFF6B5C) : Color(skHex: 0xD93A2B)
    }
    public static func ok(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0x46C46E) : Color(skHex: 0x2E8A4E)
    }

    // MARK: - インク (ガラス上の文字。3段階)
    //
    // CSS の --sk-ink / --sk-ink-2 / --sk-ink-3 に対応。
    // OS の「コントラストを上げる」(colorSchemeContrast == .increased)で中間段を引き上げる。
    // level は 1(本文) / 2(補助) / 3(メタ)。

    /// ガラス上のインク色。level 1/2/3、コントラスト対応。
    public static func ink(_ level: Int,
                           _ scheme: ColorScheme,
                           _ contrast: ColorSchemeContrast = .standard) -> Color {
        let more = contrast == .increased
        let opacity: Double
        switch level {
        case 1: opacity = 0.95
        case 2: opacity = more ? 0.78 : 0.60
        default: opacity = more ? 0.56 : 0.35
        }
        return inkBase(scheme).opacity(opacity)
    }

    /// 無彩の静的フィル (CSS の --sk-fill-1 / --sk-fill-2)。level 1/2。
    public static func fill(_ level: Int, _ scheme: ColorScheme) -> Color {
        inkBase(scheme).opacity(level >= 2 ? 0.10 : 0.06)
    }

    /// ヘアライン (区切り線・内枠。CSS の --sk-hairline)。コントラスト対応。
    public static func hairline(_ scheme: ColorScheme,
                                _ contrast: ColorSchemeContrast = .standard) -> Color {
        inkBase(scheme).opacity(contrast == .increased ? 0.28 : 0.14)
    }

    /// インク/フィル/ヘアラインの基準色 (--sk-ink-rgb: light 20,20,25 / dark 236,238,243)。
    private static func inkBase(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0xECEEF3) : Color(skHex: 0x141419)
    }

    // MARK: - タイポグラフィ (HIG 整合・base 17px)
    //
    // CSS のタイポユーティリティ (.sk-t-large 〜 .sk-t-caption) と同寸・同ウェイト。
    // 色は持たない (色は ink 3段の責務)。

    public enum TextStyle {
        case large, title1, title2, title3, body, sub, foot, caption
    }

    /// セマンティックなフォント。サイズ・太さのみ (色は付けない)。
    public static func font(_ style: TextStyle) -> Font {
        switch style {
        case .large:   return .system(size: 34, weight: .heavy)
        case .title1:  return .system(size: 28, weight: .bold)
        case .title2:  return .system(size: 22, weight: .bold)
        case .title3:  return .system(size: 20, weight: .semibold)
        case .body:    return .system(size: 17)
        case .sub:     return .system(size: 15)
        case .foot:    return .system(size: 13)
        case .caption: return .system(size: 12)
        }
    }

    /// 数値/コード用の等幅フォント (tabular-nums)。CSS の --sk-mono / .sk-mono。
    public static var mono: Font {
        .system(.body, design: .monospaced).monospacedDigit()
    }
}

extension Color {
    /// 0xRRGGBB 形式の整数から Color を生成する (Sukashi トークン定義専用)。
    init(skHex hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
