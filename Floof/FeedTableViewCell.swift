//
//  FeedTableViewCell.swift
//  Floof
//
//  Created by Tommy Mallow on 4/10/18.
//  Copyright © 2018 Marshmallow. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    
    //This will be called everytime a new value is set on the videoplayer item
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Setup avplayer while the cell is created
        self.setupMoviePlayer()
    }
    
    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        //Different variations for different devices
        if UIScreen.main.bounds.width == 375 {
            avPlayerLayer?.frame = CGRect.init(x: -5, y: 45, width: screenWidth+15, height: screenHeight - 160)
            avPlayerLayer?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.05).cgColor
            print("first")
        }else if UIScreen.main.bounds.width == 320 {
            avPlayerLayer?.frame = CGRect.init(x: -5, y: 45, width: screenWidth+15, height: screenHeight - 160)
            avPlayerLayer?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.05).cgColor
            print("second")
        }else{
            avPlayerLayer?.frame = CGRect.init(x: -5, y: 45, width: screenWidth+15, height: screenHeight - 160)
            avPlayerLayer?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.05).cgColor
            print("third")
        }
        self.backgroundColor = .clear
        self.layer.insertSublayer(avPlayerLayer!, at: 0)

        
        // This notification is fired when the video ends
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
}


