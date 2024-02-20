//
//  StoreSearchView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/25.
//

import SwiftUI

//　StoreSearchView:お店検索画面
struct StoreSearchView: View {
    // ホーム画面から受け取った配列パスの参照
    @Binding var mainNavigatePath: [gourmeListPath]
    // 入力された内容を反映する変数
    @State private var storeSearchInputText: String = ""
    var body: some View {
        VStack {
            // お店検索時のキーワドを入力する欄
            TextField("🔍キーワードを入力してください", text: $storeSearchInputText)
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
            // ダミーリスト10個用意。実際はキーワード入力後にリストが表示される
            List(1..<10) { _ in
                Button(action: {
                    // お店情報登録画面へ遷移
                    mainNavigatePath.append(.storeRegistrationView)
                }) {
                    Text("実際はキーワード入力後にお店リスト表示")
                        .foregroundStyle(.black)
                }
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
                Text("お店の検索")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
            }
        }
    }
}

#Preview {
    StoreSearchView(mainNavigatePath: .constant([]))
}
