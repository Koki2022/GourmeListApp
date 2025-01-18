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
    // TagSelectionViewModelクラスをインスタンス化
    @StateObject private var viewModel = TagSelectionViewModel()
    // 選択したタグを管理する変数
    @Binding var selectedTags: [String]

    var body: some View {
        //  スクロールビューの実装
        ScrollView {
            VStack(spacing: 0) {
                // 完了ボタン
                completeButton
                    .frame(height: 50)
                Divider()
                // タグ名検索バー
                OriginalSearchBarView(text: $viewModel.tagName, prompt: "タグの名前を検索")
                    .frame(height: 60) // ビューが重なる場合はフレーム地などで対応
                    .padding(.top, 10)
                // タグボタン
                tagGrid
                Spacer()
            }
            // インジケータを右端に表示
            .frame(maxWidth: .infinity)
        }
        // 画面表示時の処理
        .onAppear {
            //  画面表示時にCoreDataからタグデータを読み取る
            viewModel.loadTagNames(fetchedTags: fetchedTags)
            //  selectedTagsにあるタグは選択状態をtrueにする
            updateTagSelectionStatus()
        }
    }
    // 完了ボタンコンポーネント化
    private var completeButton: some View {
        HStack {
            Spacer()
            Button(action: {
                // viewを閉じて一覧画面へ遷移
                dismiss()
            }) {
                Text("完了")
                    .font(.system(size: 20))
                    .foregroundStyle(.red)
                    .padding(8)
            }
        }
    }
    // タグGridのコンポーネント化
    private var tagGrid: some View {
        // タグボタンを１行に3つずつ配置
        LazyVGrid(columns: viewModel.columns, alignment: .center, spacing: 5) {
            // TagAddViewで作成したタグを表示
            ForEach(viewModel.filteredTags) { tag in
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
    }
    // タップしたタグの選択状態を切り替える関数
    private func toggleTagSelection(tag: TagButtonDetail) {
        // tagButtonDetail配列の中で{ $0.id == tag.id }がtrueを返す最初の要素のインデックスを探す
        if let index = viewModel.tagButtonDetail.firstIndex(where: { $0.id == tag.id }) {
            // タップしたボタンの選択状態を切り替える
            viewModel.tagButtonDetail[index].isSelected.toggle()
            // 選択したタグの配列に追加
            if viewModel.tagButtonDetail[index].isSelected {
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
        for (index, tag) in viewModel.tagButtonDetail.enumerated() {
            viewModel.tagButtonDetail[index].isSelected = selectedTags.contains(tag.name)
        }
    }
}

#Preview {
    TagSelectionView(selectedTags: .constant([]))
}
