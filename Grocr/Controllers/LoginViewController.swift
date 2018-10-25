/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Firebase

class LoginViewController: UIViewController {
 
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad() {
        
        print(self.getCurrentDate());
        
        self.ref = Database.database().reference()
        
        super.viewDidLoad()
        

        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
    }

  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
//    performSegue(withIdentifier: loginToList, sender: nil)
    guard
        let email = textFieldLoginEmail.text,
        let password = textFieldLoginPassword.text,
        email.count > 0,
        password.count > 0
        else {
            return
    }
    
    Auth.auth().signIn(withEmail: email, password: password) { user, error in
        if let error = error, user == nil {
            let alert = UIAlertController(title: "Sign In Failed",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register",
                                  message: "Register",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
        // 1
        let userName = alert.textFields![0]
        let emailField = alert.textFields![1]
        let passwordField = alert.textFields![2]
        
        // 2
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
            if error == nil {
                // 3
                Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                   password: self.textFieldLoginPassword.text!)
                
                
                let userID = Auth.auth().currentUser?.uid
                
                print("-------")
                print(userID!)
                print("-------")
                
                self.ref.child("users").child(userID!).setValue([
                    "name": userName.text!,
                    "email": self.textFieldLoginEmail.text!,
                    "gender": "",
                    "telephone": "",
                    "status": "",
                    "facebook_id": "",
                    "image_url": "",
                    "created_at": self.getCurrentDate(),
                    "updated_at": self.getCurrentDate(),
                ])
                
            }
        }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    
    alert.addTextField { textName in
        textName.placeholder = "Enter your name"
    }
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
    
    func getCurrentDate() -> String  {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let str = formatter.string(from: Date())
        return str
    }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
}
