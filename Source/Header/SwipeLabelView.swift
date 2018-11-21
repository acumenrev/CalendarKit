import UIKit

public protocol SwipeLabelViewDelegate: class {
    func leftEvent()
    func rightEvent()
}

class SwipeLabelView: UIView {
    
    public weak var delegate: SwipeLabelViewDelegate?
    var date = Date() {
        willSet(newDate) {
            guard newDate != date
                else { return }
//            labels.last!.text = newDate.format(with: .medium)
            
            print("DayView = \(String(describing: labels.last?.text))")
            let shouldMoveForward = newDate.isLater(than: date)
            animate(forward: shouldMoveForward)
        }
    }
    
    var firstLabel: UILabel {
        return labels.first!
    }
    
    var secondLabel: UILabel {
        return labels.last!
    }
    
    var labels = [UILabel]()
    var btnLeft = UIView()
    var imgLeft = UIImageView()
    var lblLeft = UILabel()
    
    var btnRight = UIView()
    var imgRight = UIImageView()
    var lblRight = UILabel()
    var leftBtnEnabled = true
    var rightBtnEnabled = true
    
    var numWeekBack = 0
    
    var style = SwipeLabelStyle()
    
    init(date: Date) {
        self.date = date
        super.init(frame: .zero)
        configure()
//        labels.first!.text = date.format(with: .medium)
        
//        print("DayView = \(date.format(with: .full))")
    }
    
    func setTitle(_ title: String){
        firstLabel.text = title
        firstLabel.textColor = AppConstants.Colors.ChallengeDateTitle
        firstLabel.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Bold, size: 14)
        
        secondLabel.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Bold, size: 14)
        secondLabel.text = title
        secondLabel.textColor = AppConstants.Colors.ChallengeDateTitle
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
        for _ in 0...1 {
            let label = UILabel()
            label.textAlignment = .center
            labels.append(label)
            
            addSubview(label)
        }
     
        initButton()
        
        addSubview(btnLeft)
        addSubview(btnRight)
        updateStyle(style)
        
    }
    
    func disableLeft(isDisabled: Bool){
        leftBtnEnabled = !isDisabled
        if(isDisabled){
            lblLeft.textColor = AppConstants.Colors.ChallengeDateInActive
        }else{
            lblLeft.textColor = AppConstants.Colors.ChallengeDateCompleted
        }
        
        if(leftBtnEnabled){
            if let backIcon = style.backIcon{
                imgLeft.image = backIcon
            }
        }
        else{
            if let backIcon = style.backIconInactive{
                imgLeft.image = backIcon
            }
        }
        // change image
    }
    
    func disableRight(isDisabled: Bool){
        rightBtnEnabled = !isDisabled
        if(isDisabled){
            lblRight.textColor = AppConstants.Colors.ChallengeDateInActive
        }else{
            lblRight.textColor = AppConstants.Colors.ChallengeDateCompleted
        }
        
        if(rightBtnEnabled){
            if let nextIcon = style.nextIcon{
                imgRight.image = nextIcon
            }
        }
        else{
            if let nextIcon = style.nextIconInactive{
                imgRight.image = nextIcon
            }
        }
        // change image
    }
    
    func initButton(){
        imgLeft.frame = CGRect(x: 0, y: 10, width: 22, height: 24)
        lblLeft.frame = CGRect(x: 27, y: 12, width: 60, height: 20)
        lblLeft.text = "Limeade.Progress.LastWeek".localized()
        lblLeft.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Regular, size: 12)
        lblLeft.textAlignment = .left
        lblLeft.textColor = AppConstants.Colors.ChallengeDateCompleted
        
        btnLeft.frame = CGRect(x: 8, y: 0, width: 87, height: 44)
        btnLeft.addSubview(imgLeft)
        btnLeft.addSubview(lblLeft)
        
        imgRight.frame = CGRect(x: 62, y: 10, width: 22, height: 24)
        lblRight.frame = CGRect(x: 0, y: 12, width: 60, height: 20)
        lblRight.textAlignment = .right
        lblRight.text = "Limeade.Progress.NextWeek".localized()
        lblRight.font = AppConstants.Fonts.font(Style: AppConstants.Fonts.FontStyle.OpenSans_Regular, size: 12)
        lblRight.textColor = AppConstants.Colors.ChallengeDateCompleted
        
        let screenSize: CGRect = UIScreen.main.bounds

        btnRight.frame = CGRect(x: screenSize.width - 97, y: 0, width: 97, height: 44)
        btnRight.addSubview(imgRight)
        btnRight.addSubview(lblRight)
        
        
        let leftgesture = UITapGestureRecognizer.init(target: self, action: #selector(SwipeLabelView.leftClick(_:)))
        
        self.btnLeft.addGestureRecognizer(leftgesture)
        
        let rightgesture = UITapGestureRecognizer.init(target: self, action: #selector(SwipeLabelView.rightClick(_:)))
        
        self.btnRight.addGestureRecognizer(rightgesture)
        
        self.disableRight(isDisabled: true)
        
    }
    
    func leftClick(_ sender: Any?) {
        if(leftBtnEnabled){
            delegate?.leftEvent()
            
            // back 1 week
            
           updateAfterScroll(true)
        }
    }
    
    func rightClick(_ sender: Any?) {
        delegate?.rightEvent()
        updateAfterScroll(false)
        
    }
    
    func updateAfterScroll(_ isBack: Bool){
        if(!isBack){
            numWeekBack -= 1
            if(numWeekBack == 0){
                disableRight(isDisabled: true)
            }
            disableLeft(isDisabled: false)
        }else{
            numWeekBack += 1
            if(numWeekBack == 2){
                disableLeft(isDisabled: true)
            }
            disableRight(isDisabled: false)
        }
    }
    
    func updateStyle(_ newStyle: SwipeLabelStyle) {
        style = newStyle.copy() as! SwipeLabelStyle
        labels.forEach { label in
            label.textColor = style.textColor
        }
        
        if(numWeekBack == 0){
            disableLeft(isDisabled: false)
            disableRight(isDisabled: true)
        }
    }
    
    func animate(forward: Bool) {
        let multiplier: CGFloat = forward ? -1 : 1
        let shiftRatio: CGFloat = 30/375
        let screenWidth = bounds.width
        
//        secondLabel.alpha = 0
//        secondLabel.frame = bounds
//        secondLabel.frame.origin.x -= CGFloat(shiftRatio * screenWidth * 3) * multiplier
        
        UIView.animate(withDuration: 0.3, animations: { _ in
//            self.secondLabel.frame = self.bounds
//            self.firstLabel.frame.origin.x += CGFloat(shiftRatio * screenWidth) * multiplier
//            self.secondLabel.alpha = 1
//            self.firstLabel.alpha = 0
        }, completion: { _ in
            self.labels = self.labels.reversed()
        }) 
    }
    
    override func layoutSubviews() {
        for subview in subviews {
            
            
            if subview is UILabel {
                // obj is a String. Do something with str
                subview.frame = bounds
            }
            else {
                // obj is not a String
            }
        }
    }
}
