package nv.states
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
	import citrus.view.ACitrusCamera;
	import citrus.view.spriteview.SpriteArt;
	import citrus.view.starlingview.StarlingCamera;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.events.AnimationEvent;
	import dragonBones.factorys.StarlingFactory;
	
	import nv.objects.backgrounds.GameBackground;
	import nv.objects.enemies.Enemy;
	import nv.objects.hero.Hero;
	import nv.util.Assets;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;

	public class InGame extends StarlingState
	{		
		/** Game background object. */
		private var bg:GameBackground;
		
		/** Hero character. */
		private var hero:Hero;
	
		/** Player state. */		
		private var gameState:int;
		
		/** Player's speed. */
		private var playerSpeed:Number; // this will be the player actual speed
		private var speedX:Number;
		private var speedY:Number;
		
		/** Dragonbones  */
		private var _factory:StarlingFactory;
		private var _armature:Armature;
		private var _armatureClip:Sprite;
		
		/** Player's direction */
		private var isRight:Boolean=false;
		private var isDown:Boolean=false;
		private var isUp:Boolean=false;
		private var isLeft:Boolean=false;
		
		/** Dragonbones  */
		private var moveDirX:int;
		private var moveDirY:int;
		
		/** Scale of character  */
		private var heroScale:Number;
		
		private var heroIsAdded:Boolean=false;
		private var _isAttacking:Boolean;
		
		/** Time calculation for animation. */
		private var elapsed:Number;
		
		/** Enemy character */
		private var enemy:Enemy;
		
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
		
		/** How much to shake the camera when the player get hits? */
		private var cameraShake:Number;
		
		/** Camera and game boundaries */
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

		// Rectangles
		private var _top:Rectangle;
		private var _bottom:Rectangle;
		
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
			
			//Dragonbones
			_factory = new StarlingFactory();
			_factory.addEventListener(Event.COMPLETE, _textureCompleteHandler);
			_factory.parseData(new Assets.HeroTeoData());
			
			// Set the player speed 
			playerSpeed = 1.25;
			
			moveDirX=0;
			moveDirY=0;
			
			speedX=0;
			speedY=0;
			
			//Defines the hero scale
			heroScale=0.6;

			// Define game area.
			_top 		= new Rectangle(300, 250, 1000, 20);
			_bottom  	= new Rectangle(60, 450, 1480, 20);
			_alturaY 	= _bottom.y - _top.y;
			_ladoEsq 	= _top.x - _bottom.x;
			_ladoDir 	= (_bottom.x + _bottom.width) - (_top.x + _top.width);
			

			
			// Reset hit, camera shake
			cameraShake = 0;
			
			_bounds = new Rectangle(0, 0, 1600, 480); //camera boundaries
			_camera = view.camera as StarlingCamera;
			//_camera.allowRotation = true;
			_camera.allowZoom = true;
			
			//_camera.parallaxMode = ACitrusCamera.PARALLAX_MODE_TOPLEFT;
			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
			
			drawGame();
			drawHUD();
			
			// Reset game paused states.
			gamePaused = false;
			bg.gamePaused = false;
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
		}
		
		//Draonbones
		private function _textureCompleteHandler(evt:Event):void {
			
			_factory.removeEventListener(Event.COMPLETE, _textureCompleteHandler);
			
			_armature = _factory.buildArmature("teo");
			//Set animation speed
			_armature.animation.timeScale = 0.9;
			//_armature.colorTransform.color = 0x112233;
			
			_armatureClip = _armature.display as Sprite;
			
			// if want the character to be build on the left this value need to be negative
			_armatureClip.scaleY = _armatureClip.scaleX = heroScale;
		
			hero = new Hero("teo", {x:0, width:_armatureClip.width, height:_armatureClip.height, view:_armatureClip, registration:"center"});
			
			// hero's initial position
			hero.x = 800;
			hero.y= 300;
		
			_armature.animation.gotoAndPlay("stand", -1, -1, true);
			add(hero);
						
			WorldClock.clock.add(_armature);
			
			heroIsAdded=true;
			_camera.setUp(hero, new Point(stage.stageWidth / 2, stage.stageHeight / 2), _bounds, new Point(0.05, 0.05));
					
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
			
			_armature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, animationHandler);
			_armature.addEventListener(AnimationEvent.COMPLETE, animationHandler);
								
		}
		
		private function onKeyEventHandler(e:KeyboardEvent):void
		{			
			switch (e.keyCode)
			{
				case Keyboard.X :
					kick();
					break;
				case Keyboard.Z :
					punch();
					break;
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
			}
	
			var dirX:int;
			var dirY:int;
			if(_isAttacking){
				
				moveDirX=0;
				moveDirY=0;
				
				return;
			}
			if (isLeft && isRight) 
			{
				dirX=moveDirX;
				
				if(dirX==1)
					isLeft=false;
				if(dirX==0)
					isRight=false;
				
				return;
			}
			else if (isLeft)
			{
				dirX=-1;
			}
			else if (isRight)
			{
				dirX=1;
			}else
			{
				dirX=0;
			}
			
			if (isUp && isDown) 
			{
				dirY=moveDirY;
				return;
			}else if (isUp)
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
			
			if(dirX==moveDirX && dirY==moveDirY)
			{
				return;
			}
			else
			{
				moveDirX=dirX;
				moveDirY=dirY;				
			}
			updateBehavior();
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
		
		
		private function animationHandler(e:AnimationEvent):void 
		{
			
			switch(e.type)
			{
				case AnimationEvent.MOVEMENT_CHANGE:
					//_isAttacking = false;
					if(_isAttacking)
						updateBehavior();
					break;
				case AnimationEvent.COMPLETE:
					//updateBehavior();//return to stand animation
					_isAttacking = false;
					break;
			}
		} 

		
		private function kick():void
		{
			if(_isAttacking)
			{
				return;
			}
			_isAttacking=true;
			_armature.animation.gotoAndPlay("kick");
		}
		
		//soco
		private function punch():void
		{
			if(_isAttacking)
			{
				return;
			}
			_isAttacking = true;
			
			var punchType:Number=Math.ceil(Math.random()*2);
			if(punchType==1)
			 _armature.animation.gotoAndPlay("right punch");
			if(punchType==2)
			_armature.animation.gotoAndPlay("left punch");
		}		
		
		//Update the hero's movements
		private function updateMove():void
		{	
			if(_isAttacking){
				return;
			//	_isAttacking=false;
				//updateBehavior();
			}			
			if(heroIsAdded)
			{
				// Confine the hero to stage area limit			
				// Height
				_alturaYAtual 		= hero.y - _top.y; // verificar a altura do rect
				_alturaYAtualPerc 	= (_alturaYAtual * 100)/_alturaY;
			
				// Left side
				_ladoEsqOffset		=(_ladoEsq*_alturaYAtualPerc) / 100;
				_ladoEsqOffset		= -(_ladoEsqOffset-200);
				
				// Right side
				_ladoDirOffset		=(_ladoDir*_alturaYAtualPerc) / 100;
				_ladoDirOffset		= -(_ladoDirOffset-200);			
				
				//constrains player movement in gamearea X axis	
				if(speedX !=0)
				{		
					//Move background
					if(hero.x >= 500 && hero.x <= 1100)
					{
						bg.speed=speedX * 0.01;
					}else{
						bg.speed=0;
					}
							
					if (hero.x - hero.width > _bottom.x +_ladoEsqOffset&&isLeft || hero.x + hero.width < (_bottom.x + _bottom.width)  - _ladoDirOffset&&isRight)
					{
						
						hero.x += speedX;
						
					}else
					{
						hero.x += 0;
						bg.speed=0;
					}
					
				}
				
				//constrains player movement in gamearea Y axis	
				if(speedY !=0)
				{
					if(hero.y  > _top.y &&isUp)
					{
						if (hero.x - hero.width > _bottom.x +_ladoEsqOffset){
							hero.x -= playerSpeed;
						}
						
						if (hero.x + hero.width < (_bottom.x + _bottom.width)  - _ladoDirOffset){
							hero.x += playerSpeed;
						}
						
						hero.y += speedY;						
					}
					else if(hero.y  - hero.height/2 < _bottom.y&&isDown ){
						hero.y += speedY;
					}
					else
					{
						hero.y += 0;
					}				
				}			
			}
		}	
		
		private function updateBehavior():void 
		{		
			if (_isAttacking)
			{	
				//_isAttacking = false;	
				return;
			}
			if (moveDirX == 0 && moveDirY == 0)
			{
				speedX=0;
				speedY=0;
				_armature.animation.gotoAndPlay("stand", -1, -1, true);
			}	
			else
			{	
				
				trace("moveDirX" +moveDirX);
				trace("moveDirY" +moveDirY);
				
				speedX=playerSpeed*moveDirX;
				speedY=playerSpeed*moveDirY;
				_armature.animation.gotoAndPlay("walking", -1, 0, true);
				
				//Change the facing direction of the player
				//_armatureClip.scaleX = moveDirX * heroScale;
				//trace("_armatureClip.width= " + _armatureClip.width);
				//trace("hero.width= " + hero.width);
								
				if(isRight)
					hero.inverted = false;
				if(isLeft)
					hero.inverted = true;
				
				
				
				

			}
		}	
	}
}