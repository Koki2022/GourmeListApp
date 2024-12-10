//
//  HomeNavigatePathModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/02/15.
//

import Foundation

//　ナビゲーション遷移する画面の管理
enum HomeNavigatePath: Hashable {
    case StoreOverview(store: Stores)
    case storeEditView(store: Stores)
}
