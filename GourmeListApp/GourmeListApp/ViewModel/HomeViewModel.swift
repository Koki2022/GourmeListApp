//
//  HomeViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/11/20.
//

import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    // ホーム画面用のタグ選択画面のシートの状態を管理する変数。
    @Published var isTagSelectionVisible: Bool = false
    // 訪問状況を管理する変数
    @Published var visitationStatus: VisitationStatus = .visited
    // お店登録画面のシートの状態を管理する変数。
    @Published var isStoreRegistrationVisible: Bool = false
    // CoreDataから取得したお店のデータ
    @Published var coreDataFetchedStores: [Stores] = []
    // ホーム画面でユーザーが選択したタグを保持
    @Published var userSelectedTags: [String] = []

    // フィルタリングされたお店リストを返す計算プロパティ
    var filteredStores: [Stores] {
        // タグ未選択時
        if userSelectedTags.isEmpty {
            // 全件表示
            return coreDataFetchedStores
        }
        // ユーザーが選択したタグを含むお店を表示
        return coreDataFetchedStores.filter { store in
            // CoreDataのお店が持つタグをカンマ区切り文字列から配列に変換
            guard let storeTagstring = store.selectedTag else { return false }
            // タグを分割
            let storeTags = storeTagstring.components(separatedBy: ",")
            // ユーザーが選択したタグが全て含まれているか確認(AND条件)
            return userSelectedTags.allSatisfy { storeTags.contains($0) }
        }
    }
    // CoreDataのファイル名を読み込み、UIImage型データを返却する関数
    func loadImageFromDocuments(fileName: String) -> UIImage? {
        // ドキュメントディレクトリのURLを取得
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        // 保存するファイルのフルパスを作成
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // fileURLからデータを読み込めたらUIImageオブジェクトを作成
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
}
