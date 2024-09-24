//
//  StoreInfoViewModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/09/19.
//

import SwiftUI
import CoreData
import PhotosUI

// StoreInfoViewModelクラスを「ObservableObject」プロトコルに準拠させデータバインディングを可能にする
class StoreInfoViewModel: ObservableObject {
    // @Published:ObservedObjectプロパティに準拠したクラス内部のプロパティを監視し、複数のviewに対して自動通知を行うことができる
    @Published var storeInfoData: StoreInfoData = StoreInfoData(selectedItems: [], selectedImages: [], selectedIndexes: [], storeName: "", visitStatusTag: 0, visitDate: Date(), memo: "", businessHours: "", phoneNumber: "", postalCode: "", address: "")
    // お店検索画面の管理状態
    @Published var isStoreSearchVisible: Bool = false
    // 訪問日設定画面の管理状態
    @Published var isVisitDateVisible: Bool = false
    // タグ選択画面の管理状態
    @Published var isTagSelectionVisible: Bool = false
    // 画像削除時のアラート表示
    @Published var isDeleteImageAlertVisible: Bool = false

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
        storeInfoData.selectedImages = uiImages
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
            print("UIImageをストレージに保存しました。ファイル名: \(fileName)")
            // 保存したファイル名を返却
            return fileName
        } catch {
            print("画像の保存に失敗しました: \(error)")
            return nil
        }
    }
    // 追加ボタン押下時にファイル名をCoreDataに登録する関数
    func addPhotosItem(fetchedStores: FetchedResults<Stores>, viewContext: NSManagedObjectContext) {
        // 画像なし
        if storeInfoData.selectedImages.isEmpty {
            print("画像なし")
        } else {
            // 一時的にファイル名を格納する配列を用意
            var newFileNames: [String] = []
            // UIImage型のデータを取り出す
            for image in storeInfoData.selectedImages {
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
                print("登録直前のデータ(既存): \(fileNameString)")
            } else {
                // エントリが存在してなければ、エントリを作成
                let newPhoto = Stores(context: viewContext)
                newPhoto.fileName = fileNameString
                print("登録直前のデータ(新規): \(fileNameString)")
            }

            // CoreDataにファイル名を保存する
            do {
                try viewContext.save()
                // CoreData登録直後のデータ確認
                print("CoreData登録直後のデータ: \(fileNameString)")
            } catch {
                print("CoreData登録ERROR \(error)")
            }
        }
    }
    //　選択された画像を削除する関数
    func deleteSelectedImages() {
        // 配列から要素を削除する際、インデックスがずれるのを防ぐために、インデックスを降順に処理
        let sortedIndexes = storeInfoData.selectedIndexes.sorted(by: >)
        //　取得したインデックスを処理
        for index in sortedIndexes {
            // indexが画像の数の範囲内であることをチェック
            guard index < storeInfoData.selectedImages.count else {
                print("indexが画像の数の範囲外です")
                // インデックスが範囲外なら次のインデックスのループ処理に進む
                continue
            }
            // 画像を削除
            //　selectedImagesからindexに対応する画像を削除
            storeInfoData.selectedImages.remove(at: index)
        }
        // 削除した際に写真ライブラリのアイテムの選択状態を解除するため、selectedItemsも更新
        // enumerated:PhotosPickerItemの配列にインデックスを付与する
        storeInfoData.selectedItems = storeInfoData.selectedItems.enumerated().compactMap { (index, item) in
            // compactMap:nilを返すと、その要素はPhotosPickerItemの配列に含まれない
            // 選択したインデックス番号を含んでいるものは削除対象としてnilとして扱い、PhotosPickerItem配列のitemから除外する
            return storeInfoData.selectedIndexes.contains(index) ? nil : item
        }
        // 選択をリセット
        storeInfoData.selectedIndexes.removeAll()
    }
}
