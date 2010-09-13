package
{
	import caurina.transitions.*;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.text.*;
	
	import mx.core.Application;
	
	import org.cove.ape.*;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.CompositeMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	import uk.ac.napier.Red5.*;
	
	public class PhotoPanel extends Plane
	{
		private var firstRed5Sync:Boolean = true;
		
		private var velocityX:Number = 0;
		private var velocityY:Number = 0;
		private var oldMouse3DX:Number = 0;
		private var oldMouse3DY:Number = 0;
		private var oldMouseX:Number = 0;
		private var oldMouseY:Number = 0;
		private var rotationOffsetAngle:Number = 0;
		private var zBeforeRotation:Number = 0;
		private var positionBeforeScale:Point = null;
		private var scaleOffset:Point = new Point();
		
		private var mouseDown:Boolean = false;
		private var mouseOver:Boolean = false;
		
		public var selected:Boolean = false;
		private var flipped:Boolean = false;
		private var xBeforeSelection:int;
		private var yBeforeSelection:int;
		
		private var compositeMaterial:CompositeMaterial;
		private var photoMaterial:BitmapFileMaterial
		private var fadeMaterial:ColorMaterial;
		private var faded:Boolean = false;
		private var descriptionPlane:Plane;
		private var descriptionContentPlane:Plane;
		private var descriptionMaterial:CompositeMaterial;
		private var descriptionContentMaterial:MovieMaterial;
		private var descriptionText:TextField;
		private var descriptionMovieClip:MovieClip;
		
		public var originalScaleX:Number = 1.0;
		public var originalScaleY:Number = 1.0;
		
		private var application:PhotoPalPhotoViewerApplication;
		private var vx:Number = 0.0;
		private var vy:Number = 0.0;
		
		private var red5SharedObject:SharedObject;
		
		public const ORIGINAL_WIDTH:Number = 1000;//800;//400;		//*YL*	200
		public const ORIGINAL_HEIGHT:Number = 1000;//800;//400;		//*YL*	200
		public var width:Number = ORIGINAL_WIDTH;
		public var height:Number = ORIGINAL_HEIGHT;
		public var originalPhotoWidth:int;
		public var originalPhotoHeight:int;
		
		
		public var pointX:int;					//*YL*
		public var pointY:int;					//*YL*
		public var TWEENER_TIME:Number = 0.5;	//*YL*
		
		
		private var photoPlane:ViewingPlane;
		
		private var particle:PlaneParticle;
		
		private var url:String;
		//private var flickrPhotoID:String;
		
		public var photoName:String;
		
		private var tags:Array;
		
		private var highlightableObjects:Array;
		
		// To hande double clicks on photos
		//private const DOUBLE_CLICK_TIME:int = 800;
		//private var doubleClickTimer:Timer = new Timer(DOUBLE_CLICK_TIME, 0);
		//private var doubleClick:Boolean = false;
		
		// Constants
		private const FRICTION:Number = 0.5;
		private const SELECTED_SCALE:Number = 3.5;	//*YL*	7
		//private const SELECTED_Z:Number = -0.01;
		//private const UNSELECTED_Z:Number = -0.001;
		// Amount along the z-axis the photos are raised from the viewing plane
		private const SELECTED_Z:Number = -2000;
		private const UNSELECTED_Z:Number = -1000;
		private const INITIAL_MAXIMUM_SCALE_DIFFERENCE:Number = 0.3;
		private const INITIAL_MAXIMUM_ROTATION:Number = 2;
		
		//public function PhotoPanel(x:int, y:int, url:String, flickrPhotoID:String, photoPlane:ViewingPlane, seniorCompanionInterface:SeniorCompanionInterface, tagStrings:Array, width:Number=0, height:Number=0, material:MaterialObject3D=null, segmentsW:Number=0, segmentsH:Number=0, initObject:Object=null)
		public function PhotoPanel(url:String, photoPlane:ViewingPlane, theParentApplication:PhotoPalPhotoViewerApplication, tagStrings:Array, material:MaterialObject3D=null, segmentsW:Number=0, segmentsH:Number=0, initObject:Object=null)
		{
			//this.photoName = url.slice(url.lastIndexOf("/") + 1, url.length); // Old way of naming photos
			this.photoName = url; // New way of naming photos. Backend must reflect this change
			this.application = theParentApplication;
			this.photoPlane = photoPlane;
			this.url = url;
			
			//highlightableObjects = new Array();
			
			// Material to texture the plane
			fadeMaterial = new ColorMaterial(0x000000, 0.0);
			compositeMaterial = new CompositeMaterial();
			photoMaterial = new BitmapFileMaterial(url);
			photoMaterial.addEventListener(FileLoadEvent.LOAD_COMPLETE, onLoaded);
			compositeMaterial.addMaterial(photoMaterial);
			
			compositeMaterial.addMaterial(new BitmapFileMaterial(theParentApplication.IMAGES_URI + "Bhor.png"));
			compositeMaterial.addMaterial(fadeMaterial);
			compositeMaterial.interactive = true;
			compositeMaterial.smooth = false;
			compositeMaterial.doubleSided = true;
						
			super(compositeMaterial, ORIGINAL_WIDTH, ORIGINAL_HEIGHT, segmentsW, segmentsH, initObject);
			var x:int = (Math.floor(Math.random() * (application.viewingPlane.WIDTH * 0.7))) - ((application.viewingPlane.WIDTH * 0.7) / 2);
			var y:int = (Math.floor(Math.random() * (application.viewingPlane.HEIGHT * 0.7))) - ((application.viewingPlane.HEIGHT * 0.7) / 2);
			particle = new PlaneParticle(this, x ,y, ORIGINAL_WIDTH, ORIGINAL_HEIGHT, rotationZ, false, 2, 0.3, FRICTION);
			
			this.application.addToViewingPlanePhysics(particle);

			descriptionMaterial = new CompositeMaterial();
			descriptionMaterial.addMaterial(new ColorMaterial(0x000002, 0.8, true));
			descriptionMaterial.opposite = true;
					
			descriptionPlane = new Plane(descriptionMaterial, ORIGINAL_WIDTH, ORIGINAL_HEIGHT, segmentsW, segmentsH, initObject);
			descriptionPlane.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, onPress);
			descriptionPlane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, onRelease);
			descriptionPlane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onOver);
			descriptionPlane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onOut);
			descriptionPlane.moveForward(0.5);
			
			//this.addChild(descriptionPlane);
			
			//updateDescription("");
			
			photoPlane.addChild(this);
			this.z = UNSELECTED_Z;
			
			// Set random starting rotation
			this.scale += (Math.random() * (INITIAL_MAXIMUM_SCALE_DIFFERENCE)) - INITIAL_MAXIMUM_SCALE_DIFFERENCE;
			
			//setTags(tagStrings);
			
			setUpListeners();
			
			particle.addMasslessForce(new Vector(Math.floor(Math.random() * 500) + 200, Math.floor(Math.random() * 500) + 200)); // random starting movement
			
			joinRed5();
			
			//start render loop
	        mx.core.Application.application.addEventListener(Event.ENTER_FRAME, render);
		}
		
		private function joinRed5():void {
			trace(photoName + " joining Red5");
			
			var badThings:RegExp = new RegExp("[: /\-]", "g");
			var safePhotoNameForSharedObject:String = photoName.replace(badThings, "_") + "_" + this.application.sessionName;
			
			trace("safePhotoNameForSharedObject = " + safePhotoNameForSharedObject);
			
			//red5SharedObject = SharedObject.getRemote(safePhotoNameForSharedObject, application.red5NetConnection.uri, false); // non persistent
			red5SharedObject = SharedObject.getRemote(safePhotoNameForSharedObject, application.red5NetConnection.uri, true); // persistent
			red5SharedObject.fps = 3;
				
			red5SharedObject.addEventListener(SyncEvent.SYNC, red5OnSync);
			red5SharedObject.connect(application.red5NetConnection);
		}
		
		private function red5OnSync(event:SyncEvent):void {
			if(firstRed5Sync) {
				trace("First red5 sync");
			
				particle.px = red5SharedObject.data.positionX;
				if(isNaN(particle.px)) {
					particle.px =  (Math.floor(Math.random() * (application.viewingPlane.WIDTH * 0.7))) - ((application.viewingPlane.WIDTH * 0.7) / 2); // Set random starting value
				}
				
				particle.py = red5SharedObject.data.positionY;
				if(isNaN(particle.py)) {
					particle.py = (Math.floor(Math.random() * (application.viewingPlane.HEIGHT * 0.7))) - ((application.viewingPlane.HEIGHT * 0.7) / 2); // Set random starting rotation
				}
						
				//trace("particle.px = " + particle.px);
				//trace("particle.py = " + particle.py);
				
				this.rotationZ = red5SharedObject.data.rotationZ;
				//trace("this.rotationZ is " + this.rotationZ);
				if(isNaN(this.rotationZ)) {
					this.rotationZ = (Math.random() * (INITIAL_MAXIMUM_ROTATION)) - INITIAL_MAXIMUM_ROTATION; // Set random starting rotation
				}
				
				firstRed5Sync = false;
			}
			//trace("red5OnSync. event = " + event.toString());
			
			for(var i:int = 0; i < event.changeList.length; i++) {
				trace("changed[" + i + "] " + event.changeList[i].name + ", code = " + event.changeList[i].code + ", oldValue = " + event.changeList[i].oldValue);
				trace("red5SharedObject.data.whoMoved is " + red5SharedObject.data.whoMoved + " and application.who is " + application.who);
				if((event.changeList[i].name == "positionX") && (red5SharedObject.data.whoMoved != application.who)) {
					trace("Update red5SharedObject.data.positionX to " + red5SharedObject.data.positionX);
					particle.px = red5SharedObject.data.positionX;
				}
				if((event.changeList[i].name == "positionY") && (red5SharedObject.data.whoMoved != application.who)) {
					trace("Update red5SharedObject.data.positionY to " + red5SharedObject.data.positionY)
					particle.py = red5SharedObject.data.positionY;
				}
				if((event.changeList[i].name == "rotationZ") && (red5SharedObject.data.whoMoved != application.who)) {
					trace("Update red5SharedObject.data.positionZ to " + red5SharedObject.data.positionZ)
					this.rotationZ = red5SharedObject.data.rotationZ;
				}
				//trace("red5SharedObject.data.whoSelected = " + red5SharedObject.data.whoSelected + ", seniorCompanionInterface.who = " + application.who);
				if((event.changeList[i].name == "selected") && (red5SharedObject.data.whoSelected != application.who)) {
					trace("Update selected. red5SharedObject.data.whoSelected is " + red5SharedObject.data.whoSelected + ", application.who: " + application.who);
					if(red5SharedObject.data.selected == true) {
						this.select(true); // true means bySync
						//trace("Should select");
					} else {
						application.unfadeAllPhotos();
						this.deselect(true); // true means bySync
					}
				}
			}
		}
		
		public function updateDescription(content:String):void {
			//trace(this.photoName + " updating description");
			// The description text

			if(descriptionMovieClip == null) {
				descriptionMovieClip = new MovieClip();
			}
			
			if(descriptionText == null) {
				descriptionText = new TextField();
				descriptionText.embedFonts = true;
	            descriptionText.antiAliasType = AntiAliasType.ADVANCED;
	        	descriptionText.textColor = 0xf0f0f0;
	        	descriptionText.autoSize = TextFieldAutoSize.CENTER;
	        	descriptionText.multiline = true;
	        	descriptionText.wordWrap = true;
	        	descriptionText.width = this.width * 0.9; // Magic number
	        	descriptionText.defaultTextFormat = new TextFormat("BackOfPhotoFont", 86);
	        	descriptionMovieClip.addChild(descriptionText);
   			}
   			
   			
   			//var backOfPhotoTextFormat:TextFormat = new TextFormat("BackOfPhotoFont", 76)
   			//descriptionText.setTextFormat(backOfPhotoTextFormat);
   			//if(Application.application.systemManager.isFontFaceEmbedded(backOfPhotoTextFormat)) {
   			//	trace("Font is embedded");
   			//}
   			
   			
			//descriptionText.text = content; // update the text
			descriptionText.text = content;
			//descriptionText.setTextFormat(backOfPhotoTextFormat);

			
			if(descriptionContentMaterial == null) {
	        	descriptionContentMaterial = new MovieMaterial(descriptionMovieClip, true, true, true);
				descriptionContentMaterial.smooth = true;
				descriptionContentMaterial.precise = true;
			}
			
			if(descriptionContentPlane != null) {
				// Replace the text plane with one that's a suitable size for the nex text
				descriptionPlane.removeChild(descriptionContentPlane);	
			}
			
			descriptionContentPlane = new Plane(descriptionContentMaterial, descriptionText.width, descriptionText.height, segmentsW, segmentsH);
			descriptionContentPlane.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, onPress);
			descriptionContentPlane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, onRelease);
			descriptionContentPlane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onOver);
			descriptionContentPlane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onOut);
			descriptionContentPlane.rotationY = 180;
			descriptionContentPlane.moveBackward(100);
			descriptionPlane.addChild(descriptionContentPlane);
		}

		public function addHighlightableObject(newObject:HighlightableObject):void {
			highlightableObjects.push(newObject);
			this.addChild(newObject);
		}
		
		private function onLoaded(event:Event):void {
			
			trace("PhotoPanel.onLoaded: " + this.photoName);
			//trace("HERE 2 = " + compositeMaterial.materials[0].bitmap.width + ", " + compositeMaterial.materials[0].bitmap.height);
			//trace("Material loaded = " + compositeMaterial.materials[0].loaded);	
			//if(compositeMaterial.materials[0].bitmap != null) {
			//	trace("Image width = " + compositeMaterial.materials[0].bitmap.width + "Image height = " + compositeMaterial.materials[0].bitmap.height);
			//}
			var aspectRatio:Number = compositeMaterial.materials[0].bitmap.width / compositeMaterial.materials[0].bitmap.height
			originalPhotoWidth = compositeMaterial.materials[0].bitmap.width;
			originalPhotoHeight = compositeMaterial.materials[0].bitmap.height;
			//trace("Aspectratio = " + aspectRatio);
			originalScaleX = scaleX;
			originalScaleY = scaleY;
			//trace("Aspect ratio for photo is: " + aspectRatio); 
			if(aspectRatio > 1) {
				scaleX *= aspectRatio;
				width *= aspectRatio;
				originalScaleX = scaleX;
			} else {
				scaleY /= aspectRatio;
				height /= aspectRatio;
				originalScaleY = scaleY;
			}

			particle.width = width;			
			particle.height = height;
			
			photoMaterial.precise = true;
			     
		}
		
		/*private function setTags(tagStrings:Array):void {
			tags = new Array;
			
			var xPlacement:int = - (width /2 );
			var yPlacement:int;
			for(var tagIndex:int = 0; tagIndex < tagStrings.length; tagIndex++) {
				//trace("Tag: " + foundTags.tags[tagIndex].tag);
				//xPlacement = Math.floor(Math.random() * 250) + 100;
				
				yPlacement = -((height / 2) + 20);	
				tags.push(new Tag(tagStrings[tagIndex], photoPlane, this, xPlacement, yPlacement));
				xPlacement += tags[tags.length - 1].getTextWidth() + 7;
				
			}
		}*/
				
		private function setUpListeners():void {
			this.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, onPress);
			this.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, onRelease);
			mx.core.Application.application.addEventListener(MouseEvent.MOUSE_UP, onGlobalMouseRelease);
			this.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onOver);
			this.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onOut);
		}
		
		private function onOver(event:InteractiveScene3DEvent):void {
			if(selected) {
				//showTags();	
			} else {
				//Tweener.addTween(this, {scale:originalScale + 0.1, time:0.1, transition:"easeOutQuint"});
				this.scaleX = originalScaleX + 0.01;
				this.scaleY = originalScaleY + 0.01;
			}
		}
		
		private function onOut(event:InteractiveScene3DEvent):void {
			if(selected) {
				//hideTags();
			} else {
				//Tweener.addTween(this, {scale:originalScale, time:0.1, transition:"easeOutQuint"});
				this.scaleX = originalScaleX;
				this.scaleY = originalScaleY;
			}
			
		}
		
		/*private function showTags():void {
			for(var tagIndex:int = 0; tagIndex < tags.length; tagIndex++) {
				tags[tagIndex].show();			
			}
		}*/
		
		/*private function hideTags():void {
			for(var tagIndex:int = 0; tagIndex < tags.length; tagIndex++) {
				tags[tagIndex].hide();				
			}
		}*/
		
		private function onRelease(event:InteractiveScene3DEvent):void {
				if(selected) { // down
					//seniorCompanionInterface.unselected(this);
					//deselect();
				} else { // up
					if(vx == 0.0 && vy == 0.0) {
						select(false); // false means not bySync
					}
				}	
		}
		
		/*private function displayTags():void {
			
			// Flip over photo
			flipPhoto();
			
			if(flipped) {
				trace("Displaying tags");
				// Ask for tags from Sheffield
				//var stamp:Date = new Date();	            	
           		//var message:XML = <communication><command type="getDescription" id="0" photoName={this.photoName} timestamp={stamp.getTime()} /></communication>		
				//seniorCompanionInterface.sheffield.send(message);
			}
			
		}*/
		
		/*private function flipPhoto():void {
			if(flipped) { // flip back to normal
				flipped = false;
				Tweener.addTween(this, {rotationY:0, time:TWEENER_TIME, transition:"linear" });
			} else { // flip over
				flipped = true;
				Tweener.addTween(this, {rotationY:180, time:TWEENER_TIME, transition:"linear" });
			}
		}*/
		
		private function onPress(event:InteractiveScene3DEvent):void {
			//trace("Photo pressed");
			
			if (selected) {
	 			//trace("click @ " + event.x * this.originalPhotoWidth + ", " + event.y * this.originalPhotoHeight);
				//var stamp:Date = new Date();
				//trace("timestamp: " + stamp.getTime());
				
				pointX = event.x * this.originalPhotoWidth;
				pointY = event.y * this.originalPhotoHeight;
				//application.photoPressed(this);
				
				//trace("Point clicked is " + pointX + ", " + pointY);
 			}
						
			mouseDown = true;
			
			vx = 0.0;
			vy = 0.0;
			
			oldMouse3DX = application.mouse3D.x;
			oldMouse3DY = application.mouse3D.y;
		}
		
		public function hide(flag:Boolean):void {
			if (flag == true) {
				this.z = 10;
			}
			else if (selected) {
				this.z = SELECTED_Z;
			}
			else {
				this.z = UNSELECTED_Z;
			}
		}
		
		public function setXY(x:int, y:int):void {
			this.particle.px = x;
			this.particle.py = y;			
		}		
				
		public function deselect(bySync:Boolean):void {
			
			if(selected) {//down
			
				// Update red5
				/*if(seniorCompanionInterface.who == "user") {
					red5SharedObject.data.selected = false;
					red5SharedObject.setDirty("selected");
				} else if(seniorCompanionInterface.who == "wizard") {
					red5SharedObject.data.selected = false;
					red5SharedObject.setDirty("selected");
				}*/
				if(!bySync) {
					red5SharedObject.data.selected = false;
					red5SharedObject.setDirty("selected");
					red5SharedObject.data.whoSelected = application.who;
					red5SharedObject.setDirty("whoSelected");
				}
			
				selected = false;
				compositeMaterial.smooth = false;
				//hideTags();
				//seniorCompanionInterface.frame.noSelectedPhoto();
				particle.addMasslessForce(new Vector(xBeforeSelection, yBeforeSelection)); 
				Tweener.addTween(this, {scaleX:originalScaleX, scaleY:originalScaleY, time:TWEENER_TIME, transition:"easeOutBounce", onComplete:function():void { z = UNSELECTED_Z; }});
				Tweener.addTween(this.particle, {width:this.width * originalScaleX, height:this.height * originalScaleY, time:TWEENER_TIME, transition:"easeInOutBack", onStart:function():void { z = SELECTED_Z;}, onComplete:function():void { application.moveToViewingPlanePhysics(particle); } });
				//if(flipped) {
				//	flipPhoto();
				//}				
			}
		}
		
		public function select(bySync:Boolean):void {
			
			if((!selected) && (Tweener.getTweenCount(this) == 0)) {//up

				if(!bySync) {
					red5SharedObject.data.selected = true;
					red5SharedObject.setDirty("selected");
					red5SharedObject.data.whoSelected = application.who;
					red5SharedObject.setDirty("whoSelected");
				}
			
				compositeMaterial.smooth = true;
				application.moveToSelectedLevelPhysics(particle);			
				application.selected(this);
				selected = true;
				//seniorCompanionInterface.frame.selectedPhoto();
				xBeforeSelection = this.x;
				yBeforeSelection = this.y;
				Tweener.addTween(this, {scaleX:this.scaleX * SELECTED_SCALE, scaleY:this.scaleY * SELECTED_SCALE, time:TWEENER_TIME, transition:"easeInExpo"});
				Tweener.addTween(this.particle, {px:(photoPlane.x * -1), py:(photoPlane.y * -1), width:this.width * SELECTED_SCALE, height:this.height * SELECTED_SCALE, time:TWEENER_TIME, transition:"easeInOutBack", onStart:function():void { z = SELECTED_Z;} });
				unfade();
			}
		}
		
		public function showButDontSelect(numberOfConcurrentlyShownPhotos:int):void {
			if(selected) {
				this.scaleX = originalScaleX;
				this.scaleY = originalScaleY;
				this.particle.width = this.width * originalScaleX;
				this.particle.height = this.height * originalScaleY;
				this.selected = false;
			}  
			
			if(!selected) {//up
				compositeMaterial.smooth = true;
				application.moveToSelectedLevelPhysics(particle);
				xBeforeSelection = this.x;
				yBeforeSelection = this.y;
				this.selected = true;
				Tweener.addTween(this, {scaleX:this.scaleX * (SELECTED_SCALE / numberOfConcurrentlyShownPhotos), scaleY:this.scaleY * (SELECTED_SCALE / numberOfConcurrentlyShownPhotos), time:TWEENER_TIME, transition:"easeInExpo"});
				Tweener.addTween(this.particle, {px:(photoPlane.x * -1), py:(photoPlane.y * -1), width:this.width * this.scaleX * (SELECTED_SCALE / numberOfConcurrentlyShownPhotos), height:this.height * this.scaleY * (SELECTED_SCALE / numberOfConcurrentlyShownPhotos), time:TWEENER_TIME, transition:"easeInOutBack", onStart:function():void { z = SELECTED_Z;} });
				unfade();
			}
		}
		
		public function fade():void {
			
			if(!faded) {
				faded = true;
				Tweener.addTween(fadeMaterial, {fillAlpha:0.6, time:TWEENER_TIME, transition:"linear"});
			}	
		}
		
		public function unfade():void {
			if(faded) {
				faded = false;
				Tweener.addTween(fadeMaterial, {fillAlpha:0, time:TWEENER_TIME, transition:"linear"});
			}	
		}
		
		private function onGlobalMouseRelease(event:MouseEvent):void {
			if(mouseDown) {
				//trace("Throwing photo " + url);
				throwThis();
				mouseDown = false;
				rotationOffsetAngle = 0;
				positionBeforeScale = null;
			}
			//hideTags();
		}
		
		private function throwThis():void {
			// Add force equal to the current velocity
			//photoPlaneParticle.addMasslessForce(new Vector(seniorCompanionInterface.mouse3D.x - oldMouseX, seniorCompanionInterface.mouse3D.y - oldMouseY).mult(10));
			//particle.addMasslessForce(new Vector(vx, vy).mult(20));
			particle.addMasslessForce(new Vector(vx, vy).mult(7));
			//particle.addMasslessForce(new Vector(vx, vy));
		}
				
		private function render(event:Event):void {
			//trace("in render");
			
			if(mouseDown && !selected) {
							
				particle.px += application.mouse3D.x - oldMouse3DX;
				particle.py += application.mouse3D.y - oldMouse3DY;
				
				//trace("deltaX = " + (seniorCompanionInterface.mouse3D.x - oldMouseX) + ", deltaY = " + (seniorCompanionInterface.mouse3D.y - oldMouseY)); 
								
				vx = (vx - (oldMouse3DX - application.mouse3D.x)) * FRICTION;
				vy = (vy - (oldMouse3DY - application.mouse3D.y)) * FRICTION;
				
				// Update red5 if the user has moved this photo panel
				if(((application.mouse3D.x - oldMouse3DX) != 0) || ((application.mouse3D.y - oldMouse3DY) != 0)) {
					red5SharedObject.data.whoMoved = application.who;
					red5SharedObject.setDirty("whoMoved");
					red5SharedObject.data.positionX = particle.px;
					red5SharedObject.setDirty("positionX");
					red5SharedObject.data.positionY = particle.py;
					red5SharedObject.setDirty("positionY");
					
				}
								
				
			} else if(mouseDown && selected) {
				// Rotate
				var dx:Number = application.mouse3D.x;
				var dy:Number = application.mouse3D.y;
				var radiansAngle:Number = Math.atan2(dy, dx);
				if(rotationOffsetAngle == 0) {
					zBeforeRotation = this.rotationZ; 
					rotationOffsetAngle = radiansAngle * 180 / Math.PI;
					//trace("rotationOffsetAngle = " + rotationOffsetAngle);
				}
				//trace("Angle = " + radiansAngle * 180 / Math.PI);
				//trace("Difference = " +  (rotationOffsetAngle - (radiansAngle * 180 / Math.PI)));
				this.rotationZ = zBeforeRotation + (radiansAngle * 180 / Math.PI) - rotationOffsetAngle;
				
				// Update red5 with the new angle
				red5SharedObject.data.rotationZ = this.rotationZ;
				red5SharedObject.setDirty("rotationZ");
				red5SharedObject.data.whoMoved = application.who;
				red5SharedObject.setDirty("whoMoved");
				
				// Scale
				if(positionBeforeScale == null) {
					positionBeforeScale = new Point(application.mouse3D.x, application.mouse3D.y);
					scaleOffset.x = this.scaleX;
					scaleOffset.y = this.scaleY;
				}
				
				var distance:Number = (application.mouse3D.x - positionBeforeScale.x) + (application.mouse3D.y - positionBeforeScale.y);
				
				//trace("ScaleX = " + this.scaleX + " scale delta = " + distance);
				//this.scaleX = Math.max(originalScaleX, this.scaleX * (1 + (distance / (Math.max(this.width, this.height)))));
				//this.scaleY = Math.max(originalScaleY, this.scaleY * (1 + (distance / (Math.max(this.width, this.height)))));
				
				
				//if((application.mouse3D.x < 0 && oldMouse3DX >= 0) || (application.mouse3D.x > 0 && oldMouse3DX <= 0)) {
				//	positionBeforeScale.x = application.mouse3D.x;
				//}
				
				// The below works but is "jumpy"
				/*var distanceX:Number = (application.mouse3D.x - oldMouse3DX);
				var distanceY:Number = (application.mouse3D.y - oldMouse3DY);
				if(application.mouse3D.x < 0) { // Left of the center swap around the scaling direction
					distanceX *= -1;
				}
				if(application.mouse3D.y < 0) { // Above of the center swap around the scaling direction
					distanceY *= -1;
				}
				var distance:Number = distanceX + distanceY;
				if(distance > 200) {
					distance = 200;
				} else if(distance < -200) {
					distance = -200;
				}
				
				this.scaleX = Math.max(originalScaleX, this.scaleX * (1 + (distance / (Math.max(this.width, this.height)))));
				this.scaleY = Math.max(originalScaleY, this.scaleY * (1 + (distance / (Math.max(this.width, this.height)))));*/
				
			}
			
			oldMouse3DX = application.mouse3D.x;
			oldMouse3DY = application.mouse3D.y;
			oldMouseX = application.mouseX;
			oldMouseY = application.mouseY;
			//trace("application.mouse = " + application.mouseX + ", " + application.mouseY + ". application.mouse3D = " + application.mouse3D.x + ", " + application.mouse3D.y); 
			
			// Update red5 if the photo panel is sliding
			if((particle.velocity.x > 0.01) || (particle.velocity.y > 0.01)) {
				red5SharedObject.data.whoMoved = application.who;
				red5SharedObject.setDirty("whoMoved");
				red5SharedObject.data.positionX = particle.px;
				red5SharedObject.setDirty("positionX");
				red5SharedObject.data.positionY = particle.py;
				red5SharedObject.setDirty("positionY");
				
			}
		
		}
		
	}
}