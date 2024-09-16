//
//  StoreInfoEditorView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/06/15.
//

import SwiftUI
import PhotosUI
import MapKit

// StoreInfoEditorView:　お店情報の表示・編集をする画面
struct StoreInfoEditorView: View {
    // お店情報のデータバインディング
    @Binding var storeInfoData: StoreInfoData
    // お店検索画面の管理状態
    @Binding var isStoreSearchVisible: Bool
    // 訪問日設定画面の管理状態
    @Binding var isVisitDateVisible: Bool
    // タグ選択画面の管理状態
    @Binding var isTagSelectionVisible: Bool
    // 画像削除時のアラート表示
    @State private var isDeleteImageAlertVisible: Bool = false

    var body: some View {
        VStack {
            // 写真追加画面は横スクロールでインジケータ非表示
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    // 配列内にUIImageデータが存在すれば画像を表示
                    if !storeInfoData.selectedImages.isEmpty {
                        // 画像の数だけループ処理で表示する
                        // indicesでインデックスを取得して選択した画像を削除する
                        ForEach(storeInfoData.selectedImages.indices, id: \.self) { index in
                            let image = storeInfoData.selectedImages[index]
                            // フォトピッカーを表示するView
                            PhotosPicker(selection: $storeInfoData.selectedItems, selectionBehavior: .ordered) {
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
                            // 画像長押しでメニュー表示s
                            .contextMenu(menuItems: {
                                // 削除ボタン
                                Button("画像を削除", role: .destructive) {
                                    //　削除対象のインデックスを追加
                                    storeInfoData.selectedIndexes.insert(index)
                                    // 削除時のアラート表示
                                    isDeleteImageAlertVisible.toggle()
                                }
                            })
                        }
                    }
                    // フォトピッカーを表示するView
                    PhotosPicker(selection: $storeInfoData.selectedItems, selectionBehavior: .ordered) {
                        Text("+")
                            .font(.system(size: 30))
                            .frame(width: 120, height: 80)
                            .foregroundStyle(Color.black)
                            .background(Color.gray.opacity(0.4))
                            .padding([.leading, .trailing], 5)
                    }
                    // onChangeでPhotosPickerItem型プロパティを監視
                    // アイテム選択を検知してUIImageへの変換処理を行う
                    .onChange(of: storeInfoData.selectedItems) { _, items in
                        // 非同期処理
                        Task {
                            storeInfoData.selectedImages = []
                            // UIImageへの変換処理が完了したアイテムを配列に格納
                            for item in items {
                                // 選択アイテムをDataに変換(nilで処理終了)
                                guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                                // DataをUIImageに変換(nilで処理終了)
                                guard let uiImage = UIImage(data: data) else { continue }
                                // UIImage型プロパティに保存
                                storeInfoData.selectedImages.append(uiImage)
                            }
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
                TextField("", text: $storeInfoData.storeName)
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
                Picker("訪問状況を選択", selection: $storeInfoData.visitStatusTag) {
                    Text("行った").tag(0)
                    Text("気になる").tag(1)
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
                    Text("\(storeInfoData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
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
            TextEditor(text: $storeInfoData.memo)
                .storeInfoTextFieldStyle(
                    frameHeight: 100,
                    borderColor: .gray,
                    borderWidth: 1
                )
                // プレースホルダーを追加
                .overlay(alignment: .center) {
                    // 未入力時、プレースホルダーを表示
                    if storeInfoData.memo.isEmpty {
                        Text("メモ記入欄")
                            .allowsHitTesting(false) // タップ判定を無効化
                            .foregroundStyle(Color(uiColor: .placeholderText))
                    }
                }
            // 営業時間欄
            TextEditor(text: $storeInfoData.businessHours)
                .storeInfoTextFieldStyle(
                    frameHeight: 200,
                    borderColor: .gray,
                    borderWidth: 1
                )
                // プレースホルダーを追加
                .overlay(alignment: .center) {
                    // 未入力時、プレースホルダーを表示
                    if storeInfoData.businessHours.isEmpty {
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
                TextField("", text: $storeInfoData.phoneNumber)
            }
            Divider()
            // 郵便番号欄
            HStack {
                Text("郵便番号")
                    .storeInfoTextStyle()
                TextField("", text: $storeInfoData.postalCode)
            }
            Divider()
            HStack {
                // 住所欄
                Text("住所")
                    .storeInfoTextStyle()
                TextField("", text: $storeInfoData.address)
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
                deleteSelectedImages()
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
            VisitDayView(visitDate: $storeInfoData.visitDate)
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

    //　選択された画像を削除する関数
    private func deleteSelectedImages() {
        // 配列から要素を削除する際、インデックスがずれるのを防ぐために、インデックスを降順に処理
        let sortedIndexes = storeInfoData.selectedIndexes.sorted(by: >)
        //　取得したインデックスを処理
        for index in sortedIndexes {
            // indexが画像の数の範囲内であることをチェック
            guard index < storeInfoData.selectedImages.count else {
                print("indexが画像の数の範囲外です")
                // インデックスが範囲外なら次のインデックスのループ処理に進む
                continue
            }
            // 画像を削除
            //　selectedImagesからindexに対応する画像を削除
            storeInfoData.selectedImages.remove(at: index)
        }
        // 削除した際に写真ライブラリのアイテムの選択状態を解除するため、selectedItemsも更新
        // enumerated:PhotosPickerItemの配列にインデックスを付与する
        storeInfoData.selectedItems = storeInfoData.selectedItems.enumerated().compactMap { (index, item) in
            // compactMap:nilを返すと、その要素はPhotosPickerItemの配列に含まれない
            // 選択したインデックス番号を含んでいるものは削除対象としてnilとして扱い、PhotosPickerItem配列のitemから除外する
            return storeInfoData.selectedIndexes.contains(index) ? nil : item
        }
        // 選択をリセット
        storeInfoData.selectedIndexes.removeAll()
    }
}
