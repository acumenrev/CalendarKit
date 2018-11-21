import UIKit
import DateToolsSwift

class DateLabel: UILabel {
    
    var fontSize: CGFloat = 14
    let dayFormat = "EEEE"
    
    var selectedLine: UIView?
    var date: Date! {
        didSet {
            text = getWeekDayName(date)
            updateState()
        }
    }
    
    func getWeekDayName(_ date: Date) -> String{
        
        let dayofWeek = AppUtils.getDayOfWeek(date: date)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = dayFormat
        dayTimePeriodFormatter.locale = .posix
        let timeString = dayTimePeriodFormatter.string(from: date)
        
       
        var offsetBy = 1
        // sunday and thursday
        if(dayofWeek == 1 || dayofWeek == 3 || dayofWeek == 7){
            offsetBy = 2
        }
        
        if(dayofWeek == 5){
            offsetBy = 3
        }
        
        if(selected){
            offsetBy = 3
            
            if(dayofWeek == 5){
                offsetBy = 5
            }
        }
        
        return timeString.substring(to: timeString.index(timeString.startIndex, offsetBy: offsetBy))
    }

    
    var selected: Bool = false {
        didSet {
            animate()
        }
    }
    
    var completted: Bool = false
    var active: Bool = true
    
    var style = DaySelectorStyle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        isUserInteractionEnabled = true
        textAlignment = .center
        clipsToBounds = true
        self.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Bold, size: 14)
    }
    
    func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        updateState()
    }
    
    func updateState() {
        backgroundColor = style.inactiveBackgroundColor
        
        if(completted){
            self.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Bold, size: 14)
            textColor =  AppConstants.Colors.ChallengeDateCompleted
            
        }
        else if selected {
            self.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Bold, size: 14)
            textColor = style.activeTextColor
            
        } else if active{
            self.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Regular, size: 14)
            textColor = AppConstants.Colors.ChallengeDateActive
            
        }else{
            self.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Regular, size: 14)
            textColor = AppConstants.Colors.ChallengeDateInActive
        }
        
        showSelectedLine()
    }
    
    func showSelectedLine(){
        
        selectedLine?.isHidden = !selected
        
    }
    
    func initLine(width: Int, height: Int){
        if (selectedLine == nil){
            selectedLine = UIView.init(frame: CGRect.init(x: 0, y: height - 3, width: width, height: 3))
            selectedLine?.backgroundColor = AppConstants.Colors.ChallengeDateCompleted
            selectedLine?.isHidden = !selected
            self.addSubview(selectedLine!)
        }
    }

    
    func animate(){
        UIView.transition(with: self, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { _ in
                            self.text = self.getWeekDayName(self.date)
                            
                            self.updateState()
                            
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = 2 //bounds.height / 2
    }
    override func tintColorDidChange() {
        updateState()
    }
    
    
}
