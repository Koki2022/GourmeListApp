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

    var body: some View {
        Spacer()
        // スクリーン画面
        ScrollView {
            VStack {
                // 画像欄
                imageField
                Divider()
                // 店名欄
                storeNameField
                Divider()
                // 訪問状況欄
                visitationStatusField
                Divider()
                // 訪問日欄。訪問状況で行ったを選択した場合に表示される
                if viewModel.visitationStatus == .visited {
                    visitDateField
                    Divider()
                }
                // タグ欄
                tagField
                Divider()
                // メモ記入欄
                memoField
                // 営業時間欄
                businessHoursField
                Divider()
                // 電話番号欄
                phoneNumberField
                Divider()
                // 住所欄
                addressField
                // 地図
                mapField
                Divider()
            }
            .padding(.horizontal, 16)
            // 選択画像消去のアラート
            .alert("削除しますか？", isPresented: $viewModel.isDeleteImageAlertVisible) {
                Button("この画像を削除", role: .destructive) {
                    // 選択した画像を削除する
                    viewModel.deleteSelectedImages()
                }
                Button("キャンセル", role: .cancel) {}
            }
            // 戻るボタンを押した際のアラート処理
            .alert("変更を破棄しますか?", isPresented: $viewModel.isReturnToPreviousVisible) {
                Button("キャンセル", role: .cancel) { }
                Button("OK") {
                    // お店情報画面に遷移
                    navigatePath.removeLast()
                }
            } message: {
                Text("変更中のデータは保存されません")
            }
        }
        // NavigationBarを固定する
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        // ナビゲーションタイトルの文字サイズを変更
        .toolbar {
            // navigationBarItemsを呼び出す
            navigationBarItems
        }
        // お店検索画面を表示する際の設定
        .fullScreenCover(isPresented: $viewModel.isStoreSearchVisible) {
            // 編集画面の店舗概要データとバインディング
            StoreSearchView(storeDetailData: $viewModel.editViewDetailData)
        }
        // 訪問日画面を表示する際の設定
        .sheet(isPresented: $viewModel.isVisitDateVisible) {
            visitDateSheet
        }
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $viewModel.isTagSelectionVisible) {
            tagAddSheet
        }
        // 画面表示時にデータをセット
        .onAppear {
            viewModel.setUpStores(store: store)
        }
    }
    // 画像欄コンポーネント化
    private var imageField: some View {
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
                                viewModel.isDeleteImageAlertVisible.toggle()
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
    }
    // 店名欄コンポーネント化
    private var storeNameField: some View {
        HStack {
            Text("お店の名前")
                .storeInfoTextStyle()
            // 店名を記載するスペース
            TextField("", text: $viewModel.editViewDetailData.storeName)
                .submitLabel(.done)
                // 最大幅
                .frame(maxWidth: .infinity)
            //　虫眼鏡
            Button(action: {
                // お店検索画面へ遷移
                viewModel.isStoreSearchVisible.toggle()
            }) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
    // 訪問状況欄コンポーネント化
    private var visitationStatusField: some View {
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
    }
    // 訪問日欄コンポーネント化
    private var visitDateField: some View {
        HStack {
            Text("訪問した日")
                .storeInfoTextStyle()
            // 訪問日設定シートを有効にする
            Button(action: {
                viewModel.isVisitDateVisible.toggle()
            }) {
                Text("\(viewModel.editViewDetailData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
                    .frame(width: 112)
                    .foregroundStyle(.black)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.3)))
                    .padding(10)
            }
            Spacer()
        }
    }
    // タグ欄コンポーネント化
    private var tagField: some View {
        HStack {
            Text("タグ")
                .storeInfoTextStyle()
            // 選択中のタグがある時,全てのタグを表示
            if !viewModel.selectedTags.isEmpty {
                // 横スクロールでインジケータ非表示
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedTags, id: \.self) { tag in
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
                viewModel.isTagSelectionVisible.toggle()
            }) {
                Image(systemName: "plus.circle")
            }
        }
    }
    // メモ欄コンポーネント化
    private var memoField: some View {
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
    }
    // 営業時間欄コンポーネント化
    private var businessHoursField: some View {
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
    }
    // 電話番号欄コンポーネント化
    private var phoneNumberField: some View {
        HStack {
            Text("電話番号")
                .storeInfoTextStyle()
            // 電話番号欄
            TextField("", text: $viewModel.editViewDetailData.phoneNumber)
                .submitLabel(.done)
        }
    }
    // 住所欄コンポーネント化
    private var addressField: some View {
        HStack {
            Text("住所")
                .storeInfoTextStyle()
            TextField("", text: $viewModel.editViewDetailData.address)
                .submitLabel(.done)
                // 入力完了直後に住所を検索
                .onSubmit {
                    viewModel.searchAddress()
                }
        }
        .padding([.bottom], 5)
    }
    // 地図欄コンポーネント化
    private var mapField: some View {
        Map(position: $viewModel.editViewDetailData.position) {
            if let location = viewModel.editViewDetailData.selectedLocation {
                Marker(item: location)
            }
        }
        .frame(height: 200)
    }
    // 訪問日シートコンポーネント化
    private var visitDateSheet: some View {
        VisitDateView(visitDate: $viewModel.editViewDetailData.visitDate)
            // シートの高さをカスタマイズ
            .presentationDetents([.height(280)])
    }
    // タグ追加シートコンポーネント化
    private var tagAddSheet: some View {
        // タグ追加画面を表示
        TagAddView(selectedTags: $viewModel.selectedTags)
            // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
            .presentationDetents([
                .medium,
                .large
            ])
    }
    //　NavigationBarItemをコンポーネント化
    private var navigationBarItems: some ToolbarContent {
        Group {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店情報の編集")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
            }
            // ナビゲーション バーの先端に戻るボタン配置
            ToolbarItem(placement: .cancellationAction) {
                // 戻るボタン
                Button(action: {
                    // 本当に戻るか確認のアラートを出す
                    viewModel.isReturnToPreviousVisible.toggle()
                }) {
                    Text("戻る")
                }
            }
            // ボトムバーにお店リストに編集内容追加ボタンを作成
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    // 変更した情報を保存
                    viewModel.saveStoreInfo(store: store, viewContext: viewContext)
                    // お店情報画面に遷移
                    navigatePath.removeLast()
                }) {
                    Text("編集内容を追加する")
                        .navigationBottomBarStyle()
                }
            }
        }
    }
}

#Preview {
    StoreEditView(navigatePath: .constant([]))
}
