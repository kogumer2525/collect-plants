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

「探す」「図鑑」「マップ」「植物園」画面はバーで切り替え可能にする

- 「探す」画面
  - 概要：ユーザーが撮影した植物写真をAIに送信し、植物種を識別する。
- 「図鑑」画面
  - 概要：識別された植物をユーザーの図鑑に登録・表示する。
- 「マップ」画面
  - 概要：ユーザーが発見した植物を地図上に表示する。
- 「植物園」画面
  - 概要：図鑑登録された植物が、植物園として配置される。

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

## 実装方針
- 以下2つの機能については、ファイル・枠組みだけ作成し、中身は後で実装する。
- 歩数ポイント機能
  - ユーザの歩数をポイント化する
- 動物来訪イベント
  - 植物園に植えられている植物種数に応じて動物がランダム来訪する。
  - 植物種が増えるほどレア度の高い動物が出現する確率が上がる。