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
	public class ColladaSkin extends ColladaElement
	{
		use namespace collada;
		
		public var source:String;
		
		public var bind_shape_matrix:Array;
		
		public var joints:Array;
		
		public var inverse_bind_matrices:Array;
		
		public var vertex_weights:Array;
		
		public var skeletons:Array;
		
		/**
		 * 
		 */ 
		public function ColladaSkin(node:XML=null)
		{
			super(node);
		}
		
		/**
		 * Gets the vertex weights for a joint.
		 * 
		 * @param	joint	Index into the joints array. @see #joints
		 * 
		 * @return	Array of vertex weights. @see org.ascollada.core.ColladaVertexWeight
		 */ 
		public function getJointVertexWeights(joint:uint):Array
		{
			var weights:Array = new Array();
			if(joint < this.joints.length)
			{
				var name:String = this.joints[joint];
				for(var i:int = 0; i < this.vertex_weights.length; i++)
				{
					var w:ColladaVertexWeight = this.vertex_weights[i];
					if(w.jointId == name)
						weights.push(w);
				}
			}	
			return weights;
		}
		
		/**
		 * Parses the XML node.
		 * 
		 * @param	node	The node to parse.
		 */ 
		override public function parse(node:XML):void
		{
			if(String(node.localName()) != "skin")
				throw new Error("Not a COLLADA 'skin' element!");	
				
			super.parse(node);
			
			this.source = node.@source.toString().substr(1);
			this.bind_shape_matrix = new Array();
			
			if(node.bind_shape_matrix[0])
			{
				var values:Array = ColladaElement.parseStringArray(node.bind_shape_matrix[0]);
				for(var i:int = 0; i < values.length; i++)
					this.bind_shape_matrix.push(parseFloat(values[i]));
			}
			else
				this.bind_shape_matrix = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1];
				
			parseJoints(node.joints[0]);
			
			parseVertexWeights(node.vertex_weights[0]);
		}
		
		/**
		 * 
		 */ 
		private function parseJoints(node:XML):void
		{
			if(!node)
				throw new Error("A skin element should have exactly 1 joints element!");
			
			if(String(node.localName()) != "joints")
				throw new Error("Not a COLLADA 'joints' element!");	
				
			var inputJointNode:XML = node.input.(@semantic == "JOINT")[0];
			var inputInvBindMatrixNode:XML = node.input.(@semantic == "INV_BIND_MATRIX")[0];
			
			if(!inputJointNode || !inputInvBindMatrixNode)
				throw new Error("Required input elements not found!");
				
			this.joints = new Array();
			
			var jointInput:ColladaInput = new ColladaInput(inputJointNode);
			var invBindMatrixInput:ColladaInput = new ColladaInput(inputInvBindMatrixNode);
	
			var jointSourceNode:XML = node.parent().source.(@id == jointInput.source)[0];
			var invBindMatrixSourceNode:XML = node.parent().source.(@id == invBindMatrixInput.source)[0];
			
			if(!jointSourceNode || !invBindMatrixSourceNode)
				throw new Error("Required source elements not found!");
				
			var jointSource:ColladaSource = new ColladaSource(jointSourceNode);
			var invBindMatrixSource:ColladaSource = new ColladaSource(invBindMatrixSourceNode);
			
			this.joints = jointSource.data;
			this.inverse_bind_matrices = invBindMatrixSource.data;
		}
		
		/**
		 * 
		 */ 
		private function parseVertexWeights(node:XML):void
		{
			if(!node)
				throw new Error("A skin element should have exactly 1 vertex_weights element!");
			
			if(String(node.localName()) != "vertex_weights")
				throw new Error("Not a COLLADA 'vertex_weights' element!");	
				
			var count:int = parseInt(node.@count.toString(), 10);
			
			var inputJointNode:XML = node.input.(@semantic == "JOINT")[0];
			var inputWeightNode:XML = node.input.(@semantic == "WEIGHT")[0];
			
			var vNode:XML = node.v[0];
			var vCountNode:XML = node.vcount[0];
			
			if(!inputJointNode || !inputWeightNode || !vNode || !vCountNode)
				throw new Error("Can't find required elements to parse vertex_weights.");
				
			var jointInput:ColladaInput = new ColladaInput(inputJointNode);
			var weightInput:ColladaInput = new ColladaInput(inputWeightNode);
	
			var jointSourceNode:XML = node.parent().source.(@id == jointInput.source)[0];
			var weightSourceNode:XML = node.parent().source.(@id == weightInput.source)[0];
			
			if(!jointSourceNode || !weightSourceNode)
				throw new Error("Required source elements not found!");
			
			this.vertex_weights = new Array();
			
			var jOffset:int = jointInput.offset;
			var wOffset:int = weightInput.offset;
			
			var weightSource:ColladaSource = new ColladaSource(weightSourceNode);
			var v:Array = ColladaElement.parseIntArray(vNode);
			var vCount:Array = ColladaElement.parseIntArray(vCountNode);
			
			var ptr:int = 0;
			for(var i:int = 0; i < vCount.length; i++)
			{
				var numBones:int = vCount[i];
				
				for(var j:int = 0; j < numBones; j++)
				{
					var jv:int = v[ptr+jOffset];
					var wv:int = v[ptr+wOffset];
					
					if(jv < 0)
						throw new Error("Don't know how to handle negative joint-ID!");
					
					var joint:String = this.joints[jv];
					var weight:Number = weightSource.data[wv];
					
					this.vertex_weights.push(new ColladaVertexWeight(joint, i, weight));
					
					ptr += 2;
				}
			}
		}
	}
}
