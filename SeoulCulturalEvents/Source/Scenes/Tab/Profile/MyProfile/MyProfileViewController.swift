//
//  MyProfileViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import WebKit
import iamport_ios
import Kingfisher
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class MyProfileViewController: BaseViewController {
    
    private let searchButton = UIBarButtonItem().then {
        $0.image = .searchUser
    }
    private let profileView = ProfileView()
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .settingLayout()
    ).then {
        $0.register(
            ProfileCollectionViewCell.self,
            forCellWithReuseIdentifier: ProfileCollectionViewCell.identifier
        )
        $0.register(
            SettingCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SettingCollectionHeaderView.identifier
        )
    }
    
    private let viewModel = MyProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
        let signOutAction = PublishSubject<Void>()
        let withdrawAction = PublishSubject<Void>()
        let newProfile = PublishSubject<ProfileModel>()
        let paymentsValidationTrigger = PublishSubject<String>()
        
        let input = MyProfileViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            editButtonTap: profileView.additionalButton.rx.tap,
            followerButtonTap: profileView.followerButton.rx.tap,
            followingButtonTap: profileView.followingButton.rx.tap,
            cellTap: collectionView.rx.itemSelected,
            signOutAction: signOutAction,
            withdrawAction: withdrawAction,
            newProfile: newProfile,
            searchButtonTap: searchButton.rx.tap,
            paymentsValidationTrigger: paymentsValidationTrigger
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<SettingSection> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileCollectionViewCell.identifier,
                for: indexPath
            ) as? ProfileCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(item)
            return cell
            
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SettingCollectionHeaderView.identifier,
                for: indexPath
            ) as? SettingCollectionHeaderView else {
                return UICollectionReusableView()
            }
            let section = dataSource.sectionModels[indexPath.section]
            header.configureHeader(section.model)
            return header
        }
        
        output.sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.profile
            .bind(with: self) { owner, profile in
                owner.profileView.configureView(profile)
            }
            .disposed(by: disposeBag)
        
        output.editButtonTap
            .withLatestFrom(output.profile)
            .bind(with: self) { owner, value in
                let vm = EditProfileViewModel(profile: value)
                let vc = EditProfileViewController(viewModel: vm)
                vc.sendData = { value in
                    newProfile.onNext(value)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.cellTap
            .bind(with: self) { owner, value in
                let (indexPath, userID) = value
                
                switch indexPath.section {
                // 보관함
                case 0:
                    switch indexPath.item {
                    case 0:
                        // 관심 행사
                        let vm = LikeEventViewModel(userID: userID)
                        let vc = LikeEventViewController(viewModel: vm)
                        owner.navigationController?.pushViewController(vc, animated: true)
                    case 1:
                        // 관심 후기
                        let vm = LikePostViewModel(userID: userID)
                        let vc = LikePostViewController(viewModel: vm)
                        owner.navigationController?.pushViewController(vc, animated: true)
                    case 2:
                        // 내 후기
                        let vm = UserPostViewModel(userID: userID)
                        let vc = UserPostViewController(viewModel: vm)
                        owner.navigationController?.pushViewController(vc, animated: true)
                    default:
                        break
                    }
                // 설정
                case 1:
                    switch indexPath.item {
                    case 0:
                        // 로그아웃
                        owner.showSignOutAlert() { _ in
                            signOutAction.onNext(())
                        }
                    case 1:
                        // 탈퇴하기
                        owner.showWithdrawAlert() { _ in
                            withdrawAction.onNext(())
                        }
                    case 2:
                        // MARK: - 결제 기능
                        // 후원하기 (100원)
                        
                        // 1. 결제 요청 데이터 구성
                        print("1. 결제 요청 데이터 구성")
                        let payment = IamportPayment(
                            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                            merchant_uid: "ios_\(APIKey.lslpKey)_\(Int(Date().timeIntervalSince1970))",
                            amount: "100"
                        ).then {
                            $0.pay_method = PayMethod.card.rawValue
                            $0.name = "후원하기"
                            $0.buyer_name = "김성민"
                            $0.app_scheme = "lslp"
                        }
                        
                        // 2. 포트원 SDK에 결제 요청
                        print("2. 포트원 SDK에 결제 요청")
                        Iamport.shared.payment(
                            navController: owner.navigationController ?? UINavigationController(),
                            userCode: PortOne.userCode,
                            payment: payment
                        ) { iamportResponse in
                            print("포트원 결제 정보")
                            print(String(describing: iamportResponse))
                            if let success = iamportResponse?.success, success {
                                print("결제 성공!")
                                owner.showToast("결제 성공!")
                                let impUID = iamportResponse?.imp_uid ?? ""
                                paymentsValidationTrigger.onNext(impUID)
                            } else {
                                print("결제 실패!")
                                owner.showToast("결제 실패!")
                            }
                        }
                        
                    default:
                        break
                    }
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        output.searchButtonTap
            .subscribe(with: self) { owner, following in
                let vm = SearchUserViewModel(following: following.map { $0.nick } )
                let vc = SearchUserViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)

        output.changeSignInWindow
            .bind(with: self) { owner, _ in
                SceneDelegate.changeWindow(SignInViewController())
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .subscribe(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "프로필"
        navigationItem.rightBarButtonItem = searchButton
    }
    
    override func setLayout() {
        [profileView, collectionView].forEach {
            view.addSubview($0)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(260)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
