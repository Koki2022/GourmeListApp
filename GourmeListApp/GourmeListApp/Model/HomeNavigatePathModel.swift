//
//  HomeNavigatePathModel.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/02/15.
//

import Foundation

// 画面遷移全体の配列パスとして扱う列挙型。UpperCamelCaseで記載し直しました。
// storeRegistrationView,storeSearchViewはシート表示のため削除
enum HomeNavigatePath {
    case storeInfoView, storeEditView
}
