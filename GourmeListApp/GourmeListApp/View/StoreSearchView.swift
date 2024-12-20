//
//  StoreSearchView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/06/05.
//

import SwiftUI
import GooglePlaces

//　StoreSearchView:お店検索画面
struct StoreSearchView: View {
    // StoreSearchViewModelクラスをインスタンス化
    @StateObject private var viewModel = StoreSearchViewModel()
    //　フォーカスを当てる状態を切り替える変数
    @FocusState private var isFocused: Bool
    // お店検索画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                OriginalSearchBarView(text: $viewModel.text, prompt: "店名や地名で検索できます")
                    .focused($isFocused)
                    // 入力中のtextの値を監視
                    .onChange(of: viewModel.text) { _, newText in
                        // 検索候補を更新
                        viewModel.performSearch(query: newText)
                    }
                    // 画面表示時に非同期でキーボードを表示
                    .task {
                        isFocused = true
                    }
                Spacer()
                // 検索結果がある場合店舗リストを表示
                if !viewModel.searchResults.isEmpty {
                    searchResultsListView
                }
            }
            // NavigationBarを固定する
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // navigationBarItemsを呼び出す
                navigationBarItems
            }
        }
    }
    // 店舗リストコンポーネント化
    private var searchResultsListView: some View {
        // 店舗のリスト表示
        List(viewModel.searchResults, id: \.placeID) { result in
            Button(action: {
                // お店情報登録画面へ戻り、登録内容が反映される
                dismiss()
            }) {
                // 場所の内容をテキスト表示
                Text(result.attributedFullText.string)
                    .foregroundStyle(.black)
                    .frame(height: 60)
            }
        }
    }
    //　NavigationBarItemをコンポーネント化
    private var navigationBarItems: some ToolbarContent {
        Group {
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

#Preview {
    StoreSearchView()
}
