package {
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	public class ButtonBox extends HBox {	
		// Variables
		
		// Interface
		private var streamButton:Button;
		public var recordingNameBox:TextInput = new TextInput();
		public var cameraList:ComboBox;
		private var recording:Boolean = false;
		
		public function ButtonBox()	{
			super();
			this.percentWidth = 100;
						
			streamButton = new Button();
			streamButton.label = "Start recording";
			this.addChild(streamButton);
			
			recordingNameBox.text = "Recording_name";
			recordingNameBox.width = Application.application.width / 3;
			this.addChild(recordingNameBox);
			
			cameraList = new ComboBox();
			cameraList.enabled = false;
			this.addChild(cameraList);
			cameraList.addEventListener(ListEvent.CHANGE, onCameraChange);
			
			streamButton.addEventListener(FlexEvent.BUTTON_DOWN, startStopStream);
		}
		
		private function onCameraChange(event:ListEvent):void {
			trace("ButtonBox.onCameraChange Camera changed to: " + event.currentTarget.selectedItem);
			Application.application.setCameraChoice(event.currentTarget.selectedItem);
		}
		
		private function startStopStream(event:FlexEvent):void {
			if(recording) {
				recording = false;
				streamButton.label = "Start recording";
				Application.application.stopAudioStream();
			} else {
				recording = true;
				streamButton.label = "Stop recording";
				Application.application.startAudioStream();
			}
		}
				
	}
}