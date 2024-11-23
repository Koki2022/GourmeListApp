//
//  TagSelectionView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/04/16.
//

import SwiftUI
import CoreData

// TagSelectHomeView:ホーム画面用のタグ選択画面
struct TagSelectionView: View {
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // タグのデータを取得
    @FetchRequest(entity: Tags.entity(), sortDescriptors: []) private var fetchedTags: FetchedResults<Tags>
    // タグを検索する際に入力した名前を管理する変数
    @State private var tagName: String = ""
    // タグボタンのサイズや行または列の要素数をArray文で定義
    private let columns: [GridItem] = Array(Array(repeating: .init(.fixed(120)), count: 3))
    // 各タグボタンを管理する配列。タグ名ごとに選択状態を管理するので構造体で管理
    @State private var tagButtonDetail: [TagButtonDetail] = Array(repeating: TagButtonDetail(), count: 100)
    // 選択したタグを管理する変数
    @Binding var selectedTags: [String]

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
                OriginalSearchBarView(text: $tagName, prompt: "タグの名前を検索")
                // タグボタンを１行に3つずつ配置
                LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                    // TagAddViewで作成したタグを表示
                    ForEach(filteredTags) { tag in
                        Button(action: {
                            // タップしたタグの選択状態を切り替える
                            toggleTagSelection(tag: tag)
                        }) {
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
                Spacer()
            }
            // インジケータを右端に表示
            .frame(maxWidth: .infinity)
        }
        // 画面表示時の処理
        .onAppear {
            print("TagSelectionView表示")
            loadTagNames(fetchedTags: fetchedTags)
            updateTagSelectionStatus()
        }
    }
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
    private func loadTagNames(fetchedTags: FetchedResults<Tags>) {
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
    // タップしたタグの選択状態を切り替える関数
    private func toggleTagSelection(tag: TagButtonDetail) {
        // tagButtonDetail配列の中で{ $0.id == tag.id }がtrueを返す最初の要素のインデックスを探す
        if let index = tagButtonDetail.firstIndex(where: { $0.id == tag.id }) {
            // タップしたボタンの選択状態を切り替える
            tagButtonDetail[index].isSelected.toggle()
            // 選択したタグの配列に追加
            if tagButtonDetail[index].isSelected {
                selectedTags.append(tag.name)
            } else {
                // 選択したタグがら削除する
                selectedTags.removeAll(where: { $0 == tag.name })
            }
        }
    }
    // selectedTagsにあるタグは選択状態をtrueにする関数
    private func updateTagSelectionStatus() {
        // tagButtonDetail配列のデータを取り出す。enumerated() で配列の要素を更新
        for (index, tag) in tagButtonDetail.enumerated() {
            tagButtonDetail[index].isSelected = selectedTags.contains(tag.name)
        }
    }
}

#Preview {
    TagSelectionView(selectedTags: .constant([]))
}
