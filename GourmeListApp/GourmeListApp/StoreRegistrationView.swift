//
//  StoreRegistrationView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/31.
//

import SwiftUI

//　StoreRegistrationView:お店登録画面
struct StoreRegistrationView: View {
    // ホーム画面から受け取った配列パスの参照
    @Binding var mainNavigatePath: [gourmeListPath]
    // タグ選択画面のシートの状態を管理する変数
    @State private var tagSelectIsShowSheet: Bool = false
    // 営業時間の内容を反映する変数
    @State private var StoreRegistrationViewBusinessHours: String = ""
    // メモ記入欄の内容を反映する変数
    @State private var StoreRegistrationViewInputMemoText: String = ""
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
                tagSelectIsShowSheet.toggle()
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
            TextEditor(text: $StoreRegistrationViewBusinessHours)
                .padding()
                .frame(width: 350, height: 200)
                .border(Color.gray, width: 1)
            // メモ記入欄
            TextEditor(text: $StoreRegistrationViewInputMemoText)
                .padding()
                .frame(width: 350, height: 100)
                .border(Color.gray, width: 1)
            Button(action: {
                // お店編集画面を閉じて一覧画面へ遷移
                mainNavigatePath.removeAll()
            }) {
                Text("お店リストに追加する")
                    .frame(width: 350, height: 70)
                    .foregroundStyle(.white)
                    .background(Color.red)
                    .clipShape(.buttonBorder)
                    .padding(10)
            }
        }
        // NavigationBarを固定する
        .navigationBarTitleDisplayMode(.inline)
        // NavigationBarの背景色を黄色にする
        .toolbarBackground(Color.yellow, for: .navigationBar)
        // 常時背景色が見えるようにする
        .toolbarBackground(.visible, for: .navigationBar)
        // ナビゲーションタイトルの文字サイズを変更
        .toolbar {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店情報の登録")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
            }
        }
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $tagSelectIsShowSheet) {
            // タグ選択画面を表示
            TagSelectView()
                // ハーフモーダルで表示
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    StoreRegistrationView(mainNavigatePath: .constant([]))
}
