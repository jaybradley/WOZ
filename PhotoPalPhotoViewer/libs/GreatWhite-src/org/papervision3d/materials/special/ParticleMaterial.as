package org.papervision3d.materials.special
{
	import flash.display.Graphics;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.IParticleDrawer;

	import flash.geom.Rectangle;	

	/**
	 * @Author Ralph Hauwert
	 * 
	 * updated by Seb Lee-Delisle 
	 *  - added size implementation
	 *  - added rectangle of particle for smart culling and drawing
	 * 
	 */
	public class ParticleMaterial extends MaterialObject3D implements IParticleDrawer
	{
		
		
		public function ParticleMaterial(color:Number, alpha:Number)
		{
			super();
			this.fillAlpha = alpha;
			this.fillColor = color;
		}
		
		public function drawParticle(particle:Particle, graphics:Graphics, renderSessionData:RenderSessionData):void
		{
			graphics.beginFill(fillColor, fillAlpha);
			
			var renderrect:Rectangle = particle.renderRect; 
			
			graphics.drawRect(renderrect.x, renderrect.y, renderrect.width, renderrect.height);

			graphics.endFill();
			renderSessionData.renderStatistics.particles++;
		}
		
		public function updateRenderRect(particle : Particle) :void
		{
			var renderrect:Rectangle = particle.renderRect; 

			if(particle.size == 0){

				renderrect.width = 1; 
				renderrect.height = 1; 
			}else{
				renderrect.width = particle.renderScale*particle.size;
				renderrect.height = particle.renderScale*particle.size;
			}
			renderrect.x = particle.vertex3D.vertex3DInstance.x - (renderrect.width/2); 
			renderrect.y = particle.vertex3D.vertex3DInstance.y - (renderrect.width/2);
			
		}
	}
}