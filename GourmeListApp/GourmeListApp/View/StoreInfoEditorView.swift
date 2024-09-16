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
    // フォトピッカー内で選択した複数アイテムを保持するプロパティ
    @Binding var selectedItems: [PhotosPickerItem]
    // PhotosPickerItem -> UIImageに変換した複数のアイテムを格納するプロパティ
    @Binding var selectedImages: [UIImage]
    //　店名の内容を反映する変数。
    @Binding var storeName: String
    // お店検索画面シートの状態を管理する変数。
    @Binding var isStoreSearchVisible: Bool
    //　訪問状況Pickerの識別値を管理する変数
    @Binding var visitStatusTag: Int
    // 訪問日を設定するシートの状態を管理する変数。
    @Binding var isVisitDateVisible: Bool
    //　訪問日を設定するカレンダー。現在の日時を取得
    @Binding var visitDate: Date
    // タグ選択画面のシートの状態を管理する変数。
    @Binding var isTagSelectionVisible: Bool
    // メモ記入欄の内容を反映する変数。
    @Binding var memo: String
    // 営業時間の内容を反映する変数。
    @Binding var businessHours: String
    //　電話番号を反映する変数。
    @Binding var phoneNumber: String
    //　郵便番号を反映する変数。
    @Binding var postalCode: String
    //　住所を反映する変数。
    @Binding var address: String
    var body: some View {
        VStack {
            // 写真追加画面は横スクロールでインジケータ非表示
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    // 配列内にUIImageデータが存在すれば画像を表示
                    if !selectedImages.isEmpty {
                        // 画像の数だけループ処理で表示する
                        ForEach(selectedImages, id: \.self) { image in
                            // フォトピッカーを表示するView
                            PhotosPicker(selection: $selectedItems, selectionBehavior: .ordered) {
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
                        }
                    }
                    // フォトピッカーを表示するView
                    PhotosPicker(selection: $selectedItems, selectionBehavior: .ordered) {
                        Text("+")
                            .font(.system(size: 30))
                            .frame(width: 120, height: 80)
                            .foregroundStyle(Color.black)
                            .background(Color.gray.opacity(0.4))
                            .padding([.leading, .trailing], 5)
                    }
                    // onChangeでPhotosPickerItem型プロパティを監視
                    // アイテム選択を検知してUIImageへの変換処理を行う
                    .onChange(of: selectedItems) { _, items in
                        // 非同期処理
                        Task {
                            selectedImages = []
                            // UIImageへの変換処理が完了したアイテムを配列に格納
                            for item in items {
                                // 選択アイテムをDataに変換(nilで処理終了)
                                guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                                // DataをUIImageに変換(nilで処理終了)
                                guard let uiImage = UIImage(data: data) else { continue }
                                // UIImage型プロパティに保存
                                selectedImages.append(uiImage)
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
                TextField("", text: $storeName)
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
                Picker("訪問状況を選択", selection: $visitStatusTag) {
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
                    Text("\(visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
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
            TextEditor(text: $memo)
                .storeInfoTextFieldStyle(
                    frameHeight: 100,
                    borderColor: .gray,
                    borderWidth: 1
                )
                // プレースホルダーを追加
                .overlay(alignment: .center) {
                    // 未入力時、プレースホルダーを表示
                    if memo.isEmpty {
                        Text("メモ記入欄")
                            .allowsHitTesting(false) // タップ判定を無効化
                            .foregroundStyle(Color(uiColor: .placeholderText))
                    }
                }
            // 営業時間欄
            TextEditor(text: $businessHours)
                .storeInfoTextFieldStyle(
                    frameHeight: 200,
                    borderColor: .gray,
                    borderWidth: 1
                )
                // プレースホルダーを追加
                .overlay(alignment: .center) {
                    // 未入力時、プレースホルダーを表示
                    if businessHours.isEmpty {
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
                TextField("", text: $phoneNumber)
            }
            Divider()
            // 郵便番号欄
            HStack {
                Text("郵便番号")
                    .storeInfoTextStyle()
                TextField("", text: $postalCode)
            }
            Divider()
            HStack {
                // 住所欄
                Text("住所")
                    .storeInfoTextStyle()
                TextField("", text: $address)
            }
            .padding([.bottom], 5)
            // 地図
            Map()
                .frame(height: 200)
            Divider()
        }
        .padding(.horizontal, 16)
        // お店検索画面を表示する際の設定
        .fullScreenCover(isPresented: $isStoreSearchVisible) {
            StoreSearchView()
        }
        // 訪問日画面を表示する際の設定
        .sheet(isPresented: $isVisitDateVisible) {
            VisitDayView(visitDate: $visitDate)
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
}
