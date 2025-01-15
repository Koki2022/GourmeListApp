//
//  TagSelectView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/25.
//

import SwiftUI
import CoreData

struct TagAddView: View {
    @FetchRequest(entity: Tags.entity(), sortDescriptors: []) private var fetchedTags: FetchedResults<Tags>
    @FetchRequest(entity: Stores.entity(), sortDescriptors: []) private var fetchedStores: FetchedResults<Stores>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    // TagAddViewModelクラスをインスタンス化
    @StateObject private var viewModel = TagAddViewModel()
    // 選択されたタグを格納するための配列
    @Binding var selectedTags: [String]
    // タグ名入力フィールドを管理する変数
    @State private var isInputNameVisible: Bool = false
    // 入力したタグ名を管理する変数
    @State private var tagName: String = ""
    // 削除対象のタグ名を管理する変数
    @State private var tagToDelete: String?
    // タグボタンのサイズや行または列の要素数をArray文で定義
    private let columns: [GridItem] = Array(repeating: .init(.fixed(120)), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 完了ボタン
                completeButton
                    .frame(height: 50)
                Divider()
                // 検索バー
                OriginalSearchBarView(text: $viewModel.tagName, prompt: "タグの名前を検索")
                    .frame(height: 60)
                    .padding(.top, 10)
                // 作成したタグボタンを表示
                tagGrid
            }
            .frame(maxWidth: .infinity)
        }
        // 画面表示時の処理
        .onAppear {
            // CoreDataからタグを読み込む
            viewModel.loadTagNames(fetchedTags: fetchedTags)
            // selectedTagsにあるタグは選択状態をtrueにする
            updateTagSelectionStatus()
        }
        // タグ名入力フィールド
        .alert("タグ名を入力してください", isPresented: $isInputNameVisible) {
            TextField("", text: $tagName)
            Button("キャンセル", role: .cancel) { }
            Button("OK") {
                // 空文字でなければ」タグを作成し保存
                if !tagName.isEmpty {
                    viewModel.addTagName(tagName: tagName, viewContext: viewContext)
                    tagName = ""
                }
            }
        }
        // 同名のタグが存在時のアラート処理
        .alert("同じタグ名が既に存在します", isPresented: $viewModel.isSameNameVisible) {
            Button("OK", role: .cancel) { }
        }
        // ボタン長押し時のアラート処理
        .alert("タグを削除", isPresented: $viewModel.isDeleteNameVisible, presenting: tagToDelete) { tagName in
            Button("削除", role: .destructive) {
                viewModel.deleteTag(tagName: tagName, fetchedTags: fetchedTags, fetchedStores: fetchedStores, viewContext: viewContext)
                // お店登録画面のタグも削除するため、連携しているselectedTagsも削除する
                selectedTags.removeAll { $0 == tagName }
            }
            Button("キャンセル", role: .cancel) { }
        } message: { tagName in
            Text("'\(tagName)'を削除してもよろしいですか？")
        }
    }
    // 完了ボタンのコンポーネント化
    private var completeButton: some View {
        HStack {
            Spacer()
            Button("完了") {
                dismiss()
            }
            .font(.system(size: 20))
            .foregroundStyle(.red)
            .padding(8)
        }
    }
    // タグGridのコンポーネント化
    private var tagGrid: some View {
        // タグボタン
        LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
            // タグ追加ボタン
            addTagButton
            // 作成したタグを表示
            ForEach(viewModel.tagButtonDetail) { tag in
                // タグボタンを呼び出し、actionに選択状態を変える関数をセット
                TagButtonView(tag: tag, action: { toggleTagSelection(tag: tag)})
                    // 長押しの際の処理
                    .contextMenu {
                        Button(role: .destructive) {
                            // 削除対象のタグ名をtagToDeleteに格納
                            tagToDelete = tag.name
                            // 削除する際のアラート表示
                            viewModel.isDeleteNameVisible.toggle()
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
            }
        }
    }
    // タグ追加ボタンのコンポーネント化
    private var addTagButton: some View {
        Button("タグを追加") {
            // タグ名入力フィールドを表示
            isInputNameVisible.toggle()
        }
        .frame(width: 110, height: 45)
        .font(.system(size: 18))
        .foregroundStyle(.gray)
        .background(Color.gray.opacity(0.2))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
    }
    // 選択状態を切り替える関数
    private func toggleTagSelection(tag: TagButtonDetail) {
        // tagButtonDetail配列の中で{ $0.id == tag.id }がtrueを返す最初の要素のインデックスを探す
        if let index = viewModel.tagButtonDetail.firstIndex(where: { $0.id == tag.id }) {
            // タップしたボタンの選択状態を切り替える
            viewModel.tagButtonDetail[index].isSelected.toggle()
            // 選択状態trueの場合
            if viewModel.tagButtonDetail[index].isSelected {
                // 選択したタグの配列に追加する
                selectedTags.append(tag.name)
                // 選択状態falseの場合
            } else {
                // 選択したタグがら削除する
                selectedTags.removeAll { $0 == tag.name }
            }
        }
    }
    // selectedTagsにあるタグは選択状態をtrueにする関数
    private func updateTagSelectionStatus() {
        // tagButtonDetail配列のデータを取り出す。enumerated() で配列の要素を更新
        for (index, tag) in viewModel.tagButtonDetail.enumerated() {
            // selectedTagsにあるタグは選択状態をtrueにする
            viewModel.tagButtonDetail[index].isSelected = selectedTags.contains(tag.name)
        }
    }
}

#Preview {
    TagAddView(selectedTags: .constant([]))
}
