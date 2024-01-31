//
//  StoreInfoView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/23.
//

import SwiftUI

//　StoreInfoView:お店情報画面
struct StoreInfoView: View {
    // 営業時間の内容を反映する変数
    @State private var businessHours: String = ""
    // メモ記入欄の内容を反映する変数
    @State private var inputMemoText: String = ""
    // 編集ボタン押した際のピッカーの内容を保持する変数
    private let postEditingPicker: [String] = ["お店情報を編集する", "削除する"]
    @State private var postEditingSelection: String = "お店情報を編集する"
    // actionSheetの状態を管理する変数
    @State private var storeInfoConfirmationDialog: Bool = false
    // アラートの状態を管理する変数
    @State private var storeInfoIsShowAlert: Bool = false
    // お店情報画面を閉じるための動作を呼び出す変数
    @Environment(\.dismiss) private var storeInfoViewDismiss
    // お店編集画面のシートの状態を管理する変数
    @State private var storeEditIsShowSheet: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                // 写真を表示
                Spacer()
                Text("ここに写真を表示")
                Spacer()
                // お店の名前欄
                Text("お店の名前")
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .foregroundColor(Color.gray)
                // 横線
                Divider()
                // 訪問日欄
                Text("訪問日")
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .foregroundColor(Color.gray)
                // 横線
                Divider()
                // タグ欄
                Text("タグ")
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .foregroundColor(Color.gray)
                // 横線
                Divider()
                // 電話番号欄
                Text("電話番号")
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .foregroundColor(Color.gray)
                // 横線
                Divider()
                // 住所欄
                Text("住所")
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .foregroundColor(Color.gray)
                Spacer()
                Text("地図を表示")
                Spacer()
                // 横線
                Divider()
                // map
                // 営業時間欄
                TextEditor(text: $businessHours)
                    .padding()
                    .frame(width: 350, height: 200)
                    .border(Color.gray, width: 1)
                // メモ記入欄
                TextEditor(text: $inputMemoText)
                    .padding()
                    .frame(width: 350, height: 100)
                    .border(Color.gray, width: 1)
            }
            // navigationStackの遷移先でボタンアイテムを追加する方法
            // NavigationBarを固定
            .navigationBarTitleDisplayMode(.inline)
            // NavigationBarの背景色を変える
            .toolbarBackground(Color.yellow, for: .navigationBar)
            // 常時背景色が見えるようにする
            .toolbarBackground(.visible, for: .navigationBar)
            // ナビゲーションタイトルの文字サイズを変更
            .toolbar {
                // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
                ToolbarItem(placement: .principal) {
                    Text("お店情報")
                        .font(.system(size: 30))
                        .fontWeight(.heavy)
                }
                // toolbarモディファイアにToolbarItem構造体を渡しtopBarTrailing(右上配置)を指定
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // actionSheetの状態をtrueにする
                        storeInfoConfirmationDialog.toggle()
                    }) {
                        Text("編集")
                    }
                }
            }
        }
        // 編集ボタン押した際の設定
        .confirmationDialog("", isPresented: $storeInfoConfirmationDialog) {
            Button(action: {
                // お店情報を編集するボタンをタップした際の処理
                // storeEditIsShowSheetをtrueにする
                storeEditIsShowSheet.toggle()
            }) {
                Text("お店情報を編集する")
            }
            Button(action: {
                // 削除するボタンをタップしたらstoreInfoIsShowAlertの状態をtrueにする
                storeInfoIsShowAlert.toggle()
            }) {
                Text("削除する")
            }
        }
        .alert("削除しますか？", isPresented: $storeInfoIsShowAlert) {
            // ダイアログ内で行うアクション処理
            // 削除ボタン
            Button(action: {
                // 削除ボタンタップ後のアクション
                // お店情報画面を閉じて一覧画面へ遷移
                storeInfoViewDismiss()
            }) {
                Text("削除")
            }
            // キャンセルボタン
            Button(action: {
                // キャンセルボタンタップ後のアクション
            }) {
                Text("キャンセル")
            }
        } message: {
            // アラートのメッセージ
            Text("この操作は取り消しできません")
        }
        // お店情報のシートの設定
        .sheet(isPresented: $storeEditIsShowSheet) {
            StoreEditView()
        }
    }
}

#Preview {
    StoreInfoView()
}
