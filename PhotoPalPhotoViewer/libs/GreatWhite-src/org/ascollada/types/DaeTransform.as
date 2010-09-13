/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
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
 
package org.ascollada.types 
{
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeChannel;
	import org.ascollada.utils.Logger;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * @author	Tim Knip 
	 */
	public class DaeTransform 
	{
		/** type - required */
		public var type:String;
		
		/** sid - optional */
		public var sid:String;
		
		/** */
		public var values:Array;
		
		/** matrix created from type and values */
		public var matrix:Array;
		
		/**
		 * 
		 * @param	type
		 * @param	values
		 * @return
		 */	
		public function DaeTransform( type:String, sid:String, values:Array, yUp:Boolean = false ):void
		{
			this.type = type;
			this.sid = sid;
			this.values = values;
			
			_yUp = yUp;
			
			if( !validateValues() )
			{
				Logger.trace( "[ERROR] invalid values for this transform!" );
				throw new Error( "[ERROR] invalid values for this transform!" );
			}
			
			this.matrix = buildMatrix();
		}
		
		/**
		 * 
		 * @param	channel	the animation channel. @see org.ascollada.core.DaeChannel
		 * 
		 * @return
		 */
		public function buildAnimatedMatrices( channel:DaeChannel ):Array
		{
			var output:Array = channel.output;
			var matrices:Array = new Array();
			var i:int;
			
			switch( this.type )
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					if(channel.syntax.member == "ANGLE")
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( rotationMatrix(values[0], values[1], values[2], output[i]) );
					}
					else
						Logger.trace( " => => " + this.type + " " + channel.syntax );
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					if( channel.syntax.isFullAccess )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(output[i][0], output[i][1], output[i][2]) );
					}
					else if( channel.syntax.member == "X" )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(output[i], 0, 0) );						
					}
					else if( channel.syntax.member == "Y" )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(0, output[i], 0) );						
					}
					else if( channel.syntax.member == "Z" )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(0, 0, output[i]) );						
					}
					else
					{
						Logger.trace( " => => " + this.type + " " + channel.syntax );
					}
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					Logger.trace( " => buildAnimatedMatrices " + this.type );
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					if( channel.syntax.isFullAccess )
					{
						for( i = 0; i < channel.output.length; i++ )
							matrices.push( bakedMatrix(channel.output[i]) );
					}
					break;
				default:
					Logger.trace( " => unknown type " + this.type );
					break;
			}
			
			return matrices;
		}
		
		/**
		 * 
		 * @return
		 */
		public function buildMatrix():Array
		{
			var matrix:Array = null;
			
			switch( this.type )
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					matrix = rotationMatrix(values[0], values[1], values[2], values[3]);
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					matrix = translationMatrix(values[0], values[1], values[2]);
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					matrix = scaleMatrix(values[0], values[1], values[2]);
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					matrix = bakedMatrix(values);
					break;
				default:
					Logger.trace( "[ERROR] don't know how to create a matrix with type=" + this.type );
					throw new Error( "don't know how to create a matrix with type=" + this.type );
					break;
			}
			
			return matrix;
		}
		
		/**
		 * 
		 * @return
		 */
		public function validateValues():Boolean
		{
			var valid:Boolean = false;
			
			if( !this.values || !this.values.length )
				return false;
				
			switch( this.type )
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					valid = (this.values.length == 4);
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					valid = (this.values.length == 3);
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					valid = (this.values.length == 3);
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					valid = (this.values.length == 16);
					break;
				default:
					break;
			}
			
			return valid;
		}
		
		/**
		 * 
		 * @param	values
		 * @return
		 */
		private function bakedMatrix( values:Array ):Array
		{
			return values;
			if(!this._yUp)
			{
				var m : Matrix3D = new Matrix3D(values);
				
				var neg : Boolean = (m.det < 0);
				
				var tx:Number = m.n14;
				var ty:Number = m.n24;
				var tz:Number = m.n34;
				
				var sx:Number3D = new Number3D(m.n11, m.n12, m.n13);
				var sy:Number3D = new Number3D(m.n21, m.n22, m.n23);
				var sz:Number3D = new Number3D(m.n31, m.n32, m.n33);
				
				var rot : Number3D = Matrix3D.matrix2euler(m);
				rot.x *= (Math.PI/180);
				rot.y *= (Math.PI/180); 
				rot.z *= (Math.PI/180);  
				
			//	rot.x = neg ? -rot.x : rot.x;
			//	rot.y = neg ? -rot.y : rot.y;
			//	rot.z = neg ? -rot.z : rot.z;
				var q:Object = Matrix3D.euler2quaternion( rot.x, rot.y, rot.z ); // Swappe
				
				m = Matrix3D.quaternion2matrix( q.x, q.y, q.z, q.w );
				
				var sm : Matrix3D = Matrix3D.scaleMatrix(sx.modulo, sy.modulo, sz.modulo);
				
				if(neg)
				{
					//sm.n11 = -sm.n11;
					//sm.n22 = -sm.n22;
					//sm.n33 = -sm.n33;
				}
				
				m.calculateMultiply(m, sm);
				
				values = [
					m.n11, m.n12, m.n13, tx,
					m.n21, m.n22, m.n23, ty,
					m.n31, m.n32, m.n33, tz,
					m.n41, m.n42, m.n43, 0];
			}
			return values;
		}

		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	rad
		 * @return
		 */
		private function rotationMatrix( x:Number, y:Number, z:Number, deg:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			
			var rad:Number = deg * (Math.PI/180);
			var nCos:Number	= Math.cos( rad );
			var nSin:Number	= Math.sin( rad );
			var scos:Number	= 1 - nCos;

			var sxy	:Number = x * y * scos;
			var syz	:Number = y * z * scos;
			var sxz	:Number = x * z * scos;
			var sz	:Number = nSin * z;
			var sy	:Number = nSin * y;
			var sx	:Number = nSin * x;

			m[0] =  nCos + x * x * scos;
			m[1] = -sz   + sxy;
			m[2] =  sy   + sxz;

			m[4] =  sz   + sxy;
			m[5] =  nCos + y * y * scos;
			m[6] = -sx   + syz;

			m[8] = -sy   + sxz;
			m[9] =  sx   + syz;
			m[10] =  nCos + z * z * scos;
			
			return m;			
		}

		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		private function scaleMatrix( x:Number, y:Number, z:Number ):Array
		{
			var m:Array = [
				x, 0, 0, 0,
				0, y, 0, 0,
				0, 0, z, 0,
				0, 0, 0, 1
			];

			return m;
		}
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		private function translationMatrix( x:Number, y:Number, z:Number ):Array
		{
			var m:Array = [
				1, 0, 0, x,
				0, 1, 0, y,
				0, 0, 1, z,
				0, 0, 0, 1
			];
			return m;
		}
			
		private var _yUp:Boolean;

		static private var toDEGREES :Number = 180/Math.PI;
		static private var toRADIANS :Number = Math.PI/180;
	}
}
