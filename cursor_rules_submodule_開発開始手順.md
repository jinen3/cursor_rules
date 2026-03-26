# cursor_rules サブモジュール：開発開始手順（初心者向け）

---

## 毎日ここだけ見る（入口はこの文書1本）

**方針：** 下に書いた **A →（足りなければ B-1〜B-3）→ また A** だけで完結する。別ページを探さない。

---

### まず概要（表）

| いつ | 章 | 目的 | 手法 | 手順 | やること | 備考 | 参考 |
|---|---|---|---|---|---|---|---|
| 毎回 | **A 1** | サブモジュール最新化 | Cursor機能（タスク実行） | ターミナル(T) → タスクの実行… → **`dev-start (cursor_rules submodule)`** 選択実行<br>**【警告】`dev-start (submodule init only / SkipRemote)` を選ぶと「最新化」はされません（取得だけ）。** | dev-start（サブモジュールの中身を取得＋最新化）をclick実行 | サブモジュール（=ルール）を最新化。 | B-2,B-1 |
| 毎回 | **A 1（中身）** | サブモジュール取得＋更新（コマンド） | コマンドライン（Ctrl+SHIFT+@） | `git submodule update --init --recursive`（未取得/未初期化を解消）<br>`git submodule update --remote cursor_rules`（必要ならリモート最新へ更新）<br><br>（短縮コマンド）`git submodule update --init --remote --recursive cursor_rules` | サブモジュールを取得＋更新 | GithHubからサブモジュールの中身を取得して、更新(最新に)<br><br>（短縮コマンドのメリット）短い・コピペしやすい<br>（短縮コマンドのデメリット）何が起きたか分かりにくい（init/remote の切り分けがしづらい）<br><br>（共有したい時の定型コミット文言）`Update cursor_rules submodule pointer` | ー |
| 毎回 | **A 2** | GitHub更新 | Cursor_GitHub連携（Ctrl+Shift+G） | Ctrl+Shift+G（ソース管理）→ cursor_rules (new commits) が出ていれば ステージ → コミット → 同期/プッシュ<br><br>（定型コミット文言／ルール最新化の共有）`Update cursor_rules submodule pointer (ルール最新化)` | ソース管理で更新の有無確認 → ステージ → コミット → 同期/プッシュ | 最新サブモジュールをGitHubに反映。 | ー |
| 準備 | **B-1** | サブモジュールの作成 | コマンドライン（Ctrl+SHIFT+@） | `git submodule add https://github.com/jinen3/cursor_rules.git cursor_rules`<br>`git add .gitmodules cursor_rules`<br>`git commit -m \"Add cursor_rules submodule\"`<br>`git push` | サブモジュールを追加して push<br>`.gitmodules` に cursor_rules あり（サブモジュール追加済） | プロジェクトに 共通ルールcursor_rules を組み込む。 | ー |
| 準備 | **B-2** | 最新化用のテンプレ準備 | コマンドライン（Ctrl+SHIFT+@） | `powershell -ExecutionPolicy Bypass -File .\\cursor_rules\\scripts\\setup-tasks-link.ps1`<br><br>（コピー更新時／上書きが必要な時）`powershell -ExecutionPolicy Bypass -File .\\cursor_rules\\scripts\\setup-tasks-link.ps1 -Force` | `.vscode/tasks.json` を作る（タスク読み込み用の設定ファイル（テンプレ）。共通テンプレへのリンク作成） | dev-start（サブモジュールの中身を取得＋最新化）をclick実行できるようにする | （tasks.json がGit管理対象のとき）`chore: update tasks.json for dev-start task`<br>B-1 |
| 準備 | **B-3** | ルールの初回登録 | Cursor機能（Rules） | Cursor Settings → Rules → Add Rule<br>プロジェクトフォルダ直下の Cursor ルール（.mdc）を登録<br>`<プロジェクトルート>\\cursor_rules\\.cursor\\rules\\`<br>6 ファイル + alwaysApply: true<br><br>**【重要】RulesのDeleteは .mdc 実ファイル削除になることがある**ため、外したい時は **`Agent decides when to apply`** に切り替える（`git status` が `deleted` なら `git -C "<プロジェクトルート>\\cursor_rules" restore .cursor/rules` ／特定ファイルなら `git -C "<プロジェクトルート>\\cursor_rules" restore .cursor/rules/venv-only-common.mdc`） | 6本の `.mdc` を Rules にパス登録（alwaysApply） | .mdc を自動適用して「共通ルール」をブレなく効かせる | ー |
| いつでも | （ルール）共通不具合の直し方 | 迷わないための方針 | 共通不具合は共通側を直す | **共通側（d:\\pyscript\\cursor_rules）で修正→commit/push** → 各プロジェクトは **dev-start** で取り込む | **警告：目的を見失わない。** GitHub操作やルール整備に悩んで時間を溶かしがち。まず「何をやりたいか？」（=開発で結果を出す）に立ち返る。 | B-2（共通不具合のとき） |

### A) 毎回（数秒）：開発に入る前の固定ルーティン

1. `ターミナル(T)` → `タスクの実行…` → **`dev-start (cursor_rules submodule)`** を選ぶ（サブモジュール=ルールを取得して最新化する）  
   - 一覧に **無い** → まず下の **B-2**（その前に **B-1** が未完了なら B-1 から）
2. `Ctrl+Shift+G`（ソース管理）→ `cursor_rules (new commits)` が出ていれば **ステージ → コミット → 同期/プッシュ**（親が指す参照先を共有して、別PC/他人でも同じ状態にする）

**コミットメッセージ（おすすめ・統一）**

ソース管理で `cursor_rules (new commits)` が出たときは、`tasks.json` の準備・更新が同時に出ていてもまとめてコミットしてOKです（あなたの1台運用なら迷いが減ります）。

- `Update cursor_rules submodule pointer (ルール最新化)`（`tasks.json` も含めてまとめてOK）

**タスクが「成功したか」の確認方法（この画面だけでOK）**

- **確認①（ターミナル出力）**：エラーが赤字で出ていない／最後までメッセージが出て止まっている（`ParserError` や `TerminatorExpectedAtEndOfString` が出ていない）
- **確認②（ソース管理）**：`Ctrl+Shift+G` で `cursor_rules (new commits)` が出たら「更新が入った」サイン（共有したいならステージ→コミット→同期/プッシュ）
- **確認③（タスクがやりたいこと別）**：
  - `dev-start` の確認：`cursor_rules` フォルダの中身（`scripts/` や `templates/` など）が “空ではない” 状態になり、タスク出力の最後に `== submodule status ==` と **コミットID（英数字のハッシュ）** が表示される
    - つまり「サブモジュールの中身が取得できて、いまどの版（どのコミット）を使っているか」が表示できている＝成功の目印
  - `setup-tasks-link` の確認：プロジェクト直下に `.vscode/tasks.json` が作られ、`ターミナル(T)` → `タスクの実行…` を開いたときに **`dev-start (cursor_rules submodule)` が一覧に表示される**
    - つまり「`.vscode/tasks.json`（= タスク読み込み用の設定ファイル（テンプレ））が読み込まれて、クリックで dev-start を起動できる状態になった」＝成功の目印
  - **注意（SkipRemote / update skipped の意味）**：タスク実行で `SkipRemote specified: remote update is skipped.` と出た場合、**最新化（--remote）がスキップされ、取得だけ**になっています。
    - 最新化したいときは、`-SkipRemote` が付いていない `dev-start (cursor_rules submodule)` を実行します（clone直後の「取得だけ」用途が `-SkipRemote` です）。

**タスクが無いときの代替（クリックできないときだけ・親リポジトリのルートで コマンド実行）**

`dev-start` が中でやっていること（要点）はこの2つです。

- `git submodule update --init --recursive`（未取得/未初期化を解消）
- `git submodule update --remote cursor_rules`（必要ならリモート最新へ更新）

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1
```

---

### B) まだならこの場で実行（プロジェクトごと。毎日いくつも開くならその都度）

「初回だけ」ではなく **プロジェクトが変われば未設定がありうる**。足りないものだけ下から実行し、**終わったら上の A に戻る**。

#### B-1. `.gitmodules` に `cursor_rules` が無い（サブモジュール未追加）

親リポジトリの**ルート**で実行（Cursor のターミナルで可）。**ルート直下に `cursor_rules` という名前の通常フォルダがあると失敗**するので、その場合は退避か削除してから。

```powershell
# Cursorでターミナルを開く: Ctrl+SHIFT+@（環境により Ctrl+` の場合もある）
cd <プロジェクトルートに置き換え> # 作業ディレクトリをプロジェクトのルートに移動
git submodule add https://github.com/jinen3/cursor_rules.git cursor_rules # cursor_rules をサブモジュールとして追加
git add .gitmodules cursor_rules # サブモジュール設定と参照先（ポインタ）変更をステージ
git commit -m "Add cursor_rules submodule" # サブモジュール追加をコミット
git push # GitHubへ送って他PC/他人にも反映
```

#### B-2. `タスクの実行…` に `dev-start` が出ない（`.vscode/tasks.json`＝タスク読み込み用の設定ファイル（テンプレ）が未準備）

**B-1 が済んで `cursor_rules` フォルダが取れていること**が前提。親リポジトリの**ルート**で：

```powershell
# Cursorでターミナルを開く: Ctrl+SHIFT+@（環境により Ctrl+` の場合もある）
cd <プロジェクトルートに置き換え> # 作業ディレクトリをプロジェクトのルートに移動
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\setup-tasks-link.ps1 # `.vscode/tasks.json` を作成（推奨: 共通テンプレへのリンク。不可ならコピー）
```

- シンボリックリンクに失敗した場合はコピーに **フォールバック（代替）**し、`.vscode/tasks_copy.txt` が目印になることがある。  
- 実行後、もう一度 `タスクの実行…` を開き直す。

**いまのコピーを更新したい最短手順（リンク作成に失敗する環境向け）**

`.vscode/tasks.json` が既に存在する場合、`-Force` が無いと「既に存在します（何もしません）」で終了し、コピーが更新されません。**プロジェクトのルートで `-Force` を付けて実行**します。

```powershell
cd <プロジェクトルートに置き換え>
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\setup-tasks-link.ps1 -Force
```

- これで既存 `tasks.json` を **バックアップして作り直します**
- 権限不足なら **コピーで代替しつつ、内容は最新になります**

**（ルール）全プロジェクト共通の不具合は「共通側」で直す**

`setup-tasks-link.ps1` が PowerShell の **パースエラー**（例：`TerminatorExpectedAtEndOfString` など）で落ちる場合、スクリプト自体の不具合なので **どのプロジェクトでも再発**します。
この場合は、プロジェクト内のサブモジュールをその場しのぎで直すのではなく、**共通側（`d:\pyscript\cursor_rules`）で修正 → commit/push** し、各プロジェクトは **サブモジュール更新で取り込む**のが最短です。

**最短復旧手順（共通不具合のとき）**

1. 共通側（`d:\pyscript\cursor_rules`）で `scripts/setup-tasks-link.ps1` を修正し、GitHub に push
2. 各プロジェクト側で `dev-start` を実行して、サブモジュール `cursor_rules` を最新に更新
3. そのプロジェクトのルートで、もう一度 B-2 のコマンドを実行する

#### B-3. Rules に 6 本の `.mdc` が未登録（パス指定の手動登録が必要）

**`.mdc` がディスク上にあっても、Cursor が必ず自動でルール登録してくれるわけではない。**  
ただし、**設定同期などの影響で「最初から Rules 一覧に出ている」こともある**ので、次の順で進める（= **まず確認 → 無ければ登録**）。

**重要（事故防止）**

- **Rules画面のゴミ箱（Delete）は「設定だけ」ではなく、参照元の `.mdc` ファイル自体を削除してしまうことがある。**（サブモジュール内でも `deleted` 扱いになりうる）
  - ルールを一時的に外したいだけなら、**Delete ではなく適用方法を `Agent decides when to apply` に切り替える**（= 常時適用をやめる）ほうが安全
  - もし誤って消えて `git status` で `deleted: .cursor/rules/xxx.mdc` が出たら、サブモジュール側で復旧する：

```powershell
# 例1: フォルダ配下をまとめて復旧（どれが消えたか分からないときに便利）
git -C "<プロジェクトルート>\cursor_rules" restore .cursor/rules

# 例2: 特定ファイルだけ復旧（今回のように1本だけ消えたとき）
git -C "<プロジェクトルート>\cursor_rules" restore .cursor/rules/venv-only-common.mdc
```

1. Cursor で **Settings（設定）** → **Rules**（または **Cursor Settings → Rules**）を開き、**6本が一覧にあるか確認**  
2. **すでに6本ある** → OK（登録作業は不要。以降は dev-start で中身が更新される）  
3. **無い／足りない** → **Add Rule** / **ルールを追加** → **ファイルから追加**（表記はバージョンで多少違う）  
4. 次の **フォルダ**にある **6 ファイルすべて**を追加し、**それぞれ `alwaysApply: true`**（常に適用）にする  

**登録元フォルダ（エクスプローラーで開くとき）**

ここは、**プロジェクトフォルダ直下の Cursor ルール（.mdc）を登録する**ための場所です。

```text
<プロジェクトルート>\cursor_rules\.cursor\rules\
```

**追加する 6 ファイル名（すべて `alwaysApply: true`）**

| ファイル名 |
|------------|
| `venv-only-common.mdc` |
| `errors-debug-unittest-common.mdc` |
| `post-modification-common.mdc` |
| `gui-build-security-common.mdc` |
| `markdown-common.mdc` |
| `update-management-common.mdc` |

**完全パス例（`D:` やフォルダ名は自分の環境に合わせて置き換え）**

```text
D:\pyscript\tool\あなたのプロジェクト\cursor_rules\.cursor\rules\venv-only-common.mdc
（以下、上記6本それぞれ同様に指定）
```

---

### このあと何を読むか（迷子防止）

- **毎日の操作・上の A/B だけ**で足りる。  
- **ルールの「本文」や更新の憲法**を読むときだけ `cursor_instructions_template.md` を開く（作業に必須ではない）。

---

## この手順書は「何を達成するため」のもの？

この手順書のゴールは、各プロジェクトで **共通リポジトリ `cursor_rules` をサブモジュールとして参照**しつつ、
開発開始時に「共通認識（ルール）」「共通スクリプト」「共通テンプレ」を **迷いなく最新へ揃える**ことです。

結論として、役割分担はこうなります（ここが分かれば迷子になりません）。

- **共通認識を“自動で効かせる”担当（最重要）**：Cursor の Rules に登録した `.mdc`（`alwaysApply: true`）
  - ポイント：`.mdc` は **存在するだけでは自動で適用されないことがある**。一方で、設定同期などで **最初から登録済みのこともある**。  
    → なので **B-3 は「Rules一覧で6本あるか確認」だけを毎プロジェクト最初にやる**（無ければ追加する）
- **「運用のマスタ説明書」担当**：`cursor_instructions_template.md`
  - ポイント：タスクやスクリプトは、この Markdown を AI に“自動注入”する機能ではない（人間＋AIが参照する説明書）
- **「毎回の開始操作をブレなくする」担当（最強のトリガー＝クリック運用）**：Cursor の **タスクの実行…** → `dev-start`
  - ポイント：`dev-start` は **サブモジュール（= ルール/スクリプト/テンプレの入った cursor_rules）を取得して最新化する**ための開始トリガー
  - 位置づけ：この「サブモジュール＝ルールの中身を取得して最新化」が **すべての始まり**（開発開始時に必ず最初にやる）
  - ただし **Rules 登録（alwaysApply の有効化）までは自動化しない**（別レイヤーの設定）
  - しかも、**Cursor ルール＝`.mdc` ファイルがあっても、Cursor は自動でルールとして読み込まない。**（**手動でのルール設定が必要**。）

## 背景（なぜこの手順になった？）

ここまでの議論の背景はシンプルです。

- やりたい：開発開始時に `cursor_rules` の **ルールを最新に更新して適用**したい。決まった手順で適用して、共通認識を自動維持したい
- そこで考えた：`cursor_rules` の最新ルールへの更新を、PowerShell のコマンド手打ちよりも、クリック運用に強い Cursor の **「タスク（Run Task… / タスクの実行…）」をトリガ**にすれば、クリックひとつで開始できる
- ただし分かった：タスクは **コマンド実行機能**であり、**サブモジュール＝ルールを最新化するのみ**。AIに Markdown を強制注入したり、Rules を自動登録したりはしない。**Cursor ルール＝`.mdc` ファイルがあっても、Cursor は自動でルールとして読み込まない。**
- なので到達した：  
  **最初の1回だけ Rules 登録**（`.mdc` を `alwaysApply` でパス登録）→ **2回目以降は** Cursor の **タスク（クリック）で dev-start を実行**して **サブモジュール（=ルール）を最新に更新**すれば、**Rules 登録（`.mdc` のパス登録）は自動で最新ルールに更新される！**  
  → これが「共通認識の自動維持」に一番近く、矛盾が出ない

## まず全体フロー（ツリー状）

> ここを見て全体像 → 次に「必要情報（手順）」 → 最後に「参考情報（解説）」の順で読む想定です。

```text
開始（Cursorでプロジェクトを開いた）
└─ サブモジュール設定（.gitmodules と cursor_rules）がある？
   ├─ ない（初回だけ）
   │  └─ 1) サブモジュールを追加して GitHub に保存する
   │      └─（以降は「ある」側へ）
   └─ ある
      ├─ ★最強の標準運用：「サブモジュール＝ルールの中身を取得して最新化」するために、クリック運用（タスクの実行…）で「開発開始」を実行する
      │  └─ これは「ターミナルにコマンドを打たずに、メニューから `dev-start`（= 開発開始スクリプト `dev-start-cursor-rules.ps1` を実行して、cursor_rules を取得/必要なら更新する）を実行する」という意味
      │     ├─ 先に `.vscode/tasks.json` を用意すると、`ターミナル` → `タスクの実行…` から選べるようになる
      │     └─ 逆に `tasks.json` が無いと、一覧に `dev-start ...` が出ない（クリック運用できない）
      │  ├─ 最初の1回だけ（準備）
      │  │  ├─ `.vscode/tasks.json` を用意して Task 化する（= 2) dev-start をクリック実行するための準備）
      │  │  │  └─ 目的：★おすすめの「2) 開発開始スクリプト」を Cursor 機能（`タスクの実行…`）でクリック実行できるようにする準備
      │  │  │  ├─ 推奨（コピーしない）: `.vscode/tasks.json` を共通側ファイルへのシンボリックリンクにする
      │  │  │  │  ├─ リンク元: `<プロジェクトルート>/.vscode/tasks.json`
      │  │  │  │  └─ リンク先: `<プロジェクトルート>/cursor_rules/templates/vscode_tasks.tasks.json.example`
      │  │  │  ├─ リンク作成（最初の1回）: 次を親リポジトリのルートで 1回実行
      │  │  │  │  ├─ リンク作成用スクリプト: `cursor_rules/scripts/setup-tasks-link.ps1`
      │  │  │  │  └─ 実行コマンド:
      │  │  │  │
      │  │  │  │     `powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\setup-tasks-link.ps1`
      │  │  │  └─ 代替（コピー）: `.vscode/tasks.json` をコピー（※ 共通更新は自動反映されない）
      │  │  │     └─ 目印: `.vscode/tasks_copy.txt` があれば「コピー運用」だと一目で分かる
      │  │  └─ Task 実行（クリック）:
      │  │     ├─ メニュー: `ターミナル(T)` → `タスクの実行…`
      │  │     └─ 一覧から `dev-start (cursor_rules submodule)` を選ぶ
      │  └─ 代替：ターミナル運用（コマンド直打ち）でも 2) は実行できる → そのまま次へ
      └─ Cursor の Rules に、cursor_rules の .mdc（6本）は登録済み？
         ├─ いいえ（最初の1回だけ）
         │  └─ 【最初の1回だけ】Rules登録（重要）
         │     ├─ 登録元（サブモジュール内）: `<プロジェクトルート>/cursor_rules/.cursor/rules/`
         │     ├─ 登録する6本（すべて `alwaysApply: true`）
         │     │  ├─ `venv-only-common.mdc`
         │     │  ├─ `errors-debug-unittest-common.mdc`
         │     │  ├─ `post-modification-common.mdc`
         │     │  ├─ `gui-build-security-common.mdc`
         │     │  ├─ `markdown-common.mdc`
         │     │  └─ `update-management-common.mdc`
         │     └─ 手順の詳細: **本ページ冒頭「毎日ここだけ見る」→ B-3**（この1画面にコマンド・パスあり）
         └─ はい（以降は通常運用へ）
      ├─ 【リモートリポジトリ（親GitHub）の更新まで含めたい】＝他人/別PCにも反映したい
      │  └─ サブモジュールの参照先（ポインタ）を「cursor_rules のリモート最新（origin/main 先端）」に更新して共有したい？
      │     ├─ いいえ → OK（ここでは何もしない）
      │     └─ はい
      │        ├─ 【最短ルート】（確認は後回しでOK）
      │        │  ├─ ★おすすめ：2) 開発開始スクリプトを1回実行（更新）
      │        │  │  └─ Cursorのソース管理GUIを開く（Ctrl+Shift+G）
      │        │  │     └─ `cursor_rules (new commits)` が出ている？
      │        │  │        ├─ いいえ → OK（共有作業なし）
      │        │  │        └─ はい → `cursor_rules` をステージ（＋）→ メッセージ → コミット → 同期/プッシュ（= 6）
      │        │  └─ 3) 最短ルートで最新化（コマンド直打ち）
      │        │     └─ 次に `git status` で確認（※ 3) はコマンドなので自分で実行）
      │        │        └─ `modified: cursor_rules (new commits)`？
      │        │           ├─ いいえ → OK（共有作業なし）
      │        │           └─ はい → 6) 親リポジトリに commit/push（共有＝公開。Cursorのソース管理GUIでも可）
      │        └─ 【丁寧に確認して進める】
      │           └─ 4) 最新状態を確認
      │              → 必要なら 5) 最新にする（更新）
      │              └─ `git status` が `modified: cursor_rules (new commits)`？
      │                 ├─ いいえ → OK（共有作業なし）
      │                 └─ はい → 6) 親リポジトリに commit/push（共有＝公開。Cursorのソース管理GUIでも可）
      ├─ 【ローカルリポジトリ限定】＝自分のPCだけでOK（共有しない）
      │  ├─ 【最短ルート】（確認は後回しでOK）
      │  │  ├─ 2) 開発開始スクリプトを1回実行（更新）
      │  │  │  └─ Cursorのソース管理GUI（Ctrl+Shift+G）で `cursor_rules (new commits)` を確認
      │  │  └─ 3) 最短ルートで最新化（コマンド直打ち）
      │  │     └─ `git status` で確認（差分が出ても共有しないので 6) は不要）
      │  └─ 【丁寧に確認して進める】
      │     └─ 4) 最新状態を確認 → 必要なら 5) 最新にする（更新）
      │        └─ `git status` が `modified: cursor_rules (new commits)`？
      │           ├─ いいえ → OK
      │           └─ はい → OK（共有しないので 6) は不要）
      └─ 【ローカルリポジトリ限定】clone 直後：サブモジュール（cursor_rules）の中身を取得だけ（更新はまだ）
         └─ 7) -SkipRemote（更新せず、親が指すコミットに揃えるだけ）
```

## 必要情報：まずやること（最短手順）

前提：プロジェクト（親リポジトリ）は **Cursor の機能で clone 済み**で、いまそのプロジェクトフォルダを Cursor で開いているものとします。

### 0) まず確認：このプロジェクトにサブモジュール設定がある？

- `.gitmodules` が **無い**（= まだサブモジュール設定が無い）  
  → 先に **1) サブモジュールを追加して GitHub に保存する** を実施
- `.gitmodules` が **ある**（= 既にサブモジュール設定がある）  
  → 次の **【最初の1回だけ】Rules登録**へ

### 1) 最初の1回だけ：サブモジュールを追加して GitHub に保存する（このプロジェクトに設定が無い場合）

親リポジトリのルートで実行します。**注意：親リポジトリのルート直下に `cursor_rules` という名前の通常フォルダが既にあると失敗**します。

```powershell
git submodule add https://github.com/jinen3/cursor_rules.git cursor_rules
git add .gitmodules cursor_rules
git commit -m "Add cursor_rules submodule"
git push
```

これで以降、他PCで `--recurse-submodules` 付き clone ができるようになります（サブモジュール設定が GitHub に保存された状態）。

### 【最初の1回だけ】Rules登録（重要：共通認識を“自動で効かせる”）

`cursor_rules` をサブモジュールとして置いただけでは、Cursor が `.mdc` を勝手にルール登録してくれるわけではありません。**最初の1回だけ**、Cursor の Rules に次の 6 本を登録します（すべて `alwaysApply: true`）。

- 登録元（サブモジュール内）：`<プロジェクトルート>/cursor_rules/.cursor/rules/`
  - `venv-only-common.mdc`
  - `errors-debug-unittest-common.mdc`
  - `post-modification-common.mdc`
  - `gui-build-security-common.mdc`
  - `markdown-common.mdc`
  - `update-management-common.mdc`

この「最初の1回」が終われば、以降は **2)（開発開始＝dev-start）**を回すだけで、共通ルールが安定して効くようになります。

### 2) ふだん毎回：開発を始めるとき（最初にやる：dev-start でサブモジュール＝ルールを最新化）

**dev-start を実行する目的（何のため？）**

- **目的**：作業開始前に、プロジェクト内の `cursor_rules` サブモジュールを「使える状態にする」＋（必要なら）`cursor_rules` をリモート最新へ更新して、**共通ルール/スクリプト/テンプレ**を最新に揃えるため
- **やること（中で実行していること）**：
  - `git submodule update --init --recursive`（サブモジュールの中身を取得して、空/未初期化を解消）
  - `git submodule update --remote cursor_rules`（必要なら `cursor_rules` をリモート最新へ更新）

基本は **クリック運用**で実行します（ターミナルで手打ちしない運用に寄せる＝これが最強）。

#### A) ★標準（最強）：Cursor の「タスクの実行…」でクリック実行

- メニュー: `ターミナル(T)` → `タスクの実行…` → `dev-start (cursor_rules submodule)` を選ぶ
- コマンドパレット（覚えやすい）: `Ctrl+Shift+P` → `Tasks: Run Task`（日本語UIだと「タスク: タスクの実行」等）→ 同タスクを選ぶ

#### B) 代替：ターミナルでコマンド実行（クリック運用がまだできない場合）

親リポジトリのルートで、次を **1回実行**します。

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1
```

#### ★おすすめ（最短・確実フロー：dev-start → GUIで確認 → 必要なら共有）

1. 2) のスクリプトを実行（更新）
2. Cursor ソース管理GUIを開く（`Ctrl+Shift+G`）
3. `cursor_rules (new commits)` が出ていたら
   - `cursor_rules` をステージ（＋）
   - メッセージ入力
   - コミット
   - 同期/プッシュ（= 6）
4. 出ていなければ終了（共有作業なし）

補足：
- このスクリプトは **`git status` 自体は実行しません**（最後に「git status で確認してね」と表示するだけです）。
- コマンドで確認したい場合は、実行後に `git status` を打ってもOKです。

#### 【最初の1回だけ】クリック運用（タスクの実行…）の準備：`.vscode/tasks.json` を用意する

この準備をすると、2) の dev-start を **ターミナルで手打ちせずに**、`ターミナル(T)` → `タスクの実行…` からクリック実行できるようになります。

- できること：`ターミナル(T)` → `タスクの実行…` から `dev-start (cursor_rules submodule)` を選んで実行できる
- 前提：プロジェクト側に `.vscode/tasks.json` が必要（無いと “タスク一覧” に表示されません）

最初の1回だけ「プロジェクト側の `.vscode/tasks.json` を用意する」作業をします。

- 雛形（共通リポジトリ側）：`cursor_rules/templates/vscode_tasks.tasks.json.example`
- 使い方（プロジェクト側）：
  - **推奨（コピーしない）**：プロジェクト側の `.vscode/tasks.json` を、共通側ファイルへの **シンボリックリンク**にする
    - リンク元（プロジェクト側）：`<プロジェクトルート>/.vscode/tasks.json`
    - リンク先（共通側）：`<プロジェクトルート>/cursor_rules/templates/vscode_tasks.tasks.json.example`
    - これなら “コピーが古くなる問題” を避けられる
    - **リンク作成（最初の1回）**：リンク作成用スクリプト `cursor_rules/scripts/setup-tasks-link.ps1` で自動作成できる

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\setup-tasks-link.ps1
```

  - 代替（コピーする）：プロジェクトの `.vscode/tasks.json` としてコピー（最も簡単だが、共通更新が自動反映されない）
    - **重要**：VS Code/Cursor は、基本的に **プロジェクト側のファイル名が `tasks.json` である必要**があるため、`tasks.json_copy.json` のように「名前を変えて区別する」方式は基本NGです
    - **代替時の目印**：`setup-tasks-link.ps1` が「コピーで代替」した場合は、`.vscode/tasks_copy.txt` を自動作成します（コピー運用だと一目で分かる）

> 注意：VS Code/Cursor の Task は、基本的に **ワークスペース（プロジェクト）側の `.vscode/tasks.json`** を見に行きます。共通リポジトリ側のファイルを “自動で探して” 使う仕組みはないため、**リンク**か**最小コピー**が現実解です。

（準備が終わったら）Task 実行（クリック）：

- メニュー: `ターミナル(T)` → `タスクの実行…` → `dev-start (cursor_rules submodule)` を選ぶ
- コマンドパレット: `Ctrl+Shift+P` → `Tasks: Run Task`（日本語UIだと「タスク: タスクの実行」等）→ 同タスクを選ぶ

### 6) （共有＝公開）親リポジトリに commit/push する（他人/別PCにも反映）

これは「ローカルで何らかの操作をして、**親リポジトリが記録しているサブモジュールの参照先（ポインタ）と、いま手元の `cursor_rules` が指しているコミットがズレた**」ときに使います。

もっとやさしく言うと、`git status` で `modified: cursor_rules (new commits)` が出ている状態です。

- これは「親が指すサブモジュールの参照先（ポインタ）が “新しくなった/変わった”」というより、
  **「親が GitHub で共有している（コミット済みの）参照先と、あなたの手元が違う」**という意味です。
- その “違い” が「たまたま最新にした結果」かもしれないし、「別のコミットに切り替えただけ」かもしれません。
  **本当にリモート最新（例: `origin/main` の先端）かどうかは、この表示だけでは確定しません**（5-C で確認します）。

このズレを **GitHub 上の親リポジトリに保存して、他人/別PCでも同じ状態を再現できるようにする（共有＝公開する）**のが 6) です。

> この 6)（ステージ→コミット→プッシュ）は、ターミナルでコマンド実行する以外に、**Cursor のソース管理（Git）画面**からでも実行できます（変更をステージ→コミット→プッシュ/同期）。チームの運用に合わせて、GUI/コマンドどちらでもOKです。

```powershell
git status
git add cursor_rules
git commit -m "Update cursor_rules submodule pointer"
git push
```

### 7) clone 直後など：サブモジュール（cursor_rules）の中身を「取得だけ」したい（更新はまだしない）

```powershell
powershell -ExecutionPolicy Bypass -File .\cursor_rules\scripts\dev-start-cursor-rules.ps1 -SkipRemote
```

- これは中で `git submodule update --init --recursive` を実行しており、**やりたいことは次の1行と同じ**です（より短い）。

```powershell
git submodule update --init --recursive
```

#### では、なぜスクリプト版（-SkipRemote）も載せているの？

- **スクリプトで統一したい**（手順2/3/7を同じ呼び出し方にしたい）場合に便利だからです。
- スクリプトは `.gitmodules` やサブモジュールの存在チェックもしてくれるため、失敗したときに原因が分かりやすいです。

### 3) 最短ルート：とにかく「最新にする」だけやりたい（確認は後回し）

「最新かどうかを丁寧に確認するより、まず更新してしまいたい」場合の最短です。

```powershell
git submodule update --init --recursive
git submodule update --remote cursor_rules
git status
```

- `git submodule update --init --recursive` は、clone 直後などで **サブモジュールの中身が未取得/未初期化**のときに必要です。
  - これが無いと、`cursor_rules` フォルダが空のまま（または未初期化のまま）で、`--remote` がうまく動かない場合があります。
- `git status` が `modified: cursor_rules (new commits)` なら：共有したい場合は 6)（commit/push）へ
- 本当に `origin/main` 先端まで行けているか確実にしたい場合は、あとから 5-C で確認します

### 4) （ローカル）最新状態を確認する（確認）

ここでの「確認」は 2 種類あります。

- **A. 共有の観点（親リポジトリ側の差分）**：他人/別PCにも反映する必要がある変更が出ているか？
- **B. 更新の観点（サブモジュール側の最新）**：`cursor_rules` 側にリモート最新（例: `origin/main`）の更新が来ているか？

#### 5-A) まずは `git status` で「共有の差分」を確認（いちばん大事）

親リポジトリのルートで実行します。

```powershell
git status
```

- `nothing to commit, working tree clean`  
  → 親リポジトリの観点では差分なし（**共有作業なし**）
- `modified: cursor_rules (new commits)`  
  → 親が記録しているサブモジュールの参照先（ポインタ）と、あなたの手元の `cursor_rules` が指すコミットがズレている（**共有したいなら 6) へ**）

#### 5-B) 次に `git submodule status` で「親が指しているコミットID」を確認

```powershell
git submodule status cursor_rules
```

これは「親リポジトリが、`cursor_rules` の **どのコミットIDを指しているか**」を見るコマンドです。
（`git status` は“差分があるかどうか”は分かりますが、“どのコミットIDか”を明確に見る目的ではこちらが確実です）

#### 5-C) `cursor_rules` 側が「リモート最新か」を確認（必要なときだけ）

次に「`cursor_rules` リポジトリ側のリモート最新（例: `origin/main` の先端）」を確認します。

```powershell
git -C cursor_rules fetch
git -C cursor_rules rev-parse HEAD
git -C cursor_rules rev-parse origin/main
```

- `HEAD` と `origin/main` が同じなら：`cursor_rules` 側としては最新です（※ 親リポジトリが常に最新を指すとは限りません）。
- `HEAD` と `origin/main` が違うなら：`cursor_rules` 側に新しい更新が来ています（次の「6)」へ）。

#### 【質問①】なぜ `git status` だけでは「最新かどうか」が分からないの？

`git status` は **親リポジトリの作業ツリーに“変更があるか”**を表示するコマンドです。サブモジュールについては主に次を教えてくれます。

- 親が指す参照先（ポインタ）が変わったか（例: `modified: cursor_rules (new commits)`）

一方で、`git status` だけでは **「`cursor_rules` のリモート（例: `origin/main`）が進んでいるか」**は分かりません。
リモートが進んでいるかを知るには、`cursor_rules` 側で `fetch` して比較する必要があるため、5-C のような確認をします。

#### `git status` と `git submodule status cursor_rules` の違い（ざっくり）

- `git status`（親リポジトリで実行）
  - **目的**：親リポジトリに差分があるか（共有が必要か）を確認する
  - **見えるもの**：`modified: cursor_rules (new commits)` のような「参照先が変わった」サイン
- `git submodule status cursor_rules`（親リポジトリで実行）
  - **目的**：親が指している `cursor_rules` の **コミットID** を確認する
  - **見えるもの**：`cursor_rules` が指しているコミットID（どの版を使っているか）

どちらが正しい、ではなく **目的が違う**ので両方使い分けます。


### 5) （ローカル）サブモジュールを最新にする（更新）

親リポジトリが指している `cursor_rules` の参照先（ポインタ）を、リモート最新に近づけます。

```powershell
git submodule update --remote cursor_rules
git status
```

- `git status` で `modified: cursor_rules (new commits)` が出たら「親が指す参照先（ポインタ）が変わった」状態です。
- `git status` で `modified: cursor_rules (new commits)` が出たら、次のどちらか（または両方）が起きています。
  1. **あなたの手元の `cursor_rules` が、親リポジトリが記録している参照先（ポインタ）とズレた**（= 共有されている状態と違う）
  2. そのズレが、結果として **リモート最新へ近づいた可能性はある**が、**本当にリモート最新かはこの表示だけでは分からない**

  そのため次のように考えます。
  - **他人/別PCにも反映したい（共有したい）場合**：6) の commit/push（公開）をします（親リポジトリが指す参照先を GitHub に保存）
  - **自分のPCだけでよい場合**：6) は不要です（共有しない）
  - **本当にリモート最新か確実にしたい場合**：5-C（`HEAD` と `origin/main` の比較）で確認します

---

## 参考情報：解説（やさしい説明）

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

- これは「**親リポジトリ（プロジェクト）直下にあるサブモジュール `cursor_rules` の中**」に、スクリプトが入っている、という意味です。
- サブモジュールを追加すると、親リポジトリのルート直下に `cursor_rules` フォルダができます（その中身が共通リポジトリです）。
- 例（あなたの環境イメージ）:
  - 親リポジトリ: `D:\pyscript\tool\py_tool_daily_report`
  - スクリプト: `D:\pyscript\tool\py_tool_daily_report\cursor_rules\scripts\dev-start-cursor-rules.ps1`

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

### 「最新に更新」せずに、サブモジュール（cursor_rules）の中身だけ取得する（clone 直後など）

### 【質問3】「（サブモジュールの中身を）取得だけ」ってどういうこと？

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

- 上のコマンドを「部品」に分けるとこうなります。
  - `powershell`: PowerShell を起動して実行します（今いる PowerShell から “別の PowerShell” でスクリプト実行する形になります）。
  - `-ExecutionPolicy Bypass`: スクリプト実行が制限されているPCでも、**この実行だけ**通すための指定です（設定を恒久変更しません）。
  - `-File .\cursor_rules\scripts\dev-start-cursor-rules.ps1`: 実行するスクリプトの場所です。`.\` は「今いるフォルダ（カレント）」を意味します。
    - なので通常は、親リポジトリのルートで実行すると分かりやすいです（例：`D:\pyscript\tool\py_tool_daily_report` で実行）。
  - `-ProjectRoot "D:\pyscript\tool\py_tool_daily_report"`: スクリプトに渡す「引数」です。**処理対象の親リポジトリのルート**を明示します。
    - 今いる場所がどこでも、このパスを親リポジトリのルートとして扱って処理します。

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
