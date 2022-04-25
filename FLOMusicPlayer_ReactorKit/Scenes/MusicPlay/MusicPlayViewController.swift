//
//  MusicPlayViewController.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/23.
//

import UIKit
import ReactorKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Kingfisher
import AVFAudio

final class MusicPlayViewController: BaseViewController, View {
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28.0, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let singerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16.0, weight: .regular)
        $0.textAlignment = .center
    }
    
    private let titleImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.cornerRadius = 16.0
        $0.layer.masksToBounds = true
    }
    
    private let progressBar = UISlider()
    
    private let lyricsTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.register(LyricCell.self, forCellReuseIdentifier: LyricCell.identifier)
        $0.separatorStyle = .none
        $0.rowHeight = 45.0
    }
    
    private let replyButton = UIButton().then {
        $0.setImage(UIImage(systemName: "repeat"), for: .normal)
    }
    
    private let backwardButton = UIButton().then {
        $0.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
    }
    
    private let playButton = UIButton().then {
        $0.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    private let forwardButton = UIButton().then {
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
    }
    
    private let shuffleButton = UIButton().then {
        $0.setImage(UIImage(systemName: "shuffle"), for: .normal)
    }
    
    private let curTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12.0)
        $0.text = "--:--"
    }
    
    private let endTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12.0)
        $0.text = "--:--"
    }
    
    private let bottomButtonStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 8.0
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    private var timer: Timer?
    
    init(reactor: MusicPlayReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
       
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
        [
            replyButton,
            backwardButton,
            playButton,
            forwardButton,
            shuffleButton
        ].forEach {
            bottomButtonStackView.addArrangedSubview($0)
        }
        
        [
            titleLabel,
            singerLabel,
            titleImageView,
            lyricsTableView,
            progressBar,
            bottomButtonStackView,
            curTimeLabel,
            endTimeLabel
        ].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16.0)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(72.0)
        }
        
        singerLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            make.leading.trailing.equalTo(titleLabel)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(singerLabel.snp.bottom).offset(16.0)
            make.bottom.equalTo(lyricsTableView.snp.top).offset(-16.0)
        }
        titleImageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        lyricsTableView.snp.makeConstraints { make in
            make.height.equalTo(100.0)
            make.leading.trailing.equalToSuperview().inset(30.0)
        }
        
        progressBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10.0)
            make.top.equalTo(lyricsTableView.snp.bottom).offset(20.0)
        }
        
        curTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(progressBar)
            make.top.equalTo(progressBar.snp.bottom).offset(3.0)
        }
        
        endTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(progressBar)
            make.top.equalTo(curTimeLabel)
        }
        
        bottomButtonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10.0)
            make.top.equalTo(curTimeLabel.snp.bottom).offset(8.0)
            make.bottom.equalToSuperview().inset(60.0)
        }
    }
    
    func bind(reactor: MusicPlayReactor) {
        
        //Action
        
        //viewDidLoad Action
        reactor.action.onNext(.refresh)
        
        playButton.rx.tap
            .map {
                [weak self] in
                return self?.audioPlayer?.isPlaying ?? false ? Reactor.Action.stop : Reactor.Action.play
            }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        rx.methodInvoked(#selector(updateTime))
            .map{
                [weak self] _ in
                Reactor.Action.playTime(time: self?.audioPlayer?.currentTime ?? TimeInterval.nan)
            }
            .debug()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //State
        reactor.state.map {  $0.music }
        .distinctUntilChanged({
            $0.file == $1.file
        })
        .debug()
        .bind(onNext: bindMusicPlayScene(_:))
        .disposed(by: disposeBag)
        
        reactor.state.map{ $0.lyrics }
        .debug()
        .bind(to: lyricsTableView.rx.items(cellIdentifier: LyricCell.identifier, cellType: LyricCell.self)) { index, lyric, cell in
            cell.update(with: lyric.lyric)
        }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isPlayed }
        .debug()
        .distinctUntilChanged()
        .bind(onNext: changeStateAudioPlayer(_:))
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.lyricIndex }
        .skip(1)
        .distinctUntilChanged()
        .bind(onNext: scrollTableView(_:))
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.curTime }
        .distinctUntilChanged()
        .debug()
        .bind(to: curTimeLabel.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.progress }
        .distinctUntilChanged()
        .debug()
        .bind(to: progressBar.rx.value)
        .disposed(by: disposeBag)
    }
}

private extension MusicPlayViewController {
    func bindMusicPlayScene(_ music: Music) {
        titleLabel.text = music.title
        singerLabel.text = music.singer
        titleImageView.kf.setImage(
            with: URL(string: music.image) ?? URL(string: "")
        )
        titleImageView.kf.indicatorType = .activity
        progressBar.maximumValue = Float(music.duration)
        let data = try? Data(contentsOf: URL(string: music.file) ?? URL(fileURLWithPath: "") )
        audioPlayer = try? AVAudioPlayer(data: data ?? Data())
        
        
        
    }
    
    func changeStateAudioPlayer(_ isPlayed: Bool) {
        if isPlayed {
            audioPlayer?.play()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            audioPlayer?.pause()
            print("test!!!")
            timer?.invalidate()
            timer = nil
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func updateTime() { }
    
    func scrollTableView(_ index: Int) {
        lyricsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
    }
}
