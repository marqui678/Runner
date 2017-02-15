//
//  FinishRunViewController.swift
//  Runner
//
//  Created by Thiago Heitling on 2017-02-08.
//  Copyright © 2017 Thiago Heitling. All rights reserved.
//

import UIKit

class FinishRunViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var newRun: Run?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Motivation().title
        label.textColor = UIColor(r: 32, g: 32, b: 32)
        label.textAlignment = .center
        label.font = UIFont(name: "DINAlternate-bold", size: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Motivation().phrase
        label.numberOfLines = 0
        label.textColor = UIColor(r: 32, g: 32, b: 32)
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Regular", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inputFeelingView: UIView = { // container view for emoji collecion view
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Emoji views
    lazy var emojiCollectionView: UICollectionView = {
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: self.cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false

        return collectionView
    }()
    
    var selectedEmoji = IndexPath()
    var afterRunFeelingOptions: [UIImage]?
    private let cellID = "cellID"
    
    // Stats views
    lazy var statsContainerView: CompleteRunStatsContainerView = {
        
        var containerView = CompleteRunStatsContainerView(frame: .zero)
        
        // Process distance
        let kmInt = self.newRun?.totalRunDistance != nil ? (self.newRun!.totalRunDistance / 1000 % 1000) : 0
        
        let dmTemp = self.newRun?.totalRunDistance != nil ? Double(self.newRun!.totalRunDistance) / 1000 : 0
        let dmInt = Int((Double(dmTemp) * 100)) % 100
        
        let km: String
        
        if kmInt < 10 {
            km = String(format: "%01d", kmInt)
        }
        else {
            km = String(format: "%02d", kmInt)
        }
        
        let dm = String(format: "%02d", dmInt)
        
        // Assign distance label
        containerView.distanceContainer[1].text = "\(km).\(dm)"
        
        // Process duration
        let hours: String
        let minutes: String
        let seconds: String
        
        if let duration = self.newRun?.duration {
            
            hours = String(format: "%02d", self.newRun!.duration / 3600)
            minutes = String(format: "%02d", self.newRun!.duration / 60 % 60)
            seconds = String(format: "%02d", self.newRun!.duration % 60)
        }
        else {
           
            hours = "00"
            minutes = "00"
            seconds = "00"
        }
        
        // Assing duration label
        containerView.durationContainer[1].text = "\(hours):\(minutes):\(seconds)"
        
        // Process pace
        let roundPaceString = self.newRun?.pace != nil ? "\(self.newRun!.pace)" : "00:00"
        let paceComponents = roundPaceString.components(separatedBy: ".")
        
        if paceComponents.count == 2 {
            
            let paceMinutesPart = paceComponents[0]
            var paceSecondsPart = paceComponents[1]
            
            if paceSecondsPart.characters.count == 1 {
                
                paceSecondsPart = paceSecondsPart.appending("0")
            }
            
            let paceSecondsPartInt = Int(paceSecondsPart) ?? 0
            
            let paceSecondsPartResult = paceSecondsPartInt * 60 / 100
            paceSecondsPart = String(format: "%02d", paceSecondsPartResult)
            
            // Assing pace label
            containerView.paceContainer[1].text = "\(paceMinutesPart):\(paceSecondsPart)"
        }
        else {
            // did not form the pace components array correctly
            containerView.paceContainer[1].text = "00:00"
        }
        
        // Process calories
        let calString = self.newRun?.calories != nil ? String(format: "%03d", self.newRun!.calories) : "000"
        
        // Assign calories label
        containerView.caloriesContainer[1].text = "\(calString)"
        
        return containerView
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SAVE", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.backgroundColor = UIColor(r: 0, g: 128, b: 255)
        button.layer.cornerRadius = 35
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        return button
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESUME", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        return button
    }()
    
    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = self.view.frame
        imageView.image = UIImage(named: "piste-athle2")
        imageView.alpha = 0.15
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white        
        view.addSubview(bgImageView)

        
        afterRunFeelingOptions = AfterRunFeeling.getPossibleFeelings()
        
        setupTitleView()
        setupSubtitleView()
        setupInputFeelingView()
        setupStatsContainerView()
        setupSaveButton()
        setupCancelButton()
        
        // debug
        if newRun != nil, let run = newRun {
            print(run)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupTitleView() {
        
        view.addSubview(titleLabel)
        
        // x, y, width, height constraints
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/9).isActive = true
    }
    
    func setupSubtitleView() {
        
        view.addSubview(subtitleLabel)
        
        // x, y, width, height constraints
        subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        subtitleLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/9).isActive = true
    }
    
    func setupInputFeelingView() {
        
        view.addSubview(inputFeelingView)
        
        // x, y, width, height constraints
        inputFeelingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputFeelingView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor).isActive = true
        inputFeelingView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputFeelingView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        inputFeelingView.addSubview(emojiCollectionView)

        // x, y, width, height constraints
        emojiCollectionView.centerXAnchor.constraint(equalTo: inputFeelingView.centerXAnchor).isActive = true
        emojiCollectionView.centerYAnchor.constraint(equalTo: inputFeelingView.centerYAnchor).isActive = true
        emojiCollectionView.widthAnchor.constraint(equalTo: inputFeelingView.widthAnchor).isActive = true
        emojiCollectionView.heightAnchor.constraint(equalTo: inputFeelingView.heightAnchor, constant: -20).isActive = true
    }
    
    func setupStatsContainerView() {
        
        view.addSubview(statsContainerView)
        
        // x, y, width, height constraints
        statsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statsContainerView.topAnchor.constraint(equalTo: inputFeelingView.bottomAnchor, constant: 10).isActive = true
        statsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        statsContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func setupSaveButton() {
        
        view.addSubview(saveButton)
        
        // x, y, width, height constraints
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    func setupCancelButton() {

        view.addSubview(cancelButton)
        
        // x, y, width, height constraints
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width/4).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func save() {
        
        print("saved run")
    }
    
    func cancel() {
        
        newRun = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: CollectionView Delegate and DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let count = afterRunFeelingOptions?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! EmojiCell
        cell.emoji = afterRunFeelingOptions?[indexPath.item]
        
        cell.emojiView.alpha = 0.3

        if indexPath == selectedEmoji {
            cell.emojiView.alpha = 1
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: emojiCollectionView.frame.height, height: emojiCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
            selectedEmoji = indexPath
            cell.emojiView.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: selectedEmoji) as? EmojiCell {
            cell.emojiView.alpha = 0.3
        }
    }
}

class EmojiCell: UICollectionViewCell {
    
    var emoji: UIImage? {
        didSet {
            if let image = emoji {
                emojiView.image = image
            }
        }
    }
    
    let emojiView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(emojiView)
        emojiView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
    }
    
}