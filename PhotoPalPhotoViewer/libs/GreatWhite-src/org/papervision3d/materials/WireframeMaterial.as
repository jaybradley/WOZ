/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org  blog.papervision3d.org  osflash.org/papervision3d
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

// __________________________________________________________________________ WIREFRAME MATERIAL

package org.papervision3d.materials
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.material.TriangleMaterial;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	
	/**
	* The WireframeMaterial class creates a wireframe material, where only the outlines of the faces are drawn.
	* <p/>
	* Materials collects data about how objects appear when rendered.
	*/
	public class WireframeMaterial extends TriangleMaterial implements ITriangleDrawer
	{
		// ______________________________________________________________________ NEW

		/**
		* The WireframeMaterial class creates a wireframe material, where only the outlines of the faces are drawn.
		*
		* @param	asset				A BitmapData object.
		* @param	initObject			[optional] - An object that contains additional properties with which to populate the newly created material.
		*/
		public function WireframeMaterial( color:Number=0xFF00FF, alpha:Number=100, thickness:Number = 0 )
		{
			this.lineColor     = color;
			this.lineAlpha     = alpha;
			this.lineThickness = thickness;

			this.doubleSided = false;
		}
		
		/**
		 *  drawTriangle
		 */
		override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void
		{
			var x0:Number = face3D.v0.vertex3DInstance.x;
			var y0:Number = face3D.v0.vertex3DInstance.y;
			
			if( lineAlpha )
			{
				graphics.lineStyle( lineThickness, lineColor, lineAlpha );
				graphics.moveTo( x0, y0 );
				graphics.lineTo( face3D.v1.vertex3DInstance.x, face3D.v1.vertex3DInstance.y );
				graphics.lineTo( face3D.v2.vertex3DInstance.x, face3D.v2.vertex3DInstance.y );
				graphics.lineTo( x0, y0 );
				graphics.lineStyle();

				renderSessionData.renderStatistics.triangles++;
			}

		}

		// ______________________________________________________________________ TO STRING

		/**
		* Returns a string value representing the material properties in the specified WireframeMaterial object.
		*
		* @return	A string.
		*/
		public override function toString(): String
		{
			return 'WireframeMaterial - color:' + this.lineColor + ' alpha:' + this.lineAlpha;
		}
	}
}