package org.papervision3d.core.render.sort
{
	
	/**
	 * @Author Ralph Hauwert
	 */

	
	
	public class BasicRenderSorter implements IRenderSorter
	{
		public function sort(array:Array):void
		{
			array.sortOn("screenDepth", Array.NUMERIC);
		}
		
	}
}