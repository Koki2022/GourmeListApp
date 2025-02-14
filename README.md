# GourmeListApp (グルメリストアプリ)
過去の思い出も、未来の楽しみも、すべてここに、あなたの食の冒険を記録し、新たな発見を導く究極のグルメリストアプリ！

![日記 グルメ ランチ 料理 note アイキャッチ 見出し ](https://github.com/user-attachments/assets/fd88ba16-0b4d-4101-a58d-b5328eea4715)

## 1.概要
過去に訪れたお店や、これから行きたいお店を簡単にリスト管理できます。スマート検索機能で予測入力で素早く店舗を発見し、店名、営業時間、位置情報などの店舗情報を自動で取得できます。また、カスタマイズ可能な分類システムで自由にタグを作成し「ランチ」「ディナー」「寿司」「イタリアン」など、多彩な条件で絞り込み可能です。このように、ユーザのタップ操作だけで簡単に店舗情報を登録・編集できます

## 2.ダウンロードリンク
[![204145956-f5cc0fa8-d4c9-4f2c-b1d4-3c3b1d2e2aba](https://github.com/user-attachments/assets/23e47d1a-df31-4e09-a0fd-24d5bf8af51d)](https://apple.co/3EoIjXK)


## 3.実行画面
https://github.com/user-attachments/assets/19b16ccd-2c4e-4242-b2f4-a9dbb6df75eb

## 4.アプリの機能
・訪問したお店や気になるお店をリスト管理

・お店検索時の予測入力機能と、店舗情報の自動取得

・タグでお店リストを分類

・リストとしても、グルメ日記としても活用できる

## 5.アプリの設計について

【画面遷移とボタン押下時の処理フロー】

<img width="728" alt="スクリーンショット 2025-02-14 7 11 04" src="https://github.com/user-attachments/assets/ab019455-a69b-4a55-9db2-d373ab88d9bd" />


【システム処理の流れを表すシーケンス図】

![スクリーンショット 2025-02-10 17 24 44](https://github.com/user-attachments/assets/a5429c1b-9b59-4498-8764-47a95b474c48)

【MVVM設計図】

|View名|概要|
|:---:|:---:|
|HomeView|お店一覧の表示とリスト検索を行う|
|TagSelectionView|選択したタグでお店のリストをフィルタリング|
|OriginalSearchBarView|検索バー|
|StoreSearchView|お店を検索して対象の店舗をリスト表示|
|VisitDateView|訪問日を設定する画面|
|TagAddView|店舗追加時にタグを登録する画面|
|TagButtonView|タグボタンのレイアウト|
|StoreOverview|登録した店舗の概要を確認する画面|
|StoreRegistrationView|店舗概要を登録する画面|
|StoreEditView|登録した店舗を編集する画面|
|ImageScrollView|画像を選択・登録する画面|

|ViewModel名|概要|
|:---:|:---:|
|HomeViewModel|リストのフィルタリング・削除を行うメソッドを記述したクラス|
|TagSelectionViewModel|登録したタグの表示と検索欄に入力した文字と一致するタグを検索するメソッドを記述したクラス|
|StoreSearchViewModel|Google Places APIを使用して場所の自動補完検索と詳細情報を取得するメソッドを記述したクラス|
|TagAddViewModel|登録したタグのボタン作成と長押し時のタグ削除するメソッドを記述したクラス|
|StoreOverViewModel|登録した店舗の概要を表示するメソッドを記述したクラス|
|StoreRegistrationViewModel|店舗情報をCoreDataへ登録するメソッドを記述したクラス|
|StoreEditViewModel|編集した店舗情報をCoreDataへ登録するメソッドを記述したクラス|

|Model名|概要|
|:---:|:---:|
|HomeNavigatePath|ホーム画面からナビゲーション遷移する画面の管理をする列挙体|
|TagButtonDetail|各タグボタンの情報を格納する構造体|
|StoreDetailData|お店情報を設定するためのデータをまとめた構造体|
|VisitationStatus|訪問状況を管理する列挙体|

## 6. 工夫したコード／設計
### ポイント1: Google Places APIを活用し、店舗情報を取得するコードを実装しました。
・検索結果は日本のエリアを中心に表示されるようにlocationBiasプロパティーに範囲を設定しています
https://github.com/CodeCandySchool/GourmeListApp_koki/blob/4dfa143f35d02b56a1dcdb1b080b9d0196a00281/GourmeListApp/GourmeListApp/ViewModel/StoreSearchViewModel.swift#L19-L42

・GMSPlacePropertyに店名、住所、電話番号、営業時間の店舗情報をフィールドとしてセットし、placeIDと先ほど取得したフィールドを使用してリクエストを作成します。その後Google Places APIクライアントを使用して場所の情報が取得できます。
https://github.com/CodeCandySchool/GourmeListApp_koki/blob/4dfa143f35d02b56a1dcdb1b080b9d0196a00281/GourmeListApp/GourmeListApp/ViewModel/StoreSearchViewModel.swift#L43-L62

### ポイント2: 店舗リストの絞り込み検索を実装しました。
ホーム画面でより詳細な絞り込み検索を可能にするために、選択されているタグ名と検索バーに入力した店名がAND条件で一致するものをリストに表示するようにしました。つまり選択中のタグで表示されたリストの中から店名検索を行います

①coreDataFetchedStoresにすべてのデータが格納されていますので、タグ未選択時はそのデータをtagFilteredStoresに格納してリストを全件表示します

②タグが選択されるとfilterメソッドを使用して、CoreDataに保存された店舗のタグ(storeTagsに格納)と、ホーム画面で選択したタグ(userSelectedTagsに格納)がすべて一致しているのを確認して、そのタグに該当するリストをすべて表示します

③ ②でタグが選択中の状態なった後、さらに店名入力欄の検索バーで文字を入力すると、localizedCaseInsensitiveContainsメソッドを使用して入力した文字(大文字小文字は区別しない)と一致する店名のリストを表示します。

https://github.com/CodeCandySchool/GourmeListApp_koki/blob/4dfa143f35d02b56a1dcdb1b080b9d0196a00281/GourmeListApp/GourmeListApp/ViewModel/HomeViewModel.swift#L29-L56

## 7.開発環境
Xcode 15.4

iOS 17.2以降が必要です




