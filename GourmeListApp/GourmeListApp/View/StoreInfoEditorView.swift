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
    @ObservedObject var storeInfoDataViewModel = StoreInfoViewModel()
    
    var body: some View {
        VStack {
            // 写真追加画面は横スクロールでインジケータ非表示
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    // 配列内にUIImageデータが存在すれば画像を表示
                    if !storeInfoDataViewModel.storeInfoData.selectedImages.isEmpty {
                        // 画像の数だけループ処理で表示する
                        // indicesでインデックスを取得して選択した画像を削除する
                        ForEach(storeInfoDataViewModel.storeInfoData.selectedImages.indices, id: \.self) { index in
                            let image = storeInfoDataViewModel.storeInfoData.selectedImages[index]
                            // フォトピッカーを表示するView
                            PhotosPicker(selection: $storeInfoDataViewModel.storeInfoData.selectedItems, selectionBehavior: .ordered) {
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
                                    storeInfoDataViewModel.storeInfoData.selectedIndexes.insert(index)
                                    // 削除時のアラート表示
                                    storeInfoDataViewModel.isDeleteImageAlertVisible.toggle()
                                }
                            })
                        }
                    }
                    // フォトピッカーを表示するView
                    PhotosPicker(selection: $storeInfoDataViewModel.storeInfoData.selectedItems, selectionBehavior: .ordered) {
                        Text("+")
                            .font(.system(size: 30))
                            .frame(width: 120, height: 80)
                            .foregroundStyle(Color.black)
                            .background(Color.gray.opacity(0.4))
                            .padding([.leading, .trailing], 5)
                    }
                    // onChangeでPhotosPickerItem型プロパティを監視し、アイテム選択を検知
                    .onChange(of: storeInfoDataViewModel.storeInfoData.selectedItems) { _, items in
                        // 非同期処理
                        Task {
                            // 選択画像を読み込む処理
                            await storeInfoDataViewModel.loadSelectedImages(items: items)
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
                TextField("", text: $storeInfoDataViewModel.storeInfoData.storeName)
                // 最大幅
                    .frame(maxWidth: .infinity)
                //　虫眼鏡
                Button(action: {
                    // お店検索画面へ遷移
                    storeInfoDataViewModel.isStoreSearchVisible.toggle()
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
                Picker("訪問状況を選択", selection: $storeInfoDataViewModel.storeInfoData.visitStatusTag) {
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
                    storeInfoDataViewModel.isVisitDateVisible.toggle()
                }) {
                    Text("\(storeInfoDataViewModel.storeInfoData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
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
                    storeInfoDataViewModel.isTagSelectionVisible.toggle()
                }) {
                    Image(systemName: "plus.circle")
                }
            }
            Divider()
            // メモ記入欄
            TextEditor(text: $storeInfoDataViewModel.storeInfoData.memo)
                .storeInfoTextFieldStyle(
                    frameHeight: 100,
                    borderColor: .gray,
                    borderWidth: 1
                )
            // プレースホルダーを追加
                .overlay(alignment: .center) {
                    // 未入力時、プレースホルダーを表示
                    if storeInfoDataViewModel.storeInfoData.memo.isEmpty {
                        Text("メモ記入欄")
                            .allowsHitTesting(false) // タップ判定を無効化
                            .foregroundStyle(Color(uiColor: .placeholderText))
                    }
                }
            // 営業時間欄
            TextEditor(text: $storeInfoDataViewModel.storeInfoData.businessHours)
                .storeInfoTextFieldStyle(
                    frameHeight: 200,
                    borderColor: .gray,
                    borderWidth: 1
                )
            // プレースホルダーを追加
                .overlay(alignment: .center) {
                    // 未入力時、プレースホルダーを表示
                    if storeInfoDataViewModel.storeInfoData.businessHours.isEmpty {
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
                TextField("", text: $storeInfoDataViewModel.storeInfoData.phoneNumber)
            }
            Divider()
            // 郵便番号欄
            HStack {
                Text("郵便番号")
                    .storeInfoTextStyle()
                TextField("", text: $storeInfoDataViewModel.storeInfoData.postalCode)
            }
            Divider()
            HStack {
                // 住所欄
                Text("住所")
                    .storeInfoTextStyle()
                TextField("", text: $storeInfoDataViewModel.storeInfoData.address)
            }
            .padding([.bottom], 5)
            // 地図
            Map()
                .frame(height: 200)
            Divider()
        }
        .padding(.horizontal, 16)
        // 選択画像消去のアラート
        .alert("削除しますか？", isPresented: $storeInfoDataViewModel.isDeleteImageAlertVisible) {
            Button("この画像を削除", role: .destructive) {
                // 選択した画像を削除する
                storeInfoDataViewModel.deleteSelectedImages()
            }
            Button("キャンセル", role: .cancel) {
                // 処理なし
            }
        }
        // お店検索画面を表示する際の設定
        .fullScreenCover(isPresented: $storeInfoDataViewModel.isStoreSearchVisible) {
            StoreSearchView()
        }
        // 訪問日画面を表示する際の設定
        .sheet(isPresented: $storeInfoDataViewModel.isVisitDateVisible) {
            VisitDayView(visitDate: $storeInfoDataViewModel.storeInfoData.visitDate)
            // シートの高さをカスタマイズ
                .presentationDetents([.height(280)])
        }
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $storeInfoDataViewModel.isTagSelectionVisible) {
            // タグ追加画面を表示
            TagAddView()
            // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
                .presentationDetents([
                    .medium,
                    .large
                ])
        }
    }
}

#Preview {
    StoreInfoEditorView()
}
