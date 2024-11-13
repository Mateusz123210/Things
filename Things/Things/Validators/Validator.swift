import SwiftUI
import Foundation

struct Validator{
    let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
    
    let specialCharacterRegex = "[!@#$%^&*()_+\\-\\=\\[\\]{};':\"\\\\|,.<>\\/\\?]+"
    
    func validatePassword(password: String) -> Bool {
        
        if (password.count < 8) {
            return false
        }
        
        var containsDigit = false
        var containsUpperLetter = false
        var containsLowerLetter = false
        
        for character in password {
            if (character.isNumber) {
                containsDigit = true
            }
            if (character.isUppercase){
                containsUpperLetter = true
            }
            if (character.isLowercase) {
                containsLowerLetter = true
            }
        }
        if(containsDigit == false || containsUpperLetter == false || containsLowerLetter == false){
            return false
        }
        
        let regex = try! NSRegularExpression(pattern: specialCharacterRegex, options: [])
        let range = NSRange(location: 0, length: password.utf16.count)
        if regex.firstMatch(in: password, options: [], range: range) == nil {
            return false
        }
        
        return true
        
    }
    
    func validateEmail(email: String) -> Bool{
        return emailTest.evaluate(with: email)
    }
}
