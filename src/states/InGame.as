package states
{
	import flash.events.Event;
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
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import objects.hero.Hero;
	import objects.objects.Enemy;
	import objects.objects.GameBackground;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;

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
		private var speedX:Number;
		private var speedY:Number;
		
		/** The power of obstacle after it is hit. */
		private var getHit:Number = 0;
		
		/** How much to shake the camera when the player get hits? */
		private var cameraShake:Number;
		
		/** Buffer */
		private var timeshifter:TimeShifter;
		private var _camera:ACitrusCamera;
		private var _bounds:Rectangle;		
		
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
		[Embed(source="assets/teo_output.png",mimeType="application/octet-stream")]
		private const _ResourcesData:Class;		
		private var _factory:StarlingFactory;
		private var _armature:Armature;
		private var dragon:Hero;// Substitui o hero depois quando ficar a funcionar
		private var isRight:Boolean;
		private var isDown:Boolean;
		private var isUp:Boolean;
		private var isLeft:Boolean;
		private var moveDirX:int;
		private var moveDirY:int;
		private var _armatureClip:Sprite;
		private var heroScale:Number;
		private var isFighting:Boolean;
		
		
		
		public function InGame()
		{
			super();
			
		// Is hardware rendering?
			isHardwareRendering = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
		}
		
		
		/** Constrains the gameArea */
		public function get alturaY():Number
		{
			return _alturaY;
		}

		/**
		 * @private
		 */
		public function set alturaY(value:Number):void
		{
			_alturaY = value;
		}

		override public function initialize():void {
			
			super.initialize();	
			
			//Dragonbones
			_factory = new StarlingFactory();
			_factory.addEventListener(Event.COMPLETE, _textureCompleteHandler);
			_factory.parseData(new _ResourcesData());
			
			moveDirX=0;
			moveDirY=0;
			
			speedX=0;
			speedY=0;
			
			//Defines the hero scale
			heroScale=0.6;
			
			// Define keyboard interactions - moved to the Hero class
			CitrusEngine.getInstance().input.keyboard.addKeyAction("left", Keyboard.LEFT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("right", Keyboard.RIGHT);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("down", Keyboard.DOWN);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("up", Keyboard.UP);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("kick", Keyboard.Z);
			CitrusEngine.getInstance().input.keyboard.addKeyAction("punch", Keyboard.X);
				
			// Define game area.
			_top 		= new Rectangle(100, 200, 1600, 20);
			_bottom  	= new Rectangle(0, 450, 1600, 20);
			_alturaY 	= _bottom.y - _top.y;
			_ladoEsq 	= _top.x - _bottom.x;
			_ladoDir 	= (_bottom.x + _bottom.width) - (_top.x + _top.width) ; 
				
			// Reset hit, camera shake and player speed.
			getHit = 0;
			cameraShake = 0;
			
			_bounds = new Rectangle(0, 0, 1600, 480); //camera boundaries
			_camera = view.camera as StarlingCamera;
			//_camera.setUp(hero, new Point(stage.stageWidth / 2, stage.stageHeight / 2), _bounds, new Point(0.05, 0.05));
			//_camera.allowRotation = true;
			_camera.allowZoom = true;
			
			//_camera.parallaxMode = ACitrusCamera.PARALLAX_MODE_TOPLEFT;
			//_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
			
			drawGame();
			drawHUD();
			
			// Reset game paused states.
			gamePaused = false;
			bg.gamePaused = false;
		}
		
		//Draonbones
		private function _textureCompleteHandler(evt:Event):void {
			
			_factory.removeEventListener(Event.COMPLETE, _textureCompleteHandler);
			
			_armature = _factory.buildArmature("teo");
			
			_armatureClip = _armature.display as Sprite;
			_armatureClip.x = stage.stageWidth >> 1;
			_armatureClip.y = stage.stageHeight >> 1;
			_armatureClip.pivotX = _armatureClip.width >> 1;
			
			// if want the character to be build on the left this value need to be negative
			_armatureClip.scaleY = _armatureClip.scaleX = heroScale;
		
			//the design wasn't made on the center registration point but close to the top left.
			dragon = new Hero("teo", {x:0, width:0, height:0, offsetY:0 / 2, view:_armatureClip, registration:"topLeft"});
			
			// dragon's initial position
			dragon.x = stage.stageWidth-100;
			dragon.y= stage.stageHeight/2;
			//_armature.animation.gotoAndPlay("walking", -1, -1, true);
					
			add(dragon);
			_camera.setUp(dragon, new Point(stage.stageWidth / 2, stage.stageHeight / 2), _bounds, new Point(0.05, 0.05));
			//_camera.allowRotation = true;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
			
			WorldClock.clock.add(_armature);			
		}
		
		private function onKeyEventHandler(e:KeyboardEvent):void
		{
			/*isDown	= CitrusEngine.getInstance().input.justDid("down");
			isUp	= CitrusEngine.getInstance().input.justDid("up");
			isLeft	= CitrusEngine.getInstance().input.justDid("left");
			isRight	= CitrusEngine.getInstance().input.justDid("right");
			*/
			
			switch (e.keyCode)
			{
				case Keyboard.A :
				case Keyboard.LEFT :
					isLeft=e.type == KeyboardEvent.KEY_DOWN;
					break;
				case Keyboard.D :
				case Keyboard.RIGHT :
					isRight=e.type == KeyboardEvent.KEY_DOWN;
					break;
				case Keyboard.S :
				case Keyboard.DOWN :
					isDown=e.type == KeyboardEvent.KEY_DOWN;
					break;
				case Keyboard.W :
				case Keyboard.UP :
					isUp=e.type == KeyboardEvent.KEY_DOWN;
					break;
				case Keyboard.X :
					kick();
					break;
				case Keyboard.Z :
					punch();
					break;
			}
						
			var dirX:int;
			var dirY:int;
			if (isLeft && isRight) 
			{
				dirX=moveDirX;
				return;
			}
			else if (isUp && isDown)
			{
				dirY=moveDirY;
				return;
			}
			else if (isLeft)
			{
				dirX=-1;
			}
			else if (isRight)
			{
				dirX=1;
			}

			else if (isUp)
			{
				dirY=-1;
			}
			else if (isDown)
			{
				dirY=1;
			}
			else
			{
				dirX=0;
				dirY=0;
			}
			
			trace("dirX==moveDirX ||dirY==moveDirY =" + dirX +moveDirX);
			if(dirX==moveDirX ||dirY==moveDirY )
			{
				return;
			}
			else
			{
				moveDirX=dirX;
				dirY=moveDirY;
			}
			trace("Pega no meu pau");
			updateBehavior();
		
			/*
			var dirY:int;
			if (isUp && isDown) 
			{
				
				dirY=moveDirY;
				return;
			}
			else if (isUp)
			{
				
				dirY=-1;
			}
			else if (isDown)
			{
				dirY=1;
			}
			else
			{
				
				dirY=0;
			}
		
			
			if(dirY==moveDirY)
			{
				return;
			}
			else
			{
					moveDirY=dirY;
			}
			
					
			updateBehavior();*/
			
			//fazer trace ao moveDirX dirX no update behavior variavel nao esta retornando a 0
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
			// Hero's initial position	
			hero.x = stage.stageWidth/2;
			hero.y = stage.stageHeight/2;
			//add(hero);
			hero.view.scaleX = hero.view.scaleY = heroScale;
			
			// Draw hero.
			enemy = new Enemy("enemy", {view:new MovieClip(Assets.getAtlas().getTextures("teoWalk"), 12)});
			//add(enemy);
				
			// Enemy's initial position
			enemy.x = stage.stageWidth-200;
			enemy.y= stage.stageHeight/2;
		}
		
		//essa função levava como parametro um starling event
		private function shakeAnimation():void
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
			
			//how much time has passed
			elapsed = timeDelta;
			
			//Update background animation
			bg.update(timeDelta);
			bg.speed = 0;
			
			//update player's movements
			updateMove();
			//call worldClock to animate armature
			WorldClock.clock.advanceTime(-1);
			

			
			/* 
			__________.__                                                  .__        __   
			\______   \  | _____  ___.__. ___________    ______ ___________|__|______/  |_ 
			|     ___/  | \__  \<   |  |/ __ \_  __ \  /  ___// ___\_  __ \  \____ \   __\
			|    |   |  |__/ __ \\___  \  ___/|  | \/  \___ \\  \___|  | \/  |  |_> >  |  
			|____|   |____(____  / ____|\___  >__|    /____  >\___  >__|  |__|   __/|__|  
			\/\/         \/             \/     \/         |__|        
			*/
											
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
					
			if(CitrusEngine.getInstance().input.justDid("punch")){
				punch();
			}
	
			if(CitrusEngine.getInstance().input.justDid("kick")){
				kick();
			}		
			

			
			trace("moveDirX" + moveDirX);
			trace("speedX" + speedX);
			
			trace("speedY =" + speedY);
			trace("moveDirY" + moveDirY);
			//trace("_alturaYAtualPerc" + _alturaYAtualPerc);
			//trace("_alturaYAtual" + _alturaYAtual);	
		}
		
		private function kick():void
		{
			_armature.animation.gotoAndPlay("kick");
		}
		
		//soco
		private function punch():void
		{
			 _armature.animation.gotoAndPlay("right punch");
			//_armature.animation.gotoAndPlay("left punch");
		}
		
		private function updateMove():void
		{
			
			if(speedX !=0)
			{
				dragon.x += speedX;
			}
			
			if(speedY !=0)
			{
				dragon.y += speedY;
			}
		}	
		
		private function updateBehavior():void 
		{
			if (isFighting)
			{
				//return;
			}
			if (moveDirX == 0 && moveDirY == 0)
			{
				speedX = 0;
				speedY = 0;
				_armature.animation.gotoAndPlay("stand", -1, -1, true);
			}
			else
			{
				speedX=5*moveDirX;
				speedY=5*moveDirY;
				
				_armature.animation.gotoAndPlay("walking", -1, -1, true);
				if(isRight)
					dragon.inverted = false;
				if(isLeft)
					dragon.inverted = true;
			}
		}
	}
}