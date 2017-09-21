//
//  LoginViewController.swift
//  Firebase_RTC
//
//  Created by Anshul Saraf on 11/09/17.
//  Copyright © 2017 InfoBeans Technologies Limited. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    //  MARK:-  IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton_SuperViewVerticalSpacingConstraint: NSLayoutConstraint!
    
    //  MARK:-  Properties
    fileprivate let loginButton_SuperViewVerticalSpace: CGFloat = 20
    
    //  MARK:-  Instance Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //  add keyboard state observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //  MARK:-  Keyboard Observers
    func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo {
            self.processKeyboardAppearance(keyboardUp: true, userInfo: userInfo)
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if let userInfo = notification.userInfo {
            self.processKeyboardAppearance(keyboardUp: false, userInfo: userInfo)
        }
    }
    
    //  MARK:-  Private Methods
    fileprivate func processKeyboardAppearance(keyboardUp: Bool, userInfo: [AnyHashable: Any]) {
        if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber, let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            let keyboardFrame = keyboardEndFrame.cgRectValue
            let keyboardAnimationCurve = UIViewAnimationCurve(rawValue: animationCurve.intValue) ?? UIViewAnimationCurve.easeInOut
            let keyboardAnimationDuration: TimeInterval = animationDuration.doubleValue
            
            let spacingConstant = self.loginButton_SuperViewVerticalSpace + (keyboardUp ? keyboardFrame.size.height : 0)
            self.loginButton_SuperViewVerticalSpacingConstraint.constant = spacingConstant
            
            // Animate up or down
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(keyboardAnimationDuration)
            UIView.setAnimationCurve(keyboardAnimationCurve)
            
            self.view.layoutIfNeeded()
            
            UIView.commitAnimations()
        }
    }
    
    //  MARK:-  IBActions
    @IBAction func loginDidTap() {
        let bypassLogin = false
        if bypassLogin {
            self.performSegue(withIdentifier: loginSuccessSegueID, sender: nil)
            return
        }
        
        self.view.endEditing(true)
        
        //  email id cannot be blank
        guard let email = self.emailTextField.text, !email.isEmpty else {
            let errorMessage = AlertMessages.enterEmailIDMessage
            Utility.showAlertWith(title: errorMessage, message: nil)
            debugPrint(errorMessage)
            
            return
        }
        
        //  email id cannot be invalid
        guard Utility.isValidEmail(email) else {
            let errorMessage = AlertMessages.enterEmailIDValidFormatMessage
            Utility.showAlertWith(title: errorMessage, message: nil)
            debugPrint(errorMessage)
            
            return
        }
        
        //  password cannot be blank
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            let errorMessage = AlertMessages.enterPasswordMessage
            Utility.showAlertWith(title: errorMessage, message: nil)
            debugPrint(errorMessage)
            
            return
        }
        
        //  reached here? data must be in valid format; lets try to connect
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = HUDMessages.connectingMessage
        hud.backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
        hud.backgroundView.color = UIColor.black.withAlphaComponent(0.5)
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let loginError = error as NSError? {
                hud.hide(animated: true)
                
                var errorMessage = ""
                
                if loginError.code == FIRAuthErrorCode.errorCodeUserNotFound.rawValue {
                    errorMessage = FirebaseMessages.userNotFoundMessage
                }
                else if loginError.code == FIRAuthErrorCode.errorCodeWrongPassword.rawValue {
                    errorMessage = FirebaseMessages.wrongPasswordMessage
                }
                else {
                    errorMessage = loginError.localizedDescription
                }
                Utility.showAlertWith(title: errorMessage, message: nil)
                debugPrint(errorMessage)
            }
            else {
                let loadTimeInterval: TimeInterval = 3
                
                hud.mode = MBProgressHUDMode.customView
                
                // Set an image view with a checkmark.
                let image = UIImage(named: "Checkmark")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                hud.customView = UIImageView(image: image)
                
                hud.label.text = HUDMessages.loginSuccessMessage
                
                hud.hide(animated: true, afterDelay: loadTimeInterval)
                
                //  perform segue on main queue
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + loadTimeInterval, execute: {
                    AppDataManager.sharedInstance.userEmailID = email
                    self.performSegue(withIdentifier: loginSuccessSegueID, sender: nil)
                })
            }
        })
    }
    
    //  MARK:-  UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.loginDidTap()
        }
        
        return true
    }
}

