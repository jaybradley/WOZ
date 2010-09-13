/*
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
//                                                       GeometryObject3D

package org.papervision3d.core.proto
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.AxisAlignedBoundingBox;
	import org.papervision3d.core.math.BoundingSphere;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	* The GeometryObject3D class contains the mesh definition of an object.
	*/
	public class GeometryObject3D extends EventDispatcher
	{
		
		protected var _boundingSphere:BoundingSphere;
		protected var _boundingSphereDirty :Boolean = true;
		protected var _aabb:AxisAlignedBoundingBox;
		protected var _aabbDirty:Boolean = true;
		
		/**
		 * 
		 */
		public var dirty:Boolean;
		
		/**
		* An array of Face3D objects for the faces of the mesh.
		*/
		public var faces    :Array;
	
		/**
		* An array of vertices.
		*/
		public var vertices :Array;
		public var _ready:Boolean = false;
		
		public function GeometryObject3D( initObject:Object=null ):void
		{
			dirty = true;
		}
		
		public function transformVertices( transformation:Matrix3D ):void {}
		
		public function transformUV( material:MaterialObject3D ):void
		{
			if( material.bitmap )
				for( var i:String in this.faces )
					faces[i].transformUV( material );
		}
		
		private function createVertexNormals():void
		{
			var tempVertices:Dictionary = new Dictionary(true);
			var face:Triangle3D;
			var vertex3D:Vertex3D;
			for each(face in faces){
				face.v0.connectedFaces[face] = face;
				face.v1.connectedFaces[face] = face;
				face.v2.connectedFaces[face] = face;
				tempVertices[face.v0] = face.v0;
				tempVertices[face.v1] = face.v1;
				tempVertices[face.v2] = face.v2;
			}	
			for each (vertex3D in tempVertices){
				vertex3D.calculateNormal();
			}
		}
		
		public function set ready(b:Boolean):void
		{
			if(b){
				createVertexNormals();
				this.dirty = false;
			}
			_ready = b;
		}
	
		public function get ready():Boolean
		{
			return _ready;
		}
		
		/**
		* Radius square of the mesh bounding sphere
		*/
		public function get boundingSphere():BoundingSphere
		{
			if( _boundingSphereDirty ){
				_boundingSphere = BoundingSphere.getFromVertices(vertices);
				_boundingSphereDirty = false;
			}
			return _boundingSphere;
		}
		
		/**
		 * Returns an axis aligned bounding box, not world oriented.
		 * 
		 * @Author Ralph Hauwert - Added as an initial test.
		 */
		public function get aabb():AxisAlignedBoundingBox
		{
			if(_aabbDirty){
				_aabb = AxisAlignedBoundingBox.createFromVertices(vertices);
				_aabbDirty = false;
			}
			return _aabb;
		}

		/**
		 * Clones this object.
		 * 
		 * @param	parent
		 * 
		 * @return	The cloned GeometryObject3D.
		 */ 
		public function clone(parent:DisplayObject3D = null):GeometryObject3D
		{
			var verts:Dictionary = new Dictionary();
			var geom:GeometryObject3D = new GeometryObject3D();
			var i:int;
			
			geom.vertices = new Array();			
			geom.faces = new Array();

			// clone vertices
			for(i = 0; i < this.vertices.length; i++)
			{
				var v:Vertex3D = this.vertices[i];
				verts[ v ] = v.clone();
				geom.vertices.push(verts[v]);
			}
			
			// clone triangles
			for(i = 0; i < this.faces.length; i++)
			{
				var f:Triangle3D = this.faces[i];
			
				var v0:Vertex3D = verts[ f.v0 ];
				var v1:Vertex3D = verts[ f.v1 ];	
				var v2:Vertex3D = verts[ f.v2 ];
				
				geom.faces.push(new Triangle3D(parent, [v0, v1, v2], f.material, f.uv));
			}
			
			return geom;
		}
		
		private var _numInstances:uint = 0;
	}
}