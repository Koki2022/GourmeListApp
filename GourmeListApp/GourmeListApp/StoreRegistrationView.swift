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
    @Environment(\.dismiss) private var storeRegistrationViewDismiss
    // お店登録画面から派生するナビゲーションの状態を管理する配列パス
    @State private var storeRegistrationViewPath: [StoreRegistrationViewPath] = []
    //　店名の内容を反映する変数。
    @State private var inputStoreRegistrationViewStoreName: String = ""
    //　訪問状況を管理する変数
    @State private var selectionStoreRegistrationViewVisitStatus: String = "行った"
    // 訪問日を設定するシートの状態を管理する変数。
    @State private var isVisitDaySheetShown: Bool = false
    //　訪問日を設定するカレンダー。現在の日時を取得
    @State private var datetimeVisitDay: Date = Date()
    // タグ選択画面のシートの状態を管理する変数。Bool型は先にisをつけると分かりやすい
    @State private var isTagSelectSheetShown: Bool = false
    //　電話番号を反映する変数。
    @State private var inputStoreRegistrationViewPhoneNumber: String = ""
    //　郵便番号を反映する変数。
    @State private var inputStoreRegistrationViewPostalCode: String = ""
    //　住所を反映する変数。
    @State private var inputStoreRegistrationViewAddress: String = ""
    // 営業時間の内容を反映する変数。LowerCamelCaseで記載し直しました。
    @State private var inputStoreRegistrationViewBusinessHours: String = ""
    // メモ記入欄の内容を反映する変数。LowerCamelCaseで記載し直しました。
    @State private var inputStoreRegistrationViewMemoText: String = ""
    var body: some View {
        // NavigationStackと配列パスの紐付け
        NavigationStack(path: $storeRegistrationViewPath) {
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
                            // ダミーで写真アイコンを用意
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
                    Spacer()
                    Divider()
                    // 店名欄
                    HStack {
                        Text("お店の名前")
                            .foregroundStyle(Color.gray)
                        // 店名を記載するスペース
                        TextField("", text: $inputStoreRegistrationViewStoreName)
                            // 最大幅
                            .frame(maxWidth: .infinity)
                        //　虫眼鏡
                        Button(action: {
                            // お店検索画面へ遷移
                            storeRegistrationViewPath.append(.storeSearchView)
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    Divider()
                    // 訪問状況欄
                    HStack {
                        Text("訪問の状況")
                            .foregroundStyle(Color.gray)
                        // Picker
                        Picker("訪問状況を選択", selection: $selectionStoreRegistrationViewVisitStatus) {
                            Text("行った")
                        }
                        Spacer()
                    }
                    Divider()
                    // 訪問日欄。訪問状況で行ったを選択した場合に表示される
                    HStack {
                        Text("訪問した日")
                            .foregroundStyle(Color.gray)
                        // 訪問日設定シートを有効にする
                        Button(action: {
                            isVisitDaySheetShown.toggle()
                        }) {
                            Text("\(datetimeVisitDay, format: Date.FormatStyle(date: .numeric, time: .omitted))")
                        }
                        Spacer()
                    }
                    Divider()
                    // タグ欄
                    HStack {
                        Text("タグ")
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Button(action: {
                            // タグ選択画面へ遷移
                            isTagSelectSheetShown.toggle()
                        }) {
                            Image(systemName: "plus.circle")

                        }
                    }
                    // メモ記入欄
                    TextEditor(text: $inputStoreRegistrationViewMemoText)
                        .padding()
                        .frame(height: 100)
                        .border(Color.gray, width: 1)
                        // プレースホルダーを追加
                        .overlay(alignment: .center) {
                            // 未入力時、プレースホルダーを表示
                            if inputStoreRegistrationViewMemoText.isEmpty {
                                Text("メモ記入欄")
                                    .allowsHitTesting(false) // タップ判定を無効化
                                    .foregroundStyle(Color(uiColor: .placeholderText))
                            }
                        }
                    // 営業時間欄
                    TextEditor(text: $inputStoreRegistrationViewBusinessHours)
                        .padding()
                        .frame(height: 200)
                        .border(Color.gray, width: 1)
                        // プレースホルダーを追加
                        .overlay(alignment: .center) {
                            // 未入力時、プレースホルダーを表示
                            if inputStoreRegistrationViewBusinessHours.isEmpty {
                                Text("営業時間")
                                    .allowsHitTesting(false) // タップ判定を無効化
                                    .foregroundStyle(Color(uiColor: .placeholderText))
                            }
                        }
                    Divider()
                    // 電話番号欄
                    HStack {
                        Text("電話番号")
                            .foregroundStyle(Color.gray)
                        // 電話番号欄
                        TextField("", text: $inputStoreRegistrationViewPhoneNumber)
                    }
                    Divider()
                    // 住所:郵便番号欄
                    HStack {
                        Text("住所")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $inputStoreRegistrationViewPostalCode)
                    }
                    // 住所欄
                    TextField("", text: $inputStoreRegistrationViewAddress)
                    // 地図
                    Map()
                        .frame(height: 200)
                    Divider()
                }
                .padding(.horizontal, 16)
            }
            // 配列パスに追加した値を渡す
            .navigationDestination(for: StoreRegistrationViewPath.self) { value in
                // 遷移先のビューを定義
                switch value {
                case .storeSearchView:
                    StoreSearchView(mainNavigatePath: $storeRegistrationViewPath)
                }
            }
            // NavigationBarを固定する
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションタイトルの文字サイズを変更
            .toolbar {
                // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
                ToolbarItem(placement: .principal) {
                    Text("お店情報の登録")
                        .font(.system(size: 30))
                        .fontWeight(.heavy)
                }
                // ナビゲーション バーの先端に戻るボタン配置
                ToolbarItem(placement: .cancellationAction) {
                    // 戻るボタン
                    Button(action: {
                        // ホーム画面に戻る
                        storeRegistrationViewDismiss()
                    }) {
                        Text("戻る")
                    }
                }
                // ボトムバーにお店リストに追加ボタンを作成
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // 登録した情報を保存
                        // ホーム画面に遷移
                        storeRegistrationViewDismiss()
                    }) {
                        Text("お店リストに追加")
                            .font(.system(size: 20))
                            .frame(width: 350, height: 70)
                            .foregroundStyle(.white)
                            .background(Color.red)
                            .clipShape(.buttonBorder)
                            .padding(10)
                    }
                }
            }
        }
        // 訪問日画面を表示する際の設定
        .sheet(isPresented: $isVisitDaySheetShown) {
            VisitDayView(datetimeVisitDay: $datetimeVisitDay)
                .presentationDetents([.medium])
        }
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $isTagSelectSheetShown) {
            // タグ選択画面を表示
            TagSelectView()
                // ハーフモーダルで表示
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    StoreRegistrationView()
}
