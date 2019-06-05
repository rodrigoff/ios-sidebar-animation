/// Copyright (c) 2019 Razeware LLC
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

class MenuDataSource: NSObject, UITableViewDataSource {
  private(set) var menuItems: [MenuItem] = []

  override init() {
    super.init()
    prepare()
  }

  func prepare() {
    guard let url = Bundle.main.url(forResource: "MenuItems", withExtension: "json") else {
      assertionFailure("project config error - unable to find MenuItems.json in bundle")
      return
    }
    do {
      let data = try Data(contentsOf: url)
      menuItems = try JSONDecoder().decode([MenuItem].self, from: data)
    } catch {
      assertionFailure("config error - unable to decode json file - \(error)")
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
    return menuItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell",
                                                   for: indexPath)
      as? MenuItemCell else {
      fatalError("expected to dequeue MenuItemCell - check storyboard")
    }
    let menuItem = menuItems[indexPath.row]
    cell.configureForMenuItem(menuItem)
    return cell
  }
}
