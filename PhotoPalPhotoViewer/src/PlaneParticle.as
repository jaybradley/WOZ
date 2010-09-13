package
{
	import org.cove.ape.*;
	import org.papervision3d.objects.DisplayObject3D;

	public class PlaneParticle extends RectangleParticle
	{
		private var displayObject:DisplayObject3D;
		private var shouldPaint:Boolean = true;
		
		public function PlaneParticle(displayObject:DisplayObject3D, x:Number, y:Number, width:Number, height:Number, rotation:Number=0, fixed:Boolean=false, mass:Number=1, elasticity:Number=0.3, friction:Number=0)
		{
			//trace("PlaneParticle constructed");
			super(x, y, width, height, rotation, fixed, mass, elasticity, friction);
			
			this.displayObject = displayObject;
		}
		
		// These two functions no lomnger needed due to two physics containers in the SenionCompanionInterface
		//public function temporarilyRemoveFromPhysics():void {
		//	shouldPaint = false;
		//	this.collidable = false;
		//}
		
		//public function putBackInPhysics():void {
		//	shouldPaint = true;
		//	this.collidable = true;
		//}
		
		public override function paint():void {
				displayObject.x = this.position.x;
				displayObject.y = this.position.y;
		}
		
		
	}
}