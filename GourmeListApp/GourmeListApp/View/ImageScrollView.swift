//
//  ImageScrollView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/11/17.
//

import SwiftUI
import PhotosUI

// 画像表示を別のViewとして定義し、表示ロジックを分離
struct ImageScrollView: View {
    // StoreRegistrationViewModelクラスと同期
    @ObservedObject var viewModel: StoreRegistrationViewModel
    var body: some View {
        // 写真追加画面は横スクロールでインジケータ非表示
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                // 配列内にUIImageデータが存在すれば画像を表示
                if !viewModel.registrationViewDetailData.selectedImages.isEmpty {
                    // 画像の数だけループ処理で表示する
                    // indicesでインデックスを取得して選択した画像を削除する
                    ForEach(viewModel.registrationViewDetailData.selectedImages.indices, id: \.self) { index in
                        let image = viewModel.registrationViewDetailData.selectedImages[index]
                        // フォトピッカーを表示するView
                        PhotosPicker(selection: $viewModel.registrationViewDetailData.selectedItems, selectionBehavior: .ordered) {
                            Image(uiImage: image)
                                // 画像サイズを変更可能にする
                                .resizable()
                                //  アスペクト比を維持しながら指定されたフレームを埋める
                                .scaledToFill()
                                .frame(width: 120, height: 80)
                                // フレームからはみ出た部分を切り取る
                                .clipped()
                                .padding(5)
                        }
                        // 画像長押しでメニュー表示
                        .contextMenu(menuItems: {
                            // 削除ボタン
                            Button("画像を削除", role: .destructive) {
                                //　削除対象のインデックスを追加
                                viewModel.registrationViewDetailData.selectedIndexes.insert(index)
                                // 削除時のアラート表示
                                viewModel.isDeleteImageVisible.toggle()
                            }
                        })
                    }
                }
                // フォトピッカーを表示するView
                PhotosPicker(selection: $viewModel.registrationViewDetailData.selectedItems, selectionBehavior: .ordered) {
                    Text("+")
                        .font(.system(size: 30))
                        .frame(width: 120, height: 80)
                        .foregroundStyle(Color.black)
                        .background(Color.gray.opacity(0.4))
                        .padding([.leading, .trailing], 5)
                }
                // onChangeでPhotosPickerItem型プロパティを監視し、アイテム選択を検知
                .onChange(of: viewModel.registrationViewDetailData.selectedItems) { _, items in
                    // 非同期処理
                    Task {
                        // 選択画像を読み込む処理
                        await viewModel.loadSelectedImages(items: items)
                    }
                }
            }
        }
    }
}
