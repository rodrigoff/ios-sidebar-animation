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

extension UIView {
  func embedInsideSafeArea(_ subview: UIView) {
    addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    subview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
    subview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
    subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    subview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
}

class RootViewController: UIViewController {
  let menuWidth: CGFloat = 80.0
  lazy var threshold = menuWidth/2.0

  var hamburgerView: HamburgerView?
  var menuContainer = UIView(frame: .zero)
  var detailContainer = UIView(frame: .zero)

  var menuViewController: MenuViewController?
  var detailViewController: DetailViewController?

  lazy var scroller: UIScrollView = {
    let scroller = UIScrollView(frame: .zero)
    scroller.isPagingEnabled = true
    scroller.delaysContentTouches = false
    scroller.bounces = false
    scroller.showsHorizontalScrollIndicator = false
    scroller.delegate = self
    return scroller
  }()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "rw-dark")
    view.embedInsideSafeArea(scroller)

    installMenuContainer()
    installDetailContainer()

    menuViewController = installFromStoryboard("MenuViewController", into: menuContainer) as? MenuViewController
    detailViewController = installFromStoryboard("DetailViewController", into: detailContainer) as? DetailViewController

    menuViewController?.delegate = self

    if let detailViewController = detailViewController {
      installBurger(in: detailViewController)
    }
    hamburgerView?.setFractionOpen(1.0)
  }

  private func installMenuContainer() {
    scroller.addSubview(menuContainer)
    menuContainer.translatesAutoresizingMaskIntoConstraints = false
    menuContainer.backgroundColor = .orange

    menuContainer.leadingAnchor.constraint(equalTo: scroller.leadingAnchor).isActive = true
    menuContainer.topAnchor.constraint(equalTo: scroller.topAnchor).isActive = true
    menuContainer.bottomAnchor.constraint(equalTo: scroller.bottomAnchor).isActive = true

    menuContainer.widthAnchor.constraint(equalToConstant: menuWidth).isActive = true
    menuContainer.heightAnchor.constraint(equalTo: scroller.heightAnchor).isActive = true
  }

  private func installDetailContainer() {
    scroller.addSubview(detailContainer)
    detailContainer.translatesAutoresizingMaskIntoConstraints = false
    detailContainer.backgroundColor = .red

    detailContainer.trailingAnchor.constraint(equalTo: scroller.trailingAnchor).isActive = true
    detailContainer.topAnchor.constraint(equalTo: scroller.topAnchor).isActive = true
    detailContainer.bottomAnchor.constraint(equalTo: scroller.bottomAnchor).isActive = true

    detailContainer.leadingAnchor.constraint(equalTo: menuContainer.trailingAnchor).isActive = true
    detailContainer.widthAnchor.constraint(equalTo: scroller.widthAnchor).isActive = true
  }
}

extension RootViewController {
  func installInNavigationController(_ rootController: UIViewController)
    -> UINavigationController {
      let nav = UINavigationController(rootViewController: rootController)

      nav.navigationBar.barTintColor = UIColor(named: "rw-dark")
      nav.navigationBar.tintColor = UIColor(named: "rw-light")
      nav.navigationBar.isTranslucent = false
      nav.navigationBar.clipsToBounds = true

      addChild(nav)

      return nav
  }

  func installFromStoryboard(_ identifier: String, into container: UIView) -> UIViewController {
    guard let viewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
      fatalError("broken storyboard expected \(identifier) to be available")
    }

    let nav = installInNavigationController(viewController)
    container.embedInsideSafeArea(nav.view)
    return viewController
  }

  func installBurger(in viewController: UIViewController) {
    let action = #selector(burgerTapped(_:))
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
    let burger = HamburgerView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    burger.addGestureRecognizer(tapGestureRecognizer)
    viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: burger)
    hamburgerView = burger
  }

  @objc func burgerTapped(_ sender: Any) {
    toggleMenu()
  }

  func transformForFraction(_ fraction: CGFloat, ofWidth width: CGFloat) -> CATransform3D {
      var identity = CATransform3DIdentity
      identity.m34 = -1.0 / 1000.0

      let angle = -fraction * .pi / 2.0
      let xOffset = width / 2.0 + width * fraction / 4.0

      let rotateTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0)
      let translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0)
      return CATransform3DConcat(rotateTransform, translateTransform)
  }

  func calculateMenuDisplayFraction(_ scrollview: UIScrollView) -> CGFloat {
    let fraction = scrollview.contentOffset.x / menuWidth
    let clamped = Swift.min(Swift.max(0, fraction), 1.0)
    return clamped
  }

  func updateViewVisibility(_ container: UIView, fraction: CGFloat) {
    container.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
    container.layer.transform = transformForFraction(fraction, ofWidth: menuWidth)
    container.alpha = 1.0 - fraction
  }
}

extension RootViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    scrollView.isPagingEnabled = offset.x < threshold

    let fraction = calculateMenuDisplayFraction(scrollView)
    updateViewVisibility(menuContainer, fraction: fraction)
    hamburgerView?.setFractionOpen(1.0 - fraction)
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let offset = scrollView.contentOffset
    if offset.x > threshold {
      hideMenu()
    }
  }

  func moveMenu(nextPosition: CGFloat) {
    let nextOffset = CGPoint(x: nextPosition, y: 0)
    scroller.setContentOffset(nextOffset, animated: true)
  }

  func hideMenu() {
    moveMenu(nextPosition: menuWidth)
  }

  func showMenu() {
    moveMenu(nextPosition: 0)
  }

  func toggleMenu() {
    let menuIsHidden = scroller.contentOffset.x > threshold
    if menuIsHidden {
      showMenu()
    } else {
      hideMenu()
    }
  }
}

extension RootViewController: MenuDelegate {
  func didSelectMenuItem(_ item: MenuItem) {
    detailViewController?.menuItem = item
  }
}
