package nv.objects.backgrounds{
	
	import citrus.objects.CitrusSprite;	
	import starling.display.Sprite;

	/**
	 * This class defines the whole InGame background containing multiple background layers.
	 *  
	 * @author hsharma
	 * 
	 */
	public class GameBackground extends CitrusSprite
	{
		/**
		 * Different layers of the background. 
		 */
		
		private var _container:Sprite;
		
		private var bgLayer1:BgLayer;
		private var bgLayer2:BgLayer;
		private var bgLayer3:BgLayer;
		private var bgLayer4:BgLayer;
		
		/** Current speed of animation of the background. */
	
	public var speed:Number = 0;
		
		/** State of the game. */		
		public var state:int;
		
		/** Game paused? */
		public var gamePaused:Boolean = false;
		
		public function GameBackground(name:String, params:Object = null)
		{
			super(name, params);
			
			_container = new Sprite();
			
			_view = _container;
			
			//Sky
			bgLayer1 = new BgLayer(1);
			bgLayer1.parallaxDepth = 0.002;
			_container.addChild(bgLayer1);
			
			//Mountains
			bgLayer2 = new BgLayer(2);
		bgLayer2.y =-250;
			bgLayer2.parallaxDepth = 0.02;
			_container.addChild(bgLayer2);
			
			//Hills
			bgLayer3 = new BgLayer(3);
			bgLayer3.y =-30;
			bgLayer3.parallaxDepth = 0.05;
			_container.addChild(bgLayer3);
			
			//Grass
			bgLayer4 = new BgLayer(4);
			//bgLayer4.parallaxDepth = 0;
			_container.addChild(bgLayer4);
			
		}
		
		/**
		 * On every frame, animate each layer based on its parallax depth and hero's speed. 
		 * @param event
		 * 
		 */
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (!gamePaused)
			{
				// Background 1 - Sky
				bgLayer1.x -= (speed * bgLayer1.parallaxDepth * 400);
				bgLayer2.x -= (speed * bgLayer2.parallaxDepth * 400);
				bgLayer3.x -= (speed * bgLayer3.parallaxDepth * 400);
				
	/*		
			bgLayer1.x -=- Math.ceil(speed * bgLayer1.parallaxDepth);
				trace("speed * bgLayer1.parallaxDepth" + speed * bgLayer1.parallaxDepth);
				trace("Math.ceil(speed * bgLayer1.parallaxDepth)" + Math.ceil(speed * bgLayer1.parallaxDepth));
		
			bgLayer2.x -= Math.ceil(speed * bgLayer2.parallaxDepth);
			
			bgLayer3.x -= Math.ceil(speed * bgLayer3.parallaxDepth);
			
			bgLayer4.x -= Math.ceil(speed * bgLayer4.parallaxDepth);
				
				*/
			}
			
		}
	}
}