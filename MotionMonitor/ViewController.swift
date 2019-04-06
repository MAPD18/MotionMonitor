//
//  ViewController.swift
//  MotionMonitor
//
//  Created by Aleixo Porpino Filho on 2019-04-04.
//  Copyright © 2019 Porpapps. All rights reserved.
//

import UIKit
import CoreMotion
import AVKit

class ViewController: UIViewController {
    @IBOutlet weak var score: UILabel!
    @IBOutlet var challengePitch: UILabel!
    @IBOutlet var currentPitch: UILabel!
    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var vwBackground: UIView!
    
    var challenge = 0
    var pitch = 0
    var count = 5
    var points = 0
    
    var timer:Timer?
    var backgroundTimer:Timer?
    var timeLeft = 1
    
    var soundPlayer : AVAudioPlayer?
    
    
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkGame), userInfo: nil, repeats: true)
        
        backgroundTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(checkBackground), userInfo: nil, repeats: true)
        
        self.nextChallenge()

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: queue) {
                (motion: CMDeviceMotion?, error: Error?) -> Void in
                if let motion = motion {
                    self.pitch = Int(self.rad2deg(motion.attitude.pitch))
                    let attitudeText = "Pitch: \(self.pitch)"
                    
                    DispatchQueue.main.async {
                        self.currentPitch.text = attitudeText
                    }
                }
            }
        }
    }
    
    @objc func checkGame() {
        if self.verifyPitches() {
            playSound(sound: "count_beep", "mp3")
            UIView.animate(withDuration: 0.5, animations: {
                self.countdown.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)},
                           completion: { (Bool) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.countdown.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: { (Bool) in
                            self.countdown.text = "\(self.count)"
                            self.count = self.count - 1
                    })
                })
            
        } else {
            self.count = 5
            countdown.text = ""
        }
        
        if self.count == 0 {
            self.nextChallenge()
            self.points = self.points + 1
            score.text = "Score: \(points)"
            playSound(sound: "score_beep", "wav")
        }
    }
    
    @objc func checkBackground() {
        let pitchDifference = abs(pitch - challenge)
        //0x27AE60, 0xffc305, 0x7a0406
        if pitchDifference <= 5 {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.vwBackground.backgroundColor = UIColor(rgb: 0x00CC00)
                self.changeLabelTextColors(.white)
            }, completion:nil)
        } else if pitchDifference <= 10 {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.vwBackground.backgroundColor = UIColor(rgb: 0x66CC00)
                self.changeLabelTextColors(.white)
            }, completion:nil)
        } else if pitchDifference <= 20 {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.vwBackground.backgroundColor = UIColor(rgb: 0xCCCC00)
                self.changeLabelTextColors(.white)
            }, completion:nil)
        } else if pitchDifference <= 30 {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.vwBackground.backgroundColor = UIColor(rgb: 0xCC6600)
                self.changeLabelTextColors(.white)
            }, completion:nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.vwBackground.backgroundColor = UIColor(rgb: 0xCC0000)
                self.changeLabelTextColors(.white)
            }, completion:nil)
        }
    }
    
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    func verifyPitches() -> Bool {
        return pitch == challenge
    }
    
    func nextChallenge() {
        challenge = Int.random(in: -89 ... 89)
        challengePitch.text = "Challenge \(challenge)"
    }
    
    func changeLabelTextColors(_ color: UIColor){
        score.textColor = color
        challengePitch.textColor = color
        currentPitch.textColor = color
        countdown.textColor = color
    }
    
    func playSound(sound name : String, _ ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else{
            return
        }
        soundPlayer = try? AVAudioPlayer(contentsOf: url)
        soundPlayer?.play()
    }

}

// RGB converter
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

