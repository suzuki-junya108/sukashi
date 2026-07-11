import SwiftUI

// MARK: - インライン通知 (.sk-notice)
//
// トーストと対になる「置きっぱなしにする」持続通知。面は無彩ガラスのまま、
// 意味色は左端 3px バーとアイコンにだけ乗せる (面には塗らない)。
// 既定は info (無彩)。amber は持たず、注意も danger に集約する (憲法)。

public struct SukashiNotice<Content: View>: View {
    public enum Kind { case info, ok, danger }

    private let kind: Kind
    private let systemImage: String?
    private let content: Content

    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast

    public init(_ kind: Kind = .info,
                systemImage: String? = nil,
                @ViewBuilder content: () -> Content) {
        self.kind = kind
        self.systemImage = systemImage
        self.content = content()
    }

    private var accentColor: Color {
        switch kind {
        case .info: return Sukashi.ink(2, scheme, contrast)
        case .ok: return Sukashi.ok(scheme)
        case .danger: return Sukashi.danger(scheme)
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Sukashi.Space.s2) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
            content
                .font(Sukashi.font(.sub))
                .foregroundStyle(Sukashi.ink(1, scheme, contrast))
        }
        .padding(.horizontal, Sukashi.Space.s4)
        .padding(.vertical, Sukashi.Space.s3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            Rectangle().fill(accentColor).frame(width: 3)  // 左端バー (面ではなく線)
        }
        .sukashiGlass(radius: Sukashi.Radius.m)
    }
}

// MARK: - ステッパー (.sk-steps)
//
// ウィザード進行。点・線・数字だけで語る。現在ステップの accent 円は badge と同枠
// (強調は透けさせない)。済み=薄フィル / 現在=accent / 未達=無彩フィル。

public struct SukashiSteps: View {
    private let titles: [String]
    private let current: Int   // 0 始まり

    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.sukashiAccent) private var accent

    public init(titles: [String], current: Int) {
        self.titles = titles
        self.current = current
    }

    public var body: some View {
        HStack(spacing: Sukashi.Space.s2) {
            ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                if index > 0 {
                    Rectangle()
                        .fill(Sukashi.hairline(scheme, contrast))
                        .frame(height: 1.5)
                        .frame(minWidth: 16)
                }
                step(index: index, title: title)
            }
        }
    }

    @ViewBuilder
    private func step(index: Int, title: String) -> some View {
        let state = index < current ? State.done : (index == current ? .current : .upcoming)
        HStack(spacing: Sukashi.Space.s2) {
            dot(index: index, state: state)
            Text(title)
                .font(Sukashi.font(.foot).weight(.semibold))
                .foregroundStyle(color(for: state))
        }
    }

    @ViewBuilder
    private func dot(index: Int, state: State) -> some View {
        ZStack {
            Circle().frame(width: 26, height: 26)
                .foregroundStyle(fill(for: state))
                .overlay {
                    if state == .upcoming {
                        Circle().strokeBorder(Sukashi.hairline(scheme, contrast), lineWidth: 1)
                    }
                }
            if state == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Sukashi.ink(2, scheme, contrast))
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(state == .current ? accent.on(scheme) : Sukashi.ink(2, scheme, contrast))
            }
        }
    }

    private enum State { case done, current, upcoming }

    private func color(for state: State) -> Color {
        switch state {
        case .current: return Sukashi.ink(1, scheme, contrast)
        case .done: return Sukashi.ink(2, scheme, contrast)
        case .upcoming: return Sukashi.ink(3, scheme, contrast)
        }
    }

    private func fill(for state: State) -> Color {
        switch state {
        case .current: return accent.color(scheme)
        case .done: return Sukashi.fill(2, scheme)
        case .upcoming: return Sukashi.fill(1, scheme)
        }
    }
}
