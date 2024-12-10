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
    // StoreOverViewModelクラスのインスタンス化
    @StateObject private var viewModel = StoreOverViewModel()

    var body: some View {
        Spacer()
        // スクロール機能搭載
        ScrollView {
            VStack {
                //　画像欄
                imageField
                // 横線
                Divider()
                // お店の名前欄
                storeNameField
                // 横線
                Divider()
                // もし訪問状況がvisitedならば訪問日欄を表示
                if viewModel.visitationStatus == .visited {
                    visitDateField
                    Divider()
                }
                // タグ欄
                tagField
                // メモ記入欄
                memoField
                // 営業時間欄
                businessHoursField
                // 横線
                Divider()
                // 電話番号欄
                phoneNumberField
                // 横線
                Divider()
                // 住所欄
                addressField
                // 地図
                mapField
            }
            .padding(.horizontal, 16)
        }
        // NavigationBarを固定
        .navigationBarTitleDisplayMode(.inline)
        // ナビゲーションタイトル
        .toolbar {
            // navigationBarItemsを呼び出す
            navigationBarItems
        }
        // 画面表示時にお店データを取得する
        .onAppear {
            viewModel.setUpStores(store: store)
        }
    }
    // 画像欄のコンポーネント化
    private var imageField: some View {
        // 画像欄
        TabView(selection: $viewModel.selection) {
            // selectedImagesが存在する場合の処理
            if !viewModel.overViewDetailData.selectedImages.isEmpty {
                // imageの数だけ画像を表示
                ForEach(viewModel.overViewDetailData.selectedImages.indices, id: \.self) { index in
                    Image(uiImage: viewModel.overViewDetailData.selectedImages[index])
                        // 画像サイズを変更可能にする
                        .resizable()
                        // 画像全体を表示したいのでscaledToFit
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        // フレームからはみ出た部分を切り取る
                        .clipped()
                        .tag(index)
                }
            } else {
                Text("No Image")
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        // TabViewにframeを実装すると正しく画像が表示される
        .frame(height: 200)
    }
    // 店名欄のコンポーネント化
    private var storeNameField: some View {
        HStack {
            Text("お店の名前")
                .storeInfoTextStyle()
            Text(viewModel.overViewDetailData.storeName)
            Spacer()
        }
    }
    // 訪問状況欄コンポーネント化
    private var visitDateField: some View {
        HStack {
            Text("訪問日")
                .storeInfoTextStyle()
            Text("\(viewModel.overViewDetailData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
            Spacer()
        }
    }
    // タグ欄コンポーネント化
    private var tagField: some View {
        HStack {
            Text("タグ")
                .storeInfoTextStyle()
            // タグがある時
            if !viewModel.selectedTags.isEmpty {
                // 横スクロールでインジケータを非表示にする
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // selectedTagsの各データを取り出す
                        ForEach(viewModel.selectedTags, id: \.self) { tag in
                            Text("# \(tag)")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            Spacer()
        }
    }
    // メモ欄コンポーネント化
    private var memoField: some View {
        TextEditor(text: $viewModel.overViewDetailData.memo)
            // 編集不可モード
            .disabled(true)
            .storeInfoTextFieldStyle(frameHeight: 100, borderColor: .gray, borderWidth: 1)
    }
    // 営業時間欄コンポーネント化
    private var businessHoursField: some View {
        TextEditor(text: $viewModel.overViewDetailData.businessHours)
            // 編集不可モード
            .disabled(true)
            .storeInfoTextFieldStyle(frameHeight: 200, borderColor: .gray, borderWidth: 1)
    }
    // 電話番号欄コンポーネント化
    private var phoneNumberField: some View {
        HStack {
            Text("電話番号")
                .storeInfoTextStyle()
            Text(viewModel.overViewDetailData.phoneNumber)
            Spacer()
        }
    }
    // 住所欄コンポーネント化
    private var addressField: some View {
        HStack {
            Text("住所")
                .storeInfoTextStyle()
            Text(viewModel.overViewDetailData.address)
            Spacer()
        }
        .padding([.bottom], 5)
    }
    // 地図欄コンポーネント化
    private var mapField: some View {
        Map(position: $viewModel.overViewDetailData.position) {
            // 位置情報が存在すればピンを立てる
            if let location = viewModel.overViewDetailData.selectedLocation {
                Marker(item: location)
            }
        }
        .frame(height: 200)
    }
    //　navigationBarItemsのコンポーネント化
    private var navigationBarItems: some ToolbarContent {
        Group {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text(viewModel.overViewDetailData.storeName)
                    .navigationBarTitleStyle()
            }
            // toolbarモディファイアにToolbarItem構造体を渡しtopBarTrailing(右上配置)を指定
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // 編集画面へ遷移
                    navigatePath.append(.storeEditView(store: store!))
                }) {
                    Text("編集")
                }
            }
        }
    }
}

#Preview {
    StoreOverview(navigatePath: .constant([]))
}
