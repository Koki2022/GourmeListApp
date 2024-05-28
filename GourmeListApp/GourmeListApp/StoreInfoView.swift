//
//  StoreInfoView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/23.
//

import SwiftUI

//　StoreInfoView:お店情報画面
struct StoreInfoView: View {
    // ホーム画面から受け取った配列パスの参照
    @Binding var mainNavigatePath: [HomeViewPath]
    // 営業時間の内容を反映する変数
    @State private var storeInfoViewBusinessHours: String = ""
    // メモ記入欄の内容を反映する変数
    @State private var storeInfoViewInputMemoText: String = ""
    // actionSheetの状態を管理する変数
    @State private var storeInfoConfirmationDialog: Bool = false
    // アラートの状態を管理する変数。Bool型は先にisをつけると分かりやすい
    @State private var isStoreInfoAlertShown: Bool = false
    var body: some View {
        VStack {
            // 写真を表示
            Spacer()
            Text("ここに写真を表示")
            Spacer()
            // お店の名前欄
            Text("お店の名前")
                .storeInfoTextStyle()
            // 横線
            Divider()
            // 訪問日欄
            Text("訪問日")
                .storeInfoTextStyle()
            // 横線
            Divider()
            // タグ欄
            Text("タグ")
                .storeInfoTextStyle()
            // 横線
            Divider()
            // 電話番号欄
            Text("電話番号")
                .storeInfoTextStyle()
            // 横線
            Divider()
            // 住所欄
            Text("住所")
                .storeInfoTextStyle()
            Spacer()
            Text("地図を表示")
            Spacer()
            // 横線
            Divider()
            // map
            // 営業時間欄
            TextEditor(text: $storeInfoViewBusinessHours)
                .padding()
                .frame(width: 350, height: 200)
                .border(Color.gray, width: 1)
            // メモ記入欄
            TextEditor(text: $storeInfoViewInputMemoText)
                .padding()
                .frame(width: 350, height: 100)
                .border(Color.gray, width: 1)
        }
        // NavigationBarを固定
        .navigationBarTitleDisplayMode(.inline)
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
        // 編集ボタン押した際の設定
        .confirmationDialog("", isPresented: $storeInfoConfirmationDialog) {
            Button(action: {
                // 次の画面へ遷移(お店編集画面へ遷移)
                mainNavigatePath.append(.storeEditView)
            }) {
                Text("お店情報を編集する")
            }
            Button(action: {
                // アラート表示
                isStoreInfoAlertShown.toggle()
            }) {
                Text("削除する")
            }
        }
        .alert("削除しますか？", isPresented: $isStoreInfoAlertShown) {
            // ダイアログ内で行うアクション処理
            // 削除ボタン
            Button(action: {
                // ホーム画面へ遷移
                mainNavigatePath.removeAll()
            }) {
                Text("削除")
            }
            // キャンセルボタン
            Button(action: {
                // キャンセルボタンタップ後のアクションはない
            }) {
                Text("キャンセル")
            }
        } message: {
            // アラートのメッセージ
            Text("この操作は取り消しできません")
        }
    }
}

#Preview {
    StoreInfoView(mainNavigatePath: .constant([]))
}
