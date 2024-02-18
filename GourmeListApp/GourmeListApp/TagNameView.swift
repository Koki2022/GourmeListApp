//
//  TagNameView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/02/18.
//

import SwiftUI

//　TagNameView:タグ名入力画面
struct TagNameView: View {
    // タグ選択画面から受け取った配列パスの参照
    @Binding var tagViewNavigatePath: [tagViewPath]
    // 入力されたタグ名を反映する変数
    @State private var inputTagName: String = ""
    var body: some View {
        VStack {
            HStack {
                // タグ名入力欄のTextField
                TextField("タグ名を入力してください", text: $inputTagName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                // タグ作成ボタン
                Button(action: {
                    // タグ選択画面へ遷移
                    tagViewNavigatePath.removeAll()
                }) {
                    Text("作成")
                        .font(.system(size: 20))
                        .frame(width: 70, height: 40)
                        .foregroundStyle(.white)
                        .background(Color.red)
                        .clipShape(.buttonBorder)
                        .padding(10)
                }
            }
        }
        Spacer()
        Text("タグ名入力画面。後でView作成します")
        Spacer()
    }
}

#Preview {
    TagNameView(tagViewNavigatePath: .constant([]))
}
