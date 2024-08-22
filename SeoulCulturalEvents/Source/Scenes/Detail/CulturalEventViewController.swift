//
//  CulturalEventViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class CulturalEventViewController: BaseViewController {
    
    private let likeButton = UIBarButtonItem().then {
        $0.image = .emptyHeart
        $0.tintColor = .systemRed
    }
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    private let contentView = UIView()
    private let posterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.font = .bold15
        $0.numberOfLines = 0
    }
    private let codeNameLabel = UILabel().then {
        $0.font = .regular14
        $0.numberOfLines = 0
    }
    private let dateLabel = UILabel().then {
        $0.font = .regular14
        $0.numberOfLines = 0
    }
    private let placeLabel = UILabel().then {
        $0.font = .regular14
        $0.numberOfLines = 0
    }
    private let priceLabel = UILabel().then {
        $0.font = .regular14
        $0.numberOfLines = 0
    }
    private let useTargetLabel = UILabel().then {
        $0.font = .regular14
        $0.numberOfLines = 0
    }
    private let mapView = MKMapView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.isScrollEnabled = false
    }
    private let showMapButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "지도 보기"
        config.image = .arrow
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.buttonSize = .mini
        
        config.baseBackgroundColor = .darkGray
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        $0.configuration = config
        
        $0.layer.cornerRadius = 10
    }
    private let reserveButton = PointButton(title: "예매하기")
    
    init(viewModel: CulturalEventViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: CulturalEventViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = CulturalEventViewModel.Input(
            viewDidLoad: Observable.just(()),
            likeButtonTap: likeButton.rx.tap,
            showMapButtonTap: showMapButton.rx.tap,
            reserveButtonTap: reserveButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.data
            .bind(with: self) { owner, value in
                owner.configureView(value)
            }
            .disposed(by: disposeBag)
        
        output.likeFlag
            .map { $0 ? UIImage.fillHeart : UIImage.emptyHeart }
            .bind(to: likeButton.rx.image)
            .disposed(by: disposeBag)
        
        output.networkFailure
            .bind(with: self) { owner, value in
                owner.makeNetworkFailureToast(value)
            }
            .disposed(by: disposeBag)
        
        output.showMapButtonTap
            .bind(with: self) { owner, value in
                let coordinate =  CLLocationCoordinate2D(latitude: value.lat, longitude: value.lon)
                let vc = MapViewController(coordinate: coordinate)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.reserveLink
            .bind(with: self) { owner, link in
                let vm = ReserveViewModel(link: link)
                let vc = ReserveViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.rightBarButtonItem = likeButton
    }
    
    override func setLayout() {
        [
            posterImageView,
            titleLabel,
            codeNameLabel,
            dateLabel,
            placeLabel,
            priceLabel,
            useTargetLabel,
            mapView,
            showMapButton
        ].forEach { contentView.addSubview($0) }
        scrollView.addSubview(contentView)
        [scrollView, reserveButton].forEach {
            view.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.width.verticalEdges.equalToSuperview()
        }
        posterImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        codeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(codeNameLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        placeLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(placeLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        useTargetLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        mapView.snp.makeConstraints { make in
            make.top.equalTo(useTargetLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(150)
            make.bottom.equalToSuperview().inset(80)
        }
        showMapButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(mapView).inset(8)
        }
        reserveButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func configureView(_ value: CulturalEvent) {
        navigationItem.title = value.title
        let url = URL(string: value.mainImage)
        posterImageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                // 이미지의 크기에 맞게 높이 조정
                let aspectRatio = value.image.size.height / value.image.size.width
                posterImageView.snp.makeConstraints { make in
                    make.height.equalTo(self.posterImageView.snp.width).multipliedBy(aspectRatio)
                }
            case .failure(let error):
                print("KF Error: \(error)")
            }
        }
        titleLabel.text = value.title
        codeNameLabel.text = value.codeName
        dateLabel.text = "\(value.startDateString) ~ \(value.endDateString)"
        placeLabel.text = "\(value.place) | \(value.guName)"
        priceLabel.text = value.price.isEmpty ? value.isFree : value.price
        useTargetLabel.text = value.useTarget
        
        let coordinate =  CLLocationCoordinate2D(latitude: value.lat, longitude: value.lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}
