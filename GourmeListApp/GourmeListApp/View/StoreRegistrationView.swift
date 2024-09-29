//
//  StoreRegistrationView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/31.
//

import SwiftUI
import PhotosUI
import CoreData

//　StoreRegistrationView:お店登録画面
struct StoreRegistrationView: View {
    // プロパティラッパー @FetchRequestで、データベースよりデータを取得
    @FetchRequest(entity: Stores.entity(), sortDescriptors: []
    ) private var fetchedStores: FetchedResults<Stores>
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // StoreDetailViewModelクラスをインスタンス化
    @StateObject private var storeDetailViewModel = StoreDetailViewModel()

    var body: some View {
        NavigationStack {
            Spacer()
            ScrollView {
                // カスタムViewを実装
                StoreDetailView(storeDetailViewModel: storeDetailViewModel)
                    // NavigationBarを固定する
                    .navigationBarTitleDisplayMode(.inline)
                    // ナビゲーションタイトルの文字サイズを変更
                    .toolbar {
                        // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
                        ToolbarItem(placement: .principal) {
                            Text("お店情報の登録")
                                .navigationBarTitleStyle()
                        }
                        // ナビゲーション バーの先端に戻るボタン配置
                        ToolbarItem(placement: .cancellationAction) {
                            // 戻るボタン
                            Button(action: {
                                // ホーム画面に戻る
                                dismiss()
                            }) {
                                Text("戻る")
                            }
                        }
                        // ボトムバーにお店リストに追加ボタンを作成
                        ToolbarItem(placement: .bottomBar) {
                            Button(action: {
                                // 登録した情報を保存
                                storeDetailViewModel.addStoreImages(fetchedStores: fetchedStores, viewContext: viewContext)
                                // ホーム画面に遷移
                                dismiss()
                            }) {
                                Text("お店リストに追加")
                                    .navigationBottomBarStyle()
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    StoreRegistrationView()
}
