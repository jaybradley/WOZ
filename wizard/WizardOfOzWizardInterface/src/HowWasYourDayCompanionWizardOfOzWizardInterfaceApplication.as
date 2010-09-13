package {
	import flash.events.SyncEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	
	import mx.controls.VideoDisplay;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import uk.ac.napier.Red5.*;
	
	public class HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication extends Application {
		// Red5
		public var red5SharedObject:SharedObject;
		public var pastUtterancesRed5SharedObject:SharedObject;
		public var red5NetConnection:NetConnection;
		private var red5AudioStream:Red5AudioStream;
		private var video:Video;
		private var videoDisplay:VideoDisplay;
		private var red5StreamName:String;
		private var red5SharedObjectName:String;
		private var red5SharedObjectPastUtterancesName:String;
		
		private var firstSync:Boolean = true;
				
		public function HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication() {
			super();
			
			trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication constructed");

			// Wait until the application has finished loading
			this.addEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);

		}
		
		private function onApplicationComplete(event:FlexEvent):void {
			
			// set Red5 stream and sharedobject names with respect to the session_name
			red5StreamName = "defaultStreamName" + "_" + root.loaderInfo.parameters.session_name;
			red5SharedObjectName = "HowWasYourDayCompanionWizardOfOz" + "_" + root.loaderInfo.parameters.session_name;
			red5SharedObjectPastUtterancesName = "HowWasYourDayCompanionWizardOfOz-pastUtterances" + "_" + root.loaderInfo.parameters.session_name;
			Application.application.speakBox.setText(Application.application.parameters.myName);
			
			joinRed5();
			
			// Audio stream
			red5AudioStream = new Red5AudioStream(this, false, false, red5StreamName, "rtmp://companions.napier.ac.uk/HowWasYourDayCompanionWizardOfOzRed5");
			red5SharedObject.data.recordStream = "not recording";			
		}

		public function startAudioStream():void {
			// Send a message to the user via Red5 to start recording
			// When the recording has been started then we can then play it here
						
			var now:Date = new Date();
			var recordingName:String = application.buttonBox.recordingNameBox.text + "-" + now.getDate() + "-" + (now.getMonth() + 1) + "-" + now.getFullYear() + "-" + now.getHours() + "-" + now.getMinutes() + "-" + now.getSeconds(); 
			trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication.startAudioStream recording name : " + recordingName);
			
			red5SharedObject.data.recordStreamName = recordingName;
			red5SharedObject.setDirty("recordStreamName");
			trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication.startAudioStream " + red5SharedObject.data.recordStreamName);
			
			red5AudioStream.setRecordingName(recordingName);
			red5SharedObject.data.recordStream = "start";
			red5SharedObject.setDirty("recordStream");
			
			setupVideoDisplay();
		}
		
		private function setupVideoDisplay():void {
			if(video == null) {
				trace("Setting up video display");
				video = new Video(400, 300);
				var videoComponent:UIComponent = new UIComponent();
	            videoComponent.width = 400;
	            videoComponent.height = 300;
	            videoComponent.addChild(video);
	            Application.application.buttonBox.addChild(videoComponent);
	            red5AudioStream.attachVideo(video);
   			}
            
		}
		
		public function setCameraChoice(choice:String):void {
			red5SharedObject.data.cameraChoice = choice;
			red5SharedObject.setDirty("cameraChoice");
		}
		
		public function stopAudioStream():void {
			// Send a message to the user via Red5 to start recording
			// When the recording has been started then we can then play it here
			red5SharedObject.data.recordStream = "not recording";
			red5SharedObject.setDirty("recordStream");
		}
		
		public function startListeningToAudio():void {
			// Play the stream
			trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication.Playing audio");
			red5AudioStream.play();
		}
		

		private function red5OnSync(event:SyncEvent):void {
			if(firstSync) {
				firstSync = false;
			}
			
			for(var i:int = 0; i < event.changeList.length; i++) {
				trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication Red5 sharedobject changed[" + i + "] " + event.changeList[i].name + ", code = " + event.changeList[i].code + ", oldValue = " + event.changeList[i].oldValue);
				
				// Check for start recording
				if(event.changeList[i].name == "recordStream") {
					trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication recordStream changed. Is now: " + red5SharedObject.data.recordStream);
					if(red5SharedObject.data.recordStream == "ready") {
						startListeningToAudio();
					}
				}
				
				// Check for camera options
				if(event.changeList[i].name == "cameraOptions") {
					trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication cameraOptions changed: " + red5SharedObject.data.cameraOptions);
					if(red5SharedObject.data.cameraOptions.length == 0) {
						trace("HowWasYourDayCompanionWizardOfOzWizardInterfaceApplication No web cam options!")
						Application.application.buttonBox.cameraList.enabled = false;
					} else {
						Application.application.buttonBox.cameraList.enabled = true;
						Application.application.buttonBox.cameraList.dataProvider = red5SharedObject.data.cameraOptions;
					}
					
				}
				
							
			}
									
		}

		private function joinRed5():void {
			// Join Red5
			// create basic netConnection object
			Application.application.red5NetConnection = new NetConnection();
			// connect to the local Red5 server
			Application.application.red5NetConnection.connect("rtmp://companions.napier.ac.uk/HowWasYourDayCompanionWizardOfOzRed5");

			red5SharedObject = SharedObject.getRemote(red5SharedObjectName, Application.application.red5NetConnection.uri, false);
			pastUtterancesRed5SharedObject = SharedObject.getRemote(red5SharedObjectPastUtterancesName, Application.application.red5NetConnection.uri, true);
			
			//red5SharedObject.fps = 1;
			red5SharedObject.addEventListener(SyncEvent.SYNC, red5OnSync);	
			red5SharedObject.connect(Application.application.red5NetConnection);
			
			Application.application.speakBox.connectRed5SharedObject();
			
			
		}

	}
}

