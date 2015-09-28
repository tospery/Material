//
// Copyright (C) 2015 GraphKit, Inc. <http://graphkit.io> and other GraphKit contributors.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program located at the root of the software package
// in a file called LICENSE.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public class MaterialPulseView: MaterialView {
	//
	//	:name:	pulseLayer
	//
	internal lazy var pulseLayer: CAShapeLayer = CAShapeLayer()
	
	/**
		:name:	init
	*/
	public convenience init() {
		self.init(frame: CGRectMake(MaterialTheme.pulseView.x, MaterialTheme.pulseView.y, MaterialTheme.pulseView.width, MaterialTheme.pulseView.height))
	}
	
	/**
		:name:	touchesBegan
	*/
	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event)
		let point: CGPoint = touches.first!.locationInView(self)
		if nil != visualLayer.presentationLayer()?.hitTest(point) {
			CATransaction.begin()
			CATransaction.setAnimationDuration(0)
			pulseLayer.hidden = false
			pulseLayer.position = point
			pulseLayer.frame = CGRectMake(0, 0, width, height)
			pulseLayer.cornerRadius = visualLayer.cornerRadius
			CATransaction.commit()
			
			CATransaction.begin()
			CATransaction.setAnimationDuration(0.3)
			pulseLayer.transform = CATransform3DMakeScale(3, 3, 3)
			visualLayer.transform = CATransform3DMakeScale(1.1, 1.1, 1.1)
			CATransaction.commit()
		}
	}
	
	/**
		:name:	touchesEnded
	*/
	public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		CATransaction.begin()
		CATransaction.setAnimationDuration(0.3)
		pulseLayer.hidden = true
		pulseLayer.transform = CATransform3DIdentity
		visualLayer.transform = CATransform3DIdentity
		CATransaction.commit()
	}
	
	/**
		:name:	touchesCancelled
	*/
	public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		super.touchesCancelled(touches, withEvent: event)
	}
	
	//
	//	:name:	prepareView
	//
	internal override func prepareView() {
		super.prepareView()
		userInteractionEnabled = MaterialTheme.pulseView.userInteractionEnabled
		backgroundColor = MaterialTheme.pulseView.backgroudColor
	}
	
	//
	//	:name:	prepareLayer
	//
	internal override func prepareLayer() {
		super.prepareLayer()
		contentsRect = MaterialTheme.pulseView.contentsRect
		contentsCenter = MaterialTheme.pulseView.contentsCenter
		contentsScale = MaterialTheme.pulseView.contentsScale
		contentsGravity = MaterialTheme.pulseView.contentsGravity
		shadowDepth = MaterialTheme.pulseView.shadowDepth
		shadowColor = MaterialTheme.pulseView.shadowColor
		zPosition = MaterialTheme.pulseView.zPosition
		masksToBounds = MaterialTheme.pulseView.masksToBounds
		cornerRadius = MaterialTheme.pulseView.cornerRadius
		borderWidth = MaterialTheme.pulseView.borderWidth
		borderColor = MaterialTheme.pulseView.bordercolor
		
		// pulseLayer
		pulseLayer.hidden = true
		pulseLayer.backgroundColor = MaterialColor.white.colorWithAlphaComponent(0.5).CGColor
		visualLayer.addSublayer(pulseLayer)
	}
}
