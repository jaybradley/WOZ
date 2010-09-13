﻿/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org � blog.papervision3d.org � osflash.org/papervision3d
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
//                                               GeometryObject3D: Points
package org.papervision3d.core.geom {
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.culling.IObjectCuller;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.GeometryObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	* The Vertices3D class lets you create and manipulate groups of vertices.
	*
	*/
	public class Vertices3D extends DisplayObject3D
	{
		// ___________________________________________________________________________________________________
		//                                                                                               N E W
		// NN  NN EEEEEE WW    WW
		// NNN NN EE     WW WW WW
		// NNNNNN EEEE   WWWWWWWW
		// NN NNN EE     WWW  WWW
		// NN  NN EEEEEE WW    WW

		/**
		* Creates a new Points object.
		*
		* The Points GeometryObject3D class lets you create and manipulate groups of vertices.
		*
		* @param	vertices	An array of Vertex3D objects for the vertices of the mesh.
		* <p/>
		* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created GeometryObject3D.
		* <p/>
		* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
		* <p/>
		* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
		*/
		public function Vertices3D( vertices:Array, name:String=null, initObject:Object=null )
		{
			super( name, new GeometryObject3D(), initObject );
			this.geometry.vertices = vertices || new Array();
		}

		/**
		 * Clones this object.
		 * 
		 * @return	The cloned DisplayObject3D.
		 */ 
		public override function clone():DisplayObject3D
		{
			var object:DisplayObject3D = super.clone();
			var verts:Vertices3D = new Vertices3D(null, object.name);
			
			verts.material = object.material;
			if(object.materials)
				verts.materials = object.materials.clone();
				
			if(this.geometry)
				verts.geometry = this.geometry.clone(verts);
				
			verts.copyTransform(this.transform);
			
			return verts;
		}
		
		// ___________________________________________________________________________________________________
		//                                                                                   T R A N S F O R M
		// TTTTTT RRRRR    AA   NN  NN  SSSSS FFFFFF OOOO  RRRRR  MM   MM
		//   TT   RR  RR  AAAA  NNN NN SS     FF    OO  OO RR  RR MMM MMM
		//   TT   RRRRR  AA  AA NNNNNN  SSSS  FFFF  OO  OO RRRRR  MMMMMMM
		//   TT   RR  RR AAAAAA NN NNN     SS FF    OO  OO RR  RR MM M MM
		//   TT   RR  RR AA  AA NN  NN SSSSS  FF     OOOO  RR  RR MM   MM

		/**
		* Projects three dimensional coordinates onto a two dimensional plane to simulate the relationship of the camera to subject.
		*
		* This is the first step in the process of representing three dimensional shapes two dimensionally.
		*
		* @param	camera		Camera.
		*/
		public override function project( parent :DisplayObject3D,  renderSessionData:RenderSessionData ):Number
		{
			super.project( parent, renderSessionData );

			if( this.culled )
				return 0;
				
			if( renderSessionData.camera is IObjectCuller )
				return projectFrustum(parent, renderSessionData);
				
			var view:Matrix3D = this.view,

			// Camera
			m11 :Number = view.n11,
			m12 :Number = view.n12,
			m13 :Number = view.n13,
			m21 :Number = view.n21,
			m22 :Number = view.n22,
			m23 :Number = view.n23,
			m31 :Number = view.n31,
			m32 :Number = view.n32,
			m33 :Number = view.n33,
			vx	:Number,
			vy	:Number,
			vz	:Number,
			s_x	:Number,
			s_y	:Number,
			s_z	:Number,
			vertex:org.papervision3d.core.geom.renderables.Vertex3D, 
			screen:Vertex3DInstance,
			persp :Number,

			vertices :Array  = this.geometry.vertices,
			i        :int    = vertices.length,

			focus    :Number = renderSessionData.camera.focus,
			fz       :Number = focus * renderSessionData.camera.zoom;
			
			while( vertex = vertices[--i] )
			{
				// Center position
				vx = vertex.x;
				vy = vertex.y;
				vz = vertex.z;
				
				s_z = vx * m31 + vy * m32 + vz * m33 + view.n34;
				
				screen = vertex.vertex3DInstance;
		
				if( screen.visible = ( s_z > 0 ) )
				{
					s_x = vx * m11 + vy * m12 + vz * m13 + view.n14;
					s_y = vx * m21 + vy * m22 + vz * m23 + view.n24;
					
					persp = fz / (focus + s_z);
					screen.x = s_x * persp;
					screen.y = s_y * persp;
					screen.z = s_z;
				}
			}

			return 0; //screenZ;
		}

		/**
		 * 
		 * @param	parent
		 * @param	camera
		 * @param	sorted
		 * @return
		 */
		public function projectFrustum( parent :DisplayObject3D, renderSessionData:RenderSessionData ):Number 
		{
			
			var view:Matrix3D = this.view,
				viewport:Rectangle = renderSessionData.camera.viewport,
				m11 :Number = view.n11,
				m12 :Number = view.n12,
				m13 :Number = view.n13,
				m21 :Number = view.n21,
				m22 :Number = view.n22,
				m23 :Number = view.n23,
				m31 :Number = view.n31,
				m32 :Number = view.n32,
				m33 :Number = view.n33,
				m41 :Number = view.n41,
				m42 :Number = view.n42,
				m43 :Number = view.n43,
				vx	:Number,
				vy	:Number,
				vz	:Number,
				s_x	:Number,
				s_y	:Number,
				s_z	:Number,
				s_w :Number,
				vpw :Number = viewport.width / 2,
				vph :Number = viewport.height / 2,
				vertex : Vertex3D, 
				screen:Vertex3DInstance,
				vertices :Array  = this.geometry.vertices,
				i        :int    = vertices.length;
			
			while( vertex = vertices[--i] )
			{
				// Center position
				vx = vertex.x;
				vy = vertex.y;
				vz = vertex.z;
				
				s_z = vx * m31 + vy * m32 + vz * m33 + view.n34;
				s_w = vx * m41 + vy * m42 + vz * m43 + view.n44;
				
				screen = vertex.vertex3DInstance;
				
				// to normalized clip space (0.0 to 1.0)
				// NOTE: can skip and simply test (s_z < 0) and save a div
				s_z /= s_w;
			
				// is point between near- and far-plane?
				if( screen.visible = (s_z > 0 && s_z < 1) )
				{
					// to normalized clip space (-1,-1) to (1, 1)
					s_x = (vx * m11 + vy * m12 + vz * m13 + view.n14) / s_w;
					s_y = (vx * m21 + vy * m22 + vz * m23 + view.n24) / s_w;
					
					// NOTE: optionally we can flag screen verts here 
					//screen.visible = (s_x > -1 && s_x < 1 && s_y > -1 && s_y < 1);
					
					// project to viewport.
					screen.x = s_x * vpw;
					
					screen.y = s_y * vph;
					
					//Papervision3D.logger.debug( "sx:" + screen.x + " " +screen.y );
					// NOTE: z not lineair, value increases when nearing far-plane.
					screen.z = s_z*s_w;
				}
			}
			
			return 0;
		}
		
		/**
		* Calculates 3D bounding box.
		*
		* @return	{minX, maxX, minY, maxY, minZ, maxZ}
		*/
		public function boundingBox():Object
		{
			var vertices :Object = this.geometry.vertices;
			var bBox     :Object = new Object();

			bBox.min  = new Number3D();
			bBox.max  = new Number3D();
			bBox.size = new Number3D();

			for( var i:String in vertices )
			{
				var v:org.papervision3d.core.geom.renderables.Vertex3D = vertices[Number(i)];

				bBox.min.x = (bBox.min.x == undefined)? v.x : Math.min( v.x, bBox.min.x );
				bBox.max.x = (bBox.max.x == undefined)? v.x : Math.max( v.x, bBox.max.x );

				bBox.min.y = (bBox.min.y == undefined)? v.y : Math.min( v.y, bBox.min.y );
				bBox.max.y = (bBox.max.y == undefined)? v.y : Math.max( v.y, bBox.max.y );

				bBox.min.z = (bBox.min.z == undefined)? v.z : Math.min( v.z, bBox.min.z );
				bBox.max.z = (bBox.max.z == undefined)? v.z : Math.max( v.z, bBox.max.z );
			}

			bBox.size.x = bBox.max.x - bBox.min.x;
			bBox.size.y = bBox.max.y - bBox.min.y;
			bBox.size.z = bBox.max.z - bBox.min.z;

			return bBox;
		}

		public function transformVertices( transformation:Matrix3D ):void
		{
			var m11 :Number = transformation.n11,
			m12 :Number = transformation.n12,
			m13 :Number = transformation.n13,
			m21 :Number = transformation.n21,
			m22 :Number = transformation.n22,
			m23 :Number = transformation.n23,
			m31 :Number = transformation.n31,
			m32 :Number = transformation.n32,
			m33 :Number = transformation.n33,

			m14 :Number = transformation.n14,
			m24 :Number = transformation.n24,
			m34 :Number = transformation.n34,

			vertices :Array  = this.geometry.vertices,
			i        :int    = vertices.length,

			vertex   :org.papervision3d.core.geom.renderables.Vertex3D;

			// trace( "transformed " + i ); // DEBUG

			while( vertex = vertices[--i] )
			{
				// Center position
				var vx :Number = vertex.x;
				var vy :Number = vertex.y;
				var vz :Number = vertex.z;

				var tx :Number = vx * m11 + vy * m12 + vz * m13 + m14;
				var ty :Number = vx * m21 + vy * m22 + vz * m23 + m24;
				var tz :Number = vx * m31 + vy * m32 + vz * m33 + m34;

				vertex.x = tx;
				vertex.y = ty;
				vertex.z = tz;
			}
		}
	}
}