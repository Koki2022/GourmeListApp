//
//  StoreRegistrationView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/31.
//

import SwiftUI
import PhotosUI
import CoreData
import MapKit

//　StoreRegistrationView:お店登録画面
struct StoreRegistrationView: View {
    // プロパティラッパー @FetchRequestで、データベースよりデータを取得
    @FetchRequest(entity: Stores.entity(), sortDescriptors: []
    ) private var fetchedStores: FetchedResults<Stores>
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // StoreRegistrationViewModelクラスをインスタンス化
    @StateObject private var viewModel = StoreRegistrationViewModel()

    var body: some View {
        NavigationStack {
            Spacer()
            ScrollView {
                VStack {
                    // 写真追加画面は横スクロールでインジケータ非表示
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // 配列内にUIImageデータが存在すれば画像を表示
                            if !viewModel.registrationViewDetailData.selectedImages.isEmpty {
                                // 画像の数だけループ処理で表示する
                                // indicesでインデックスを取得して選択した画像を削除する
                                ForEach(viewModel.registrationViewDetailData.selectedImages.indices, id: \.self) { index in
                                    let image = viewModel.registrationViewDetailData.selectedImages[index]
                                    // フォトピッカーを表示するView
                                    PhotosPicker(selection: $viewModel.registrationViewDetailData.selectedItems, selectionBehavior: .ordered) {
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
                                            viewModel.registrationViewDetailData.selectedIndexes.insert(index)
                                            // 削除時のアラート表示
                                            viewModel.isDeleteImageVisible.toggle()
                                        }
                                    })
                                }
                            }
                            // フォトピッカーを表示するView
                            PhotosPicker(selection: $viewModel.registrationViewDetailData.selectedItems, selectionBehavior: .ordered) {
                                Text("+")
                                    .font(.system(size: 30))
                                    .frame(width: 120, height: 80)
                                    .foregroundStyle(Color.black)
                                    .background(Color.gray.opacity(0.4))
                                    .padding([.leading, .trailing], 5)
                            }
                            // onChangeでPhotosPickerItem型プロパティを監視し、アイテム選択を検知
                            .onChange(of: viewModel.registrationViewDetailData.selectedItems) { _, items in
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
                        TextField("", text: $viewModel.registrationViewDetailData.storeName)
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
                            viewModel.isVisitDateVisible.toggle()
                        }) {
                            Text("\(viewModel.registrationViewDetailData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
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
                        // TagAddViewで選択されたタグを表示
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
                        Spacer()
                        Button(action: {
                            // タグ選択画面へ遷移
                            viewModel.isTagSelectionVisible.toggle()
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                    Divider()
                    // メモ記入欄
                    TextEditor(text: $viewModel.registrationViewDetailData.memo)
                        .storeInfoTextFieldStyle(
                            frameHeight: 100,
                            borderColor: .gray,
                            borderWidth: 1
                        )
                        // プレースホルダーを追加
                        .overlay(alignment: .center) {
                            // 未入力時、プレースホルダーを表示
                            if viewModel.registrationViewDetailData.memo.isEmpty {
                                Text("メモ記入欄")
                                    .allowsHitTesting(false) // タップ判定を無効化
                                    .foregroundStyle(Color(uiColor: .placeholderText))
                            }
                        }
                    // 営業時間欄
                    TextEditor(text: $viewModel.registrationViewDetailData.businessHours)
                        .storeInfoTextFieldStyle(
                            frameHeight: 200,
                            borderColor: .gray,
                            borderWidth: 1
                        )
                        // プレースホルダーを追加
                        .overlay(alignment: .center) {
                            // 未入力時、プレースホルダーを表示
                            if viewModel.registrationViewDetailData.businessHours.isEmpty {
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
                        TextField("", text: $viewModel.registrationViewDetailData.phoneNumber)
                            // 電話番号入力タイプのキーボード
                            .keyboardType(.phonePad)
                    }
                    Divider()
                    HStack {
                        // 住所欄
                        Text("住所")
                            .storeInfoTextStyle()
                        TextField("", text: $viewModel.registrationViewDetailData.address)
                            // 入力完了直後に住所を検索
                            .onSubmit {
                                viewModel.searchAddress()
                            }
                    }
                    .padding([.bottom], 5)
                    // 地図
                    Map(position: $viewModel.registrationViewDetailData.position) {
                        // 位置情報が存在すればピンを立てる
                        if let location = viewModel.registrationViewDetailData.selectedLocation {
                            Marker(item: location)
                        }
                    }
                    .frame(height: 200)
                    Divider()
                }
                .padding(.horizontal, 16)
                // 選択画像消去のアラート
                .alert("削除しますか？", isPresented: $viewModel.isDeleteImageVisible) {
                    Button("この画像を削除", role: .destructive) {
                        // 選択した画像を削除する
                        viewModel.deleteSelectedImages()
                    }
                    Button("キャンセル", role: .cancel) {
                        // 処理なし
                    }
                }
                // お店検索画面を表示する際の設定
                .fullScreenCover(isPresented: $viewModel.isStoreSearchVisible) {
                    StoreSearchView()
                }
                // 訪問日画面を表示する際の設定
                .sheet(isPresented: $viewModel.isVisitDateVisible) {
                    VisitDateView(visitDate: $viewModel.registrationViewDetailData.visitDate)
                        // シートの高さをカスタマイズ
                        .presentationDetents([.height(280)])
                }
                // タグ選択画面を表示する際の設定
                .sheet(isPresented: $viewModel.isTagSelectionVisible) {
                    // タグ追加画面を表示
                    TagAddView(selectedTags: $viewModel.selectedTags)
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
                    Text("お店情報の登録")
                        .navigationBarTitleStyle()
                }
                // ナビゲーション バーの先端に戻るボタン配置
                ToolbarItem(placement: .cancellationAction) {
                    // 戻るボタン
                    Button(action: {
                        // ホーム画面に戻る
                        dismiss()
                    }) {
                        Text("戻る")
                    }
                }
                // ボトムバーにお店リストに追加ボタンを作成
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // 画像のファイル名をCoreDataに保存
                        viewModel.addStoreImages(fetchedStores: fetchedStores, viewContext: viewContext)
                        // 店名をCoreDataに保存
                        viewModel.addStoreNames(viewContext: viewContext)
                        // 訪問状況をCoreDataに保存
                        viewModel.addVisitationStatus(viewContext: viewContext)
                        // 訪問日をCoreDataに保存
                        viewModel.addVisitDate(viewContext: viewContext)
                        // タグをCoreDataに保存
                        viewModel.addSelectedTags(fetchedStores: fetchedStores, viewContext: viewContext)
                        // メモ内容をCoreDataに保存
                        viewModel.addMemo(viewContext: viewContext)
                        // 営業時間をCoreDataに保存
                        viewModel.addBusinessHours(viewContext: viewContext)
                        // 電話番号をCoreDataに保存
                        viewModel.addPhoneNumber(viewContext: viewContext)
                        // 住所をCoreDataに保存
                        viewModel.addAddress(viewContext: viewContext)
                        // ホーム画面に遷移
                        dismiss()
                    }) {
                        Text("お店リストに追加")
                            .navigationBottomBarStyle()
                    }
                }
            }
        }
    }

}

#Preview {
    StoreRegistrationView()
}
