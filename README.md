# 서울 문화 행사
서울시 문화 행사 정보를 찾고, 후기를 공유하는 서비스
![투데이](https://github.com/user-attachments/assets/05dc4549-a57e-4d28-b77c-b2bb504a8c4d) | ![상세](https://github.com/user-attachments/assets/71170376-a80f-42be-b557-b5244724acd3) | ![후기](https://github.com/user-attachments/assets/54959447-bec8-434a-80fc-84f0bb41771a) | ![후기 상세](https://github.com/user-attachments/assets/48a84978-2d92-4b7e-8003-c443907f81dd)
---|---| ---| ---|


## 프로젝트 환경
- 개발 인원: iOS 1 서버 1  
- 개발 기간: 24.08.15 ~ 24.09.01 (3주)  
- 최소 버전: iOS 15.0

## 기술 스택
- 🎨 View Drawing - `UIKit`  
- 🏛️ Architecture - `MVVM`  
- ♻️ Asynchronous - `RxSwift`  
- 📡 Network - `Moya`  
- 🏞️ Image Loader - `Kingfisher`  
- 🍎 Apple Framework - `MapKit` `WebKit` `PhotosUI`  
- 🎸 기타 - `SnapKit` `Then` `Toast` `IQKeyboardManager`  

## 주요 기능
- **회원가입, 로그인** 기능
- 오늘의 문화 행사 **추천 및 검색**
- 홈페이지를 통한 **행사 예매**
- 후기 및 댓글 **조회 / 작성 / 수정 / 삭제** 기능
- 프로필, 관심 행사, 좋아요한 후기 관리

## 주요 기술

### MVVM 아키텍처
- Input&Output 패턴과 Data Binding을 적용하여 View와 Data 분리  
- ViewModelType 프로토콜을 사용하여 ViewModel 추상화  
  
### 네트워크  
- Moya의 TargetType 프로토콜을 채택한 Router 패턴  
- Enum의 연관값으로 Encodable을 채택한 모델을 직렬화하여 JSON 형태의 request body를 구성  
- 네트워크 통신 메서드의 리턴형을 Single<Result>타입으로 설정하여 스트림 유지 및 에러 핸들링  
- 상태코드에 따라 다른 메시지를 사용자에게 보여주기 위해 Error 프로토콜을 채택한 Enum 사용  
- 포스트 조회, 작성, 수정, 삭제 시에 다양한 HTTP 메서드(GET, POST, PUT, DELETE) 사용  
- 포스트 이미지 업로드를 위해 MultipartFormData 사용  
  
### 네트워크 모니터링  
- NWPathMonitor로 네트워크 연결 감지  
- 전역적인 감지를 위해 SceneDelegate의 willConnectTo 메서드에서 네트워크 감지를 시작하고, sceneDidDisconnect 메서드에서 네트워크 모니터링을 종료  
- 네트워크 에러뷰가 더해진 error window라는 별도의 윈도우를 만들어 기존 윈도우 위에 띄우는 방식을 선택  
- errorWindow의 window level을 statusBar로 설정하여 항상 기존 window보다 위에 보일 수 있도록 보장  
  
### 토큰 갱신  
- Request Interceptor의 adapt, retry를 활용한 토큰 갱신  
- 통신 시 짧은 만료 시간을 가진 엑세스 토큰을 사용하여 보안성 강화  
- 토큰 갱신 시에는 상대적으로 만료 시간이 긴 리프레시 토큰을 사용하여 사용성 증가  
  
### 페이지네이션  
- 페이지 기반 페이지네이션과 커서 기반 페이지네이션 사용  
- 서울시 문화 행사에 대한 공공 API에서는 페이지 기반 페이지네이션을 사용함  
- 서버 API에서는 데이터 변경 시 데이터의 누락, 중복이 발생하지 않는 커서 기반 페이지네이션을 사용함  
  
### 기타
- propertyWrapper - getter와 setter 코드 중복을 제거 하기 위해 UserDefaultsManager를 propertyWrapper로 구성  
- DispatchGroup - 포스트 작성 시 사용자가 PHPicker를 통해 선택한 사진들을 ViewModel에 전달할 때 빈 값이 전달되는 문제를 해결하기 위해 사용  
- PG 결제 구현 - 결제 요청 데이터를 구성하여 결제를 진행하고, 서버에 결제 검증을 진행

## 트러블 슈팅

### 네트워크 연결 상태를 감지하고, 연결이 끊겼을 때 에러뷰를 띄워주는 문제

모든 화면에 네트워크 통신이 있기 때문에 전역적인 처리가 필요
문제를 2가지로 나누어 해결하고자 함

- 네트워크 연결을 감지하는 문제
- 연결이 끊겼을 때 네트워크 에러뷰를 보여주고,  재연결시 네트워크 에러뷰를 제거하는 문제
 
1. 네트워크 연결 상태 감지하기

- BaseViewController에서 NWPathMonitor를 사용한 네트워크 모니터 객체를 만들어 상속 받아 사용
- 네트워크 모니터 객체의 개수가 BaseViewController를 상속받은 모든 ViewController의 개수만큼 생성되어 리소스가 낭비됨
- SceneDelegate의 willConnectTo 메서드에서 네트워크 감지를 시작하고, sceneDidDisconnect 메서드에서 네트워크 모니터링을 종료시켜줌으로써 해결

 2. 네트워크 에러뷰를 띄우고, 제거하기
 
- UIWindow의 bringSubviewToFront 메서드를 통해 에러뷰를 윈도우 최상단에 위치시켜 화면을 덮도록 함
네트워크 에러뷰를 제거할 때는 keyWindow의 최상단 뷰를 제거해주는 방식 사용
- 제거 시 네트워크 에러뷰가 최상단이 아닐 경우, 다른 뷰를 제거하게 될 가능성이 있음
- 네트워크 에러뷰가 더해진 errorWindow라는 별도의 윈도우를 만들어 기존 윈도우 위에 띄우는 방식을 선택
동일한 window level에서는 window의 정렬이 보장되지 않기 때문에, errorWindow의 window level을 statusBar로 설정하여 항상 메인 윈도우보다 위에 보일 수 있도록 보장함  
재연결 감지 시 errorWindow를 화면에서 제거하고 nil로 설정하여 리소스를 제거함
