package states
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.TimeShifter;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import core.Assets;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.events.AnimationEvent;
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
		private var playerSpeed:Number; // this will be the player actual speed
		private var speedX:Number;
		private var speedY:Number;
		
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
		private var heroIsAdded:Boolean=false;
		private var _isAttacking:Boolean;
		
		
		
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
			_factory.parseData(new _ResourcesData());
			
			// Set the player speed 
			playerSpeed = 1.5;
			
			moveDirX=0;
			moveDirY=0;
			
			speedX=0;
			speedY=0;
			
			//Defines the hero scale
			heroScale=0.6;

			// Define game area.
			_top 		= new Rectangle(250, 200, 1100, 20);
			_bottom  	= new Rectangle(0, 450, 1600, 20);
			_alturaY 	= _bottom.y - _top.y;
			_ladoEsq 	= _top.x - _bottom.x;
			_ladoDir 	= (_bottom.x + _bottom.width) - (_top.x + _top.width) ;

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
			_armature.animation.timeScale = 0.8;
			
			_armatureClip = _armature.display as Sprite;
			_armatureClip.x = stage.stageWidth >> 1;
			_armatureClip.y = stage.stageHeight >> 1;
			_armatureClip.pivotX = _armatureClip.width >> 1;
			
			// if want the character to be build on the left this value need to be negative
			_armatureClip.scaleY = _armatureClip.scaleX = heroScale;
		
			//the design wasn't made on the center registration point but close to the top left.
			dragon = new Hero("teo", {x:0, width:_armatureClip.width, height:_armatureClip.height, offsetY:0 / 2, view:_armatureClip, registration:"topLeft"});
			
			// dragon's initial position
			dragon.x = 800;
			dragon.y= 300;
			_armature.animation.gotoAndPlay("stand", -1, -1, true);
			add(dragon);
			
			WorldClock.clock.add(_armature);
			
			heroIsAdded=true;
			_camera.setUp(dragon, new Point(stage.stageWidth / 2, stage.stageHeight / 2), _bounds, new Point(0.05, 0.05));
					
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
			
			if (isLeft && isRight||_isAttacking) 
			{
				dirX=0;
				moveDirX=0;
				//dirX=moveDirX;
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
			
			//Draw enemy
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
		
		
		private function animationHandler(e:AnimationEvent):void 
		{
			
			switch(e.type)
			{
				case AnimationEvent.MOVEMENT_CHANGE:
					//_isAttacking = false;
					trace("MOVEMENT_CHANGE");
					break;
				case AnimationEvent.COMPLETE:
					trace("COMPLETE");
					_isAttacking = false;
					updateBehavior();//return to stand animation
					break;
			}
			trace("_isAttacking =" + _isAttacking);
			
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
			_isAttacking=true;
			
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
			}
			
			if(heroIsAdded)
			{
				// Confine the hero to stage area limit			
				// Height
				_alturaYAtual 		= (dragon.y - dragon.height >> 1 ) - (_top.y); // verificar a altura do rect
				_alturaYAtualPerc 	= (_alturaYAtual * 100)/_alturaY;
			
				// Left side
				_ladoEsqOffset		=(_ladoEsq*_alturaYAtualPerc) / 100;
				_ladoEsqOffset		= -(_ladoEsqOffset-100);
				
				// Right side
				_ladoDirOffset		=(_ladoDir*_alturaYAtualPerc) / 100;
				_ladoDirOffset		= -(_ladoDirOffset-100);			
				

				if(speedX !=0)
				{		
					if(dragon.x >= 500 && dragon.x <= 1100)
					{
						bg.speed=speedX * 0.01;
					}else{
						bg.speed=0;
					}
					
				
					
					if (dragon.x + 5  > _bottom.x + (dragon.width/2) +_ladoEsqOffset&&isLeft)
					{
						dragon.x += speedX;
						
					}
					else if((dragon.x + 5) < (_bottom.x + _bottom.width + (dragon.width/2)) - _ladoDirOffset&&isRight)
					{
						dragon.x += speedX;
					}else
					{
						dragon.x += 0;
						bg.speed=0;
					}
					
				}
				
				if(speedY !=0)
				{
					if((dragon.y + 5) >= _top.y &&isUp)
					{
						if (dragon.x + 5  > _bottom.x + (dragon.width/2) +_ladoEsqOffset){
							dragon.x -= 5;
						}
						
						if ((dragon.x + 5) < (_bottom.x + _bottom.width + (dragon.width/2)) - _ladoDirOffset){
							dragon.x += 5;
						}
						
						dragon.y += speedY;
						
					}
					else if((dragon.y + 5) <= (_bottom.y)&&isDown ){
						dragon.y += speedY;
					}
					else
					{
						dragon.y += 0;
					}				
				}
			}
		}	
		
		private function updateBehavior():void 
		{
			if (_isAttacking)
			{
				return;
			}
			if (moveDirX == 0 && moveDirY == 0)
			{
				speedX = 0;
				speedY = 0;
				
				_armature.animation.gotoAndPlay("stand", -1, -1, true);
			}	
			else
			{
				speedX=playerSpeed*moveDirX;
				speedY=playerSpeed*moveDirY;
				
				_armature.animation.gotoAndPlay("walking", -1, -1, true);
				if(isRight)
					dragon.inverted = false;
				if(isLeft)
					dragon.inverted = true;
			}
		}	
	}
}