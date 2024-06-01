//
//  HomeView.swift
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
    @State private var mainNavigatePath: [HomeViewPath] = []
    // ホーム画面用のタグ選択画面のシートの状態を管理する変数。Bool型は先にisをつけると分かりやすい
    @State private var isTagSelectHomeViewSheetShown: Bool = false
    //　行った気になるタブを管理する変数
    @State private var tabControlNumber: Int = 0
    // お店登録画面のシートの状態を管理する変数。
    @State private var isStoreRegistrationViewSheetShown: Bool = false
    // 入力された内容を反映する変数
    @State private var homeSearchInputText: String = ""
    var body: some View {
        // NavigationStackと配列パスの紐付け
        NavigationStack(path: $mainNavigatePath) {
            VStack {
                // #とタブボタンの実装
                HStack {
                    Spacer()
                    // タグボタン
                    Button(action: {
                        // ハーフモーダルでタグ選択画面のシートを表示
                        isTagSelectHomeViewSheetShown.toggle()
                    }) {
                        Text("#")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 30)
                            .border(Color.gray)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(10)
                    }
                    Spacer()
                    // 行ったリストと気になるリストのタブ作成
                    // それぞれ、店名とタグ情報を継続してViewを切り替えられる
                    Picker("行った気になるを選択", selection: $tabControlNumber) {
                        // 行ったタブ
                        Button(action: {
                            // 行ったお店リストだけを表示する設定
                        }) {
                            Text("行った")
                        }
                        .tag(0)
                        // 気になるタブ
                        Button(action: {
                            // 気になるお店リストだけを表示する設定
                        }) {
                            Text("気になる")
                        }
                        .tag(1)
                    }
                    .pickerStyle(.segmented)
                    Spacer()
                }
                // ダミーリスト100個用意
                List(1..<100) { _ in
                    HStack {
                        // 各リストの左側に自分が撮影した写真を載せる
                        Image("")
                            // サイズ変更モードに設定
                            .resizable()
                            // 写真をリストのビューにフィットするようにアスペクト比を維持
                            .aspectRatio(contentMode: .fit)
                            // 枠の高さを調整
                            .frame(height: 60)
                        Button(action: {
                            // お店情報画面へ遷移
                            mainNavigatePath.append(.storeInfoView)
                        }) {
                            Text("ダミー")
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            // 遷移先のビューをそれぞれ定義
            .navigationDestination(for: HomeViewPath.self) { value in
                switch value {
                // お店情報画面のビューを定義
                case .storeInfoView:
                    StoreInfoView(mainNavigatePath: $mainNavigatePath)
                // お店編集画面のビューを定義
                case .storeEditView:
                    StoreEditView(mainNavigatePath: $mainNavigatePath)
                }
            }
            // NavigationBarを固定する
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションタイトルの文字サイズを変更
            .toolbar {
                // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
                ToolbarItem(placement: .principal) {
                    Text("一覧")
                        .navigationBarTitleStyle()
                }
                // ボトムバーにお店を追加ボタン作成
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // お店登録画面をシート表示
                        isStoreRegistrationViewSheetShown.toggle()
                    }) {
                        Text("お店を追加")
                            .navigationBottomBarStyle()
                    }
                }
            }
        }
        // 店名検索バーの実装
        .searchable(text: $homeSearchInputText, prompt: Text("店名を入力"))
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $isTagSelectHomeViewSheetShown) {
            // タグ選択画面を表示
            TagSelectHomeView()
                // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
                .presentationDetents([
                    .medium,
                    .large
                ])
        }
        // お店登録画面をフルスクリーンで表示
        .fullScreenCover(isPresented: $isStoreRegistrationViewSheetShown) {
            StoreRegistrationView()
        }
    }
}

#Preview {
    HomeView()
}
