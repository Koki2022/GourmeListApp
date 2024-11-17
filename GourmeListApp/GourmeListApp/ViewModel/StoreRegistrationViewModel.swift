//
//  StoreRegistrationViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/09/30.
//

import SwiftUI
import PhotosUI
import CoreData
import MapKit

class StoreRegistrationViewModel: ObservableObject {
    // @Published:ObservedObjectプロパティに準拠したクラス内部のプロパティを監視し、複数のviewに対して自動通知を行うことができる
    @Published var registrationViewDetailData: StoreDetailData = StoreDetailData()
    // 訪問状態を管理する変数
    @Published var visitationStatus: VisitationStatus = .visited
    // 選択されたタグを格納するための配列
    @Published var selectedTags: [String] = []
    // お店検索画面の管理状態
    @Published var isStoreSearchVisible: Bool = false
    // 訪問日設定画面の管理状態
    @Published var isVisitDateVisible: Bool = false
    // タグ選択画面の管理状態
    @Published var isTagSelectionVisible: Bool = false
    // 画像削除時のアラート表示
    @Published var isDeleteImageVisible: Bool = false

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
        registrationViewDetailData.selectedImages = uiImages
        print("画像: \(registrationViewDetailData.selectedImages.count)件")
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
        let sortedIndexes = registrationViewDetailData.selectedIndexes.sorted(by: >)
        //　取得したインデックスを処理
        for index in sortedIndexes {
            // indexが画像の数の範囲内であることをチェック
            guard index < registrationViewDetailData.selectedImages.count else {
                print("indexが画像の数の範囲外です")
                // インデックスが範囲外なら次のインデックスのループ処理に進む
                continue
            }
            // 画像を削除
            //　selectedImagesからindexに対応する画像を削除
            registrationViewDetailData.selectedImages.remove(at: index)
            print("画像削除: \(index)")
        }
        // 削除した際に写真ライブラリのアイテムの選択状態を解除するため、selectedItemsも更新
        // enumerated:PhotosPickerItemの配列にインデックスを付与する
        registrationViewDetailData.selectedItems = registrationViewDetailData.selectedItems.enumerated().compactMap { (index, item) in
            // compactMap:nilを返すと、その要素はPhotosPickerItemの配列に含まれない
            // 選択したインデックス番号を含んでいるものは削除対象としてnilとして扱い、PhotosPickerItem配列のitemから除外する
            return registrationViewDetailData.selectedIndexes.contains(index) ? nil : item
        }
        // 選択をリセット
        registrationViewDetailData.selectedIndexes.removeAll()
    }
    // 入力された住所を検索する関数
    func searchAddress() {
        // 地図上の特定の場所、施設、住所などを検索するためのリクエストを作成
        let request = MKLocalSearch.Request()
        // 検索項目の文字列に入力した住所を格納
        request.naturalLanguageQuery = registrationViewDetailData.address
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
                self.registrationViewDetailData.selectedLocation = firstItem
                // 検索結果の座標を中心に新しい地図領域を作成
                self.registrationViewDetailData.position = .region(MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
    //　CoreDataにお店情報を登録する関数
    func saveStoreInfo(fetchedStores: FetchedResults<Stores>, viewContext: NSManagedObjectContext) {
        // NSFetchRequest<Stores>: Storesオブジェクトを返すFetchRequestの型, Stores.fetchRequest: Storesエンティティに対するフェッチリクエストを生成するメソッド
        let fetchRequest: NSFetchRequest<Stores> = Stores.fetchRequest()
        // Storesエンティティのnameアトリビュートと完全一致するstoreName変数名を検索するNSPredicate を作成
        fetchRequest.predicate = NSPredicate(format: "name == %@", registrationViewDetailData.storeName)

        // CoreData保存処理の際do-try文でエラー処理も記載
        do {
            // 設定したfetchRequestを使用してデータベースからデータを取得
            let existingStores = try viewContext.fetch(fetchRequest)
            let store: Stores
            // 既存の店舗が見つかった場合、更新する。
            if let existingStore = existingStores.first {
                store = existingStore
            } else {
                store = Stores(context: viewContext)
            }

            // 画像保存処理
            if registrationViewDetailData.selectedImages.isEmpty {
                // 画像ない際の出力
                print("画像なし")
            } else {
                // 一時的にファイル名を格納する配列を用意
                var newFileNames: [String] = []
                // UIImage型のデータを取り出す
                for image in registrationViewDetailData.selectedImages {
                    // ファイル名を取得する関数の引数にUIImage型データを渡し、取得したファイル名をアンラップして処理する
                    if let unwrappedFileName = saveImageAndGetFileName(image: image) {
                        // ファイル名を格納
                        newFileNames.append(unwrappedFileName)
                    }
                }
                // ファイル名を結合してStoresEntityのfileNameAttributeへ格納
                store.fileName = newFileNames.joined(separator: ",")
            }
            // 店名をStoresEntityのnameAttributeに格納
            store.name = registrationViewDetailData.storeName
            // 選択した訪問状況をStoresEntityのvisitationStatusへ格納
            store.visitationStatus = visitationStatus.rawValue
            // 入力した日付をStoresEntityのvisitDateAttributeへ格納
            store.visitDate = registrationViewDetailData.visitDate
            // 選択したタグをStoresEntityのselectedTagAttributeへ格納
            store.selectedTag = selectedTags.joined(separator: ",")
            // メモ内容をStoresEntityのmemoAttributeに格納
            store.memo = registrationViewDetailData.memo
            // 営業時間の内容をStoresEntityのbusinessHoursAttributeに格納
            store.businessHours = registrationViewDetailData.businessHours
            // 電話番号の内容をStoresEntityのphoneNumberAttributeに格納
            store.phoneNumber = registrationViewDetailData.phoneNumber
            // 住所の内容をStoresEntityのaddressAttributeに格納
            store.address = registrationViewDetailData.address

            // CoreDataに保存
            try viewContext.save()
            print("CoreData 店名保存完了: \(store.name ?? "")")
            print("CoreData 訪問状況の管理番号の登録完了: \(visitationStatus.rawValue)")
            print("CoreData 訪問日完了: \(registrationViewDetailData.visitDate)")
            print("CoreData 選択したタグの登録完了: \(selectedTags)")
            print("CoreData メモ登録完了: \(registrationViewDetailData.memo)")
            print("CoreData 営業時間登録完了: \(registrationViewDetailData.businessHours)")
            print("CoreData 電話番号登録完了: \(registrationViewDetailData.phoneNumber)")
            print("CoreData 住所登録完了: \(registrationViewDetailData.address)")
        } catch {
            print("CoreData ERROR: \(error)")
        }
    }
}
