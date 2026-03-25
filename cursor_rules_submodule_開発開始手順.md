# cursor_rules サブモジュール：開発開始手順（初心者向け）

この文書は「`cursor_rules` をサブモジュールで運用するとき」に、**何をどの順番で打てばよいか**を、なるべくやさしく説明します。

## 最初にこれだけ覚える（初心者向けの覚え方）

- **最初の1回だけ（プロジェクトにサブモジュール設定が無いとき）**：⑥ Pattern①（サブモジュール登録を作って GitHub に保存）
- **ふだん毎回（開発を始めるとき）**：⑤ の「開発開始スクリプト」を **1回実行**（サブモジュール取得と、必要なら更新まで）
- **共有したい更新が出たら**：④の手順1〜4（`git status` → `git add cursor_rules` → `git commit` → `git push`）

⑤のスクリプトは「開発開始時の定番コマンド」をまとめて実行するためのものです（詳細は⑤）。

---

## ① まず結論（サブモジュールは「常に最新」ではない）

サブモジュールは、親リポジトリがサブモジュールを **ブランチではなく「特定のコミットID」**で記録します。

- GitHub で `cursor_rules @ 3aff711` と表示される = 親リポジトリが「`cursor_rules` は **3aff711** を使う」と決めている

そのため、**何もしないと固定のまま**です。必要なタイミングで「最新へ上げる」作業をします。

---

## ② コミットIDと「参照情報（ポインタ）」の違い（やさしい説明）

### コミットIDとは（cursor_rules 側の番号）

`3aff711` のような文字列は、`cursor_rules` リポジトリの **ある時点のスナップショット番号**です。

- **コミットID**: 「`cursor_rules` の状態を一意に表す番号」

### 参照情報（ポインタ）とは（親が覚えている“指し先”）

親リポジトリ（例: `py_tool_daily_report`）は、サブモジュールを
**“cursor_rules はこのコミットIDを使う”** という情報で持ちます。

- **参照情報（ポインタ）**: 「親が、サブモジュールとして **どのコミットIDの cursor_rules を使うか** を覚えている情報」

例え：

- **コミットID** = 本の「版（第◯版）」や「ページ番号」（`cursor_rules` 側の番号）
- **ポインタ** = しおり（親が「この版を使う」と決めている）

---

## ③ `git submodule update --remote cursor_rules` で「最新にする」とは？

これは一言でいうと、

> 親リポジトリが指している `cursor_rules` のコミットID（ポインタ）を、より新しいコミットに **付け替える**こと

です。

### `git submodule add` の時点で親が覚えているもの

親リポジトリは、サブモジュールを **“ブランチ” ではなく “特定のコミットID”** で記録します。

- GitHub の表示 `cursor_rules @ 3aff711` = 「親が 3aff711 を指している」

### `git submodule update --remote cursor_rules` がやること

サブモジュール `cursor_rules` の **追跡ブランチ（通常は `origin/main`）** の先端コミットを取りに行き、
親が指すコミットID（= ポインタ）を **より新しいコミット** に更新します。

つまり、**親リポジトリが参照する `cursor_rules` の内容を、リモート最新に近い状態へ更新する**ということです。

重要：これはまず **あなたのPC上**で起きる変更です。GitHub 上の親リポジトリには自動反映されません。

---

## ④ 「最新にした状態」を他人/別PCに共有する（重要：手順1〜4）

`git submodule update --remote cursor_rules` を実行すると、親リポジトリ側では
「`cursor_rules` の参照先コミットが変わった」という差分になります。

そのため、共有したい場合は **親リポジトリで commit/push が必要**です。

### 1) `git status`（何が変わったか見る）

親リポジトリのルートで `git status` を見ると、だいたいこんな表示になります。

```text
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   cursor_rules (new commits)
```

`modified: cursor_rules (new commits)` は、
「`cursor_rules` の**中身ファイルが編集された**というより、親が指してる**コミットID（ポインタ）が変わった**」
という意味です。

### 2) `git add cursor_rules`（“参照先コミットが変わった”をステージする）

`git add cursor_rules` は、`cursor_rules` フォルダの中身を親にコピーするのではなく、
親リポジトリにある **参照先コミットIDの変更（ポインタの付け替え）** を「コミット対象」に乗せます。

### 3) `git commit -m "..."`（参照先コミットの更新を確定）

これで親リポジトリの履歴に、

> 「cursor_rules の参照先を新しいコミットに更新した」

という記録が残ります。

### 4) `git push`（GitHub に送る＝他人/別PCと共有）

push して初めて GitHub 上の親リポジトリも更新され、他人や別PCが clone したときに

- **同じ新しいコミットを参照する `cursor_rules`**

を再現できます。

### よくある誤解

- 誤解: `git submodule update --remote` したから、GitHub の親リポジトリも自動で最新参照になる  
  実際: それは **あなたのPCだけ**。共有したいなら **親で commit/push** が必要
- 誤解: `git add cursor_rules` は `cursor_rules` の中身を親に取り込む  
  実際: 親が記録するのは基本的に **“サブモジュールが指すコミットID（ポインタ）”** だけ

---

## ⑤ まずはこれだけ：開発開始スクリプト（1回実行）

ここが初心者向けの一番大事なところです。

この文書では、**開発を始めるときに “毎回やりたい操作” を 1回でまとめて実行するスクリプト**を用意しています。

- 実行した結果「親リポジトリの差分（cursor_rules の参照先が変わった）」が出たら、**共有したいときは commit/push が別途必要**です（④の手順1〜4）

このスクリプトは、やっていることを隠して魔法をかけるのではなく、**毎回の定番コマンドを順番に実行してくれるだけ**です。

### 【質問1】「毎回の定番コマンド」って具体的に何？

この2つです（スクリプトが自動で順番に実行します）。

1) `git submodule update --init --recursive`  
2) `git submodule update --remote cursor_rules`（※ `-SkipRemote` を付けたときは実行しません）

#### 1) `git submodule update --init --recursive`（未取得/未初期化を解消＝中身を取る）

サブモジュールは「設定だけあるが中身がまだ無い」状態になりがちです。たとえば次のケースです。

- ふつうの `git clone` をして、サブモジュールの取得をまだしていない
- `.gitmodules` はあるが、`cursor_rules` フォルダの中身が空っぽ/未取得

こういう状態をこのコマンドで直します。

- **未取得**：サブモジュールの中身（cursor_rules のファイル群）をまだダウンロードしていない状態
- **未初期化（未init）**：サブモジュールとして使う準備（URL/パスに従って取得する準備）がまだできていない状態

`--init` は「未初期化なら初期化もやる」、`--recursive` は「もし入れ子のサブモジュールがあっても追って取る」です。

#### 2) `git submodule update --remote cursor_rules`（必要なら“最新に近づける”）

これは **親リポジトリが指している cursor_rules のコミットID（ポインタ）**を、より新しいコミットに付け替える操作です。

その結果、親リポジトリ側で「cursor_rules の参照先が変わった」という差分が出ることがあります（④で説明した `modified: cursor_rules (new commits)` など）。

### 配置例（サブモジュール利用時）

`your_project/cursor_rules/scripts/dev-start-cursor-rules.ps1`

### 実行例（親リポジトリのルートで）

```powershell
cd D:\pyscript\tool\py_tool_daily_report
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1
```

- `cd ...`: 作業対象プロジェクト（親リポジトリ）のルートへ移動します。サブモジュールの操作は**親リポジトリのルート**で行うのが基本です。
- `powershell -ExecutionPolicy Bypass -File ...`: `.ps1`（PowerShellスクリプト）を実行します。`ExecutionPolicy` はPCのポリシーでスクリプト実行がブロックされるケースがあるため、**この実行だけ一時的に制限を回避**します（システム設定を恒久変更しません）。
- `dev-start-cursor-rules.ps1` が内部でやること:
  - `git submodule update --init --recursive`（未取得/未初期化のサブモジュールを取る）
  - `git submodule update --remote cursor_rules`（必要なら共通をリモート最新に近づける。親に差分が出る場合あり）

### これを実行したあとの「次の一手」

### 【質問2】「差分が出たかどうか」はどう確認するの？

一番わかりやすいのは、親リポジトリのルートで `git status` を見ることです。

- **差分が無い例**：`nothing to commit, working tree clean`（= 参照先は変わっていない）
- **差分がある例**：`modified: cursor_rules (new commits)`（= 参照先が変わった）

この文書の④に、表示例を載せています。

---

**差分が出なければ**：それで準備OKです（親が指す cursor_rules は変わっていません）  
**差分が出たら**：あなたのPCで cursor_rules の参照先（ポインタ）が動きました  
  - **自分だけで使う**なら、そのまま作業してOK  
  - **他人/別PCにも同じ状態にしたい**なら、④の手順どおりに `git add cursor_rules` → `git commit` → `git push` します

### リモート最新まで上げず、取得だけ（clone 直後など）

### 【質問3】「取得だけ」ってどういうこと？

ここでいう「取得だけ」は **“サブモジュールの中身を取る（未取得/未初期化を解消する）だけ”** で、
**参照先コミット（ポインタ）を最新へ付け替えるところまではやらない**、という意味です。

具体的には：

- やる：`git submodule update --init --recursive`（中身を取って、親が指している状態に揃える）
- やらない：`git submodule update --remote cursor_rules`（最新へ付け替える）

clone 直後はまず「親が記録しているコミットに揃える」だけにして、動作確認してから更新したい場合があります。そのときに `-SkipRemote` を使います。

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1 -SkipRemote
```

- `-SkipRemote`: `--remote` 更新を**行わない**オプションです。まずは「サブモジュールの中身を取るだけ」にしたい場合（clone 直後、まず動作確認したい場合）に使います。

### 別パスを明示

### 【質問4】「別パスを明示」ってどういうこと？

このスクリプトは、通常「親リポジトリのルートで実行」します。  
でも、たとえば次のように **別のフォルダからスクリプトを実行したい**ことがあります。

- 今いる場所（カレント）が親リポジトリのルートではない
- いくつもプロジェクトがあり、実行したいプロジェクトを明示したい

そのときに `-ProjectRoot` で「対象プロジェクトのルート」を指定します。

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1 -ProjectRoot "D:\pyscript\tool\py_tool_daily_report"
```

- `-ProjectRoot "..."`
  - スクリプトを別フォルダから実行するときに「親リポジトリのルート」を明示します。
  - 省略すると「今いるフォルダ（カレント）」を親リポジトリのルートとして扱います。

---

## ⑥ Pattern ①：最初の1回だけ（サブモジュール設定がまだ無いプロジェクト）

**いつ使う？**  
GitHub 上のプロジェクトに、まだ `.gitmodules` が無い（= まだサブモジュールとして登録されていない）ときに使います。

**前提:** リモートに `.gitmodules` がまだない。

1. プロジェクトを clone し、ルートに移動する。  
   `git clone https://github.com/jinen3/py_tool_daily_report.git`  
   `cd py_tool_daily_report`

- `git clone <URL>`: GitHub のリポジトリをPCにコピー（クローン）します。ここでは**親リポジトリ（プロジェクト本体）**を取得します。
- `cd ...`: 取得したプロジェクトのフォルダ（親リポジトリのルート）へ移動します。

2. サブモジュールを追加する（**親リポジトリのルート直下に `cursor_rules` という名前の通常フォルダが既にあると失敗**します。空でない場合は退避または削除）。  
   `git submodule add https://github.com/jinen3/cursor_rules.git cursor_rules`

- `git submodule add <URL> <path>`: 親リポジトリの配下（ここでは `cursor_rules`）に、別リポジトリ（共通の `cursor_rules`）を**サブモジュールとして登録**します。
  - 登録されるもの: `.gitmodules`（設定ファイル）と、親リポジトリ側の「サブモジュールが指すコミットID」という情報
  - 注意: **親リポジトリのルート直下に `cursor_rules` という名前の通常フォルダが既にあると失敗**します。これは「その場所をサブモジュールの作業ツリーとして使う」ためです。

3. コミットして push する。  
   `git add .gitmodules cursor_rules`  
   `git commit -m "Add cursor_rules submodule"`  
   `git push`

- `git add ...`: 変更を「コミット対象」として登録します。ここでは「サブモジュール設定」と「サブモジュール参照（ポインタ）」をステージします。
  - `.gitmodules`: サブモジュールのURLと配置パスが書かれます
  - `cursor_rules`: 中身の全ファイルをコミットするのではなく、基本的に「どのコミットを指すか」という参照情報が入ります
- `git commit -m "..."`: 変更を履歴として確定します（ローカルのコミット）。
- `git push`: GitHub にコミットを送ります。これをしないと、他PC/他メンバーが clone しても「サブモジュール設定済み」になりません。

4. **以降の作業開始のたび（共通を最新に近づけたいとき）:** 上記⑤の「開発開始スクリプト」を実行する。  
   - 親リポジトリに「指すコミットが変わった」差分が出たら、方針に従いコミットする。

- `git submodule update --remote cursor_rules` を実行すると、親リポジトリから見て「cursor_rules が指すコミットID」が変わる場合があります。その場合、親リポジトリで `git status` を見ると差分として出ます。
  - その差分をコミットして push すると、チーム全員が「この時点の cursor_rules」を再現できます。
  - コミットしない場合、あなたのPCでは更新されても、リモートや他PCには共有されません（運用方針に合わせて判断します）。

**補足:** `D:\pyscript\cursor_rules` に既にある独立クローンは**そのまま残してよい**。サブモジュール用は **各プロジェクト直下の `cursor_rules`** として別に clone される（Git が管理）。

---

## ⑦ Pattern ②：ふだんはこれ（サブモジュール設定済みのプロジェクトを clone するだけ）

**いつ使う？**  
Pattern①を誰かが既にやって、GitHub 上のプロジェクトに `.gitmodules` がある（= サブモジュール登録済み）場合です。  
あなたがPCを変えたり、ローカルを消して clone し直すときもここです。

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

2. **共通を最新に近づけたいとき:** 上記⑤の「開発開始スクリプト」を実行する（`--remote` まで行う版）。

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
