package {
	
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	
	public class Frame extends Plane {
		
		private var seniorCompanionInterface:PhotoPalPhotoViewerApplication;
		private var selectedMaterial:BitmapFileMaterial;
		private var noSelectedMaterial:BitmapFileMaterial;
		
		private var frames:Array;
		private var frameIndex:int = 0;
		
		//private const FRAME_WIDTH:int = 5650;
		//private const FRAME_HEIGHT:int = 3750;
		private const FRAME_WIDTH:int = 3800;
		private const FRAME_HEIGHT:int = 2625;
		
		public function Frame(seniorCompanionInterface:PhotoPalPhotoViewerApplication):void {
			this.seniorCompanionInterface = seniorCompanionInterface;
			
			frames = new Array();
			frames.push(new BitmapFileMaterial(seniorCompanionInterface.IMAGES_URI + "newFrameWhiteBorder.png"));
			//frames.push(new BitmapFileMaterial(seniorCompanionInterface.IMAGES_URI + "newFrameNoBlackBorder.png"));
			//frames.push(new BitmapFileMaterial(seniorCompanionInterface.IMAGES_URI + "newFrame.png"));
			/*frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/test1.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/frame4.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/frame2.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/frame3.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/frameEmpty.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/0.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/1.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/2.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/3.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/4.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/5.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/6.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/7.png"));
			frames.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/frames/8.png"));*/
			
			//selectedMaterial = new BitmapFileMaterial("graphics/frame4.png");
			//noSelectedMaterial = new BitmapFileMaterial("graphics/frame4.png");
			//material = noSelectedMaterial;
			
			material = frames[frameIndex];
			
			super(material, FRAME_WIDTH, FRAME_HEIGHT);
			this.z = -0;
			this.y = -100;
		}
		
		public function changeFrame():void {
			frameIndex++;
			if(frameIndex >= frames.length) {
				frameIndex = 0;
			}
			material = frames[frameIndex];
		}
		
		public function noSelectedPhoto():void {
			//this.material = noSelectedMaterial;
		}
		
		public function selectedPhoto():void {
			//this.material = selectedMaterial;
		}
	}
}