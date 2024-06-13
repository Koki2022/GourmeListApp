//
//  StoreInfoTextFieldModifier.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/05/31.
//

import SwiftUI

// StoreInfoTextFieldModifier:お店情報のテキストフィールドスタイルをまとめた構造体
struct StoreInfoTextFieldModifier: ViewModifier {
    var frameHeight: CGFloat
    var borderColor: Color
    var borderWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(height: frameHeight)
            .border(borderColor, width: borderWidth)
    }
}

extension View {
    func storeInfoTextFieldStyle(
        frameHeight: CGFloat,
        borderColor: Color,
        borderWidth: CGFloat
    ) -> some View {
        self.modifier(
            StoreInfoTextFieldModifier(
                frameHeight: frameHeight,
                borderColor: borderColor,
                borderWidth: borderWidth
            )
        )
    }
}
