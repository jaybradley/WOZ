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
	public class ColladaChannel extends ColladaElement
	{
		use namespace collada;
		
		public var source:String;
		
		/** The ID of the targeted node. */
		public var targetID:String;
		
		/** The full URI to the targeted node */
		public var targetURI:String;
		
		/** The SID of the targeted transform. */ 
		public var transformSID:String;
		
		/** The targeted members of the transform. */
		public var transformMembers:Array;
		
		public var input:Array;
		
		public var output:Array;
		
		public var interpolations:Array;
		
		public var inTangents:Array;
		
		public var outTangents:Array;
		
		/**
		 * Constructor.
		 */ 
		public function ColladaChannel(node:XML=null)
		{
			super(node);
		}
	
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 
		override public function parse(node:XML):void
		{
			if(String(node.localName()) != "channel")
				throw new Error("Not a COLLADA 'channel' element!");	
				
			super.parse(node);
			
			var targetAttribute:String = node.@target.toString();
			var targetParts:Array = targetAttribute.split("/");
			var uriParts:Array = new Array();
			
			while(targetParts.length > 1)
				uriParts.push(String(targetParts.shift()));
			
			this.source = node.@source.toString().substr(1);
			this.targetID = String(uriParts.pop());	
			
			uriParts.push(this.targetID);
			
			this.targetURI = uriParts.join("/");
			
			this.transformSID = String(targetParts[0]);
			this.transformMembers = new Array();
			
			var parts:Array;
			if(this.transformSID.indexOf(".") != -1)
			{
				parts = this.transformSID.split(".");
				this.transformSID = String(parts.shift());
					
				var member:String = String(parts.shift());
				var memberIndex:int = 0;
				switch(member)
				{
					case "Y":
						memberIndex = 1;
						break;
					case "Z":
						memberIndex = 2;
						break;
					case "ANGLE":
						memberIndex = 3;
						break;
					case "X":
					default:
						break;
				}
				this.transformMembers.push(memberIndex);
			}
			else if(this.transformSID.indexOf("(") != -1)
			{
				parts = this.transformSID.split("(");
				this.transformSID = String(parts.shift());
				for(var i:int = 0; i < parts.length; i++)
				{
					var tmp:String = parts[i] as String;
					var parts2:Array = tmp.split(")");
					this.transformMembers.push(parseInt(String(parts2.shift()), 10));
				}
			}
		}	
	}
}