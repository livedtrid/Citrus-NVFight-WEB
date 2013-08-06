package states
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.TimeShifter;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import core.Assets;
	
	import dragonBones.Armature;
	import dragonBones.factorys.StarlingFactory;
	
	import objects.hero.Hero;
	import objects.objects.Enemy;
	import objects.objects.GameBackground;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
		

	public class InGame extends StarlingState
	{
		
		/** Game background object. */
		private var bg:GameBackground;
		
		/** Hero character. */		
		private var hero:Hero;
		
		/** Enemy character */
		private var enemy:Enemy;
		
		/** Time calculation for animation. */
		private var elapsed:Number;
		
		// ------------------------------------------------------------------------------------------------------------
		// GAME INTERACTION 
		// ------------------------------------------------------------------------------------------------------------
		/** Keyboard interactions */
		//private var keyboard:Keyboard = _ce.input.keyboard as Keyboard;		
		
		/** Is game rendering through hardware or software? */
		private var isHardwareRendering:Boolean;
		
		/** Hero's current X position. */
		private var heroX:int;
		
		/** Hero's current Y position. */
		private var heroY:int;
		
		/** Game interaction area. */		
		private var gameArea:Rectangle;
		
		/** Is game currently in paused state? */
		private var gamePaused:Boolean = false;
		
		/** Player state. */		
		private var gameState:int;
		
		/** Player's speed. */
		private var playerSpeed:Number;
		
		/** The power of obstacle after it is hit. */
		private var getHit:Number = 0;
		
		/** How much to shake the camera when the player get hits? */
		private var cameraShake:Number;
		
		/** Buffer */
		private var timeshifter:TimeShifter;
		private var _camera:ACitrusCamera;
		private var _bounds:Rectangle;		
		
		/** Constrains the gameArea */		
		// Em altura é necessário saber onde o jogador está para a "regra 3 simples"
		private var _alturaY:Number;
		private var _alturaYAtual:Number;
		private var _alturaYAtualPerc:Number;
		
		// Margem do lado esquerdo
		private var _ladoEsq:Number;
		private var _ladoEsqOffset:Number;
		
		// Margem do lado direito
		private var _ladoDir:Number;
		private var _ladoDirOffset:Number;	

		// ------------------------------------------------------------------------------------------------------------
		// METHODS
		// ------------------------------------------------------------------------------------------------------------
		
		private var _top:Rectangle;
		private var _bottom:Rectangle;
		
		// Dragon Bones
		[Embed(source="assets/texture.png",mimeType="application/octet-stream")]
		private const _ResourcesData:Class;		
		private var _factory:StarlingFactory;
		private var _armature:Armature;
		
		
		public function InGame()
		{
			super();
		
			// Is hardware rendering?
			isHardwareRendering = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
		}
		
		
		override public function initialize():void {
			
			super.initialize();
			
			//Dragonbones
			//_factory = new StarlingFactory();
			//_factory.addEventListener(Event.COMPLETE, _textureCompleteHandler);
			//_factory.parseData(new _ResourcesData());
			
			drawGame();
			drawHUD();
			
			// Define keyboard interactions - moved to the Hero class
			CitrusEngine.getInstance().input.keyboard.addKeyAction("left", Keyboard.LEFT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("right", Keyboard.RIGHT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("down", Keyboard.DOWN);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("up", Keyboard.UP);
			
			// Define game area.
			_top 		= new Rectangle(100, 200, 1600, 20);
			_bottom  	= new Rectangle(0, 450, 1600, 20);
			_alturaY 	= _bottom.y - _top.y;
			_ladoEsq 	= _top.x - _bottom.x;
			_ladoDir 	= (_bottom.x + _bottom.width) - (_top.x + _top.width) ; 
				
			// Reset hit, camera shake and player speed.
			getHit = 0;
			cameraShake = 0;
			playerSpeed = 0.8;
			
			// Hero's initial position
			hero.x = stage.stageWidth/2;
			hero.y = stage.stageHeight/2;
				
			// Reset game paused states.
			gamePaused = false;
			bg.gamePaused = false;
			
			_bounds = new Rectangle(0, 0, 1600, 480); //camera boundaries
			_camera = view.camera as StarlingCamera;
			_camera.setUp(hero, new Point(stage.stageWidth / 2, stage.stageHeight / 2), _bounds, new Point(0.05, 0.05));
			//_camera.allowRotation = true;
			_camera.allowZoom = true;
			
			//_camera.parallaxMode = ACitrusCamera.PARALLAX_MODE_TOPLEFT;
			//_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
		}
		
		//Draonbones
		private function _textureCompleteHandler(evt:Event):void {
			
			_factory.removeEventListener(Event.COMPLETE, _textureCompleteHandler);
			
			_armature = _factory.buildArmature("teo");
			
			(_armature.display as Sprite).scaleY = 0.5;
			// the character is build on the left
			(_armature.display as Sprite).scaleX = -0.5;
			

			
		}
		
		private function drawHUD():void
		{
			// TODO Auto Generated method stub			
		}
		
		private function drawGame():void
		{				
			// Draw background.
			bg = new GameBackground("background");
			add(bg);
			
			// Draw hero.
			hero = new Hero("hero", {view:new MovieClip(Assets.getAtlas().getTextures("teoWalk"), 12)});
			add(hero);
			hero.view.scaleX = hero.view.scaleY = 0.8;
			
			// Draw hero.
			enemy = new Enemy("enemy", {view:new MovieClip(Assets.getAtlas().getTextures("teoWalk"), 12)});
			add(enemy);
			
			//the design wasn't made on the center registration point but close to the top left.
			//var dragon:Hero = new Hero("teo", {x:150, width:60, height:135, offsetY:135 / 2, view:_armature, registration:"topLeft"});
			//add(dragon);
			
			//var dragonbones:DBStarlingMultiBehavior = new DBStarlingMultiBehavior();
			//add(dragonbones as CitrusSprite);
			
		
			// Enemy's initial position
			enemy.x = stage.stageWidth-200;
			enemy.y= stage.stageHeight/2;
		}
		
		private function shakeAnimation(event:Event):void
		{
			// Animate quake effect, shaking the camera a little to the sides and up and down.
			if (cameraShake > 0)
			{
				cameraShake -= 0.1;
				// Shake left right randomly.
				this.x = int(Math.random() * cameraShake - cameraShake * 0.5); 
				// Shake up down randomly.
				this.y = int(Math.random() * cameraShake - cameraShake * 0.5); 
			}
			else if (x != 0) 
			{
				// If the shake value is 0, reset the stage back to normal.
				// Reset to initial position.
				this.x = 0;
				this.y = 0;
			}
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			elapsed = timeDelta;
			
			bg.update(timeDelta);

			bg.speed = 0;
			//hero.view.scaleX = hero.view.scaleY = (_alturaYAtualPerc * 0.02); 
								
			// Confine the hero to stage area limit			
			// Height
			_alturaYAtual 		= (hero.y - hero.height >> 1 ) - (_top.y); // verificar a altura do rect
			_alturaYAtualPerc 	= (_alturaYAtual * 100)/_alturaY + 80;
			
			// Left side
			_ladoEsqOffset		=(_ladoEsq*_alturaYAtualPerc) / 100;
			_ladoEsqOffset		= -(_ladoEsqOffset-100);
			
			// Right side
			_ladoDirOffset		=(_ladoDir*_alturaYAtualPerc) / 100;
			_ladoDirOffset		= -(_ladoDirOffset-100);
						
			if (CitrusEngine.getInstance().input.isDoing("left"))
			{			
				
				if ((hero.x + 5)  >= (_bottom.x + (hero.width/2)  ) + _ladoEsqOffset ){
					hero.x -= 5 * playerSpeed; // move the player to the left
					
					//// stop background
					if (hero.x <= 400 || hero.x >= 1200)
					{
						bg.speed = 0; // stop background
					}else{
						bg.speed = playerSpeed * elapsed * -1; //move background to the right
					}
					
				}else{
					hero.x -= 0; // stop player
					bg.speed = 0; // stop background
				}				
				if(hero.inverted == false)
				hero.inverted=true;
			}
			
			if (CitrusEngine.getInstance().input.isDoing("right"))
			{					
				if ((hero.x + 5) <= (_bottom.x + _bottom.width + (hero.width/2)) - _ladoDirOffset){
					hero.x += 5 * playerSpeed; // move the player to the right
										
					//// stop background
					if (hero.x <= 500 || hero.x >= 1100)
					{
						bg.speed = 0; // stop background
					}else{
						bg.speed = playerSpeed * elapsed; //move background to the left
					}
					
				}else{
					hero.x += 0; // stop player
					bg.speed = 0; // stop background
				}				
				if(hero.inverted == true)
					hero.inverted=false;
			}
			
			if (CitrusEngine.getInstance().input.isDoing("up"))
			{
				// Dont get stuck on wall when walking up on the right side
				if ((hero.x + 5) >= (_bottom.x + _bottom.width + (hero.width/2) ) - _ladoDirOffset){
					hero.x -= 5;
					bg.speed = 0; // stop background need to be fixed
				}

				// Dont get stuck on wall when walking up on the left side
				if ((hero.x + 5)  <= (_bottom.x + (hero.width/2)  ) + _ladoEsqOffset ){
					hero.x += 5;
					bg.speed = 0; // stop background need to be fixed
				}				
					if((hero.y + 5) >= _top.y ){
					hero.y -= 5 * playerSpeed;
				}else{
					hero.y-=0;
					
				}
				
			}
			if (CitrusEngine.getInstance().input.isDoing("down"))
			{	
				
				if((hero.y + (hero.height >> 1) + 5) <= (_bottom.y)){
					hero.y += 5 * playerSpeed;
				}else{
					hero.y +=0;
				}
				
			}
			//trace("hero.y" + hero.y);
			//trace("hero.x" + hero.x);
			//trace("_bottom.x" + _bottom.x);
			//trace("_bottom.y" + _bottom.y);
			//trace("_bottom.width" + _bottom.width);
			//trace("_bottom.height" + _bottom.height);
			//trace("_top.y" + _top.y);
			//trace("_top.x" + _top.x);
			//("_top.width" + _top.width);
			//trace("_top.height" + _top.height);
			//trace("OffsetEsq" + _ladoEsqOffset);
			//trace("OffsetDir" + _ladoDirOffset);
			//trace("_alturaYAtualPerc" + _alturaYAtualPerc);
			//trace("_alturaYAtual" + _alturaYAtual);
	
		}
	}
	

}