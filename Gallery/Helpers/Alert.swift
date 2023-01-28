import UIKit

final class AlertService {
        
    init() {}
    
    func showErrorAlert(on vc: UIViewController, error: Error, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Не удалось войти в систему", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in handler() }))
        vc.present(alert, animated: true)
    }
    
    func showLogoutAlert(on vc: UIViewController, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in handler() }))
        vc.present(alert, animated: true)
    }

}

