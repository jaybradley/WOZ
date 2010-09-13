/*
Copyright (c) 2007 Jason Crist

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package com.pbking.facebook.methodGroups
{
	import com.pbking.facebook.Facebook;
	import com.pbking.facebook.data.photos.FacebookAlbum;
	import com.pbking.facebook.data.users.FacebookUser;
	import com.pbking.facebook.delegates.photos.*;
	
	import flash.utils.ByteArray;
	
	public class Photos
	{
		// VARIABLES //////////
		
		private var facebook:Facebook;
		
		// CONSTRUCTION //////////
		
		function Photos(facebook:Facebook):void
		{
			this.facebook = facebook;
		}
		
		// FACEBOOK FUNCTIONS //////////
		
		/**
		 * Creates and returns a new album owned by the current session user. 
		 * See photo uploads for a description of the upload workflow. 
		 * The only storable values returned from this call are aid and owner. 
		 * No relationships between them are storable.
		 */
		public function createAlbum(name:String, location:String="", description:String="", callback:Function = null):CreateAlbumDelegate
		{
			var delegate:CreateAlbumDelegate = new CreateAlbumDelegate(facebook, name, location, description);
			return MethodGroupUtil.addCallback(delegate, callback) as CreateAlbumDelegate;
		}
		
		/**
		 * Returns the set of user tags on all photos specified.
		 */
		public function getTags(photos:Array, callback:Function = null):GetTagsDelegate
		{
			var delegate:GetTagsDelegate = new GetTagsDelegate(facebook, photos);
			return MethodGroupUtil.addCallback(delegate, callback) as GetTagsDelegate;
		}
		
		/**
		 * Uploads a photo owned by the current session user and returns the new photo. See photo uploads for a description 
		 * of the upload workflow. The only storable values returned from this call are pid, aid, and owner. All applications 
		 * can upload photos with a "pending" state, which means that the photos must be approved by the user before they are 
		 * visible on the site. Photos uploaded by applications with the photo_upload extended permission will be visible 
		 * immediately.
		 */
		public function upload(data:ByteArray, album:FacebookAlbum=null, caption:String="", callback:Function=null):UploadDelegate
		{
			var delegate:UploadDelegate = new UploadDelegate(facebook, data, album, caption) 
			return MethodGroupUtil.addCallback(delegate, callback) as UploadDelegate;		
		}
		
		/**
		 * Works the same as the upload method but will handle the image jpeg conversion for you.
		 * Alas, I cannot include this in the release as the JPEGEncoder is in the mx.* package (and probably just Flex3, though I'm not sure).
		 * But I'm leaving it in here to show how you SHOULD encode a BMD object to send.
		public function encodeAndUpload(bitmap:BitmapData, quality:int=85, album:FacebookAlbum=null, caption:String="", callback:Function=null):Upload_delegate
		{
			var jpgEncoder:JPEGEncoder = new JPEGEncoder(quality);
			var jpgStream:ByteArray = jpgEncoder.encode(bitmap);
			return upload(jpgStream, album, caption, callback);
		}
		 */
		
		/**
		 * Adds a tag with the given information to a photo.
		 */
		public function addTag(pid:int, tag_uid:int, tag_text:String, x:Number, y:Number, callback:Function=null):AddTagsDelegate
		{
			return addTags([{pid:int, tag_uid:tag_uid, tag_text:tag_text, x:x, y:y}], callback);
		}
		
		/**
		 * Add multiple tags.  Each item in the array must have:
		 * pid, tag_uid OR tag_text, x, y
		 * 
		 * Adds a tag with the given information to a photo. See photo uploads for a description of the upload workflow.
		 * 
		 * For regular applications, tags can only be added to pending photos owned by the current session user – once a 
		 * photo has been approved or rejected, it can no longer be tagged with this method. Applications with the 
		 * photo_upload extended permission can add tags to any photo owned by the user. There is a limit of 20 tags 
		 * per pending photo. 
		 * 
		 * @param tags:Array array of NewTag objects
		 */
		public function addTags(tags:Array, callback:Function = null):AddTagsDelegate
		{
			var delegate:AddTagsDelegate = new AddTagsDelegate(facebook, tags);
			return MethodGroupUtil.addCallback(delegate, callback) as AddTagsDelegate;
		}
		
		/**
		 * Returns metadata about all of the photo albums uploaded by the specified user. 
		 * The values returned from this call are not storable.
		 */
		public function getAlbums(uid:int, getCoverPhotos:Boolean = false, callback:Function = null):GetAlbumsDelegate
		{
			var delegate:GetAlbumsDelegate = new GetAlbumsDelegate(facebook, uid, getCoverPhotos);
			return MethodGroupUtil.addCallback(delegate, callback) as GetAlbumsDelegate;
		}
		
		/**
		 * Returns all visible photos according to the filters specified
		 */
		public function getPhotos(subj_id:Object=null, aid:Object=null, pids:Array=null, callback:Function = null):GetPhotosDelegate
		{
			var delegate:GetPhotosDelegate = new GetPhotosDelegate(facebook, subj_id, aid, pids);
			return MethodGroupUtil.addCallback(delegate, callback) as GetPhotosDelegate;
		}
		
		// HELPER FUNCTIONS //////////

		/**
		 * Get all of the pictures for an album
		 */
		public function getPhotosForAlbum(album:FacebookAlbum, callback:Function = null):GetPhotosDelegate
		{
			return getPhotos(null, album.aid, null, callback);
		}
		
	}
}