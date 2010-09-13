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
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author	Tim Knip
	 */  
	public class Animation3D
	{
		/** The target for this animation */
		public var target:DisplayObject3D;
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 */ 
		public function Animation3D(target:DisplayObject3D)
		{
			this.target = target;
			
			_channels = new Array();
		}
		
		/**
		 * Adds an AnimationChannel3D. @see org.papervision3d.core.animation.AnimationChannel3D
		 * 
		 * @param	channel	The channel to add.
		 * 
		 * @return	the added channel.
		 */ 
		public function addChannel(channel:AnimationChannel3D):AnimationChannel3D
		{
			channel.target = this.target;
			
			_channels.push(channel);
			
			return channel;
		}
		
		/**
		 * Removes an AnimationChannel3D. @see org.papervision3d.core.animation.AnimationChannel3D
		 * 
		 * @param	channel	The channel to remove.
		 * 
		 * @return	the removed channel or null on failure.
		 */ 
		public function removeChannel(channel:AnimationChannel3D):AnimationChannel3D
		{
			var removed:AnimationChannel3D = null;	
			var idx:int = -1;
			
			for(var i:int = 0; i < _channels.length; i++)
			{
				if(_channels[i] === channel)
				{
					i = idx;
					removed = _channels.splice(i, 1)[0] as AnimationChannel3D;
					break;	
				}
			}
			return removed;	
		}
		
		/** */
		private var _channels:Array;
	}
}