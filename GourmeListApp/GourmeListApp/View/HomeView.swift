//
//  HomeView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2023/12/20.
//

// Run実行時にSandbox: ... deny(1) file-read-data エラー
// Podfile.lockにデフォルトでアクセスできない(Build PhaseのCheck Pod欄に情報あり)
// Build Settings の User Script Sandboxing を No にするとエラー解決

import SwiftUI
import CoreData

//　HomeView:お店一覧画面(ホーム画面)
struct HomeView: View {
    // SwiftUIの環境からmanagedObjectContextを取得してCoreDataの操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // 訪問日順でソート、%iで数値の値を検索しフィルタリング
    @FetchRequest(entity: Stores.entity(), sortDescriptors: [NSSortDescriptor(key: "visitDate", ascending: false)], predicate: (NSPredicate(format: "visitationStatus == %i", 0))) private var fetchedStores: FetchedResults<Stores>
    // 変数の順序は関連性に基づくグループ、プロパティラッパーの種類、アクセス修飾子、使用される順を意識
    // HomeViewModelクラスをインスタンス化
    @StateObject private var viewModel = HomeViewModel()
    // 画面遷移全体のナビゲーションの状態を管理する配列パス。
    @State private var navigatePath: [HomeNavigatePath] = []
    // 選択したタグを管理する変数
    @State private var selectedTags: [String] = []

    var body: some View {
        // NavigationStackと配列パスの紐付け
        NavigationStack(path: $navigatePath) {
            VStack {
                // #とタブボタンの実装
                HStack {
                    Spacer()
                    // タグ選択ボタン
                    tagSelectionButton
                    Spacer()
                    // 訪問状態タブ
                    visitationStatusPicker
                    Spacer()
                }
                // 選択中のタグを表示する欄
                if selectedTags.isEmpty {
                    // タグ未選択時のタグ欄
                    emptyTagsView
                } else {
                    selectedTagsView
                }
                Spacer()
                // リストがない場合は作成しようと表示
                if fetchedStores.isEmpty {
                    Text("お店リストを作成しよう！")
                    Spacer()
                } else {
                    // お店リストを表示
                    filteredStoresListView
                }
            }
            // 遷移先のビューをそれぞれ定義
            .navigationDestination(for: HomeNavigatePath.self) { value in
                switch value {
                // お店情報画面のビューを定義
                case .StoreOverview(let store):
                    StoreOverview(store: store, navigatePath: $navigatePath)
                // お店編集画面のビューを定義
                case .storeEditView(let store):
                    StoreEditView(store: store, navigatePath: $navigatePath)
                }
            }
            // NavigationBarを固定する
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションタイトルの文字サイズを変更
            .toolbar {
                // navigationBarItemsを呼び出す
                navigationBarItems
            }
        }
        // 画面表示の際にデータを更新
        .onAppear(perform: updateStoreDataAndSelectedTags)
        // isStoreRegistrationVisibleの値を監視
        .onChange(of: viewModel.isStoreRegistrationVisible) { _, isVisible in
            // isStoreRegistrationVisibleシート非表示(false)の際,userSelectedTagsとcoreDataFetchedStoresにデータを渡す
            if !isVisible {
                // データを更新
                updateStoreDataAndSelectedTags()
            }
        }
        //　selectedTagsの値を監視
        .onChange(of: selectedTags) {
            // タグが選択されたらデータを更新
            updateStoreDataAndSelectedTags()
        }
        // onChangeを使用してfetchedStoresのpredicateを更新
        .onChange(of: viewModel.visitationStatus) {
            // visitationStatusが変更された際に動的にフィルタリング
            fetchedStores.nsPredicate = NSPredicate(format: "visitationStatus == %i", viewModel.visitationStatus.rawValue)
            // タブの状態が変化したらデータ更新
            updateStoreDataAndSelectedTags()
        }
        // 店名検索バーの実装
        .searchable(text: $viewModel.storeName, prompt: Text("店名を入力"))
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $viewModel.isTagSelectionVisible) {
            tagSelectionSheet
        }
        // お店登録画面をフルスクリーンで表示
        .fullScreenCover(isPresented: $viewModel.isStoreRegistrationVisible) {
            StoreRegistrationView()
        }
    }
    // タグ選択ボタンのコンポーネント化
    private var tagSelectionButton: some View {
        // タグボタン
        Button(action: {
            // ハーフモーダルでタグ選択画面のシートを表示
            viewModel.isTagSelectionVisible.toggle()
        }) {
            Text("#")
                .font(.system(size: 20))
                .frame(width: 50, height: 30)
                // 枠線の角が消失してたのでViewを変更
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .foregroundStyle(.black)
                .padding(10)
        }
    }
    // 訪問状態タブのコンポーネント化
    private var visitationStatusPicker: some View {
        // 行ったリストと気になるリストのタブ作成
        Picker("行った気になるを選択", selection: $viewModel.visitationStatus) {
            Text("行った").tag(VisitationStatus.visited)
            Text("気になる").tag(VisitationStatus.interested)
        }
        .pickerStyle(.segmented)
    }
    // タグ未選択時のタグ欄
    private var emptyTagsView: some View {
        // 選択中のタグ
        HStack {
            Spacer()
            Text("選択中のタグなし")
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    // 選択中のタグを表示する欄
    private var selectedTagsView: some View {
        // TagSelectionViewで選択したタグを表示
        HStack {
            Spacer()
            Text("選択中のタグ")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(selectedTags, id: \.self) { tag in
                        Text("\(tag)")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            Spacer()
            // タグをまとめて削除するためのxボタン
            Button(action: {
                selectedTags.removeAll()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    // お店リストのコンポーネント化
    private var filteredStoresListView: some View {
        List {
            // リスト表示
            ForEach(viewModel.filteredStores) { store in
                HStack {
                    // CoreDataの最初のファイル名を読み込み、1枚目に選択した画像を表示
                    if let firstFileName = store.fileName?.components(separatedBy: ",").first,
                       let image = viewModel.loadImageFromDocuments(fileName: firstFileName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 60)
                            .clipped()
                    } else {
                        // 画像未登録ならphotoアイコン
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 60)
                            .foregroundStyle(Color.gray)
                    }
                    Spacer()
                    Button(action: {
                        // お店情報画面へ遷移。storeのデータも渡す
                        navigatePath.append(.StoreOverview(store: store))
                    }) {
                        Text("\(store.name ?? "店名なし")")
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
            }
            // リスト削除処理
            .onDelete(perform: { indexSet in
                //　削除対象の整数値をセット
                viewModel.indexSetToDelete = indexSet
                // アラートセット
                viewModel.isDeleteItem.toggle()
            })
        }
        // リスト削除時のアラート
        .alert("お店を削除しますか？", isPresented: $viewModel.isDeleteItem) {
            Button("削除", role: .destructive) {
                // 削除対象のデータがある場合
                if let indexSet = viewModel.indexSetToDelete {
                    withAnimation {
                        // 選択した画像を削除する
                        viewModel.deleteItems(offsets: indexSet, fetchedStores: fetchedStores, viewContext: viewContext)
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
    //　navigationBarItemsのコンポーネント化
    private var navigationBarItems: some ToolbarContent {
        Group {
            // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
            ToolbarItem(placement: .principal) {
                Text("一覧")
                    .navigationBarTitleStyle()
            }
            // ボトムバーにお店を追加ボタン作成
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    // お店登録画面をシート表示
                    viewModel.isStoreRegistrationVisible.toggle()
                }) {
                    Text("お店を追加")
                        .navigationBottomBarStyle()
                }
            }
        }
    }
    // タグ選択シートコンポーネント化
    private var tagSelectionSheet: some View {
        // タグ選択画面を表示
        TagSelectionView(selectedTags: $selectedTags)
            // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
            .presentationDetents([
                .medium,
                .large
            ])
    }
    // お店データとタグを更新する関数
    private func updateStoreDataAndSelectedTags() {
        //　お店データを更新
        viewModel.coreDataFetchedStores = Array(fetchedStores)
        // 選択しているタグを更新
        viewModel.userSelectedTags = selectedTags
    }
}

#Preview {
    HomeView()
}
