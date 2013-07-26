package screens
{
	import citrus.core.starling.StarlingState;
	import objects.Hero;
	import objects.GameBackground;
	
	public class InGame extends StarlingState
	{
		
		/** Game background object. */
		private var bg:GameBackground;
		
		/** Hero character. */		
		private var hero:Hero;
		
		public function InGame()
		{
			super();
		}
	}
}