//
//  StoreEditView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/30.
//

import SwiftUI
import CoreData
import PhotosUI
import MapKit

//　StoreEditView:お店編集画面
struct StoreEditView: View {
    var store: Stores?
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // ホーム画面から受け取った配列パスの参照
    @Binding var navigatePath: [HomeNavigatePath]
    // StoreEditViewModelクラスをインスタンス化
    @StateObject private var viewModel = StoreEditViewModel()
    // 選択されたタグを格納するための配列
    @State private var selectedTags: [String] = []
    // お店検索画面の管理状態
    @State private var isStoreSearchVisible: Bool = false
    // 訪問日設定画面の管理状態
    @State private var isVisitDateVisible: Bool = false
    // タグ選択画面の管理状態
    @State private var isTagSelectionVisible: Bool = false
    // 画像削除時のアラート表示
    @State private var isDeleteImageAlertVisible: Bool = false

    var body: some View {
        Spacer()
        // スクリーン画面
        ScrollView {
            VStack {
                // 写真追加画面は横スクロールでインジケータ非表示
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // 配列内にUIImageデータが存在すれば画像を表示
                        if !viewModel.editViewDetailData.selectedImages.isEmpty {
                            // 画像の数だけループ処理で表示する
                            // indicesでインデックスを取得して選択した画像を削除する
                            ForEach(viewModel.editViewDetailData.selectedImages.indices, id: \.self) { index in
                                let image = viewModel.editViewDetailData.selectedImages[index]
                                // フォトピッカーを表示するView
                                PhotosPicker(selection: $viewModel.editViewDetailData.selectedItems, selectionBehavior: .ordered) {
                                    Image(uiImage: image)
                                        // 画像サイズを変更可能にする
                                        .resizable()
                                        //  アスペクト比を維持しながら指定されたフレームを埋める
                                        .scaledToFill()
                                        .frame(width: 120, height: 80)
                                        // フレームからはみ出た部分を切り取る
                                        .clipped()
                                        .padding(5)
                                }
                                // 画像長押しでメニュー表示
                                .contextMenu(menuItems: {
                                    // 削除ボタン
                                    Button("画像を削除", role: .destructive) {
                                        //　削除対象のインデックスを追加
                                        viewModel.editViewDetailData.selectedIndexes.insert(index)
                                        // 削除時のアラート表示
                                        isDeleteImageAlertVisible.toggle()
                                    }
                                })
                            }
                        }
                        // フォトピッカーを表示するView
                        PhotosPicker(selection: $viewModel.editViewDetailData.selectedItems, selectionBehavior: .ordered) {
                            Text("+")
                                .font(.system(size: 30))
                                .frame(width: 120, height: 80)
                                .foregroundStyle(Color.black)
                                .background(Color.gray.opacity(0.4))
                                .padding([.leading, .trailing], 5)
                        }
                        // onChangeでPhotosPickerItem型プロパティを監視し、アイテム選択を検知
                        .onChange(of: viewModel.editViewDetailData.selectedItems) { _, items in
                            // 非同期処理
                            Task {
                                // 選択画像を読み込む処理
                                await viewModel.loadSelectedImages(items: items)
                            }
                        }
                    }
                }
                Divider()
                // 店名欄
                HStack {
                    Text("お店の名前")
                        .storeInfoTextStyle()
                    // 店名を記載するスペース
                    TextField("", text: $viewModel.editViewDetailData.storeName)
                        // 最大幅
                        .frame(maxWidth: .infinity)
                    //　虫眼鏡
                    Button(action: {
                        // お店検索画面へ遷移
                        isStoreSearchVisible.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                Divider()
                // 訪問状況欄
                HStack {
                    Text("訪問状況")
                        .storeInfoTextStyle()
                    // Picker
                    Picker("訪問状況を選択", selection: $viewModel.visitationStatus) {
                        Text("行った").tag(VisitationStatus.visited)
                        Text("気になる").tag(VisitationStatus.interested)
                    }
                    Spacer()
                }
                Divider()
                // 訪問日欄。訪問状況で行ったを選択した場合に表示される
                if viewModel.visitationStatus == .visited {
                    HStack {
                        Text("訪問した日")
                            .storeInfoTextStyle()
                        // 訪問日設定シートを有効にする
                        Button(action: {
                            isVisitDateVisible.toggle()
                        }) {
                            Text("\(viewModel.editViewDetailData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
                                .frame(width: 112)
                                .foregroundStyle(.black)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.3)))
                                .padding(10)
                        }
                        Spacer()
                    }
                    Divider()
                }
                // タグ欄
                HStack {
                    Text("タグ")
                        .storeInfoTextStyle()
                    // 選択中のタグがある時,全てのタグを表示
                    if !selectedTags.isEmpty {
                        // 横スクロールでインジケータ非表示
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
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
                    Button(action: {
                        // タグ選択画面へ遷移
                        isTagSelectionVisible.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                Divider()
                // メモ記入欄
                TextEditor(text: $viewModel.editViewDetailData.memo)
                    .storeInfoTextFieldStyle(
                        frameHeight: 100,
                        borderColor: .gray,
                        borderWidth: 1
                    )
                    // プレースホルダーを追加
                    .overlay(alignment: .center) {
                        // 未入力時、プレースホルダーを表示
                        if viewModel.editViewDetailData.memo.isEmpty {
                            Text("メモ記入欄")
                                .allowsHitTesting(false) // タップ判定を無効化
                                .foregroundStyle(Color(uiColor: .placeholderText))
                        }
                    }
                // 営業時間欄
                TextEditor(text: $viewModel.editViewDetailData.businessHours)
                    .storeInfoTextFieldStyle(
                        frameHeight: 200,
                        borderColor: .gray,
                        borderWidth: 1
                    )
                    // プレースホルダーを追加
                    .overlay(alignment: .center) {
                        // 未入力時、プレースホルダーを表示
                        if viewModel.editViewDetailData.businessHours.isEmpty {
                            Text("営業時間")
                                .allowsHitTesting(false) // タップ判定を無効化
                                .foregroundStyle(Color(uiColor: .placeholderText))
                        }
                    }
                Divider()
                // 電話番号欄
                HStack {
                    Text("電話番号")
                        .storeInfoTextStyle()
                    // 電話番号欄
                    TextField("", text: $viewModel.editViewDetailData.phoneNumber)
                }
                Divider()
                HStack {
                    // 住所欄
                    Text("住所")
                        .storeInfoTextStyle()
                    TextField("", text: $viewModel.editViewDetailData.address)
                        // 入力完了直後に住所を検索
                        .onSubmit {
                            searchAddress()
                        }
                }
                .padding([.bottom], 5)
                // 地図
                Map(position: $viewModel.editViewDetailData.position) {
                    if let location = viewModel.editViewDetailData.selectedLocation {
                        Marker(item: location)
                    }
                }
                .frame(height: 200)
                Divider()
            }
            .padding(.horizontal, 16)
            // 選択画像消去のアラート
            .alert("削除しますか？", isPresented: $isDeleteImageAlertVisible) {
                Button("この画像を削除", role: .destructive) {
                    // 選択した画像を削除する
                    viewModel.deleteSelectedImages()
                }
                Button("キャンセル", role: .cancel) {}
            }
            // お店検索画面を表示する際の設定
            .fullScreenCover(isPresented: $isStoreSearchVisible) {
                StoreSearchView()
            }
            // 訪問日画面を表示する際の設定
            .sheet(isPresented: $isVisitDateVisible) {
                VisitDateView(visitDate: $viewModel.editViewDetailData.visitDate)
                    // シートの高さをカスタマイズ
                    .presentationDetents([.height(280)])
            }
            // タグ選択画面を表示する際の設定
            .sheet(isPresented: $isTagSelectionVisible) {
                // タグ追加画面を表示
                TagAddView(selectedTags: $selectedTags)
                    // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
                    .presentationDetents([
                        .medium,
                        .large
                    ])
            }
        }
        // NavigationBarを固定する
        .navigationBarTitleDisplayMode(.inline)
        // ナビゲーションタイトルの文字サイズを変更
        .toolbar {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店情報の編集")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
            }
            // ボトムバーにお店リストに編集内容追加ボタンを作成
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    // 変更した情報を保存
                    saveStoreInfo(viewContext: viewContext)
                    // お店情報画面に遷移
                    navigatePath.removeLast()
                }) {
                    Text("編集内容を追加する")
                        .navigationBottomBarStyle()
                }
            }
        }
        // 画面表示時にデータをセット
        .onAppear {
            setUpStores(store: store)
        }
    }
    // 編集画面で変更した内容を保存
    func saveStoreInfo(viewContext: NSManagedObjectContext) {
        // 画像保存処理
        if viewModel.editViewDetailData.selectedImages.isEmpty {
            // 画像ない際の出力
            print("画像なし")
        } else {
            // 一時的にファイル名を格納する配列を用意
            var newFileNames: [String] = []
            // UIImage型のデータを取り出す
            for image in viewModel.editViewDetailData.selectedImages {
                // ファイル名を取得する関数の引数にUIImage型データを渡し、取得したファイル名をアンラップして処理する
                if let unwrappedFileName = viewModel.saveImageAndGetFileName(image: image) {
                    // ファイル名を格納
                    newFileNames.append(unwrappedFileName)
                }
            }
            // ファイル名を結合してStoresEntityのfileNameAttributeへ格納
            store?.fileName = newFileNames.joined(separator: ",")
        }
        // 店名をStoresEntityのnameAttributeに格納
        store?.name = viewModel.editViewDetailData.storeName
        // 選択した訪問状況をStoresEntityのvisitationStatusへ格納
        store?.visitationStatus = viewModel.visitationStatus.rawValue
        // 入力した日付をStoresEntityのvisitDateAttributeへ格納
        store?.visitDate = viewModel.editViewDetailData.visitDate
        // 選択したタグをStoresEntityのselectedTagAttributeへ格納
        store?.selectedTag = selectedTags.joined(separator: ",")
        // メモ内容をStoresEntityのmemoAttributeに格納
        store?.memo = viewModel.editViewDetailData.memo
        // 営業時間の内容をStoresEntityのbusinessHoursAttributeに格納
        store?.businessHours = viewModel.editViewDetailData.businessHours
        // 電話番号の内容をStoresEntityのphoneNumberAttributeに格納
        store?.phoneNumber = viewModel.editViewDetailData.phoneNumber
        // 住所の内容をStoresEntityのaddressAttributeに格納
        store?.address = viewModel.editViewDetailData.address

        do {
            // CoreDataに保存
            try viewContext.save()
            print("CoreData 店名編集完了: \(store?.name ?? "")")
            print("CoreData 訪問状況の管理番号の編集完了: \(viewModel.visitationStatus.rawValue)")
            print("CoreData 訪問日編集完了: \(viewModel.editViewDetailData.visitDate)")
            print("CoreData 選択したタグの編集完了: \(selectedTags)")
            print("CoreData メモ編集完了: \(viewModel.editViewDetailData.memo)")
            print("CoreData 営業時間編集完了: \(viewModel.editViewDetailData.businessHours)")
            print("CoreData 電話番号編集完了: \(viewModel.editViewDetailData.phoneNumber)")
            print("CoreData 住所編集完了: \(viewModel.editViewDetailData.address)")
        } catch {
            print("CoreData ERROR: \(error)")
        }
    }

    // 画面起動時にデータを取得
    func setUpStores(store: Stores?) {
        // アンラップされた値を新しい定数storesに代入。storesがnilの場合、処理を抜け出す
        guard let store = store else { return }
        // ファイル名からUIImageを作成する
        loadImagesFromFileNames(fileNames: store.fileName)
        // 店名データを取得
        viewModel.editViewDetailData.storeName = store.name ?? "店名未記入"
        // 訪問状況ステータスを取得
        viewModel.visitationStatus = VisitationStatus(rawValue: store.visitationStatus) ?? .none
        // 訪問日時データ
        viewModel.editViewDetailData.visitDate = store.visitDate ?? Date()
        // タグデータ　selectedTagが空なら空の配列を返す。値があるなら分割してselectedTagsに格納
        selectedTags = store.selectedTag?.isEmpty ?? true ? [] : store.selectedTag!.components(separatedBy: ",")
        // メモの内容を取得
        viewModel.editViewDetailData.memo = store.memo ?? "メモ未記入"
        // 営業時間のデータ
        viewModel.editViewDetailData.businessHours = store.businessHours ?? "営業時間未記入"
        // 電話番号データ
        viewModel.editViewDetailData.phoneNumber = store.phoneNumber ?? "電話番号未記入"
        // 住所データ
        viewModel.editViewDetailData.address = store.address ?? "住所未記入"
        // 住所検索
        searchAddress()
    }
    // ファイル名を取得してUIImageを作成する関数
    func loadImagesFromFileNames(fileNames: String?) {
        // アンラップされた値を新しい定数fileNamesに代入。nilの場合、処理を抜け出す
        guard let fileNames = fileNames else { return }
        // 取得したファイル名をカンマ区切りで配列に格納
        let fileNameArray = fileNames.components(separatedBy: ",")
        // compactMapでnilを除いて配列の値を渡す
        viewModel.editViewDetailData.selectedImages = fileNameArray.compactMap { fileName in
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
        request.naturalLanguageQuery = viewModel.editViewDetailData.address
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
                self.viewModel.editViewDetailData.selectedLocation = firstItem
                // 検索結果の座標を中心に新しい地図領域を作成
                self.viewModel.editViewDetailData.position = .region(MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}

#Preview {
    StoreEditView(navigatePath: .constant([]))
}
