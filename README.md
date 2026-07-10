# sukashi(透かし)

Liquid Glass 系の材質を、Web サービスで汎用に使える形へ翻訳したモノクローム・デザインシステム。名称は透かし彫りから。依存ゼロ・単一 CSS ファイルで動く。

- **透明であることを名に持つ** — ガラスは白背景の上で、エッジと影だけで層を語る
- **グラデーション不使用** — 材質は `backdrop-filter: blur() saturate()` と実線ヘアライン2本のみ
- **透明度は単一変数 `--gi` で全連動** — 0(clear)〜1(tinted)を 1 行で切替

現行版: **v2.2 フルセット**(v2.1 のダークモード・識別色に加え、実アプリ由来の部材 — 通知 / 破壊的操作ボタン / フォーム解剖学 / メニュー / サイドナビ / ステッパー / コード表示 — とコントラスト強化を追加)

**ライブデモ(常に最新): https://suzuki-junya108.github.io/sukashi/** — main への push ごとに自動更新される。

## クイックスタート

CSS を読み込み、アイコンスプライトを HTML 先頭にインライン展開する。

```html
<link rel="stylesheet" href="sukashi.css">

<!-- <body> 直後にアイコンスプライトをインライン展開 -->
<!-- sukashi-icons.svg の中身をそのまま貼るか、fetch して差し込む -->

<div class="sk-toolbar sk-glass">
  <button class="sk-btn sk-btn--primary">保存</button>
  <svg class="sk-icon"><use href="#sk-i-search"/></svg>
</div>
```

透明度の切替はページ単位・ユーザー設定単位で 1 行:

```css
:root { --gi: 0.75; } /* データ密度の高い管理画面向け */
```

用途別の推奨 `--gi`: メディア系ヒーロー `0.2〜0.4` / 一般 UI `0.5〜0.6` / 管理画面 `0.75〜1.0`

## 3つの制約(このシステムの憲法)

1. **グラデーション不使用。** ガラスの質感は blur / saturate と実線ヘアライン2本(外周 0.5px ダークエッジ + 上辺 1px スペキュラ)のみで構成する。
2. **システムは背景を持たない。** 全部材は透明で、ホスト側の白背景の上に置く。半透明の意義は、画像・地図・スクロールするコンテンツがバー下を通過する瞬間に生まれる。
3. **透明度は単一変数 `--gi` で全連動。** 不透明度・blur 量・彩度・エッジ強度・影がすべて `--gi` から `calc()` で導出される。

## 材質は 1 クラス

`.sk-glass` が唯一のガラス定義。全コンポーネントは形状だけを持ち、材質は `.sk-glass` の合成で与える。材質の調整が全部材に波及する構造を守ること。

ガラス化しない例外は 3 つ(確定・強調は透けさせない): `.sk-btn--primary` / `.sk-chip--accent` / `.sk-badge`。

## トークン構造

```
--gi(マスター)
 ├─ --sk-alpha   0.10〜0.75   ガラス不透明度
 ├─ --sk-blur    8〜30px      ぼかし量
 ├─ --sk-sat     1.9〜1.4     彩度(clearほど上げて下地を鮮やかに透かす)
 ├─ --sk-edge-dark / --sk-edge-spec   エッジ強度
 └─ --sk-shadow  浮きの影
```

- **プライマリーは黒(`--sk-accent: #111418`)。** 有彩色を持たない完全モノクローム系。インタラクティブ要素は色相ではなく形で区別する。
- 有彩色は `--sk-danger` / `--sk-ok` の意味色のみ、状態表示に限定。
- 同心円半径: 外周R = 内周R + パディング(トークンは 12 / 18 / 26 / pill)。
- 数値は `.sk-mono`(tabular-nums)。

## コンポーネント(v2.2)

- **操作**: `.sk-btn`(--primary / --danger / --quiet / :disabled)、`.sk-iconbtn`、`.sk-seg`、`.sk-tabbar`(セーフエリア対応)、`.sk-menu`(ドロップダウン)、`.sk-sidenav`(デスクトップ縦ナビ)
- **フォーム**: `.sk-field`(ラベル+ヘルプ+エラー)、`.sk-input`(+ `.is-invalid`)、`.sk-select`、`.sk-textarea`、`.sk-switch`、`.sk-check`、`.sk-radio`、`.sk-range`
- **表示**: `.sk-card`、`.sk-toolbar`(+ `.is-scrolled`)、`.sk-row`、`.sk-table`、`.sk-chip`、`.sk-badge`、`.sk-avatar`、`.sk-divider`、`.sk-code` / `.sk-kbd`、`.sk-t-*`(タイポユーティリティ)
- **フィードバック**: `.sk-notice`(インライン通知)、`.sk-progress`、`.sk-spinner`、`.sk-skeleton`(脈動)、`.sk-empty`、`.sk-toast`、`.sk-steps`(ステッパー)
- **オーバーレイ**: `.sk-scrim` + `.sk-modal` / `.sk-sheet`(`.is-open` で開閉)
- **テーマ(v2.1)**: `.sk-dark`(暗下地・opt-in)、`.sk-auto`(OS 追従)
- **識別色(v2.1)**: `.sk-cat-1`〜`.sk-cat-8` + `.sk-dot` / `.sk-catbar`

## ダークモード / 識別色(v2.1)

白既定は不変。暗下地は `.sk-dark` を要素かその祖先に付けて opt-in する(OS 追従は `.sk-auto`)。材質 `.sk-glass` は変えず、トークンを反転するだけ。プライマリーは黒 → 近白へモノクロームのまま反転する。

```html
<body class="sk sk-dark"> … </body>   <!-- 配下すべて暗下地 -->
```

カテゴリ識別色は状態色とは別枠の識別専用色。憲法「面に色を塗らない」を守るため、**適用先は glyph・ドット(`.sk-dot`)・3px リードバー(`.sk-catbar`)に限定**し、背景色クラスは提供しない。

```html
<div class="sk-row">
  <span class="sk-catbar sk-cat-6"></span>
  <svg class="sk-icon sk-cat-6"><use href="#sk-i-heart"/></svg>
  <div class="sk-row__main">Design</div>
</div>
```

## sukashi icons(オリジナル 59種)

24×24 グリッド、stroke 1.5、round cap/join、`currentColor`、fill なし(塗りは more/warning/info の点のみ)。

```html
<svg class="sk-icon"><use href="#sk-i-search"/></svg>
```

サイズは `.sk-icon--s`(18)/ 標準(24)/ `.sk-icon--l`(28)。カテゴリはナビゲーション / 基本オブジェクト / コミュニケーション / 編集・操作 / メディア・ファイル / コマース / ステータス。

## アクセシビリティ

- `prefers-reduced-transparency: reduce` で `--gi` を 1 に固定し、backdrop-filter を切って 96% 不透明にフォールバック。
- `@supports` で backdrop-filter 非対応ブラウザにも同様のフォールバック。
- `prefers-reduced-motion` で全モーション停止。
- `--gi < 0.5` の運用ではガラス上に本文級の長文を置かない(見出し・数値・ラベルまで)。

## SwiftUI 版(ネイティブ)

Web(CSS)と同じ憲法・トークンを SwiftUI へ転写した Swift Package を同梱している。macOS 14 / iOS 17 以上。真の Liquid Glass(OS 26 の `.glassEffect`)を待たず、`.regularMaterial` + 実線ヘアライン2本で同じ静的近似を再現する。

```swift
// Package.swift
.package(url: "https://github.com/suzuki-junya108/sukashi.git", branch: "main")
// ターゲットの dependencies に .product(name: "Sukashi", package: "sukashi")
```

```swift
import Sukashi

// クロームにガラス材質(外周エッジ + 上辺スペキュラ + 影)
VStack { … }
    .sukashiGlass(radius: Sukashi.Radius.l)

// 識別色は面に塗らず、点・線・glyph にだけ乗せる
HStack {
    SukashiCatBar(6)                       // 3px の縦リードバー
    Image(systemName: "heart").sukashiCategory(6)   // glyph 着色
    Text("Design")
    SukashiDot(6)                          // 8px のドット
}
```

- トークン: `Sukashi.Space` / `Sukashi.Radius` / `Sukashi.accent(_:)` / `Sukashi.category(_:_:)` / `Sukashi.danger(_:)` / `Sukashi.ok(_:)`
- ライト/ダークは `@Environment(\.colorScheme)` 追従(プライマリーは黒↔近白へモノクローム反転)。AppKit/UIKit 非依存。
- `#Preview`(light/dark)同梱。`swift build` で単体ビルド可。

## ファイル

| ファイル | 内容 |
|---|---|
| `sukashi.css` | トークン + 材質 + 全コンポーネント(依存なし・単一ファイル) |
| `sukashi-icons.svg` | アイコンスプライト(59種) |
| `sukashi-showcase.html` | 全部材 + アイコン一覧のリビングスタイルガイド(intensity 連動、アイコン名タップコピー) |
| `Package.swift` / `Sources/Sukashi/` | SwiftUI 版(トークン + `.sukashiGlass()` + `SukashiDot`/`SukashiCatBar`) |
| `DESIGN_SYSTEM.md` | 設計思想と運用ルールの全文 |

`sukashi-showcase.html` をブラウザで開くと、全コンポーネントとアイコンを intensity スライダー連動で確認できる。

## 運用ルール

- **ガラスはクロームに使う。** ツールバー・タブ・フローティング操作が主用途。長文・表・フォームの本体は不透明面(ホスト側)に置く。
- **スクロールエッジ。** コンテンツがバー下を通る状態で `.is-scrolled` を付与すると不透明側に寄る。IntersectionObserver での付与を推奨。
- **アクセントは非面が原則。** primary ボタンと accent チップ以外の面に黒を塗らない。面に塗り始めるとガラスの透明性が死ぬ。

詳細は [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) を参照。
