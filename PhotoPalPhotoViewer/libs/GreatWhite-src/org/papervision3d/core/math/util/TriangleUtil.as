package org.papervision3d.core.math.util
{
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.math.Plane3D;
	
	public class TriangleUtil
	{
		
		public static function splitTriangleWithPlane(triangle:Triangle3D, plane:Plane3D, e:Number=0.01 ):Array
		{
			var side:uint = ClassificationUtil.classifyTriangle(triangle, plane,e);
			if(side != ClassificationUtil.STRADDLE){
				
				return null;
			}

			var points:Array = [triangle.v0, triangle.v1, triangle.v2];
			var uvs:Array = [triangle.uv0, triangle.uv1, triangle.uv2];
			var triA:Array = new Array();
			var triB:Array = new Array();
			var uvsA:Array = new Array();
			var uvsB:Array = new Array();
			
			for( var i:int = 0; i < points.length; i++ )
			{
				var j:int = (i+1) % points.length;
				
				var pA:Vertex3D = points[i];
				var pB:Vertex3D = points[j];
				
				var uvA:NumberUV = uvs[i];
				var uvB:NumberUV = uvs[j];
				
				var sideA:Number = plane.distance(pA);
				var sideB:Number = plane.distance(pB);
				var isect:Intersection;
				var newUV:NumberUV;
				
				if(sideB > e) 
				{
					if(sideA < -e) 
					{
						isect = Intersection.linePlane( pA, pB, plane );
						if( isect.status != Intersection.INTERSECTION )
							return null;
						
						triangle.instance.geometry.vertices.push( isect.vert );
						triA.push( isect.vert );
						triB.push( isect.vert );
						newUV = InterpolationUtil.interpolateUV(uvA, uvB, isect.alpha);
						
						uvsA.push(newUV);
						uvsB.push(newUV);
					}
					triA.push( pB );
					uvsA.push( uvB );
				}
				else if(sideB < -e) 
				{
					if(sideA > e) 
					{
						isect = Intersection.linePlane( pA, pB, plane );
						if( isect.status != Intersection.INTERSECTION )
							return null;
						
						triangle.instance.geometry.vertices.push( isect.vert );
						
						triA.push( isect.vert );
						triB.push( isect.vert );
						
						newUV = InterpolationUtil.interpolateUV(uvA, uvB, isect.alpha);
						
						uvsA.push(newUV);
						uvsB.push(newUV);
					}
					triB.push( pB );
					uvsB.push( uvB );
				}
				else
				{
					triA.push( pB );
					triB.push( pB );
					uvsA.push( uvB );
					uvsB.push( uvB );
				}
			}
			
			
			var tris:Array = new Array();
			tris.push( new Triangle3D(triangle.instance, [triA[0], triA[1], triA[2]], triangle.material, [uvsA[0], uvsA[1], uvsA[2]]) );
			tris.push( new Triangle3D(triangle.instance, [triB[0], triB[1], triB[2]], triangle.material, [uvsB[0], uvsB[1], uvsB[2]]) );
			
			if( triA.length > 3 )
				tris.push( new Triangle3D(triangle.instance, [triA[0], triA[2], triA[3]], triangle.material, [uvsA[0], uvsA[2], uvsA[3]]) );
			else if( triB.length > 3 )
				tris.push( new Triangle3D(triangle.instance, [triB[0], triB[2], triB[3]], triangle.material, [uvsB[0], uvsB[2], uvsB[3]]) );
			return tris;
		}
	}
}