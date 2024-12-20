//
//  StoreSearchViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/12/21.
//

import SwiftUI
import GooglePlaces

class StoreSearchViewModel: ObservableObject {
    // 入力された文字を反映する変数
    @Published var text: String = ""
    // 自動補完の検索結果を保持するための状態変数
    @Published var searchResults: [GMSAutocompletePrediction] = []
    // Google Places APIの自動補完セッションを管理するためのトークンを生成
    private var sessionToken = GMSAutocompleteSessionToken()

    // Google Places APIを使用して場所の自動補完検索を実行する機能を実装
    @MainActor func performSearch(query: String) {
        // 空のクエリの場合、検索結果をクリアして終了
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        // フィルター設定
        let filter = GMSAutocompleteFilter()
        // 日本の大まかな緯度経度範囲を指定し、この地域の結果を優先
        filter.locationBias = GMSPlaceRectangularLocationOption(CLLocationCoordinate2DMake(45.551483, 139.769018), CLLocationCoordinate2DMake(24.396308, 122.93457))
        // GMSPlacesClient.shared().findAutocompletePredictionsを使用して検索を実行
        GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: sessionToken) { ( results, error) in
            // エラー出力
            if let error = error {
                print("Autocomplete error: \(error.localizedDescription)")
                return
            }
            // 検索結果の更新をUIスレッドで行う
            Task {
                self.searchResults = results ?? []
            }
        }
    }
}
