//
//  ReferralPromoPopupViewController.swift
//  House
//
//  Created by Shmeel Ahmad on 19/06/2023.
//  Copyright (c) 2023 All rights reserved.
//

import UIKit
import Combine

public class ReferralPromoPopupViewController: UIViewController {
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var panDismissView: UIView!
    
    var data:[(String,String)]=[]
    
    var calculatingCell:InfoTableViewCell!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var mainView: UIView! {
        didSet {
            mainView.layer.cornerRadius = 16
            mainView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: -- Variables
//    private let input: PassthroughSubject<ReferralPromoPopupViewModel.Input, Never> = .init()
//    private let viewModel = ReferralPromoPopupViewModel()
//    private var cancellables = Set<AnyCancellable>()
    private var dismissViewTranslation = CGPoint(x: 0, y: 0)
    
//    weak var coordinator: ReferralPromoPopupCoordinator?
//    var popupData: ReferralPromoPopupObject?
    
    // MARK: -- View LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        calculatingCell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell") as? InfoTableViewCell
        panDismissView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        panDismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
//        bind(to: viewModel)
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    public static func get() -> ReferralPromoPopupViewController {
        return UIStoryboard(name: "ReferralPromoPopup", bundle: Bundle.module).instantiateViewController(withIdentifier: "ReferralPromoPopupViewController") as! ReferralPromoPopupViewController
    }
    // MARK: -- Binding
    
//    func bind(to viewModel: ReferralPromoPopupViewModel) {
//        let output = viewModel.transform(input: input.eraseToAnyPublisher())
//        output
//            .sink { [weak self] event in
//                guard let self = self else {return}
////                switch event {
////
////                }
//            }.store(in: &cancellables)
//    }
    
    @IBAction func crossBtnTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func setupUI() {
        data.append(("Apply to activate Referal code ipiscing elit Apply to activ ipiscing elit Apply to activ","Lorem ipsum dolor sit amet, consectetur adipiscing elit Apply to activate Referal code"))
//        data.append(("Apply to activate unlimited Buy 1 Get 1 offers","Lor"))
//        data.append(("Apply to activate unlimited Buy 1 Get 1 offers","Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do"))
//        data.append((" Apply to activate unlimited Buy 1 Get 1 offers","Lorem ipsum dolor sit amet, consectetur adipiscing it amet, consectetur adipiscing it amet, consectetur adipiscing elit, sed do"))
        descriptionText.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, seit amet, consectetur adipiscing it amet, consectetur adipiscing d do"
        titleLabel.text = "Appit amet, consectetur adipiscing lying referral/ promo code"
        tableView.dataSource = self
        tableView.delegate = self
        setTableViewHeight()
        let img = UIImage.init(named: "grayCross", in: Bundle.module, compatibleWith: nil)
        crossBtn.setImage(img, for: .normal)
    }
    
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            dismissViewTranslation = sender.translation(in: view)
            if dismissViewTranslation.y > 0 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.dismissViewTranslation.y)
                })
            }
        case .ended:
            if dismissViewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            }
            else {
                dismiss(animated: true) {
                    
                }
            }
        default:
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        dismiss(animated: true) {
            
        }
    }
}
extension ReferralPromoPopupViewController:UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell") as! InfoTableViewCell
        cell.titleLbl.text = data[indexPath.row].0
        cell.descLbl.text = data[indexPath.row].1
        return cell
    }
    
    
    func setTableViewHeight(){
        UIView.animate(withDuration: 0, animations: {
            self.tableView.layoutIfNeeded()
            }) { (complete) in
                var totalHeight: CGFloat = 0
                for d in self.data {
                    self.calculatingCell.titleLbl.text = d.0
                    self.calculatingCell.descLbl.text = d.1
                    self.calculatingCell.setNeedsLayout()
                    self.calculatingCell.layoutIfNeeded()
                    let targetSize = CGSize(width: self.tableView.frame.width, height: UIView.layoutFittingCompressedSize.height)
                    let size = self.calculatingCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                    
                    
                    totalHeight += size.height
                }
                
                self.tableViewHeight.constant = min(totalHeight,self.view.frame.size.height*0.7)
                print("\(min(totalHeight,self.view.frame.size.height*0.7))")
        }
    }
}
