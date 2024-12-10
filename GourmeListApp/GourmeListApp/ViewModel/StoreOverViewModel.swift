//
//  StoreOverviewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/12/07.
//

import SwiftUI
import MapKit

class StoreOverViewModel: ObservableObject {
    // 店舗概要を格納するStoreDetailData型のデータ
    @Published var overViewDetailData: StoreDetailData = StoreDetailData()
    // タブの選択項目を保持する変数
    @Published var selection: Int = 0
    // 訪問状況を管理する変数
    @Published var visitationStatus: VisitationStatus = .none
    // 選択したタグを格納する配列
    @Published var selectedTags: [String] = []

    // 画面起動時にデータを取得
    func setUpStores(store: Stores?) {
        // アンラップされた値を新しい定数storesに代入。storesがnilの場合、処理を抜け出す
        guard let store = store else { return }
        // ファイル名からUIImageを作成する
        loadImagesFromFileNames(fileNames: store.fileName)
        // 店名データを取得
        overViewDetailData.storeName = store.name ?? "店名未記入"
        // 訪問状況ステータスを取得
        visitationStatus = VisitationStatus(rawValue: store.visitationStatus) ?? .none
        // 訪問日時データ
        overViewDetailData.visitDate = store.visitDate ?? Date()
        // タグデータ　selectedTagが空なら空の配列を返す。値があるなら分割してselectedTagsに格納
        selectedTags = store.selectedTag?.isEmpty ?? true ? [] : store.selectedTag!.components(separatedBy: ",")
        // メモの内容を取得
        overViewDetailData.memo = store.memo ?? "メモ未記入"
        // 営業時間のデータ
        overViewDetailData.businessHours = store.businessHours ?? "営業時間未記入"
        // 電話番号データ
        overViewDetailData.phoneNumber = store.phoneNumber ?? "電話番号未記入"
        // 住所データ
        overViewDetailData.address = store.address ?? "住所未記入"
        // 住所検索
        searchAddress()
    }
    // ファイル名を取得してUIImageを作成する関数
    func loadImagesFromFileNames(fileNames: String?) {
        // アンラップされた値を新しい定数fileNamesに代入。nilの場合、処理を抜け出す
        guard let fileNames = fileNames else { return }
        // 取得したファイル名をカンマ区切りで配列に格納
        let fileNameArray = fileNames.components(separatedBy: ",")
        // compactMapでnilを除いて配列の値を渡す
        overViewDetailData.selectedImages = fileNameArray.compactMap { fileName in
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
    // 入力された住所を検索する関数
    func searchAddress() {
        // 地図上の特定の場所、施設、住所などを検索するためのリクエストを作成
        let request = MKLocalSearch.Request()
        // 検索項目の文字列に入力した住所を格納
        request.naturalLanguageQuery = overViewDetailData.address
        // 指定された検索リクエストに基づいて地図上の場所を検索するためのクラス
        let search = MKLocalSearch(request: request)
        // 検索を非同期で開始。クロージャ内で検索結果または検索エラーを受け取る。
        search.start { response, error in
            // 検索結果responseが存在するかチェック
            guard let response = response else {
                // 結果がない場合、エラーメッセージを出力して終了
                print("検索エラー: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // 検索結果の最初の項目（mapItems.first）を取得
            if let firstItem = response.mapItems.first {
                // 最初の検索結果を selectedLocation に設定し地図上にマーカーが表示される
                self.overViewDetailData.selectedLocation = firstItem
                // 検索結果の座標を中心に新しい地図領域を作成
                self.overViewDetailData.position = .region(MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}
