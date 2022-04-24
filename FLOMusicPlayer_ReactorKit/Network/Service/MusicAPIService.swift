//
//  MusicAPIService.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/24.
//

import Foundation
import Moya
import RxSwift

final class MusicAPIService: Networkable {
    typealias Target = MusicAPI
    
    private let provider = makeProvider()
    
    func fetchMusic() -> Observable<Result<Music,Error>> {
        return provider.rx.request(.fetchMusic)
            .filterSuccessfulStatusCodes()
            .map(Music.self)
            .map { Result.success($0) }
            .catch{ .just(Result.failure($0)) }
            .asObservable()
    }
}
