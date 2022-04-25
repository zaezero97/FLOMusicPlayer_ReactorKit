//
//  MusicPlayReactor.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/23.
//

import Foundation
import ReactorKit

final class MusicPlayReactor: Reactor {
    
    enum Action {
        case refresh
        case play
        case stop
    }
    
    enum Mutation {
        case setMusic(music: Music)
        case changePlayState(isPlayed: Bool)
    }
    
    struct State {
        var music: Music
        var lyrics: [String]
        /// true: 재생, false: 정지
        var isPlayed: Bool
        
    }
    
    let initialState: State = .init(
        music: Music(
            singer: "제제로",
            album: "무한 열차와다다다",
            title: "에브리바디 부처핸섭",
            duration: 456,
            image: "",
            file: "",
            lyrics: "ㄹㄴㅇㅁㅇㄹㅇㄴㅁ"
        ),
        lyrics: [],
        isPlayed: false
    )
    
    private let musicAPIService: MusicAPIService
    
    init(musicAPIService: MusicAPIService) {
        self.musicAPIService = musicAPIService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        print("mutate call!!!")
        switch action {
        case .refresh:
            let setMusic = musicAPIService.fetchMusic()
                .compactMap { result -> Music? in
                    guard case let .success(music) = result else { return nil }
                    return music
                }.map {
                    Mutation.setMusic(music: $0)
                }
            return Observable.concat([Observable.just(Mutation.changePlayState(isPlayed: false)), setMusic])
        case .play:
            return Observable.just(Mutation.changePlayState(isPlayed: true))
        case .stop:
            return Observable.just(Mutation.changePlayState(isPlayed: false))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce call!!!")
        var newState = state
        switch mutation {
        case .setMusic(let music):
            newState.music = music
            newState.lyrics = music.lyrics.components(separatedBy: "\n")
        case .changePlayState(let isPlayed):
            newState.isPlayed = isPlayed
        }
        
        return newState
    }
}
