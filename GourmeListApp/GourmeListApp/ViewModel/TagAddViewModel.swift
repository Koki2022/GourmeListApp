//
//  TagAddViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/11/08.
//

import SwiftUI
import CoreData

class TagAddViewModel: ObservableObject {

    // CoreDataのタグ名の情報を管理するための配列
    @Published var tagNames: [String] = []
    // 各タグボタンを管理する配列。タグ名ごとに選択状態を管理するので構造体で管理
    @Published var tagButtonDetail: [TagButtonDetail] = []
    // 同名のタグ存在時のアラートを管理する変数
    @Published var isSameNameVisible: Bool = false
    // タグ削除の際のアラートを管理する変数
    @Published var isDeleteNameVisible: Bool = false
    // 削除対象のタグ名を管理する変数
    @Published var tagToDelete: String?

    // 画面表示時にcoredataからタグ情報を読み取る関数
    func loadTagNames(fetchedTags: FetchedResults<Tags>) {
        // 一時的に配列を用意
        var newTagButtonDetail: [TagButtonDetail] = []
        var newTagNames: [String] = []

        // CoreDataからタグ名を管理するデータを取得
        for tag in fetchedTags {
            // 配列のタグ名を分解する
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
        // UIを更新
        tagNames = newTagNames
        tagButtonDetail = newTagButtonDetail
    }
    // タグ名をCoreDataに登録し、新しいタグボタンを作成するための関数
    func addTagName(tagName: String, viewContext: NSManagedObjectContext) {
        // CoreDataからTagsエンティティの全てのインスタンスを取得する
        let fetchRequest: NSFetchRequest<Tags> = Tags.fetchRequest()
        // nameアトリビュートがtagNameの値と完全に一致するエンティティのみを取得する
        fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)

        // CoreDataへ保存する際の処理
        do {
            // 設定したfetchRequestを使用してデータベースからデータを取得
            let existingTags = try viewContext.fetch(fetchRequest)

            // 既存のタグが見つかった場合は、新しいタグを作成しない
            if !tagNames.contains(tagName) && existingTags.isEmpty {
                // 新しいエントリを作成してデータを保存
                let newTag = Tags(context: viewContext)
                // 配列にタグ名を格納
                tagNames.append(tagName)
                // タグ名を格納している配列の値を文字列で結合
                let tagNameString = tagNames.joined(separator: ",")
                // 結合したタグ名をTagsEntityのnameAttributeに格納
                newTag.name = tagNameString
                // coredata保存
                try viewContext.save()
                print("CoreData タグ名登録完了: \(tagNameString)")
                // 新しいタグボタンを生成するためにタグ名をtagButtonDetail配列に追加
                tagButtonDetail.append(TagButtonDetail(name: tagName))
            } else {
                // 同名のタグが存在する時の処理
                print("タグ '\(tagName)' は既に存在します")
                // 同名が存在する際のアラートを表示
                isSameNameVisible.toggle()
            }
        } catch {
            print("ERROR \(error)")
        }
    }

    func deleteTag(tagName: String, fetchedTags: FetchedResults<Tags>, fetchedStores: FetchedResults<Stores>, viewContext: NSManagedObjectContext) {
        // Tagsエンティティのタグ名削除処理
        for tag in fetchedTags {
            // タグ名を分割する
            if let names = tag.name?.components(separatedBy: ",") {
                // $0は配列の各要素。削除対象のタグ名ではない他の要素で値を結合する
                let updatedNames = names.filter { $0 != tagName }
                tag.name = updatedNames.joined(separator: ",")
            }
        }
        // Storesエンティティのタグ削除処理
        for store in fetchedStores {
            // タグ名を分割する
            if let selectedTags = store.selectedTag?.components(separatedBy: ",") {
                // $0は配列の各要素。削除対象のタグではない他の要素で値を結合する
                let updatedSelectedTags = selectedTags.filter { $0 != tagName }
                store.selectedTag = updatedSelectedTags.joined(separator: ",")
            }
        }
        // それぞれtagNameと一致する配列の要素を削除する
        tagButtonDetail.removeAll { $0.name == tagName }
        tagNames.removeAll { $0 == tagName }

        do {
            try viewContext.save()
            print("CoreData タグ名削除完了: \(tagNames)")
        } catch {
            print("タグの削除中にエラーが発生しました: \(error)")
        }
    }
}
