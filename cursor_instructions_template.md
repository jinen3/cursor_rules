# Cursor 開発 共通ルール文書

**役割:** この文書は Cursor が読んで実行する指示書である。**この文書は .mdc ではない。** Markdown（.md）であり、共通リポジトリ（cursor_rules）のルートに置く「マスタ指示文書」である。次の 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）は .cursor/rules/ に置く個別ルールで、本ファイル（cursor_instructions_template.md）はその一覧・使い方・更新手順を一括で示す。人間向けの説明は別ファイル `Cursor開発共通ルール_ユーザー向け説明.md` に記載する。

**リビジョン:** 3  
**更新日:** 2026-03-25

## 目次

- [0. セットアップ（【Cursorがやる】）](#0-セットアッププロジェクト開始時に実行すること)
- [1. cursor/rules の登録（【人がやる】最初の1回）](#1-cursorrules-の登録)
- [2. スクリプト作成 補足（【Cursorがやる】）](#2-スクリプト作成-補足アプリごとに指定がある場合)
- [3. Markdown 全般の共通ルール（全 .md に適用）（【Cursorがやる】）](#3-markdown-文書の共通ルール全-md-に適用)
- [4. README 作成・更新（【Cursorがやる】）](#4-readme-作成更新)
- [5. 教材4種 作成・更新（【Cursorがやる】）](#5-教材4種-作成更新)
- [6. 知見の追記先（【Cursorがやる】）](#6-エラーデバッグ単体テストの知見の追記先)
- [7. 文書・mdc の更新 実施手順（【Cursorがやる】）](#7-文書mdc-の更新-実施手順cursor-が完璧に更新するための手順)
  - [7.1 README](#71-readme-の更新) / [7.2 教材 _project](#72-教材4種_projectmd-の更新) / [7.3 知見の追記](#73-教材4種_commonmd-および-errors-debug-unittest-commonmdc-への知見の追記) / [7.4 .mdc](#74-mdc-の更新) / [7.5 cursor_instructions_template.md](#75-cursor_instructions_templatemd-の更新) / [7.6 サブモジュール](#76-サブモジュールの更新)
- [8. プロジェクト開始時の実行順序（【Cursorがやる】）](#8-プロジェクト開始時の実行順序)
- [9. 修正・機能追加後の実行（【Cursorがやる】）](#9-修正機能追加後の実行)
- [10. .mdc の内容（参照用）（【Cursorがやる】）](#10-mdc-の内容参照用)

---

<a id="0-セットアッププロジェクト開始時に実行すること"></a>
## 0. セットアップ（プロジェクト開始時に実行すること）

**【Cursorがやる】** プロジェクト開始時に、作業PC上で準備する（必要ならターミナルでコマンド実行する）。

以下を実施すること。

- プロジェクトフォルダ直下に仮想環境（.venv）がなければ作成する。
- すべての作業は .venv を有効化した状態で行う。python / pip / pyinstaller は .venv 経由で実行する（Windows: .venv\Scripts\python.exe、Mac/Linux: .venv/bin/python）。
- 起動スクリプト（.vbs / .bat / .sh）を作る場合も .venv 内の Python を優先する。
- システムPython（グローバル環境）には何もインストールしない。誤ってインストールした場合はアンインストールして元に戻し、完了を報告する。

---

<a id="1-cursorrules-の登録"></a>
## 1. cursor/rules の登録

**【人がやる】** このプロジェクトで最初の1回だけ、Cursor の Rules に `.mdc` を登録する（以降は不要）。

**禁止:** 作業対象のプロジェクトフォルダの `.cursor/rules/` に次の 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）をコピー・配置しないこと。コピーすると共通リポジトリ（cursor_rules）でこれらを更新してもプロジェクトに反映されず、バージョン管理ができなくなる。

**実施すること:** 次の 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）は **共通リポジトリ（cursor_rules）の `.cursor/rules/` にのみ存在させる。** 作業対象のプロジェクトでは、cursor_rules をサブモジュールとして取り込み、**サブモジュール内のパス（プロジェクトフォルダ/cursor_rules/.cursor/rules/）を参照して** これら 6 本を登録すること。すべて `alwaysApply: true` で登録する。

### 【最初の1回だけ】Rules登録（重要・短縮版）

このプロジェクトで最初に一度だけ、Cursor の Rules に **サブモジュール内の `.mdc` を登録**する必要がある。**サブモジュールを更新しても、Rules が自動登録されるわけではない**ため、ここを最初にやる。

- 登録する場所：`<プロジェクトルート>/cursor_rules/.cursor/rules/`
- 登録するもの：次の 6 本（`alwaysApply: true`）
  - `venv-only-common.mdc`
  - `errors-debug-unittest-common.mdc`
  - `post-modification-common.mdc`
  - `gui-build-security-common.mdc`
  - `markdown-common.mdc`
  - `update-management-common.mdc`

以降は、日々の作業開始時に `cursor_rules` サブモジュールを更新し（更新したい場合）、必要ならソース管理GUIで差分を commit/push する運用にする（詳細は `cursor_rules_submodule_開発開始手順.md` を参照）。

| ファイル名 | 用途 |
|------------|------|
| venv-only-common.mdc | 仮想環境・システムPython保護 |
| errors-debug-unittest-common.mdc | エラー対応・デバッグ・単体テスト・知見の追記先 |
| post-modification-common.mdc | コード修正後の必須手順（README・教材の更新） |
| gui-build-security-common.mdc | GUI・ビルド・WEBセキュリティ |
| markdown-common.mdc | Markdown 全般の共通ルール（globs: "**/*.md"、目次リンク・アンカー・プレビュー注記含む） |
| update-management-common.mdc | 共通／プロジェクトの更新場所・サブモジュール更新・コピー禁止 |

上記 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）の本文は、本ファイル（cursor_instructions_template.md）の「10. .mdc の内容（参照用）」を参照すること。これにより cursor_instructions_template.md 一枚のインプットで登録・作成まで完結する。

---

<a id="2-スクリプト作成-補足アプリごとに指定がある場合"></a>
## 2. スクリプト作成 補足（アプリごとに指定がある場合）

**【Cursorがやる】** ユーザーの要望に合わせて、実装方針・ライブラリ選定などの補足条件として適用する。

- 環境: 本ファイルのセクション0（セットアップ）および venv-only-common.mdc に従う。
- GUI ライブラリ: 指定がなければ Tkinter / customtkinter / Flet から 1 つ選ぶ。PyQt6 は GPL のため商用・配布では避ける。
- アウトプット形式: アプリに合わせて .txt / .md / .csv 等を指定する。
- WEBアプリの場合: PCとスマホでデータ同期、プライベート利用、gui-build-security-common.mdc のセキュリティ要件に従う。

---

<a id="3-markdown-文書の共通ルール全-md-に適用"></a>
## 3. Markdown 全般の共通ルール（全 .md に適用）

**【Cursorがやる】** README・教材など、見出しが複数ある Markdown を作成/更新するときは必ず従う。

本セクションは Markdown 文書全般の共通ルールである。目次リンクに限らず、すべての .md に共通する書式・ルールを定める。実施内容は markdown-common.mdc（Markdown 全般の共通ルール）と同一とする。

**適用対象:** すべての Markdown 文書（プロジェクトフォルダ直下の readme.md、教材4種（*_common.md / *_project.md）を含む）。見出しが複数ある文書には、以下 1〜3 を適用する。

**実施すること（見出しが複数ある .md に適用）:**

1. 文書冒頭に「## 目次」を置く。目次は `- [表示テキスト](#アンカーID)` の形式でリンクにする。アンカーID は半角英数字とハイフンのみ（例: sec0, sec1-1）。
2. 目次でリンクする各見出しの**直前に** `<a id="アンカーID"></a>` を 1 行で置く。見出しに `{#id}` のみ付けることは禁止。
3. 文書内の「## 目次」セクションの直後に、引用ブロックで「Markdown Preview Enhanced で Ctrl+Alt+M により目次リンクがジャンプする」旨を 1 行入れる。

---

<a id="4-readme-作成更新"></a>
## 4. README 作成・更新

**【Cursorがやる】** コード修正・機能追加後に、README（および配布物内のREADME）を現状に同期して更新する。

作成すること:

- **readme.md**: プロジェクトフォルダ直下に保存。使い方・バックアップ・トラブル対処を記載。目次は本ファイルのセクション3（Markdown 全般の共通ルール）に従う。
- **readme.txt**: readme.md と同一内容を .txt で作成。平易な日本語。目次は「見出し一覧」として記載。
- **デスクトップアプリの場合のみ:** プロジェクトフォルダ直下の readme.md・readme.txt と同一内容の readme.md・readme.txt を **dist フォルダ内**にも配置する。
- **WEBアプリの場合:** dist フォルダは使わないため、**プロジェクトフォルダ直下の readme.md・readme.txt のみ**作成・更新する。

更新のタイミングと対象: コード修正・機能追加後。対象は本ファイルの「7. 文書・mdc の更新 実施手順」の 7.1（README の更新）に従う。

---

<a id="5-教材4種-作成更新"></a>
## 5. 教材4種 作成・更新

**【Cursorがやる】** コード修正後は教材を現状に同期し、チャット終了時は知見を追記する（7.2/7.3）。

教材4種は共通リポジトリ（cursor_rules）のルート配下と、各プロジェクトフォルダの両方に置く。ファイル名で区別する。

| 種類 | 共通リポジトリ（cursor_rules）内のファイル名 | 各プロジェクトフォルダ内のファイル名 |
|------|----------------------------------|----------------------------|
| 5.1 概要と一覧 | textbook_01_overview_common.md | textbook_01_overview_project.md |
| 5.2 詳細チュートリアル | textbook_02_tutorial_common.md | textbook_02_tutorial_project.md |
| 5.3 デバッグ・エラー原因の調べ方 | textbook_03_debug_common.md | textbook_03_debug_project.md |
| 5.4 実際のエラー対応一覧 | textbook_04_errors_common.md | textbook_04_errors_project.md |

- **記載の方針（Python 初心者）:** 教材4種は、Python を初めて学ぶ人が読んでも理解できる**学習用テキスト**として書くこと。専門用語・コマンド・コードは初出でも追えるよう短く説明し、手順は段階を追って記載する。知見の追記（7.3）でも同じ方針を守る。
- **共通（*_common.md）:** 複数の異なるプロジェクトから、プロジェクトごとに追記が重ねられているファイルである。一つの *_common.md に、別々のプロジェクトで得た知見が蓄積される。追記時は必ず `【出典: リポジトリ名】` を付ける。
- **各プロジェクト（*_project.md）:** 当該プロジェクトフォルダの内容のみ。保存先はプロジェクトフォルダ直下およびプロジェクトフォルダ内の dist フォルダ（デスクトップアプリの場合）。WEBアプリの場合はプロジェクトフォルダ直下のみ。
- 各 .md には本ファイルのセクション3（Markdown 全般の共通ルール）に従う。見出しが複数ある .md には目次・アンカー・引用ブロックを作成する。

更新のタイミングと対象: 本ファイルの「7. 文書・mdc の更新 実施手順」の 7.2（*_project.md の更新）および 7.3（*_common.md と errors-debug-unittest-common.mdc への知見追記）に従う。

---

<a id="6-エラーデバッグ単体テストの知見の追記先"></a>
## 6. エラー・デバッグ・単体テストの知見の追記先

**【Cursorがやる】** チャット終了時に「うまくいった知見だけ」を ①②③ の3か所へ追記する。

知見を追記するときは、次の 3 か所すべてに追記する。② 共通の教材 と ③ errors-debug-unittest-common.mdc には必ず `【出典: リポジトリ名】` を付ける。

**追記のタイミング：** チャットでの作業が終わるたびに、当チャットで得た知見をそのチャットのうちに追記すること。複数チャット後にまとめて更新すると、前のチャットの内容が反映されず漏れる。

**追記する内容：** チャット毎に追記するが、**最終的に残すのは、うまくいったものだけ**とする。トライ＆エラーで何度も修正を繰り返している最中の、まだ解決していない試行や失敗したパターンは残さない。最終的にエラー対策ができたときの原因・対策・修正内容、うまくいったデバッグ方法、有効だった単体テストだけを、① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc の 3 か所に残す。

**GUI の改善・修正の場合：** Cursor は GUI をマウスで操作できない。ユーザーがアプリを起動して操作し、うまくいったかどうかはユーザーが次のチャットの返信で伝える。チャット毎に追記し、**ユーザーの返信の趣旨で判断する。** 趣旨がうまくいった・解決したと Cursor が判断した時点で、その内容を ① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc に残す（必ずしも同じ表現でなくてもよい）。趣旨が解決に至っていないと判断したときは残さない（必ずしも同じ言い方でなくても、そう判断したら残さない）。

| 追記先 | 置き場所（ファイル名） |
|--------|------------------------|
| ① プロジェクトの教材 | 作業対象のプロジェクトフォルダ直下の textbook_01_overview_project.md, textbook_02_tutorial_project.md, textbook_03_debug_project.md, textbook_04_errors_project.md のうち、知見の内容に応じて該当するファイルに追記する。 |
| ② 共通の教材 | 共通リポジトリ（cursor_rules）内の textbook_01_overview_common.md, textbook_02_tutorial_common.md, textbook_03_debug_common.md, textbook_04_errors_common.md のうち、知見の内容に応じて該当するファイルに追記する。 |
| ③ errors-debug-unittest-common.mdc | 共通リポジトリ（cursor_rules）の .cursor/rules/errors-debug-unittest-common.mdc 内の追記用セクション。知見の種類に応じ、次の 3 つの見出しのいずれかの下に追記する：【追記用】経験したエラー対応（事例一覧）／【追記用】デバッグの良い方法（事例一覧）／【追記用】単体テストの良い方法（事例一覧）。 |

エラー・デバッグ中心なら textbook_03_debug_*・textbook_04_errors_* に、概要やチュートリアルに触れる知見なら textbook_01_overview_*・textbook_02_tutorial_* にも追記する。② 共通の教材 と ③ errors-debug-unittest-common.mdc には必ず `【出典: リポジトリ名】` を付ける。

---

<a id="7-文書mdc-の更新-実施手順cursor-が完璧に更新するための手順"></a>
## 7. 文書・mdc の更新 実施手順（Cursor が完璧に更新するための手順）

**【Cursorがやる】** トリガーに該当したら 7.1〜7.6 を省略せず実施する。

以下のいずれかの更新が指示されたとき、該当する 7.1〜7.6 の手順を**省略せずに**実行する。

<a id="71-readme-の更新"></a>
### 7.1 README の更新

**【Cursorがやる】**

**トリガー:** コード修正・機能追加後（post-modification-common.mdc の ③ に相当）。

**デスクトップアプリの場合:**

1. 次の 4 ファイルを、現在のコード・機能に合わせて更新する。内容は 4 ファイルで同一にする。
   - プロジェクトフォルダ直下の `readme.md`
   - プロジェクトフォルダ直下の `readme.txt`
   - プロジェクトフォルダ直下の dist フォルダ内の `readme.md`
   - プロジェクトフォルダ直下の dist フォルダ内の `readme.txt`

**WEBアプリの場合（dist がない場合）:**

1. 次の 2 ファイルを、現在のコード・機能に合わせて更新する。内容は同一にする。
   - プロジェクトフォルダ直下の `readme.md`
   - プロジェクトフォルダ直下の `readme.txt`

<a id="72-教材4種_projectmd-の更新"></a>
### 7.2 教材4種（*_project.md）の更新

**【Cursorがやる】**

**トリガー:** コード修正・機能追加後（post-modification-common.mdc の ④ に相当）。

**7.2 と 7.3 の違い（同じことではない）:**  
- **7.2（同期）:** コード・機能の変更に合わせて、教材の内容を**現在の実装に同期する**。教材を「いまのコードが何をしているか」に合わせて**書き換え・更新**する。トリガーはコード修正・機能追加後。  
- **7.3（知見の追記）:** チャット毎に得た知見を**追記**するが、うまくいったものだけを残す。「このエラーはこう直した」「このデバッグ方法が有効だった」といった**一文ずつの知見を足していく**作業。トリガーはチャット終了時。  

同期（7.2）は「教材全体を現状に合わせる」、知見の追記（7.3）は「うまくいった事柄を追記して残す」で、**別の作業**である。最終的にうまくいったときのことは、どちらの手順でも教材などに記載される（7.2 で現状が反映され、7.3 でうまくいった対策・方法が積み重なる）。

**デスクトップアプリの場合:**

1. 次の 8 ファイルを、現在のコードに合わせて更新する。
   - プロジェクトフォルダ直下: `textbook_01_overview_project.md`, `textbook_02_tutorial_project.md`, `textbook_03_debug_project.md`, `textbook_04_errors_project.md`
   - プロジェクトフォルダ直下の dist フォルダ内: 上記 4 ファイル名で同じ 4 ファイル（計 8 ファイル）。

**WEBアプリの場合:**

1. プロジェクトフォルダ直下の次の 4 ファイルを、現在のコードに合わせて更新する。
   - `textbook_01_overview_project.md`, `textbook_02_tutorial_project.md`, `textbook_03_debug_project.md`, `textbook_04_errors_project.md`

<a id="73-教材4種_commonmd-および-errors-debug-unittest-commonmdc-への知見の追記"></a>
### 7.3 教材4種（*_common.md）および errors-debug-unittest-common.mdc への知見の追記

**【Cursorがやる】**

**トリガー:** チャットでの作業が終わるたびに（ユーザーが一区切りつけたとき・「今日はここまで」などと言ったとき）。**いずれもユーザーの返信の趣旨で判断する。** 必ずしも本項（7.3）に書いた表現と同一でなくても、同じ趣旨と Cursor が判断したら該当する動作を行う。

**重要:** チャット毎に ① ② ③ を更新するが、**残すのは、うまくいったものだけ**とする。ユーザーの返信の趣旨で判断し、趣旨がうまくいった・解決したと Cursor が判断した時点で、その内容を ① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc に**残す**（必ずしも同じ表現でなくてもよい）。トライ＆エラー中の未解決・失敗した試行は**残さない**。複数チャット後にまとめて更新すると前のチャットの内容が漏れるため、**毎回のチャット終了時に更新する**。

**GUI の場合：** Cursor は GUI のマウス操作ができない。ユーザーがアプリを起動して操作し、うまくいったかどうかはユーザーが次のチャットの返信に書く。上記と同様、チャット毎に追記し、**ユーザーの返信の趣旨で判断する。** 趣旨がうまくいった・解決したと Cursor が判断した時点で、その内容を ① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc に残す（必ずしも同じ表現でなくてもよい）。趣旨が解決に至っていないと判断したときは残さない（必ずしも同じ言い方でなくても、そう判断したら残さない）。

1. **① プロジェクトの教材:** 作業対象のプロジェクトフォルダ直下の次の 4 種のうち、知見の内容に応じて該当するファイルに追記する。`textbook_01_overview_project.md`（概要）、`textbook_02_tutorial_project.md`（詳細チュートリアル）、`textbook_03_debug_project.md`（デバッグ）、`textbook_04_errors_project.md`（エラー対応）。
2. **② 共通の教材:** 共通リポジトリ（cursor_rules）を開き、次の 4 種のうち、知見の内容に応じて該当するファイルに追記する。`textbook_01_overview_common.md`（概要）、`textbook_02_tutorial_common.md`（詳細チュートリアル）、`textbook_03_debug_common.md`（デバッグ）、`textbook_04_errors_common.md`（エラー対応）。各項目の冒頭に `【出典: リポジトリ名】` を付ける。
3. **③ errors-debug-unittest-common.mdc:** 共通リポジトリ（cursor_rules）の `.cursor/rules/errors-debug-unittest-common.mdc` を開き、知見の種類に応じて該当する追記用見出しの下に追記する。【追記用】経験したエラー対応（事例一覧）／【追記用】デバッグの良い方法（事例一覧）／【追記用】単体テストの良い方法（事例一覧）の 3 つ。各項目の冒頭に `【出典: リポジトリ名】` を付ける。

<a id="74-mdc-の更新"></a>
### 7.4 .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）の更新

**【Cursorがやる】**

**トリガー:** 共通ルールの内容を変更するとき。

**禁止:** 作業対象のプロジェクトフォルダの `.cursor/rules/` に上記 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）をコピーしたり配置したりしないこと。これら 6 本は常にサブモジュール（共通リポジトリ cursor_rules）内の `.cursor/rules/` を参照する。コピーすると古いかどうか分からなくなり、共通の更新が反映されない。

1. 共通リポジトリ（cursor_rules）の `.cursor/rules/` を開く（作業対象のプロジェクトではなく、共通リポジトリ側を開く）。
2. 編集対象の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc のいずれか）を編集する。
3. 編集後、共通リポジトリ（cursor_rules）で commit および push して **GitHub にアップロードする**。push しないと各プロジェクトに最新が反映されない。Cursor が編集したときは、共通リポジトリ（cursor_rules）をカレントにしたターミナルで commit および push を実行する。作業対象のプロジェクト側では上記 6 本の .mdc を編集せず、7.6 サブモジュールの更新で最新を取り込む。

<a id="75-cursor_instructions_templatemd-の更新"></a>
### 7.5 cursor_instructions_template.md の更新

**【Cursorがやる】**

**トリガー:** 共通ルールや手順・運用を変更したとき。

1. 共通リポジトリ（cursor_rules）を開く。
2. 共通リポジトリ（cursor_rules）のルートにある `cursor_instructions_template.md` を編集する。
3. 冒頭の「リビジョン」「更新日」も更新する。
4. 共通リポジトリ（cursor_rules）で commit および push して **GitHub にアップロードする**。push しないと各プロジェクトに最新が反映されない。Cursor が編集したときは、共通リポジトリをカレントにしたターミナルで commit および push を実行する。

<a id="76-サブモジュールの更新"></a>
### 7.6 サブモジュールの更新（プロジェクトで作業を始める前）

**【Cursorがやる】**

**トリガー:** 作業対象のプロジェクトフォルダで作業を開始する前（毎回推奨）。

**共通の書類を更新したとき（7.4・7.5 の後）：** 共通リポジトリ（cursor_rules）で .mdc や cursor_instructions_template.md を編集したら、**commit および push して GitHub にアップロードする**まで行う。push しないと各プロジェクトで `git submodule update --remote cursor_rules` を実行しても最新が取り込まれない。Cursor が共通リポジトリを編集したときは、共通リポジトリをカレントにしたターミナルで `git add`・`git commit`・`git push` を実行する。

**プロジェクトで共通の最新を取り込むとき：** ユーザーの返信の趣旨が作業開始・共通を最新にしたいと Cursor が判断したときは、**Cursor が**作業対象のプロジェクトフォルダをカレントにしたターミナルで次を実行する。`git submodule update --remote cursor_rules` 必ずしも「作業を始める」「共通を最新にして」の表現でなくても、その趣旨と判断したら実行する。これにより GitHub に push 済みの共通リポジトリの最新が作業対象のプロジェクトに取り込まれる。Cursor はこのコマンドをターミナルで実行できる。

---

<a id="8-プロジェクト開始時の実行順序"></a>
## 8. プロジェクト開始時の実行順序

**【Cursorがやる】**

1. セクション0（セットアップ）を実施する。
2. セクション1の次の 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）を登録する（共通リポジトリ cursor_rules をサブモジュールで取り込んでいれば、サブモジュール内の .cursor/rules/ を参照する）。
3. スクリプトの内容・機能はユーザーから別途指示があるまで待つ。

---

<a id="9-修正機能追加後の実行"></a>
## 9. 修正・機能追加後の実行

**【Cursorがやる】**

post-modification-common.mdc が alwaysApply: true で登録されているため、コード修正・追加後は自動的に以下を実施する。

- デスクトップアプリ: ビルド → 7.1（README 4 ファイル更新）→ 7.2（教材 *_project.md 8 ファイル更新）を実行する。
- WEBアプリ: サーバー再起動 → 7.1（README、プロジェクトフォルダ直下の readme.md・readme.txt のみ）→ 7.2（教材 *_project.md、プロジェクトフォルダ直下の 4 ファイルのみ）を実行する。

完了したら完了報告する。

---

<a id="10-mdc-の内容参照用"></a>
## 10. .mdc の内容（参照用）

**【Cursorがやる】** `.mdc` が存在しない場合に作成できるよう、参照用として載せる。

次のいずれかの .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）が 共通リポジトリ（cursor_rules）の `.cursor/rules/` に存在しない場合、以下を元に作成する。各ファイルの先頭に YAML フロントマターを付ける。フロントマターは `---` で囲み、必ず `description:` と `alwaysApply:`（true または false）を記載する。markdown-common.mdc のみ `globs: "**/*.md"` と `alwaysApply: false` を記載する。本ファイル（cursor_instructions_template.md）一枚で登録・作成まで完結するため、本セクション（10. .mdc の内容（参照用））を参照すること。

---

**venv-only-common.mdc**  
- フロントマター: `description: 仮想環境・システムPython保護`、`alwaysApply: true`
- 記載内容（すべて明示）:（1）すべての作業は .venv を有効化した状態で行う。python / pip / pyinstaller は .venv 経由で実行する（Windows: .venv\Scripts\python.exe 等）。（2）システムPython（グローバル環境）には何もインストールしない。（3）誤ってシステムPythonにインストールした場合は、アンインストールして元に戻し、完了を報告する。

---

**errors-debug-unittest-common.mdc**  
- フロントマター: `description: エラー対応・デバッグ・単体テスト・知見の追記先（3か所に追記）`、`alwaysApply: true`
- 記載内容（すべて明示）: 経験したエラー対応・デバッグの良い方法・単体テストの良い方法を 3 つに分けて記述。知見は次の 3 か所に追記する。チャット毎に追記するが、最終的に残すのは、うまくいったものだけとする。トライ＆エラー中の未解決・失敗した試行は残さない。GUI の場合は Cursor がマウス操作できないため、うまくいったかはユーザーが次のチャットの返信で伝える。チャット毎に追記し、ユーザーの返信の趣旨で判断する。趣旨がうまくいった・解決したと Cursor が判断した時点で、その内容を残す。趣旨が解決に至っていないと判断したときは残さない。②③には【出典: リポジトリ名】を付ける。教材への追記はセクション5の「記載の方針（Python 初心者）」に従う。① プロジェクトの教材：作業対象のプロジェクトフォルダ直下の textbook_01_overview_project.md, textbook_02_tutorial_project.md, textbook_03_debug_project.md, textbook_04_errors_project.md のうち該当ファイルに追記。② 共通の教材：共通リポジトリ（cursor_rules）内の textbook_01_overview_common.md, textbook_02_tutorial_common.md, textbook_03_debug_common.md, textbook_04_errors_common.md のうち該当ファイルに追記。③ errors-debug-unittest-common.mdc 内の「追記用」：次の 3 見出しのいずれかの下に【出典】付きで追記。【追記用】経験したエラー対応（事例一覧）／【追記用】デバッグの良い方法（事例一覧）／【追記用】単体テストの良い方法（事例一覧）。単体テストの実行方法（pytest: `python -m pytest tests/テストファイル名.py -v`、unittest: `python -m unittest tests.テストファイル名 -v`）を .mdc 内に記載する。

---

**post-modification-common.mdc**  
- フロントマター: `description: コード修正・機能追加後の必須手順（README・教材の更新）`、`alwaysApply: true`
- 記載内容（すべて明示）: コードを修正・追加した後は、アプリ種別に応じて順番に実施する。**デスクトップアプリ:**（1）アプリが起動中であれば強制終了する。（2）.venv 環境で exe をビルドする。（3）README の更新：プロジェクトフォルダ直下の readme.md・readme.txt と dist フォルダ内の readme.md・readme.txt の計 4 ファイルを、内容に合わせて更新する。プロジェクトフォルダ直下と dist 内は同一内容にすること。（4）教材の更新：プロジェクトフォルダ直下と dist フォルダ内の、textbook_01_overview_project.md, textbook_02_tutorial_project.md, textbook_03_debug_project.md, textbook_04_errors_project.md の計 8 ファイルを、現在のコードに合わせて更新する。教材はセクション5の「記載の方針（Python 初心者）」に従う。**WEBアプリ:**（1）サーバーを再起動する。（2）README の更新：プロジェクトフォルダ直下の readme.md・readme.txt を、内容に合わせて更新する。（3）教材の更新：プロジェクトフォルダ直下の textbook_01_overview_project.md, textbook_02_tutorial_project.md, textbook_03_debug_project.md, textbook_04_errors_project.md の 4 ファイルを、現在のコードに合わせて更新する。教材はセクション5の「記載の方針（Python 初心者）」に従う。完了したら完了報告する。**チャットでの作業が終わったとき:** 当チャットで最終的にうまくいった知見があれば、cursor_instructions_template.md の 7.3 に従い、① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc に追記する。GUI の場合はユーザーの返信の趣旨で判断し、うまくいった・解決したと判断した時点で残す。解決に至っていないと判断したときは残さない。毎回のチャット終了時に更新する。

---

**gui-build-security-common.mdc**  
- フロントマター: `description: GUI・ビルド・WEBセキュリティ`、`alwaysApply: true`
- 記載内容（すべて明示）: **GUI 共通ルール（デスクトップアプリ）:**（1）Enter：OK・実行、Tab：フォーカス移動、Escape：キャンセル・終了を GUI 全体で有効にする。（2）「終了」ボタンを必ず追加する。（3）×ボタン（WM_DELETE_WINDOW）でも「終了」ボタンと同じ終了処理（quit → destroy）を通す。（4）インプットファイルを選択できるようにする。（5）アウトプットフォルダも選択できるようにする。デフォルトはインプットファイルと同じフォルダ。（6）アウトプットファイルがある場合は、完了時に完了通知を表示し、「フォルダを開く」ボタンをつける。**ビルドルール（デスクトップアプリ）:**（1）PyInstaller の --onefile オプションでビルドする。ファイル数・サイズが大きく起動が遅い場合は --onedir を提案可。（2）ビルドは .venv 環境内で行う。（3）任意の PC で動作し、システムに影響しない実行ファイルを作成する。**WEBアプリ セキュリティ要件:**（1）アクセスにパスワード認証を設ける（簡易トークン認証でも可）。（2）入力値のバリデーション（サニタイズ）を行う。（3）SQLインジェクション・XSS対策を施す。（4）CSRF対策を施す（CSRFトークンの使用が一般的）。（5）HTTPS化する（クラウド運用時は必須）。（6）エラーメッセージにDB構造・スタックトレースなどの内部情報を表示しない。（7）サーバーは localhost または LAN 内 IP（192.168.x.x）にのみバインドする（0.0.0.0 でのバインドは避ける）。（8）セッション管理を行い、一定時間操作がなければ再認証を求める。（9）使用ライブラリは既知の脆弱性がない最新版を使用する。

---

**markdown-common.mdc**  
- フロントマター: `description: Markdown 全般の共通ルール（目次リンク・アンカー・プレビュー注記含む、全 .md に適用）`、`globs: "**/*.md"`、`alwaysApply: false`
- 記載内容（すべて明示）: **Markdown 全般の共通ルール**。本ファイルのセクション3（Markdown 全般の共通ルール）と同一内容。適用対象はすべての Markdown 文書（readme.md、教材4種 *_common.md / *_project.md を含む）。見出しが複数ある .md には以下を適用する。（1）文書冒頭に「## 目次」を置く。目次は `[表示テキスト](#アンカーID)` の形式でリンクにする。アンカーID は半角英数字とハイフンのみ（例: sec0, sec1-1）。（2）目次でリンクする各見出しの直前に `<a id="アンカーID"></a>` を 1 行置く。見出しに `{#id}` のみ付けることは禁止。（3）「## 目次」セクションの直後に、引用ブロックで「Markdown Preview Enhanced で Ctrl+Alt+M により目次リンクがジャンプする」旨を入れる。詳細・Cursor 設定は `目次リンク付きマークダウン作成指示.md` を参照。

---

**update-management-common.mdc**  
- フロントマター: `description: 共通ルール・共通教材とプロジェクト固有の更新場所を分けるルール`、`alwaysApply: true`
- 記載内容（すべて明示）: **共通で更新するもの（cursor_rules 側）:** .cursor/rules の次の 6 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc）、cursor_instructions_template.md、共通教材（textbook_01_overview_common.md, textbook_02_tutorial_common.md, textbook_03_debug_common.md, textbook_04_errors_common.md）。共通教材は cursor_instructions_template.md セクション5の「記載の方針（Python 初心者）」に従う。編集したら **commit および push して GitHub にアップロードする**まで行う。push しないと各プロジェクトに最新が反映されない。**プロジェクトで更新するもの:** ソースコード、readme.md・readme.txt、教材（textbook_01_overview_project.md, textbook_02_tutorial_project.md, textbook_03_debug_project.md, textbook_04_errors_project.md）。編集・commit・push はそのプロジェクトのフォルダで行う。**禁止:** プロジェクトの .cursor/rules/ に上記 6 本の .mdc をコピー・配置しないこと。これら 6 本は常にサブモジュール（cursor_rules）内の .cursor/rules/ を参照する。**プロジェクト側で共通の最新を取り込むとき:** プロジェクトで作業を始める前に、プロジェクトのフォルダで `git submodule update --remote cursor_rules` を実行する（Cursor のターミナルで可）。**Cursor が実行すること:**（1）開始時：ユーザーの返信の趣旨が作業を始めたいと判断したとき、cursor_rules/cursor_instructions_template.md を開き、セクション 0・1・8 に従う。（2）サブモジュールの更新：ユーザーの返信の趣旨が共通を最新にしたいと判断したとき、ターミナルで `git submodule update --remote cursor_rules` を実行する。（3）チャット終了時：ユーザーの返信の趣旨が一区切りついたと判断したとき、7.3 に従い、うまくいった知見だけを ① ② ③ に残す。GUI の場合は返信の趣旨で判断し、うまくいった・解決したと判断した時点で残す。解決に至っていないと判断したときは残さない。
