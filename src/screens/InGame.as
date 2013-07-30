package screens
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
	
	import objects.GameBackground;
	import objects.Hero;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import citrus.objects.CitrusSprite;
	import starling.display.Quad;
	
	public class InGame extends StarlingState
	{
		
		/** Game background object. */
		private var bg:GameBackground;
		
		/** Hero character. */		
		private var hero:Hero;
		
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
		
		
		
		// ------------------------------------------------------------------------------------------------------------
		// METHODS
		// ------------------------------------------------------------------------------------------------------------
		
		
		public function InGame()
		{
			super();
			
			// Is hardware rendering?
			isHardwareRendering = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
		}
		
		override public function initialize():void {
			
			super.initialize();
			
			drawGame();
			drawHUD();
			
			// Define keyboard interactions - moved to the Hero class
			CitrusEngine.getInstance().input.keyboard.addKeyAction("left", Keyboard.LEFT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("right", Keyboard.RIGHT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("down", Keyboard.DOWN);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("up", Keyboard.UP);

			
			// Define game area.
			gameArea = new Rectangle(200, 50, 1100, stage.stageHeight -50);
			
			
			// Define game area with a custom quad
			//var bq:Quad = new Quad(1300, 430, 0xE5E5E5);
			//do some linear gradient using VertexColor
			//bq.setVertexColor(0, 0x666666);
			//bq.setVertexColor(1, 0x666667);
			//bq.setVertexColor(2, 0x666668);
			//bq.setVertexColor(3, 0x666669);
			//add(new CitrusSprite("background", { x: 100, y: 50, width: 1300, height: 430, view: bq } ));
			
			
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
			
			_bounds = new Rectangle(0, 0, 1700, 480); //camera boundaries
			_camera = view.camera as StarlingCamera;
			_camera.setUp(hero, new Point(stage.stageWidth / 2, stage.stageHeight / 2), _bounds, new Point(0.05, 0.05));
			//_camera.allowRotation = true;
			_camera.allowZoom = true;
			
			//_camera.parallaxMode = ACitrusCamera.PARALLAX_MODE_DEPTH;
			//_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
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
			
			
			
			//set the background velocity
			
			
			if (CitrusEngine.getInstance().input.isDoing("left"))
			{	
				bg.speed = playerSpeed * elapsed * -1;
				
				hero.x -= 5 * playerSpeed;
				
				if(hero.inverted == false)
					hero.inverted=true;
			}
			if (CitrusEngine.getInstance().input.isDoing("right"))
			{	
				bg.speed = playerSpeed * elapsed;
				
				hero.x += 5 * playerSpeed;
				if(hero.inverted == true)
					hero.inverted=false;
			}
			if (CitrusEngine.getInstance().input.isDoing("up"))
			{		
				hero.y -= 5 * playerSpeed;
			}
			if (CitrusEngine.getInstance().input.isDoing("down"))
			{	
				hero.y += 5 * playerSpeed;
			}
			
			// Confine the hero to stage area limit
			if (hero.y > gameArea.bottom - hero.height * 0.5)    
			{
				hero.y = gameArea.bottom - hero.height * 0.5;
				
			}
			if (hero.y < gameArea.top + hero.height * 0.5)    
			{
				hero.y = gameArea.top + hero.height * 0.5;
			}
			if (hero.x < gameArea.left + hero.width * 0.5)    
			{
				bg.speed = 0;
				hero.x = gameArea.left + hero.width * 0.5;
			}
			if (hero.x > gameArea.right + hero.width * 0.5)    
			{
				bg.speed = 0;
				hero.x = gameArea.right + hero.width * 0.5;
			}
		}
	}
}