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
        case playTime(time: Double)
    }
    
    enum Mutation {
        case setMusic(music: Music)
        case changePlayState(isPlayed: Bool)
        case getCurrentLyric(index: Int)
        case updateTime(time: String)
        case getCurrentProgress(time: Double)
    }
    
    struct State {
        var music: Music
        var lyrics: [(time: String, lyric: String)]
        /// true: 재생, false: 정지
        var isPlayed: Bool
        var lyricIndex: Int
        var curTime: String
        var progress: Float
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
        isPlayed: false,
        lyricIndex: 0,
        curTime: "00:00",
        progress: 0.0
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
        case .playTime(let time):
            return Observable.concat(
                [
                    getCurrentLyricIndex(time),
                    Observable.just(Mutation.updateTime(time: Int(time).toTimeString())),
                    Observable.just(Mutation.getCurrentProgress(time: time))
                ]
            )
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce call!!!")
        var newState = state
        switch mutation {
        case .setMusic(let music):
            newState.music = music
            newState.lyrics = music.lyrics.split(separator: "\n").map{
                (splitedLyric) -> (time:String, lyric: String) in
                let str = String(splitedLyric)
                let splitIndex = str.index(str.startIndex, offsetBy: 10)
                return (time: String(str[str.startIndex...splitIndex]), lyric: String(str[str.index(splitIndex, offsetBy: 1)...]))
            }
        case .changePlayState(let isPlayed):
            newState.isPlayed = isPlayed
        case .getCurrentLyric(index: let index):
            newState.lyricIndex = index
        case .updateTime(let time):
            newState.curTime = time
        case .getCurrentProgress(time: let time):
            newState.progress = Float(time)
        }
        
        return newState
    }
}

private extension MusicPlayReactor {
    func getCurrentLyricIndex(_ time: Double) -> Observable<Mutation> {
        let index = currentState.lyrics.lastIndex {
            $0.time.tolyricTime() <= time
        }
        return Observable.just(Mutation.getCurrentLyric(index: index ?? 0))
    }
    
   
}

extension String {
    func tolyricTime() -> Double {
        var str = self
        str.removeAll { $0 == "[" || $0 == "]"}
        let splitStr = str.split(separator: ":")
        var result = 0.0
        result += (Double(splitStr[0]) ?? 0) * 60.0
        result += (Double(splitStr[1]) ?? 0)
        result += (Double(splitStr[2]) ?? 0) / 1000.0
        return result
    }
}

extension Int {
    func toTimeString() -> String {
        let min = self/60
        let sec = self%60
        
        return String(format: "%02d:%02d", min,sec)
    }
}
