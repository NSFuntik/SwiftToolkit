#if os(iOS) || os(tvOS)
import UIKit
import Foundation

class ScrollViewDecorator {
  weak var scrollView: UIScrollView?
  var directions: SimultaneouslyScrollViewDirection?

  init(scrollView: UIScrollView, directions: SimultaneouslyScrollViewDirection?) {
    self.scrollView = scrollView
    self.directions = directions
  }
}
#endif
