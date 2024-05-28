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
    @Binding var mainNavigatePath: [StoreRegistrationViewPath]
    // 入力された内容を反映する変数
    @State private var storeSearchInputText: String = ""
    var body: some View {
        VStack {
            OriginalSearchBarView(inputTagSelectHomeViewTagName: $storeSearchInputText)
            Spacer()
            // ダミーリスト10個用意。実際はキーワード入力後にリストが表示される
            if storeSearchInputText != "" {
                List(1..<100) { _ in
                    Button(action: {
                        // お店情報登録画面へ遷移

                    }) {
                        Text("キーワード入力後,取得した位置情報を店名を表示")
                            .foregroundStyle(.black)
                            // 枠の高さを調整
                            .frame(height: 60)
                    }
                }
            }
        }
        // NavigationBarを固定する
        .navigationBarTitleDisplayMode(.inline)
        // ナビゲーションタイトルの文字サイズを変更
        .toolbar {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店の検索")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
            }
        }
        /* キーワード入力バーを実装
         .searchable(text: $storeSearchInputText, prompt: "キーワードを入力してください") */
    }
}

#Preview {
    StoreSearchView(mainNavigatePath: .constant([]))
}
