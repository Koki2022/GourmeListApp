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

struct HomeView: View {
    // 入力された内容を反映する変数
    @State private var inputText: String = ""
    // タグ選択画面のシートの状態を管理する変数
    @State private var tagSelectIsShowSheet: Bool = false
    // お店検索画面のシートの状態を管理する変数
    @State private var storeSearchIsShowSheet: Bool = false
    var body: some View {
        // リスト表示にタイトルをつけるためNavigationStackを用意
        NavigationStack {
            VStack {
                // TextFiledの色を後で設定
                TextField("🔍キーワードを入力してください", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                // 行ったリストとこれからリストのタブ作成
                
                HStack {
                    // タグボタン
                    Button(action: {
                        // ハーフモーダルでタグ選択画面のシートを表示
                        tagSelectIsShowSheet.toggle()
                    }) {
                        Text("タグ")
                            .font(.system(size: 20))
                            .frame(width: 70,height: 45)
                            .foregroundColor(Color.black)
                            .background(Color.yellow)
                            .cornerRadius(5)
                            .padding(10)
                    }
                    // タグボタンを左端に配置
                    Spacer()
                }
                // ダミーリスト100個用意
                List (1..<100) { gourmeList in
                    // お店情報画面へ遷移
                    NavigationLink("ダミーデータ", destination: StoreInfoView())
                }
                HStack {
                    Spacer()
                    // +ボタン
                    Button(action: {
                        storeSearchIsShowSheet.toggle()
                    }) {
                        Text("+")
                            .font(.system(size: 60))
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.red)
                            .clipShape(.circle)
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
                    Text("一覧")
                        .font(.system(size: 30))
                        .fontWeight(.heavy)
                }
            }
        }
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $tagSelectIsShowSheet) {
            // タグ選択画面を表示
            TagSelectView()
            // ハーフモーダルで表示
                .presentationDetents([.medium])
        }
        // お店検索画面を表示する際のシートの状態を管理する変数
        .sheet(isPresented: $storeSearchIsShowSheet) {
            StoreSearchView()
        }
    }
}

#Preview {
    HomeView()
}
