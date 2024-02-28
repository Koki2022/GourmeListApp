//
//  TagSelectView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/25.
//

import SwiftUI

//　TagSelectView:タグ選択画面
struct TagSelectView: View {
    // タグ選択画面でのナビゲーションの状態を管理する配列パス
    @State private var tagViewNavigatePath: [TagViewPath] = []
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var tagSelsectViewDismiss
    var body: some View {
        // NavigationStackと配列パスの紐付け
        NavigationStack(path: $tagViewNavigatePath) {
            VStack {
                // 横線
                Divider()
                HStack {
                    Spacer()
                    // 決定ボタン
                    Button(action: {
                        // viewを閉じて一覧画面へ遷移
                        tagSelsectViewDismiss()
                    }) {
                        Spacer()
                        Text("完了")
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                            .padding(10)
                    }
                }
                // 横線
                Divider()
                HStack {
                    // タグボタン
                    Button(action: {
                        // 処理追加
                    }) {
                        Text("ダミー")
                            .font(.system(size: 20))
                            .frame(width: 100, height: 45)
                            .foregroundStyle(.black)
                            .background(Color.yellow)
                            .clipShape(.buttonBorder)
                            .padding(10)
                    }
                    Spacer()
                    // タグボタン
                    Button(action: {
                        // 処理追加
                    }) {
                        Text("ダミー")
                            .font(.system(size: 20))
                            .frame(width: 100, height: 45)
                            .foregroundStyle(.black)
                            .background(Color.yellow)
                            .cornerRadius(5)
                            .padding(10)
                    }
                    Spacer()
                    // タグボタン
                    Button(action: {
                        // 処理追加
                    }) {
                        Text("ダミー")
                            .font(.system(size: 20))
                            .frame(width: 100, height: 45)
                            .foregroundStyle(.black)
                            .background(Color.yellow)
                            .cornerRadius(5)
                            .padding(10)
                    }
                    Spacer()
                }

            }
            Spacer()
                // 遷移先のビューを定義
                .navigationDestination(for: TagViewPath.self) { value in
                    switch value {
                    // タグ名入力欄ビューを定義
                    case .tagNameView:
                        TagNameView(tagViewNavigatePath: $tagViewNavigatePath)
                    }
                }
                //　タグ作成ボタンを下部に配置
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            // 名前入力画面へ遷移
                            tagViewNavigatePath.append(.tagNameView)
                        }) {
                            Text("新規タグ作成")
                                .font(.system(size: 20))
                                .frame(width: 150, height: 70)
                                .foregroundStyle(.white)
                                .background(Color.red)
                                .clipShape(.buttonBorder)
                                .padding(10)
                        }
                    }
                }
        }
    }
}

#Preview {
    TagSelectView()
}
