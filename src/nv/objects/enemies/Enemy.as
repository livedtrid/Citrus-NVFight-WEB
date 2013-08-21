package nv.objects.enemies {
	
	import flash.events.Event;
	
	import citrus.objects.CitrusSprite;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import nv.util.Assets;
	
	import starling.display.Sprite;
	
	/**
	 * This class is the Enemy character.
	 *  
	 * @author livedtrid
	 * 
	 */
	public class Enemy extends CitrusSprite
	{		
		private var _factory:StarlingFactory;
		private var _armature:Armature;
		public var _armatureClip:Sprite;
		private var enemyScale:Number;
							
		public function Enemy(name:String, params:Object=null)
		{
			super(name, params);
			
			enemyScale=0.6;
			trace("Enemy");
			
			createEnemyArt();
			
		}
		
	
		/**
		 * Create hero art/visuals. 
		 * 
		 */
		private function createEnemyArt():void
		{
			trace("createEnemyArt");
			//Dragonbones
			_factory = new StarlingFactory();
			_factory.addEventListener(Event.COMPLETE, _textureCompleteHandler);
			_factory.parseData(new Assets.EnemyTyker1Data());

		}
		
		//Draonbones
		private function _textureCompleteHandler(evt:Event):void {
			trace("_textureCompleteHandler");
			
			_factory.removeEventListener(Event.COMPLETE, _textureCompleteHandler);
			
			_armature = _factory.buildArmature("tyker1");
			//Set animation speed
			_armature.animation.timeScale = 0.9;
			//_armature.colorTransform.color = 0x112233;
			
			_armatureClip = _armature.display as Sprite;
			
			// if want the character to be build on the left this value need to be negative
			_armatureClip.scaleY = _armatureClip.scaleX = enemyScale;
			_armature.animation.gotoAndPlay("stand", -1, -1, true);
					
			WorldClock.clock.add(_armature);			
		
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