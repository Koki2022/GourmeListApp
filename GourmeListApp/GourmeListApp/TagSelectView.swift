//
//  TagSelectView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/25.
//


import SwiftUI

//　TagSelectView:タグ選択画面
struct TagSelectView: View {
    // タグ選択画面を閉じるための動作を呼び出す変数
    @Environment(\.dismiss) private var tagSelsectViewDismiss
    var body: some View {
        VStack {
            // 決定ボタン
            Button(action: {
                // viewを閉じて一覧画面へ遷移
                tagSelsectViewDismiss()
            }) {
                Spacer()
                Text("決定")
                    .font(.system(size: 20))
                    .frame(width: 70,height: 45)
                    .foregroundColor(Color.red)
                    .padding(10)
            }
            HStack {
                // タグボタン
                Button(action: {
                    // 処理追加
                }) {
                    Text("ダミー")
                        .font(.system(size: 20))
                        .frame(width: 100,height: 45)
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
                        .frame(width: 100,height: 45)
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
                        .frame(width: 100,height: 45)
                        .foregroundStyle(.black)
                        .background(Color.yellow)
                        .cornerRadius(5)
                        .padding(10)
                }
                Spacer()
            }
            
        }
    }
}

#Preview {
    TagSelectView()
}
