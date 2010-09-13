package {
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.media.Camera;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	import uk.ac.napier.Red5.*;
	
	public class PhotoPalWizardOfOzUserInterfaceApplication extends Application {	
		// Variables
		
		private var chatHistoryArray:Array = new Array();
		
		// Red5
		public var red5NetConnection:NetConnection;
		private var red5SharedObject:SharedObject;
		private var red5AudioStream:Red5AudioStream;
		private var red5StreamName:String;
		private var red5SharedObjectName:String;
		
		
		private var firstSync:Boolean = true;
		// Functions
		
		public function PhotoPalWizardOfOzUserInterfaceApplication() {
			trace("PhotoPalWizardOfOzUserInterfaceApplication constructed");

			// Wait until the application has finished loading
			//this.addEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);
			this.addEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);
			
		}
		
		private function onApplicationComplete(event:FlexEvent):void {
			
			// set Red5 stream and sharedobject names with respect to the session_name
			red5StreamName = "defaultStreamName" + "_" + root.loaderInfo.parameters.session_name;
			red5SharedObjectName = "PhotoPalWizardOfOz" + "_" + root.loaderInfo.parameters.session_name;
			
			// set scaling mode (this is a pain in the ass when using flex or flash
			this.stage.scaleMode = StageScaleMode.EXACT_FIT;
		
			
			// flashvars
			//trace("session_name: " + root.loaderInfo.parameters.session_name + "\n");
			
			// Connect to Red5
			joinRed5();
			
			// Audio stream
			red5AudioStream = new Red5AudioStream(this, false, false, red5StreamName, "rtmp://companions.napier.ac.uk/PhotoPalWizardOfOzRed5");
			
			
			
			application.chatHistory.dataProvider = chatHistoryArray;
			//chatHistoryArray.push("session_name is " + root.loaderInfo.parameters.session_name);
			//chatHistoryArray.push("url is " + root.loaderInfo.loaderURL.toString().slice(root.loaderInfo.loaderURL.toString().length - 20, root.loaderInfo.loaderURL.toString().length));
			/*chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");
			chatHistoryArray.push("j");*/
			application.chatHistory.invalidateList();
			application.chatHistory.validateNow();
			application.chatHistory.verticalScrollPosition = application.chatHistory.maxVerticalScrollPosition;

		}
		
		private function setCameraOptions():void {
			trace("HowWasYourDayCompanionWizardOfOzUserInterfaceApplication.setCameraOptions Camera.names = " + Camera.names);
			red5SharedObject.data.cameraOptions = Camera.names;
			red5SharedObject.setDirty("cameraOptions");

		}
		
		public function speak(text:String):void {
			// Speak
			trace("User - speak");
			if (ExternalInterface.available) {
				//ExternalInterface.call("alert('" + text + "')");
				ExternalInterface.call("play('" + text.replace("'", "\\'") + "')"); // escape apostrophes
				//ExternalInterface.call("play('" + text + "')");
            } else {
            	trace("ExternalInterface is NOT vailable");
            	ExternalInterface.call("alert('" + "ExternalInterface is NOT vailable. i.e. there's no javascript engine available (is javascript turned off?)." + "')");
            }
            addToChatHistory(text);
		}
		
		private function addToChatHistory(text:String):void {
			chatHistoryArray.push(text);
			application.chatHistory.invalidateList();
			application.chatHistory.validateNow();
			application.chatHistory.verticalScrollPosition = application.chatHistory.maxVerticalScrollPosition;
		}
		
		private function joinRed5():void {
			trace("User joining Red5");
			
			// create basic netConnection object
			red5NetConnection = new NetConnection();
			// connect to the local Red5 server
			red5NetConnection.connect("rtmp://companions.napier.ac.uk/PhotoPalWizardOfOzRed5");
			red5SharedObject = SharedObject.getRemote(red5SharedObjectName, this.red5NetConnection.uri, false);
			
			//red5SharedObject.fps = 1;
			red5SharedObject.addEventListener(SyncEvent.SYNC, red5OnSync);
			red5SharedObject.addEventListener(NetStatusEvent.NET_STATUS, red5SharedObjectStatus);
			red5SharedObject.connect(this.red5NetConnection);
											 
		}
		
		private function red5SharedObjectStatus(event:NetStatusEvent):void {
			trace("red5SharedObjectStatus: " + event.info);
		}
		
		private function red5OnSync(event:SyncEvent):void {
			if(firstSync) {
				red5SharedObject.data.recordStream = "not recording";
				setCameraOptions();
				firstSync = false
			}
			
			for(var i:int = 0; i < event.changeList.length; i++) {
				// Check for speech
				trace("changed[" + i + "] " + event.changeList[i].name + ", code = " + event.changeList[i].code + ", oldValue = " + event.changeList[i].oldValue);
				//trace(event.type);
				if(event.changeList[i].name == "wizardInputText") {
					if(red5SharedObject.data.wizardInputText.length > 0) {
						trace("User - onSync. wizard sent " + red5SharedObject.data.wizardInputText);
						// Speak
						speak(red5SharedObject.data.wizardInputText);
						Application.application.red5SharedObject.data.wizardInputText = "";
						Application.application.red5SharedObject.setDirty("wizardInputText");
     				}
					
				}
				
				// Check for begin recording audio command
				if(event.changeList[i].name == "recordStream") {
					trace("recordStream changed. Is now: " + red5SharedObject.data.recordStream);
					if(red5SharedObject.data.recordStream == "start") {
						startRecordingAudio();
					}
					if(red5SharedObject.data.recordStream == "not recording") {
						stopRecordingAudio();
					}
				}
				
				// Check for setting the camera to use
				if(event.changeList[i].name == "cameraChoice") {
					trace("cameraChoice changed. Is now: " + red5SharedObject.data.cameraChoice);
					// Set the camera to use
					// red5AudioStream.setupCamera(red5SharedObject.data.cameraChoice); This does not work despite what Adobe say
					// Need to pass the string representation of the camera index in Camera.names
					// As suggested at: http://www.tricedesigns.com/tricedesigns_home/blog/2006/10/multiple-cameras-in-flex-demystifying.html
					var cameraArray:Array = red5SharedObject.data.cameraOptions
					if(cameraArray.indexOf(red5SharedObject.data.cameraChoice) != -1) {
						trace("PhotoPalWizardOfOzUserInterfaceApplication.red5OnSync cameraArray = " + cameraArray);
						red5AudioStream.setupCamera(cameraArray.indexOf(red5SharedObject.data.cameraChoice).toString());
					}
				}
							
			}
									
		}
		
		private function startRecordingAudio():void {
			
			// Clear and then start recordin again
			trace("Recording audio - filename: " + red5SharedObject.data.recordStreamName);
			red5AudioStream.setRecordingName(red5SharedObject.data.recordStreamName);
			red5AudioStream.stopRecording();
			red5AudioStream.record();
		}
		
		private function stopRecordingAudio():void {
			// Clear and then start recordin again
			trace("Not recording audio");
			red5AudioStream.stopRecording();
		}
		
		public function audioStreamReady():void {
			trace("In audioStreamReady()");
			red5AudioStream.setupMic();
			red5AudioStream.setMicRate(11);
			
			red5SharedObject.data.recordStream = "ready";
			red5SharedObject.setDirty("recordStream");
			
		}
	
	}
}
