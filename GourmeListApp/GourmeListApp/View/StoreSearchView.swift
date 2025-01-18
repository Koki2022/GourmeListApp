//
//  StoreSearchView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/06/05.
//

import SwiftUI
import GooglePlaces
import MapKit

//　StoreSearchView:お店検索画面
struct StoreSearchView: View {
    // StoreSearchViewModelクラスをインスタンス化
    @StateObject private var viewModel = StoreSearchViewModel()
    //　フォーカスを当てる状態を切り替える変数
    @FocusState private var isFocused: Bool
    // お店検索画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // 店舗概要のデータをバインディングするための変数
    @Binding var storeDetailData: StoreDetailData

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    OriginalSearchBarView(text: $viewModel.text, prompt: "店名や地名で検索できます")
                        .frame(height: 60)
                        .focused($isFocused)
                        .onChange(of: viewModel.text) { _, newText in
                            viewModel.performSearch(query: newText)
                        }
                        .task {
                            isFocused = true
                        }

                    if !viewModel.searchResults.isEmpty {
                        searchResultsListView
                            .frame(height: geometry.size.height - 60)
                    } else {
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationBarItems
            }
        }
    }
    // 店舗リストコンポーネント化
    private var searchResultsListView: some View {
        // 店舗のリスト表示
        List(viewModel.searchResults, id: \.placeID) { result in
            Button(action: {
                // 詳細情報を取得
                viewModel.fetchPlaceDetails(for: result.placeID) { detailData in
                    // 店舗データを反映
                    if let detailData = detailData {
                        self.storeDetailData = detailData
                        // 取得した住所を検索しマップ上にピンを生成するための関数を実行
                        searchAddress()
                        // お店情報登録画面へ戻り、登録内容が反映される
                        dismiss()
                    }
                }
            }) {
                // 場所の内容をテキスト表示
                Text(result.attributedFullText.string)
                    .foregroundStyle(.black)
                    .frame(height: 60)
            }
        }
    }
    //　NavigationBarItemをコンポーネント化
    private var navigationBarItems: some ToolbarContent {
        Group {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店の検索")
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
        }
    }
    // 取得した住所からlocationを設定し、登録画面に遷移した際マップ上にピンを表示させる
    private func searchAddress() {
        // 地図上の特定の場所、施設、住所などを検索するためのリクエストを作成
        let request = MKLocalSearch.Request()
        // 検索項目の文字列に入力した住所を格納
        request.naturalLanguageQuery = storeDetailData.address
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
                self.storeDetailData.selectedLocation = firstItem
                // 検索結果の座標を中心に新しい地図領域を作成
                self.storeDetailData.position = .region(MKCoordinateRegion(center: firstItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
            }
        }
    }
}

#Preview {
    StoreSearchView(storeDetailData: .constant(StoreDetailData()))
}
