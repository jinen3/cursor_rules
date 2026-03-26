## 目次

- [Checklist A（統合チェック）とは](#sec1)
- [チェック項目（日本語）](#sec2)
- [実行方法（1クリック）](#sec3)
- [失敗したとき（自動でやり直す方針）](#sec4)

---

<a id="sec1"></a>
## Checklist A（統合チェック）とは

**目的**：依頼対応の「すり抜け」を潰す。  
**禁止**：チェックだけして「完了」と言うこと（実行せずに完了扱い）。  

Checklist A は、`cursor_rules` の 6本の `.mdc` に書かれている「変更後に必ずやる」を **1つの実行**にまとめたものです。

---

<a id="sec2"></a>
## チェック項目（日本語）

1. `cursor_rules` サブモジュールが存在し、中身が取得されている
2. 必須の 6本 `.mdc` が揃っている（`<プロジェクトルート>\cursor_rules\.cursor\rules\`）
   - `venv-only-common.mdc`
   - `errors-debug-unittest-common.mdc`
   - `post-modification-common.mdc`
   - `gui-build-security-common.mdc`
   - `markdown-common.mdc`
   - `update-management-common.mdc`
3. Markdown 目次ルール（全 `**/*.md`）
   - **自動修正（fix）**：目次が無い/壊れている `.md` は、バックアップ（`.bak.<日時>`）を作ってから自動で付与する
   - **再チェック（check）**：fix の後にもう一度チェックし、通ること
4. 単体テスト（プロジェクトに `tests/` がある場合）
   - `.venv` と `tests/` があるなら、`pytest` → 失敗時 `unittest` を実行して通す
   - 無い場合は SKIP（ただし、テストが必要な修正なら `tests/` を用意する）

## 実際に何を検証するか（6本 .mdc）

- **存在チェックだけではない。** 各 `.mdc` の中身まで検証する。
- 例:
  - `venv-only-common.mdc`: `.venv` / `システムPython` / Checklist A 文言があるか
  - `errors-debug-unittest-common.mdc`: `単体テスト` / `pytest` / `unittest` / Checklist A 文言があるか
  - `post-modification-common.mdc`: `修正完了後の標準手順` / Checklist A 文言があるか
  - `gui-build-security-common.mdc`: `WEBアプリ セキュリティ要件` / `0.0.0.0` 制約 / Checklist A 文言があるか
  - `markdown-common.mdc`: `目次` / `check: markdown toc (project)` / `fix: markdown toc (project)` / Checklist A 文言があるか
  - `update-management-common.mdc`: 共通更新セクション / Checklist A 文言があるか
- frontmatter も検証する:
  - `markdown-common.mdc` は `globs: "**/*.md"` と `alwaysApply: false`
  - それ以外 5本は `alwaysApply: true`

---

<a id="sec3"></a>
## 実行方法（1クリック）

`ターミナル(T)` → `タスクの実行…` → **`run: checklist A (all rules)`**

---

<a id="sec4"></a>
## 失敗したとき（自動でやり直す方針）

- Checklist A が失敗したら、**原因を直して、同じタスクをもう一度実行**します。
- 「チェック漏れました」の報告は不要で、**漏れない仕組み（Checklist A）を通るまで回す**運用にします。

