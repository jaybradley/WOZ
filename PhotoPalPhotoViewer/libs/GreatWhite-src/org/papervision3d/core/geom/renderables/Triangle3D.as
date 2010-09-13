﻿/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org • blog.papervision3d.org • osflash.org/papervision3d
 */

/*
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

// ______________________________________________________________________
//                                                                 Face3D

package org.papervision3d.core.geom.renderables {
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.command.RenderTriangle;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	* The Face3D class lets you render linear textured triangles. It also supports solid colour fill and hairline outlines.
	*
	*/
	public class Triangle3D extends AbstractRenderable implements IRenderable
	{
		/**
		* An array of Vertex3D objects for the three vertices of the triangle.
		*/
		public var vertices :Array;
	
		/**
		* A material id TODO
		*/
		public var _materialName :String;
	
		/**
		* A MaterialObject3D object that contains the material properties of the back of a single sided triangle.
		*/
	//	public var materialBack :MaterialObject3D;
		
		public var uv0:NumberUV;
		public var uv1:NumberUV;
		public var uv2:NumberUV;
		
		private var _uvArray:Array;
		/**
		* An array of {x,y} objects for the corresponding UV pixel coordinates of each triangle vertex.
		*/
		public function set uv(uv:Array):void
		{
			uv0 = NumberUV(uv[0]);
			uv1 = NumberUV(uv[1]);
			uv2 = NumberUV(uv[2]);
			_uvArray = uv;
		}
		
		public function get uv():Array
		{
			return _uvArray;	
		}
	
		// ______________________________________________________________________
	
		/**
		* [read-only] The average depth (z coordinate) of the transformed triangle. Also known as the distance from the camera. Used internally for z-sorting.
		*/
		public var screenZ :Number;
	
		/**
		* [read-only] A Boolean value that indicates that the face is visible, i.e. it's vertices are in front of the camera.
		*/
		public var visible :Boolean;
	
	
		/**
		* The object where the face belongs.
		*/
	//	public var object :Mesh3D;
	
	
		/**
		* [read-only] Unique id of this instance.
		*/
		public var id :Number;
		
		/**
		 * Used to store references to the vertices.
		 */
		public var v0:Vertex3D;
		public var v1:Vertex3D;
		public var v2:Vertex3D;
		
		/**
		 * The face normal
		 */
		public var faceNormal:Number3D;
		
		/**
		 * The transformed Face3DInstance
		 */
		public var face3DInstance:Triangle3DInstance;
		
		/**
		 * The do3d instance this triangle belongs too.
		 */
		 public var instance:DisplayObject3D;
		
		/**
		 * stores the material for this face.
		 */
		public var material:MaterialObject3D;
				
		//To be docced
		public var renderCommand:RenderTriangle;
		
		private static var _totalFaces:Number = 0;
		
		/**
		* The Face3D constructor lets you create linear textured or solid colour triangles.
		*
		* @param	vertices	An array of Vertex3D objects for the three vertices of the triangle.
		* @param	material	A MaterialObject3D object that contains the material properties of the triangle.
		* @param	uv			An array of {x,y} objects for the corresponding UV pixel coordinates of each triangle vertex.
		*/
		public function Triangle3D(do3dInstance:DisplayObject3D, vertices:Array, material:MaterialObject3D=null, uv:Array=null )
		{
			this.instance = do3dInstance;
			this.renderCommand = new RenderTriangle(this);
			
			//Setup this instance
			face3DInstance = new Triangle3DInstance(this, do3dInstance);
			
			// Vertices
			this.vertices = vertices;
			v0 = vertices[0];
			v1 = vertices[1];
			v2 = vertices[2];
			
			// Material, if passed from a materials list.
			this.material = material;
			this.uv = uv;
			this.id = _totalFaces++;
			
			createNormal();
		}
		
		public function createNormal():void
		{
			var vn0:Number3D = v0.toNumber3D(),
				vn1:Number3D = v1.toNumber3D(),
				vn2:Number3D = v2.toNumber3D(),
				vt1:Number3D = Number3D.sub(vn1,vn0),
				vt2:Number3D = Number3D.sub(vn2,vn0);
			faceNormal = Number3D.cross(vt1,vt2);
			faceNormal.normalize();
		}
		
		override public function getRenderListItem():IRenderListItem
		{
			return renderCommand;
		}
		
		public function updateVertices():void
		{
			v0 = vertices[0];
			v1 = vertices[1];
			v2 = vertices[2];
		}
		
		
	}
}