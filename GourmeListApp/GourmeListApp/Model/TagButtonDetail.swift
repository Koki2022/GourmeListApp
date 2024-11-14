//
//  TagButtonDetail.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/04/28.
//

import Foundation

// 各タグボタンの情報を格納する構造体
struct TagButtonDetail: Identifiable {
    let id = UUID()
    var name: String = ""
    var isSelected: Bool = false
}
