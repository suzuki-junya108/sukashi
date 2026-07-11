import SwiftUI

// MARK: - フォームの解剖学 (.sk-field)
//
// 部品(入力)ではなく「ラベル / 入力 / ヘルプ・エラーの距離と階層」を規定する。
// エラー時は error 文を出し、入力側には .sukashiInvalid(true) で danger アウトラインを付ける。
// (a11y: 呼び出し側で入力へ適切なラベル紐付けを行うこと。)

public struct SukashiField<Content: View>: View {
    private let label: String
    private let help: String?
    private let error: String?
    private let content: Content

    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast

    public init(_ label: String,
                help: String? = nil,
                error: String? = nil,
                @ViewBuilder content: () -> Content) {
        self.label = label
        self.help = help
        self.error = error
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Sukashi.Space.s1) {
            Text(label)
                .font(Sukashi.font(.foot).weight(.semibold))
                .foregroundStyle(Sukashi.ink(2, scheme, contrast))
            content
            if let error {
                Text(error)
                    .font(Sukashi.font(.foot).weight(.semibold))
                    .foregroundStyle(Sukashi.danger(scheme))
            } else if let help {
                Text(help)
                    .font(Sukashi.font(.foot))
                    .foregroundStyle(Sukashi.ink(3, scheme, contrast))
            }
        }
    }
}

extension View {
    /// 入力を「エラー状態」にする (danger の 1.5px アウトライン)。
    /// CSS の .sk-input.is-invalid 相当。radius は入力の角丸に合わせる。
    public func sukashiInvalid(_ isInvalid: Bool, radius: CGFloat = Sukashi.Radius.m) -> some View {
        modifier(SukashiInvalidModifier(isInvalid: isInvalid, radius: radius))
    }
}

private struct SukashiInvalidModifier: ViewModifier {
    let isInvalid: Bool
    let radius: CGFloat
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.overlay {
            if isInvalid {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Sukashi.danger(scheme), lineWidth: 1.5)
            }
        }
    }
}
