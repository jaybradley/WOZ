/*
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
 
package org.ascollada.core
{
	import org.ascollada.namespaces.*;

	/**
	 * @author Tim Knip
	 */ 
	public class ColladaElement
	{
		use namespace collada;
		
		public var node:XML;
		public var id:String;
		public var name:String;
		public var sid:String;
		
		/**
		 * Constructor.
		 * 
		 * @param	node	The XML node to parse.
		 */ 
		public function ColladaElement(node:XML = null)
		{
			this.node = node;
			if(node)
				parse(node);
		}
		
		/**
		 * Parses a float array.
		 * 
		 * @param	node
		 */ 
		public static function parseFloatArray(node:XML):Array
		{
			var values:Array = parseStringArray(node);
			for(var i:int = 0; i < values.length; i++)
				values[i] = parseFloat(values[i]);
			return values;	
		}
		
		/**
		 * Parses a int array.
		 * 
		 * @param	node
		 */ 
		public static function parseIntArray(node:XML):Array
		{
			var values:Array = parseStringArray(node);
			for(var i:int = 0; i < values.length; i++)
				values[i] = parseInt(values[i], 10);
			return values;	
		}
		
		/**
		 * Parses a string array.
		 * 
		 * @param	node
		 */ 
		public static function parseStringArray(node:XML):Array
		{
			var raw:String = node.text().toString();	
			raw = raw.replace(/^\s+/, "");
			raw = raw.replace(/\s+$/, "");
			return raw.split(/\s+/);
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 
		public function parse(node:XML):void
		{
			this.id = node.attribute("id").toString();
			this.name = node.attribute("name").toString();
			this.sid = node.attribute("sid").toString();
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 		
		public function parseAsync(node:XML):void
		{
			
		}
	}
}