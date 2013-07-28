package screens
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.TimeShifter;
	
	import core.Assets;
	
	import objects.GameBackground;
	import objects.Hero;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	
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
			
			// Define keyboard interactions
			CitrusEngine.getInstance().input.keyboard.addKeyAction("left", Keyboard.LEFT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("right", Keyboard.RIGHT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("down", Keyboard.DOWN);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("up", Keyboard.UP);

			
			// Define game area.
			gameArea = new Rectangle(0, 100, stage.stageWidth, stage.stageHeight - 250);
			
			// Reset hit, camera shake and player speed.
			getHit = 0;
			cameraShake = 0;
			playerSpeed = 1;
			
			// Hero's initial position
			hero.x = stage.stageWidth/2;
			hero.y = stage.stageHeight/2;
			
			// Reset game paused states.
			gamePaused = false;
			bg.gamePaused = false;
			
			// we register a buffer of 20 seconds.
			timeshifter = new TimeShifter(20);
			
			
			// Setup Camera
			timeshifter.addBufferSet( { object:hero.camTarget, continuous:["x", "y"] } );
			
			view.camera.setUp(hero, new Point(stage.stageWidth / 2  , stage.stageHeight / 2 ),
				new Rectangle(0, 0, 2400, 1200), new Point(.25, .25));
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
			hero = new Hero("hero", {view:new MovieClip(Assets.getAtlas().getTextures("teoWalk"), 8)});
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
			/*
			if (CitrusEngine.getInstance().input.justDid("left"))
			{	
					//walkLeft=true
					//walkRight=false
				hero.x -= 5 * playerSpeed;
			}
			if (CitrusEngine.getInstance().input.justDid("right"))
			{	
				hero.x += 5 * playerSpeed;
			}
			if (CitrusEngine.getInstance().input.justDid("up"))
			{		
				hero.y -= 5 * playerSpeed;
			}
			if (CitrusEngine.getInstance().input.justDid("down"))
			{	
				hero.y += 5 * playerSpeed;
			}
			*/
				
		}
	}
}