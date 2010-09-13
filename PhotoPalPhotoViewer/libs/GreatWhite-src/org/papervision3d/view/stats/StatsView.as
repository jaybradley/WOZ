package org.papervision3d.view.stats
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.papervision3d.core.render.AbstractRenderEngine;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.data.RenderStatistics;

	public class StatsView extends AbstractStatsView
	{
		protected var statsFormat:TextFormat;
		
		protected var fpsInfoTextField:TextField;
		protected var objectInfoTextField:TextField;
		protected var renderInfoTextField:TextField;
		protected var cullingInfoTextField:TextField;
		
		public function StatsView(renderEngine:AbstractRenderEngine)
		{
			super();
			this.renderEngine = renderEngine;
			init();
		}
		
		protected function init():void
		{
			setupView();
		}
		
		protected function setupView():void
		{
			opaqueBackground = 0;
			
			statsFormat = new TextFormat("Arial", 12, 0xFFFFFF, false, false, false);
			
			fpsInfoTextField = new TextField();
			fpsInfoTextField.y = 0;
			fpsInfoTextField.autoSize = TextFieldAutoSize.LEFT;
			addChild(fpsInfoTextField);
			
			objectInfoTextField = new TextField();
			objectInfoTextField.y = 12;
			objectInfoTextField.autoSize = TextFieldAutoSize.LEFT;
			addChild(objectInfoTextField);
			
			renderInfoTextField = new TextField();
			renderInfoTextField.y = 24;
			renderInfoTextField.autoSize = TextFieldAutoSize.LEFT;
			addChild(renderInfoTextField);
			
			cullingInfoTextField = new TextField();
			cullingInfoTextField.y = 36;
			cullingInfoTextField.autoSize = TextFieldAutoSize.LEFT;
			addChild(cullingInfoTextField);
		}
		
		override public function set renderSessionData(renderSessionData:RenderSessionData):void
		{
			var stats:RenderStatistics = renderSessionData.renderStatistics;
			
			objectInfoTextField.text = "Tri : "+stats.triangles+" Sha : "+stats.shadedTriangles+" Lin : "+stats.lines+" Par : "+stats.particles;
			renderInfoTextField.text = "Ren: "+stats.rendered+" RT : "+stats.renderTime+" PT : "+stats.projectionTime;
			cullingInfoTextField.text = "COb : "+stats.culledObjects+ " CTr : "+stats.culledTriangles+" CPa : "+stats.culledParticles+" FOb : "+stats.filteredObjects;
		
			objectInfoTextField.setTextFormat(statsFormat);
			renderInfoTextField.setTextFormat(statsFormat);
			cullingInfoTextField.setTextFormat(statsFormat);
		}
		
		override public function set fps(fps:int):void
		{
			fpsInfoTextField.text = "FPS : "+fps;
			fpsInfoTextField.setTextFormat(statsFormat);
		}
	
	}
}