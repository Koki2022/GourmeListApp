//
//  OriginalSearchBarView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/04/16.
//

import SwiftUI

struct OriginalSearchBarView: View {
    @Binding var text: String
    var prompt: String
    var body: some View {
        // GeometryReaderを使用して、親ビューのサイズに基づいて子ビューのサイズや位置を動的に調整
        GeometryReader { geometry in
            ZStack {
                // 背景の設定
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: geometry.size.width * 0.9, height: 40) // 画面幅の90%に設定し、両端に5%ずつの余白をうむ
                HStack(spacing: 6) {
                    //　虫眼鏡
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    // 入力欄
                    TextField(prompt, text: $text)
                }
                .padding(.horizontal, 25)
            }
        }
    }
}

#Preview {
    OriginalSearchBarView(text: .constant(""), prompt: "タグの名前を検索")
}
