//
//  Anniversary-forgetting-oreventionModel.swift
//  Anniversary-forgetting-prevention
//
//  Created by 徳富博 on 2021/04/26.
//

import RealmSwift

class Anniversary: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()
    
    //プレゼント有無
    @objc dynamic var present = false

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
