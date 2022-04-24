//
//  MusicAPI.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/24.
//

import Foundation
import Moya

enum MusicAPI {
    case fetchMusic
}

extension MusicAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}
