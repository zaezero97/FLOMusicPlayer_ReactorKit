//
//  Music.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/24.
//

import Foundation

struct Music: Decodable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String /// 이미지 url
    let file: String /// music file url
    let lyrics: String /// 시간에 대한 재생되는 가사
}
