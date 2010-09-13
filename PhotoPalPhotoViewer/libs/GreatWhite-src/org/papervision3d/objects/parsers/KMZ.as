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

package org.papervision3d.objects.parsers {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	import nochump.util.zip.*;
	
	import org.ascollada.namespaces.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.utils.*;
	
	/**
	 * @author Tim Knip
	 */
	public class KMZ extends TriangleMesh3D {
		
		/** The DAE */
		public var dae : DAE;
		
		/**
		 * Constructor.
		 */
		public function KMZ( name : String = null ) : void {
			super(new WireframeMaterial(), [], [], name);
		}
		
		/**
		 * Loads a KMZ.
		 *
		 * @param	asset	URL or ByteArray.
		 */
		public function load( asset : *, materials : MaterialsList = null ) : void {
			
			this.materials = materials || new MaterialsList();
			
			if(asset is String) {
				var loader : URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
	            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader.load(new URLRequest(String(asset)));
			} else if(asset is ByteArray) {
				parse(asset as ByteArray);
			} else {
				throw new Error("KMZ#load : don't know how to load asset: " + asset);
			}
		}
		
		private function progressHandler( event : ProgressEvent ) : void {
			dispatchEvent(event);
		}
		private function securityErrorHandler( event : SecurityErrorEvent ) : void {
			dispatchEvent(event);
		}
		private function httpStatusHandler( event : HTTPStatusEvent ) : void {
			dispatchEvent(event);
		}
		private function ioErrorHandler( event : IOErrorEvent ) : void {
			dispatchEvent(event);
		}
		
		/**
		 * Gets the COLLADA from the zip.
		 *
		 * @param	zipFile
		 */
		private function getColladaFromZip( zipFile : ZipFile ) : ByteArray  {
			for(var i:int = 0; i < zipFile.entries.length; i++) {
			    var entry:ZipEntry = zipFile.entries[i];
			
			    // extract the entry's data from the zip
			    var data:ByteArray = zipFile.getInput(entry);
		
				if(entry.name.toLowerCase().indexOf(".dae") != -1) {
					return data;
				}
			}
			return null;
		}
		
		/**
		 * The KMZ was successfully loaded.
		 *
		 * @param 	event
		 */
		private function onLoadComplete( event : Event ) : void {
			var loader : URLLoader = event.target as URLLoader;
			parse(loader.data);
		}
		
		/**
		 * A texture was successfully loaded.
		 *
		 * @param 	event
		 */
		private function onTextureComplete( event : Event = null ) : void {
			if(event && event.target is Bitmap) {
				
				_loadedTextures++;
				
				var loader : Loader = event.target.parent as Loader;
				var xml : XML = new XML(_loadedDAE);
				var effects : XMLList = xml..collada::library_effects..collada::effect;

				for each(var effect : XML in effects) {
					try {
						var id  :String = effect.@id.toString();
						var images : XMLList = effect..collada::init_from;
				
						for each(var image:XML in images) {
							var init_from : String = String(image.text());
							var img:XML = xml..collada::image.(@id == init_from)..collada::init_from[0];
							var img_url : String = img.toString();
							var url : String = "#" + id;
							var mat:XML = xml..collada::material.(collada::instance_effect.@url == url)[0];
					
							if(img_url.indexOf(loader.name) != -1) {
								var material : BitmapMaterial = new BitmapMaterial(event.target.bitmapData);
								
								material.tiled = true;
								
								this.materials.addMaterial(material, String(mat.@name));
							}
						}
					} catch(e:Error) {
				
					}
				}
			}
			
			if(_loadedTextures == _totalTextures) {
				this.dae = new DAE();
				this.dae.addEventListener(FileLoadEvent.LOAD_COMPLETE, onColladaComplete);
				this.dae.load(_loadedDAE, this.materials);
			}
		}
		
		/**
		 * 
		 */
		private function onColladaComplete( event : Event ) : void {
			this.addChild(this.dae);
			dispatchEvent(event);
		}
		
		/**
		 * Parse the KMZ data.
		 *
		 * @param	data
		 */
		private function parse( data : ByteArray ) : void {
			
			var zipFile:ZipFile = new ZipFile(data);
			
			_loadedDAE = getColladaFromZip(zipFile);
			_totalTextures = numTexturesInZip(zipFile);
			_loadedTextures = 0;
			
			if(_totalTextures == 0) {
				onTextureComplete(null);
				return;
			}
			
			for(var i:int = 0; i < zipFile.entries.length; i++) {
			    var entry:ZipEntry = zipFile.entries[i];
			
			    // extract the entry's data from the zip
			    var data:ByteArray = zipFile.getInput(entry);
		
				if(entry.name.toLowerCase().indexOf(".png") != -1 || entry.name.toLowerCase().indexOf(".jpg") != -1) {
					var loader:Loader = new Loader();
					loader.name = entry.name;
					loader.addEventListener("added", onTextureComplete);
					loader.loadBytes(data);
				} 
			}
		}
		
		/**
		 * Gets the number of textures inside a zip.
		 *
		 * @param	zipFile
		 *
		 * @return	The number of textures.
		 */
		private function numTexturesInZip( zipFile : ZipFile ) : uint {
			var count : uint = 0;
			for(var i:int = 0; i < zipFile.entries.length; i++) {
			    var entry:ZipEntry = zipFile.entries[i];
			
			    // extract the entry's data from the zip
			    var data:ByteArray = zipFile.getInput(entry);
		
				if(entry.name.toLowerCase().indexOf(".png") != -1 || entry.name.toLowerCase().indexOf(".jpg") != -1) {
					count++;
				}
			}
			return count;
		}
		
		/** */
		private var _loadedTextures : uint;
		
		/** */
		private var _totalTextures  : uint;
		
		/** */
		private var _loadedDAE		: ByteArray;
	}
}
