//
//  TagSelectionView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/04/16.
//

import SwiftUI

// TagSelectHomeView:ホーム画面用のタグ選択画面
struct TagSelectionView: View {
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    //　入力した文字を格納する変数
    @State private var text: String = ""
    // タグボタンのサイズや行または列の要素数をArray文で定義
    private let columns: [GridItem] = Array(Array(repeating: .init(.fixed(120)), count: 3))
    // 各タグボタンを管理する配列。タグ名ごとに選択状態を管理するので構造体で管理
    @State private var tagButtonInfo: [TagButtonInfo] = Array(repeating: TagButtonInfo(), count: 100)
    // アラートを管理する変数
    @State private var isShowAlert: Bool = false
    var body: some View {
        //  スクロールビューの実装
        ScrollView {
            VStack {
                // 横線
                Divider()
                HStack {
                    // 右よせ
                    Spacer()
                    Button(action: {
                        // 適用されたタグがあればホーム画面の選択中のタグに表示
                        dismiss() // viewを閉じて一覧画面へ遷移
                    }) {
                        Text("完了")
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                            .padding(8)
                    }
                }
                // 横線
                Divider()
                // 自作検索バー
                OriginalSearchBarView(text: $text, prompt: "タグの名前を検索")
                // タグボタンを１行に3つずつ配置
                LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                    // ForEach文で任意の数のタグボタンを実装
                    ForEach(Array(tagButtonInfo.enumerated()), id: \.offset) { index, _ in
                        Button(action: {
                            // タップされたボタンのBool値を変更
                            tagButtonInfo[index].isTagButtonInfoShown.toggle()
                        }) {
                            Text("# ダミー")
                                .frame(width: 110, height: 45)
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                                .overlay(alignment: .center) {
                                    // 角丸長方形
                                    RoundedRectangle(cornerRadius: 10)
                                        // 黒縁にする
                                        .stroke(Color.black)
                                }
                                // タップしたボタンだけ背景色を黄色にする
                                .background(RoundedRectangle(cornerRadius: 10).fill(tagButtonInfo[index].isTagButtonInfoShown ? Color.yellow: Color.white))
                                .padding(10)
                        }
                        // 長押しした際の挙動
                        .contextMenu(menuItems: {
                            Button("削除", role: .destructive) {
                                isShowAlert.toggle()
                            }
                        })
                    }
                }
                Spacer()
            }
            // インジケータを右端に表示
            .frame(maxWidth: .infinity)
        }
        // アラート処理
        .alert("削除しますか？ ", isPresented: $isShowAlert) {
            // キャンセルボタン実装
            Button("キャンセル", role: .cancel) {
                // キャンセル実行時の処理
            }
            // 削除ボタン実装
            Button("削除", role: .destructive) {
                // タグを削除する処理
            }
            // アラートポップアップ表示の際の警告
        } message: {
            Text("この操作は取り消しできません")
        }
    }
}

#Preview {
    TagSelectionView()
}
