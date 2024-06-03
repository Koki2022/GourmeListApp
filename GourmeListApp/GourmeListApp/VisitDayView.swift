//
//  VisitDayView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/05/21.
//

import SwiftUI

struct VisitDayView: View {
    //　訪問日を設定するカレンダー。現在の日時を取得
    @Binding var setVisitedDay: Date
    var body: some View {
        // 日付の範囲を定義。モーダルシートで表示
        DatePicker("", selection: $setVisitedDay, displayedComponents: [.date])
            .datePickerStyle(.wheel)
        // 日本語対応
        // .environment(\.locale, Locale(identifier: "ja_jp"))
    }
}

#Preview {
    VisitDayView(setVisitedDay: .constant(Date()))
}
