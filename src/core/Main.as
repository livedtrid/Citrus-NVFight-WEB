package core
{

	import citrus.core.starling.StarlingCitrusEngine;
	
	import starling.events.Event;
	
	import states.InGame;
	
	
	[SWF(frameRate="60", width="800", height="480", backgroundColor="0x000000")]
	public class Main extends StarlingCitrusEngine
	{
		public function Main()
		{
			
			setUpStarling(true);
		}
		
		override protected function _context3DCreated(evt:Event):void {
			
			super._context3DCreated(evt);
			
			state = new InGame();
		}
	}
}