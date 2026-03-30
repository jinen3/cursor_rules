# Cursor 開発 共通ルール ユーザー向け説明

**対象読者:** 人間（運用者）。Cursor が読んで実行する指示は `cursor_instructions_template.md` に記載する。

この文書では、運用の流れ・用語・判断のための参考情報を説明する。

---

## 目次

> プレビューで目次リンクをジャンプするには **Markdown Preview Enhanced** をインストールし、**Ctrl+Alt+M** または右クリック「Open Preview」でプレビューを開く。標準プレビューでは目次リンクは動作しない。

- [目次の見方](#sec0)
- [参考1. 配布形式の選び方](#sec1)
- [参考2. WEBアプリ構成の選び方](#sec2)
- [参考3. Cursor rules の運用・更新管理](#sec3)
- [参考4. 共通リポジトリと各プロジェクトの運用](#sec4)
- [参考5. Checklist A（統合チェック）概要](#sec4b)
- [用語：「追記先」とは](#sec5)
- [付録 A. .mdc の本文](#sec6)

---

<a id="sec0"></a>
## 目次の見方

- 目次リンクでジャンプするには **Markdown Preview Enhanced** をインストールし、**Ctrl+Alt+M** でプレビューを開く。
- 拡張を使わない場合は左のアウトラインまたは **Ctrl+F** で検索する。

---

<a id="sec1"></a>
## 参考1. 配布形式の選び方（onefile vs onedir）

- **原則:** onefile + readme.txt。起動が遅くなるリスクがある場合は onedir を提案する。
- **onefile:** 配布物は .exe 1つ。起動時に展開するため遅くなることがある。
- **onedir:** 起動が速い。dist フォルダごと配布する必要がある。
- **使い分け:** 相手が素人 or 手軽さ優先 → onefile。ファイル・サイズが大きい or 起動速度が重要 → onedir。

---

<a id="sec2"></a>
## 参考2. WEBアプリ構成の選び方

- **Firebase Firestore:** クラウド上のDB。PCもスマホも同じデータを参照できる。
- **Render / Railway:** Pythonアプリをクラウドで動かす。HTTPS自動対応。
- **構成例:** ① Firebase + exe / ② Firebase + Render/Railway / ③ Render/Railway 単体。用途に応じて選択する。

---

<a id="sec3"></a>
## 参考3. Cursor rules の運用・更新管理

- **共通リポジトリを参照する（サブモジュール）のみ。** コピーは更新漏れが生じるため行わない。
- 共通リポジトリを「正」とし、プロジェクトでは取り込むだけにする。共通で更新 → 各プロジェクトで `git submodule update --remote cursor_rules` を実行する。
- 知見は ①プロジェクトの教材 ②共通の教材 ③errors-debug-unittest-common.mdc の 3 か所に追記する。②③には `【出典: リポジトリ名】` を付ける。

---

<a id="sec4"></a>
## 参考4. 共通リポジトリと各プロジェクトの運用（手順・目的）

- **リポジトリの役割:** 共通＝cursor_rules（.mdc、テンプレート、*_common.md）。各プロジェクト＝アプリのソース・readme・*_project.md。
- **手順 A:** 共通リポジトリの準備（clone、以降は cursor_rules で編集→commit→push）。
- **手順 B:** プロジェクトで共通ルールを初めて使うとき（GitHubでリポジトリ作成→clone→Cursorでフォルダを開く→`git submodule add ...`）。
- **手順 C:** 作業を始めるとき（毎回）プロジェクトを開く→ターミナルで `git submodule update --remote cursor_rules` を実行する。
- **手順 D:** 共通ルール・共通教材の中身を編集するときは cursor_rules を開き、編集→commit→push する。
- **補足:** ターミナルは **Ctrl+`**、ソース管理は **Ctrl+Shift+G**。

---

<a id="sec4b"></a>
## 参考5. Checklist A（統合チェック）概要

- **いつ:** 開発タスクが一区切りついた **あと**、**完了報告の前**（エディタが自動起動するわけではない。Cursor が可能な限り実行するか、**ユーザーがタスクから実行**する）。
- **何をするか:** `run-checklist-a.ps1` が **各 `.mdc` の本文まで**（`spec` のハッシュ）とランタイム検証を **機械的**に行う。失敗したら修正し、**同じタスクを再実行して PASS まで**回す。
- **WEB と非WEB:** **WEB実装が検出されたプロジェクトだけ**一部ルールで **手動確認**。**非WEB** は out of scope、**自動チェックのみ**で当該手動項目は完了扱い。
- **実行（1クリック）:** `ターミナル(T)` → `タスクの実行…` → **`run: checklist A (all rules)`**
- **詳細・FAQ（実行タイミング・`.mdc` 内容の検証反映）:** `cursor_rules` ルートの **`Checklist_A.md`** を参照する。
- **検証の仕組み:** Checklist A は **最新の `.mdc` 内容が検証に反映される仕組み**である。手元の **`cursor_rules` サブモジュール**にある **実 `.mdc` ファイルの本文**と、同梱の **`spec/checklist_a_requirements.json`**（各 `.mdc` 全文のハッシュ）を照合する。詳細は **`Checklist_A.md`**（「最新の .mdc 内容が検証に反映される仕組み」）を参照する。
- **`.mdc` の取り込み（Git・プロジェクト側）:** プロジェクトでは **`git submodule update --remote cursor_rules`** や **`dev-start`** などでサブモジュールを最新化すると、**`cursor_rules/.cursor/rules/*.mdc` がリポジトリ上の最新版に置き換わる**（共通ルールのファイルを手元に取り込む。手作業コピーではない）。
- **知見の `.mdc` 反映（開発タスク終了時）:** そのタスクで**うまくいった**エラー対応・デバッグ・単体テストの知見は、**運用ルール上** ①プロジェクト教材 ②共通教材 ③ **`errors-debug-unittest-common.mdc` の【追記用】** に追記する（`.mdc` にも蓄積する）。**Checklist A が自動で追記する**のではなく、**Cursor がチャット終了時に追記する／または人が追記する**（`cursor_instructions_template.md` の 7.3、`errors-debug-unittest-common.mdc` 冒頭のルール）。
- **`spec` の更新（共通リポジトリ側・メンテナンス）:** 共通側で `.mdc` を編集したら **`sync-checklist-a-spec.ps1`** を実行し、**`spec` を `.mdc` に合わせて更新**する（Checklist A がハッシュ照合できるようにするため）。

---

<a id="sec5"></a>
## 用語：「追記先」とは

**追記先** ＝ エラー・デバッグ・単体テストの知見を**どのファイル・どこに書き足すか**（書き足す先）のこと。

- **① プロジェクトの教材**（textbook_01_overview_project.md, textbook_02_tutorial_project.md, textbook_03_debug_project.md, textbook_04_errors_project.md のうち該当）＝ そのプロジェクトの内容・知見の記録。エラー・デバッグ中心なら 03・04、概要・チュートリアルに触れるなら 01・02 に追記する例がある。
- **② 共通の教材**（textbook_01_overview_common.md, textbook_02_tutorial_common.md, textbook_03_debug_common.md, textbook_04_errors_common.md のうち該当）＝ プロジェクトのたびに追記され知見が蓄積される。②には必ず `【出典: リポジトリ名】` を付ける。
- 教材の書き方は `cursor_instructions_template.md` セクション5の「記載の方針（Python 初心者）」に従う。
- **③ errors-debug-unittest-common.mdc** ＝ 同じく知見をためる文書。.mdc 内に【追記用】経験したエラー対応（事例一覧）／【追記用】デバッグの良い方法（事例一覧）／【追記用】単体テストの良い方法（事例一覧）の 3 つの見出しを設け、知見の種類に応じて該当する見出しの下に追記する。③にも `【出典: リポジトリ名】` を付ける。

---

<a id="sec6"></a>
## 付録 A. .mdc の本文（ファイルが存在しない場合の作成用）

cursor_rules の `.cursor/rules/` に .mdc が存在しない場合、以下を元に作成する。フロントマター（--- で囲んだ description, alwaysApply 等）を先頭に付ける。

### A.1 venv-only-common.mdc

```
【常に適用】仮想環境ルール
1. すべての作業は .venv を有効化した状態で行う。python / pip / pyinstaller は .venv 経由で実行する。
2. システムPython（グローバル環境）には何もインストールしない。
3. 誤ってシステムPythonにインストールした場合は、アンインストールして元に戻し、完了を報告する。
```

### A.2 errors-debug-unittest-common.mdc

（経験したエラー対応・デバッグの良い方法・単体テストの良い方法を 3 つに分けて記述。知見は ①プロジェクトの教材 ②共通の教材 ③ errors-debug-unittest-common.mdc の追記用セクション の 3 か所に追記する。③では、知見の種類に応じて【追記用】経験したエラー対応（事例一覧）／【追記用】デバッグの良い方法（事例一覧）／【追記用】単体テストの良い方法（事例一覧）のいずれかの見出しの下に【出典】付きで追記する。②③には【出典: リポジトリ名】を付ける。単体テスト実行方法: pytest / unittest のコマンド例を記載。）

### A.3 post-modification-common.mdc

（デスクトップ: ビルド → README 4 ファイル更新 → 教材 8 ファイル更新。WEB: サーバー再起動 → README 2 ファイル更新 → 教材 4 ファイル更新。ファイル名は 7.1・7.2 の実施手順に同じ。）

### A.4 gui-build-security-common.mdc

（GUI共通ルール・ビルドルール（--onefile）・WEBアプリセキュリティ要件を記載。パスワード認証、バリデーション、SQLインジェクション・XSS・CSRF対策、HTTPS、セッション管理など。）

---

以上がユーザー向け説明である。実施すべき内容はすべて `cursor_instructions_template.md` に記載する。
