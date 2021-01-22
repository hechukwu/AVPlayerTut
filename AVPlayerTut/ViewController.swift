import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var overallDurationLbl: UILabel!
    @IBOutlet weak var playBackSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    fileprivate let seekDuration: Float64 = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        playBackSlider.minimumValue = 0
        playBackSlider.addTarget(self, action: #selector(ViewController.playbackSliderValueChanged(_:)), for: .valueChanged)
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        overallDurationLbl.text = self.stringFromTimeInterval(interval: seconds)
        
        let currentDuration : CMTime = playerItem.currentTime()
        let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
        currentTimeLbl.text = self.stringFromTimeInterval(interval: currentSeconds)
        
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.tintColor = UIColor(red: 0.93, green: 0.74, blue: 0.00, alpha: 1.00)
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.playBackSlider.value = Float ( time );
                
                self.currentTimeLbl.text = self.stringFromTimeInterval(interval: time)
            }
            
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                print("IsBuffering")
                self.playBtn.isHidden = true
                //                        self.loadingView.isHidden = false
            } else {
                //stop the activity indicator
                print("Buffering completed")
                self.playBtn.isHidden = false
                //                        self.loadingView.isHidden = true
            }
            
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if player == nil { return }
        let playerCurrenTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        player?.play()
    }
    
    @IBAction func forwardBtnTapped(_ sender: Any) {
        if player == nil { return }
        if let duration  = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
    
    @IBAction func playBtnTapped(_ sender: Any) {
        if player?.rate == 0
        {
            player!.play()
            self.playBtn.isHidden = true
            //            self.loadingView.isHidden = false
//            playBtn.setImage(UIImage(named: "ic_orchadio_pause"), for: UIControl.State.normal)
        } else {
            player!.pause()
//            playBtn.setImage(UIImage(named: "ic_orchadio_play"), for: UIControl.State.normal)
        }
    }
    @IBAction func playBackSliderValueChanged(_ sender: Any) {
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
//        playBtn.setImage(UIImage(named: "ic_orchadio_play"), for: UIControl.State.normal)
    }
}
