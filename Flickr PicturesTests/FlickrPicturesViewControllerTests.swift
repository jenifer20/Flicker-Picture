//
//  Flickr PicturesViewControllerTests.swift
//  Flickr PicturesTests
//
//  Created by jenifer_s on 27/01/23.
//

import XCTest
@testable import Flickr_Pictures

class Flickr_PicturesViewControllerTests: XCTestCase {
    
    var sut : ViewController!
    override func setUp() {
        super.setUp()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyBoard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSearchBar() {
        sut.searchBar.setValue("cat", forKey: "text")
        let searchText = sut.searchBar.text
        XCTAssertEqual(searchText, "cat")
    }
}
