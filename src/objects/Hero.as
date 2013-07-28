package objects {
		
		import citrus.core.CitrusEngine;
		import citrus.input.controllers.Keyboard;
		import citrus.objects.CitrusSprite;
		
		//import games.hungryhero.GameConstants;
		
		/**
		 * This class is the hero character.
		 *  
		 * @author hsharma
		 * 
		 */
		public class Hero extends CitrusSprite
		{		
			/** State of the hero. */
			public var state:int;
			public var camTarget:Object = { x: 0, y: 0 };
			private var playerSpeed:int =10;
			
			public function Hero(name:String, params:Object=null)
			{
				super(name, params);
				
				// Set the game state to idle.
			//	this.state = GameConstants.GAME_STATE_IDLE;
				
				// Initialize hero art and hit area.
				createHeroArt();
				
			}
			
			/**
			 * Create hero art/visuals. 
			 * 
			 */
			private function createHeroArt():void
			{
				/** Hero character animation. */
				
				offsetX = Math.ceil(-_view.width/2);
				offsetY = Math.ceil(-_view.height/2);
			}
			
			/**
			 * Set hero animation speed. 
			 * @param speed
			 * 
			 */
			public function setHeroAnimationSpeed(speed:int):void {
				
				_view.fps = (speed == 0) ? 20 : 60;
			}
			
			override public function get width():Number
			{
				return _view ? view.texture.width : NaN;
			}
			
			override public function get height():Number
			{
				return _view ? view.texture.height : NaN;
			}
			
			override public function update(timeDelta:Number):void
			{
				//camTarget.x = _body.position.x;
				//camTarget.y = _body.position.y;
				
			}
		}
	}