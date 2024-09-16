//
//  StoreRegistrationView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/31.
//

import SwiftUI
import PhotosUI
import CoreData

//　StoreRegistrationView:お店登録画面
struct StoreRegistrationView: View {
    // プロパティラッパー @FetchRequestで、データベースよりデータを取得
    @FetchRequest(entity: Stores.entity(), sortDescriptors: []
    ) private var fetchedStores: FetchedResults<Stores>
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // お店情報データ構造体の初期化
    @State var storeInfoData: StoreInfoData = StoreInfoData(selectedItems: [], selectedImages: [], selectedIndexes: [], storeName: "", visitStatusTag: 0, visitDate: Date(), memo: "", businessHours: "", phoneNumber: "", postalCode: "", address: "")
    // お店検索画面シートの状態を管理する変数。
    @State private var isStoreSearchVisible: Bool = false
    // 訪問日を設定するシートの状態を管理する変数。
    @State private var isVisitDateVisible: Bool = false
    // タグ選択画面のシートの状態を管理する変数。
    @State private var isTagSelectionVisible: Bool = false

    var body: some View {
        NavigationStack {
            Spacer()
            ScrollView {
                // カスタムViewを実装
                StoreInfoEditorView(storeInfoData: $storeInfoData, isStoreSearchVisible: $isStoreSearchVisible, isVisitDateVisible: $isVisitDateVisible, isTagSelectionVisible: $isTagSelectionVisible)
                    // NavigationBarを固定する
                    .navigationBarTitleDisplayMode(.inline)
                    // ナビゲーションタイトルの文字サイズを変更
                    .toolbar {
                        // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
                        ToolbarItem(placement: .principal) {
                            Text("お店情報の登録")
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
                        // ボトムバーにお店リストに追加ボタンを作成
                        ToolbarItem(placement: .bottomBar) {
                            Button(action: {
                                // 登録した情報を保存
                                addPhotosItem()
                                // CoreDataをチェック
                                print("CoreDataに登録したファイル名の件数: \(fetchedStores.count)件")
                                // ホーム画面に遷移
                                dismiss()
                            }) {
                                Text("お店リストに追加")
                                    .navigationBottomBarStyle()
                            }
                        }
                    }
            }
        }
    }
    // UIImageをストレージに保存し、ファイル名を返す関数
    private func saveImageAndGetFileName(image: UIImage) -> String? {
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
    private func addPhotosItem() {
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
}

#Preview {
    StoreRegistrationView()
}
