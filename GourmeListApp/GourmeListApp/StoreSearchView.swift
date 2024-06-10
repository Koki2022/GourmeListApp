//
//  StoreSearchView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/06/05.
//

import SwiftUI

//　StoreSearchView:お店検索画面
struct StoreSearchView: View {
    //　フォーカスを当てる状態を切り替える変数
    @FocusState private var isFocused: Bool
    // お店検索画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // 入力された文字を反映する変数
    @State private var text: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                OriginalSearchBarView(text: $text, prompt: "キーワードを入力してください")
                    .focused($isFocused)
                    // 画面表示時にキーボードを表示
                    .onAppear {
                        // DispatchQueueのasyncメソッドを使用してビューの構築処理の外でプロパティを設定することでキーボードが自動表示される
                        DispatchQueue.main.async {
                            isFocused = true
                        }
                    }
                Spacer()
                // TextFieldの入力完了直後にお店を検索(機能実装の際にやる)
                // 現段階では文字が入力されたらダミーリスト100個表示。
                if text != "" {
                    List(1..<100) { _ in
                        Button(action: {
                            // お店情報登録画面へ戻り、登録内容が反映される
                            dismiss()
                        }) {
                            // リストを読み込んでいる間はProgressViewを表示(機能実装の際にやる)
                            Text("キーワード入力後,取得した位置情報や店名を表示")
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
            }
        }
    }
}

#Preview {
    StoreSearchView()
}
