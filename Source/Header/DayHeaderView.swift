import UIKit
import DateToolsSwift

public protocol DayHeaderViewDelegate: class {
    func dateHeaderDateChanged(_ newDate: Date)
}

public class DayHeaderView: UIView, SwipeLabelViewDelegate {
    
    public weak var delegate: DayHeaderViewDelegate?
    
    public var daysInWeek = 7
    
    public var calendar = Calendar.autoupdatingCurrent
    
    var style = DayHeaderStyle()
    
    var currentWeekdayIndex = -1
    var currentDate = Date().dateOnly()
    var activeView:CommonDaySelector?
    
    var daySymbolsViewHeight: CGFloat = 0
    var pagingScrollViewHeight: CGFloat = 44
    var swipeLabelViewHeight: CGFloat = 44
    
    lazy var daySymbolsView: DaySymbolsView = DaySymbolsView(daysInWeek: self.daysInWeek)
    let pagingScrollView = PagingScrollView<CommonDaySelector>()
    lazy var swipeLabelView: SwipeLabelView = SwipeLabelView(date: Date().dateOnly())
    var reselectAfterScrolling = true
    
    public init(selectedDate: Date) {
        super.init(frame: CGRect.zero)
        self.currentDate = selectedDate
        self.backgroundColor = AppConstants.Colors.ChallengeDateBackground
        configure()
        configurePages(selectedDate)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configurePages()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        configurePages()
    }
    public func leftEvent() {
        pagingScrollView.scrollBackward()
        print("leftEvent")
    }
    public func rightEvent() {
        pagingScrollView.scrollForward()
        print("rightEvent")
        
    }
    
    func setTitle(_ title:String){
        swipeLabelView.setTitle(title)
    }
    
    func configure() {
        [daySymbolsView, pagingScrollView, swipeLabelView].forEach {
            addSubview($0)
        }
        swipeLabelView.delegate = self;
        print("DayView = \(swipeLabelView)")
        pagingScrollView.viewDelegate = self
        self.backgroundColor = AppConstants.Colors.ChallengeDateBackground
        
        pagingScrollView.scrollEvent = { [weak self] (isNext) in
            self?.swipeLabelView.updateAfterScroll(!isNext)
        }
    }
    
    func configurePages(_ selectedDate: Date = Date()) {
        for i in -1...1 {
            let daySelector = CommonDaySelector(daysInWeek: daysInWeek)
            let date = selectedDate.add(TimeChunk(seconds: 0,
                                                  minutes: 0,
                                                  hours: 0,
                                                  days: 0,
                                                  weeks: i,
                                                  months: 0,
                                                  years: 0))
            daySelector.startDate = beginningOfWeek(date)
            pagingScrollView.reusableViews.append(daySelector)
            pagingScrollView.addSubview(daySelector)
            daySelector.delegate = self
        }
        let centerDaySelector = pagingScrollView.reusableViews[1]
        centerDaySelector.selectedDate = selectedDate
        currentWeekdayIndex = centerDaySelector.selectedIndex
    }
    
    func beginningOfWeek(_ date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month, .day,
                                                  .weekday, .timeZone], from: date)
        // monday is first
        let firstWeekday = 2
        let offset = components.weekday! - firstWeekday
        components.day = components.day! - offset
        
        return calendar.date(from: components)!
    }
    
    public func selectDate(_ selectedDate: Date) {
        
        let selectedDate = selectedDate.dateOnly()
        let centerDaySelector = pagingScrollView.reusableViews[1]
        let startDate = centerDaySelector.startDate.dateOnly()
        
        let daysFrom = selectedDate.days(from: startDate, calendar: calendar)
        
        if daysFrom < 0 {
//            pagingScrollView.scrollBackward()
            currentWeekdayIndex = abs(daysInWeek + daysFrom % daysInWeek)
        } else if daysFrom > daysInWeek - 1 {
//            pagingScrollView.scrollForward()
            currentWeekdayIndex = daysFrom % daysInWeek
        } else {
            centerDaySelector.selectedDate = selectedDate
        }
        
        swipeLabelView.date = selectedDate
        currentDate = selectedDate
    }
    
    public func updateStyle(_ newStyle: DayHeaderStyle) {
        style = newStyle.copy() as! DayHeaderStyle
        daySymbolsView.updateStyle(style.daySymbols)
        swipeLabelView.updateStyle(style.swipeLabel)
        pagingScrollView.reusableViews.forEach { daySelector in
            daySelector.updateStyle(style.daySelector)
        }
        backgroundColor = style.backgroundColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        pagingScrollView.contentOffset = CGPoint(x: bounds.width, y: 10)
        pagingScrollView.contentSize = CGSize(width: bounds.size.width * CGFloat(pagingScrollView.reusableViews.count), height: 0)
        //thay o day -phuocp
        
        // hai adjust layout
        swipeLabelView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: swipeLabelViewHeight)
        daySymbolsView.alignAndFillWidth(align: .underCentered, relativeTo: swipeLabelView, padding: 0, height: daySymbolsViewHeight)
        pagingScrollView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 0, otherSize: pagingScrollViewHeight)
        
        //swipeLabelView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: swipeLabelViewHeight)
        //pagingScrollView.alignAndFillWidth(align: .underCentered, relativeTo: swipeLabelView, padding: 0, height: pagingScrollViewHeight)
        
        //daySymbolsView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 10, otherSize: daySymbolsViewHeight)
    }
}

extension DayHeaderView: DaySelectorDelegate {
    func dateSelectorDidSelectDate(_ date: Date, index: Int) {
        currentDate = date
        currentWeekdayIndex = index
        swipeLabelView.date = date
        delegate?.dateHeaderDateChanged(date)
    }
}

extension DayHeaderView: PagingScrollViewDelegate {
    
    func updateViewAtIndex(_ index: Int) {
        let viewToUpdate = pagingScrollView.reusableViews[index]
        let weeksToAdd = index > 1 ? 3 : -3
        viewToUpdate.startDate = viewToUpdate.startDate.add(TimeChunk(seconds: 0,
                                                                      minutes: 0,
                                                                      hours: 0,
                                                                      days: 0,
                                                                      weeks: weeksToAdd,
                                                                      months: 0,
                                                                      years: 0))
    }
    
    func scrollviewDidScrollToViewAtIndex(_ index: Int) {
        activeView = pagingScrollView.reusableViews[index]
        if(reselectAfterScrolling){
            currentWeekdayIndex = 0
            activeView?.selectedIndex = currentWeekdayIndex
            swipeLabelView.date = (activeView?.selectedDate)!
            delegate?.dateHeaderDateChanged((activeView?.selectedDate)!)
        }else{
            activeView?.prepareForReuse()
            if((activeView?.dateLabels[currentWeekdayIndex].date.dateOnly().equals(currentDate.dateOnly())) ?? false ){
                swipeLabelView.date = currentDate
                activeView?.selectedIndex = currentWeekdayIndex
                delegate?.dateHeaderDateChanged(currentDate)
            }else{
                delegate?.dateHeaderDateChanged((activeView?.dateLabels[0].date)!)
            }
        }
    }
    
    
}
