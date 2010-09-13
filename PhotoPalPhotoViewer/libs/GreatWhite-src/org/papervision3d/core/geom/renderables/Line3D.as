package org.papervision3d.core.geom.renderables
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.command.RenderLine;
	import org.papervision3d.materials.special.LineMaterial;

	public class Line3D extends AbstractRenderable implements IRenderable
	{
		
		public var v0:Vertex3D;
		public var v1:Vertex3D;
		public var material:LineMaterial;
		public var renderCommand:RenderLine;
		public var size:Number;
		public var instance:Lines3D;
		
		public function Line3D(instance:Lines3D, material:LineMaterial, size:Number, vertex0:Vertex3D, vertex1:Vertex3D)
		{
			this.size = size;
			this.material = material;
			this.v0 = vertex0;
			this.v1 = vertex1;
			this.instance = instance;
			this.renderCommand = new RenderLine(this);
		}
		
		override public function getRenderListItem():IRenderListItem
		{
			return this.renderCommand;
		}
		
	}
}