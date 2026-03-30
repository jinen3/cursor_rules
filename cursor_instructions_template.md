# Cursor 開発 共通ルール文書

**役割:** この文書は Cursor が読んで実行する指示書である。**この文書は .mdc ではない。** Markdown（.md）であり、共通リポジトリ（cursor_rules）のルートに置く「マスタ指示文書」である。次の 7 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）は .cursor/rules/ に置く個別ルールで、本ファイル（cursor_instructions_template.md）はその一覧・使い方・更新手順を一括で示す。人間向けの説明は別ファイル `Cursor開発共通ルール_ユーザー向け説明.md` に記載する。

**リビジョン:** 7  
**更新日:** 2026-03-30

## 目次

> プレビューで目次リンクをジャンプするには **Markdown Preview Enhanced** をインストールし、**Ctrl+Alt+M** または右クリック「Open Preview」でプレビューを開く。標準プレビューでは目次リンクは動作しない。

- [0. セットアップ](#sec0)
- [1. cursor/rules の登録](#sec1)
- [1.1 Checklist A（全共通 .mdc の順守チェック）](#sec1-1)
- [2. スクリプト作成 補足](#sec2)
- [3. Markdown 全般の共通ルール](#sec3)
- [4. README 作成・更新](#sec4)
- [5. 教材4種 作成・更新](#sec5)
- [6. 知見の追記先](#sec6)
- [7. 文書・mdc の更新 実施手順](#sec7)
- [8. プロジェクト開始時の実行順序](#sec8)
- [9. 修正・機能追加後の実行](#sec9)
- [10. .mdc の内容（参照用）](#sec10)

---

<a id="sec0"></a>
<a id="0-セットアッププロジェクト開始時に実行すること"></a>
## 0. セットアップ（プロジェクト開始時に実行すること）

**【Cursor対応項目】** プロジェクト開始時に、作業PC上で準備する（必要ならターミナルでコマンド実行する）。

以下を実施すること。

- プロジェクトフォルダ直下に仮想環境（.venv）がなければ作成する。
- すべての作業は .venv を有効化した状態で行う。python / pip / pyinstaller は .venv 経由で実行する（Windows: .venv\Scripts\python.exe、Mac/Linux: .venv/bin/python）。
- 起動スクリプト（.vbs / .bat / .sh）を作る場合も .venv 内の Python を優先する。
- システムPython（グローバル環境）には何もインストールしない。誤ってインストールした場合はアンインストールして元に戻し、完了を報告する。

---

<a id="sec1"></a>
<a id="1-cursorrules-の登録"></a>
## 1. cursor/rules の登録

**【人が対応要！】** このプロジェクトで最初の1回だけ、Cursor の Rules に `.mdc` を登録する（以降は不要）。

**禁止:** 作業対象のプロジェクトフォルダの `.cursor/rules/` に次の 7 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）をコピー・配置しないこと。コピーすると共通リポジトリ（cursor_rules）でこれらを更新してもプロジェクトに反映されず、バージョン管理ができなくなる。

**実施すること:** 次の 7 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）は **共通リポジトリ（cursor_rules）の `.cursor/rules/` にのみ存在させる。** 作業対象のプロジェクトでは、cursor_rules をサブモジュールとして取り込み、**サブモジュール内のパス（プロジェクトフォルダ/cursor_rules/.cursor/rules/）を参照して** これら 7 本を登録すること。`markdown-common.mdc` は `globs: "**/*.md"` と `alwaysApply: false`、それ以外 6 本は `alwaysApply: true` で登録する。

<a id="sec1-1"></a>
### 1.1 Checklist A（全共通 .mdc の順守チェック）

#### 概要（一目で）

- **開発タスク（依頼対応）が一区切りついたあと・完了報告の前**に、**Checklist A を必ず通す**運用とする。Cursor（エージェント）は共通ルールに従い、可能な限り **`run: checklist A (all rules)` を実行してから**完了報告する（**手動でタスクを実行する**必要がある場合もある）。
- 一度走らせると、スクリプトが **各 `.mdc` の本文まで**（`spec` のハッシュ一致）と、ポリシーに沿った **ランタイム検証**を **機械的に**行う。
- Checklist A が **失敗したら**、原因を直し、**同じタスクをもう一度実行**する。**漏れない仕組み（Checklist A）を通るまで**回す。
- **WEB実装が検出されたプロジェクトだけ**、一部ルールについて **手動確認**を要求する。デスクトップなど **非WEB** は **out of scope** とし、**自動チェックのみ**で当該手動項目は完了扱い。
- **実行（1クリック）:** `ターミナル(T)` → `タスクの実行…` → **`run: checklist A (all rules)`**

#### 「自動」と「手動でタスク実行」の違い

- **スクリプト内部の検証は自動**（各 `.mdc` 全文のハッシュ照合、TOC fix→check、該当時の単体テスト、ランタイム検証など）。
- **エディタがチャット終了やファイル保存を検知して、勝手に Checklist A を起動する**わけではない。運用ルール上、**完了報告の前**に Checklist A を通す。**Cursor（エージェント）**は可能な限り `run: checklist A (all rules)` を実行する。**ユーザーが同じタスクを手動で実行する**場合もある。

#### 詳細・FAQ（実行タイミング・`.mdc` 内容の検証反映）

- **`Checklist_A.md`** の「[実行タイミング（いつ実行するか）](Checklist_A.md#sec-timing)」「[最新の .mdc 内容が検証に反映される仕組み](Checklist_A.md#sec-fresh)」を参照する。

**【Cursor対応項目】** 共通ルールの順守は **Markdown 目次だけ**ではなく、venv・テスト・事後手順・セキュリティ・更新管理など **すべての領域別 `.mdc`** にまたがる。それらを **抜け漏れなく機械検証する本体**である **Checklist A** の役割を、`checklist-a-all-rules-common.mdc` で明示する。

- **正（ソース・オブ・トゥルース）**は各 `.mdc` の本文と、`run-checklist-a.ps1` が照合する **`spec/checklist_a_requirements.json`（各 `.mdc` 全文のハッシュ）** である。テンプレ文書のセクション10（参照用）は補助であり、**自動チェックの定義そのものではない**。
- 実行は **`ターミナル(T)` → `タスクの実行…` → `run: checklist A (all rules)`**。詳細は `checklist-a-all-rules-common.mdc` および `Checklist_A.md` を参照する。

### Rules 登録の手順・チェックリスト・毎日の dev-start はどこに書いてある？

**重複を避けるため、開いてすぐ迷わない運用は `cursor_rules_submodule_開発開始手順.md` に集約する。** そちらに、次をまとめて載せている。

- プロジェクトごとの確認（サブモジュール／タスク／Rules の3点）
- **タスクの実行…** で `dev-start` → ソース管理で共有の有無
- 7 本のファイル名と登録元パス

**本ファイル（cursor_instructions_template.md）の役割**は、上記の「禁止・パス参照の原則」と、下記セクションの更新方針・.mdc 本文（参照用）である。

**7 本の .mdc の本文**は、本ファイルの「10. .mdc の内容（参照用）」を参照すること。

**Checklist A（統合チェック）**の意味・実行は、**1.1** および `checklist-a-all-rules-common.mdc` を参照すること。

---

<a id="sec2"></a>
<a id="2-スクリプト作成-補足アプリごとに指定がある場合"></a>
## 2. スクリプト作成 補足（アプリごとに指定がある場合）

**【Cursor対応項目】** ユーザーの要望に合わせて、実装方針・ライブラリ選定などの補足条件として適用する。

- 環境: 本ファイルのセクション0（セットアップ）および venv-only-common.mdc に従う。
- GUI ライブラリ: 指定がなければ Tkinter / customtkinter / Flet から 1 つ選ぶ。PyQt6 は GPL のため商用・配布では避ける。
- アウトプット形式: アプリに合わせて .txt / .md / .csv 等を指定する。
- WEBアプリの場合: PCとスマホでデータ同期、プライベート利用、gui-build-security-common.mdc のセキュリティ要件に従う。

---

<a id="sec3"></a>
<a id="3-markdown-文書の共通ルール全-md-に適用"></a>
## 3. Markdown 全般の共通ルール（全 .md に適用）

**【Cursor対応項目】** README・教材など、見出しが複数ある Markdown を作成/更新するときは必ず従う。

本セクションは Markdown 文書全般の共通ルールである。目次リンクに限らず、すべての .md に共通する書式・ルールを定める。実施内容は markdown-common.mdc（Markdown 全般の共通ルール）と同一とする。

**適用対象:** すべての Markdown 文書（プロジェクトフォルダ直下の readme.md、教材4種（*_common.md / *_project.md）を含む）。見出しが複数ある文書には、以下 1〜3 を適用する。

**実施すること（見出しが複数ある .md に適用）:**

1. 文書冒頭に「## 目次」を置く。目次は `- [表示テキスト](#アンカーID)` の形式でリンクにする。アンカーID は半角英数字とハイフンのみ（例: sec0, sec1-1）。
2. 目次でリンクする各見出しの**直前に** `<a id="アンカーID"></a>` を 1 行で置く。見出しに `{#id}` のみ付けることは禁止。
3. 文書内の「## 目次」セクションの直後に、引用ブロックで「Markdown Preview Enhanced で Ctrl+Alt+M により目次リンクがジャンプする」旨を 1 行入れる。

---

<a id="sec4"></a>
<a id="4-readme-作成更新"></a>
## 4. README 作成・更新

**【Cursor対応項目】** コード修正・機能追加後に、README（および配布物内のREADME）を現状に同期して更新する。

作成すること:

- **readme.md**: プロジェクトフォルダ直下に保存。使い方・バックアップ・トラブル対処を記載。目次は本ファイルのセクション3（Markdown 全般の共通ルール）に従う。
- **readme.txt**: readme.md と同一内容を .txt で作成。平易な日本語。目次は「見出し一覧」として記載。
- **デスクトップアプリの場合のみ:** プロジェクトフォルダ直下の readme.md・readme.txt と同一内容の readme.md・readme.txt を **dist フォルダ内**にも配置する。
- **WEBアプリの場合:** dist フォルダは使わないため、**プロジェクトフォルダ直下の readme.md・readme.txt のみ**作成・更新する。

更新のタイミングと対象: コード修正・機能追加後。対象は本ファイルの「7. 文書・mdc の更新 実施手順」の 7.1（README の更新）に従う。

---

<a id="sec5"></a>
<a id="5-教材4種-作成更新"></a>
## 5. 教材4種 作成・更新

**【Cursor対応項目】** コード修正後は教材を現状に同期し、チャット終了時は知見を追記する（7.2/7.3）。

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

<a id="sec6"></a>
<a id="6-エラーデバッグ単体テストの知見の追記先"></a>
## 6. エラー・デバッグ・単体テストの知見の追記先

**【Cursor対応項目】** チャット終了時に「うまくいった知見だけ」を ①②③ の3か所へ追記する。

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

<a id="sec7"></a>
<a id="7-文書mdc-の更新-実施手順cursor-が完璧に更新するための手順"></a>
## 7. 文書・mdc の更新 実施手順（Cursor が完璧に更新するための手順）

**【Cursor対応項目】** トリガーに該当したら 7.1〜7.6 を省略せず実施する。

以下のいずれかの更新が指示されたとき、該当する 7.1〜7.6 の手順を**省略せずに**実行する。

<a id="71-readme-の更新"></a>
### 7.1 README の更新

**【Cursor対応項目】**

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

**【Cursor対応項目】**

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

**【Cursor対応項目】**

**トリガー:** チャットでの作業が終わるたびに（ユーザーが一区切りつけたとき・「今日はここまで」などと言ったとき）。**いずれもユーザーの返信の趣旨で判断する。** 必ずしも本項（7.3）に書いた表現と同一でなくても、同じ趣旨と Cursor が判断したら該当する動作を行う。

**重要:** チャット毎に ① ② ③ を更新するが、**残すのは、うまくいったものだけ**とする。ユーザーの返信の趣旨で判断し、趣旨がうまくいった・解決したと Cursor が判断した時点で、その内容を ① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc に**残す**（必ずしも同じ表現でなくてもよい）。トライ＆エラー中の未解決・失敗した試行は**残さない**。複数チャット後にまとめて更新すると前のチャットの内容が漏れるため、**毎回のチャット終了時に更新する**。

**GUI の場合：** Cursor は GUI のマウス操作ができない。ユーザーがアプリを起動して操作し、うまくいったかどうかはユーザーが次のチャットの返信に書く。上記と同様、チャット毎に追記し、**ユーザーの返信の趣旨で判断する。** 趣旨がうまくいった・解決したと Cursor が判断した時点で、その内容を ① プロジェクトの教材 ② 共通の教材 ③ errors-debug-unittest-common.mdc に残す（必ずしも同じ表現でなくてもよい）。趣旨が解決に至っていないと判断したときは残さない（必ずしも同じ言い方でなくても、そう判断したら残さない）。

1. **① プロジェクトの教材:** 作業対象のプロジェクトフォルダ直下の次の 4 種のうち、知見の内容に応じて該当するファイルに追記する。`textbook_01_overview_project.md`（概要）、`textbook_02_tutorial_project.md`（詳細チュートリアル）、`textbook_03_debug_project.md`（デバッグ）、`textbook_04_errors_project.md`（エラー対応）。
2. **② 共通の教材:** 共通リポジトリ（cursor_rules）を開き、次の 4 種のうち、知見の内容に応じて該当するファイルに追記する。`textbook_01_overview_common.md`（概要）、`textbook_02_tutorial_common.md`（詳細チュートリアル）、`textbook_03_debug_common.md`（デバッグ）、`textbook_04_errors_common.md`（エラー対応）。各項目の冒頭に `【出典: リポジトリ名】` を付ける。
3. **③ errors-debug-unittest-common.mdc:** 共通リポジトリ（cursor_rules）の `.cursor/rules/errors-debug-unittest-common.mdc` を開き、知見の種類に応じて該当する追記用見出しの下に追記する。【追記用】経験したエラー対応（事例一覧）／【追記用】デバッグの良い方法（事例一覧）／【追記用】単体テストの良い方法（事例一覧）の 3 つ。各項目の冒頭に `【出典: リポジトリ名】` を付ける。

<a id="74-mdc-の更新"></a>
### 7.4 .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）の更新

**【Cursor対応項目】**

**トリガー:** 共通ルールの内容を変更するとき。

**禁止:** 作業対象のプロジェクトフォルダの `.cursor/rules/` に上記 7 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）をコピーしたり配置したりしないこと。これら 7 本は常にサブモジュール（共通リポジトリ cursor_rules）内の `.cursor/rules/` を参照する。コピーすると古いかどうか分からなくなり、共通の更新が反映されない。

1. 共通リポジトリ（cursor_rules）の `.cursor/rules/` を開く（作業対象のプロジェクトではなく、共通リポジトリ側を開く）。
2. 編集対象の .mdc（上記 7 本のいずれか）を編集する。
3. 編集後、共通リポジトリ（cursor_rules）で commit および push して **GitHub にアップロードする**。push しないと各プロジェクトに最新が反映されない。Cursor が編集したときは、共通リポジトリ（cursor_rules）をカレントにしたターミナルで commit および push を実行する。作業対象のプロジェクト側では上記 7 本の .mdc を編集せず、7.6 サブモジュールの更新で最新を取り込む。

<a id="75-cursor_instructions_templatemd-の更新"></a>
### 7.5 cursor_instructions_template.md の更新

**【Cursor対応項目】**

**トリガー:** 共通ルールや手順・運用を変更したとき。

1. 共通リポジトリ（cursor_rules）を開く。
2. 共通リポジトリ（cursor_rules）のルートにある `cursor_instructions_template.md` を編集する。
3. 冒頭の「リビジョン」「更新日」も更新する。
4. 共通リポジトリ（cursor_rules）で commit および push して **GitHub にアップロードする**。push しないと各プロジェクトに最新が反映されない。Cursor が編集したときは、共通リポジトリをカレントにしたターミナルで commit および push を実行する。

<a id="76-サブモジュールの更新"></a>
### 7.6 サブモジュールの更新（プロジェクトで作業を始める前）

**【Cursor対応項目】**

**トリガー:** 作業対象のプロジェクトフォルダで作業を開始する前（毎回推奨）。

**共通の書類を更新したとき（7.4・7.5 の後）：** 共通リポジトリ（cursor_rules）で .mdc や cursor_instructions_template.md を編集したら、**commit および push して GitHub にアップロードする**まで行う。push しないと各プロジェクトで `git submodule update --remote cursor_rules` を実行しても最新が取り込まれない。Cursor が共通リポジトリを編集したときは、共通リポジトリをカレントにしたターミナルで `git add`・`git commit`・`git push` を実行する。

**プロジェクトで共通の最新を取り込むとき：** ユーザーの返信の趣旨が作業開始・共通を最新にしたいと Cursor が判断したときは、**Cursor が**作業対象のプロジェクトフォルダをカレントにしたターミナルで次を実行する。`git submodule update --remote cursor_rules` 必ずしも「作業を始める」「共通を最新にして」の表現でなくても、その趣旨と判断したら実行する。これにより GitHub に push 済みの共通リポジトリの最新が作業対象のプロジェクトに取り込まれる。Cursor はこのコマンドをターミナルで実行できる。

---

<a id="sec8"></a>
<a id="8-プロジェクト開始時の実行順序"></a>
## 8. プロジェクト開始時の実行順序

**【Cursor対応項目】**

1. セクション0（セットアップ）を実施する。
2. セクション1の次の 7 本の .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）を登録する（共通リポジトリ cursor_rules をサブモジュールで取り込んでいれば、サブモジュール内の .cursor/rules/ を参照する）。
3. スクリプトの内容・機能はユーザーから別途指示があるまで待つ。

---

<a id="sec9"></a>
<a id="9-修正機能追加後の実行"></a>
## 9. 修正・機能追加後の実行

**【Cursor対応項目】**

post-modification-common.mdc が alwaysApply: true で登録されているため、コード修正・追加後は自動的に以下を実施する。

- デスクトップアプリ: ビルド → 7.1（README 4 ファイル更新）→ 7.2（教材 *_project.md 8 ファイル更新）を実行する。
- WEBアプリ: サーバー再起動 → 7.1（README、プロジェクトフォルダ直下の readme.md・readme.txt のみ）→ 7.2（教材 *_project.md、プロジェクトフォルダ直下の 4 ファイルのみ）を実行する。

完了したら完了報告する。

---

<a id="sec10"></a>
<a id="10-mdc-の内容参照用"></a>
## 10. .mdc の内容（参照用）

**【Cursor対応項目】** `.mdc` が存在しない場合に作成できるよう、参照用として載せる。

次のいずれかの .mdc（venv-only-common.mdc, errors-debug-unittest-common.mdc, post-modification-common.mdc, gui-build-security-common.mdc, markdown-common.mdc, update-management-common.mdc, checklist-a-all-rules-common.mdc）が 共通リポジトリ（cursor_rules）の `.cursor/rules/` に存在しない場合、以下を元に作成する。各ファイルの先頭に YAML フロントマターを付ける。フロントマターは `---` で囲み、必ず `description:` と `alwaysApply:`（true または false）を記載する。markdown-common.mdc のみ `globs: "**/*.md"` と `alwaysApply: false` を記載する。本ファイル（cursor_instructions_template.md）一枚で登録・作成まで完結するため、本セクション（10. .mdc の内容（参照用））を参照すること。

---
