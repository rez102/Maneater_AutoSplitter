# Maneater LiveSplit Auto Splitter

Maneater PC版向けのLiveSplit Auto Splitterです。

Objective / Quest、EP進行、Player Level、Infamy Rankなどをメモリ読み取りで検出して自動スプリットします。

## 対応状況

- Epic Games版: 対応
- Steam版: 対応

## 主な機能

- Objective / Quest完了でスプリット
- EP / Story進行でスプリット
- Player Level 1-40でスプリット
- Growth Stageでスプリット
- Base Game Infamy Rank 1-10でスプリット
- DLC Infamy Rank 1-5でスプリット
- DLC Chidori Island / Truth Quest Objective対応
- Epic Games版 / Steam版ロード画面中のGame Time停止

## インストール

1. LiveSplitを起動します。
2. Layout Editorを開きます。
3. `Scriptable Auto Splitter` コンポーネントを追加します。
4. Script Pathに以下のASLを指定します。

```text
Maneater_Objective_AutoSplitter_release.asl
```

5. LiveSplitでManeaterを起動または認識させます。
6. Settingsから使いたいsplit項目にチェックを入れます。

## 使い方

初期状態では、各カテゴリは表示されますが、実際のsplit項目は基本OFFです。

使いたい項目だけONにしてください。

例:

- `Story / EP Clear Splits`
- `Player Levels 1-40`
- `Growth Stages`
- `Base Game Infamy Ranks 1-10`
- 各地域のObjective / Quest

親カテゴリがOFFだと、その下の項目をONにしてもスプリットしません。使うカテゴリの親もONにしてください。

## ロード除去について

Epic Games版 / Steam版ともにMoviePlayerのLoading Screenフラグを使ってGame Timeを停止します。

## 注意

- ASLはManeater Epic Games版 / Steam版で検証しています。
- Quest / Objective splitは、ゲーム内でObjectiveが完了済みリストに追加されたタイミングで反応します。
- すでに完了済みのObjectiveは、タイマー開始時点のbaselineとして扱われるため即スプリットしません。


## License

MIT License
