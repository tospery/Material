/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

open class ChipItem: FlatButton {}

@objc(ChipBarDelegate)
public protocol ChipBarDelegate {
    /**
     A delegation method that is executed when the chipItem will trigger the
     animation to the next chip.
     - Parameter chipBar: A ChipBar.
     - Parameter chipItem: A ChipItem.
     */
    @objc
    optional func chipBar(chipBar: ChipBar, willSelect chipItem: ChipItem)
    
    /**
     A delegation method that is executed when the chipItem did complete the
     animation to the next chip.
     - Parameter chipBar: A ChipBar.
     - Parameter chipItem: A ChipItem.
     */
    @objc
    optional func chipBar(chipBar: ChipBar, didSelect chipItem: ChipItem)
}

@objc(ChipBarStyle)
public enum ChipBarStyle: Int {
    case auto
    case nonScrollable
    case scrollable
}

open class ChipBar: Bar {
    /// A boolean indicating if the ChipBar line is in an animation state.
    open fileprivate(set) var isAnimating = false
    
    /// The total width of the chipItems.
    fileprivate var chipItemsTotalWidth: CGFloat {
        var w: CGFloat = 0
        
        for v in chipItems {
            w += v.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentView.height)).width + interimSpace
        }
        
        return w
    }
    
    /// An enum that determines the chip bar style.
    open var chipBarStyle = ChipBarStyle.auto {
        didSet {
            layoutSubviews()
        }
    }
    
    /// A reference to the scroll view when the chip bar style is scrollable.
    open let scrollView = UIScrollView()
    
    /// Enables and disables bouncing when swiping.
    open var isScrollBounceEnabled: Bool {
        get {
            return scrollView.bounces
        }
        set(value) {
            scrollView.bounces = value
        }
    }
    
    /// A delegation reference.
    open weak var delegate: ChipBarDelegate?
    
    /// The currently selected chipItem.
    open fileprivate(set) var selected: ChipItem?
    
    /// Buttons.
    open var chipItems = [ChipItem]() {
        didSet {
            for b in oldValue {
                b.removeFromSuperview()
            }
            
            prepareChipItems()
            layoutSubviews()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard willLayout else {
            return
        }
        
        var lc = 0
        var rc = 0
        
        grid.begin()
        grid.views.removeAll()
        
        for v in leftViews {
            if let b = v as? ChipItem {
                b.contentEdgeInsets = .zero
                b.titleEdgeInsets = .zero
            }
            
            v.width = v.intrinsicContentSize.width
            v.sizeToFit()
            v.grid.columns = Int(ceil(v.width / gridFactor)) + 2
            
            lc += v.grid.columns
            
            grid.views.append(v)
        }
        
        grid.views.append(contentView)
        
        for v in rightViews {
            if let b = v as? ChipItem {
                b.contentEdgeInsets = .zero
                b.titleEdgeInsets = .zero
            }
            
            v.width = v.intrinsicContentSize.width
            v.sizeToFit()
            v.grid.columns = Int(ceil(v.width / gridFactor)) + 2
            
            rc += v.grid.columns
            
            grid.views.append(v)
        }
        
        contentView.grid.begin()
        contentView.grid.offset.columns = 0
        
        var l: CGFloat = 0
        var r: CGFloat = 0
        
        if .center == contentViewAlignment {
            if leftViews.count < rightViews.count {
                r = CGFloat(rightViews.count) * interimSpace
                l = r
            } else {
                l = CGFloat(leftViews.count) * interimSpace
                r = l
            }
        }
        
        let p = width - l - r - contentEdgeInsets.left - contentEdgeInsets.right
        let columns = Int(ceil(p / gridFactor))
        
        if .center == contentViewAlignment {
            if lc < rc {
                contentView.grid.columns = columns - 2 * rc
                contentView.grid.offset.columns = rc - lc
            } else {
                contentView.grid.columns = columns - 2 * lc
                rightViews.first?.grid.offset.columns = lc - rc
            }
        } else {
            contentView.grid.columns = columns - lc - rc
        }
        
        grid.axis.columns = columns
        
        if .scrollable == chipBarStyle || (.auto == chipBarStyle && chipItemsTotalWidth > bounds.width) {
            var w: CGFloat = 0
            for v in chipItems {
                let x = v.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentView.height)).width + interimSpace
                scrollView.addSubview(v)
                v.height = scrollView.height
                v.width = x
                v.x = w
                w += x
            }
            
            scrollView.contentSize = CGSize(width: w, height: height)
        } else {
            scrollView.grid.views = chipItems
            scrollView.grid.axis.columns = chipItems.count
            scrollView.contentSize = CGSize(width: scrollView.width, height: height)
        }
        
        grid.commit()
        contentView.grid.commit()
        
        layoutDivider()
    }
    
    open override func prepare() {
        super.prepare()
        contentEdgeInsetsPreset = .none
        interimSpacePreset = .interimSpace6
        
        prepareContentView()
        prepareScrollView()
        prepareDivider()
    }
}

fileprivate extension ChipBar {
    /// Prepares the divider.
    func prepareDivider() {
        dividerColor = Color.grey.lighten3
    }
    
    /// Prepares the chipItems.
    func prepareChipItems() {
        for v in chipItems {
            v.grid.columns = 0
            v.cornerRadius = 0
            v.contentEdgeInsets = .zero
        }
    }
    
    /// Prepares the contentView.
    func prepareContentView() {
        contentView.zPosition = 6000
    }
    
    /// Prepares the scroll view.
    func prepareScrollView() {
        scrollView.isPagingEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        centerViews = [scrollView]
    }
}

extension ChipBar {
    /**
     Selects a given index from the chipItems array.
     - Parameter at index: An Int.
     - Paramater completion: An optional completion block.
     */
    open func select(at index: Int, completion: ((ChipItem) -> Void)? = nil) {
        guard -1 < index, index < chipItems.count else {
            return
        }
        animate(to: chipItems[index], isTriggeredByUserInteraction: false, completion: completion)
    }
    
    /**
     Animates to a given chipItem.
     - Parameter to chipItem: A ChipItem.
     - Parameter completion: An optional completion block.
     */
    open func animate(to chipItem: ChipItem, completion: ((ChipItem) -> Void)? = nil) {
        animate(to: chipItem, isTriggeredByUserInteraction: false, completion: completion)
    }
    
    /**
     Animates to a given chipItem.
     - Parameter to chipItem: A ChipItem.
     - Parameter isTriggeredByUserInteraction: A boolean indicating whether the
     state was changed by a user interaction, true if yes, false otherwise.
     - Parameter completion: An optional completion block.
     */
    fileprivate func animate(to chipItem: ChipItem, isTriggeredByUserInteraction: Bool, completion: ((ChipItem) -> Void)? = nil) {
        if isTriggeredByUserInteraction {
            delegate?.chipBar?(chipBar: self, willSelect: chipItem)
        }
        
        selected = chipItem
        isAnimating = true
        
        if !scrollView.bounds.contains(chipItem.frame) {
            let contentOffsetX = (chipItem.x < scrollView.bounds.minX) ? chipItem.x : chipItem.frame.maxX - scrollView.bounds.width
            let normalizedOffsetX = min(max(contentOffsetX, 0), scrollView.contentSize.width - scrollView.bounds.width)
            scrollView.setContentOffset(CGPoint(x: normalizedOffsetX, y: 0), animated: true)
        }
    }
}