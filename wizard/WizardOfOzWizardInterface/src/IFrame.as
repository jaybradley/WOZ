// -----------------------------------------------------------------------
// IFrame.as, Alistair Rutherford, www.netthreads.co.uk
// -----------------------------------------------------------------------
// Revision  Date      Who    Notes
// --------  ----      ---    -----
// 1.0       16/09/07  AJR    .Initial version
// 1.1       29/09/07  AJR    .Fixed bug where the frame wasn't resizing itself
//                             when the source url was assigned.
// 1.2       14/12/07  Max    .http://16-bits.com/HTMLTest/HTMLTest.html
//                             I modified it a little bit so that you can also set 
//                             a content property instead of source to display a div 
//                             container instead of iFrame.
//
// -----------------------------------------------------------------------
// This component is based on the work of:
// 
// Christophe Conraets 
// www.coenraets.org
//
// and
//
// Brian Deitte
// http://www.deitte.com/archives/2006/08/finally_updated.htm
//
// -----------------------------------------------------------------------
// I have made some additions to the original code
//
// - javascript support functions are now generated by the component and
// inserted directly into the DOM.
//
// - Component generates it's own div and iframe element and inserts them
// into the DOM.
//
// - When the component is created the display list is traversed from the 
// component down to the root element. At each traversal a test is made to 
// see if current component is a container. If it is a container then the 
// child of the element which leads back to the component is determined and 
// a note madeof the appropriate 'index' on the path. The index is stored 
// against a reference to the Container in a Dictionary. Also the container
// is 'seeded' with an event handler so that if the container triggers an
// IndexChangedEvent.CHANGE (i.e. when you click on a tab in a tab navigator)
// the path of 'index' values down to the component can be checked. If the
// path indicates that the indexes 'line up' to expose the component then
// the view is made visible. I hope I have explained this correctly :)
// -----------------------------------------------------------------------
// 
// -----------------------------------------------------------------------

package
{
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.external.ExternalInterface;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import mx.core.Container;
    import mx.events.IndexChangedEvent;

	public class IFrame extends Container
	{
        private var __source: String;
        private var __content: String;
        private var frameId:String;
        private var iframeId:String;

        private var containerDict:Object = null;
        private var settingDict:Object = null;

        /**
        * Here we define javascript functions which will be inserted into the DOM
        * 
        */
        private static var FUNCTION_CREATEIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
                "if (document.createIFrame==null)" + 
                "{" + 
                    "createIFrame = function (frameID)" +
                	"{ " +
                        "var bodyID = document.getElementsByTagName(\"body\")[0];" +
                        "var newDiv = document.createElement('div');" +
                        "newDiv.id = frameID;" +
                        "newDiv.style.position ='absolute';" +
                        "newDiv.style.backgroundColor = 'transparent';" + 
                        "newDiv.style.border = '0px';" +
                        "newDiv.style.visibility = 'hidden';" +
                        "bodyID.appendChild(newDiv);" +
                    "}" +
                "}" +
            "}";
        
        private static var FUNCTION_MOVEIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.moveIFrame==null)" +
	            "{" +
	                "moveIFrame = function(frameID, iframeID, x,y,w,h) " + 
	                "{" +
	                    "var frameRef=document.getElementById(frameID);" +
	                    "frameRef.style.left=x;" + 
	                    "frameRef.style.top=y;" +
	                    "var iFrameRef=document.getElementById(iframeID);" +
	                	"iFrameRef.width=w;" +
	                	"iFrameRef.height=h;" +
		            "}" +
                "}" +
            "}";

        private static var FUNCTION_HIDEIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.hideIFrame==null)" +
	            "{" +
	                "hideIFrame = function (frameID)" +
                    "{" +
                        "document.getElementById(frameID).style.visibility='hidden';" +
                    "}" +
                "}" +
            "}";

        private static var FUNCTION_SHOWIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.showIFrame==null)" +
	            "{" +
	                "showIFrame = function (frameID)" +
                    "{" +
                        "document.getElementById(frameID).style.visibility='visible';" +
                    "}" +
                "}" +
            "}";
		
        private static var FUNCTION_LOADIFRAME:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.loadIFrame==null)" +
	            "{" +
	                "loadIFrame = function (frameID, iframeID, url)" +
                    "{" +
                        "document.getElementById(frameID).innerHTML = \"<iframe id='\"+iframeID+\"' src='\"+url+\"' frameborder='0'></iframe>\";" + 
                    "}" +
                "}" +
            "}";
        
       	private static var FUNCTION_LOADDIV_CONTENT:String = 
            "document.insertScript = function ()" +
        	"{ " +
	            "if (document.loadDivContent==null)" +
	            "{" +
	                "loadDivContent = function (frameID, iframeID, content)" +
                    "{" +
                    	"document.getElementById(frameID).innerHTML = \"<div id='\"+iframeID+\"' frameborder='0'>\"+content+\"</div>\";" +
                    "}" +
                "}" +
            "}";
        
        /**
        * Constructor
        * 
        */
	    public function IFrame()
	    {
	        super();
	    }
		
        /**
        * Generate DOM elements and build display path.
        * 
        */
        override protected function createChildren():void
        {
            super.createChildren();
            
            if (! ExternalInterface.available)
            {
                throw new Error("ExternalInterface is not available in this container. Internet Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other browsers that support NPRuntime are required.");
            }

            // Generate unique id's for frame div name
            frameId = id;
            iframeId = "iframe_"+frameId;
            
            // Add functions to DOM if they aren't already there
            ExternalInterface.call(FUNCTION_CREATEIFRAME);
            ExternalInterface.call(FUNCTION_MOVEIFRAME);
            ExternalInterface.call(FUNCTION_HIDEIFRAME);
            ExternalInterface.call(FUNCTION_SHOWIFRAME);
            ExternalInterface.call(FUNCTION_LOADIFRAME);
            ExternalInterface.call(FUNCTION_LOADDIV_CONTENT);

            // Insert frame into DOM using our precreated function 'createIFrame'
            ExternalInterface.call("createIFrame", frameId);
            
            buildContainerList();
        }

        /**
        * Build list of container objects on the display list path all the way down
        * to this object. We will seed the container classes we find with an event
        * listener which will be used to test if this object is to be displayed or not.
        *
        */
        private function buildContainerList():void
        {
            // We are going to store containers against index of child which leads down
            // to IFrame item.
            containerDict = new Dictionary();
            settingDict = new Dictionary();

            var current:DisplayObjectContainer = parent;
            var previous:DisplayObjectContainer = this;
            
            while (current!=null)
            {
                if (current is Container)
                {
                    if (current.contains(previous))
                    {
                    	
                        var childIndex:Number = current.getChildIndex(previous);                
                        trace("index:" + childIndex);
                        // Store child index against container
                        containerDict[current] = childIndex;
                        settingDict[current] = childIndex;
                        
                        // Tag on a change listener             
                        current.addEventListener(IndexChangedEvent.CHANGE, handleChange);
                        
                    }
                    
                }        
                
                previous = current;
                current = current.parent;
            }
            
        }

        /**
        * Triggered by one of our listeners seeded all the way up the display
        * list to catch a 'changed' event which might hide or display this object.
        * 
        * @param event Event trigger
        *
        */
        private function handleChange(event:Event):void
        {
            var target:Object = event.target;
            
            if (event is IndexChangedEvent)
            {
                var changedEvent:IndexChangedEvent = IndexChangedEvent(event)

                var newIndex:Number = changedEvent.newIndex;
                
                visible = checkDisplay(target, newIndex);
                
            }
        }
        
        /**
        * This function updates the selected view child of the signalling container
        * and then compares the path from our IFrame up the displaylist to see if
        * the index settings match. Only an exact match all the way down to our
        * IFrame will satisfy the condition to display the IFrame contents.
        *
        * @param target Object event source
        * @param newIndex Number index from target object.
        * 
        */
        private function checkDisplay(target:Object, newIndex:Number):Boolean
        {
            var valid:Boolean = false;
            
            if (target is Container)
            {
                var container:DisplayObjectContainer = DisplayObjectContainer(target);
                
                // Update current setting
                settingDict[container] = newIndex;
                
                valid = true;
                
                for (var item:Object in containerDict)
                {
                    var index:Number = lookupIndex(item as Container);
                    var setting:Number = lookupSetting(item as Container);
                    trace(item);
                    valid = valid&&(index==setting);
                }
                
            }
            
            return valid;
        }
		
        /**
        * Return index of child item on path down to this object. If not
        * found then return -1;
        *
        * @param target Container object
        * 
        */
        public function lookupIndex(target:Container):Number
        {
            var index:Number = -1;
            
            try
            {
                index = containerDict[target];
            }
            catch (e:Error)
            {
                // Error not found, we have to catch this or a silent exception
                // will be thrown.
                trace(e);
            }
            
            return index;
        }

        /**
        * Return index of child item on path down to this object. If not
        * found then return -1;
        *
        * @param target Container object
        * 
        */
        public function lookupSetting(target:Container):Number
        {
            var index:Number = -1;
            
            try
            {
                index = settingDict[target];
            }
            catch (e:Error)
            {
                // Error not found, we have to catch this or a silent exception
                // will be thrown.
                trace(e);
            }
            
            return index;
        }                
        
        /**
        * Adjust frame position to match the exposed area in the application.
        * 
        */
        private function moveIFrame(): void
        {

            var localPt:Point = new Point(0, 0);
            var globalPt:Point = this.localToGlobal(localPt);

            ExternalInterface.call("moveIFrame", frameId, iframeId, globalPt.x, globalPt.y, this.width, this.height);
        }

        /**
        * Triggered by change to component properties.
        * 
        */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
            if (source)
            {
	            ExternalInterface.call("loadIFrame", frameId, iframeId, source);
				trace("load Iframe");
				// Trigger re-layout of iframe contents.	            
	            invalidateDisplayList();
            } 
            else if (content) 
            {
            	ExternalInterface.call("loadDivContent", frameId, iframeId, content);
				trace("load Content");
				// Trigger re-layout of iframe contents.	            
	            invalidateDisplayList();
            }
		}        
		
        /**
        * Triggered when display contents change. Adjusts frame layout.
        * 
        * @param unscaledWidth
        * @param unscaledHeight
        * 
        */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
            moveIFrame();
		}
		
        /**
        * Set source url
        * 
        * @param url Frame contents
        * 
        */
        public function set source(source: String): void
        {
            if (source)
            {
                __source = source;

				invalidateProperties();                
            }
        }

        /**
        * Return url of frame contents
        * 
        */
        public function get source(): String
        {
            return __source;
        }
        
         /**
        * Set content string
        * 
        */
        public function set content(content: String): void
        {
            if (content)
            {
                __content = content;

				invalidateProperties();                
            }
        }

        /**
        * Return content string of div contents
        * 
        */
        public function get content(): String
        {
            return __content;
        }
        
        /**
        * Sets visibility of html iframe. Rtn calls inserted javascript functions.
        * 
        * @param visible Boolean flag
        * 
        */
        override public function set visible(visible: Boolean): void
        {
            super.visible=visible;

            if (visible)
            {
                ExternalInterface.call("showIFrame", frameId);
                trace("show iframe");
            }
            else 
            {
                ExternalInterface.call("hideIFrame", frameId);
            }
            
        }
        
        // document.getElementById('myframe').src
       // private static var FUNCTION_GET_URL:String = 
        //    "document.insertScript = function ()" +
        //	"{ " +
        //		"document.getElementById(frameID).src;" +
        //    "}";
            
        public function getURL():String {
        	//var url:String = String(ExternalInterface.call("document.getElementById(" + frameId + ").src;"));
        	        	
        	return "bob";
        	//htmlReturnValue = String(ExternalInterface.call("showStatus", "'" + inputTask.text + "' is a message sent to the HTML page Javascript showStatus() function from the application (swf --> HTML)"));
        }
                
	}

}