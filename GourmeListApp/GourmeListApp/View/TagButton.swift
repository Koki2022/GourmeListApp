//
//  TagButton.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/11/13.
//

import SwiftUI

//　作成したTagButtonをコンポーネント化
struct TagButton: View {
    let tag: TagButtonDetail
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("# \(tag.name)")
                .frame(width: 110, height: 45)
                .font(.system(size: 18))
                .foregroundStyle(.black)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                .background(RoundedRectangle(cornerRadius: 10).fill(tag.isSelected ? Color.yellow : Color.white))
                .padding(10)
        }
    }
}
