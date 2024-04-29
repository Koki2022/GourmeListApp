//
//  OriginalSearchBarView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/04/16.
//

import SwiftUI

struct OriginalSearchBarView: View {
    @Binding var inputTextTagSelectHomeView: String
    var body: some View {
        ZStack {
            // 背景の設定
            RoundedRectangle(cornerRadius: 8) // 角丸長方形
                .fill(Color.gray.opacity(0.2))
                .frame(width: 350, height: 40)
            HStack(spacing: 6) {
                // アイコンと入力欄の位置調整
                Spacer()
                    .frame(width: 25)
                //　虫眼鏡
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                // 入力欄
                TextField("タグの名前を検索", text: $inputTextTagSelectHomeView)
            }

        }
    }
}

#Preview {
    OriginalSearchBarView(inputTextTagSelectHomeView: .constant(""))
}
