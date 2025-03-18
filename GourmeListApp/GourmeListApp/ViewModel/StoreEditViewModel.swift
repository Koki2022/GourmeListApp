//
//  StoreEditViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/09/30.
//

import SwiftUI
import PhotosUI
import CoreData
import MapKit

class StoreEditViewModel: ObservableObject {
    // @Published:ObservedObjectプロパティに準拠したクラス内部のプロパティを監視し、複数のviewに対して自動通知を行うことができる
    @Published var editViewDetailData: StoreDetailData = StoreDetailData()
    // 選択されたタグを格納するための配列
    @Published var selectedTags: [String] = []
    // 訪問状態を管理する変数
    @Published var visitationStatus: VisitationStatus = .visited
    // お店検索画面の管理状態
    @Published var isStoreSearchVisible: Bool = false
    // 訪問日設定画面の管理状態
    @Published var isVisitDateVisible: Bool = false
    // タグ選択画面の管理状態
    @Published var isTagSelectionVisible: Bool = false
    // 画像削除時のアラート表示
    @Published var isDeleteImageAlertVisible: Bool = false
    // 前画面に戻る時のアラート表示 
    @Published var isReturnToPreviousVisible: Bool = false

    // 非同期かつ、メインスレッド上でUIImageへの変換処理を行う関数
    @MainActor func loadSelectedImages(items: [PhotosPickerItem]) async {
        // 一時的にUIImageデータを格納する配列
        var uiImages: [UIImage] = []
        // UIImageへの変換処理が完了したアイテムを配列に格納
        for item in items {
            // エラーハンドリング処理
            do {
                // 選択アイテムをDataに変換(nilで処理終了)
                guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                // DataをUIImageに変換(nilで処理終了)
                guard let uiImage = UIImage(data: data) else { continue }
                // UIImage型プロパティに保存
                uiImages.append(uiImage)
            } catch {
                print("Error loadingImage: \(error.localizedDescription)")
            }
        }
        // 変換処理が全て完了したらselectedImagesへ格納
        editViewDetailData.selectedImages = uiImages
        print("画像: \(editViewDetailData.selectedImages.count)件")
    }
    // UIImageをストレージに保存し、ファイル名を返す関数
    func saveImageAndGetFileName(image: UIImage) -> String? {
        // ファイル名の重複を避けるためUUIDを生成
        let uuid = UUID().uuidString
        // 生成したuuidをファイル名に使用
        let fileName = "\(uuid).png"

        // 画像をpngデータに変換
        guard let data = image.pngData() else {
            return nil
        }
        // FileManager.default.urls(for:in:) メソッドを使用して、アプリのドキュメントディレクトリのURLを取得
        // .documentDirectoryは、ユーザーのドキュメントディレクトリを指定し、アプリがユーザーデータを保存するのに適した場所
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        // 保存するファイルのフルパスを作成
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        // エラーハンドリング処理
        do {
            // データをファイルに書き込む
            try data.write(to: fileURL)
            // 保存したファイル名を返却
            return fileName
        } catch {
            print("画像の保存に失敗しました: \(error)")
            return nil
        }
    }
    //　選択された画像を削除する関数
    func deleteSelectedImages() {
        // 配列から要素を削除する際、インデックスがずれるのを防ぐために、インデックスを降順に処理
        let sortedIndexes = editViewDetailData.selectedIndexes.sorted(by: >)
        //　取得したインデックスを処理
        for index in sortedIndexes {
            // indexが画像の数の範囲内であることをチェック
            guard index < editViewDetailData.selectedImages.count else {
                print("indexが画像の数の範囲外です")
                // インデックスが範囲外なら次のインデックスのループ処理に進む
                continue
            }
            // 画像を削除
            //　selectedImagesからindexに対応する画像を削除
            editViewDetailData.selectedImages.remove(at: index)
            print("画像削除: \(index)")
        }
        // 削除した際に写真ライブラリのアイテムの選択状態を解除するため、selectedItemsも更新
        // enumerated:PhotosPickerItemの配列にインデックスを付与する
        editViewDetailData.selectedItems = editViewDetailData.selectedItems.enumerated().compactMap { (index, item) in
            // compactMap:nilを返すと、その要素はPhotosPickerItemの配列に含まれない
            // 選択したインデックス番号を含んでいるものは削除対象としてnilとして扱い、PhotosPickerItem配列のitemから除外する
            return editViewDetailData.selectedIndexes.contains(index) ? nil : item
        }
        // 選択をリセット
        editViewDetailData.selectedIndexes.removeAll()
    }
    // 編集画面で変更した内容を保存
    func saveStoreInfo(store: Stores?, viewContext: NSManagedObjectContext) {
        // 画像保存処理
        if editViewDetailData.selectedImages.isEmpty {
            // 画像ない際の出力
            print("画像なし")
        } else {
            // 一時的にファイル名を格納する配列を用意
            var newFileNames: [String] = []
            // UIImage型のデータを取り出す
            for image in editViewDetailData.selectedImages {
                // ファイル名を取得する関数の引数にUIImage型データを渡し、取得したファイル名をアンラップして処理する
                if let unwrappedFileName = saveImageAndGetFileName(image: image) {
                    // ファイル名を格納
                    newFileNames.append(unwrappedFileName)
                }
            }
            // ファイル名を結合してStoresEntityのfileNameAttributeへ格納
            store?.fileName = newFileNames.joined(separator: ",")
        }
        // 店名をStoresEntityのnameAttributeに格納
        store?.name = editViewDetailData.storeName
        // 選択した訪問状況をStoresEntityのvisitationStatusへ格納
        store?.visitationStatus = visitationStatus.rawValue
        // 入力した日付をStoresEntityのvisitDateAttributeへ格納
        store?.visitDate = editViewDetailData.visitDate
        // 選択したタグをStoresEntityのselectedTagAttributeへ格納
        store?.selectedTag = selectedTags.joined(separator: ",")
        // メモ内容をStoresEntityのmemoAttributeに格納
        store?.memo = editViewDetailData.memo
        // 営業時間の内容をStoresEntityのbusinessHoursAttributeに格納
        store?.businessHours = editViewDetailData.businessHours
        // 電話番号の内容をStoresEntityのphoneNumberAttributeに格納
        store?.phoneNumber = editViewDetailData.phoneNumber
        // 住所の内容をStoresEntityのaddressAttributeに格納
        store?.address = editViewDetailData.address

        do {
            // CoreDataに保存
            try viewContext.save()
            print("CoreData 店名編集完了: \(store?.name ?? "")")
            print("CoreData 訪問状況の管理番号の編集完了: \(visitationStatus.rawValue)")
            print("CoreData 訪問日編集完了: \(editViewDetailData.visitDate)")
            print("CoreData 選択したタグの編集完了: \(selectedTags)")
            print("CoreData メモ編集完了: \(editViewDetailData.memo)")
            print("CoreData 営業時間編集完了: \(editViewDetailData.businessHours)")
            print("CoreData 電話番号編集完了: \(editViewDetailData.phoneNumber)")
            print("CoreData 住所編集完了: \(editViewDetailData.address)")
        } catch {
            print("CoreData ERROR: \(error)")
        }
    }

    // 画面起動時にデータを取得
    func setUpStores(store: Stores?) {
        // アンラップされた値を新しい定数storesに代入。storesがnilの場合、処理を抜け出す
        guard let store = store else { return }
        // ファイル名からUIImageを作成する
        loadImagesFromFileNames(fileNames: store.fileName)
        // 店名データを取得
        editViewDetailData.storeName = store.name ?? "店名未記入"
        // 訪問状況ステータスを取得
        visitationStatus = VisitationStatus(rawValue: store.visitationStatus) ?? .none
        // 訪問日時データ
        editViewDetailData.visitDate = store.visitDate ?? Date()
        // タグデータ　selectedTagが空なら空の配列を返す。値があるなら分割してselectedTagsに格納
        selectedTags = store.selectedTag?.isEmpty ?? true ? [] : store.selectedTag!.components(separatedBy: ",")
        // メモの内容を取得
        editViewDetailData.memo = store.memo ?? "メモ未記入"
        // 営業時間のデータ
        editViewDetailData.businessHours = store.businessHours ?? "営業時間未記入"
        // 電話番号データ
        editViewDetailData.phoneNumber = store.phoneNumber ?? "電話番号未記入"
        // 住所データ
        editViewDetailData.address = store.address ?? "住所未記入"
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
        editViewDetailData.selectedImages = fileNameArray.compactMap { fileName in
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
        request.naturalLanguageQuery = editViewDetailData.address
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
                self.editViewDetailData.selectedLocation = firstItem
                // 検索結果の座標を中心に新しい地図領域を作成
                self.editViewDetailData.position = .region(MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}
