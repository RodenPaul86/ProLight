//
//  whatsNewData.swift
//  ProLight
//
//  Created by Paul on 7/13/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct whatsNewData: Identifiable, Hashable {
    var id = UUID()
    var version: String
    var date: String
    var newFeatureBody: String
    var bugFixBody: String
}

var dataComponents: [whatsNewData] = [
    whatsNewData(version: "3.4.0",
                 date: "July, 2023",
                 newFeatureBody: "This is a new version of prolight hfsfgskufgugfsgfgudgfgsfshfisfodsgsgsihgisdhgshgdshgshgsihgsdhgshgsdhgoshgsod;hgohgso;dhgso;hgoshgoshgo;shgodhgoshgoshgoshg",
                 bugFixBody: "This is a new version of prolight hfsfgskufgugfsgfgudgfgsfshfisfodsgsgsihgisdhgshgdshgshgsihgsdhgshgsdhgoshgsod;hgohgso;dhgso;hgoshgoshgo;shgodhgoshgoshgoshg")
]
