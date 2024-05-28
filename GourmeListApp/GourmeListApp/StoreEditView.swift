//
//  StoreEditView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/30.
//

import SwiftUI

//　StoreEditView:お店編集画面
struct StoreEditView: View {
    // ホーム画面から受け取った配列パスの参照
    @Binding var mainNavigatePath: [HomeViewPath]
    // タグ選択画面のシートの状態を管理する変数。Bool型は先にisをつけると分かりやすい
    @State private var isTagSelectSheetShown: Bool = false
    // 営業時間の内容を反映する変数。LowerCamelCaseで記載し直しました。
    @State private var storeRegistrationViewBusinessHours: String = ""
    // メモ記入欄の内容を反映する変数。LowerCamelCaseで記載し直しました。
    @State private var storeRegistrationViewInputMemoText: String = ""
    var body: some View {
        VStack {
            Spacer()
            Text("写真を登録するスペース")
            Spacer()
            // お店の名前欄
            Text("お店の名前")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            // 横線
            Divider()
            // 訪問について欄
            Text("訪問について")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            // 横線
            Divider()
            // 訪問日欄
            Text("訪問日")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            // 横線
            Divider()
            // タグ欄
            Text("タグ")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            Button(action: {
                // タグ選択画面へ遷移
                isTagSelectSheetShown.toggle()
            }) {
                Text("タグ追加")
                    .frame(width: 70, height: 20)
                    .foregroundStyle(.white)
                    .background(Color.gray)
                    .clipShape(.buttonBorder)
                    .padding(10)
            }
            // 横線
            Divider()
            // 電話番号欄
            Text("電話番号")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            // 横線
            Divider()
            // 住所欄
            Text("住所")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            Spacer()
            Text("地図を表示")
            Spacer()
            // 横線
            Divider()
            // map
            // 営業時間欄
            TextEditor(text: $storeRegistrationViewBusinessHours)
                .padding()
                .frame(width: 350, height: 200)
                .border(Color.gray, width: 1)
            // メモ記入欄
            TextEditor(text: $storeRegistrationViewInputMemoText)
                .padding()
                .frame(width: 350, height: 100)
                .border(Color.gray, width: 1)
            Button(action: {
                // お店編集画面を閉じて一覧画面へ遷移
                mainNavigatePath.removeAll()
            }) {
                Text("完了")
                    .frame(width: 350, height: 70)
                    .foregroundStyle(.white)
                    .background(Color.red)
                    .clipShape(.buttonBorder)
                    .padding(10)
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
    StoreEditView(mainNavigatePath: .constant([]))
}
