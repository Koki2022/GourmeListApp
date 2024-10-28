//
//  StoreDetailData.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/09/29.
//

import SwiftUI
import PhotosUI
import MapKit

// StoreDetailData: お店情報を設定するためのデータをまとめた構造体
struct StoreDetailData {
    // フォトピッカー内で選択した複数アイテムを保持するプロパティ
    var selectedItems: [PhotosPickerItem]
    // PhotosPickerItem -> UIImageに変換した複数のアイテムを格納するプロパティ
    var selectedImages: [UIImage]
    // 削除の際に複数選択するためのインデックスをセット
    var selectedIndexes: Set<Int>
    //　店名の内容を反映する変数。
    var storeName: String
    //　訪問日を設定するカレンダー。現在の日時を取得
    var visitDate: Date
    // メモ記入欄の内容を反映する変数。
    var memo: String
    // 営業時間の内容を反映する変数。
    var businessHours: String
    //　電話番号を反映する変数。
    var phoneNumber: String
    //　住所を反映する変数。
    var address: String
    // 検索結果の場所を保持する
    var selectedLocation: MKMapItem?
    // 地図のカメラ位置を保持する
    var position: MapCameraPosition
}
