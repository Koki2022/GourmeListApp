//
//  StoreInfoEditorView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/06/15.
//

import SwiftUI
import MapKit

// StoreInfoEditorView:　お店情報の表示・編集をする画面
struct StoreInfoEditorView: View {
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
                    // 自分が撮った写真を追加。ダミーで写真アイコンを用意
                    Button(action: {

                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .frame(width: 100, height: 100)
                            .foregroundStyle(Color.black)
                            .background(Color.gray.opacity(0.4))
                    }
                    // 写真追加する場所
                    Button(action: {

                    }) {
                        Text("+")
                            .font(.system(size: 30))
                            .frame(width: 100, height: 100)
                            .foregroundStyle(Color.black)
                            .background(Color.gray.opacity(0.4))
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
