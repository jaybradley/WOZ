package {
	/*import caurina.transitions.*;
	
	import com.adobe.net.URI;
	*/
	import flash.display.*;
	import flash.events.*;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.events.*;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.cove.ape.*;
	import org.httpclient.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.utils.Mouse3D;
	import org.papervision3d.events.*;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.*;
	import org.papervision3d.view.Viewport3D;
	
	import uk.ac.napier.Red5.*;

	public class PhotoPalPhotoViewerApplication extends Application {
		
		// Member data
		
		public var who:String = "not set";
		public var sessionName:String = "not set";
		private const PHOTO_SERVER_URI:String = "http://companions.napier.ac.uk/photopalwoz/";
		private const USER_LIST_URI:String = PHOTO_SERVER_URI + "user_list";
		private const PHOTO_LIST_URI:String = PHOTO_SERVER_URI + "photo_list/";
		public const IMAGES_URI:String = PHOTO_SERVER_URI + "images/";
		
		// Papervision
		private var papervisionCanvas:Sprite;
		private var scene:Scene3D;
        private var camera:FrustumCamera3D;
        private var viewport:Viewport3D;
        private var renderer:BasicRenderEngine;
        private var canvas:Sprite;
        public var mouse3D:Mouse3D;
        private var centerOfWorld:DisplayObject3D;
        private var sphere:Sphere;
        public var viewingPlane:ViewingPlane;
        public var frame:Frame;
		private const CAMERA_FIELD_OF_VIEW:int = 62;//100;
		private const PHYSICS_DAMPING:Number = 0.8;
		//private const VIEWPORT_WIDTH:int = 750;
		//private const VIEWPORT_HEIGHT:int = 500;
		private const VIEWPORT_WIDTH:int = 500; // This hieght and width work when scaling is set to StageScaleMode.SHOW_ALL
		private const VIEWPORT_HEIGHT:int = 370;
		
		// Physics
    	private var globalPhysics:org.cove.ape.Group;
    	private var viewingPlanePhysics:Group;
    	private var selectedLevelPhysics:Group;

		// Red5
		public var red5NetConnection:NetConnection;
		private var red5SharedObject:SharedObject;
		private var red5AudioStream:Red5AudioStream;
		private var startStreamButton:Button;
		private var red5SharedObjectName:String;
		
		// Photos
    	private var photos:Array;
		
		// Timing
		public var time:Date;
		
		// Start page
		private var leftHandVerticalBox:VBox
		private var instructionsTextArea:TextArea;
			
		
		
		// Member functions
		
		public function PhotoPalPhotoViewerApplication() {
			super();
			
			trace("PhotoPalWizardOfOzApplication constructed");
					
			papervisionCanvas = new Canvas3D();
			papervisionCanvas.width = 750;
			papervisionCanvas.height = 500;
			this.addChild(papervisionCanvas);
			
			this.addEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);
		}
		
		private function onApplicationComplete(event:Event):void {
			trace("In onApplicationComplete");
			time = new Date();
			
			// TODO change who to keep session_name and wizard_or_user so that different sessions can exist at the same time
			this.who = root.loaderInfo.parameters.user_or_wizard; // i.e. user or wizard
			this.sessionName = root.loaderInfo.parameters.session_name; // i.e. napier, albany, dave, bob, whatever, etc...

			trace("Interface for " + who);
						
			joinRed5();
			
			queryServerForUsers();
		}
		
		private function joinRed5():void {
			trace("PhotoPalPhotoViewer joining Red5");
			
			// create basic netConnection object
			red5NetConnection = new NetConnection();
			// connect to the local Red5 server
			
			red5NetConnection.connect("rtmp://companions.napier.ac.uk/PhotoPalWizardOfOzRed5"); // Use the PhotoPalWizardOfOz service. Could maybe use it's own red5 service.
			
			red5SharedObjectName = "PhotoPalPhotoViewer" + "_" + root.loaderInfo.parameters.session_name;
			trace("red5SharedObjectName: " + red5SharedObjectName);
			
			red5SharedObject = SharedObject.getRemote(red5SharedObjectName, this.red5NetConnection.uri, false);
			red5SharedObject.clear();
			
			red5SharedObject.addEventListener(SyncEvent.SYNC, red5OnSync);	
			red5SharedObject.connect(this.red5NetConnection);		 
		}
		
		private function red5OnSync(event:SyncEvent):void {
			trace("PhotoPavViewerApplication.red5OnSync");
			// nothing to sync here I think
		}
		
		public function queryServerForUsers():void {
			trace("Asking server for a list of users");
			
			var getUsersFromServerHTTPService:HTTPService = new HTTPService();
			getUsersFromServerHTTPService.url = USER_LIST_URI;
			getUsersFromServerHTTPService.addEventListener(ResultEvent.RESULT, onReceivedUserListFromServer);
			getUsersFromServerHTTPService.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {trace("onFault for queryServerForUsers: " + event.message);});
			getUsersFromServerHTTPService.send();
		}
		
		private function onReceivedUserListFromServer(event:ResultEvent):void {
        	var userListXML:XML = new XML(event.message.body);
        	trace(userListXML);
        	
        	var users:Array = new Array();
        	for each(var userXML:XML in userListXML.children()) {
				users.push(userXML.toString());
			}
			trace("Users: " + users);
        	showStartingInterface(users);
		}
		
		private function showStartingInterface(users:Array):void {
			// add the interface
			leftHandVerticalBox = new VBox();
					
			var localAccountLabel:Label = new Label();
			localAccountLabel.text = "Users";
			leftHandVerticalBox.addChild(localAccountLabel);
			
			var localUsersHorizontalBox:HBox = new HBox();
			leftHandVerticalBox.addChild(localUsersHorizontalBox);
						
			var accountList:List = new List();
			accountList.maxWidth = 400;
			accountList.minWidth = 100;
			accountList.dataProvider = users;
			//accountList.setStyle("backgroundColor", "0x000000");
			//accountList.setStyle("borderStyle", "none");
			//accountList.setStyle("color", "0xffffff");
			accountList.addEventListener(ListEvent.ITEM_CLICK, onAccountItemClick);
			localUsersHorizontalBox.addChild(accountList);
			
			instructionsTextArea = new TextArea();
			instructionsTextArea.minHeight = 200;
			instructionsTextArea.minWidth = 300;
			instructionsTextArea.editable = false;
			instructionsTextArea.selectable = false;
			instructionsTextArea.setStyle("backgroundColor", "0xffffff");
			instructionsTextArea.setStyle("borderStyle", "none");
			instructionsTextArea.htmlText = "<font color='#080808'>Some instructions<br><br>Use the mouse to move around and select photos to view. Left and right arrows or space bar moves through the pictures.</font>";
			leftHandVerticalBox.addChild(instructionsTextArea);
						
			mx.core.Application.application.addChild(leftHandVerticalBox);
		}
		
		public function onAccountItemClick(event:ListEvent):void {
			trace(event.currentTarget.selectedItem + " - user selected");
			queryServerForUsersPhotos(event.currentTarget.selectedItem);
		}
		
		private function queryServerForUsersPhotos(user:String):void {
			trace("Asking server for a list of user's photos");
			
			var getUsersFromServerHTTPService:HTTPService = new HTTPService();
			getUsersFromServerHTTPService.url = PHOTO_LIST_URI + user;
			getUsersFromServerHTTPService.addEventListener(ResultEvent.RESULT, onReceivedPhotoListFromServer);
			getUsersFromServerHTTPService.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {trace("onFault for queryServerForUsersPhotos: " + event.message);});
			getUsersFromServerHTTPService.send();
		}
		
		private function onReceivedPhotoListFromServer(event:ResultEvent):void {
			
        	var photoListXML:XML = new XML(event.message.body);
        	trace(photoListXML);
        	
        	var photoURIs:Array = new Array();
        	for each(var photoXML:XML in photoListXML.children()) {
				photoURIs.push(PHOTO_SERVER_URI + photoXML.toString());
			}
			trace("PhotoURIs: " + photoURIs);
        
        	mx.core.Application.application.removeChild(leftHandVerticalBox);
        	showPhotoViewer(photoURIs);	
        	
        	// add the photos
			addPhotos(photoURIs);
		}
		
		private function showPhotoViewer(photos:Array):void {
						
			// Stop papervision from spewing hundreds of comments
			//Papervision3D.VERBOSE = false;
			
			// Prepare the physics engine
			initPhysics();
			
			// Prepare the 3D scene, camera, etc.
			init3D();
			addCenterOfWorld();
	
			//addTestPrimitives();
			
			addFrame();
			
			// Viewing plane
			addviewingPlane(photos.length);
			
			//start render loop
	        mx.core.Application.application.addEventListener(Event.ENTER_FRAME, render);
	        	        
		}
		
		private function addviewingPlane(numberOfPhotos:int):void {
			if(viewingPlane == null) {
				viewingPlane = new ViewingPlane(this, numberOfPhotos);
				centerOfWorld.addChild(viewingPlane);
			}
		}

		private function addCenterOfWorld():void {
			centerOfWorld = new DisplayObject3D();
			scene.addChild(centerOfWorld);
		}
		
		private function addFrame():void {
			frame = new Frame(this);
			centerOfWorld.addChild(frame);
		}
		
		private function init3D():void {
	        trace("init3D");
	        
	        scene = new Scene3D();
	        //viewport = new Viewport3D(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, true, true, true);
	        //viewport = new Viewport3D(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, false, true, true);
	        viewport = new Viewport3D(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, false, true, true);
	        //                                                          near  far
	        camera = new FrustumCamera3D(viewport, CAMERA_FIELD_OF_VIEW, 1000, 10000);
	        camera.moveBackward(1000);
	        papervisionCanvas.addChild(viewport);
	        
	        renderer = new BasicRenderEngine();
	        
	        mouse3D = viewport.interactiveSceneManager.mouse3D;
			Mouse3D.enabled = true;

	    }
	    
	    private function initPhysics():void {
			APEngine.init(1/4);
			//APEngine.init(1/2);
			
			APEngine.damping = PHYSICS_DAMPING;
         	globalPhysics = new Group(true);
         	viewingPlanePhysics = new Group(true);
         	selectedLevelPhysics = new Group(true);
			APEngine.addGroup(viewingPlanePhysics);
			APEngine.addGroup(selectedLevelPhysics);
         	APEngine.addGroup(globalPhysics);
		}
		
		private function render(e:Event):void {
			APEngine.step();
			APEngine.paint();
			
			renderer.renderScene(scene, camera, viewport);
	    }
		
		public function addPhotos(uris:Array):void {

			photos = new Array();
			
			for each(var uri:String in uris) {
				addPhoto(uri);
			}
		}
		
		public function addPhoto(uri:String):void {
			trace("Adding photo: " + uri);
			photos.push(new PhotoPanel(uri, viewingPlane, this, new Array()));	
		}
		
		public function addToGlobalPhysics(object:AbstractParticle):void {
			globalPhysics.addParticle(object);
		}
		
		public function addToViewingPlanePhysics(object:AbstractParticle):void {
			viewingPlanePhysics.addParticle(object);
		}
		
		public function moveToViewingPlanePhysics(object:AbstractParticle):void {
			selectedLevelPhysics.removeParticle(object);
			addToViewingPlanePhysics(object);
		}
		
		public function addToSelectedLevelPhysics(object:AbstractParticle):void {
			selectedLevelPhysics.addParticle(object);
		}
		
		public function moveToSelectedLevelPhysics(object:AbstractParticle):void {
			viewingPlanePhysics.removeParticle(object);
			addToSelectedLevelPhysics(object);
		}
		
		public function deselectAllPhotos():void {
			for(var photoIndex:int = 0; photoIndex < photos.length; photoIndex++) {
					photos[photoIndex].deselect(false); // false means not bySync
					unselected(photos[photoIndex]);
			}
		}
		
		public function unselected(selectedPhoto:PhotoPanel):void {
			for(var photoIndex:int = 0; photoIndex < photos.length; photoIndex++) {
				if(selectedPhoto != photos[photoIndex]) {
					photos[photoIndex].unfade();
				}
			}
		}
		
		public function selected(selectedPhoto:PhotoPanel):void {
			selectedPhoto.unfade();
			
			for(var photoIndex:int = 0; photoIndex < photos.length; photoIndex++) {
				if(selectedPhoto != photos[photoIndex]) {
					photos[photoIndex].deselect(false); // false means not bySync
					photos[photoIndex].fade();
				}
			}
		}
		
		public function unfadeAllPhotos():void {
			for(var photoIndex:int = 0; photoIndex < photos.length; photoIndex++) {
					photos[photoIndex].unfade();
			}
		}
		

		
	}
}