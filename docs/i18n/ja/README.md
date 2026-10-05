# Vidrado

**落ち着いたデスクトップ。すっきりした思考。**

Vidrado は、背面のウインドウをぼかして暗くしながら、アクティブなウインドウを鮮明に保つ macOS ネイティブのメニューバーアプリです。すべての処理は Mac 内で完結し、アカウント、サブスクリプション、追跡、画面録画はありません。

[ダウンロード](https://github.com/tonhadaplaces/vidrado/releases) · [不具合を報告](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [開発に参加](../../../AGENTS.md)

**言語：** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## 動作イメージ

![Vidrado の集中コントロール](../../../docs/screenshots/focus.png)

| アプリごとのルール | 設定 |
| --- | --- |
| ![実際のアプリアイコンをグレースケールで表示するアプリごとのルール](../../../docs/screenshots/apps.png) | ![設定と自動動作](../../../docs/screenshots/preferences.png) |

## 機能

- 背面のウインドウにリアルタイムのぼかし、暗さ、または両方を適用。手軽に使える強度スライダーと「軽め」「バランス」「深く」のレベルを用意しています。
- アプリや Spaces を切り替えても、アクティブなウインドウは鮮明なままです。
- アプリごとのルールで、背面のウインドウを自動的にぼかす、特定のアプリを鮮明に保つ、そのアプリがアクティブな間は集中を一時停止する、といった設定ができます。実際のアプリアイコンをグレースケールで表示します。
- すべてのディスプレイ、またはアクティブなディスプレイだけに集中を適用。整列したウインドウと Split View を維持します。
- フルスクリーン、画面共有、継続的なキャプチャ、ディスプレイのミラーリング中に、必要に応じて一時停止できます。
- カスタマイズ可能なグローバルショートカット、任意のカーソルを振るジェスチャー、ログイン時の起動。
- 保存できるプリセットとローカル設定。
- 13 言語のインターフェース。Vidrado はシステムの優先言語に従い、対応していない言語では英語を使用します。アラビア語とウルドゥー語では右から左のレイアウトを使用します。

## インストール

**macOS 14 以降**が必要です。[Releases](https://github.com/tonhadaplaces/vidrado/releases) から DMG をダウンロードして開き、**Vidrado** を **アプリケーション** にドラッグしてください。

現在の配布版は **アドホック署名**を使用しており、**Apple の公証を受けていません**。このリポジトリからダウンロードした Vidrado アプリを macOS が開けない場合は、そのアプリだけから隔離属性を削除してください。

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

その後、Vidrado をもう一度開いてください。このコマンドはアプリを公証するものではなく、システム全体の Gatekeeper 設定も変更しません。必要に応じてローカルでビルドすることもできます。自動リリースの DMG は **Apple silicon と Intel** に対応しています。

## 使い方

メニューバーの重なったウインドウのアイコンをクリックすると、集中コントロールが開きます。**⌥⌘B** でどこからでも集中のオンとオフを切り替えられます。メニューバーのアイコンを右クリックするか、Option キーを押しながらクリックしても切り替えられます。

スライダーのボタン、または **⌘,** で設定を開きます。**一部のアプリを鮮明に保つ** でアプリを選択してください。追加のエフェクトスライダー、プリセット、カーソルのジェスチャーは **その他のオプション** にあります。**⌘W** で設定ウインドウを閉じても、Vidrado はメニューバーで動作を続けます。**⌘Q** でアプリを終了します。

## ビルドとテスト

Swift 5.9 以降を備えた Xcode または Command Line Tools を使用してください。

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` は `dist/Vidrado.app` をビルドして署名します。`package.sh` は `dist/Vidrado.dmg` とその SHA-256 チェックサムを生成します。既定では、その Mac のアーキテクチャ向けにビルドします。Apple silicon と Intel の両方に対応するビルドには `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` を使用してください。

`swift test` はコアの XCTest テストを実行します。完全なテストスクリプトでは、debug と release の両構成でネイティブチェックも実行します。これらのチェックには、ロックされていないグラフィカルセッション、前面にある通常のウインドウ、停止した状態の Vidrado が必要です。GitHub CI はコアテストを実行し、アプリのビルドを検証します。グラフィカルなチェックはローカルで実行します。

開発に参加する前に、[リポジトリのガイドライン](../../../AGENTS.md)と[検証に関する注意事項](../../../TESTING.md)を読んでください。プルリクエストを使用してください。`main` には、少なくとも 1 件の承認、CI の成功、レビューの会話がすべて解決済みであることが必要です。

## 自動リリース

レビュー済みの変更を `main` にマージした後、`Resources/Info.plist` の `CFBundleShortVersionString` と `CFBundleVersion` を新しいバージョンに更新し、対応するタグをプッシュしてください。

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

`1.0.0` はリリースするバージョンに置き換えてください。GitHub Actions はコードをテストし、ユニバーサルアプリをビルドし、署名済みバンドルと DMG を検証して、DMG とその SHA-256 チェックサムを公開します。ワークフローは、タグが `main` 上にあり、アプリのバージョンと一致することを確認します。有料の Apple Developer アカウントの認証情報は不要です。リリースには、上記のアドホック署名の制約が引き続き適用されます。

## プライバシーと技術的な制約

Vidrado はウインドウのメタデータを読み取り、操作を受け付けないオーバーレイをアクティブなウインドウの下に配置します。macOS のコンポジタが背面のコンテンツにリアルタイムでエフェクトを適用します。アプリはドキュメントを読み取らず、画面のフレームをキャプチャせず、ネットワーク経由でデータを送信しません。また、アクセシビリティ権限も必要ありません。

ぼかし、クリッピング、共有の検出、Spaces のメタデータには、実行時に解決される非公開の SkyLight 関数を使用します。macOS のアップデートによって利用可否が変わる可能性があり、この実装は Mac App Store には適していません。タイル配置されたウインドウの検出には幾何学的な情報を使用します。エフェクトは視覚的なものであり、録画内の機密コンテンツを隠す手段ではありません。

## ライセンスとクレジット

[GNU AGPL-3.0](../../../LICENSE)。Swift、SwiftUI、AppKit で開発されており、実行時の外部依存関係はありません。Inter は [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt) の下で配布されています。Lucide のデザインアイコンには ISC ライセンスが適用されます。[サードパーティに関する通知](../../../THIRD_PARTY_NOTICES.md)を参照してください。

[Defocus](https://defocus.me/) に着想を得ています。Vidrado は独立した実装であり、Defocus のソースコードを使用していません。インターフェースのソースファイルは [`design.pen`](../../../design.pen) としてリポジトリに含まれています。
