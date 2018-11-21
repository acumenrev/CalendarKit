import UIKit

protocol PagingScrollViewDelegate: class {
  func updateViewAtIndex(_ index: Int)
  func scrollviewDidScrollToViewAtIndex(_ index: Int)
}

protocol ReusableView: class {
  func prepareForReuse()
}

class PagingScrollView<T: UIView>: UIScrollView, UIScrollViewDelegate where T: ReusableView {

  var reusableViews = [T]()
  weak var viewDelegate: PagingScrollViewDelegate?
    
    var isScrollByManual = false
    var scrollEvent: ((_ isNext:Bool) ->())?
    var numBackWeek = 0
  var previousPage: CGFloat = 1
  var currentScrollViewPage: CGFloat {
    get {
      let width = bounds.width
      let centerOffsetX = contentOffset.x + width / 2
      return centerOffsetX / width - 0.5
    }
  }

  var accumulator: CGFloat = 0
  var currentIndex: CGFloat {
    return round(currentScrollViewPage) + accumulator
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    isPagingEnabled = true
    isDirectionalLockEnabled = true
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    delegate = self
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    realignViews()
  }

  func recenterIfNecessary() {
    if reusableViews.isEmpty { return }
    let contentWidth = contentSize.width
    let centerOffsetX = (contentWidth - bounds.size.width) / 2

    let distanceFromCenter = contentOffset.x - centerOffsetX

    if fabs(distanceFromCenter) > (contentWidth / 3) {
      recenter()
    }
  }

  func recenter() {
    let contentWidth = contentSize.width
    let centerOffsetX = (contentWidth - bounds.size.width) / 2
    let distanceFromCenter = contentOffset.x - centerOffsetX

    if distanceFromCenter > 0 {
      reusableViews.shift(1)
      accumulator += 1
      reusableViews.last!.prepareForReuse()
      viewDelegate?.updateViewAtIndex(reusableViews.endIndex - 1)
    } else if distanceFromCenter < 0 {
      reusableViews.shift(-1)
      accumulator -= 1
      reusableViews.first!.prepareForReuse()
      viewDelegate?.updateViewAtIndex(0)
    }
    contentOffset = CGPoint(x: centerOffsetX, y: contentOffset.y)
  }

  func realignViews() {
    for (index, subview) in reusableViews.enumerated() {
      subview.frame.origin.x = bounds.width * CGFloat(index)
      subview.frame.size = bounds.size
    }
  }

  func scrollForward() {
    isScrollByManual = true
    setContentOffset(CGPoint(x: contentOffset.x + bounds.width, y: 0), animated: true)
    
  }

  func scrollBackward() {
    isScrollByManual = true
    setContentOffset(CGPoint(x: contentOffset.x - bounds.width, y: 0), animated: true)
  }

  func checkForPageChange() {
    
    if currentIndex != previousPage {
        
        if(numBackWeek == 0){
            if(currentIndex > previousPage){
                setContentOffset(CGPoint(x: contentOffset.x - bounds.width, y: 0), animated: true)
                return
            }
            
        }
        
        if(numBackWeek == 2){
            if(currentIndex < previousPage){
                setContentOffset(CGPoint(x: contentOffset.x + bounds.width, y: 0), animated: true)
                
                return
            }
            

        }

        
        if(!isScrollByManual){
            if(currentIndex < previousPage){
                scrollEvent?(false)
            }else{
                scrollEvent?(true)
            }
        }
        isScrollByManual = false
        
        
        if(currentIndex < previousPage){
            numBackWeek += 1
        }else{
            numBackWeek -= 1
        }
        
        
        
      viewDelegate?.scrollviewDidScrollToViewAtIndex(Int(currentScrollViewPage))
      previousPage = currentIndex
        
        
    }
    recenter()
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if decelerate {return}
    checkForPageChange()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    checkForPageChange()
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    checkForPageChange()
  }
}
