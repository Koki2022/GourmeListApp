//
//  VisitDayView.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2024/05/21.
//

import SwiftUI

struct VisitDayView: View {
    // 訪問日設定画面を閉じるための動作を呼び出す変数。
    @Environment(\.dismiss) private var dismiss
    //　訪問日を設定するカレンダー。現在の日時を取得
    @Binding var visitDate: Date
    var body: some View {
        VStack {
            // 決定ボタン
            HStack {
                Spacer()
                Button(action: {
                    // 適用されたタグがあればホーム画面の選択中のタグに表示
                    // viewを閉じて一覧画面へ遷移
                    dismiss()
                }) {
                    Text("決定")
                        .font(.system(size: 20))
                        .foregroundStyle(.red)
                        .padding(8)
                }
            }
            Divider()
            // 日付の範囲を定義(機能実装の際にやる)
            DatePicker("", selection: $visitDate, displayedComponents: [.date])
                // ホイール形式
                .datePickerStyle(.wheel)
                // ラベルを非表示にするとピッカーが真ん中に配置される
                .labelsHidden()
        }
    }
}

#Preview {
    VisitDayView(visitDate: .constant(Date()))
}
