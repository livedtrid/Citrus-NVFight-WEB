// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package objects
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.utils.VertexData;
	
	/** A Quad represents a rectangle with a uniform color or a color gradient.
	 *  
	 *  <p>You can set one color per vertex. The colors will smoothly fade into each other over the area
	 *  of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
	 *  another color to vertices 2 and 3. </p> 
	 *
	 *  <p>The indices of the vertices are arranged like this:</p>
	 *  
	 *  <pre>
	 *  0 - 1
	 *  | / |
	 *  2 - 3
	 *  </pre>
	 * 
	 *  @see Image
	 */
	public class Quad extends DisplayObject
	{
		private var mTinted:Boolean;
		
		/** The raw vertex data of the quad. */
		protected var mVertexData:VertexData;
		
		/** Helper objects. */
		private static var sHelperPoint:Point = new Point();
		private static var sHelperMatrix:Matrix = new Matrix();
		
		/** Creates a quad with a certain size and color. The last parameter controls if the 
		 *  alpha value should be premultiplied into the color values on rendering, which can
		 *  influence blending output. You can use the default value in most cases.  */
		public function Quad(width:Number, height:Number, topleft:Number, topright:Number, color:uint=0xffffff,
							 premultipliedAlpha:Boolean=true)
		{
			mTinted = color != 0xffffff;
			
			mVertexData = new VertexData(4, premultipliedAlpha);
			mVertexData.setPosition(0, topleft, 0.0);
			mVertexData.setPosition(1, width, topright);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height);            
			mVertexData.setUniformColor(color);
			
			onVertexDataChanged();
		}
		
		/** Call this method after manually changing the contents of 'mVertexData'. */
		protected function onVertexDataChanged():void
		{
			// override in subclasses, if necessary
		}
		
		/** @inheritDoc */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			if (targetSpace == this) // optimization
			{
				mVertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(0.0, 0.0, sHelperPoint.x, sHelperPoint.y);
			}
			else if (targetSpace == parent && rotation == 0.0) // optimization
			{
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				mVertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
					sHelperPoint.x * scaleX, sHelperPoint.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
			}
			else
			{
				getTransformationMatrix(targetSpace, sHelperMatrix);
				mVertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
			}
			
			return resultRect;
		}
		
		/** Returns the color of a vertex at a certain index. */
		public function getVertexColor(vertexID:int):uint
		{
			return mVertexData.getColor(vertexID);
		}
		
		/** Sets the color of a vertex at a certain index. */
		public function setVertexColor(vertexID:int, color:uint):void
		{
			mVertexData.setColor(vertexID, color);
			onVertexDataChanged();
			
			if (color != 0xffffff) mTinted = true;
			else mTinted = mVertexData.tinted;
		}
		
		/** Returns the alpha value of a vertex at a certain index. */
		public function getVertexAlpha(vertexID:int):Number
		{
			return mVertexData.getAlpha(vertexID);
		}
		
		/** Sets the alpha value of a vertex at a certain index. */
		public function setVertexAlpha(vertexID:int, alpha:Number):void
		{
			mVertexData.setAlpha(vertexID, alpha);
			onVertexDataChanged();
			
			if (alpha != 1.0) mTinted = true;
			else mTinted = mVertexData.tinted;
		}
		
		/** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
		public function get color():uint 
		{ 
			return mVertexData.getColor(0); 
		}
		
		/** Sets the colors of all vertices to a certain value. */
		public function set color(value:uint):void 
		{
			for (var i:int=0; i<4; ++i)
				setVertexColor(i, value);
			
			if (value != 0xffffff || alpha != 1.0) mTinted = true;
			else mTinted = mVertexData.tinted;
		}
		
		/** @inheritDoc **/
		public override function set alpha(value:Number):void
		{
			super.alpha = value;
			
			if (value < 1.0) mTinted = true;
			else mTinted = mVertexData.tinted;
		}
		
		/** Copies the raw vertex data to a VertexData instance. */
		public function copyVertexDataTo(targetData:VertexData, targetVertexID:int=0):void
		{
			mVertexData.copyTo(targetData, targetVertexID);
		}
		
		/** @inheritDoc */
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			support.batchQuad(this, parentAlpha);
		}
		
		/** Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
		public function get tinted():Boolean { return mTinted; }
		
		/** Indicates if the rgb values are stored premultiplied with the alpha value; this can
		 *  affect the rendering. (Most developers don't have to care, though.) */
		public function get premultipliedAlpha():Boolean { return mVertexData.premultipliedAlpha; }
	}
}