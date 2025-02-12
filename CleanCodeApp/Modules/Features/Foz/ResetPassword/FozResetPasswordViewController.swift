import UIKit

class FozResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var recoverPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var viewSuccess: UIView!
    @IBOutlet weak var emailLabel: UILabel!

    var userEmail = ""
    var userPressedRecoveryButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }

// MARK: Recover Password
    @IBAction func recoverPasswordButton(_ sender: Any) {
        if !userPressedRecoveryButton {
            validateRecovering()
        }
        else {
            dismiss(animated: true)
        }

        view.endEditing(true)
    }

    private func validateRecovering(){
        guard validateForm() else {
            return
        }

        checkUserConnection()

        guard let email = emailTextfield.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty else {
            return
        }

        let parameters = ["email": email]
        performPasswordReset(with: parameters, email: email)
    }

    private func checkUserConnection (){
        guard ConnectivityManager.shared.isConnected else {
            Globals.showNoInternetCOnnection(controller: self)
            return
        }
    }

    private func performPasswordReset(with parameters: [String: String], email: String) {
        BadNetworkLayer.shared.resetPassword(self, parameters: parameters) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                success ? self.handlePasswordResetSuccess(withEmail: email) : self.handlePasswordResetFailure()
            }
        }
    }

    private func handlePasswordResetSuccess(withEmail email: String) {
        userPressedRecoveryButton = true
        emailTextfield.isHidden = true
        textLabel.isHidden = true
        viewSuccess.isHidden = false
        emailLabel.text = email
        recoverPasswordButton.setTitle("Voltar", for: .normal)
    }

    private func handlePasswordResetFailure() {
        let alertController = UIAlertController(
            title: "Ops…",
            message: "Algo de errado aconteceu. Tente novamente mais tarde.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }


    @IBAction func loginButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func helpButton(_ sender: Any) {
        let vc = FozContactUsViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func createAccountButton(_ sender: Any) {
        let newVc = FozCreateAccountViewController()
        newVc.modalPresentationStyle = .fullScreen
        present(newVc, animated: true)
    }

    func validateForm() -> Bool {
        let isEmailValid = EmailValidator.isValid(emailTextfield.text)

        if isEmailValid {
            return true
        }

        else {
            setupErrorMessage()
            return false
        }

    }

    private func setupErrorMessage(){
        emailTextfield.setErrorColor()
        textLabel.textColor = .red
        textLabel.text = "Verifique o e-mail informado"
    }
}

struct EmailValidator {
    static func isValid(_ email: String?) -> Bool {
        guard let email = email?.trimmingCharacters(in: .whitespaces), !email.isEmpty else { return false }
        return email.contains("@") && email.contains(".") && email.count > 5
    }
}

// MARK: - Comportamentos de layout
extension FozResetPasswordViewController {

    func setupView() {
        stylePrimaryButton(recoverPasswordButton)

        styleSecondaryButton(loginButton)

        styleSecondaryButton(helpButton)

        styleSecondaryButton(createAccountButton)

        emailTextfield.setDefaultColor()

        if !userEmail.isEmpty {
            emailTextfield.text = userEmail
            emailTextfield.isEnabled = false
        }
        validateButton()
    }

    //email
    @IBAction func emailBeginEditing(_ sender: Any) {
        emailTextfield.setEditingColor()
    }

    @IBAction func emailEditing(_ sender: Any) {
        emailTextfield.setEditingColor()
        validateButton()
    }

    @IBAction func emailEndEditing(_ sender: Any) {
        emailTextfield.setDefaultColor()
    }

    // MARK: Button Styler
    func stylePrimaryButton(_ button: UIButton){
        button.layer.cornerRadius = button.bounds.height / 2
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
    }

    func styleSecondaryButton(_ button: UIButton){
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.backgroundColor = .white
        button.setTitleColor(.blue, for: .normal)
    }

}

extension FozResetPasswordViewController {

    func validateButton() {
        if !emailTextfield.text!.isEmpty {
            enableCreateButton()
        } else {
            disableCreateButton()
        }
    }

    func disableCreateButton() {
        recoverPasswordButton.backgroundColor = .gray
        recoverPasswordButton.setTitleColor(.white, for: .normal)
        recoverPasswordButton.isEnabled = false
    }

    func enableCreateButton() {
        recoverPasswordButton.backgroundColor = .blue
        recoverPasswordButton.setTitleColor(.white, for: .normal)
        recoverPasswordButton.isEnabled = true
    }

}


