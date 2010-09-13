package
{
	import org.cove.ape.RectangleParticle;

	public class ImmovableInvisibleParticle extends RectangleParticle
	{
		public function ImmovableInvisibleParticle(x:Number, y:Number, width:Number, height:Number, rotation:Number=0, fixed:Boolean=false, mass:Number=1, elasticity:Number=0.3, friction:Number=0)
		{
			super(x, y, width, height, rotation, true, mass, elasticity, friction);
		}
		
		//public override function paint():void {
			// Do nothing because it's invisible and imovable
		//}
		
	}
}