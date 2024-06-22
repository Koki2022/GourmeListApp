//
//  StoreEditView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/30.
//

import SwiftUI

//　StoreEditView:お店編集画面
struct StoreEditView: View {
    // ホーム画面から受け取った配列パスの参照
    @Binding var navigatePath: [HomeNavigatePath]
    //　店名の内容を反映する変数。
    @State private var storeName: String = ""
    // お店検索画面シートの状態を管理する変数。
    @State private var isStoreSearchVisible: Bool = false
    //　訪問状況Pickerの識別値を管理する変数
    @State private var visitStatusTag: Int = 0
    // 訪問日を設定するシートの状態を管理する変数。
    @State private var isVisitDateVisible: Bool = false
    //　訪問日を設定するカレンダー。現在の日時を取得
    @State private var visitDate: Date = Date()
    // タグ選択画面のシートの状態を管理する変数。
    @State private var isTagSelectionVisible: Bool = false
    // メモ記入欄の内容を反映する変数。
    @State private var memo: String = ""
    // 営業時間の内容を反映する変数。
    @State private var businessHours: String = ""
    //　電話番号を反映する変数。
    @State private var phoneNumber: String = ""
    //　郵便番号を反映する変数。
    @State private var postalCode: String = ""
    //　住所を反映する変数。
    @State private var address: String = ""
    var body: some View {
        Spacer()
        // スクリーン画面
        ScrollView {
            //　カスタムVIew
            StoreInfoEditorView(storeName: $storeName, isStoreSearchVisible: $isStoreSearchVisible, visitStatusTag: $visitStatusTag, isVisitDateVisible: $isVisitDateVisible, visitDate: $visitDate, isTagSelectionVisible: $isTagSelectionVisible, memo: $memo, businessHours: $businessHours, phoneNumber: $phoneNumber, postalCode: $postalCode, address: $address)
        }
        // NavigationBarを固定する
        .navigationBarTitleDisplayMode(.inline)
        // ナビゲーションタイトルの文字サイズを変更
        .toolbar {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店情報の編集")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
            }
            // ボトムバーにお店リストに追加ボタンを作成
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    // 登録した情報を保存
                    // お店情報画面に遷移
                    navigatePath.removeLast()
                }) {
                    Text("編集内容を追加する")
                        .navigationBottomBarStyle()
                }
            }
        }
    }
}

#Preview {
    StoreEditView(navigatePath: .constant([]))
}
