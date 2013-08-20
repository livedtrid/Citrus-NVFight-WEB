package nv.objects.backgrounds{
		
		import nv.util.Assets;
		
		import starling.display.Image;
		import starling.display.Sprite;
		import starling.events.Event;
				
		/**
		 * This class defines each of background layers used in the InGame screen.
		 *  
		 * @author hsharma
		 * 
		 */
		public class BgLayer extends Sprite
		{
			/** Layer identification. */
			private var _layer:int;
			
			/** Primary image. */
			private var image1:Image;
			
			/** Secondary image. */
			//private var image2:Image;
			
			/** Parallax depth - used to decide speed of the animation. */
			public var parallaxDepth:Number;
			
			public function BgLayer(_layer:int)
			{
				super();
				
				this._layer = _layer;
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
			
			/**
			 * On added to stage. 
			 * @param event
			 * 
			 */
			private function onAddedToStage(event:Event):void
			{
				this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				
				image1 = new Image(Assets.getAtlas().getTexture("bgLayer" + _layer));
				/*
				if (_layer == 1)
				{
					image1 = new Image(Assets.getTexture("BgLayer" + _layer));
					image1.blendMode = BlendMode.NONE;
					//image2 = new Image(Assets.getTexture("BgLayer" + _layer));
					//image2.blendMode = BlendMode.NONE;
				}
				else
				{
					image1 = new Image(Assets.getAtlas().getTexture("bgLayer" + _layer));
					//image2 = new Image(Assets.getAtlas().getTexture("bgLayer" + _layer));
				}
				*/
				
				image1.x = 1600 - image1.width >> 1;
				image1.y = stage.stageHeight - image1.height;
				
				//image2.x = image2.width;
				//image2.y = image1.y;
				
				this.addChild(image1);
				//this.addChild(image2);
			}
		}
	}