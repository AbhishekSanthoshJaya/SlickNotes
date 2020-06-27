//
//  AudioPlayerView.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-27.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit

class AudioPlayerView: UIView{
    
    var isPlaying: Bool = false
    
    
    var playBtn : UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "play")
        btn.tintColor = .white
        btn.setImage(image, for: .normal)
//        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 70)
        btn.addTarget(self, action: #selector(playPauseClicked(sender:)), for: .touchDown)
        btn.translatesAutoresizingMaskIntoConstraints = false

        return btn
    }()
    
    
    var audioSlider : UISlider  = {
        let slider = UISlider()
        slider.thumbTintColor = .red
        let image = UIImage(named: "circle")
        slider.setThumbImage(image, for: .normal)
        slider.setThumbImage(image, for: .focused)

        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        return slider
    }()
    
    var audioLengthLabel: UILabel = {
        let label =  UILabel()
        label.text = "00:00"
        label.textColor = .white
        return label
    }()
    
    var vStackView: UIStackView  = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()
    
    var seekHStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.axis = .horizontal
        return view
    }()
    
    var controlsHStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.axis = .horizontal
        return view
    }()
    
    
    @objc func playPauseClicked(sender: UIButton!){
        if isPlaying{
            // pause the player
            // pause the slider
            
            
            
            // update ui
            UIView.animate(withDuration: 0.4) {
                let image = UIImage(named: "play")
                self.playBtn.setImage(image, for: .normal)
            }
        }
        else{
            
            // play the player
            // play the slider
            
            // update ui
            
            UIView.animate(withDuration: 0.4) {
                   let image = UIImage(named: "pause")
                   self.playBtn.setImage(image, for: .normal)
            }
        }
        
        // flip state
        isPlaying = !isPlaying
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        // set the anchor
        backgroundColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                 self.heightAnchor.constraint(equalToConstant: 80),
                 self.widthAnchor.constraint(equalToConstant: 300),
             
            ]
        )
        
        addSubview(vStackView)
        
        NSLayoutConstraint.activate([
        
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor
            ),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor
            )
       
        ])
        
        
        
        vStackView.addArrangedSubview(seekHStack)
        vStackView.addArrangedSubview(controlsHStack)

        
        
        // setUp internal views
        
        seekHStack.addArrangedSubview(audioSlider)
        seekHStack.addArrangedSubview(audioLengthLabel)
        
        
        // add controls
        controlsHStack.addArrangedSubview(playBtn)
        
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
