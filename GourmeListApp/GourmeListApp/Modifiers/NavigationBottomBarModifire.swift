//
//  NavigationBottomBarModifire.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/05/31.
//

import SwiftUI

// NavigationBarTitleModifire:ナビゲーションのボトムバーのスタイルをまとめた構造体
struct NavigationBottomBarModifire: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .frame(width: 350, height: 70)
            .foregroundStyle(.white)
            .background(Color.red)
            .clipShape(.buttonBorder)
            .padding(10)
    }
}

extension View {
    func navigationBottomBarStyle() -> some View {
        self.modifier(NavigationBottomBarModifire())
    }
}
