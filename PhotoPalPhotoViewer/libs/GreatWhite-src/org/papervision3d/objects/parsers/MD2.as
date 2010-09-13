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
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;	

	/**
	 * Loads Quake 2 MD2 file with animation!
	 * </p>Please feel free to use, but please mention me!</p>
	 * 
	 * @author Philippe Ajoux (philippe.ajoux@gmail.com) adapted by Tim Knip(tim.knip at gmail.com).
	 * @website www.d3s.net
	 * @version 04.11.07:11:56
	 */
	public class MD2 extends TriangleMesh3D
	{
		/**
		 * Variables used in the loading of the file
		 */
		private var file:String;
		private var loader:URLLoader;
		private var loadScale:Number;
		
		/**
		 * MD2 Header data
		 * These are all the variables found in the md2_header_t
		 * C style struct that starts every MD2 file.
		 */
		private var ident:int, version:int;
		private var skinwidth:int, skinheight:int;
		private var framesize:int;
		private var num_skins:int, num_vertices:int, num_st:int;
		private var num_tris:int, num_glcmds:int, num_frames:int;
		private var offset_skins:int, offset_st:int, offset_tris:int;
		private var offset_frames:int, offset_glcmds:int, offset_end:int;
		private var fps:int;
		
		/**
		 * Constructor.
		 */
		public function MD2():void
		{
			super(null, new Array(), new Array());
		}
		
		/**
		 * Loads the MD2.
		 * 
		 * @param	asset	URL or ByteArray
		 * @param	material	The material for the MD2
		 * @param	fps		Frames per second
		 * @param	scale	Scale
		 */
		public function load(asset:*, material:MaterialObject3D = null, fps:int = 6, scale:Number = 1):void
		{
			this.loadScale = scale;
			this.fps = fps;
			this.visible = false;
			this.material = material || MaterialObject3D.DEFAULT;
			
			if(asset is ByteArray)
			{
				this.file = "";
				parse(asset as ByteArray);
			}
			else
			{
				this.file = String(asset);
				
				loader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
				loader.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
				
				try
				{
		            loader.load(new URLRequest(this.file));
				}
				catch(e:Error)
				{
					Papervision3D.log("error in loading MD2 file (" + this.file + ")");
				}
			}
		}
		
		/**
		 * <p>Parses the MD2 file. This is actually pretty straight forward.
		 * Only complicated parts (bit convoluded) are the frame loading
		 * and "metaface" loading. Hey, it works, use it =)</p>
		 * 
		 * @param	data	A ByteArray
		 */
		private function parse(data:ByteArray):void
		{
			var i:int, j:int, uvs:Array = new Array();
			var metaface:Object;
			data.endian = Endian.LITTLE_ENDIAN;
			
			// Read the header and make sure it is valid MD2 file
			readMd2Header(data);
			if (ident != 844121161 || version != 8)
				throw new Error("error loading MD2 file (" + file + "): Not a valid MD2 file/bad version");
				
			//---Vertice setup
			// be sure to allocate memory for the vertices to the object
			for (i = 0; i < num_vertices; i++)
				geometry.vertices.push(new Vertex3D());

			//---UV coordinates
			data.position = offset_st;
			for (i = 0; i < num_st; i++)
			{
				var uv:NumberUV = new NumberUV(data.readShort() / skinwidth, data.readShort() / skinheight);
				//uv.u = 1 - uv.u;
				uv.v = 1 - uv.v;
				uvs.push(uv);
			}

			//---Frame animation data
			data.position = offset_frames;
			readFrames(data);
			
			//---Faces
			// make sure to push the faces with allocated vertices to the object!
			data.position = offset_tris;
			for (i = 0; i < num_tris; i++)
			{
				metaface = {a: data.readUnsignedShort(), b: data.readUnsignedShort(), c: data.readUnsignedShort(),
					        ta: data.readUnsignedShort(), tb: data.readUnsignedShort(), tc: data.readUnsignedShort()};
				
				var v0:Vertex3D = geometry.vertices[metaface.a];
				var v1:Vertex3D = geometry.vertices[metaface.b];
				var v2:Vertex3D = geometry.vertices[metaface.c];
				
				var uv0:NumberUV = uvs[metaface.ta];
				var uv1:NumberUV = uvs[metaface.tb];
				var uv2:NumberUV = uvs[metaface.tc];

				geometry.faces.push(new Triangle3D(this, [v0, v1, v2], material, [uv0, uv1, uv2]));
			}
			
			geometry.ready = true;
	
			visible = true;
						
			Papervision3D.log("Parsed MD2: " + file + "\n vertices:" + 
							  geometry.vertices.length + "\n texture vertices:" + uvs.length +
							  "\n faces:" + geometry.faces.length + "\n frames: " );
	
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Reads in all the frames
		 */
		private function readFrames(data:ByteArray):void
		{
			var sx:Number, sy:Number, sz:Number;
			var tx:Number, ty:Number, tz:Number;
			var verts:Array
			var i:int, j:int, char:int;

			var t:uint = 0;
			
			for (i = 0; i < num_frames; i++)
			{				
				sx = data.readFloat();
				sy = data.readFloat();
				sz = data.readFloat();
				
				tx = data.readFloat();
				ty = data.readFloat();
				tz = data.readFloat();
				
				var frameName:String = "";
				
				for (j = 0; j < 16; j++)
					if ((char = data.readUnsignedByte()) != 0)
						frameName += String.fromCharCode(char);
				
				// Note, the extra data.position++ in the for loop is there 
				// to skip over a byte that holds the "vertex normal index"
				for (j = 0; j < num_vertices; j++, data.position++)
				{
					var v:Vertex3D = new Vertex3D(
						((sx * data.readUnsignedByte()) + tx) * loadScale, 
						((sy * data.readUnsignedByte()) + ty) * loadScale,
						((sz * data.readUnsignedByte()) + tz) * loadScale);
						
					if( i == 1 )
					{
						this.geometry.vertices[j].x = v.x;
						this.geometry.vertices[j].y = v.y;
						this.geometry.vertices[j].z = v.z;
					}
				}
			}
		}
		
		/**
		 * Reads in all that MD2 Header data that is declared as private variables.
		 * I know its a lot, and it looks ugly, but only way to do it in Flash
		 */
		private function readMd2Header(data:ByteArray):void
		{
			ident = data.readInt();
			version = data.readInt();
			skinwidth = data.readInt();
			skinheight = data.readInt();
			framesize = data.readInt();
			num_skins = data.readInt();
			num_vertices = data.readInt();
			num_st = data.readInt();
			num_tris = data.readInt();
			num_glcmds = data.readInt();
			num_frames = data.readInt();
			offset_skins = data.readInt();
			offset_st = data.readInt();
			offset_tris = data.readInt();
			offset_frames = data.readInt();
			offset_glcmds = data.readInt();
			offset_end = data.readInt();
		}

		/**
		 * 
		 */ 
		private function loadCompleteHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var data:ByteArray = loader.data;
			parse(data);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent(event);
		}
	}
}
