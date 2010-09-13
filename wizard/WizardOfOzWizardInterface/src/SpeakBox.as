package {
	
	import flash.events.KeyboardEvent;
	import flash.events.SyncEvent;
	import flash.utils.Dictionary;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.core.mx_internal;
	
	//It looks like everything is working apart fro two things:
	//	- the orders haven't been sorted yet. need to keep track of frequencies and sort by that' + 
	//	- when using typing a part of the text and then using the keys to scroll down and then selecting a long piece of text the behaviour is screwy. need to have a look at every selection statement in the autocompletemodified.as - one of them is WRONG.
	//  the selection problem happens only when typing part of a recognised sentence and then selecting a long sentence
	//  Typing a long sentence, slecting a long sentence or typing some then selecting s short sentence works fine.
	
	public class SpeakBox extends HBox {	
		// Variables		
		private var firstSync:Boolean = true;
		private var currentText:String;
		
		// Interface
		//private var textBox:TextInput = new TextInput();
		//private var textBox:ComboBox = new ComboBox();
		private var textBox:AutoCompleteModified = new AutoCompleteModified();
		private var speakButton:Button = new Button();
		private var removeFromHistoryButton:Button = new Button();
		
		public function SpeakBox() {
			
			super();
					
			this.percentWidth = 100;
			
			speakButton.label = "Speak";
			removeFromHistoryButton.label = "Remove";
			textBox.percentWidth = 100;
			textBox.editable = true;
			this.addChild(textBox);
			this.addChild(speakButton);
			this.addChild(removeFromHistoryButton);
			
			
			
			// Wait until the application has finished
			Application.application.addEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);
			
		}
		
		private function onApplicationComplete(event:FlexEvent):void {
			speakButton.addEventListener(FlexEvent.BUTTON_DOWN, onSpeakButtonClick);
			removeFromHistoryButton.addEventListener(FlexEvent.BUTTON_DOWN, onRemoveFromHistoryButtonClick);
			textBox.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			textBox.addEventListener(FlexEvent.ENTER, onEnter);
		}
		
		public function connectRed5SharedObject():void {
			Application.application.pastUtterancesRed5SharedObject.addEventListener(SyncEvent.SYNC, onSyncRed5);
			Application.application.pastUtterancesRed5SharedObject.connect(Application.application.red5NetConnection);
		}
		
		private function onSyncRed5(event:SyncEvent):void {
			trace("SpeakBox - onSyncRed5 event: " + event);
			if(firstSync) {
				firstSync = false;
				red5Ready();
			}
			
		}
		
		private function red5Ready():void {
			// update pastUtterances from red5
			trace("pastUtterances from red5 is " + Application.application.pastUtterancesRed5SharedObject.data.pastUtterances);
			if(Application.application.pastUtterancesRed5SharedObject.data.pastUtterances == undefined) {
				Application.application.pastUtterancesRed5SharedObject.data.pastUtterances = new Array();
			}
			textBox.dataProvider = Application.application.pastUtterancesRed5SharedObject.data.pastUtterances;
			textBox.selectedIndex = -1;
			
			// orderPastUtterances(); Don't call here. If it's called whenever an entry is made then it will be in order now.
		}
		
		private function orderPastUtterances():void {
			// reorder pastUtterances according to frquency
			
			// create an array of the indices of pastUtterances 
			var unorderedPastUtterancesIndicesFrequencies:Array = new Array();
			
			// run through each entry in pastUtterances and fill in orderedPastUtterancesIndices 
			for(var unsortedUtteranceIndex:int = 0; unsortedUtteranceIndex < Application.application.pastUtterancesRed5SharedObject.data.pastUtterances.length; unsortedUtteranceIndex++) {
				unorderedPastUtterancesIndicesFrequencies.push(Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[unsortedUtteranceIndex]]); // put on the end of the array
				//trace("Ordering: " + Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[unsortedUtteranceIndex] 
				//	+ " which has appears " + Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[unsortedUtteranceIndex]]
				//		 + " times");
			}
			//trace("unorderedPastUtterancesIndicesFrequencies = " + unorderedPastUtterancesIndicesFrequencies);
			// so now unorderedPastUtterancesIndicesFrequencies is in the same index order as pasUtterances and contains the frequencies from pastUtterancefrequencies
			
			// now run through the unorderedPastUtterancesIndicesFrequencies and sort them into orderedPastUtterancesIndices
			var orderedPastUtterances:Array = new Array();
			// take the largest frequnecy and put it's index into orderedPastUtterancesIndices - need to do this n times
			var numberOfEntriesInunorderedPastUtterancesIndicesFrequencies:int = unorderedPastUtterancesIndicesFrequencies.length;
			for(var findMaxNumberIteration:int = 0; findMaxNumberIteration < numberOfEntriesInunorderedPastUtterancesIndicesFrequencies; findMaxNumberIteration++) {
				//trace("findMaxNumberIteration = " + findMaxNumberIteration);
				// find the max number
				var max:int = -1;
				var indexOfMax:int = -1;
				for(var indexOfPossibleMax:int = 0; indexOfPossibleMax < unorderedPastUtterancesIndicesFrequencies.length; indexOfPossibleMax++) {
					//trace("indexOfPossibleMax = " + indexOfPossibleMax + " possible max is " + Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[indexOfPossibleMax] + " with frequency " + unorderedPastUtterancesIndicesFrequencies[indexOfPossibleMax]);
					if(unorderedPastUtterancesIndicesFrequencies[indexOfPossibleMax] >= max) {
						max = unorderedPastUtterancesIndicesFrequencies[indexOfPossibleMax];
						indexOfMax = indexOfPossibleMax;
					}
				}
				//trace("Max is: " + Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[indexOfMax] + " with index " + indexOfMax);
				orderedPastUtterances.push(Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[indexOfMax]);
				//trace("Working ordered past utterances: " + orderedPastUtterances);
				// delete the max item so we can't find it next time
				//trace("Before filter: unorderedPastUtterancesIndicesFrequencies: = " + unorderedPastUtterancesIndicesFrequencies);
				//unorderedPastUtterancesIndicesFrequencies = unorderedPastUtterancesIndicesFrequencies.filter(function(element:*, index:int, arr:Array):Boolean { if(index != indexOfMax) { return true; }	return false;	}	);
				// don't filter just make -1 so that the indices don't get messed around
				unorderedPastUtterancesIndicesFrequencies[indexOfMax] = -1;
				//trace("After filter: unorderedPastUtterancesIndicesFrequencies : = " + unorderedPastUtterancesIndicesFrequencies);
			}
			
			// copy the sorted array of past utterances over the original and setDirty  
			//trace("Final ordered past utterances: " + orderedPastUtterances);
			
			//Application.application.pastUtterancesRed5SharedObject.data.pastUtterances = orderedPastUtterances; doesn't work
			for(var utteranceIndex:int = 0; utteranceIndex < orderedPastUtterances.length; utteranceIndex++) {
				Application.application.pastUtterancesRed5SharedObject.data.pastUtterances[utteranceIndex] = orderedPastUtterances[utteranceIndex];
			}
			
			Application.application.pastUtterancesRed5SharedObject.setDirty("pastUtterances");
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			
		}
		
		private function onEnter(event:FlexEvent):void {
			//trace("onEnter");
			
			speak();
			
		}
		
		public function setText(newText:String):void {
			textBox.text = newText;
		}
		
		private function speak():void {
			if(textBox.text.length > 0) {
				trace("Wizard speak: " + textBox.text);
				Application.application.red5SharedObject.data.wizardInputText = textBox.text;
				
				// Add the text to the history of utterances on the red5 server
				addToUtteranceHistory(textBox.text);
				
				trace("red5SharedObject.data.wizardInputText is " + Application.application.red5SharedObject.data.wizardInputText);
				Application.application.red5SharedObject.setDirty("wizardInputText");
				
				trace("Clear text box");
				textBox.text = ""; // Clear text after it's sent to be spoken
				textBox.typedText = ""; // Deal with the bug by clearing this extra text parameter too
			}
		}

		private function addToUtteranceHistory(utterance:String):void {
			trace("addToUtteranceHistory");
			// if the utterance doesn't exist then add it
			if(Application.application.pastUtterancesRed5SharedObject.data.pastUtterances.indexOf(utterance) == -1) {
				Application.application.pastUtterancesRed5SharedObject.data.pastUtterances.push(utterance);
			}
			
			if(Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies == undefined) {
				Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies = new Dictionary();
			}
			
			if(Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[utterance] == undefined) {
				trace("Setting pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[" + utterance + "] to 0");
				Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[utterance] = 0;
			}
			trace("Incrementing pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[" + utterance + "]");
			Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[utterance] += 1;
			
			Application.application.pastUtterancesRed5SharedObject.setDirty("pastUtteranceFrequencies");
			Application.application.pastUtterancesRed5SharedObject.setDirty("pastUtterances");
			
			orderPastUtterances(); // order as adding entries so pastUtterances will alwasy be orederd
		}

		private function onSpeakButtonClick(event:FlexEvent):void {
			speak();
			textBox.setFocus();
		}
		
		private function onRemoveFromHistoryButtonClick(event:FlexEvent):void {
			// Remove utterance from pastUtterances and from pastUtteranceFrequencies
			var indexOfUtteranceToBeRemoved:int = Application.application.pastUtterancesRed5SharedObject.data.pastUtterances.indexOf(textBox.text);
			if(indexOfUtteranceToBeRemoved != -1) { // if the utterance was found - remove it
				Application.application.pastUtterancesRed5SharedObject.data.pastUtterances.splice(indexOfUtteranceToBeRemoved, 1); 
				delete Application.application.pastUtterancesRed5SharedObject.data.pastUtteranceFrequencies[textBox.text];
				// update red5
				Application.application.pastUtterancesRed5SharedObject.setDirty("pastUtteranceFrequencies");
				Application.application.pastUtterancesRed5SharedObject.setDirty("pastUtterances");
			}
			
			textBox.text = "";
			textBox.typedText = "";
			textBox.setFocus();
			
		}
		
		
	}
}