//
//  StoreRegistrationView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/31.
//

import SwiftUI
import MapKit

//　StoreRegistrationView:お店登録画面
struct StoreRegistrationView: View {
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    //　店名の内容を反映する変数。
    @State private var storeName: String = ""
    // お店検索画面シートの状態を管理する変数。
    @State private var isStoreSearchVisible: Bool = false
    //　訪問状況Pickerの識別値を管理する変数
    @State private var visitStatusTag: Int = 0
    // 訪問日を設定するシートの状態を管理する変数。
    @State private var isVisitDateVisible: Bool = false
    //　訪問日を設定するカレンダー。現在の日時を取得
    @State private var visitDate: Date = Date()
    // タグ選択画面のシートの状態を管理する変数。
    @State private var isTagSelectionVisible: Bool = false
    // メモ記入欄の内容を反映する変数。
    @State private var memo: String = ""
    // 営業時間の内容を反映する変数。
    @State private var businessHours: String = ""
    //　電話番号を反映する変数。
    @State private var phoneNumber: String = ""
    //　郵便番号を反映する変数。
    @State private var postalCode: String = ""
    //　住所を反映する変数。
    @State private var address: String = ""
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    // 写真は横スクロールで表示
                    // インジケータを非表示にする
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // 自分が撮った写真を追加
                            // ダミーで写真アイコンを用意
                            Button(action: {
                                //　処理
                            }) {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(Color.black)
                                    .background(Color.gray.opacity(0.4))
                            }
                            Button(action: {
                                //　処理
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
                        // 登録した情報を保存
                        // ホーム画面に遷移
                        dismiss()
                    }) {
                        Text("お店リストに追加")
                            .navigationBottomBarStyle()
                    }
                }
            }
        }
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

#Preview {
    StoreRegistrationView()
}
