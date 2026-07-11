# CLAUDE.md — sukashi デザインシステム

このリポジトリで作業する Claude Code への指示書。作業前に必ず読むこと。

## このリポジトリは何か

Liquid Glass 系のモノクローム・デザインシステム「sukashi(透かし)」。
2つの実装を**同居**させており、両者は**同一の憲法・トークン・見た目**を保つ。

| 実装 | 位置 | 役割 |
|---|---|---|
| **Web(CSS)** | `sukashi.css` / `sukashi-icons.svg` / `sukashi-showcase.html` | **リファレンス(正)**。設計はここで決まる |
| **SwiftUI** | `Package.swift` / `Sources/Sukashi/` | CSS の**ネイティブ転写**。CSS に追従する |
| 設計文書 | `DESIGN_SYSTEM.md` / `README.md` | 思想と運用ルール |

## 憲法(このシステムの不変条件 — 破らない)

1. **グラデーション不使用。** 材質は blur / saturate と実線ヘアライン2本(外周エッジ + 上辺スペキュラ)のみ。
2. **システムは背景を持たない。** 部材は透明で、ホスト側の面の上に置く。
3. **透明度は単一変数 `--gi` で全連動**(CSS)。SwiftUI は Material の段階で近似する。
4. **ガラスはクロームに使う。** 長文・表・フォーム本体は不透明面に置く。
5. **プライマリーはモノクローム(黒 ↔ ダークで近白)。** 既定で有彩色を面に塗らない。ブランド色は opt-in のみ。
6. **意味色は danger / ok の2つだけ。** amber(第3の警告色)は持たない。注意も danger に集約する。
7. **識別色は面に塗らない。** カテゴリ色は glyph / ドット / リードバーにだけ乗せる(背景色の入口を作らない)。

## 最重要ルール: SwiftUI は CSS に常に追従する

**CSS(リファレンス)を拡張したら、同じ変更で必ず SwiftUI 版(`Sources/Sukashi/`)も更新して parity を保つこと。** 
SwiftUI をリファレンスから遅れさせない。これは「あれば嬉しい」ではなく**必須要件**。

### 追従の手順(CSS を変更したとき)

1. `sukashi.css` に部材/トークン/モードを追加・変更する。
2. **同じコミット(または直後の連続作業)で** `Sources/Sukashi/` に等価物を実装する。
   - トークン(色・寸法・タイポ) → `Sukashi.swift`(必要なら値を CSS と一致させる)
   - プライマリー色切替 → `SukashiAccent.swift`
   - ガラス材質 / 識別色マーク → `SukashiGlass.swift`
   - ボタン類 → `SukashiControls.swift`
   - 通知 / ステッパー等フィードバック → `SukashiFeedback.swift`
   - フォーム解剖学 → `SukashiForm.swift`
   - コード / ショートカット表示 → `SukashiText.swift`
   - メニュー / サイドナビ → `SukashiNav.swift`
3. `DESIGN_SYSTEM.md` / `README.md` の該当箇所を両実装ぶん更新する。
4. **検証**: `swift build` を通す。見た目は `sukashi-showcase.html`(ブラウザ)と、SwiftUI は実ウィンドウ描画 + screencapture で両モード(light/dark)を確認する。
5. CSS 側の値(色 hex・寸法)を変えたら、SwiftUI 側の対応する定数も同値へ揃える。

### SwiftUI で表現できない場合

CSS の一部(連続 `--gi`、`backdrop-filter` の厳密な blur 量など)は SwiftUI で完全一致しない。
その場合は**最も近い静的近似**を採り(例: `.regularMaterial` + 実線ヘアライン2本)、差異を該当ファイルのコメントと `DESIGN_SYSTEM.md` に明記する。「未対応のまま黙って放置」はしない。

## ビルド / 検証

```
swift build                 # SwiftUI パッケージのコンパイル確認
open sukashi-showcase.html  # Web の目視(intensity/ダーク/識別色トグル付き)
```

SwiftUI の見た目確認は、`Sources/Sukashi/*.swift` の `#Preview`(Xcode)か、
パッケージに path 依存する小さな実行ファイルで `NSHostingView` を描画し `screencapture` する。

## コミット規約

- Conventional Commits(`feat:` / `fix:` / `docs:` 等)。日本語可。
- コミットメッセージ・PR に Claude / Anthropic への言及や生成元表記を**入れない**。
- `main` へ直接コミットして push してよい(単独リポジトリ)。破壊的操作の前は確認する。
