# English Listening App (MVP)

iOS向け英語リスニング練習アプリのMVP開発リポジトリ

## 概要

LibriSpeechコーパスを利用した、シンプルな英語リスニング学習アプリです。
音声再生・トランスクリプト表示・基本的な学習進捗管理機能を提供します。

## プロジェクト構成

```
english-listening-ios/
├── EnglishListeningApp/  # iOSアプリ本体（Xcodeプロジェクト）
├── data/
│   ├── raw/              # LibriSpeech元データ（.gitignoreで除外）
│   └── processed/        # 加工済みデータ（.gitignoreで除外）
├── tools/                # データ処理スクリプト等
└── docs/                 # 設計書・仕様書
```

## データセットについて

本プロジェクトは **LibriSpeech ASR corpus** を使用します。

- **データセット**: LibriSpeech ASR corpus (OpenSLR SLR12)
- **ライセンス**: CC BY 4.0
- **引用**: Vassil Panayotov, Guoguo Chen, Daniel Povey and Sanjeev Khudanpur. 
  "LibriSpeech: an ASR corpus based on public domain audio books", 
  ICASSP 2015.
- **URL**: https://www.openslr.org/12

### ライセンス遵守

CC BY 4.0に従い、以下を実施します：
- アプリ内およびApp Storeページにて適切なクレジット表記
- データセットへのリンクとライセンス情報の明示
- 改変内容の説明（音声の切り出し・圧縮等を行った場合）

## 開発方針

- **MVP最小機能**: 音声再生、トランスクリプト表示、進捗記録
- **技術スタック**: Swift, SwiftUI, AVFoundation
- **データ管理**: 初期はローカルバンドル、将来的にオンデマンドダウンロード検討
- **安全第一**: 大容量データはリポジトリ管理外、再現可能なビルド手順を文書化

## ライセンス

（本アプリのライセンスは後で決定）  
データセット: CC BY 4.0 (LibriSpeech)
