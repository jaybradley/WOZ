/*
 * PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 * AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 * PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 * ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 * RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 * ______________________________________________________________________
 * papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 *
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.papervision3d.objects.parsers
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.ascollada.core.*;
	import org.ascollada.namespaces.*;
	import org.papervision3d.core.animation.AnimationChannel3D;
	import org.papervision3d.core.animation.AnimationKeyFrame3D;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class DAE extends DisplayObject3D
	{
		use namespace collada;
		
		/** */
		public var COLLADA:XML;
		
		/** */
		public var filename:String;
		
		/**
		 * Constructor.
		 */ 
		public function DAE()
		{
			super();
		}
		
		/**
		 * Gets an Array of animated children.
		 * 
		 * @return Array.
		 */ 
		public function getAnimatedChildren():Array
		{
			var animatables:Array = new Array();
			for each(var child:DisplayObject3D in _animatedObjects)
				animatables.push(child);
			return animatables;	
		}
		
		/**
		 * Gets a child by its name.
		 * 
		 * @param	name	The name of the object to find.
		 */ 
		override public function getChildByName(name:String):DisplayObject3D
		{
			return findChildByName(name, this);
		}

		/**
		 * Gets one of the transforms of a child by COLLADA sid. Used by animation.
		 * 
		 * @param	child
		 * @param	sid
		 * 
		 * @return 	The found Matrix3D or null on failure.
		 */ 
		public function getTransformBySID(child:DisplayObject3D, sid:String):Matrix3D
		{
			var sids:Array = _transformSID[ child ];
			var transforms:Array = _transformStack[ child ];
			
			if(sids && transforms && sids.length == transforms.length)
			{
				for(var i:int = 0; i < sids.length; i++)
				{
					if(sid == sids[i])
						return transforms[i];
				}
			}
			return null;
		}
		
		/**
		 * Gets the transform type of a child by COLLADA sid. Used by animation.
		 * 
		 * @param	child
		 * @param	sid
		 * 
		 * @return 	The found Matrix3D or null on failure.
		 */ 
		public function getTransformTypeBySID(child:DisplayObject3D, sid:String):Matrix3D
		{
			var sids:Array = _transformSID[ child ];
			var types:Array = _transformTypes[ child ];
			
			if(sids && types && sids.length == types.length)
			{
				for(var i:int = 0; i < sids.length; i++)
				{
					if(sid == sids[i])
						return types[i];
				}
			}
			return null;
		}
		
		/**
		 * Gets all transforms for a child. Used by animation.
		 * 
		 * @param	child
		 * 
		 * @return	An array of Matrix3D. @see org.papervision3d.core.math.Matrix3D
		 */ 
		public function getTransforms(child:DisplayObject3D):Array
		{
			return _transformStack[child];
		}
		
		/**
		 * Removes a child.
		 * 
		 * @param	child	The child to remove
		 * 
		 * @return	The removed child
		 */ 
		override public function removeChild(child:DisplayObject3D):DisplayObject3D
		{
			var object:DisplayObject3D = getChildByName(child.name);
			
			if(object)
			{
				var parent:DisplayObject3D = DisplayObject3D(object.parent);
				if(parent)
				{
					var removed:DisplayObject3D = parent.removeChild(object);
					if(removed)
						return removed;
				}
			}
			return null;	
		}
		
		/**
		 * Loads the COLLADA.
		 * 
		 * @param	asset The url, an XML object or a ByteArray specifying the COLLADA file.
		 * @param	materials	An optional materialsList.
		 */ 
		public function load(asset:*, materials:MaterialsList = null):void
		{
			this.materials = materials || new MaterialsList();
			this.filename = "nofile";
			
			if(asset is XML)
			{
				this.COLLADA = asset as XML;
				parse();
			}
			else if(asset is ByteArray)
			{
				this.COLLADA = new XML(ByteArray(asset));
				parse();
			}
			else if(asset is String)
			{
				this.loadFile(String(asset));
			}
			else
			{
				throw new Error("load : unknown asset type!");
			}
		}
		
		public function updateChannel(channel:AnimationChannel3D):void
		{
			var target:DisplayObject3D = channel.target;
		//	var type:String = this.g
		}
		
		/**
		 * Recursively finds a child by its name.
		 * 
		 * @param	name
		 * @param	parent
		 * 
		 * @return 	The found child.
		 */ 
		private function findChildByName(name:String, parent:DisplayObject3D = null):DisplayObject3D
		{
			parent = parent || this;
			
			if(parent.name == name)
				return parent;
				
			for each(var child:DisplayObject3D in parent.children)	
			{
				var obj:DisplayObject3D = findChildByName(name, child);
				if(obj)
					return obj;
			}
			return null
		}
		
		/**
		 * Links a skin to a PV3D object.
		 * 
		 * @param	instance	The object to be skinned.
		 * @param	skin	The COLLADA skin controller.
		 *
		private function linkSkin(instance:SkinnedMesh3D, skin:ColladaSkin):void
		{
			instance.joints = new Array();
			instance.skeletons = new Array();
			
			for(var j:int = 0; j < skin.skeletons.length; j++)
			{
				var skeletonName:String = skin.skeletons[j];
				var skeleton:Joint3D = _idToObject[skeletonName] || _sidToObject[skeletonName];
				
				if(!skeleton)
					throw new Error("Could not find skeleton with name = '" + skeletonName + "'");
					
				instance.skeletons.push(skeleton);
			}
			
			for(var i:int = 0; i < skin.joints.length; i++)
			{
				var name:String = skin.joints[i];
				
				var joint:Joint3D = _idToObject[name] || _sidToObject[name];

				if(!joint)
					throw new Error("Could not find joint with name = '" + name + "'");
					
				joint.inverse_bind_matrix = new Matrix3D(skin.inverse_bind_matrices[i]);
				joint.vertexWeights = skin.getJointVertexWeights(i);
				
				instance.joints.push(joint);
				
				// remove the joints
				removeChild(joint);
			}
			
			instance.bind_shape_matrix = new Matrix3D(skin.bind_shape_matrix);
		}
		*/
		
		/**
		 * Link all skins to their object.
		 */ 
		private function linkSkins():void
		{
			/*
			for each(var object:SkinnedMesh3D in _skinnedObjects)
			{
				var controllers:Array = _controllers[ object ];

				for each(var controller:ColladaController in controllers)
				{
				//	if(controller.skin)
				//		linkSkin(object, controller.skin);
				}
			}
			*/
		}
		
		/**
		 * Loads the COLLADA XML from file.
		 * 
		 * @param	filename
		 */ 
		private function loadFile(filename:String):void
		{
			this.filename = filename;	
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onFileLoadComplete);
			loader.load(new URLRequest(this.filename));
		}
		
		/**
		 *
		 * @param	event 
		 */ 
		private function loadNextAnimation(event:TimerEvent = null):void
		{
			if(_queuedAnimations.length)
			{
				var cur:uint = _numAnimations - _queuedAnimations.length + 1;
				var message:String = "Loading animation #" + cur + " of " + _numAnimations + ".";
				
				var animation:ColladaAnimation = _queuedAnimations.shift() as ColladaAnimation;

				var animationNode:XML = this.COLLADA..animation.(@id == animation.id)[0];
				
				animation.parseAsync(animationNode);
								
				for(var i:int = 0; i < animation.channels.length; i++)
				{
					var channel:ColladaChannel = animation.channels[i];
					var target:DisplayObject3D = _idToObject[ channel.targetID ] || _sidToObject[ channel.targetID ];
					
					if(!target)
						throw new Error("Can't find the animated object for channel with id='" + channel.id + "'");
					
					if(!_channels[target])
						_channels[target] = new Array();
						
					var matrix:Matrix3D = getTransformBySID(target, channel.transformSID);
					
					if(!matrix)
						throw new Error("Can't find the targeted transform for channel with id='" + channel.id + "'");
						
					var pv3dChannel:AnimationChannel3D = new AnimationChannel3D(target, matrix);
					
				//	pv3dChannel.targetIndices = channel.transformMembers;
					
					for(var j:int = 0; j < channel.input.length; j++)
					{
						var keyFrame:AnimationKeyFrame3D = new AnimationKeyFrame3D(channel.input[j], channel.output[j]);
						
						if(channel.interpolations && channel.interpolations[j] is String)
							keyFrame.interpolation = channel.interpolations[j];
						if(channel.inTangents && channel.inTangents[j] is String)
							keyFrame.inTangent = channel.inTangents[j];
						if(channel.outTangents && channel.outTangents[j] is String)
							keyFrame.outTangent = channel.outTangents[j];
							
						pv3dChannel.addKeyFrame(keyFrame);
					}
	
					if(!_animatedObjects[target])
						_animatedObjects[target] = target;
				}
				
				dispatchEvent(new FileLoadEvent(FileLoadEvent.ANIMATIONS_PROGRESS, this.filename, cur, _numAnimations, message));
			}
			else
			{
				var timer:Timer = event.target as Timer;
				timer.stop();
				dispatchEvent(new FileLoadEvent(FileLoadEvent.ANIMATIONS_COMPLETE, this.filename));
			}
		}
		
		/**
		 * Called when the COLLADA xml was loaded.
		 */ 
		private function onFileLoadComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			this.COLLADA = new XML(loader.data);
			parse();
		}
		
		/**
		 * Called when a bitmap material was loaded.
		 * 
		 * @param 	event
		 */
		private function onMaterialComplete(event:FileLoadEvent):void
		{
			var material:MaterialObject3D = event.target as MaterialObject3D;
			
			this.materials.addMaterial(material, _queuedMaterials[event.file]);
			
			_loadedBitmaps++;
			if(_loadedBitmaps == _numBitmaps)
				parseAfterMaterials();
		}
		
		/**
		 * Called when a bitmap material failed to load.
		 * 
		 * @param 	event
		 */
		private function onMaterialError(event:FileLoadEvent):void
		{
			this.materials.addMaterial(MaterialObject3D.DEFAULT, _queuedMaterials[event.file]);
			
			_loadedBitmaps++;
			if(_loadedBitmaps == _numBitmaps)
				parseAfterMaterials();
		}
		
		/**
		 * Parses the COLLADA XML.
		 */ 
		private function parse():void
		{	
			parseInstanceMaterials();
			
			if(_numBitmaps > 0)
			{
				for(var imageUrl:String in _queuedMaterials)
				{
					var material:BitmapFileMaterial = new BitmapFileMaterial();
					material.addEventListener(FileLoadEvent.LOAD_COMPLETE, onMaterialComplete);
					material.addEventListener(FileLoadEvent.LOAD_ERROR, onMaterialError);
					material.texture = imageUrl;
					
				}
			}
			else
			{
				parseAfterMaterials();
			}
		}
		
		/**
		 * Continues parsing when all materials are available.
		 */ 
		private function parseAfterMaterials():void
		{
			_queuedAnimations = new Array();
			_transformStack = new Dictionary();
			_transformSID = new Dictionary();
			_transformTypes = new Dictionary();
			_animatedObjects = new Dictionary();
			_skinnedObjects = new Dictionary();
			_idToObject = new Object();
			_objectToID = new Dictionary();
			_sidToObject = new Object();
			_objectToSID = new Dictionary();
			_controllers = new Dictionary();
			_channels = new Dictionary();
			
			parseLibraryVisualScenes();
			parseScene();
			parseAnimations(false);

			_numAnimations = _queuedAnimations.length;
			
			linkSkins();
			
			dispatchEvent(new FileLoadEvent(FileLoadEvent.LOAD_COMPLETE, this.filename));	

			var timer:Timer = new Timer(50, _queuedAnimations.length + 1);
			timer.addEventListener(TimerEvent.TIMER, loadNextAnimation);
			timer.start();
		}
		
		/**
		 * Parses all COLLADA animation elements.
		 * 
		 * @param	parseData	A Boolean indicating whether to parse all animation data (defaults to false).
		 */ 
		private function parseAnimations(parseData:Boolean = false):void
		{
			var anims:XMLList = this.COLLADA..animation;
			for(var j:int = 0; j < anims.length(); j++)
			{
				var anim:ColladaAnimation = new ColladaAnimation(anims[j], parseData);
				_queuedAnimations.push(anim);
			}
		}
		
		/**
		 * Parses a COLLADA bind_material element.
		 * 
		 * @param	node	The XML node to parse
		 * 
		 * @return	The created MaterialObject3D.
		 */
		private function parseBindMaterial(node:XML):MaterialObject3D
		{
			var material:MaterialObject3D = null;
			
			var instances:XMLList = node..instance_material;
			
			for(var i:int = 0; i < instances.length(); i++)
			{
				var instance:XML = instances[i];
				var symbol:String = instance.@symbol.toString();
				material = this.getMaterialByName(symbol);
				if(material)
				{
					return material;
				}
			}
			
			return material;
		}
		
		/**
		 * Parses a COLLADA effect element.
		 * 
		 * @param	id	The id of the effect.
		 * @param	materialName	The name for the new material
		 */
		private function parseEffect(id:String, materialName:String):void
		{
			var effectNode:XML = this.COLLADA..effect.(@id == id)[0];
			if(!effectNode)
				throw new Error("Can't find the effect element with id='" + id + "'");
				
			var technique:XML = effectNode..technique[0];
			if(!technique)
				throw new Error("Can't find the technique element for effect with id='" + id + "'");
				
			// technique sid="common" should have at least one of these shaders:
			// <constant>, <lambert>, <phong> or <blinn> 
			var shaderNode:XML = technique.constant[0];
			if(!shaderNode)
			{
				shaderNode = technique.lambert[0];
				if(!shaderNode)
				{
					shaderNode = technique.phong[0];
					if(!shaderNode)
						shaderNode = technique.blinn[0];
				}
			}
			
			// no shader found, throw!
			if(!shaderNode)
				throw new Error("Can't find a shader for effect with id='" + id + "'");
				
			// only handle diffuse...
			var diffuseNode:XML = shaderNode.diffuse[0];
			if(!diffuseNode)
				throw new Error("Can't find the diffuse element for effect with id='" + id + "'");
				
			var textureNode:XML = diffuseNode.texture[0];
			if(textureNode)
			{
				var texture:String = textureNode.@texture.toString();
				var texCoord:String = textureNode.@texcoord.toString();
				
				var samplerNode:XML = effectNode..newparam.(@sid == texture).sampler2D.source[0];
				if(!samplerNode)
					throw new Error("Can't find the sampler2D element for texture '" + texture + "'");
					
				var surfaceID:String = samplerNode.text().toString();
				
				var surfaceNode:XML = effectNode..newparam.(@sid == surfaceID).surface[0];
				if(!surfaceNode)
					throw new Error("Can't find the surface element for texture '" + texture + "'");
				
				var init_fromNode:XML = surfaceNode.init_from[0];
				if(!init_fromNode)
					throw new Error("Can't find the init_from element for texture '" + texture + "'");
					
				var init_from:String = init_fromNode.text().toString();
				
				// try to find the image element specified by 'init_from'
				var imageNode:XML = this.COLLADA.library_images.image.(@id == init_from)[0];
				if(!imageNode)
					throw new Error("Can't find the image element for texture '" + texture + "'");
					
				var imageUrl:String = imageNode.init_from.text().toString();
				
				_numBitmaps++;
				
				_queuedMaterials[imageUrl] = materialName;
			}
			else
			{
				var colorNode:XML = diffuseNode.color[0];
				if(!colorNode)
					throw new Error("Can't find a color element on the diffuse element.");
					
				var colorValues:Array = ColladaElement.parseStringArray(colorNode);
				var r:int = int(parseFloat(colorValues[0]) * 0xff);
				var g:int = int(parseFloat(colorValues[1]) * 0xff);
				var b:int = int(parseFloat(colorValues[2]) * 0xff);
				var color:uint = r << 16 | g << 8 | b;
				
				this.materials.addMaterial(new ColorMaterial(color), materialName);
			}
		}
		
		/**
		 * Parses a COLLADA geometry element.
		 * 
		 * @param	node
		 * @param	instance
		 */
		private function parseGeometry(node:XML, instance:DisplayObject3D):void
		{
			var children:XMLList = node.children();
			var num:int = children.length();
			
			for(var i:int = 0; i < num; i++)
			{
				var child:XML = children[i];
				
				switch(String(child.localName()))
				{
					case "convex_mesh":
						break;
						
					case "mesh":
						parseMesh(child, instance);
						break;
						
					case "spline":
						break;
					
					case "extra":
						break;	
						
					default:
						trace("unknown node: " + String(child.localName()));
						break;	
				}
			}
		}
		
		/**
		 * 
		 */ 
		private function parseInstanceController(node:XML, instance:DisplayObject3D):void
		{
			if(String(node.localName()) != "instance_controller")
				throw new Error("Not a instance_controller element!");
			
			var url:String = node.@url.toString().substr(1);
			
			var controllerNode:XML = this.COLLADA..controller.(@id == url)[0];
			if(!controllerNode)
				throw new Error("Could not find controller with id='" + url + "'");
				
			var controller:ColladaController = new ColladaController(controllerNode);
			
			if(controller.skin)
			{
				var bindMaterialNode:XML = node.bind_material[0];
				if(bindMaterialNode)
					instance.material = parseBindMaterial(bindMaterialNode);
				parseGeometry(this.COLLADA..geometry.(@id == controller.skin.source)[0], instance); 
				
				_skinnedObjects[instance] = instance;
				
				controller.skin.skeletons = new Array();
				var skeletonList:XMLList = node.skeleton;
				for(var i:int = 0; i < skeletonList.length(); i++)
				{
					var skeletonId:String = skeletonList[i].text().toString();
					skeletonId = skeletonId.indexOf("#") != -1 ? skeletonId.substr(1) : skeletonId;
					
					controller.skin.skeletons.push(skeletonId);
				}
			}
			else if(controller.morph)
			{
				
			}
			else
				throw new Error("A COLLADA controller needs one of <skin> or <morph> elements!");
				
			if(!_controllers[instance])
				_controllers[instance] = new Array();
			_controllers[instance].push(controller);
		}
		
		/**
		 * Parses all COLLADA instance_material elements to prepare for PV3D materials.
		 */ 
		private function parseInstanceMaterials():void
		{
			_numBitmaps = 0;
			_loadedBitmaps = 0;
			_queuedMaterials = new Object();
			_materialSymbol = new Object();
			_materialTarget = new Object();
			
			var instances:XMLList = this.COLLADA..instance_material;
			for(var i:int = 0; i < instances.length(); i++)
			{
				var instance:XML = instances[i];
				var symbol:String = instance.@symbol.toString();
				var target:String = instance.@target.toString().substr(1);
				
				var material:MaterialObject3D = this.materials.getMaterialByName(symbol);
				if(material)
					continue;
					
				_materialTarget[symbol] = target;
				_materialSymbol[target] = symbol;
			}
			
			for(var materialID:String in _materialSymbol)
				parseMaterial(materialID, _materialSymbol[materialID]);
		}
		
		/**
		 * Parses the COLLADA library_visual_scenes element.
		 */
		private function parseLibraryVisualScenes():void
		{
			var node:XMLList = this.COLLADA.library_visual_scenes.visual_scene;
			
			this._visual_scene = new Object();
			
			for(var i:int = 0; i < node.length(); i++)
			{
				var vscene:ColladaVisualScene = new ColladaVisualScene(node[i]);
				
				this._visual_scene[vscene.id] = vscene;
			}
		}
		
		/**
		 * Parses a COLLADA material element.
		 * 
		 * @param	id
		 * @param	symbol
		 */ 
		private function parseMaterial(id:String, symbol:String):void
		{
			var materialNode:XML = this.COLLADA.library_materials.material.(@id == id)[0];
			if(!materialNode)
				throw new Error("Can't find material element with id='" + id + "'");
				
			var instanceEffectNode:XML = materialNode.instance_effect[0];
			if(!instanceEffectNode)
				throw new Error("Can't find instance_effect element for material with id='" + id + "'");
				
			var effectUrl:String = instanceEffectNode.@url.toString().substr(1);
			
			parseEffect(effectUrl, symbol);
		}	
		
		/**
		 * Parses a COLLADA mesh element.
		 * 
		 * @param	node
		 * @param	instance
		 */
		private function parseMesh(node:XML, instance:DisplayObject3D):void
		{
			var children:XMLList = node.children();
			var num:int = children.length();

			for(var i:int = 0; i < num; i++)
			{
				var child:XML = children[i];
				switch(String(child.localName()))
				{	
					case "triangles":
						parseTriangles(child, instance);
						break;
							
					default:
						break;	
				}
			}
		}
		
		/**
		 * 
		 */ 
		private function buildNode(node:XML, name:String):DisplayObject3D
		{
			var controller:XML = node.instance_controller[0];
			
			if(controller)
			{
				if(String(controller.localName()) != "instance_controller")
				throw new Error("Not a instance_controller element!");
			
				var url:String = controller.@url.toString().substr(1);
				
				var controllerNode:XML = this.COLLADA..controller.(@id == url)[0];
				if(!controllerNode)
					throw new Error("Could not find controller with id='" + url + "'");
					
				var ctrl:ColladaController = new ColladaController(controllerNode);
				
				if(ctrl.skin)
				{
					return null;
				}
				else
				{
					return null;
				}
			}	
			else if(node.instance_geometry[0])
			{
				return new TriangleMesh3D(null, [], [], name);
			}
			else
			{
				return new DisplayObject3D(name);
			}
		}
		
		/**
		 * Parses a COLLADA <node> element.
		 * 
		 * @param	node	The node to parse
		 * @param	instance
		 */ 
		private function parseNode(node:XML, parent:DisplayObject3D = null):void
		{
			var id:String = node.@id.toString();
			var sid:String = node.@sid.toString();
			var name:String = node.@name.toString();
			var type:String = node.@type.toString();
			
			var i:int;
			var values:Array;
			var transformStack:Array = new Array();
			var transformSID:Array = new Array();
			var transformTypes:Array = new Array();
			
			type = type == "JOINT" ? type : "NODE";
			
			var instance:DisplayObject3D = parent.addChild(buildNode(node, name));
			
			// loop over children
			var children:XMLList = node.children();
			var num:int = children.length();
			
			for(i = 0; i < num; i++)
			{
				var child:XML = children[i];
				var nodeName:String = String(child.localName());
				
				var csid:String = child.@sid.toString();
				
				switch(nodeName)
				{
					case "asset":
						break;
					case "lookat":
						break;
					case "matrix":
						values = ColladaElement.parseStringArray(child);
						transformStack.push(new Matrix3D(values));
						transformSID.push(csid);
						transformTypes.push("matrix");
						break;
					case "rotate":
						values = ColladaElement.parseStringArray(child);
						transformStack.push(Matrix3D.rotationMatrix(values[0], values[1], values[2], values[3]*(Math.PI/180)));
						transformSID.push(csid);
						transformTypes.push("rotate");
						break;
					case "scale":
						values = ColladaElement.parseStringArray(child);
						transformStack.push(Matrix3D.scaleMatrix(values[0], values[1], values[2]));
						transformSID.push(csid);
						transformTypes.push("scale");
						break;
					case "skew":
						break;
					case "translate":
						values = ColladaElement.parseStringArray(child);
						transformStack.push(Matrix3D.translationMatrix(values[0], values[1], values[2]));
						transformSID.push(csid);
						transformTypes.push("translate");
						break;
					case "instance_camera":
						break;
					case "instance_controller":
						parseInstanceController(child, instance);
						break;
					case "instance_geometry":
						var geomId:String = child.@url.toString().substr(1);
						var bindMaterialNode:XML = child.bind_material[0];
						if(bindMaterialNode)
							instance.material = parseBindMaterial(bindMaterialNode);
						parseGeometry(this.COLLADA..geometry.(@id == geomId)[0], instance); 
						break;
					case "instance_light":
						break;
					case "instance_node": // Allows the node to instantiate a hierarchy of other nodes.  0 or more.
						break;
					case "node":
						parseNode(child, instance);
						break;
					case "extra":
						break;
					default:
						trace("[WARNING] DAE#parseNode => unknown childnode: " + nodeName);
						break;
				}
			}
			
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for(i = 0; i < transformStack.length; i++)
				matrix = Matrix3D.multiply(matrix, transformStack[i]);
				
			instance.copyTransform(matrix);
			if(instance is TriangleMesh3D)
			{
				TriangleMesh3D(instance).geometry.ready = true;
			}
			
			// save COLLADA id and sid
			_objectToID[ instance ] = id;
			_objectToSID[ instance ] = sid;
			_idToObject[ id ] = instance;
			_sidToObject[ sid ] = instance;
			
			// save the matrix stack
			_transformStack[ instance ] = transformStack;
			
			// save the SID's for each matrix in the stack
			_transformSID[ instance ] = transformSID;
			
			_transformTypes[ instance ] = transformTypes;
		}
		
		/**
		 * Parses the COLLADA scene element
		 */ 
		private function parseScene():void
		{
			var sceneList:XMLList = this.COLLADA..instance_visual_scene;
			if(sceneList == new XMLList())
				throw new Error("DAE#parseScene: can't find a <instance_visual_scene> element!");
			
			var vscene:ColladaVisualScene = this._visual_scene[ sceneList[0].@url.toString().substr(1) ];
			
			parseVisualScene(vscene);
		}
		
		/**
		 * Parses a visual scene.
		 *
		 * @param	vscene	The vscene to parse. @see org.ascollada.core.DaeVisualScene
		 */  
		private function parseVisualScene(vscene:ColladaVisualScene):void
		{
			var scene:DisplayObject3D = new DisplayObject3D(vscene.id);
			
			var children:XMLList = vscene.node.children();
			var num:int = children.length();

			for(var i:int = 0; i < num; i++)
			{
				var child:XML = children[i];
				var nodeName:String = String(child.localName());
				
				switch(nodeName)
				{	
					case "node":
						parseNode(child, scene);
						break;
					
					case "extra":
						break;
						
					default:
						trace("" + nodeName);
						break;	
				}
			}

			this.addChild(scene);
		}
		
		/**
		 * Parses a COLLADA triangles element.
		 * 
		 * @param	node
		 * @param	instance
		 * @param	material
		 */
		private function parseTriangles(node:XML, instance:DisplayObject3D, material:MaterialObject3D = null):void
		{
			instance.geometry = instance.geometry || new GeometryObject3D();
			instance.geometry.vertices = instance.geometry.vertices || new Array();
			instance.geometry.faces = instance.geometry.faces || new Array();
			
			material = material || instance.material;

			var startVertex:uint = instance.geometry.vertices.length;
			var uvs:Array = new Array();
			var normals:Array = new Array();
			var inputList:XMLList = node..input;
			var input:ColladaInput;
			var inputs:Array = new Array();
			var maxOffset:uint = 0;
			var i:int, j:int;
			
			for(i = 0; i < inputList.length(); i++)
			{
				input = new ColladaInput(inputList[i]);
				
				inputs.push(input);
				
				maxOffset = Math.max(maxOffset, input.offset);

				var sourceList:XMLList = node.parent()..source.(@id == input.source);				
				if(sourceList == new XMLList())
				{
					if(input.semantic == "VERTEX")
					{
						input = new ColladaInput(node.parent()..vertices[0].input[0]);
						input.semantic = "VERTEX";
					}
				}
				
				sourceList = node.parent()..source.(@id == input.source);
				
				var source:ColladaSource = new ColladaSource(sourceList[0]);
				for(j = 0; j < source.data.length; j++)
				{
					var data:Array = source.data[j];
					 
					switch(input.semantic)
					{
						case "NORMAL":
							normals.push(new Vertex3D(data[0], data[1], data[2]));
							break;
						case "TEXCOORD":
							uvs.push(new NumberUV(data[0], data[1]));
							break;
						case "VERTEX":
							var v:Vertex3D = new Vertex3D(data[0], data[1], data[2]);
							instance.geometry.vertices.push(v);
							break;
						default:
							break;
					}
				}
			}
			
			// build triangles!
			var pList:XMLList = node..p;
			
			for(i = 0; i < pList.length(); i++)
			{
				var p:Array = ColladaElement.parseStringArray(pList[i]);
				
				var tri:Array = new Array();
				var uv:Array = new Array();
					
				for(j = 0; j < p.length; j += (maxOffset+1))
				{	
					for(var k:int = 0; k < inputs.length; k++)
					{
						input = inputs[k];
						var idx:int = parseInt(p[j+input.offset], 10);
	
						switch(input.semantic)
						{
							case "NORMAL":
								break;
							case "TEXCOORD":
								uv.push(uvs[idx]);
								break;
							case "VERTEX":
								tri.push(instance.geometry.vertices[startVertex+idx]);
								break;
							default:
								break;
						}
					}
					
					if(tri.length == 3)
					{
						if(uv.length < 3)
							uv = [new NumberUV(), new NumberUV(), new NumberUV()];

						instance.geometry.faces.push(new Triangle3D(instance, tri, material, uv));	
						
						tri = new Array();
						uv = new Array();
					}
				}
			}
		}

		private var _scenes:Object;
		private var _visual_scene:Object;
		private var _materialSymbol:Object;
		private var _materialTarget:Object;
		private var _numBitmaps:uint;
		private var _loadedBitmaps:uint;
		private var _queuedMaterials:Object;
		private var _animatedObjects:Dictionary;
		private var _queuedAnimations:Array;
		private var _numAnimations:uint;
		private var _skinnedObjects:Dictionary;
		
		/** */
		private var _channels:Dictionary;
		
		/** */
		private var _controllers:Dictionary;
		
		/** ID to object. */
		private var _idToObject:Object;
		
		/** Object to ID */
		private var _objectToID:Dictionary;
		
		/** SID to object. */
		private var _sidToObject:Object;
		
		/** Object to SID */
		private var _objectToSID:Dictionary;
		
		/** Stack of matrices for each child. Used by animations. */
		private var _transformStack:Dictionary;
		
		/** SID of each matrix in the stack. Used by animation. */
		private var _transformSID:Dictionary;
		
		/** Type of transform for each matrix in the stack. Used by animation. */
		private var _transformTypes:Dictionary;
	}
}
