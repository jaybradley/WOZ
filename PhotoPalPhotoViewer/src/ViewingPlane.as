package
{
	import caurina.transitions.*;
	
	import flash.events.*;
	import flash.net.SharedObject;
	
	import mx.core.Application;
	
	import org.cove.ape.*;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.*;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	import uk.ac.napier.Red5.*;

	public class ViewingPlane extends Plane {
		
		private var velocityX:Number = 0;
		private var velocityY:Number = 0;
		private var oldMouseX:Number = 0;
		private var oldMouseY:Number = 0;
		
		private var mouseDown:Boolean = false;
		private var mouseOver:Boolean = false;
		
		public var particle:PlaneParticle;
		
		private var backgrounds:Array;
		private var backgroundIndex:int = 0;
		
		private var topBoundaryParticle:ImmovableInvisibleParticle;
		private var bottomBoundaryParticle:ImmovableInvisibleParticle;
		private var leftBoundaryParticle:ImmovableInvisibleParticle;
		private var rightBoundaryParticle:ImmovableInvisibleParticle;
		
		private var topViewingPlaneBoundaryParticle:ImmovableInvisibleParticle;
		private var bottomViewingPlaneBoundaryParticle:ImmovableInvisibleParticle;
		private var leftViewingPlaneBoundaryParticle:ImmovableInvisibleParticle;
		private var rightViewingPlaneBoundaryParticle:ImmovableInvisibleParticle;
		
		private var parentApplication:PhotoPalPhotoViewerApplication;
		
		private var vx:Number = 0.0;
		private var vy:Number = 0.0;
		
		private var red5SharedObject:SharedObject;
		
		// Constants
		public const WIDTH:int =  20000;//6000;
		public const HEIGHT:int = 18000;//4000;
		private const FRICTION:Number = 0.5;
		private const DEPTH_OF_BOUNDARY_BLOCKS:int = 500;
		
		private const WIDTH_OF_BORDERS:int = 1000;//200;
		private const HEIGHT_OF_BORDERS:int = 1000;//200;
		
		private const WIDTH_PER_PHOTO:int = 900;
		private const RATIO:Number = 0.6;
		
		public function ViewingPlane(parentApplication:PhotoPalPhotoViewerApplication, numberOfPhotos:int, material:MaterialObject3D=null, width:Number=0, height:Number=0, segmentsW:Number=0, segmentsH:Number=0, initObject:Object=null) {
			trace("PhotoHolderPlane constructed");
			
			this.parentApplication = parentApplication;
			
			backgrounds = new Array();
			//backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/originalBackground.jpg"));
			//backgrounds.push(new BitmapFileMaterial("images/backgrounds/stickyBackground.jpg"));
			backgrounds.push(new BitmapFileMaterial(parentApplication.IMAGES_URI + "stickyBackground.jpg"));
			
			//backgrounds.push(new BitmapFileMaterial("images/backgrounds/newspaper.jpg"));			//*YL*
			
			//backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/originalBackground.jpg"));
			//backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/1.jpg"));
			//backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/2.jpg"));
			/*backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/3.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/4.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/5.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/6.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/7.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/8.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/9.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/10.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/11.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/12.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/13.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/14.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/15.jpg"));
			backgrounds.push(new BitmapFileMaterial("../../../../../resources/NapierInterface/images/backgrounds/16.jpg"));*/
			
			material = backgrounds[backgroundIndex];
			//material = new BitmapFileMaterial("graphics/swirlyBackground.jpg");
			material.interactive = true;
			//material.smooth = true;
			
			super(material, WIDTH, HEIGHT, segmentsW, segmentsH, initObject);
			moveForward(5000);
			//scaleY = 2;
			//scaleX = 2;
			//trace("The ViewingPlane will be " + Math.max(WIDTH, numberOfPhotos * WIDTH_PER_PHOTO) + ", " + Math.max(HEIGHT, numberOfPhotos * WIDTH_PER_PHOTO * RATIO) + " in size for " + numberOfPhotos + " photos");
			//super(material, Math.max(WIDTH, numberOfPhotos * WIDTH_PER_PHOTO), Math.max(HEIGHT, numberOfPhotos * WIDTH_PER_PHOTO * RATIO), segmentsW, segmentsH, initObject);
			
			particle = new PlaneParticle(this, x ,y, WIDTH, HEIGHT, rotationZ, false, 2, 0.3, FRICTION);
			
			// Boundary for the viewing plane i.e. the edge of the world
			topBoundaryParticle = new ImmovableInvisibleParticle(0, HEIGHT - 4000, WIDTH, 0);
			bottomBoundaryParticle = new ImmovableInvisibleParticle(0, -HEIGHT + 3200, WIDTH, 0);
			leftBoundaryParticle = new ImmovableInvisibleParticle(-WIDTH + 5450, 0, 0, HEIGHT);
			rightBoundaryParticle = new ImmovableInvisibleParticle(WIDTH - 5450, 0, 0, HEIGHT);
			/*topBoundaryParticle = new ImmovableInvisibleParticle(0, HEIGHT - 1100, WIDTH, 0);
			bottomBoundaryParticle = new ImmovableInvisibleParticle(0, -HEIGHT + 1100, WIDTH, 0);
			leftBoundaryParticle = new ImmovableInvisibleParticle(-WIDTH + 1500, 0, 0, HEIGHT);
			rightBoundaryParticle = new ImmovableInvisibleParticle(WIDTH - 1500, 0, 0, HEIGHT);*/
			
			this.parentApplication.addToGlobalPhysics(particle);
			
			this.parentApplication.addToGlobalPhysics(topBoundaryParticle);
			this.parentApplication.addToGlobalPhysics(bottomBoundaryParticle);
			this.parentApplication.addToGlobalPhysics(leftBoundaryParticle);
			this.parentApplication.addToGlobalPhysics(rightBoundaryParticle);
			
			// Boundary of the viewing plane. So photos don't fall over the edge of the viewing plane
			topViewingPlaneBoundaryParticle = new ImmovableInvisibleParticle(0, (DEPTH_OF_BOUNDARY_BLOCKS / 2) + (HEIGHT / 2), WIDTH, DEPTH_OF_BOUNDARY_BLOCKS);
			bottomViewingPlaneBoundaryParticle = new ImmovableInvisibleParticle(0, -(HEIGHT / 2) - (DEPTH_OF_BOUNDARY_BLOCKS / 2), WIDTH, DEPTH_OF_BOUNDARY_BLOCKS);
			leftViewingPlaneBoundaryParticle = new ImmovableInvisibleParticle(-(WIDTH / 2) - (DEPTH_OF_BOUNDARY_BLOCKS / 2), 0, DEPTH_OF_BOUNDARY_BLOCKS, HEIGHT);
			rightViewingPlaneBoundaryParticle = new ImmovableInvisibleParticle((DEPTH_OF_BOUNDARY_BLOCKS / 2) + (WIDTH / 2), 0, DEPTH_OF_BOUNDARY_BLOCKS, HEIGHT);
			
			this.parentApplication.addToViewingPlanePhysics(topViewingPlaneBoundaryParticle);
			this.parentApplication.addToViewingPlanePhysics(bottomViewingPlaneBoundaryParticle);
			this.parentApplication.addToViewingPlanePhysics(leftViewingPlaneBoundaryParticle);
			this.parentApplication.addToViewingPlanePhysics(rightViewingPlaneBoundaryParticle);
										
			setUpListeners();
			
			particle.addMasslessForce(new Vector(Math.floor(Math.random() * 500) + 200, Math.floor(Math.random() * 500) + 200)); // random starting movement
			
			// Join Red5
			joinRed5();
			
			//start render loop
	        mx.core.Application.application.addEventListener(Event.ENTER_FRAME, render);
		}
		
		private function joinRed5():void {
			
			red5SharedObject = SharedObject.getRemote("viewingPlane" + "_" + this.parentApplication.sessionName, parentApplication.red5NetConnection.uri, true);
			red5SharedObject.clear();
			red5SharedObject.fps = 3;
	
			// Set initial Red5 values
			//red5SharedObject.data.who = parentApplication.who;
			//red5SharedObject.setDirty("who");
			red5SharedObject.data.positionX = particle.px;
			red5SharedObject.setDirty("positionX");
			red5SharedObject.data.positionY = particle.py;
			red5SharedObject.setDirty("positionY");
			//red5SharedObject.setDirty("position");
			

			red5SharedObject.addEventListener(SyncEvent.SYNC, red5OnSync);	
			red5SharedObject.connect(parentApplication.red5NetConnection);
	
		}
		
		private function red5OnSync(event:SyncEvent):void {
			
			for(var i:int = 0; i < event.changeList.length; i++) {
				//trace("changed[" + i + "] " + event.changeList[i].name + ", code = " + event.changeList[i].code + ", oldValue = " + event.changeList[i].oldValue);
				
				if((event.changeList[i].name == "positionX") && (red5SharedObject.data.whoMoved != parentApplication.who)) {
					particle.px = red5SharedObject.data.positionX;
				}
				if((event.changeList[i].name == "positionY") && (red5SharedObject.data.whoMoved != parentApplication.who)) {
					particle.py = red5SharedObject.data.positionY;
				}
				
			}
			
			
			// if someone else made the changes we should update our settings
			//if(red5SharedObject.data.who != parentApplication.who) {
			//	trace("Syncing position");
			//	particle.px = red5SharedObject.data.position.x;
			//	particle.py = red5SharedObject.data.position.y; 
			//	
			//}

		}
		
		public function changeBackground():void {
			backgroundIndex++;
			if(backgroundIndex >= backgrounds.length) {
				backgroundIndex = 0;
			}
			material = backgrounds[backgroundIndex];
			material.interactive = true;
		}
		
		private function setUpListeners():void {
			this.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, onPress);
			mx.core.Application.application.addEventListener(MouseEvent.MOUSE_UP, onGlobalMouseRelease);
		}
		
		private function onPress(event:InteractiveScene3DEvent):void {
			//trace("Photo plane pressed");
			mouseDown = true;
			
			// Deselect any selected photos
			parentApplication.deselectAllPhotos();	// Should check if in news mode first
			
			
			vx = 0.0;
			vy = 0.0;
			
			oldMouseX = parentApplication.mouse3D.x;
			oldMouseY = parentApplication.mouse3D.y;
		}
		
		private function onGlobalMouseRelease(event:MouseEvent):void {
			
			if(mouseDown) {
				//trace("Throwing PhotoPlane");
				throwThis();
				mouseDown = false;
			}
		}
		
		private function throwThis():void {
			// Add force equal to the current velocity
			//photoPlaneParticle.addMasslessForce(new Vector(parentApplication.mouse3D.x - oldMouseX, parentApplication.mouse3D.y - oldMouseY).mult(10));
			particle.addMasslessForce(new Vector(vx, vy).mult(10));
		}
				
		private function render(event:Event):void {
			
			if(mouseDown) {
				
				// Update red5 if the user has moved this panel
				if(((parentApplication.mouse3D.x - oldMouseX) != 0) || ((parentApplication.mouse3D.y - oldMouseY) != 0)) {
					red5SharedObject.data.whoMoved = parentApplication.who;
					red5SharedObject.setDirty("whoMoved");
					red5SharedObject.data.positionX = particle.px;
					red5SharedObject.setDirty("positionX");
					red5SharedObject.data.positionY = particle.py;
					red5SharedObject.setDirty("positionY");
					
				}
				
				//photoPlaneParticle.position.setTo(parentApplication.mouse3D.x, parentApplication.mouse3D.y);
				//this.x = parentApplication.mouse3D.x;
				//this.y = parentApplication.mouse3D.y;
				
				particle.px += parentApplication.mouse3D.x - oldMouseX;
				particle.py += parentApplication.mouse3D.y - oldMouseY;
				
				//trace("deltaX = " + (parentApplication.mouse3D.x - oldMouseX) + ", deltaY = " + (parentApplication.mouse3D.y - oldMouseY)); 
								
								
				vx = (vx - (oldMouseX - parentApplication.mouse3D.x)) * FRICTION;
				vy = (vy - (oldMouseY - parentApplication.mouse3D.y)) * FRICTION;
				
				oldMouseX = parentApplication.mouse3D.x;
				oldMouseY = parentApplication.mouse3D.y;
			}
			
			// Update red5 if the  panel is sliding
			if((particle.velocity.x > 0.01) || (particle.velocity.y > 0.01)) {
				red5SharedObject.data.whoMoved = parentApplication.who;
				red5SharedObject.setDirty("whoMoved");
				red5SharedObject.data.positionX = particle.px;
				red5SharedObject.setDirty("positionX");
				red5SharedObject.data.positionY = particle.py;
				red5SharedObject.setDirty("positionY");
			}
					
			
		}
		
	}
}