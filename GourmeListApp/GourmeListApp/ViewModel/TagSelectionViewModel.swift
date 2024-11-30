//
//  TagSelectionViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/11/30.
//

import SwiftUI

class TagSelectionViewModel: ObservableObject {
    // タグを検索する際に入力した名前を管理する変数
    @Published var tagName: String = ""
    // 各タグボタンを管理する配列。タグ名ごとに選択状態を管理するので構造体で管理
    @Published var tagButtonDetail: [TagButtonDetail] = []
    // タグボタンのサイズや行または列の要素数をArray文で定義
    let columns: [GridItem] = Array(Array(repeating: .init(.fixed(120)), count: 3))

    // 検索バーで入力したタグ名を表示するfilteredTags
    var filteredTags: [TagButtonDetail] {
        // 未入力時はすべてのタグを返却
        if tagName.isEmpty {
            return tagButtonDetail
        } else {
            // tagButtonDetailにtagNameの文字が含まれているかフィルタリングしてチェック
            // 小文字で統一して、大文字小文字の判別をなくす
            return tagButtonDetail.filter { $0.name.lowercased().contains(tagName.lowercased()) }
        }
    }
    // 画面表示時にCoreDataからタグデータを読み取る関数
    func loadTagNames(fetchedTags: FetchedResults<Tags>) {
        // 配列を用意
        var newTagButtonDetail: [TagButtonDetail] = []
        var newTagNames: [String] = []

        // CoreDataからタグ名を管理するデータを取得
        for tag in fetchedTags {
            // 結合しているタグ名を分解
            if let tagNames = tag.name?.components(separatedBy: ",") {
                // 分解したタグ名を取り出す
                for tagName in tagNames {
                    // タグ名が存在し、タグ名の配列と取り出したタグ名が重複していなければnewTagButtonDetailとnewTagNamesに追加
                    if !tagName.isEmpty && !newTagNames.contains(tagName) {
                        newTagButtonDetail.append(TagButtonDetail(name: tagName))
                        newTagNames.append(tagName)
                    }
                }
            }
        }
        // UI更新
        tagButtonDetail = newTagButtonDetail
    }
}
