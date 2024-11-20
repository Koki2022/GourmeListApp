//
//  HomeViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/11/20.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    // 訪問状況を管理する変数
    @Published var visitationStatus: VisitationStatus = .visited

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
