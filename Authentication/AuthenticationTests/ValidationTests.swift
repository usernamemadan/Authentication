//
//  AuthenticationTests.swift
//  AuthenticationTests
//
//  Created by Madan AR on 20/10/21.
//

import XCTest

class ValidationTests: XCTestCase {

    func test_email_with_empty_string_should_return_false() throws {
        let result = Validation.shared.isValidEmail(email: "")
        XCTAssertFalse(result)
    }

    func test_email_with_wrong_email_format_should_return_false() throws {
        let result = Validation.shared.isValidEmail(email: "user@go")
        XCTAssertFalse(result)
    }
    func test_email_with_valid_email_should_return_true() throws {
        let result = Validation.shared.isValidEmail(email: "newuser@gmail.com")
        XCTAssertTrue(result)
    }
    
    func test_password_with_empty_string_should_return_false() throws {
        let result = Validation.shared.isValidPassword(password: "")
        XCTAssertFalse(result)
    }
    
    func test_password_with_invalid_password_should_return_false() throws {
        let result = Validation.shared.isValidPassword(password: "password77")
        XCTAssertFalse(result)
    }

    func test_password_with_valid_password_should_return_true() throws {
        let result = Validation.shared.isValidPassword(password: "Auser456")
        XCTAssertTrue(result)
    }
    
}
