package nv.objects.enemies {
	
	import flash.events.Event;

	
	import citrus.objects.CitrusSprite;
	
	/**
	 * This class is the hero character.
	 *  
	 * @author livedtrid
	 * 
	 */
	public class Enemy extends CitrusSprite
	{		
					
		public function Enemy(name:String, params:Object=null)
		{
			super(name, params);
			
			createEnemyArt();
			
		}
		
		/**
		 * Create hero art/visuals. 
		 * 
		 */
		private function createEnemyArt():void
		{

		}
		
		private function _textureCompleteHandler(evt:Event):void {

		
			
		}
		
		/**
		 * Set enemy animation speed. 
		 * @param speed
		 * 
		 */
		public function setEnemyAnimationSpeed(speed:int):void {
			
			_view.fps = (speed == 0) ? 20 : 60;
		}
		
		override public function update(timeDelta:Number):void
		{
			//camTarget.x = _body.position.x;
			//camTarget.y = _body.position.y;
			
		}
	}
}