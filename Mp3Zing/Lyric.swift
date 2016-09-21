//
//  Lyric.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/16/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit

struct Lyric {
    var time = ""
    var content = ""
    init(time: String, content: String){
        self.time = time
        self.content = content
    }
}