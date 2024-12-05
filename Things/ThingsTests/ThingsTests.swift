
import Testing
@testable import Things
import XCTest

class ThingsTests: XCTestCase {
    
    var validator: Validator!
    
    override func setUp(){
        super.setUp()
        validator = Validator()
    }


    func testEmailValidation() {
        let result = validator.validateEmail(email: "252808@student.pwr.edu.pl")
        XCTAssertTrue(result, "Validator should accept valid email")
        
        let result2 = validator.validateEmail(email: "252808@abc")
        XCTAssertFalse(result2, "Validator should not accept invalid email")

    }
    
    func testPasswordValidation() {
        let result = validator.validatePassword(password: "j0H4fur&6!/d9M#")
        XCTAssertTrue(result, "Validator should accept valid password")
        
        let result2 = validator.validatePassword(password: "1234")
        XCTAssertFalse(result2, "Validator should not accept invalid password")
    }

}

