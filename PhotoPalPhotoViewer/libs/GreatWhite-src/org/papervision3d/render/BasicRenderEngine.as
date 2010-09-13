package org.papervision3d.render
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	import flash.geom.Point;
	
	import org.papervision3d.core.culling.IObjectCuller;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.AbstractRenderEngine;
	import org.papervision3d.core.render.IRenderEngine;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.data.RenderStatistics;
	import org.papervision3d.core.render.filter.BasicRenderFilter;
	import org.papervision3d.core.render.filter.IRenderFilter;
	import org.papervision3d.core.render.material.MaterialManager;
	import org.papervision3d.core.render.sort.BasicRenderSorter;
	import org.papervision3d.core.render.sort.IRenderSorter;
	import org.papervision3d.core.utils.StopWatch;
	import org.papervision3d.events.RendererEvent;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	public class BasicRenderEngine extends AbstractRenderEngine implements IRenderEngine
	{
		public var sorter:IRenderSorter;
		public var filter:IRenderFilter;
		
		protected var renderStatistics:RenderStatistics;
		protected var renderList:Array;
		protected var renderSessionData:RenderSessionData;
		protected var cleanRHD:RenderHitData = new RenderHitData();
		protected var stopWatch:StopWatch;
		
		public function BasicRenderEngine():void
		{
			init();			 
		}
		
		protected function init():void
		{
			renderStatistics = new RenderStatistics();
			stopWatch = new StopWatch();
				
			sorter = new BasicRenderSorter();
			filter = new BasicRenderFilter();
			
			renderList = new Array();
			
			renderSessionData = new RenderSessionData();
			renderSessionData.renderer = this;
		}
		
		override public function renderScene(scene:SceneObject3D, camera:CameraObject3D, viewPort:Viewport3D, updateAnimation:Boolean = true):RenderStatistics
		{
			//Clear the viewport.
			viewPort.updateBeforeRender();
			
			// update the viewports reference to the lastRenderer - the ISM needs this to receive render done events
			viewPort.lastRenderer = this;
			
			//Update the renderSessionData object.
			renderSessionData.scene = scene;
			renderSessionData.camera = camera;
			renderSessionData.viewPort = viewPort;
			renderSessionData.container = viewPort.containerSprite;
			renderSessionData.triangleCuller = viewPort.triangleCuller;
			renderSessionData.particleCuller = viewPort.particleCuller;
			renderSessionData.renderStatistics.clear();
			
			//Project the Scene (this will fill up the renderlist).
			doProject(renderSessionData);
			
			//Render the Scene.
			doRender(renderSessionData);
			dispatchEvent(new RendererEvent(RendererEvent.RENDER_DONE, renderSessionData));
			
			return renderSessionData.renderStatistics;
		}
		
		protected function doProject(renderSessionData:RenderSessionData):void
		{
			stopWatch.reset();
			stopWatch.start();
			
			// Transform camera
			renderSessionData.camera.transformView();
			
			// Project objects
			var objects:Array = renderSessionData.scene.objects;
			var p:DisplayObject3D;
			var i:Number = objects.length;
			if( renderSessionData.camera is IObjectCuller){
				for each(p in objects){
					if(p.visible){
						if(renderSessionData.viewPort.viewportObjectFilter){
							if(renderSessionData.viewPort.viewportObjectFilter.testObject(p)){
								p.view.calculateMultiply4x4(renderSessionData.camera.eye, p.transform);
								p.project(renderSessionData.camera, renderSessionData);
							}else{
								renderSessionData.renderStatistics.filteredObjects++;
							}
						}else{
							p.view.calculateMultiply4x4(renderSessionData.camera.eye, p.transform);
							p.project(renderSessionData.camera, renderSessionData);
						}
					}
				}
			}else{
				for each(p in objects){
					if( p.visible){
						if(renderSessionData.viewPort.viewportObjectFilter){
							if(renderSessionData.viewPort.viewportObjectFilter.testObject(p)){
								p.view.calculateMultiply(renderSessionData.camera.eye, p.transform);
								p.project(renderSessionData.camera, renderSessionData);
							}else{
								renderSessionData.renderStatistics.filteredObjects++;
							}
						}else{
							p.view.calculateMultiply(renderSessionData.camera.eye, p.transform);
							p.project(renderSessionData.camera, renderSessionData);
						}
					}
				}
			}
			renderSessionData.renderStatistics.projectionTime = stopWatch.stop();
		}
		
		protected function doRender(renderSessionData:RenderSessionData):RenderStatistics
		{
			stopWatch.reset();
			stopWatch.start();
			
			//Update Materials.
			MaterialManager.getInstance().updateMaterialsBeforeRender(renderSessionData);
			
			//Filter the list
			filter.filter(renderList);
			
			//Sort entire list.
			sorter.sort(renderList);
			
			var rc:IRenderListItem;
			while(rc = renderList.pop())
			{
				rc.render(renderSessionData);
				renderSessionData.viewPort.lastRenderList.push(rc);
			}
			
			//Update Materials
			MaterialManager.getInstance().updateMaterialsAfterRender(renderSessionData);
			renderSessionData.renderStatistics.renderTime = stopWatch.stop();
			
			renderSessionData.viewPort.updateAfterRender();
			return renderStatistics;
		}
		
		public function hitTestPoint2D(point:Point, viewPort3D:Viewport3D):RenderHitData
		{
			return viewPort3D.hitTestPoint2D(point);
		}
		
		override public function addToRenderList(renderCommand:IRenderListItem):int
		{
			return renderList.push(renderCommand);
		}
		
		override public function removeFromRenderList(renderCommand:IRenderListItem):int
		{
			return renderList.splice(renderList.indexOf(renderCommand),1);
		}

	}
}