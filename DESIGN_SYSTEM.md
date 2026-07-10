# sukashi(透かし)デザインシステム v2.2 — フルセット

Liquid Glass 系の材質を、Web サービスで汎用に使える形へ翻訳したデザインシステム。名称は透かし彫りから。CLI ツール群と同じ「〜ai」ではないが、透明であることをそのまま名に持つ。

## 基本姿勢

下地は**白(#FFFFFF)が既定**。ガラスは白の上でエッジと影だけで層を語り、黒プライマリーとの組み合わせでモノクロームの計器盤になる。白既定に伴い、外周ダークエッジの下限を 0.13 に引き上げて白 on 白の輪郭を保証している。

v2.1 で**暗下地版を `.sk-dark` として opt-in で追加**した(§ダークモード)。既定は白のままなので後方互換。憲法(モノクローム・グラデ無し・ガラスはクローム)は暗下地でもそのまま成立する — トークンを反転させるだけで材質定義 `.sk-glass` は一切変えていない。

v2.2 で**実アプリ由来の部材**(インライン通知・破壊的操作ボタン・フォーム解剖学・メニュー・サイドナビ・ステッパー・コード表示・タイポユーティリティ)と**コントラスト強化対応**を追加した(§v2.2 部材)。実アプリ(Sengu: Electron 製 Mac アプリ)への適用で判明した不足を汎用化して還元したもの。憲法の変更はなく、不透明例外に `.sk-btn--danger` を1つ加えたのみ。

## 制約(このシステムの憲法)

1. **グラデーション不使用。** 装飾にも材質にも使わない。ガラスの質感は `backdrop-filter: blur() saturate()` と実線ヘアライン2本(外周 0.5px ダークエッジ+上辺 1px スペキュラ)のみで構成する。iOS 27 が加えた「暗いエッジ+明るいスペキュラ」を実線で再現したもの。
2. **システムは背景を持たない。** 全部材は透明で、ホスト側の白背景の上に置く。半透明である意義は、画像・地図・スクロールするコンテンツがバー下を通過する瞬間に生まれる。
3. **透明度は単一変数 `--gi` で全連動。** 0(clear)〜1(tinted)。不透明度・blur 量・彩度・エッジ強度がすべて `--gi` から calc() で導出される。iOS 27 の intensity スライダーの思想を CSS アーキテクチャに落としたもの。

## トークン構造

```
--gi(マスター)
 ├─ --sk-alpha   0.10〜0.75   ガラス不透明度
 ├─ --sk-blur    8〜30px      ぼかし量
 ├─ --sk-sat     1.9〜1.4     彩度(clearほど上げて下地を鮮やかに透かす)
 ├─ --sk-edge-dark / --sk-edge-spec   エッジ強度
 └─ --sk-shadow  浮きの影
```

用途別の推奨 `--gi`:メディア系ヒーロー 0.2〜0.4 / 一般 UI 0.5〜0.6 / データ密度の高い管理画面 0.75〜1.0。ページ単位・ユーザー設定単位で 1 行で切替できる。

## 材質は 1 クラス

`.sk-glass` が唯一のガラス定義。全コンポーネント(`.sk-toolbar` `.sk-card` `.sk-btn` `.sk-seg` `.sk-input` `.sk-chip`)は形状だけを持ち、材質は `.sk-glass` の合成で与える。材質の調整が全部材に波及する構造を守ること。

例外は `.sk-btn--primary` と `.sk-btn--danger`(v2.2)。主操作と破壊的な確定操作は透けさせない(不透明面)。Apple の実アプリでも確定系アクションはガラスにしない。

## 運用ルール

- **ガラスはクロームに使う。** ツールバー・タブ・フローティング操作が主用途。長文・表・フォームの本体は不透明面(ホスト側)に置く。
- **スクロールエッジ。** コンテンツがバー下を通る状態で `.is-scrolled` を付与すると不透明側に寄る(iOS 27 の uniform toolbar 相当)。IntersectionObserver での付与を推奨。
- **同心円半径。** 入れ子の角丸は 外周R = 内周R + パディング。トークンは 12 / 18 / 26 / pill。
- **プライマリーは黒(`--sk-accent: #111418`)。** 有彩色を持たない完全モノクローム系。インタラクティブ要素は色相ではなく形(黒塗りピル・塗りチップ)で区別する。
- **アクセントは非面が原則。** primary ボタンと accent チップ以外の面に黒を塗らない。面に塗り始めるとガラスの透明性が死ぬ。有彩色は `--sk-danger` / `--sk-ok` の意味色のみで、状態表示に限定する。
- **警告(注意・要確認)は danger に集約する(v2.2 で明文化)。** 第3の意味色 amber は持たない。「危険」と「注意」を色相で分けるほどの情報量はモノクローム計器盤には不要で、迷ったら赤に倒す。強弱は色ではなく文言と配置で付ける。
- **数値は `.sk-mono`**(tabular-nums)。

## アクセシビリティ

- `prefers-reduced-transparency: reduce` で `--gi` を 1 に固定し、backdrop-filter を切って 96% 不透明にフォールバック。
- `@supports` で backdrop-filter 非対応ブラウザにも同様のフォールバック。
- `prefers-reduced-motion` で全モーション停止。
- `prefers-contrast: more`(v2.2)で ink の中間段(`--sk-ink-2/3`)・ヘアライン・外周エッジを引き上げる。ライト/ダーク両対応。
- フォームエラー(v2.2)は視覚(`.is-invalid`)と支援技術(`aria-invalid="true"` + エラー文へ `aria-describedby`)を必ず併用する。
- ガラス上の文字コントラストは下地依存で保証できないため、`--gi < 0.5` の運用ではガラス上に本文級の長文を置かないこと(見出し・数値・ラベルまで)。
- 識別色(`--sk-cat-*`)はアイコン・ドット・リードバー・短いラベルに限定し、**本文級の長文には使わない**。暗下地では沈むため `.sk-dark` で一段明るい版へ自動差し替えしている。

## ダークモード(v2.1)

`.sk-dark` を要素かその祖先に付けると、その配下だけ暗下地版になる。既定(付けない状態)は白のままなので後方互換。

- **材質は不変。** `.sk-glass` の定義は変えず、`.sk-dark` が参照トークン(`--sk-tint` / `--sk-ink-rgb` / エッジ / 影 / accent)を反転するだけ。`--sk-hairline` / `--sk-fill-*` は `--sk-ink-rgb` 由来なので自動追従する。
- **プライマリーはモノクロームのまま反転。** 黒(`#111418`)→ 近白(`#F5F6F8`)。面上の図(スイッチのつまみ・チェック)は `--sk-on-accent` を参照するため反転時も消えない。
- **外周リムは反転。** 白下地では黒の外周エッジ、暗下地では微光(白低アルファ)の外周リムで輪郭を出す。
- **OS 追従は opt-in。** 既定でシステムのダーク設定に従わせたい場合のみ `.sk-auto` を付与する(`@media (prefers-color-scheme: dark)`)。無指定なら白固定を維持。
- 意味色(`--sk-danger` / `--sk-ok`)は暗背景で沈まないよう一段明るい値へ差し替える。

```html
<body class="sk sk-dark">        <!-- 配下すべてが暗下地版 -->
<div class="host sk sk-auto">     <!-- OS のダーク設定に追従 -->
```

## カテゴリ識別色(v2.1)

種別・タグ・チャンネルなど**N 分類を区別するための識別専用色**。状態色(danger/ok)とは別枠で、憲法「面に色を塗らない」を破らないよう**適用先を glyph / ドット / リードバーに限定**する。

- トークンは `--sk-cat-1`〜`--sk-cat-8`(8色)。暗下地では `.sk-dark` / `.sk-auto` で明るい版へ差し替え。
- **色の入口は `.sk-cat-1`〜`.sk-cat-8` のみ**で、これは `color` を差し替えるだけ。`currentColor` 経由でアイコン(stroke)・`.sk-dot`・`.sk-catbar`・短ラベルへ伝わる。
- **背景色クラスは意図的に提供しない。** 面を塗る手段が無いこと自体で憲法を担保する。カード/行/チップの面は無彩のまま、色は「点(`.sk-dot`)」と「3px の縦線(`.sk-catbar`)」とアイコンにだけ乗る。
- 一覧での使い方: 行の左端に `.sk-catbar`、種別アイコンに `.sk-cat-N`、チップ内に `.sk-dot`。面はガラス/無彩を維持する。

```html
<div class="sk-row">
  <span class="sk-catbar sk-cat-6"></span>            <!-- 左端の識別バー -->
  <svg class="sk-icon sk-cat-6"><use href="#sk-i-heart"/></svg>
  <div class="sk-row__main">Design</div>
  <span class="sk-glass sk-chip"><span class="sk-dot sk-cat-6"></span>tag</span>
</div>
```

## コンポーネント一覧(v2.2)

**操作**: `.sk-btn`(--primary / --danger / --quiet / :disabled)、`.sk-iconbtn`、`.sk-seg`(セグメンテッド)、`.sk-tabbar`(下部固定・セーフエリア対応)、`.sk-menu`(ドロップダウン/コンテキストメニュー)、`.sk-sidenav`(デスクトップ縦ナビ)
**フォーム**: `.sk-field`(ラベル+ヘルプ+エラーの解剖学)、`.sk-input`(+ `.is-invalid` / :disabled / :read-only)、`.sk-select`、`.sk-textarea`、`.sk-switch`(51×31 iOS寸法)、`.sk-check`、`.sk-radio`、`.sk-range`
**表示**: `.sk-card`、`.sk-toolbar`(+ `.is-scrolled`)、`.sk-row`、`.sk-table`、`.sk-chip`(--accent は黒塗り)、`.sk-badge`(--danger)、`.sk-avatar`、`.sk-divider`、`.sk-dot` / `.sk-catbar`(識別色マーク)、`.sk-code` / `.sk-code--l` / `.sk-kbd`(コード・確認コード・ショートカット)、`.sk-t-large`〜`.sk-t-caption`(タイポユーティリティ)
**テーマ**: `.sk-dark`(暗下地・opt-in)、`.sk-auto`(OS 追従)、識別色 `.sk-cat-1`〜`.sk-cat-8`
**フィードバック**: `.sk-notice`(インライン通知: 既定 info / --ok / --danger)、`.sk-progress`、`.sk-spinner`、`.sk-skeleton`(グラデ禁止のため shimmer ではなく脈動)、`.sk-empty`、`.sk-toast`、`.sk-steps`(ステッパー)
**オーバーレイ**: `.sk-scrim` + `.sk-modal` / `.sk-sheet`(いずれも `.is-open` で開閉、z-index はトークン管理)

材質規律は全部材共通:形状クラス+`.sk-glass` の合成。ガラス化しない例外は `.sk-btn--primary`、`.sk-btn--danger`、`.sk-chip--accent`、`.sk-badge` の4つ(確定・強調は透けさせない)。

## v2.2 部材の設計判断

- **`.sk-notice`**: トースト(一時)と対になる持続通知。面は無彩ガラスのまま、意味色は左端 3px バー(`.sk-catbar` と同じ「線」の流儀)とアイコンにだけ乗せる。既定は無彩(info)。
- **`.sk-btn--danger`**: 「確定系は透けさせない」の理屈を破壊的操作に延長した不透明例外。danger の面塗りはこのボタンと `.sk-badge--danger` に限る。
- **`.sk-field`**: 部品(input)ではなく解剖学(ラベル/ヘルプ/エラーの距離と階層)を規定する。エラーは `.is-invalid` と `aria-invalid` の両対応。
- **`.sk-menu` / `.sk-sidenav`**: 選択・ホバーは `--sk-fill-1` と「白寄せ+スペキュラ」で表現し、seg / tabbar と同じ公式を使う。内側角丸は同心円(外周R−パディング)。
- **`.sk-steps`**: 点・線・数字だけで進行を語る。現在ステップの accent 円は badge と同枠の強調面。
- **タイポユーティリティ**: サイズ・太さのみで色を持たない(色は ink 3段の責務)。

## オーバーレイ挙動規約(v2.2)

CSS が提供するのは見た目と開閉トランジションのみ。以下はホスト側の責務として実装する。

- **フォーカス**: 開いたら内部の最初のフォーカス可能要素へ移し、閉じたら呼び出し元へ戻す。モーダル表示中はフォーカスを内部に閉じ込める(可能なら `<dialog>` 要素 + `showModal()` を使うと無償で得られる)
- **キーボード**: Esc で閉じる。`.sk-menu` は矢印キーで項目移動(`role="menu"` / `menuitem`)
- **外側クリック**: `.sk-scrim` クリックで閉じる(showcase の実装例参照)。`.sk-menu` は document への mousedown で閉じる
- **スクロール**: モーダル表示中は背面のスクロールを止める(`overflow: hidden`)

## `.is-scrolled` の自動付与(コピペ用)

```js
// 監視対象(コンテンツ先頭に置いた 1px の番兵)がバー下に隠れたら .is-scrolled を付与
const sentinel = document.querySelector('#scroll-sentinel');
const bar = document.querySelector('.sk-toolbar');
new IntersectionObserver(([e]) => {
  bar.classList.toggle('is-scrolled', !e.isIntersecting);
}).observe(sentinel);
```

## sukashi icons(オリジナルアイコン 59種)

- 24×24 グリッド、stroke 1.5、round cap/join、`currentColor`、fill なし(塗りは more/warning/info の点のみ)
- SVG スプライト(`sukashi-icons.svg`)を HTML 先頭にインライン展開し、`<svg class="sk-icon"><use href="#sk-i-search"/></svg>` で使用
- サイズは `.sk-icon--s`(18)/ 標準(24)/ `.sk-icon--l`(28)
- カテゴリ: ナビゲーション(16)/ 基本オブジェクト(16: v2.2 で globe, shield, key, inbox 追加)/ コミュニケーション(5)/ 編集・操作(9: v2.2 で restore, sparkle 追加)/ メディア・ファイル(7)/ コマース(5: cart, tag, package, truck, barcode)/ ステータス(2)
- v2.2 追加分は Web サービス運用系(サイト=globe / 保護=shield / 認証=key / 受信箱=inbox / 復元=restore / AI=sparkle)
- 拡張規約: 新アイコンも 24 グリッド・stroke 1.5・端点は 0.5px 単位に置く。曲線は円弧優先、装飾ディテールは1アイコン1つまで

## ファイル

- `sukashi.css` — トークン+材質+全コンポーネント(依存なし・単一ファイル)
- `sukashi-icons.svg` — アイコンスプライト
- `showcase.html` — 全部材+アイコン一覧のリビングスタイルガイド(intensity 連動、アイコン名タップコピー)

## SwiftUI 版(ネイティブ転写)

Web(CSS)と同じ憲法・トークンを SwiftUI へ転写した Swift Package を `Sources/Sukashi/` に同梱する(`import Sukashi`)。macOS 14 / iOS 17 以上、AppKit/UIKit 非依存。

- 材質 `.sk-glass` → `.sukashiGlass(radius:)`。`.regularMaterial`(blur 近似・ライト/ダーク自動)に、憲法どおり実線ヘアライン2本(外周エッジ + 上辺スペキュラ)を overlay で合成し、影で浮きを作る。グラデーションは使わない。
- 識別色 → `SukashiDot` / `SukashiCatBar` / `.sukashiCategory(_:)`。CSS 版と同じく**面には塗らず、点・線・glyph にだけ**色を乗せる(背景色 API は提供しない)。
- ライト/ダークは `@Environment(\.colorScheme)` 追従。プライマリーは黒↔近白へモノクローム反転し、面上の図は `Sukashi.onAccent(_:)` で消えないようにする。
- CSS 版の `--gi`(連続 intensity)は SwiftUI では Material の段階に離散化される。それ以外はトークン値まで一致させている。

## 今後の検討

ツールチップ、日付ピッカー、ページネーション、パンくず、Tailwind preset / React コンポーネントへの転写、SwiftUI 版のコンポーネント拡充(seg / tabbar / chip / v2.2 部材)、アイコンの追加(ラジオ・園芸・調理など個人アプリ向けセット)。

> v2.1 で対応済み: ダークモード(`.sk-dark`)の再導入、カテゴリ識別色(`.sk-cat-*`)、SwiftUI(ネイティブ)への転写。
> v2.2 で対応済み: インライン通知、破壊的操作ボタン、フォーム解剖学(ラベル/ヘルプ/エラー/無効)、ドロップダウンメニュー(ポップオーバー)、サイドナビ、ステッパー、コード/kbd 表示、タイポユーティリティ、`prefers-contrast` 対応、`.is-scrolled` ミニ JS(スニペット掲載)、オーバーレイ挙動規約、警告色ポリシーの明文化、運用系アイコン6種。
