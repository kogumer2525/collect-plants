# Pocket Garden

散歩中に植物を撮るだけで名前を判定し図鑑に登録！登録した植物の数に応じて庭に花が増え、歩数ポイントは庭に配置できるアイテムと交換できます。日常の散歩が「集めて育てる楽しさ」に変わり自然とモチベーションUP！植物の知識も付き、身近な自然への関心が高まるアプリです。

デモ動画はこちら
https://drive.google.com/file/d/1MZHFOixdl2_lbFs0OGM_kBjAMO00FO9_/view?usp=drivesdk

## 機能

- **探す** - カメラで植物を撮影し、PlantNet AIで種類を識別
- **情報取得** - 学名をもとにMediaWiki APIまたはMistral APIで日本語名と解説文を取得
- **図鑑** - 識別・登録した植物を一覧・詳細表示（一日本語名/英名表示、解説文、地図・写真拡大・前後移動等）
- **マップ** - 発見した植物を地図上にマッピング、HealthKitで取得した歩数とポイントの表示
- **庭** - 登録した植物数に応じてランダムに花が咲く庭園、動物来訪イベント
- **ショップ** - ポイントで家具を購入して庭に配置

## 技術スタック

| 用途 | 技術 |
|------|------|
| 言語 | Swift |
| UI | SwiftUI |
| データ保存 | CoreData |
| 地図 | MapKit |
| 位置情報 | CoreLocation |
| API通信 | URLSession |
| 植物識別 | PlantNet API |
| 植物情報取得 | MediaWiki API |
| AI 植物情報取得 | Mistral API |
| 歩数・ポイント | HealthKit |
| カメラ | AVFoundation |

## アーキテクチャ

MVVM (Model-View-ViewModel) を採用しています。
- **Model** - データ構造とビジネスロジック（Models/ および Services/ に配置）
- **View** - UI表示（Views/ に配置）
- **ViewModel** - View と Model を仲介し、状態管理と処理ロジックを担当（ViewModels/ に配置）

## ファイル構成

```
collect_plants/
├── collect_plantsApp.swift          # アプリのエントリーポイント
├── ContentView.swift                # タブバー (探す/図鑑/マップ/庭/ショップ)
├── Info.plist                       # カメラ・位置情報・HealthKit の利用許可設定
│
├── Config/
│   ├── Debug.xcconfig               # APIキー設定 (git管理外)
│   └── Debug.xcconfig.sample        # APIキー設定のテンプレート
│
├── Models/
│   ├── PlantRecord.swift            # 植物記録のデータ構造
│   ├── PlantIdentificationResult.swift  # PlantNet API レスポンスの型定義
│   ├── AnimalRecord.swift           # 動物来訪イベントのデータ構造
│   ├── Furniture.swift              # 家具データの基本構造
│   └── FurnitureRecord.swift        # CoreData 家具イベント記録
│
├── ViewModels/
│   ├── ExploreViewModel.swift       # 撮影・識別・登録の状態管理
│   ├── DictionaryViewModel.swift    # 図鑑一覧の状態管理
│   ├── PlantDetailViewModel.swift   # 図鑑詳細のWikipedia情報取得・状態管理
│   ├── MapViewModel.swift           # 地図表示・歩数・ポイントの状態管理
│   ├── GardenViewModel.swift        # 庭の状態管理・動物イベント
│   └── ItemShopViewModel.swift      # ショップの状態管理・家具購入
│
├── Views/
│   ├── Explore/
│   │   ├── ExploreView.swift        # カメラ撮影・識別結果表示画面
│   │   ├── CameraPreviewView.swift  # AVCaptureSession のプレビュー表示
│   │   └── ImagePickerView.swift    # ギャラリーから画像を選択
│   ├── Dictionary/
│   │   ├── DictionaryView.swift     # 登録済み植物の図鑑一覧・詳細
│   │   └── PlantEditView.swift      # 植物情報の編集画面
│   ├── Map/
│   │   ├── MapView.swift            # 発見場所のマップ表示
│   │   └── StepsDetailView.swift    # 歩数とポイント表示
│   ├── Garden/
│   │   ├── GardenView.swift         # 庭園の全体表示
│   │   ├── GardenScene.swift        # タイルグリッドの描画・アイソメトリック表示
│   │   ├── GardenLevelView.swift    # 庭レベルの表示
│   │   └── CritterView.swift        # 動物キャラクターの表示・移動
│   └── Shop/
│       └── ItemShopView.swift       # 家具ショップ・購入画面
│
├── Services/
│   ├── CameraService.swift          # AVFoundation カメラ制御・撮影
│   ├── PlantNetService.swift        # PlantNet API への画像送信・識別
│   ├── LocationService.swift        # 位置情報取得・逆ジオコーディング
│   ├── CoreDataService.swift        # CoreData への保存・取得
│   ├── WikipediaService.swift       # Wikipedia から和名・解説文を取得
│   ├── HealthKitService.swift       # 歩数取得
│   ├── AnimalEventService.swift     # 動物来訪イベント管理
│   ├── FurnitureManager.swift       # 家具管理・グリッド配置
│   ├── PointManager.swift           # ポイント管理・計算
│   └── MistralService.swift         # AI 画像解析サービス (補助)
│
├── Utilities/
│   ├── AppTheme.swift               # カラーパレット・グラデーション・カードスタイル
│   ├── Constants.swift              # APIキー・ベースURL
│   └── Extensions.swift             # 汎用 Extension
│
└── Resources/
    ├── Assets.xcassets/             # アプリアイコン・アクセントカラー・スプライト
    └── CollectPlants.xcdatamodeld/  # CoreData スキーマ定義
```

## セットアップ

1. リポジトリをクローン
2. `Config/Debug.xcconfig.sample` を `Config/Debug.xcconfig` にコピー
3. [PlantNet API](https://my.plantnet.org/) でAPIキーを取得
4. [Mistral AI](https://console.mistral.ai/) でAPIキーを取得
5. `Debug.xcconfig` に以下を設定：
   - `PLANTNET_API_KEY` = PlantNet のAPIキー
   - `MISTRAL_API_KEY` = Mistral のAPIキー
6. Xcodeでプロジェクトを開いてビルド・実行

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
