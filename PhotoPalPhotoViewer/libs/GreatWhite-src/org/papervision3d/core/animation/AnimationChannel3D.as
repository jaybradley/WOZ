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
 
package org.papervision3d.core.animation
{
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author Tim Knip
	 */ 
	public class AnimationChannel3D
	{		
		public static const TYPE_SINGLE_PROPERTY:uint = 0;
		public static const TYPE_BAKED_TRANSFORM:uint = 1;
		public static const TYPE_MULTI_TRANSFORM:uint = 2;
		
		/** The target for this animation */
		public var target:DisplayObject3D;
		
		/** */
		public var minTime:Number;
		
		/** */
		public var maxTime:Number;
		
		/** */
		public function get keyFrames():Array { return _keyframes; }
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 */ 
		public function AnimationChannel3D(target:DisplayObject3D, property:*, type:uint = TYPE_SINGLE_PROPERTY)
		{
			this.target = target;
			this.minTime = this.maxTime = 0;
			
			_keyframes = new Array();
			
			setTargetProperty(property, type);
		}
		
		/**
		 * Adds a new keyframe.
		 * 
		 * @param	keyframe
		 * 
		 * @return	The added keyframe.
		 */ 
		public function addKeyFrame(keyframe:AnimationKeyFrame3D):AnimationKeyFrame3D
		{
			if(_keyframes.length)
			{
				this.minTime = Math.min(this.minTime, keyframe.time);
				this.maxTime = Math.max(this.maxTime, keyframe.time);
			}
			else
			{
				this.minTime = this.maxTime = keyframe.time;
			}
			
			_keyframes.push(keyframe);
			
			return keyframe;
		}
		
		/**
		 * Sets this channel's target property.
		 * 
		 * @param	property
		 * @param	type
		 */ 
		public function setTargetProperty(property:*, type:uint = TYPE_SINGLE_PROPERTY):void
		{
			_type = type;
			
			switch(_type)
			{
				case TYPE_BAKED_TRANSFORM:
					if(!(property is Matrix3D))
						throw new Error("passed in property should be of type Matrix3D!");
					_matrixProperty = property as Matrix3D;
					break;
				
				case TYPE_MULTI_TRANSFORM:
					if(!(property is Array))
						throw new Error("passed in property should be of type Array!");
					_arrayProperty = property as Array;
					for each(var prop:* in _arrayProperty)
					{
						if(!(prop is Matrix3D))
							throw new Error("The passed in Array should contain only objects with type Matrix3D!");	
					}
					break;
						
				case TYPE_SINGLE_PROPERTY:
				default:
					if(!(property is String))
						throw new Error("passed in property should be of type String!");
					_type = TYPE_SINGLE_PROPERTY;
					_stringProperty = property as String;
					break;
			}		
		}
		
		/** */
		private var _type:uint;
		
		/** */
		private var _keyframes:Array;
		
		/** */
		private var _stringProperty:String;
		
		/** */
		private var _arrayProperty:Array;
		
		/** */
		private var _matrixProperty:Matrix3D;
	}
}