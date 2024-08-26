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
    
    private let profileView = ProfileView()
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
            viewWillAppear: rx.viewWillAppear,
            editButtonTap: profileView.editButton.rx.tap,
            followerButtonTap: profileView.followerButton.rx.tap,
            followingButtonTap: profileView.followingButton.rx.tap,
            cellTap: tableView.rx.itemSelected,
            withdrawAction: withdrawAction,
            newProfile: newProfile
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SettingSection> { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
                return UITableViewCell()
            }
            cell.configureCell(title: item)
            return cell
        } titleForHeaderInSection: { [weak self] dataSource, row in
            let header = self?.viewModel.sections[row].model ?? ""
            return header
        }
        
        output.settinglist
            .bind(to: tableView.rx.items(dataSource: dataSource))
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
                let userStorage = UserStorage.allCases[value.0.row]
                switch userStorage {
                case .likeCulturalEvent:
                    print("관심 행사 탭")
                    let vm = LikeEventViewModel(userID: value.1)
                    let vc = LikeEventViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .likePost:
                    print("관심 후기 탭")
                case .myPost:
                    print("내 후기 탭")
                }
            }
            .disposed(by: disposeBag)
        
//        output.withdrawTap
//            .bind(with: self) { owner, _ in
//                owner.showWithdrawAlert(
//                    title: "탈퇴하기",
//                    message: "모든 정보가 사라집니다. 정말 탈퇴하시겠습니까?",
//                    actionTitle: "탈퇴하기") { _ in
//                    withdrawAction.onNext(())
//                }
//            }
//            .disposed(by: disposeBag)
//        
//        output.withdrawActionSuccess
//            .bind(with: self) { owner, _ in
//                SceneDelegate.changeWindow(SignInViewController())
//            }
//            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "프로필"
    }

    override func setLayout() {
        [profileView, tableView, separator].forEach {
            view.addSubview($0)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(150)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
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
