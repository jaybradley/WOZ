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
	/**
	 * @author Tim Knip
	 */ 
	public class AnimationKeyFrame3D
	{
		public static const INTERPOLATION_LINEAR:String = "LINEAR";
		public static const INTERPOLATION_BEZIER:String = "BEZIER";
		
		/** */
		public var time:Number;
		
		/** */
		public var output:Array;
		
		/** */
		public var interpolation:String;
		
		/** */
		public var inTangent:Array;
		
		/** */
		public var outTangent:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param	time
		 * @param	output
		 * @param	interpolation
		 * @param	inTangent
		 * @param	outTangent
		 */ 
		public function AnimationKeyFrame3D(time:Number, output:Array = null, interpolation:String = null, inTangent:Array = null, outTangent:Array = null)
		{
			this.time = time;
			this.output = output || new Array();
			this.interpolation = interpolation || INTERPOLATION_LINEAR;
			this.inTangent = inTangent || new Array();
			this.outTangent = outTangent || new Array();
		}
	}
}