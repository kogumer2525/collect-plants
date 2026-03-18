## 概要

ユーザーが散歩中に発見した植物を記録し、図鑑に登録・マップ表示・博物館展示ができるiOSスマートフォンアプリです。Xcodeで実行します。

## ディレクトリ構造

- `Models/` : データ構造・CoreDataエンティティのみ。ロジックは書かない。
- `ViewModels/` : 画面ごとに1ファイル。状態管理とビジネスロジックを担当。
- `Views/` : 機能ごとにサブフォルダを切る。ViewはViewModelを監視するだけ。
- `Services/` : 外部通信・CoreData操作・デバイス機能へのアクセスはここに集約。
- `Utilities/` : 定数・Extension など汎用的なもの。
- `Resources/` : Assets・CoreDataスキーマなど。

## APIキー管理

- APIキーは `Config/Debug.xcconfig` に記載する
- サンプルは `Config/Debug.xcconfig.sample` を参照
- gitignoreに登録する

## アーキテクチャ

- MVVMを採用する。

## 仕様技術

- Swift UI：UI
- CoreData：データ保存
- MapKit：地図
- CoreLocation：位置情報
- URL Session：API通信
- PlantNet API：植物識別
- HealthKit：歩数
- AVFoundation：カメラ

## 画面構成

「探す」「図鑑」「マップ」「庭」画面はバーで切り替え可能にする

- 「探す」画面
  - 概要：ユーザーが撮影した植物写真をAIに送信し、植物種を識別する。
- 「図鑑」画面
  - 概要：識別された植物をユーザーの図鑑に登録・表示する。
- 「マップ」画面
  - 概要：ユーザーが発見した植物を地図上に表示する。
- 「庭」画面
  - 概要：図鑑登録された植物の種数に応じて、庭に花がランダムに咲く。家具も配置できる。
  - アイソメトリック表示（SwiftUI座標指定、SpriteKitは不使用）で画面全体にタイルグリッドを敷き詰める。
  - 植物は種類ごとに異なる見た目ではなく、ランダムな花の絵文字が咲く。
  - 家具はグリッド上の固定座標に配置される。購入済みの家具のみ表示。
  - 動物（boar・badger・stag）が庭レベルに応じて出現し、GL/Pタイル上をゆっくり移動する。

## 処理の流れ

1. アプリ起動
2. 「探す」画面へ遷移（AVFoundation）
3. カメラ起動
  - 初回：「カメラへのアクセスを許可しますか？」ダイアログ
  - 2回目以降：そのまま起動
4. シャッターボタンをタップし写真を撮影
5. 以下を並行して実行
   1. 画像を識別（PlantNet API）
   2. 現在地の緯度経度を取得（CoreLocation）
6. 5.が両方完了したら識別結果を移す
  - 表示内容：
    - 撮影した写真
    - 植物名
    - 学名
    - 信頼度
  - 1位の識別結果を選択済み状態でデフォルトとしてセット
  - 他の候補として、PlantNet APIから受け取った他の候補は、植物名・学名・信頼度を出して並べる
  - もしユーザーが他の候補をタップした場合のみ、選択中の植物名・学名が切り替わる
7. ユーザーが「登録する」をタップしたら、現在選択されている候補でDBに保存
8. 以下を並行して実装
   1. 緯度経度を地名に変換（CoreLocation）
   2. PlantRecordを組み立て、CoreDataに保存
      - id: UUID自動生成
      - plantName: API結果（ユーザーの最終的に選択したもの）
      - scientificName: API結果
      - imageData: 撮影画像をdata型に変換
      - latitude: CoreLocationの値
      - locationName: CLGeocoderの結果
      - date: 現在時刻
      - growthLevel: 0（初期値）
      - confidence: APIのscore
9.  「探す」画面に戻る

## データ設計

- PlantRecord
  - id, plantName, scientificName, imageData, latitude, longitude, date, growthLevel, confidence, locationName
- AnimalRecord
  - id, name, rarity, icon, description
- FurnitureRecord
  - id, furnitureID, name, emoji, purchasedDate

## 実装方針

### 実装済み
- 動物来訪イベント（基本実装）
  - 庭レベルに応じて boar・badger・stag がランダムに出現（レベル-1 匹）
  - GL・Pタイル上をゆっくり連続移動（停止なし、移動時間9秒）
  - 出現する動物種は起動のたびにランダム
  - レア度システム・CoreData保存は未実装（AnimalRecord は枠のみ）

### 枠組みのみ（中身は後で実装）
- 歩数ポイント機能
  - ユーザの歩数をポイント化する
- 家具購入機能
  - 庭に家具を配置できる。家具はグリッド上の固定座標に配置。
  - 購入するとCoreDataに保存され、庭に表示される。
  - 家具の種類: bench, fountain, lantern, statue, table, birdhouse

## 庭タイルシステム

- 実装ファイル: `Views/Garden/GardenScene.swift`
- スタッガードグリッド: 偶数行10タイル・奇数行9タイル、合計56行
- タイルサイズ: `tileW = 画面幅 ÷ 9`、`tileH = tileW ÷ 2`
- `gardenLayoutMap`: タイル種類の2次元配列（短縮名で記述）
- `gardenDecorationMap`: タイル上に重ねる装飾の2次元配列
- `TileType.depthOffset`: 正の値で下に凹む、負の値で上に浮く
- `TileDecoration.depthOffset`: デコレーションの同様のオフセット
- 動物の移動対象タイル: `canWalk`（GL・P のみ）