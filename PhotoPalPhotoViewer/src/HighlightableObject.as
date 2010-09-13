package
{
	import caurina.transitions.*;
	
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	public class HighlightableObject extends Plane
	{		
		private var type:String;
		private var belongsTo:PhotoPanel;
		private var objectsMaterial:ColorMaterial;
		private var faceID:String;
		private var scaleFactorX:Number;  
		private var scaleFactorY:Number;
		private var actualX:int;
		private var actualY:int;
		
		public function HighlightableObject(belongsTo:PhotoPanel, faceID:String, type:String, x:Number, y:Number, width:Number, height:Number) {
			super(null, belongsTo.ORIGINAL_WIDTH, belongsTo.ORIGINAL_HEIGHT, 2, 2);
			this.belongsTo = belongsTo;
			this.type = type;
			
			// Work out the scale factors for x and y
			this.scaleX = width / belongsTo.originalPhotoWidth;
			this.scaleY = height / belongsTo.originalPhotoHeight;
			
			this.x = ((-belongsTo.originalPhotoWidth / 2) + x + (width / 2)) * scaleX;
			this.y = ((belongsTo.originalPhotoHeight / 2) - y - (height / 2)) * scaleY;
			
			this.z -= 0.000001;
			this.faceID = faceID;
					
			
			objectsMaterial = new ColorMaterial();
			objectsMaterial.fillColor = 0xffffff;
			objectsMaterial.fillAlpha = 0.0;
			objectsMaterial.lineColor = 0xFF00FF;
			objectsMaterial.interactive =  true;
			this.material = objectsMaterial;
			
			this.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onObjectSelect);
			this.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, onObjectSelect);
			//this.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onObjectOut); DOES NOT WORK
			
			trace("HighlightableObject created of type " + type + " at " + x + ", " + y + " with dimensions " + width + ", " + height);
		}
		
		private function onObjectSelect(event:InteractiveScene3DEvent):void {
			//trace("Over highlightable object");
			show();
		}
		
		private function onObjectOut(event:InteractiveScene3DEvent):void { // DOES NOT WORK
			trace("Moved out of highlightable object");
			hide();
		}
		
		private function show():void {
			//objectsMaterial.fillAlpha = 0.5;
			Tweener.addTween(objectsMaterial, {fillAlpha:0.5, time:1, transition:"easeOutQuint"});
			Tweener.addTween(objectsMaterial, {fillAlpha:0.0, time:1, delay:1, transition:"easeOutQuint"});
		}
		
		private function hide():void {
			//objectsMaterial.fillAlpha = 0.0;
		}
		
		
	}
}