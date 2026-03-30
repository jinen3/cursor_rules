## 目次

- [概要（一目で）](#sec-overview)
- [Checklist A（統合チェック）とは](#sec1)
- [チェック項目（日本語）](#sec2)
- [実行方法（1クリック）](#sec3)
- [失敗したとき（自動でやり直す方針）](#sec4)
- [手動確認が必要になる条件（WEBのみ）](#sec5)
- [実行タイミング（いつ実行するか）](#sec-timing)
- [最新の .mdc 内容が検証に反映される仕組み](#sec-fresh)
- [`git submodule update` だけで `.vscode/tasks.json` は揃うか](#sec-tasks-vs-sub)
- [エージェントが Checklist A を実行しなかった理由](#sec-why-skip-agent)
- [Checklist A は Cursor 上で「強制」できるか](#sec-enforcement)

---

<a id="sec-overview"></a>
## 概要（一目で）

- **開発タスク（依頼対応）が一区切りついたあと・完了報告の前**に、**Checklist A を必ず通す**運用とする。Cursor（エージェント）は共通ルールに従い、可能な限り **`run: checklist A (all rules)` を実行してから**完了報告する（**手動でタスクを実行する**必要がある場合もある）。
- 一度走らせると、スクリプトが **各 `.mdc` の本文まで**（`spec` のハッシュ一致）と、ポリシーに沿った **ランタイム検証**を **機械的に**行う（人の目視チェックリストではない）。
- Checklist A が **失敗したら**、原因を直し、**同じタスクをもう一度実行**する。**漏れない仕組み（Checklist A）を通るまで**回す。
- **WEB実装が検出されたプロジェクトだけ**、一部ルールについて **手動確認**を要求する。デスクトップなど **非WEB** は **out of scope** とし、**自動チェックのみ**で当該手動項目は完了扱い。
- **実行（1クリック）:** `ターミナル(T)` → `タスクの実行…` → **`run: checklist A (all rules)`**

---

<a id="sec1"></a>
## Checklist A（統合チェック）とは

**目的**：依頼対応の「すり抜け」を潰す。  
**禁止**：チェックだけして「完了」と言うこと（実行せずに完了扱い）。  

Checklist A は、`cursor_rules` の **7本**の `.mdc`（領域別 6 本 + **Checklist A 統合**の `checklist-a-all-rules-common.mdc`）に書かれている「変更後に必ずやる」を **1つの実行**にまとめたものです。

---

<a id="sec2"></a>
## チェック項目（日本語）

1. `cursor_rules` サブモジュールが存在し、中身が取得されている
2. 必須の 7本 `.mdc` が揃っている（`<プロジェクトルート>\cursor_rules\.cursor\rules\`）
   - `venv-only-common.mdc`
   - `errors-debug-unittest-common.mdc`
   - `post-modification-common.mdc`
   - `gui-build-security-common.mdc`
   - `markdown-common.mdc`
   - `update-management-common.mdc`
   - `checklist-a-all-rules-common.mdc`
3. Markdown 目次ルール（全 `**/*.md`）
   - **自動修正（fix）**：目次が無い/壊れている `.md` は、バックアップ（`.bak.<日時>`）を作ってから自動で付与する
   - **再チェック（check）**：fix の後にもう一度チェックし、通ること
4. 単体テスト（プロジェクトに `tests/` がある場合）
   - `.venv` と `tests/` があるなら、`pytest` → 失敗時 `unittest` を実行して通す
   - 無い場合は SKIP（ただし、テストが必要な修正なら `tests/` を用意する）

## 実際に何を検証するか（7本 .mdc）

- **存在チェックだけではない。** 各 `.mdc` の中身まで検証する。
- 例:
  - `venv-only-common.mdc`: `.venv` / `システムPython` / Checklist A 文言があるか
  - `errors-debug-unittest-common.mdc`: `単体テスト` / `pytest` / `unittest` / Checklist A 文言があるか
  - `post-modification-common.mdc`: `修正完了後の標準手順` / Checklist A 文言があるか
  - `gui-build-security-common.mdc`: `WEBアプリ セキュリティ要件` / `0.0.0.0` 制約 / Checklist A 文言があるか
  - `markdown-common.mdc`: `目次` / `check: markdown toc (project)` / `fix: markdown toc (project)` / Checklist A 文言があるか
  - `update-management-common.mdc`: 共通更新セクション / Checklist A 文言 / `CHECKLIST_A_POLICY` があるか
  - `checklist-a-all-rules-common.mdc`: Checklist A が **全共通 `.mdc` の順守**を担う旨が書かれているか
- frontmatter も検証する:
  - `markdown-common.mdc` は `globs: "**/*.md"` と `alwaysApply: false`
  - それ以外 6本は `alwaysApply: true`

---

<a id="sec3"></a>
## 実行方法（1クリック）

`ターミナル(T)` → `タスクの実行…` → **`run: checklist A (all rules)`**

---

<a id="sec4"></a>
## 失敗したとき（自動でやり直す方針）

- Checklist A が失敗したら、**原因を直して、同じタスクをもう一度実行**します。
- 「チェック漏れました」の報告は不要で、**漏れない仕組み（Checklist A）を通るまで回す**運用にします。

---

<a id="sec5"></a>
## 手動確認が必要になる条件（WEBのみ）

- `sec.use_safe_runtime_context` の手動確認は、`update-management-common.mdc` の `manualReviewScope: "web_only"` に従います。
- つまり、**WEB実装が検出されたプロジェクトだけ**手動確認を要求します。
- デスクトップアプリなど **非WEBプロジェクトでは対象外（out of scope）** として扱い、Checklist A は自動チェックのみで完了します。
- 判定は「ユーザーが言ったから」ではなく、プロジェクト実コードの機械判定で行います。

---

<a id="sec-timing"></a>
## 実行タイミング（いつ実行するか）

- **運用の正:** 依頼対応の作業が一区切りついた **あと**、**完了報告の前**に Checklist A を通す。
- **Cursor（エージェント）**は、共通ルールに従い、可能な限り **`run: checklist A (all rules)` を実行してから**完了報告する。
- **IDE がチャット終了を検知して自動でスクリプトを起動する**わけではない。エージェントが実行できない状況では、**ユーザーが同じタスクを手動で実行**する（上記「実行方法（1クリック）」）。

---

<a id="sec-fresh"></a>
## 最新の .mdc 内容が検証に反映される仕組み

- **はい（前提を満たせば）。** Checklist A は、プロジェクト内の **`cursor_rules` サブモジュール**にある **実ファイル**（`.cursor/rules/*.mdc`）と、同梱の **`spec/checklist_a_requirements.json`** の **SHA-256** を照合する。
- **共通側で `.mdc` を編集したら** `sync-checklist-a-spec.ps1` で `spec` を更新し、push したうえで、各プロジェクトは **`git submodule update --remote cursor_rules`** などで **手元のサブモジュールを最新にする**こと。古いサブモジュールのままでは、GitHub 上の最新ルールは手元に来ない。
- `.mdc` を変えたのに `spec` を更新していないと、Checklist A は **FAIL（mdc changed but spec not synced）** になる。これにより「最新のルール本文」と「記録されているハッシュ」がずれないようになっている。

---

<a id="sec-tasks-vs-sub"></a>
## `git submodule update` だけで `.vscode/tasks.json` は揃うか

- **いいえ（別対応）。** `git submodule update --init --recursive` や `git submodule update --remote cursor_rules` は、**サブモジュール内**（`cursor_rules/` 以下）のスクリプトと `.mdc` を最新にする。**親リポジトリの `.vscode/tasks.json` は書き換えない**。
- Checklist A の **タスク配線**（`upd.checklist_task_wired`）は、親の **`tasks.json` に `requiredTaskLabels` と一致する `label` があるか**で検証する。正は **`cursor_rules/templates/vscode_tasks.tasks.json.example`**。**`setup-tasks-link.ps1`**（開発開始手順の B-2）でこのテンプレにリンクするか、同じラベルを手で追記する。
- **共通リポジトリ（cursor_rules）**では、`check: cursor_rules sanity` が **テンプレに必須ラベルがすべて含まれるか**も検証する（テンプレとポリシーの乖離を防ぐ）。

---

<a id="sec-why-skip-agent"></a>
## エージェントが Checklist A を実行しなかった理由

- **「ルールに書いてないから」ではない。** §1.1・各 `.mdc` に、完了報告の前に Checklist A を実行しとある。
- **典型的な抜け:** ① **エディタは自動でチェックを起動しない**（手順またはタスクで明示実行が必要）② **pytest のみ等で「十分」と誤結論**（Checklist A は別物：.mdc ハッシュ、TOC、タスク配線、サブモジュール等の統合）③ **エージェントの一貫性**（毎ターンで必ず実行する保証はない）。
- **対策:** Cursor（エージェント）は **完了報告の直前に** `run-checklist-a.ps1` を実行し、**exit code またはログ要約をチャットに書く**（`cursor_instructions_template.md` §1.1「Cursor（エージェント）の完了報告ゲート」）。

---

<a id="sec-enforcement"></a>
## Checklist A は Cursor 上で「強制」できるか

- **完全な強制（チャット送信や完了報告をブロックする OS／エディタ機能）はない。** 「Checklist A 未実行なら送信不可」といった仕組みは Cursor 標準にはない。
- **機械的に効くもの:** ① **`run-checklist-a.ps1` を実行した結果が FAIL** なら、その時点では **ルール上「作業完了」と言えない**（スクリプトが exit code 非ゼロ）② **CI（例：GitHub Actions）で同スクリプトを走らせ、FAIL ならマージ不可**にすれば、リポジトリ単位では **かなり強い拘束**になる（要：ワークフロー設定）。
- **それ以外:** ルール文書・§1.1 の「完了報告ゲート」は **運用とエージェントの遵守**に依存する。**pytest だけでは代替にならない**ことは、スクリプト側の検証内容が別物だからである。

- **テンプレ配布（推奨）:** `cursor_rules` には Checklist A を実行する GitHub Actions のテンプレがある。各プロジェクトで次を1回実行し、`.github/workflows/checklist-a.yml` をコミットして branch protection で required にすると、**実質的に「必ず実行」**に近づく。

```powershell
cd <プロジェクトルートに置き換え>
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\setup-ci-checklist-a.ps1
```
