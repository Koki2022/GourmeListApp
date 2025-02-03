//
//  StoreRegistrationView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/01/31.
//

import SwiftUI
import PhotosUI
import CoreData
import MapKit

//　StoreRegistrationView:お店登録画面
struct StoreRegistrationView: View {
    // プロパティラッパー @FetchRequestで、データベースよりデータを取得
    @FetchRequest(entity: Stores.entity(), sortDescriptors: []
    ) private var fetchedStores: FetchedResults<Stores>
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // タグ選択画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    // StoreRegistrationViewModelクラスをインスタンス化
    @StateObject private var viewModel = StoreRegistrationViewModel()

    var body: some View {
        NavigationStack {
            Spacer()
            ScrollView {
                VStack {
                    // 画像表示
                    ImageScrollView(viewModel: viewModel)
                    Divider()
                    // 店名欄
                    storeNameField
                    Divider()
                    // 訪問状況欄
                    visitationStatusField
                    Divider()
                    // 訪問状況行ったを選択したら訪問日欄を表示
                    if viewModel.visitationStatus == .visited {
                        visitDateField
                        Divider()
                    }
                    // タグ欄
                    tagField
                    Divider()
                    // メモ記入欄
                    memoField
                    // 営業時間欄
                    businessHoursField
                    Divider()
                    // 電話番号欄
                    phoneNumberField
                    Divider()
                    // 住所欄
                    addressField
                    // 地図
                    mapField
                    Divider()
                }
                .padding(.horizontal, 16)
                // 選択画像消去のアラート
                .alert("削除しますか？", isPresented: $viewModel.isDeleteImageVisible) {
                    Button("この画像を削除", role: .destructive) {
                        // 選択した画像を削除する
                        viewModel.deleteSelectedImages()
                    }
                    Button("キャンセル", role: .cancel) { }
                }
            }
            // NavigationBarを固定する
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションタイトルの文字サイズを変更
            .toolbar {
                // navigationBarItemsを呼び出す
                navigationBarItems
            }
            // 検索画面から登録画面へ遷移時に、該当住所のマップ上にピンを立てる
            .onAppear {
                viewModel.searchAddress()
            }
            // お店検索画面を表示する際の設定
            .fullScreenCover(isPresented: $viewModel.isStoreSearchVisible) {
                // 登録画面の店舗概要データとバインディング
                StoreSearchView(storeDetailData: $viewModel.registrationViewDetailData)
            }
            // 訪問日画面を表示する際の設定
            .sheet(isPresented: $viewModel.isVisitDateVisible) {
                visitDateSheet
            }
            // タグ選択画面を表示する際の設定
            .sheet(isPresented: $viewModel.isTagSelectionVisible) {
                tagAddSheet
            }
        }
    }
    // 店名欄コンポーネント化
    private var storeNameField: some View {
        // 店名欄
        HStack {
            Text("お店の名前")
                .storeInfoTextStyle()
            // 店名を記載するスペース
            TextField("", text: $viewModel.registrationViewDetailData.storeName)
                // 最大幅
                .frame(maxWidth: .infinity)
            //　虫眼鏡
            Button(action: {
                // お店検索画面へ遷移
                viewModel.isStoreSearchVisible.toggle()
            }) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
    // 訪問状況欄コンポーネント化
    private var visitationStatusField: some View {
        HStack {
            Text("訪問状況")
                .storeInfoTextStyle()
            // Picker
            Picker("訪問状況を選択", selection: $viewModel.visitationStatus) {
                Text("行った").tag(VisitationStatus.visited)
                Text("気になる").tag(VisitationStatus.interested)
            }
            Spacer()
        }
    }
    // 訪問日欄コンポーネント化
    private var visitDateField: some View {
        HStack {
            Text("訪問した日")
                .storeInfoTextStyle()
            // 訪問日設定シートを有効にする
            Button(action: {
                viewModel.isVisitDateVisible.toggle()
            }) {
                Text("\(viewModel.registrationViewDetailData.visitDate, format: Date.FormatStyle(date: .numeric, time: .omitted))")
                    .frame(width: 112)
                    .foregroundStyle(.black)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.3)))
                    .padding(10)
            }
            Spacer()
        }
    }
    // タグ欄コンポーネント化
    private var tagField: some View {
        HStack {
            Text("タグ")
                .storeInfoTextStyle()
            // TagAddViewで選択されたタグを表示
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.selectedTags, id: \.self) { tag in
                        Text("# \(tag)")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            Spacer()
            Button(action: {
                // タグ選択画面へ遷移
                viewModel.isTagSelectionVisible.toggle()
            }) {
                Image(systemName: "plus.circle")
            }
        }
    }
    // メモ欄コンポーネント化
    private var memoField: some View {
        TextEditor(text: $viewModel.registrationViewDetailData.memo)
            .storeInfoTextFieldStyle(
                frameHeight: 100,
                borderColor: .gray,
                borderWidth: 1
            )
            // プレースホルダーを追加
            .overlay(alignment: .center) {
                // 未入力時、プレースホルダーを表示
                if viewModel.registrationViewDetailData.memo.isEmpty {
                    Text("メモ記入欄")
                        .allowsHitTesting(false) // タップ判定を無効化
                        .foregroundStyle(Color(uiColor: .placeholderText))
                }
            }
    }
    // 営業時間欄コンポーネント化
    private var businessHoursField: some View {
        TextEditor(text: $viewModel.registrationViewDetailData.businessHours)
            .storeInfoTextFieldStyle(
                frameHeight: 200,
                borderColor: .gray,
                borderWidth: 1
            )
            // プレースホルダーを追加
            .overlay(alignment: .center) {
                // 未入力時、プレースホルダーを表示
                if viewModel.registrationViewDetailData.businessHours.isEmpty {
                    Text("営業時間")
                        .allowsHitTesting(false) // タップ判定を無効化
                        .foregroundStyle(Color(uiColor: .placeholderText))
                }
            }
    }
    // 電話番号欄コンポーネント化
    private var phoneNumberField: some View {
        HStack {
            Text("電話番号")
                .storeInfoTextStyle()
            // 電話番号欄
            TextField("", text: $viewModel.registrationViewDetailData.phoneNumber)
                // 電話番号入力タイプのキーボード
                .keyboardType(.phonePad)
        }
    }
    // 住所欄コンポーネント化
    private var addressField: some View {
        HStack {
            Text("住所")
                .storeInfoTextStyle()
            TextField("", text: $viewModel.registrationViewDetailData.address)
                // 入力完了直後に住所を検索
                .onSubmit {
                    viewModel.searchAddress()
                }
        }
        .padding([.bottom], 5)
    }
    // 地図欄コンポーネント化
    private var mapField: some View {
        Map(position: $viewModel.registrationViewDetailData.position) {
            // 位置情報が存在すればピンを立てる
            if let location = viewModel.registrationViewDetailData.selectedLocation {
                Marker(item: location)
            }
        }
        .frame(height: 200)
    }
    // 訪問日シートコンポーネント化
    private var visitDateSheet: some View {
        VisitDateView(visitDate: $viewModel.registrationViewDetailData.visitDate)
            // シートの高さをカスタマイズ
            .presentationDetents([.height(280)])
    }
    // タグ追加シートコンポーネント化
    private var tagAddSheet: some View {
        // タグ追加画面を表示
        TagAddView(selectedTags: $viewModel.selectedTags)
            // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
            .presentationDetents([
                .medium,
                .large
            ])
    }
    //　NavigationBarItemをコンポーネント化
    private var navigationBarItems: some ToolbarContent {
        // 複数のToolbarItemをGroupでまとめる
        Group {
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
                    // 登録したお店情報をCoreDataに保存
                    viewModel.saveStoreInfo(viewContext: viewContext)
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

#Preview {
    StoreRegistrationView()
}
