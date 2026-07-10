# sukashi(透かし)

Liquid Glass 系の材質を、Web サービスで汎用に使える形へ翻訳したモノクローム・デザインシステム。名称は透かし彫りから。依存ゼロ・単一 CSS ファイルで動く。

- **透明であることを名に持つ** — ガラスは白背景の上で、エッジと影だけで層を語る
- **グラデーション不使用** — 材質は `backdrop-filter: blur() saturate()` と実線ヘアライン2本のみ
- **透明度は単一変数 `--gi` で全連動** — 0(clear)〜1(tinted)を 1 行で切替

現行版: **v2.1 フルセット**(v2.0 に憲法を保ったままダークモードとカテゴリ識別色を追加)

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

## コンポーネント(v2.0)

- **操作**: `.sk-btn`(--primary / --quiet / :disabled)、`.sk-iconbtn`、`.sk-seg`、`.sk-tabbar`(セーフエリア対応)
- **フォーム**: `.sk-input`、`.sk-select`、`.sk-textarea`、`.sk-switch`、`.sk-check`、`.sk-radio`、`.sk-range`
- **表示**: `.sk-card`、`.sk-toolbar`(+ `.is-scrolled`)、`.sk-row`、`.sk-table`、`.sk-chip`、`.sk-badge`、`.sk-avatar`、`.sk-divider`
- **フィードバック**: `.sk-progress`、`.sk-spinner`、`.sk-skeleton`(脈動)、`.sk-empty`、`.sk-toast`
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

## sukashi icons(オリジナル 53種)

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

## ファイル

| ファイル | 内容 |
|---|---|
| `sukashi.css` | トークン + 材質 + 全コンポーネント(依存なし・単一ファイル) |
| `sukashi-icons.svg` | アイコンスプライト(53種) |
| `sukashi-showcase.html` | 全部材 + アイコン一覧のリビングスタイルガイド(intensity 連動、アイコン名タップコピー) |
| `DESIGN_SYSTEM.md` | 設計思想と運用ルールの全文 |

`sukashi-showcase.html` をブラウザで開くと、全コンポーネントとアイコンを intensity スライダー連動で確認できる。

## 運用ルール

- **ガラスはクロームに使う。** ツールバー・タブ・フローティング操作が主用途。長文・表・フォームの本体は不透明面(ホスト側)に置く。
- **スクロールエッジ。** コンテンツがバー下を通る状態で `.is-scrolled` を付与すると不透明側に寄る。IntersectionObserver での付与を推奨。
- **アクセントは非面が原則。** primary ボタンと accent チップ以外の面に黒を塗らない。面に塗り始めるとガラスの透明性が死ぬ。

詳細は [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) を参照。
