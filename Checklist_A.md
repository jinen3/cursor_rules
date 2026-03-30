## 目次

- [Checklist A（統合チェック）とは](#sec1)
- [チェック項目（日本語）](#sec2)
- [実行方法（1クリック）](#sec3)
- [失敗したとき（自動でやり直す方針）](#sec4)
- [手動確認が必要になる条件（WEBのみ）](#sec5)

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
