//
//  HealthCareManager.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/10/02.
//

import Foundation
import HealthKit

let healthStore = HKHealthStore()
struct ListRowItem{
    
    var id: String
    var datetime: Date
    var count: String
}

class HealthCareManager: NSObject ,ObservableObject{
    
    @Published var date: Date?
    @Published var heartRate: Double?
    
    func get()  {
        // 最新の1件を取得するためのソートディスクリプターを作成
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleType = HKSampleType.quantityType(forIdentifier: .heartRate)! // 監視したいデータタイプを選択
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                // エラーハンドリング
                print("Observer Queryエラー: \(error.localizedDescription)")
                return
            }
            
            let newQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
                    if let error = error {
                        // エラーハンドリング
                        print("データ取得エラー: \(error.localizedDescription)")
                        return
                    }
                    // データが取得できた場合、それをprint
                if let sample = results?.first as? HKQuantitySample {
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    let date = sample.startDate
                    DispatchQueue.main.async {
                        self.heartRate = heartRate
                        self.date = date
                    }
                    print("最新の心拍数: \(heartRate) bpm")
                    print("日付: \(date.description(with: Locale(identifier: "ja_JP")))")
                    }
                }
            healthStore.execute(newQuery)
            // データが変更されたときの処理
            print("データが変更されました。")
            
            // データの変更に対する処理をここに追加します
//            healthStore.execute(query)
            // completionHandlerを呼び出して、Observer Queryを再度登録
            completionHandler()
        }
        healthStore.execute(query)
        
    }
}
