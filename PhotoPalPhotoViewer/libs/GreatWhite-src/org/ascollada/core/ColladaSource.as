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
 
package org.ascollada.core
{
	import org.ascollada.namespaces.*;
	
	/**
	 * @author Tim Knip
	 */
	public class ColladaSource extends ColladaElement
	{
		use namespace collada;
		
		public static const FLOAT:uint = 0;
		public static const NAME:uint = 1;
		public static const IDREF:uint = 2;
		public static const BOOL:uint = 3;
		public static const INT:uint = 4;
		
		/** */
		public var accessor:ColladaAccessor;
		
		/** */
		public var type:uint = 0;
		
		/** */
		public var async:Boolean;
		
		/** */
		public var data:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param	node
		 * @param	async
		 */ 
		public function ColladaSource(node:XML, async:Boolean=false)
		{
			this.async = async;
			
			super(node);		
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 
		override public function parse(node:XML):void
		{
			if(String(node.localName()) != "source")
				throw new Error("Not a COLLADA 'source' element!");	
				
			super.parse(node);
			
			this.accessor = new ColladaAccessor(this, node..accessor[0]);
			
			if(this.async)
				return;
				
			this.parseAsync(node);
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 
		override public function parseAsync(node:XML):void
		{
			// assume <float_array>
			var rawDataNode:XMLList = node..float_array;
			this.type = FLOAT;
			
			if(rawDataNode == new XMLList())
			{
				// nope, maybe a <Name_array>
				rawDataNode = node..Name_array;
				this.type = NAME;
			
				if(rawDataNode == new XMLList())
				{
					// nope, maybe a <IDREF_array>
					rawDataNode = node..IDREF_array;
					this.type = IDREF;
					
					if(rawDataNode == new XMLList())
					{
						// nope, maybe a <int_array>
						rawDataNode = node..int_array;
						this.type = INT;
	
						if(rawDataNode == new XMLList())
						{
							// nope, maybe a <bool_array>
							rawDataNode = node..bool_array;
							this.type = BOOL;
						}
					}
				}
			}
			
			// found data?
			if(rawDataNode == new XMLList())
				throw new Error("ColladaSource#parse: need one of <bool_array>, <float_array>, <int_array>, <Name_array>, or <IDREF_array>");
				
			this.data = ColladaElement.parseStringArray(rawDataNode[0]);
			
			// process the accessor
			var processedData:Array = new Array();
			var params:Array = this.accessor.params;
			
			for(var ptr:int = 0; ptr < this.data.length;)
			{
				var tmp:Array = new Array();
				var curParam:int = 0;
				
				for(var i:int = 0; i < this.accessor.stride; i++, ptr++)
				{
					var param:ColladaParam = params[curParam];
					/*
					switch(param.type)
					{
						case "float4x4":
							curParam += 16;
							curParam = curParam % this.accessor.stride;
							break;
						case "float":
						case "int":
						case "boolean":
						case "Name":
						default:
							curParam++;
					}
					
					// skip over empty param
					if(!param.name || !param.name.length)
						continue;
					*/	
					tmp.push(getValue(ptr));
				}
				processedData.push(tmp);
			}
			
			this.data = processedData;
		}
		
		/**
		 * Gets a safe value from the data.
		 * 
		 * @param	ptr		index into the data array.
		 * 
		 * @return	The value.
		 */ 
		private function getValue(ptr:uint):*
		{
			var value:*;
			
			switch(this.type)
			{
				case BOOL:
					value = this.data[ptr] == "true" ? true : false;
					break;
				case INT:
					value = parseInt(this.data[ptr], 10);
					break;
				case FLOAT:
					value = parseFloat(this.data[ptr]);
					break;
				default:	
					value = this.data[ptr];
					break;
			}
			
			return value;
		}
	}
}