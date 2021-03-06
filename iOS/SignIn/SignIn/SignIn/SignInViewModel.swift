//
//  SignInViewModel.swift
//  SignIn
//
//  Created by 김혜빈 on 2021/01/15.
//
import RxSwift
import RxCocoa
import NaverThirdPartyLogin

struct LoginModel {
    func requestLogin(_ email: String, _ password: String) -> Int {
        print("test - request login - email: \(email), pw: \(password)")
        return 200
    }
}

class SignInViewModel {
    let input = Input()
    let output = Output()
    let disposeBag = DisposeBag()
    lazy var loginModel = LoginModel()
    
    struct Input {
        let email = PublishSubject<String>()
        let password = PublishSubject<String>()
        let signInButton = PublishSubject<Void>()
    }
    
    struct Output {
        let enableSignInButton = PublishRelay<Bool>()
        let enableLogIn = PublishRelay<Bool>()
        let emailStatus = PublishRelay<Bool>()
        let passwordStatus = PublishRelay<Bool>()
    }
    
    init() {
        Observable.combineLatest(input.email, input.password)
            .map { [weak self] (email, password) in
                (self?.validateEmail(email) ?? false) && (self?.validatePassword(password) ?? false)
            }.bind(to: output.enableSignInButton)
            .disposed(by: disposeBag)

        input.email.map { [weak self] email in
            if email.isEmpty { return true }
            return self?.validateEmail(email) ?? false
        }.bind(to: output.emailStatus)
        .disposed(by: disposeBag)
        
        input.password.map { [weak self] pw in
            if pw.isEmpty { return true }
            return self?.validatePassword(pw) ?? false
        }.bind(to: output.passwordStatus)
        .disposed(by: disposeBag)
        
        input.signInButton.withLatestFrom(Observable.combineLatest(input.email, input.password))
            .map { [weak self] (email, password) in
                return (self?.loginModel.requestLogin(email, password) ?? 404) == 200
            }.bind(to: output.enableLogIn)
            .disposed(by: disposeBag)
    }
    
    func validateEmail(_ email: String) -> Bool {
        if email.isEmpty { return false }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func validatePassword(_ pw: String) -> Bool {
        if pw.isEmpty { return false }
        
        let pwRegex = "^.{8,16}$"
        let pwText = NSPredicate(format:"SELF MATCHES %@", pwRegex)
        return pwText.evaluate(with: pw)
    }
}
