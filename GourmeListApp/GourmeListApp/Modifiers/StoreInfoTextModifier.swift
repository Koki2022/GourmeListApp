//
//  InfoTextModifier.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/03/31.
//

import SwiftUI

// ViewModifier:ビューまたは別のビュー モディファイアに適用して、元の値の異なるバージョンを生成するモディファイア。
// カスタムModifierはViewModifier protocolに準じた構造体として定義
// StoreInfoTextModifier:お店情報のテキストスタイルをまとめた構造体
struct StoreInfoTextModifier: ViewModifier {
    // Content:contentViewのbodyに値を渡す
    //　typealias：モディファイアを抽象化して受け付ける
    func body(content: Content) -> some View {
        content
            .frame(width: 80)
            .foregroundStyle(Color.gray)
    }
}

extension View {
    func storeInfoTextStyle() -> some View {
        // modifier:ビューにモディファイアを適用し、新しいビューを返す。modifier()メソッドを任意のメソッドに置き換えられる。
        self.modifier(StoreInfoTextModifier())
    }
}
