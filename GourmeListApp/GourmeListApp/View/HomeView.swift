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
    // 画面遷移全体のナビゲーションの状態を管理する配列パス。private変数の中で一番先に使用される変数なので一番上に記載。
    @State private var navigatePath: [HomeNavigatePath] = []
    // ホーム画面用のタグ選択画面のシートの状態を管理する変数。Bool型は先にisをつけると分かりやすい
    @State private var isTagSelectionVisible: Bool = false
    // 訪問状況を管理する変数
    @State private var visitationStatus: VisitationStatus = .visited
    // お店登録画面のシートの状態を管理する変数。
    @State private var isStoreRegistrationVisible: Bool = false
    // 入力された内容を反映する変数
    @State private var text: String = ""

    var body: some View {
        // NavigationStackと配列パスの紐付け
        NavigationStack(path: $navigatePath) {
            VStack {
                // #とタブボタンの実装
                HStack {
                    Spacer()
                    // タグボタン
                    Button(action: {
                        // ハーフモーダルでタグ選択画面のシートを表示
                        isTagSelectionVisible.toggle()
                    }) {
                        Text("#")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 30)
                            .border(Color.gray)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(10)
                    }
                    Spacer()
                    // 行ったリストと気になるリストのタブ作成
                    Picker("行った気になるを選択", selection: $visitationStatus) {
                        Text("行った").tag(VisitationStatus.visited)
                        Text("気になる").tag(VisitationStatus.interested)
                    }
                    .pickerStyle(.segmented)
                    Spacer()
                }
                Spacer()
                // リストがない場合は作成しようと表示
                if fetchedStores.isEmpty {
                    Text("お店リストを作成しよう！")
                    Spacer()
                } else {
                    List {
                        // リスト表示
                        ForEach(fetchedStores) { store in
                            HStack {
                                // 各リストの左側に自分が撮影した写真を載せる
                                Image("")
                                    // サイズ変更モードに設定
                                    .resizable()
                                    // 写真をリストのビューにフィットするようにアスペクト比を維持
                                    .aspectRatio(contentMode: .fit)
                                    // 枠の高さを調整
                                    .frame(height: 60)
                                Button(action: {
                                    // お店情報画面へ遷移
                                    navigatePath.append(.storeInfoView)
                                }) {
                                    Text("\(store.name ?? "店名なし")")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    }

                }
            }
            // onChangeを使用してfetchedStoresのpredicateを更新
            .onChange(of: visitationStatus) {
                // visitationStatusが変更された際に動的にフィルタリング
                fetchedStores.nsPredicate = NSPredicate(format: "visitationStatus == %i", visitationStatus.rawValue)
            }
            // 遷移先のビューをそれぞれ定義
            .navigationDestination(for: HomeNavigatePath.self) { value in
                switch value {
                // お店情報画面のビューを定義
                case .storeInfoView:
                    StoreOverview(navigatePath: $navigatePath)
                // お店編集画面のビューを定義
                case .storeEditView:
                    StoreEditView(navigatePath: $navigatePath)
                }
            }
            // NavigationBarを固定する
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションタイトルの文字サイズを変更
            .toolbar {
                // toolbarモディファイアにToolbarItem構造体を渡しprincipal(中央配置)を指定
                ToolbarItem(placement: .principal) {
                    Text("一覧")
                        .navigationBarTitleStyle()
                }
                // ボトムバーにお店を追加ボタン作成
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // お店登録画面をシート表示
                        isStoreRegistrationVisible.toggle()
                    }) {
                        Text("お店を追加")
                            .navigationBottomBarStyle()
                    }
                }
            }
        }
        // 店名検索バーの実装
        .searchable(text: $text, prompt: Text("店名を入力"))
        // タグ選択画面を表示する際の設定
        .sheet(isPresented: $isTagSelectionVisible) {
            // タグ選択画面を表示
            TagSelectionView()
                // ハーフモーダルで表示。全画面とハーフに可変できるようにする。
                .presentationDetents([
                    .medium,
                    .large
                ])
        }
        // お店登録画面をフルスクリーンで表示
        .fullScreenCover(isPresented: $isStoreRegistrationVisible) {
            StoreRegistrationView()
        }
    }
}

#Preview {
    HomeView()
}
