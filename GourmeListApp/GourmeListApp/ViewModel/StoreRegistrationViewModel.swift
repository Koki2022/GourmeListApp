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
    @Published var registrationViewDetailData: StoreDetailData = StoreDetailData(selectedItems: [], selectedImages: [], selectedIndexes: [], storeName: "", visitStatusTag: 0, visitDate: Date(), memo: "", businessHours: "", phoneNumber: "", address: "", selectedLocation: nil, position: .automatic)
    
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
    // 追加ボタン押下時にファイル名をCoreDataに登録する関数
    func addStoreImages(fetchedStores: FetchedResults<Stores>, viewContext: NSManagedObjectContext) {
        // 画像なし
        if registrationViewDetailData.selectedImages.isEmpty {
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
            
            // ファイル名を結合
            let fileNameString = newFileNames.joined(separator: ",")
            
            // 既存のエントリをチェックして、ボタン押下の度に新エントリが作成されるのを防ぐ
            let existingPhoto = fetchedStores.first
            
            // エントリが存在してれば、エントリを更新
            if let photo = existingPhoto {
                photo.fileName = fileNameString
            } else {
                // エントリが存在してなければ、エントリを作成
                let newPhoto = Stores(context: viewContext)
                newPhoto.fileName = fileNameString
            }
            
            // CoreDataにファイル名を保存する
            do {
                try viewContext.save()
                print("CoreData登録完了: \(fileNameString)")
            } catch {
                print("CoreData ERROR \(error)")
            }
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
    // 店名を保存する関数。同じ店名のデータがないか確認してから保存する。
    func addStoreNames(viewContext: NSManagedObjectContext) {
        // NSFetchRequest<Stores>: Storesオブジェクトを返すFetchRequestの型
        // Stores.fetchRequest: Storesエンティティに対するフェッチリクエストを生成するメソッド
        let fetchRequest: NSFetchRequest<Stores> = Stores.fetchRequest()
        // Storesエンティティのnameアトリビュートと完全一致するstoreName変数名を検索するNSPredicate を作成
        fetchRequest.predicate = NSPredicate(format: "name == %@", registrationViewDetailData.storeName)
        
        // CoreDataへ保存
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
            // 店名をStoresEntityのnameAttributeに格納
            store.name = registrationViewDetailData.storeName
            
            try viewContext.save()
            print("CoreData 店名登録完了: \(registrationViewDetailData.storeName)")
        } catch {
            print("CoreData 店名ERROR \(error)")
        }
    }
    // 訪問日情報を保存する関数
    func addVisitDate(viewContext: NSManagedObjectContext) {
        let store = Stores(context: viewContext)
        // 入力した日付をStoresEntityのvisitDateAttributeへ格納
        store.visitDate = registrationViewDetailData.visitDate
        
        // CoreDataに保存
        do {
            try viewContext.save()
        } catch {
            print("CoreData 訪問日ERROR \(error)")
        }
    }
    // メモ記入欄の内容を保存する関数
    func addMemo(viewContext: NSManagedObjectContext) {
        let store = Stores(context: viewContext)
        // メモ内容をStoresEntityのmemoAttributeに格納
        store.memo = registrationViewDetailData.memo
        
        // CoreDataに保存
        do {
            try viewContext.save()
            print("CoreData メモ登録完了: \(registrationViewDetailData.memo)")
        } catch {
            print("CoreData メモERROR \(error)")
        }
    }
    // 営業時間の内容を保存する関数
    func addBusinessHours(viewContext: NSManagedObjectContext) {
        let store = Stores(context: viewContext)
        // 営業時間の内容をStoresEntityのbusinessHoursAttributeに格納
        store.businessHours = registrationViewDetailData.businessHours
        
        // CoreDataに保存
        do {
            try viewContext.save()
            print("CoreData 営業時間登録完了: \(registrationViewDetailData.businessHours)")
        } catch {
            print("CoreData 営業時間ERROR \(error)")
        }
    }
    // 住所の内容を保存する関数
    func addAddress(viewContext: NSManagedObjectContext) {
        let store = Stores(context: viewContext)
        // 住所の内容をStoresEntityのaddressAttributeに格納
        store.address = registrationViewDetailData.address
        
        // CoreDataに保存
        do {
            try viewContext.save()
            print("CoreData 住所登録完了: \(registrationViewDetailData.address)")
        } catch {
            print("CoreData 住所ERROR \(error)")
        }
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
}
