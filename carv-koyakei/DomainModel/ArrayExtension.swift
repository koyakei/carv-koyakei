//
//  ArrayExtension.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/10/16.
//


extension Array where Element == Float {
    // ２つのFloat配列足し算
    static func + (lhs: [Float], rhs: [Float]) -> [Float] {
        precondition(lhs.count == rhs.count, "配列の長さが一致しません")
        return zip(lhs, rhs).map { $0 + $1 }
    }
    
    static func / (lhs: [Float], rhs: Float) -> [Float] {
        return lhs.map{$0 / rhs}
    }
}
