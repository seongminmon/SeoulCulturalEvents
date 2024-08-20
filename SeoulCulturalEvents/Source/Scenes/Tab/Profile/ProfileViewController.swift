//
//  ProfileViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class ProfileViewController: BaseViewController {
    
    private let profileContainerView = UIView()
    private let profileImageView = ProfileImageView()
    private let nicknameLabel = UILabel().then {
        $0.font = .bold16
    }
    private let followerButton = UIButton().then {
        $0.titleLabel?.textAlignment = .left
        $0.titleLabel?.font = .bold16
        $0.setTitleColor(.black, for: .normal)
    }
    private let followingButton = UIButton().then {
        $0.titleLabel?.font = .bold16
        $0.titleLabel?.textAlignment = .left
        $0.setTitleColor(.black, for: .normal)
    }
    private let editButton = UIButton().then {
        $0.setImage(.chevron, for: .normal)
        $0.tintColor = .black
    }
    private let separator = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    private let tableView = UITableView().then {
        $0.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        $0.rowHeight = 44
        $0.separatorStyle = .singleLine
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.separatorInsetReference = .fromCellEdges
        $0.separatorColor = .systemGray3
    }
    
    private let viewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
        let withdrawAction = PublishSubject<Void>()
        let newProfile = PublishSubject<ProfileModel>()
        
        let input = ProfileViewModel.Input(
            viewDidLoad: Observable.just(()),
            editButtonTap: editButton.rx.tap,
            followerButtonTap: followerButton.rx.tap,
            followingButtonTap: followingButton.rx.tap,
            cellTap: tableView.rx.itemSelected, 
            withdrawAction: withdrawAction,
            newProfile: newProfile
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SettingSection> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
            cell.configureCell(title: item)
            return cell
        } titleForHeaderInSection: { [weak self] dataSource, row in
            return self?.viewModel.sectionData[row].header
        }
        
        output.list
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.profile
            .bind(with: self) { owner, profile in
                let parameter = (profile.profileImage ?? "").getKFParameter()
                owner.profileImageView.kf.setImage(
                    with: parameter.url,
                    placeholder: UIImage.person,
                    options: [.requestModifier(parameter.modifier)]
                )
                owner.nicknameLabel.text = profile.nick
                owner.followerButton.setTitle("팔로워 \(profile.followers.count)", for: .normal)
                owner.followingButton.setTitle("팔로잉 \(profile.following.count)", for: .normal)
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
        
        output.withdrawTap
            .bind(with: self) { owner, _ in
                owner.showWithdrawAlert(title: "탈퇴하기", message: "정말 탈퇴하시겠습니까?", actionTitle: "탈퇴하기") { _ in
                    withdrawAction.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        output.withdrawActionSuccess
            .bind(with: self) { owner, _ in
                SceneDelegate.changeWindow(SignInViewController())
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "프로필"
    }

    override func setLayout() {
        [profileImageView, nicknameLabel, followerButton, followingButton, editButton].forEach {
            profileContainerView.addSubview($0)
        }
        
        [profileContainerView, tableView, separator].forEach {
            view.addSubview($0)
        }
        
        profileContainerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(150)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.size.equalTo(100)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).inset(16)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalTo(editButton.snp.leading)
            make.height.equalTo(30)
        }
        
        followerButton.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView).inset(16)
            make.leading.equalTo(nicknameLabel)
            make.height.equalTo(30)
        }
        
        followingButton.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView).inset(16)
            make.leading.equalTo(followerButton.snp.trailing).offset(8)
            make.height.equalTo(30)
        }
        
        editButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(40)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(profileContainerView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(0.3)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separator)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
