# Collect Plants

散歩中に発見した植物を撮影・識別し、図鑑に登録・マップ表示・植物園展示ができるiOSアプリです。

## 機能

- **探す** - カメラで植物を撮影し、PlantNet AIで種類を識別
- **図鑑** - 識別・登録した植物を一覧・詳細表示
- **マップ** - 発見した植物を地図上にマッピング
- **植物園** - 登録した植物をコレクションとして展示

## 技術スタック

| 用途 | 技術 |
|------|------|
| UI | SwiftUI |
| データ保存 | CoreData |
| 地図 | MapKit |
| 位置情報 | CoreLocation |
| API通信 | URLSession |
| 植物識別 | PlantNet API |
| 歩数 | HealthKit |
| カメラ | AVFoundation |

## アーキテクチャ

MVVM を採用しています。

## ファイル構成

```
collect_plants/
├── collect_plantsApp.swift          # アプリのエントリーポイント
├── ContentView.swift                # タブバー (探す/図鑑/マップ/植物園)
├── Info.plist                       # カメラ・位置情報・HealthKit の利用許可設定
│
├── Config/
│   ├── Debug.xcconfig               # APIキー設定 (git管理外)
│   └── Debug.xcconfig.sample        # APIキー設定のテンプレート
│
├── Models/
│   ├── PlantRecord.swift            # 植物記録のデータ構造
│   ├── PlantIdentificationResult.swift  # PlantNet API レスポンスの型定義
│   └── AnimalRecord.swift           # 動物来訪イベントのデータ構造
│
├── ViewModels/
│   ├── ExploreViewModel.swift       # 撮影・識別・登録の状態管理
│   ├── DictionaryViewModel.swift    # 図鑑一覧の状態管理
│   ├── MapViewModel.swift           # 地図表示の状態管理
│   └── GardenViewModel.swift        # 植物園の状態管理
│
├── Views/
│   ├── Explore/
│   │   ├── ExploreView.swift        # カメラ撮影・識別結果表示画面
│   │   └── CameraPreviewView.swift  # AVCaptureSession のプレビュー表示
│   ├── Dictionary/
│   │   └── DictionaryView.swift     # 登録済み植物の図鑑一覧
│   ├── Map/
│   │   └── MapView.swift            # 発見場所のマップ表示
│   └── Garden/
│       └── GardenView.swift         # 植物園コレクション表示
│
├── Services/
│   ├── CameraService.swift          # AVFoundation カメラ制御・撮影
│   ├── PlantNetService.swift        # PlantNet API への画像送信・識別
│   ├── LocationService.swift        # 位置情報取得・逆ジオコーディング
│   ├── CoreDataService.swift        # CoreData への保存・取得
│   ├── HealthKitService.swift       # 歩数取得 (未実装)
│   └── AnimalEventService.swift     # 動物来訪イベント (未実装)
│
├── Utilities/
│   ├── AppTheme.swift               # カラーパレット・グラデーション・カードスタイル
│   ├── Constants.swift              # APIキー・ベースURL
│   └── Extensions.swift             # 汎用 Extension
│
└── Resources/
    ├── Assets.xcassets/             # アプリアイコン・アクセントカラー
    └── CollectPlants.xcdatamodeld/  # CoreData スキーマ定義
```

## セットアップ

1. リポジトリをクローン
2. `Config/Debug.xcconfig.sample` を `Config/Debug.xcconfig` にコピー
3. [PlantNet API](https://my.plantnet.org/) でAPIキーを取得
4. `Debug.xcconfig` の `PLANTNET_API_KEY` にキーを設定
5. Xcodeでプロジェクトを開いてビルド・実行

### Xcode の xcconfig 設定

`Debug.xcconfig` は Xcode プロジェクトの全ビルド構成 (Debug/Release) に紐付けられています。`Info.plist` 内の `$(PLANTNET_API_KEY)` がビルド時に xcconfig の値で置換され、アプリ内から `Bundle.main.infoDictionary` 経由でアクセスできます。

## 実行方法

1. `collect_plants.xcodeproj` をXcodeで開く
2. 左上のスキームが「collect_plants」になっていることを確認
3. 実行先として実機またはiOSシミュレータを選択
4. `Cmd + R` で実行

## 動作環境

- iOS 26.2+
- Xcode 26.3+
