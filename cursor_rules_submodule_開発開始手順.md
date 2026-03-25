# cursor_rules サブモジュール：用語・運用・開発開始コマンド

## ① 用語（git subtree / CI で自動更新 PR）

### git subtree とは

別リポジトリの内容を、**親リポジトリのフォルダに「履歴ごと取り込む」**仕組みです。サブモジュールのように「特定コミットへのポインタ」ではなく、**コピーに近いがマージ履歴でつなぐ**イメージです。

| | サブモジュール | git subtree |
|--|----------------|-------------|
| 中身の置き場 | 別リポジトリ（親はコミット ID のみ記録） | 親リポジトリのツリーに取り込む |
| 更新 | `git submodule update --remote` 等 | `git subtree pull` 等（別手順） |
| よくある用途 | 共通ライブラリを複数プロジェクトで共有 | ツールを1リポジトリに統合したいとき |

あなたの運用（`cursor_rules` を複数プロジェクトで**同じリポジトリを参照**）では、**サブモジュールのまま**が一般的です。subtree は「別の選択肢」であり、**常に最新に追従する特別なスイッチがあるわけではありません**。

### CI で自動更新 PR 作成とは

**CI**（継続的インテグレーション：GitHub Actions など）で、定期的または `cursor_rules` 更新時に次を自動で行う運用です。

1. 親リポジトリをクローンし、`git submodule update --remote cursor_rules` でサブモジュールを最新にする  
2. 親リポジトリに「記録されるコミット ID の変更」が出るので、その差分を **Pull Request として自動作成**する  

効果は「**常に自動で最新になる**」ではなく、「**最新への更新を人が忘れない／レビュー付きで取り込める**」ことです。親リポジトリに記録されるのは結局 **ある時点のコミット** のままです。

---

## ② 「常に最新」について（再掲）

Git のサブモジュールに、**親を変えずに常に追跡ブランチの先端だけを指し続ける公式オプションはありません**。  
実務では次のどちらかです。

- **手動・スクリプト:** `git submodule update --remote cursor_rules` を決まったタイミングで実行し、必要なら親リポジトリにその結果をコミットする  
- **CI:** 上記を自動化し PR にする  

---

## ③ 開発開始コマンド1本（PowerShell）

共通リポジトリ（cursor_rules）に同梱のスクリプトを使うか、内容をプロジェクト側にコピーして使います。

**配置例（サブモジュール利用時）:**

`your_project/cursor_rules/scripts/dev-start-cursor-rules.ps1`

**実行例（親リポジトリのルートで）:**

```powershell
cd D:\pyscript\tool\py_tool_daily_report
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1
```

- `cd ...`: 作業対象プロジェクト（親リポジトリ）のルートへ移動します。サブモジュールの操作は**親リポジトリのルート**で行うのが基本です。
- `powershell -ExecutionPolicy Bypass -File ...`: `.ps1`（PowerShellスクリプト）を実行します。`ExecutionPolicy` はPCのポリシーでスクリプト実行がブロックされるケースがあるため、**この実行だけ一時的に制限を回避**します（システム設定を恒久変更しません）。
- `dev-start-cursor-rules.ps1` が内部でやること:
  - `git submodule update --init --recursive`（未取得/未初期化のサブモジュールを取る）
  - `git submodule update --remote cursor_rules`（必要なら共通をリモート最新に近づける。親に差分が出る場合あり）

**リモート最新まで上げず、取得だけ（clone 直後など）:**

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1 -SkipRemote
```

- `-SkipRemote`: `--remote` 更新を**行わない**オプションです。まずは「サブモジュールの中身を取るだけ」にしたい場合（clone 直後、まず動作確認したい場合）に使います。

**別パスを明示:**

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1 -ProjectRoot "D:\pyscript\tool\py_tool_daily_report"
```

- `-ProjectRoot "..."`
  - スクリプトを別フォルダから実行するときに「親リポジトリのルート」を明示します。
  - 省略すると「今いるフォルダ（カレント）」を親リポジトリのルートとして扱います。

---

## Pattern ①：サブモジュール未設定のリモートを clone → 手元で `submodule add` して開発

**前提:** リモートに `.gitmodules` がまだない。

1. プロジェクトを clone し、ルートに移動する。  
   `git clone https://github.com/jinen3/py_tool_daily_report.git`  
   `cd py_tool_daily_report`

- `git clone <URL>`: GitHub のリポジトリをPCにコピー（クローン）します。ここでは**親リポジトリ（プロジェクト本体）**を取得します。
- `cd ...`: 取得したプロジェクトのフォルダ（親リポジトリのルート）へ移動します。

2. サブモジュールを追加する（**既に `cursor_rules` という名前の通常フォルダがあると失敗**するので、空でない場合は退避または削除）。  
   `git submodule add https://github.com/jinen3/cursor_rules.git cursor_rules`

- `git submodule add <URL> <path>`: 親リポジトリの配下（ここでは `cursor_rules`）に、別リポジトリ（共通の `cursor_rules`）を**サブモジュールとして登録**します。
  - 登録されるもの: `.gitmodules`（設定ファイル）と、親リポジトリ側の「サブモジュールが指すコミットID」という情報
  - 注意: `cursor_rules` という**通常フォルダが既に存在**すると失敗します。これは「その場所をサブモジュールの作業ツリーとして使う」ためです。

3. コミットして push する。  
   `git add .gitmodules cursor_rules`  
   `git commit -m "Add cursor_rules submodule"`  
   `git push`

- `git add ...`: 変更を「コミット対象」として登録します。ここでは「サブモジュール設定」と「サブモジュール参照（ポインタ）」をステージします。
  - `.gitmodules`: サブモジュールのURLと配置パスが書かれます
  - `cursor_rules`: 中身の全ファイルをコミットするのではなく、基本的に「どのコミットを指すか」という参照情報が入ります
- `git commit -m "..."`: 変更を履歴として確定します（ローカルのコミット）。
- `git push`: GitHub にコミットを送ります。これをしないと、他PC/他メンバーが clone しても「サブモジュール設定済み」になりません。

4. **以降の作業開始のたび（共通を最新に近づけたいとき）:** 上記「開発開始コマンド1本」を実行する。  
   - 親リポジトリに「指すコミットが変わった」差分が出たら、方針に従いコミットする。

- `git submodule update --remote cursor_rules` を実行すると、親リポジトリから見て「cursor_rules が指すコミットID」が変わる場合があります。その場合、親リポジトリで `git status` を見ると差分として出ます。
  - その差分をコミットして push すると、チーム全員が「この時点の cursor_rules」を再現できます。
  - コミットしない場合、あなたのPCでは更新されても、リモートや他PCには共有されません（運用方針に合わせて判断します）。

**補足:** `D:\pyscript\cursor_rules` に既にある独立クローンは**そのまま残してよい**。サブモジュール用は **各プロジェクト直下の `cursor_rules`** として別に clone される（Git が管理）。

---

## Pattern ②：サブモジュール設定済みリポジトリを clone し直す

**前提:** リモートに `.gitmodules` と `cursor_rules` の登録済み。

1. サブモジュールごと取得して clone する。  
   `git clone --recurse-submodules https://github.com/jinen3/py_tool_daily_report.git`  
   `cd py_tool_daily_report`

   通常の `git clone` だけした場合は続けて:  
   `git submodule update --init --recursive`

- `git clone --recurse-submodules <URL>`: 親リポジトリを clone すると同時に、`.gitmodules` に書かれたサブモジュールも**自動で取得**します。Pattern②の最短です。
- `git submodule update --init --recursive`: すでに clone 済みの親リポジトリに対して、サブモジュールを取得します。
  - `--init`: 初回（未初期化）のサブモジュールを初期化して取得します
  - `--recursive`: サブモジュールの中にさらにサブモジュールがある場合も追って取得します

2. **共通を最新に近づけたいとき:** 上記「開発開始コマンド1本」を実行する（`--remote` まで行う版）。

- clone 直後は「親が記録しているコミット」に揃うだけで、**常に最新にはなりません**。必要に応じて `git submodule update --remote cursor_rules`（またはスクリプト）で更新します。

---

## コピペ用：dev-start-cursor-rules.ps1 全文

サブモジュールをまだ置いていない段階では、共通リポジトリを参照できないため、次をプロジェクトルートに `dev-start-cursor-rules.ps1` として保存して使っても構いません（`cursor_rules` 同梱の `scripts/dev-start-cursor-rules.ps1` と同一内容です）。

```powershell
#Requires -Version 5.1
<#
.SYNOPSIS
  プロジェクト作業開始時: cursor_rules サブモジュールを取得し、必要ならリモート最新へ更新する。
#>
param(
    [string]$ProjectRoot = "",
    [string]$SubmodulePath = "cursor_rules",
    [switch]$SkipRemote
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = (Get-Location).Path
}
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot ".git"))) {
    throw "Git リポジトリのルートではありません: $ProjectRoot"
}

Set-Location -LiteralPath $ProjectRoot

Write-Host "== [1/2] submodule init (取得・未初期化の解消) ==" -ForegroundColor Cyan
git submodule update --init --recursive

$gitmodules = Join-Path $ProjectRoot ".gitmodules"
if (-not (Test-Path -LiteralPath $gitmodules)) {
    Write-Warning ".gitmodules がありません。先に Pattern① で git submodule add を実行してください。"
    exit 1
}

$subStatus = git submodule status $SubmodulePath 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($subStatus)) {
    Write-Warning "サブモジュール '$SubmodulePath' が見つかりません。.gitmodules の path を確認してください。"
    exit 1
}

if ($SkipRemote) {
    Write-Host "SkipRemote 指定のため、リモート最新への更新は行いません。" -ForegroundColor Yellow
} else {
    Write-Host "== [2/2] submodule update --remote ($SubmodulePath) ==" -ForegroundColor Cyan
    git submodule update --remote $SubmodulePath
}

Write-Host "`n== submodule status ==" -ForegroundColor Green
git submodule status

Write-Host "`n親リポジトリで cursor_rules の指すコミットが変わった場合は、git status で確認し、チーム方針に従いコミットしてください。" -ForegroundColor DarkGray
```

---

## 参考

- 共通ルール本文: `cursor_instructions_template.md` のセクション 1、7.6、8  
- サブモジュールの更新コマンド: `git submodule update --remote cursor_rules`
