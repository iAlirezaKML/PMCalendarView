//
//  PMCalendarView.swift
//  PMCalendarView
//
//  Created by Peymayesh on 10/5/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import UIKit

let NUMBER_OF_DAYS_IN_WEEK = 7

let MAX_NUMBER_OF_DAYS_IN_WEEK = 7                              // Should not be changed
let MIN_NUMBER_OF_DAYS_IN_WEEK = MAX_NUMBER_OF_DAYS_IN_WEEK     // Should not be changed
let MAX_NUMBER_OF_ROWS_PER_MONTH = 6                            // Should not be changed
let MIN_NUMBER_OF_ROWS_PER_MONTH = 1                            // Should not be changed

let FIRST_DAY_INDEX = 0
let OFFSET_CALC = 2
let NUMBER_OF_DAYS_INDEX = 1
let DATE_SELECTED_INDEX = 2
let TOTAL_DAYS_IN_MONTH = 3
let DATE_BOUNDRY = 4

public struct PMCalendarDateState {
    public enum DateOwner: Int {
        case ThisMonth = 0,
		PreviousMonthWithinBoundary,
		PreviousMonthOutsideBoundary,
		FollowingMonthWithinBoundary,
		FollowingMonthOutsideBoundary
    }
    public let isSelected: Bool
    public let text: String
    public let dateBelongsTo: DateOwner
}

public enum DaysOfWeek: Int {
    case Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7
	var specialValue: Int {
		switch self {
		case Sunday:	return 7
		case Monday:	return 6
		case Tuesday:	return 5
		case Wednesday: return 4
		case Thursday:	return 10
		case Friday:	return 9
		case Saturday:	return 8
		}
	}
}

protocol PMCalendarLayoutDelegate: class {
    func numberOfRows() -> Int
    func numberOfColumns() -> Int
    func numberOfsectionsPermonth() -> Int
    func numberOfSections() -> Int
}

public protocol PMCalendarViewDataSource {
	var calendarViewStartDate: NSDate { get }
	var calendarViewEndDate: NSDate { get }
	var calendarViewCalendar: NSCalendar { get }
	var calendarViewLocale: NSLocale { get }	
}

public protocol PMCalendarViewDelegate {
	func calendarView(calendarView: PMCalendarView, canSelectDate date: NSDate, state: PMCalendarDateState) -> Bool
	func calendarView(calendarView: PMCalendarView, canDeselectDate date: NSDate, state: PMCalendarDateState) -> Bool
	func calendarView(calendarView: PMCalendarView, didSelectDate date: NSDate, state: PMCalendarDateState)
	func calendarView(calendarView: PMCalendarView, didDeselectDate date: NSDate, state: PMCalendarDateState)
	func calendarView(calendarView: PMCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?)
}

public extension PMCalendarViewDelegate {
	func calendarView(calendarView: PMCalendarView, canSelectDate date: NSDate, state: PMCalendarDateState) -> Bool {
		return date.isLessThanDate(calendarView.endDateCache) && date.isGreaterThanDate(calendarView.startDateCache)
	}
	func calendarView(calendarView: PMCalendarView, canDeselectDate date: NSDate, state: PMCalendarDateState) -> Bool { return true }
	func calendarView(calendarView: PMCalendarView, didSelectDate date: NSDate, state: PMCalendarDateState) {}
	func calendarView(calendarView: PMCalendarView, didDeselectDate date: NSDate, state: PMCalendarDateState) {}
	func calendarView(calendarView: PMCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?) {}
}

public protocol PMCalendarCellDataSource {
	func calendarCell(canSelectDate date: NSDate, state: PMCalendarDateState) -> Bool
	func calendarCell(canDeselectDate date: NSDate, state: PMCalendarDateState) -> Bool
	func calendarCell(didSelectDate date: NSDate, state: PMCalendarDateState)
	func calendarCell(didDeselectDate date: NSDate, state: PMCalendarDateState)
	func calendarCell(isAboutToDisplayDate date: NSDate, state: PMCalendarDateState)
}

protocol PMCalendarLayoutProtocol: class {
	var itemSize: CGSize { get set }
	var headerReferenceSize: CGSize { get set }
	var pathForFocusItem: NSIndexPath { get set }
	
	func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint
}

class PMCalendarBaseFlowLayout: UICollectionViewLayout, PMCalendarLayoutProtocol {
	var itemSize = CGSizeZero
	var headerReferenceSize = CGSizeZero
	var pathForFocusItem = NSIndexPath(forItem: 0, inSection: 0)
	
	override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
		let layoutAttrs = layoutAttributesForItemAtIndexPath(pathForFocusItem)
		guard collectionView != nil && layoutAttrs != nil else { return CGPointZero }
		return CGPointMake(layoutAttrs!.frame.origin.x - collectionView!.contentInset.left, layoutAttrs!.frame.origin.y - collectionView!.contentInset.top)
	}
}

class PMCalendarVerticalFlowLayout: UICollectionViewFlowLayout, PMCalendarLayoutProtocol {
	var pathForFocusItem = NSIndexPath(forItem: 0, inSection: 0)
	
	override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
		let layoutAttrs = layoutAttributesForItemAtIndexPath(pathForFocusItem)
		guard collectionView != nil && layoutAttrs != nil else { return CGPointZero }
		return CGPointMake(layoutAttrs!.frame.origin.x - collectionView!.contentInset.left, layoutAttrs!.frame.origin.y - collectionView!.contentInset.top)
	}
}

class PMCalendarHorizontalFlowLayout: PMCalendarBaseFlowLayout {
	var numberOfRows = 0
	var numberOfColumns = 0
	var minimumInteritemSpacing: CGFloat = 0
	var minimumLineSpacing: CGFloat = 0
	var scrollDirection = UICollectionViewScrollDirection.Horizontal
	
	weak var delegate: PMCalendarLayoutDelegate?
	
	init(withDelegate delegate: PMCalendarLayoutDelegate) {
		super.init()
		self.delegate = delegate
		minimumInteritemSpacing = 0
		minimumLineSpacing = 0
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func prepareLayout() {
		numberOfRows = delegate?.numberOfRows() ?? 0
		numberOfColumns = delegate?.numberOfColumns() ?? 0
	}
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard delegate != nil else { return nil }
		
		let requestedWidth = rect.width
		let requestedColumns = Int(requestedWidth / itemSize.width) + 2
		var startColumn = Int(rect.origin.x / itemSize.width)
		var endColumn = startColumn + requestedColumns
		
		let maxColumns = delegate!.numberOfSections() * delegate!.numberOfsectionsPermonth() * 7
		if endColumn >= maxColumns { endColumn = maxColumns }
		if startColumn >= endColumn { startColumn = endColumn - 1 }
		if startColumn < 0 { startColumn = 0 }
		
		var attributes = [UICollectionViewLayoutAttributes]()
		
		for index in 0..<numberOfRows {
			for columnNumber in startColumn..<endColumn {
				let section = columnNumber / numberOfColumns
				let sectionIndex = (columnNumber % numberOfColumns) + (index * numberOfColumns)
				let indexPath = NSIndexPath(forItem: sectionIndex, inSection: section)
				if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
					attributes.append(attribute)
				}
			}
		}
		return attributes
	}
	
	override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
		let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
		applyLayoutAttributes(attr)
		return attr
	}
	
	func applyLayoutAttributes(attributes: UICollectionViewLayoutAttributes) {
		guard attributes.representedElementKind == nil && collectionView != nil else { return }
		
		let stride = collectionView!.frame.size.width
		let offset = CGFloat(attributes.indexPath.section) * stride
		var xCellOffset: CGFloat = CGFloat(attributes.indexPath.item % 7) * itemSize.width
		let yCellOffset: CGFloat = CGFloat(attributes.indexPath.item / 7) * itemSize.height
		xCellOffset += offset
		attributes.frame = CGRectMake(xCellOffset, yCellOffset, itemSize.width, itemSize.height)
	}
	
	override func collectionViewContentSize() -> CGSize {
		var size = super.collectionViewContentSize()
		guard collectionView != nil && delegate != nil else { return size }
		size.width = collectionView!.bounds.size.width * CGFloat(delegate!.numberOfSections()) * CGFloat(delegate!.numberOfsectionsPermonth())
		return size
	}
}


public class PMCalendarCell: UICollectionViewCell, PMCalendarCellDataSource {
	static var reuseID: String { return NSStringFromClass(self) }
	
	public func calendarCell(canSelectDate date: NSDate, state: PMCalendarDateState) -> Bool { return true }
	public func calendarCell(canDeselectDate date: NSDate, state: PMCalendarDateState) -> Bool { return true }
	public func calendarCell(didSelectDate date: NSDate, state: PMCalendarDateState) {}
	public func calendarCell(didDeselectDate date: NSDate, state: PMCalendarDateState) {}
	public func calendarCell(isAboutToDisplayDate date: NSDate, state: PMCalendarDateState) {}
}


public class PMCalendarView: UIView {
	public var bufferTop: CGFloat    = 0
    public var bufferBottom: CGFloat = 0
	
	public var animationsEnabled = true
	public var firstDayOfWeek = DaysOfWeek.Sunday {
		didSet { weekdaysView?.reloadText() }
	}
	public var rightToLeftLayout = false {
		didSet { calendarView.transform = CGAffineTransformMakeScale(rightToLeftLayout ? -1 : 1, 1) }
	}
	
	public var direction = UICollectionViewScrollDirection.Horizontal {
        didSet {
            let layout = generateNewLayout()
            calendarView.collectionViewLayout = layout
            configureChangeOfRows()
        }
    }

	public var allowsMultipleSelection: Bool = false {
        didSet { calendarView.allowsMultipleSelection = allowsMultipleSelection }
    }

	

	public var numberOfRowsPerMonth = 6 {
        didSet {
            if numberOfRowsPerMonth == 4 || numberOfRowsPerMonth == 5 || numberOfRowsPerMonth > 6 || numberOfRowsPerMonth < 0 { numberOfRowsPerMonth = 6 }
            if monthInfoActivated { layoutNeedsUpdating = true }
        }
    }

	
	
	public var delegate: PMCalendarViewDelegate?
	public var dataSource: PMCalendarViewDataSource! {
        didSet {
            if monthInfo.count < 1 { monthInfo = setupMonthInfoDataForStartAndEndDate() }
            reloadData()
        }
    }
	
	public var selectedDates = [NSDate]()
	private(set) var selectedIndexPaths = [NSIndexPath]()
		
	public var scrollEnabled: Bool = true {
		didSet { calendarView.scrollEnabled = scrollEnabled }
	}
	
	weak var headerView: PMCalendarHeaderView?
	weak var weekdaysView: PMCalendarWeekdaysView?

	private var cellClassType: PMCalendarCell.Type!
	private var layoutNeedsUpdating = false
    private var scrollToDatePathOnRowChange: NSDate?
    private var delayedExecutionClosure: (Void -> Void)?
	
    private var currentSectionPage: Int {
        var page = 0
        if self.direction == .Horizontal {
            page = Int(floor(calendarView.contentOffset.x / calendarView.bounds.width))
        } else {
            page = Int(floor(calendarView.contentOffset.y / calendarView.bounds.height))
        }
        let totalSections = monthInfo.count * numberOfSectionsPerMonth
        if page >= totalSections { return totalSections - 1 }
        return page > 0 ? page : 0
    }

    private lazy var startDateCache: NSDate = {
		[unowned self] in
		self.calendar = self.dataSource.calendarViewCalendar
		self.locale = self.dataSource.calendarViewLocale
		self.endDateCache = self.dataSource.calendarViewEndDate
		return self.dataSource.calendarViewStartDate
    }()
    
    private lazy var endDateCache: NSDate = {
		[unowned self] in
		self.calendar = self.dataSource.calendarViewCalendar
		self.locale = self.dataSource.calendarViewLocale
		self.startDateCache = self.dataSource.calendarViewStartDate
		return self.dataSource.calendarViewEndDate
    }()
    
    lazy var calendar: NSCalendar = {
		[unowned self] in
		self.locale = self.dataSource.calendarViewLocale
		self.startDateCache = self.dataSource.calendarViewStartDate
		self.endDateCache = self.dataSource.calendarViewEndDate
		return self.dataSource.calendarViewCalendar
    }()
	
	lazy var locale: NSLocale = {
		[unowned self] in
		self.calendar = self.dataSource.calendarViewCalendar
		self.startDateCache = self.dataSource.calendarViewStartDate
		self.endDateCache = self.dataSource.calendarViewEndDate
		return self.dataSource.calendarViewLocale
	}()
    
    private lazy var startOfMonthCache: NSDate = {
		[unowned self] in
        let dayOneComponents = self.calendar.components([.Era, .Year, .Month], fromDate: self.startDateCache)
        if let date = self.calendar.dateFromComponents(dayOneComponents) { return date }
        let currentDate = NSDate()
        print("Error: Date was not correctly generated for start of month. current date was used: \(currentDate)")
        return currentDate
    }()
    
    private lazy var endOfMonthCache: NSDate = {
		[unowned self] in
            let lastDayComponents = self.calendar.components([.Era, .Year, .Month], fromDate: self.endDateCache)
            lastDayComponents.month = lastDayComponents.month + 1
            lastDayComponents.day = 0
        if let returnDate = self.calendar.dateFromComponents(lastDayComponents) { return returnDate }
        let currentDate = NSDate()
        print("Error: Date was not correctly generated for end of month. current date was used: \(currentDate)")
        return currentDate
    }()
	
	
    private lazy var monthInfo : [[Int]] = {
		[unowned self] in
            let newMonthInfo = self.setupMonthInfoDataForStartAndEndDate()
            self.monthInfoActivated = true
            return newMonthInfo
    }()
	
	
	private var monthInfoActivated = false
    private var numberOfMonthSections: Int = 0
    private var numberOfSectionsPerMonth: Int = 0
    private var numberOfItemsPerSection: Int { return MAX_NUMBER_OF_DAYS_IN_WEEK * numberOfRowsPerMonth }
    

	private lazy var numberFormatter: NSNumberFormatter = {
		[unowned self] in
		let formatter = NSNumberFormatter()
		formatter.locale = self.locale
		return formatter
	}()

	private lazy var calendarView: UICollectionView = {
		[unowned self] in
		let layout = PMCalendarHorizontalFlowLayout(withDelegate: self)
		layout.scrollDirection = self.direction
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		
		let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.pagingEnabled = true
		collectionView.backgroundColor = .clearColor()
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.allowsMultipleSelection = false
		return collectionView
	}()
	
    private func updateLayoutItemSize(layout: PMCalendarLayoutProtocol) {
        layout.itemSize = CGSizeMake(
            calendarView.frame.size.width / CGFloat(MAX_NUMBER_OF_DAYS_IN_WEEK),
            (calendarView.frame.size.height - layout.headerReferenceSize.height) / CGFloat(numberOfRowsPerMonth)
        )
		if let layout = layout as? UICollectionViewLayout { calendarView.collectionViewLayout = layout }
    }
    
    public override var frame: CGRect {
        didSet {
            calendarView.frame = CGRect(x:0.0, y:bufferTop, width: frame.size.width, height: frame.size.height - bufferBottom)
            calendarView.collectionViewLayout.invalidateLayout()
			if let layout = calendarView.collectionViewLayout as? PMCalendarLayoutProtocol {
				updateLayoutItemSize(layout)
			}
        }
    }

	public init(withDataSource dataSource: PMCalendarViewDataSource, cellClass: PMCalendarCell.Type) {
		super.init(frame: CGRectMake(0, 0, 200, 200))
		self.dataSource = dataSource
		initialSetup()
		registerCellClass(cellClass)
	}
	
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        initialSetup()
    }
    
    public override func layoutSubviews() {
        frame = super.frame
    }
        
    public func initialSetup() {
        clipsToBounds = true
        addSubview(calendarView)
    }
    
	public func registerCellClass(classType: PMCalendarCell.Type) {
		cellClassType = classType
		calendarView.registerClass(classType.self, forCellWithReuseIdentifier: classType.reuseID)
	}

	public func registerCellNib(nib: UINib?, classType: PMCalendarCell.Type) {
		cellClassType = classType
		calendarView.registerNib(nib, forCellWithReuseIdentifier: classType.reuseID)
	}
	
    public func reloadData() {
        if layoutNeedsUpdating {
            changeNumberOfRowsPerMonthTo(numberOfRowsPerMonth, withFocusDate: nil)
        } else {
            calendarView.reloadData()
        }
    }
    
    public func changeNumberOfRowsPerMonthTo(number: Int, withFocusDate date: NSDate?) {
        scrollToDatePathOnRowChange = date
        switch number {
            case 1, 2, 3:
                numberOfRowsPerMonth = number
            default:
                numberOfRowsPerMonth = 6
        }
        configureChangeOfRows()
    }
    
    private func configureChangeOfRows() {
        selectedDates.removeAll()
        selectedIndexPaths.removeAll()
        
        monthInfo = setupMonthInfoDataForStartAndEndDate()
        monthInfoActivated = true
        
        let layout = calendarView.collectionViewLayout
		if let layout = layout as? PMCalendarLayoutProtocol { updateLayoutItemSize(layout) }
        calendarView.setCollectionViewLayout(layout, animated: true)
        calendarView.reloadData()
        
        layoutNeedsUpdating = false
        
        guard let dateToScrollTo = scrollToDatePathOnRowChange else {
            let position: UICollectionViewScrollPosition = direction == .Horizontal ? .Left : .Top
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: position, animated: animationsEnabled)
            return
        }
        
        delayRunOnMainThread(0.0, closure: { self.scrollToDate(dateToScrollTo) })
    }
    
    private func generateNewLayout() -> UICollectionViewLayout {
        if direction == .Horizontal {
            let layout = PMCalendarHorizontalFlowLayout(withDelegate: self)
            layout.scrollDirection = direction
            return layout
        } else {
            let layout = PMCalendarVerticalFlowLayout()
            layout.scrollDirection = direction
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            return layout
        }
    }
	
    private func setupMonthInfoDataForStartAndEndDate() -> [[Int]] {
        var retval = [[Int]]()
		
		let startDate = dataSource.calendarViewStartDate
		let endDate = dataSource.calendarViewEndDate
		
		if calendar.compareDate(startDate, toDate: endDate, toUnitGranularity: .Nanosecond) == .OrderedDescending {
			return retval
		}
		
		startDateCache = startDate
		endDateCache = endDate
		
		let dayOneComponents = calendar.components([.Era, .Year, .Month], fromDate: startDateCache)
            
		let lastDayComponents = calendar.components([.Era, .Year, .Month], fromDate: endDateCache)
		lastDayComponents.month = lastDayComponents.month + 1
		lastDayComponents.day = 0
		
		if let dateFromDayOneComponents = calendar.dateFromComponents(dayOneComponents),
			dateFromLastDayComponents = calendar.dateFromComponents(lastDayComponents) {
			startOfMonthCache = dateFromDayOneComponents
			endOfMonthCache = dateFromLastDayComponents
			
			let differenceComponents = calendar.components(.Month, fromDate: startOfMonthCache, toDate: endOfMonthCache, options: [])
			
			let leftDate = calendar.dateByAddingUnit(.Weekday, value: -1, toDate: startOfMonthCache, options: [])!
			let leftDateInt = calendar.component(.Day, fromDate: leftDate)
			
			numberOfMonthSections = differenceComponents.month + 1
			numberOfSectionsPerMonth = Int(ceil(Float(MAX_NUMBER_OF_ROWS_PER_MONTH)  / Float(numberOfRowsPerMonth)))
			
			for numberOfMonthsIndex in 0...numberOfMonthSections-1 {
				if let correctMonthForSectionDate = calendar.dateByAddingUnit(.Month, value: numberOfMonthsIndex, toDate: startOfMonthCache, options: []) {
					
					let numberOfDaysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: correctMonthForSectionDate).length
					
					var firstWeekdayOfMonthIndex = calendar.component(.Weekday, fromDate: correctMonthForSectionDate)
					firstWeekdayOfMonthIndex -= 1
					firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + firstDayOfWeek.specialValue) % 7
					
					let aFullSection = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK)
					var numberOfDaysInFirstSection = aFullSection - firstWeekdayOfMonthIndex
					
					if numberOfDaysInFirstSection > numberOfDaysInMonth {
						numberOfDaysInFirstSection = numberOfDaysInMonth
					}
					
					let firstSectionDetail = [firstWeekdayOfMonthIndex, numberOfDaysInFirstSection, 0, numberOfDaysInMonth]
					retval.append(firstSectionDetail)
					let numberOfSectionsLeft = numberOfSectionsPerMonth - 1
					
					if numberOfSectionsLeft < 1 { continue }
					
					var numberOfDaysLeft = numberOfDaysInMonth - numberOfDaysInFirstSection
					for _ in 0...numberOfSectionsLeft-1 {
						switch numberOfDaysLeft {
						case _ where numberOfDaysLeft <= aFullSection:
							let midSectionDetail: [Int] = [0, numberOfDaysLeft, firstWeekdayOfMonthIndex]
							retval.append(midSectionDetail)
							numberOfDaysLeft = 0
						case _ where numberOfDaysLeft > aFullSection:
							let lastPopulatedSectionDetail: [Int] = [0, aFullSection, firstWeekdayOfMonthIndex]
							retval.append(lastPopulatedSectionDetail)
							numberOfDaysLeft -= aFullSection
						default:
							break
						}
					}
				}
			}
			retval[0].append(leftDateInt)
		}
		return retval
    }

    public func scrollToNextSegment(animateScroll: Bool = true, completionHandler: (Void -> Void)? = nil) {
        let page = currentSectionPage
        if page + 1 < monthInfo.count {
            let position: UICollectionViewScrollPosition = direction == .Horizontal ? .Left : .Top
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection:page + 1), atScrollPosition: position, animated: animateScroll)
        }
    }

	public func scrollToPreviousSegment(animateScroll: Bool = true, completionHandler: (Void -> Void)? = nil) {
        let page = currentSectionPage
        if page - 1 > -1 {
            let position: UICollectionViewScrollPosition = direction == .Horizontal ? .Left : .Top
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection:page - 1), atScrollPosition: position, animated: animateScroll)
        }
    }
	
	public func scrollToDate(date: NSDate, animateScroll: Bool = true, completionHandler: (Void -> Void)? = nil) {
        guard monthInfoActivated else { return }
        
        let components = calendar.components([.Year, .Month, .Day],  fromDate: date)
        let firstDayOfDate = calendar.dateFromComponents(components)
        
        if !firstDayOfDate!.isWithinInclusiveBoundaryDates(startOfMonthCache, endDate: endOfMonthCache) {
            return
        }

        let periodApart = calendar.components(.Month, fromDate: startOfMonthCache, toDate: date, options: [])
        let monthsApart = periodApart.month
        let segmentIndex = monthsApart * numberOfSectionsPerMonth
        let sectionIndexPath =  pathsFromDates([date])[0]
        let page = currentSectionPage
        
        delayedExecutionClosure = completionHandler
        
        let segmentToScrollTo = NSIndexPath(forItem: 0, inSection: sectionIndexPath.section)
        
        if page != segmentIndex {
            let position: UICollectionViewScrollPosition = direction == .Horizontal ? .Left : .Top
            delayRunOnMainThread(0.0, closure: { 
                self.calendarView.scrollToItemAtIndexPath(segmentToScrollTo, atScrollPosition: position, animated: animateScroll)
                if !animateScroll {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                }
            })
        } else {
            scrollViewDidEndScrollingAnimation(calendarView)
        }
    }
	
    public func selectDates(dates: [NSDate], triggerSelectionDelegate: Bool = true) {
        delayRunOnMainThread(0.0) {
            var allIndexPathsToReload = [NSIndexPath]()
            for date in dates {
                let components = self.calendar.components([.Year, .Month, .Day],  fromDate: date)
                let firstDayOfDate = self.calendar.dateFromComponents(components)
                
                if !firstDayOfDate!.isWithinInclusiveBoundaryDates(self.startOfMonthCache, endDate: self.endOfMonthCache) {
                    continue
                }
                
                let pathFromDates = self.pathsFromDates([date])
                
                if pathFromDates.count < 0 {
                    continue
                }
                
                let sectionIndexPath = pathFromDates[0]
                allIndexPathsToReload.append(sectionIndexPath)
                let selectTheDate = {
                    if self.selectedIndexPaths.contains(sectionIndexPath) == false {
                        self.selectedDates.append(date)
                        self.selectedIndexPaths.append(sectionIndexPath)
                    }
                    self.calendarView.selectItemAtIndexPath(sectionIndexPath, animated: false, scrollPosition: .None)
                    if triggerSelectionDelegate {
                        self.collectionView(self.calendarView, didSelectItemAtIndexPath: sectionIndexPath)
                    }
                }
                
                let deSelectTheDate = { (indexPath: NSIndexPath) in
                    self.calendarView.deselectItemAtIndexPath(indexPath, animated: false)
                    if self.selectedIndexPaths.contains(indexPath),
						let index = self.selectedIndexPaths.indexOf(indexPath) {
                        self.selectedIndexPaths.removeAtIndex(index)
                        self.selectedDates.removeAtIndex(index)
                    }
                    if triggerSelectionDelegate {
                        self.collectionView(self.calendarView, didDeselectItemAtIndexPath: indexPath)
                    }
                }
				
                if self.calendarView.allowsMultipleSelection == false {
                    for indexPath in self.selectedIndexPaths {
                        if indexPath != sectionIndexPath {
                            deSelectTheDate(indexPath)
                        }
                    }
                    selectTheDate()
                } else {
                    if self.selectedIndexPaths.contains(sectionIndexPath) {
                        deSelectTheDate(sectionIndexPath)
                    } else {
                        selectTheDate()
                    }
                }
            }
			
            if triggerSelectionDelegate == false {
                self.calendarView.reloadItemsAtIndexPaths(allIndexPathsToReload)
            }
        }
    }
    
    public func reloadDates(dates: [NSDate]) {
        let paths = pathsFromDates(dates)
        reloadPaths(paths)
    }
    
    func reloadPaths(indexPaths: [NSIndexPath]) {
        if indexPaths.count > 0 {
            calendarView.reloadItemsAtIndexPaths(indexPaths)
        }
    }
    
    private func pathsFromDates(dates:[NSDate])-> [NSIndexPath] {
        var returnPaths = [NSIndexPath]()
        for date in dates {
            if date.isWithinInclusiveBoundaryDates(startOfMonthCache, endDate: endOfMonthCache) {
                let periodApart = calendar.components(.Month, fromDate: startOfMonthCache, toDate: date, options: [])
                let monthSectionIndex = periodApart.month
                let startSectionIndex = monthSectionIndex * numberOfSectionsPerMonth
                let sectionIndex = startMonthSectionForSection(startSectionIndex)
                let currentMonthInfo = monthInfo[sectionIndex]
                let dayIndex = calendar.components(.Day, fromDate: date).day
                let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
                let cellIndex = dayIndex + fdIndex - 1
                let updatedSection = cellIndex / numberOfItemsPerSection
                let adjustedSection = sectionIndex + updatedSection
                let adjustedCellIndex = cellIndex - (numberOfItemsPerSection * (cellIndex / numberOfItemsPerSection))
                returnPaths.append(NSIndexPath(forItem: adjustedCellIndex, inSection: adjustedSection))
            }
        }
        return returnPaths
    }
    
    public func currentCalendarSegment() -> (startDate: NSDate, endDate: NSDate)? {
        if monthInfo.count < 1 {
            return nil
        }
        let section = currentSectionPage
        let monthData = monthInfo[section]
        let itemLength = monthData[NUMBER_OF_DAYS_INDEX]
        let fdIndex = monthData[FIRST_DAY_INDEX]
        let startIndex = NSIndexPath(forItem: fdIndex, inSection: section)
        let endIndex = NSIndexPath(forItem: fdIndex + itemLength - 1, inSection: section)

        if let theStartDate = dateFromPath(startIndex), theEndDate = dateFromPath(endIndex) {
            return (theStartDate, theEndDate)
        }
        return nil
    }
}

// MARK: scrollViewDelegates
extension PMCalendarView: UIScrollViewDelegate {
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
        delayedExecutionClosure?()
        delayedExecutionClosure = nil
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let section = currentSectionPage
		let indexPath = NSIndexPath(forItem: 0, inSection: section)
        (calendarView.collectionViewLayout as? PMCalendarLayoutProtocol)?.pathForFocusItem = indexPath
		
        if let currentSegmentDates = currentCalendarSegment() {
			headerView?.updateToDate(currentSegmentDates.endDate)
			delegate?.calendarView(self, didScrollToDateSegmentStartingWith: currentSegmentDates.startDate, endingWithDate: currentSegmentDates.endDate)
        }
    }
}

extension PMCalendarView {
    private func cellStateFromIndexPath(indexPath: NSIndexPath) -> PMCalendarDateState {
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        
        let currentMonthInfo = monthInfo[itemSection]
        
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]

        var cellText: String = ""
        var dateBelongsTo: PMCalendarDateState.DateOwner  = .ThisMonth
        
        if itemIndex >= fdIndex && itemIndex < fdIndex + nDays {
            let cellDate = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - fdIndex - offSet + 1
            cellText = numberFormatter.stringFromNumber(cellDate) ?? String(cellDate)
            dateBelongsTo = .ThisMonth
		} else if itemIndex < fdIndex  && itemSection - 1 > -1 {
			let startOfMonthSection = startMonthSectionForSection(itemSection - 1)
			let cellDate = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - offSet + 1
			let dateToAdd = monthInfo[startOfMonthSection][TOTAL_DAYS_IN_MONTH]
			let dateInt = cellDate + dateToAdd - monthInfo[itemSection][FIRST_DAY_INDEX]
			cellText = numberFormatter.stringFromNumber(dateInt) ?? String(dateInt)
			dateBelongsTo = .PreviousMonthWithinBoundary
		} else if itemIndex >= fdIndex + nDays && itemSection + 1 < monthInfo.count {
            let startOfMonthSection = startMonthSectionForSection(itemSection)
            let cellDate = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - offSet + 1
            let dateToSubtract = monthInfo[startOfMonthSection][TOTAL_DAYS_IN_MONTH]
            let dateInt = cellDate - dateToSubtract - monthInfo[itemSection][FIRST_DAY_INDEX]
			cellText = numberFormatter.stringFromNumber(dateInt) ?? String(dateInt)
            dateBelongsTo = .FollowingMonthWithinBoundary
        } else if itemIndex < fdIndex {
            let cellDate = monthInfo[0][DATE_BOUNDRY] - monthInfo[0][FIRST_DAY_INDEX] + itemIndex + 1
			cellText = numberFormatter.stringFromNumber(cellDate) ?? String(cellDate)
            dateBelongsTo = .PreviousMonthOutsideBoundary
        } else {
            let cmp = calendar.component(.Day, fromDate: dateFromPath(indexPath)!)
			cellText = numberFormatter.stringFromNumber(cmp) ?? String(cmp)
            dateBelongsTo = .FollowingMonthOutsideBoundary
        }

        let cellState = PMCalendarDateState(isSelected: selectedIndexPaths.contains(indexPath),text: cellText, dateBelongsTo: dateBelongsTo)
        
        return cellState
    }
    
    private func startMonthSectionForSection(aSection: Int) -> Int {
        let monthIndexWeAreOn = aSection / numberOfSectionsPerMonth
        let nextSection = numberOfSectionsPerMonth * monthIndexWeAreOn
        return nextSection
    }
    
    private func dateFromPath(indexPath: NSIndexPath) -> NSDate? {
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let monthIndexWeAreOn = itemSection / numberOfSectionsPerMonth
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]
        let cellDate = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - fdIndex - offSet + 1
        let offsetComponents = NSDateComponents()
        
        offsetComponents.month = monthIndexWeAreOn
        offsetComponents.weekday = cellDate - 1

        return calendar.dateByAddingComponents(offsetComponents, toDate: startOfMonthCache, options: [])
    }
    
    private func delayRunOnMainThread(delay: Double, closure: (Void -> Void)) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
    
    private func delayRunOnGlobalThread(delay: Double, qos: qos_class_t, closure: (Void -> Void)) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_global_queue(qos, 0), closure)
    }
}

// MARK: CollectionView delegates
extension PMCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if selectedIndexPaths.contains(indexPath) {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        } else {
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        }
        let dayCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellClassType.reuseID, forIndexPath: indexPath) as! PMCalendarCell
		if let date = dateFromPath(indexPath) {
			let cellState = cellStateFromIndexPath(indexPath)
			dayCell.calendarCell(isAboutToDisplayDate: date, state: cellState)
			dayCell.transform = collectionView.transform
		}
        return dayCell
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if monthInfo.count > 0 { scrollViewDidEndDecelerating(calendarView) }
        return monthInfo.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  MAX_NUMBER_OF_DAYS_IN_WEEK * numberOfRowsPerMonth
    }
    
	public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let dateUserSelected = dateFromPath(indexPath),
			cell = collectionView.cellForItemAtIndexPath(indexPath) as? PMCalendarCell {
			if cell.hidden == false && cell.userInteractionEnabled == true {
				let cellState = cellStateFromIndexPath(indexPath)
				return delegate?.calendarView(self, canSelectDate: dateUserSelected, state: cellState) ??
					cell.calendarCell(canSelectDate: dateUserSelected, state: cellState)
			}
		}
        return false
    }
	
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		if let dateSelectedByUser = dateFromPath(indexPath) {
			if let index = selectedIndexPaths.indexOf(indexPath) {
				selectedIndexPaths.removeAtIndex(index)
				selectedDates.removeAtIndex(index)
			}
			
			let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? PMCalendarCell
			let cellState = cellStateFromIndexPath(indexPath)
			delegate?.calendarView(self, didDeselectDate: dateSelectedByUser, state: cellState)
			selectedCell?.calendarCell(didDeselectDate: dateSelectedByUser, state: cellState)
		}
	}
	
	public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let dateUserSelected = dateFromPath(indexPath),
			cell = collectionView.cellForItemAtIndexPath(indexPath) as? PMCalendarCell {
			let cellState = cellStateFromIndexPath(indexPath)
			return delegate?.calendarView(self, canDeselectDate: dateUserSelected, state: cellState) ??
				cell.calendarCell(canDeselectDate: dateUserSelected, state: cellState)
		}
        return false
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let dateSelectedByUser = dateFromPath(indexPath) {
            if selectedIndexPaths.contains(indexPath) == false {
                selectedIndexPaths.append(indexPath)
                selectedDates.append(dateSelectedByUser)
            }
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? PMCalendarCell
            let cellState = cellStateFromIndexPath(indexPath)
			headerView?.updateToDate(dateSelectedByUser)
			delegate?.calendarView(self, didSelectDate: dateSelectedByUser, state: cellState)
			selectedCell?.calendarCell(didSelectDate: dateSelectedByUser, state: cellState)
        }
    }
}

extension PMCalendarView: PMCalendarLayoutDelegate {
    func numberOfRows() -> Int {
        return numberOfRowsPerMonth
    }
    
    func numberOfColumns() -> Int {
        return MAX_NUMBER_OF_DAYS_IN_WEEK
    }
    
    func numberOfsectionsPermonth() -> Int {
        return numberOfSectionsPerMonth
    }
    
    func numberOfSections() -> Int {
        return numberOfMonthSections
    }
}

private extension NSDate {
    private func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        return compare(dateToCompare) == .OrderedDescending
    }
    
    private func isLessThanDate(dateToCompare: NSDate) -> Bool {
		return compare(dateToCompare) == .OrderedAscending
	}
	
    private func equalToDate(dateToCompare: NSDate) -> Bool {
        return compare(dateToCompare) == .OrderedSame
    }
    
    private func isWithinInclusiveBoundaryDates(startDate: NSDate, endDate: NSDate) -> Bool {
        return (equalToDate(startDate) || isGreaterThanDate(startDate)) && (equalToDate(endDate) || isLessThanDate(endDate))
    }
    
    private func isWithinExclusiveBoundaryDates(startDate: NSDate, endDate: NSDate) -> Bool {
        return isGreaterThanDate(startDate) && isLessThanDate(endDate)
    }
}
