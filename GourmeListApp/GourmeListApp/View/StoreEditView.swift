//
//  StoreEditView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/30.
//

import SwiftUI
import PhotosUI
import MapKit

//　StoreEditView:お店編集画面
struct StoreEditView: View {
    // プロパティラッパー @FetchRequestで、データベースよりデータを取得
    @FetchRequest(entity: Stores.entity(), sortDescriptors: []
    ) private var fetchedStores: FetchedResults<Stores>
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // ホーム画面から受け取った配列パスの参照
    @Binding var navigatePath: [HomeNavigatePath]
    // StoreEditViewModelクラスをインスタンス化
    @StateObject private var viewModel = StoreEditViewModel()
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
                // タグ欄
                HStack {
                    Text("タグ")
                        .storeInfoTextStyle()
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
                }
                .padding([.bottom], 5)
                // 地図
                Map()
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
                Button("キャンセル", role: .cancel) {
                    // 処理なし
                }
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
                TagAddView()
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
                    // 登録した情報を保存
                    viewModel.addStoreImages(fetchedStores: fetchedStores, viewContext: viewContext)
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
