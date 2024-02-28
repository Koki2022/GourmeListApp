//
//  ContentView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2023/12/20.
//

// Run実行時にSandbox: ... deny(1) file-read-data エラー
// Podfile.lockにデフォルトでアクセスできない(Build PhaseのCheck Pod欄に情報あり)
// Build Settings の User Script Sandboxing を No にするとエラー解決

import SwiftUI

//　HomeView:お店一覧画面(ホーム画面)
struct HomeView: View {
    // 変数の順序は関連性に基づくグループ、プロパティラッパーの種類、アクセス修飾子、使用される順を意識
    // 画面遷移全体のナビゲーションの状態を管理する配列パス。private変数の中で一番先に使用される変数なので一番上に記載。
    @State private var mainNavigatePath: [GourmeListPath] = []
    // 入力された内容を反映する変数
    @State private var homeSearchInputText: String = ""
    // タグ選択画面のシートの状態を管理する変数。Bool型は先にisをつけると分かりやすい
    @State private var isTagSelectSheetShown: Bool = false
    var body: some View {
        // NavigationStackと配列パスの紐付け
        NavigationStack(path: $mainNavigatePath) {
            VStack {
                // TextFiledの色を後で設定
                TextField("🔍キーワードを入力してください", text: $homeSearchInputText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                // 行ったリストとこれからリストのタブ作成

                HStack {
                    // タグボタン
                    Button(action: {
                        // ハーフモーダルでタグ選択画面のシートを表示
                        isTagSelectSheetShown.toggle()
                    }) {
                        Text("タグ")
                            .font(.system(size: 20))
                            .frame(width: 70, height: 45)
                            .foregroundColor(Color.black)
                            .background(Color.yellow)
                            .cornerRadius(5)
                            .padding(10)
                    }
                    // タグボタンを左端に配置
                    Spacer()
                }
                // ダミーリスト100個用意
                List(1..<100) { _ in
                    Button(action: {
                        // お店情報画面へ遷移
                        mainNavigatePath.append(.storeInfoView)
                    }) {
                        Text("ダミー")
                            .foregroundStyle(.black)
                    }
                }
            }
            // 遷移先のビューをそれぞれ定義
            .navigationDestination(for: GourmeListPath.self) { value in
                switch value {
                // お店情報画面のビューを定義
                case .storeInfoView:
                    StoreInfoView(mainNavigatePath: $mainNavigatePath)
                // お店編集画面のビューを定義
                case .storeEditView:
                    StoreEditView(mainNavigatePath: $mainNavigatePath)
                // お店検索画面のビューを定義
                case .storeSearchView:
                    StoreSearchView(mainNavigatePath: $mainNavigatePath)
                // お店登録画面のビューを定義
                case .storeRegistrationView:
                    StoreRegistrationView(mainNavigatePath: $mainNavigatePath)
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
                    Text("一覧")
                        .font(.system(size: 30))
                        .fontWeight(.heavy)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // お店検索画面へ遷移
                        mainNavigatePath.append(.storeSearchView)
                    }) {
                        Text("お店を追加")
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
    HomeView()
}
