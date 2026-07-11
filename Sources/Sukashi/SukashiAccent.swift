import SwiftUI

// MARK: - プライマリー色の切替 (opt-in)
//
// CSS の `.sk-accent-<hue>` / `--sk-accent` 切替機構の SwiftUI 版。
// 既定はモノクローム (黒 → ダークで近白) で不変。ブランド識別色を 1 色だけ
// 乗せたい場合に限り opt-in で差し替える。差し替わるのは accent 面
// (primary / danger 以外のボタン・進捗・ステッパー現在位置等) の色相だけで、
// ガラス面には一切色を塗らない = 透明性の憲法を守る。意味色 (danger/ok) も不変。

/// プライマリーの色定義。light/dark それぞれに面色と面上文字色を持つ。
public struct SukashiAccent {
    public var light: Color
    public var dark: Color
    public var onLight: Color
    public var onDark: Color

    public init(light: Color, dark: Color,
                onLight: Color = .white,
                onDark: Color = Color(.sRGB, red: 22 / 255, green: 24 / 255, blue: 29 / 255, opacity: 1)) {
        self.light = light
        self.dark = dark
        self.onLight = onLight
        self.onDark = onDark
    }

    /// 現在のスキームでの面色。
    public func color(_ scheme: ColorScheme) -> Color { scheme == .dark ? dark : light }
    /// 現在のスキームでの面上文字/チェック色。
    public func on(_ scheme: ColorScheme) -> Color { scheme == .dark ? onDark : onLight }

    /// 既定 (モノクローム)。黒 ↔ 近白。CSS の初期 --sk-accent に一致。
    public static let mono = SukashiAccent(
        light: Color(skHex: 0x111418), dark: Color(skHex: 0xF5F6F8))

    // プリセット6色。light=中濃色+白文字 / dark=一段明色+暗文字 (CSS と同値)。
    public static let blue = SukashiAccent(light: Color(skHex: 0x2563EB), dark: Color(skHex: 0x6AA1FF))
    public static let teal = SukashiAccent(light: Color(skHex: 0x0F766E), dark: Color(skHex: 0x4FD1C5))
    public static let green = SukashiAccent(light: Color(skHex: 0x15803D), dark: Color(skHex: 0x4ADE80))
    public static let purple = SukashiAccent(light: Color(skHex: 0x7C3AED), dark: Color(skHex: 0xB794F6))
    public static let pink = SukashiAccent(light: Color(skHex: 0xDB2777), dark: Color(skHex: 0xF776A8))
    public static let orange = SukashiAccent(light: Color(skHex: 0xC2410C), dark: Color(skHex: 0xFB9A56))
}

private struct SukashiAccentKey: EnvironmentKey {
    static let defaultValue = SukashiAccent.mono
}

extension EnvironmentValues {
    /// 現在の sukashi プライマリー色。既定はモノクローム。
    public var sukashiAccent: SukashiAccent {
        get { self[SukashiAccentKey.self] }
        set { self[SukashiAccentKey.self] = newValue }
    }
}

extension View {
    /// この配下のプライマリー面の色相を差し替える (opt-in)。
    /// 既定に戻すには渡さない (=モノクローム)。ガラス面・意味色には影響しない。
    public func sukashiAccent(_ accent: SukashiAccent) -> some View {
        environment(\.sukashiAccent, accent)
    }
}
