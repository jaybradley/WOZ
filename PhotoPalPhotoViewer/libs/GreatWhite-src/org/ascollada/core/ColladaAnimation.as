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
	public class ColladaAnimation extends ColladaElement
	{
		use namespace collada;
		
		public var channels:Array;
		
		/**
		 * Constructor.
		 */ 
		public function ColladaAnimation(node:XML=null, async:Boolean=true)
		{
			_async = async;
			super(node);
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 
		override public function parse(node:XML):void
		{
			if(String(node.localName()) != "animation")
				throw new Error("Not a COLLADA 'animation' element!");	
				
			super.parse(node);
			
			this.channels = new Array();
			
			if(!_async)
				parseAsync(node);
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 		
		override public function parseAsync(node:XML):void
		{
			this.channels = new Array();
				
			var i:int;
			var children:XMLList = node..channel;
			var numChildren:int = children.length();

			// get the channels
			for(i = 0; i < numChildren; i++)
			{
				var channel:ColladaChannel = new ColladaChannel(children[i]);
			
				var samplerNode:XML = node.sampler.(@id == channel.source)[0];
				if(!samplerNode)
					throw new Error("Can't find sampler element with id='" + channel.source + "'");
					
				var inputList:XMLList = samplerNode.input;
				for each(var inputNode:XML in inputList)
				{
					var input:ColladaInput = new ColladaInput(inputNode);
					var sourceNode:XML = node..source.(@id == input.source)[0];
					
					if(!sourceNode)
						throw new Error("Can't find source with id='" + input.source + "'");
					
					var src:ColladaSource = new ColladaSource(sourceNode);
					
					switch(input.semantic)
					{
						case "INPUT":
							channel.input = src.data;
							break;
						case "OUTPUT":
							channel.output = src.data;
							break;
						case "INTERPOLATION":
							channel.interpolations = src.data;
							break;
						case "IN_TANGENT":
							channel.inTangents = src.data;
							break;
						case "OUT_TANGENT":
							channel.outTangents = src.data;
							break;
						default:
							break;
					}
				}
				
				if(!channel.input || !channel.output)
					throw new Error("The channel needs at least a input and a output!");
					
				if(channel.input.length != channel.output.length)
					throw new Error("input- and output-array lengths should be equal!");
				
				this.channels.push(channel);
			}
		}
		
		private var _async:Boolean;
	}
}