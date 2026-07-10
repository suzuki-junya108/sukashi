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
    public static func danger(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0xFF6B5C) : Color(skHex: 0xD93A2B)
    }
    public static func ok(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(skHex: 0x46C46E) : Color(skHex: 0x2E8A4E)
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
