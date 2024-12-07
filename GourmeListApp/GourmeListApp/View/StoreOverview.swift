//
//  StoreInfoView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/23.
//

import SwiftUI
import MapKit

//　StoreOverview:店舗概要画面
struct StoreOverview: View {
    // お店データを格納する変数
    var store: Stores?
    // ホーム画面から受け取った配列パスの参照
    @Binding var navigatePath: [HomeNavigatePath]
    // 店舗概要を格納するStoreDetailData型のデータ
    @State private var overViewDetailData: StoreDetailData = StoreDetailData()
    // タブの選択項目を保持する変数
    @State private var selection: Int = 0
    // 訪問状況を管理する変数
    @State private var visitationStatus: VisitationStatus = .none
    // 選択したタグを格納する配列
    @State private var selectedTags: [String] = []
    // メニューを管理するactionSheetの状態を表す変数
    @State private var isMenuVisible: Bool = false
    // お店情報削除の際のアラートを管理する変数
    @State private var isDeleteVisible: Bool = false
    var body: some View {
        Spacer()
        // スクロール機能搭載
        ScrollView {
            VStack {
                // TabView実装
                TabView(selection: $selection) {
                    // selectedImagesが存在する場合の処理
                    if !overViewDetailData.selectedImages.isEmpty {
                        // imageの数だけ画像を表示
                        ForEach(overViewDetailData.selectedImages.indices, id: \.self) { index in
                            Image(uiImage: overViewDetailData.selectedImages[index])
                                // 画像サイズを変更可能にする
                                .resizable()
                                // 表示枠を覆い尽くす最小サイズ
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                // フレームからはみ出た部分を切り取る
                                .clipped()
                                .padding(5)
                                .tag(index)
                        }
                    } else {
                        Text("No Image")
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                // TabViewにframeを実装すると正しく画像が表示される
                .frame(height: 200)
                // 横線
                Divider()
                // お店の名前欄
                HStack {
                    Text("お店の名前")
                        .storeInfoTextStyle()
                    Text(overViewDetailData.storeName)
                    Spacer()
                }
                // 横線
                Divider()
                // もし訪問状況がvisitedならば訪問日欄を表示
                if visitationStatus == .visited {
                    HStack {
                        Text("訪問日")
                            .storeInfoTextStyle()
                        Text("\(overViewDetailData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
                        Spacer()
                    }
                    // 横線
                    Divider()
                }
                // タグ欄
                HStack {
                    Text("タグ")
                        .storeInfoTextStyle()
                    // タグがある時
                    if !selectedTags.isEmpty {
                        // 横スクロールでインジケータを非表示にする
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // selectedTagsの各データを取り出す
                                ForEach(selectedTags, id: \.self) { tag in
                                    Text("# \(tag)")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                // メモ記入欄
                TextEditor(text: $overViewDetailData.memo)
                    // 編集不可モード
                    .disabled(true)
                    .storeInfoTextFieldStyle(frameHeight: 100, borderColor: .gray, borderWidth: 1)
                // 営業時間欄
                TextEditor(text: $overViewDetailData.businessHours)
                    // 編集不可モード
                    .disabled(true)
                    .storeInfoTextFieldStyle(frameHeight: 200, borderColor: .gray, borderWidth: 1)
                // 横線
                Divider()
                // 電話番号欄
                HStack {
                    Text("電話番号")
                        .storeInfoTextStyle()
                    Text(overViewDetailData.phoneNumber)
                    Spacer()
                }
                // 横線
                Divider()
                // 住所欄
                HStack {
                    Text("住所")
                        .storeInfoTextStyle()
                    Text(overViewDetailData.address)
                    Spacer()
                }
                .padding([.bottom], 5)
                // 地図
                Map(position: $overViewDetailData.position) {
                    // 位置情報が存在すればピンを立てる
                    if let location = overViewDetailData.selectedLocation {
                        Marker(item: location)
                    }
                }
                .frame(height: 200)
            }
            .padding(.horizontal, 16)
        }
        // NavigationBarを固定
        .navigationBarTitleDisplayMode(.inline)
        // ナビゲーションタイトル
        .toolbar {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text(overViewDetailData.storeName)
                    .navigationBarTitleStyle()
            }
            // toolbarモディファイアにToolbarItem構造体を渡しtopBarTrailing(右上配置)を指定
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // actionSheetの状態をtrueにする
                    isMenuVisible.toggle()
                }) {
                    Text("編集")
                }
            }
        }
        // 編集ボタン押した際の設定
        .confirmationDialog("", isPresented: $isMenuVisible) {
            Button(action: {
                // 次の画面へ遷移(お店編集画面へ遷移)
                navigatePath.append(.storeEditView)
            }) {
                Text("お店情報を編集する")
            }
            // 削除ボタン実装
            Button("削除する", role: .destructive) {
                // アラート起動
                isDeleteVisible.toggle()
                // このシートを削除する処理
            }
        }
        .alert("削除しますか？", isPresented: $isDeleteVisible) {
            // ダイアログ内で行うアクション処理
            // キャンセルボタン実装
            Button("キャンセル", role: .cancel) {
                // キャンセル実行時の処理
            }
            // 削除ボタン
            Button("削除", role: .destructive) {
                // ホーム画面に戻る
                navigatePath.removeAll()
                // このシートを削除する処理
            }
        } message: {
            // アラートのメッセージ
            Text("この操作は取り消しできません")
        }
        // 画面表示時にお店データを取得する
        .onAppear {
            print("StoreOverview表示")
            setUpStores(store: store)
        }
    }
    // 画面起動時にデータを取得
    private func setUpStores(store: Stores?) {
        // アンラップされた値を新しい定数storesに代入。storesがnilの場合、処理を抜け出す
        guard let store = store else { return }
        // ファイル名からUIImageを作成する
        loadImagesFromFileNames(fileNames: store.fileName)
        // 店名データを取得
        overViewDetailData.storeName = store.name ?? "店名未記入"
        // 訪問状況ステータスを取得
        visitationStatus = VisitationStatus(rawValue: store.visitationStatus) ?? .none
        // 訪問日時データ
        overViewDetailData.visitDate = store.visitDate ?? Date()
        // タグデータ　selectedTagが空なら空の配列を返す。値があるなら分割してselectedTagsに格納
        selectedTags = store.selectedTag?.isEmpty ?? true ? [] : store.selectedTag!.components(separatedBy: ",")
        // メモの内容を取得
        overViewDetailData.memo = store.memo ?? "メモ未記入"
        // 営業時間のデータ
        overViewDetailData.businessHours = store.businessHours ?? "営業時間未記入"
        // 電話番号データ
        overViewDetailData.phoneNumber = store.phoneNumber ?? "電話番号未記入"
        // 住所データ
        overViewDetailData.address = store.address ?? "住所未記入"
        // 住所検索
        searchAddress()
    }
    // ファイル名を取得してUIImageを作成する関数
    private func loadImagesFromFileNames(fileNames: String?) {
        // アンラップされた値を新しい定数fileNamesに代入。nilの場合、処理を抜け出す
        guard let fileNames = fileNames else { return }
        // 取得したファイル名をカンマ区切りで配列に格納
        let fileNameArray = fileNames.components(separatedBy: ",")
        // compactMapでnilを除いて配列の値を渡す
        overViewDetailData.selectedImages = fileNameArray.compactMap { fileName in
            // ドキュメントディレクトリのURLを取得
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            // 保存するファイルのフルパスを作成
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            // fileURLからデータを読み込めたらUIImageオブジェクトを作成
            if let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                return image
            } else {
                return nil
            }
        }
    }
    // 入力された住所を検索する関数
    func searchAddress() {
        // 地図上の特定の場所、施設、住所などを検索するためのリクエストを作成
        let request = MKLocalSearch.Request()
        // 検索項目の文字列に入力した住所を格納
        request.naturalLanguageQuery = overViewDetailData.address
        // 指定された検索リクエストに基づいて地図上の場所を検索するためのクラス
        let search = MKLocalSearch(request: request)
        // 検索を非同期で開始。クロージャ内で検索結果または検索エラーを受け取る。
        search.start { response, error in
            // 検索結果responseが存在するかチェック
            guard let response = response else {
                // 結果がない場合、エラーメッセージを出力して終了
                print("検索エラー: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // 検索結果の最初の項目（mapItems.first）を取得
            if let firstItem = response.mapItems.first {
                // 最初の検索結果を selectedLocation に設定し地図上にマーカーが表示される
                self.overViewDetailData.selectedLocation = firstItem
                // 検索結果の座標を中心に新しい地図領域を作成
                self.overViewDetailData.position = .region(MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}

#Preview {
    StoreOverview(navigatePath: .constant([]))
}
