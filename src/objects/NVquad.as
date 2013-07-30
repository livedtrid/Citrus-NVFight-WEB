package objects
{
	import starling.display.Quad;
	import starling.utils.VertexData;

	public class NVquad extends Quad
	{
		public function NVquad(width:Number, height:Number, topleft:Number, topright:Number, color:uint=0xffffff,premultipliedAlpha:Boolean=true) 
		{
			
			
			super(width, height,color,premultipliedAlpha);
			
			//mTinted = color != 0xffffff;
			
			mVertexData = new VertexData(4, premultipliedAlpha);
			mVertexData.setPosition(0, topleft, 0.0);
			mVertexData.setPosition(1, width, topright);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height); 
			mVertexData.setUniformColor(color);
			
			onVertexDataChanged();
		}
	}
}