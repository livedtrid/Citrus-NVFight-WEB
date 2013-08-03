package screens
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.TimeShifter;
	import citrus.objects.CitrusSprite;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import core.Assets;
	
	import objects.GameBackground;
	import objects.Hero;
	import objects.NVquad;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.display.Shape;

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
		
		private var bq:NVquad;
		private var _quadWidth:int;
		private var _quadHeight:int;
		private var _quadTopLeft:int;
		private var _quadTopRight:int;

		// ------------------------------------------------------------------------------------------------------------
		// METHODS
		// ------------------------------------------------------------------------------------------------------------
		private var myQuad:CitrusSprite;
		private var _top:Rectangle;
		private var _bottom:Rectangle;
		private var rectangle:Shape;
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
			_top 		= new Rectangle(250, 200, 1100, 20);
			_bottom  	= new Rectangle(50, 450, 1500, 20);
			_alturaY 	= _bottom.y - _top.y;
			_ladoEsq 	= _top.x - _bottom.x;
			_ladoDir 	= (_bottom.x + _bottom.width) - (_top.x + _top.width) ; 
			
			
			rectangle = new Shape; // initializing the variable named rectangle
			rectangle.graphics.beginFill(0xFF0000); // choosing the colour for the fill, here it is red
			rectangle.graphics.drawRect(300, 200, 900,20); // (x spacing, y spacing, width, height)
			rectangle.graphics.endFill(); // not always needed but I like to put it in to end the fill
			//addChild(rectangle); // adds the rectangle to the stage
			
			
			// Define game area with a custom quad
			//_quadWidth = 1600;
			//_quadHeight = 294;
			//_quadTopLeft = 254;
			//_quadTopRight = 1346;
			
			//bq = new NVquad(_quadWidth, _quadHeight, _quadTopLeft, _quadTopRight, 0xE5E5E5);
			//gameArea = bq.getBounds(bq);
			//draw the quad
			//myQuad = new CitrusSprite("quad", { x: 0, y: 180, width: 1600, height: 294, view: bq } )
			//add(myQuad);
			//add(new CitrusSprite("background", { x: 0, y: 180, width: 1600, height: 294, view: bq } ));
			//_alturaY 			= (myQuad.y + myQuad.height) - myQuad.y; // constrains player in height
			// LATERAL ESQUERDA
			//_ladoEsq			= _quadTopLeft - myQuad.x;  //
			// LATERAL DIREITA
			//_ladoDir			= (myQuad.x + myQuad.width) - (_quadTopRight) ;  // pode ser colocado no inicio
			

						
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
						
			// Confine the hero to stage area limit
			
			// Height
			_alturaYAtual 		= hero.y - _top.top; // verificar a altura do quad
			_alturaYAtualPerc 	= (_alturaYAtual * 100)/_alturaY;
			
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
					bg.speed = playerSpeed * elapsed * -1; //move background to the right
				}else{
					hero.x -= 0; // stop player
					bg.speed = 0; // stop background
				}				
				if(hero.inverted == false)
				hero.inverted=true;
			}
			
			if (CitrusEngine.getInstance().input.isDoing("right"))
			{	
				
				if ((hero.x + 5)+ (hero.width)  <= (_bottom.x + _bottom.width ) - _ladoDirOffset){
					hero.x += 5 * playerSpeed; // move the player to the right
					bg.speed = playerSpeed * elapsed; //move background to the left
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
				if ((hero.x + 5)+ (hero.width)  >= (_bottom.x + _bottom.width ) - _ladoDirOffset){
					hero.x -= 5;
					bg.speed = 0; // stop background need to be fixed
				}

				// Dont get stuck on wall when walking up on the left side
				if ((hero.x + 5)  <= (_bottom.x + (hero.width/2)  ) + _ladoEsqOffset ){
					hero.x += 5;
					bg.speed = 0; // stop background need to be fixed
				}
	
				
					if((hero.y + (hero.height >> 1) - 5) >= _top.top ){
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

			/*			
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
			*/
			trace("hero.y" + hero.y);
			trace("hero.x" + hero.x);
			trace("_bottom.x" + _bottom.x);
			trace("_bottom.y" + _bottom.y);
			trace("_bottom.width" + _bottom.width);
			trace("_bottom.height" + _bottom.height);
			trace("_top.y" + _top.y);
			trace("_top.x" + _top.x);
			trace("_top.width" + _top.width);
			trace("_top.height" + _top.height);
			trace("OffsetEsq" + _ladoEsqOffset);
			trace("OffsetDir" + _ladoDirOffset);	
	
		}
	}
}