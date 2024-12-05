//
//  StoreInfoView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/23.
//

import SwiftUI
import MapKit

//　StoreOverview:店舗概要画面
struct StoreOverview: View {
    // お店データを格納する変数
    var store: Stores?
    // ホーム画面から受け取った配列パスの参照
    @Binding var navigatePath: [HomeNavigatePath]
    // タブの選択項目を保持する変数
    @State private var selection: Int = 0
    //　訪問日を設定するカレンダー。現在の日時を取得
    @State private var visitDate: Date = Date()
    // メモ記入欄の内容を反映する変数
    @State private var memo: String = ""
    // 営業時間の内容を反映する変数
    @State private var businessHours: String = ""
    // メニューを管理するactionSheetの状態を表す変数
    @State private var isMenuVisible: Bool = false
    // お店情報削除の際のアラートを管理する変数
    @State private var isDeleteVisible: Bool = false
    var body: some View {
        // スクロール機能搭載
        ScrollView {
            VStack {
                // TabView実装
                TabView(selection: $selection) {
                    // ファイル名を取得してUIImageを作成
                    if let fileNames = store?.fileName {
                        // fileNamesからUIImageを作成
                        let images = loadImagesFromFileNames(fileNames: fileNames)
                        // imageの数だけ画像を表示
                        ForEach(images.indices, id: \.self) { index in
                            Image(uiImage: images[index])
                                // 画像サイズを変更可能にする
                                .resizable()
                                // 表示枠を覆い尽くす最小サイズ
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                // フレームからはみ出た部分を切り取る
                                .clipped()
                                .padding(5)
                                .tag(index)
                        }
                    } else {
                        Text("No Image")
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                // TabViewにframeを実装すると正しく画像が表示される
                .frame(height: 200)
                // 横線
                Divider()
                // お店の名前欄
                HStack {
                    Text("お店の名前")
                        .storeInfoTextStyle()
                    Spacer()
                }
                // 横線
                Divider()
                // 訪問日欄
                HStack {
                    Text("訪問日")
                        .storeInfoTextStyle()
                    Text("\(visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
                    Spacer()
                }
                // 横線
                Divider()
                // タグ欄
                HStack {
                    Text("タグ")
                        .storeInfoTextStyle()
                    // 横スクロールでインジケータを非表示にする
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text("# ダミー")
                            .frame(width: 80, height: 32)
                            .font(.system(size: 15))
                            .overlay(alignment: .center) {
                                // 角丸長方形
                                RoundedRectangle(cornerRadius: 10)
                                    // 黒縁にする
                                    .stroke(Color.black)
                            }
                            // 背景色をグレーにする
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
                    }
                    Spacer()
                }
                // メモ記入欄
                TextEditor(text: $memo)
                    // 編集不可モード
                    .disabled(true)
                    .storeInfoTextFieldStyle(frameHeight: 100, borderColor: .gray, borderWidth: 1)
                // 営業時間欄
                TextEditor(text: $businessHours)
                    // 編集不可モード
                    .disabled(true)
                    .storeInfoTextFieldStyle(frameHeight: 200, borderColor: .gray, borderWidth: 1)
                // 横線
                Divider()
                // 電話番号欄
                HStack {
                    Text("電話番号")
                        .storeInfoTextStyle()
                    Spacer()
                }
                // 横線
                Divider()
                // 郵便番号欄
                HStack {
                    Text("郵便番号")
                        .storeInfoTextStyle()
                    Spacer()
                }
                // 横線
                Divider()
                // 住所欄
                HStack {
                    Text("住所")
                        .storeInfoTextStyle()
                    Spacer()
                }
                .padding([.bottom], 5)
                // 地図
                Map()
                    .frame(height: 200)
            }
            .padding(.horizontal, 16)
        }
        // NavigationBarを固定
        .navigationBarTitleDisplayMode(.inline)
        // ナビゲーションタイトル
        .toolbar {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("お店の名前")
                    .navigationBarTitleStyle()
            }
            // toolbarモディファイアにToolbarItem構造体を渡しtopBarTrailing(右上配置)を指定
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // actionSheetの状態をtrueにする
                    isMenuVisible.toggle()
                }) {
                    Text("編集")
                }
            }
        }
        // 編集ボタン押した際の設定
        .confirmationDialog("", isPresented: $isMenuVisible) {
            Button(action: {
                // 次の画面へ遷移(お店編集画面へ遷移)
                navigatePath.append(.storeEditView)
            }) {
                Text("お店情報を編集する")
            }
            // 削除ボタン実装
            Button("削除する", role: .destructive) {
                // アラート起動
                isDeleteVisible.toggle()
                // このシートを削除する処理
            }
        }
        .alert("削除しますか？", isPresented: $isDeleteVisible) {
            // ダイアログ内で行うアクション処理
            // キャンセルボタン実装
            Button("キャンセル", role: .cancel) {
                // キャンセル実行時の処理
            }
            // 削除ボタン
            Button("削除", role: .destructive) {
                // ホーム画面に戻る
                navigatePath.removeAll()
                // このシートを削除する処理
            }
        } message: {
            // アラートのメッセージ
            Text("この操作は取り消しできません")
        }
    }
    // ファイル名を取得してUIImageを作成する関数
    private func loadImagesFromFileNames(fileNames: String) -> [UIImage] {
        // 取得したファイル名をカンマ区切りで配列に格納
        let fileNameArray = fileNames.components(separatedBy: ",")

        // nilを除いて配列の値を渡す
        return fileNameArray.compactMap { fileName in
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
}

#Preview {
    StoreOverview(navigatePath: .constant([]))
}
