package com
{
	import mx.core.WindowedApplication;
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.containers.HBox;
//	import mx.controls.TileList;
//	import mx.core.Repeater;
	//import mx.collections.ArrayCollection;
	import mx.controls.Button;
	
	import mx.events.FlexEvent;
	import flash.events.*;
	
	import flash.desktop.*;
    import flash.filesystem.File;
    import flash.net.*;
    import mx.controls.Alert;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.display.DisplayObject;
	
	import com.FileComponent;
//	import flash.media.Video;
	import mx.controls.VideoDisplay;
	
	public class App extends WindowedApplication
	{
		private var filesToShow :Array;
		//public var files_vb:TileList;
		public var files_vb:HBox;
		//public var files_vb:Repeater;
		//[Bindable]
		//public var files_vb:ArrayCollection = new ArrayCollection();
		public var show_btn:Button;
		public var clear_btn:Button;
		public var upload_btn:Button;
		public var browse_btn:Button;
		private var FileComponents : Array = new Array();
		public var myCanvas:Canvas;
		//thumbnail height and width
		public var tn_height:uint = 0;
		public var tn_width:uint = 0;
		
		/*
		 * Constructor
		 */
		public function App() :void
		{
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		/*
		 * creationComplete
		 *
		 * called when the AIR has finishe loading, sets up drag/drop event listeners reference objects
		 *
		 */
		private function creationCompleteHandler( event:FlexEvent ) :void
		{
			addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER,	onDragEnter );
            addEventListener( NativeDragEvent.NATIVE_DRAG_DROP,		onDragDrop );
            show_btn.enabled = false;
            show_btn.addEventListener( MouseEvent.CLICK, show );
            clear_btn.enabled = false;
            clear_btn.addEventListener( MouseEvent.CLICK, clear );
            upload_btn.enabled = false;
            //todo:
            upload_btn.addEventListener( MouseEvent.CLICK, clear );
            browse_btn.addEventListener( MouseEvent.CLICK, browse);
            
            filesToShow = new Array();
		}
		
		/*
		 * onDragEnter
		 *
		 * files have been dragged into the app
		 */
		private function onDragEnter( event:NativeDragEvent ) :void
        {
           DragManager.acceptDragDrop(this);
        }
        
        /*
		 * onDragDrop
		 *
		 * when files are dropped... 
		 */
        private function onDragDrop( event:NativeDragEvent ) :void
        {
        	DragManager.dropAction = DragActions.COPY;
            var files:Array = event.transferable.dataForFormat( TransferableFormats.FILE_LIST_FORMAT ) as Array;
            for each (var f:File in files)
            {
               addFile( FileReference( f ) );
        	}
        	
        	show_btn.enabled = true;
        	clear_btn.enabled = true;
        	upload_btn.enabled = true;
        }
        
        /*
		 * addFile
		 *
		 * ...add then to filesToUpload array, and the file upload listeners, 
		 * and create a progress component for each file
		 */
        private function addFile( f:FileReference ) :void
        {
        	filesToShow.push( f );

        	var fileComponent:FileComponent = new FileComponent();
        	FileComponents.push(fileComponent);
        	files_vb.addChild( fileComponent ); //if H/VBox
        	//files_vb.addItem( fileComponent ); //if arraycollection
        	//files_vb.push(fileComponent); //if array
    		fileComponent.file_lb.text = f.name;
        	f.addEventListener( Event.COMPLETE, completeHandler );
        	f.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
        }
        
        /*
		 * completeHandler
		 *
		 * a file upload is complete, remove it from filesToUpload 
		 * and remove the upload component
		 */
    	private function completeHandler( e:Event ) :void 
    	{
    		
        	var f:FileReference = FileReference(e.target);
        	for( var i:uint; i < filesToShow.length; i++ )
        	{
        		if( f.name == filesToShow[i].name )
        		{
        			files_vb.removeChild( FileComponents[i] ); //if H/VBox
        			//files_vb.removeItemAt(i);//if arraycollection
        			//files_vb.pop(); //if array
        			filesToShow.splice(i, 1);
        			FileComponents.splice(i, 1);
        		}
        	}
        	
    	}
    	
    	/*
		 * trace any errors
		 */
    	private function ioErrorHandler( event:IOErrorEvent ) :void 
    	{
			trace("ioErrorHandler: " + event);
		}
		
		private function browse (e:MouseEvent):void{
			var fr:FileReference = new FileReference();
			fr.addEventListener(Event.SELECT,select);
			//called without pause after browse in Windows:
			//fr.addEventListener(Event.COMPLETE,complete);
			try
			{
			    var success:Boolean = fr.browse();
			}
			catch (error:Error)
			{
			    Alert.show("Unable to browse for files.");
			}
			try
			{
				//fr.upload(null);
			}
			catch (error:Error)
			{
			    Alert.show("Unable to upload file.");
			}
			function select():void{
				Alert.show(fr.name);
			}
			function complete():void{
				Alert.show(fr.name);
			}
		}
		
		private function upload (e:MouseEvent):void{
			for each (var f:File in filesToShow){
				if (f.isDirectory){
					uploadDir(f);
				}
				else{
					uploadFile(f);
				}
			}
		}
		
		private function uploadDir(dir:File):void{
			for each (var file:File in dir.listDirectory()){
				if (file.isDirectory){
					uploadDir(file);
				}else{
					uploadFile(file);
				}
			}
		}

		private function uploadFile(file:File):void{
        	var name:String = file.name.toLowerCase();

        	if (name.indexOf(".txt")!=-1){
        		uploadTxt(file);
        	}else if (name.indexOf(".jpg")!=-1){
        		uploadPic(file);
        	}else if (name.indexOf(".png")!=-1){
        		uploadPic(file);
        	}else if (name.indexOf(".gif")!=-1){
        		uploadPic(file);
        	}else if (name.indexOf(".bmp")!=-1){
        		uploadPic(file);
        	}else if (name.indexOf(".flv")!=-1){
        		uploadVid(file);
        	}else if (name.indexOf(".mov")!=-1){
        		uploadVid(file);
        	}
//            	else Alert.show("Sorry, I'm not prepared to display this type of file.");
        }
        private function uploadTxt(file:File):void{}
        private function uploadPic(file:File):void{}
        private function uploadVid(file:File):void{}
        
        private function show( e:MouseEvent ) :void
        {
        	for each (var f:File in filesToShow){
            	if (f.isDirectory){
            		showDir(f);
            	}else {
            		showFile(f);
            	}
        	}
        }

        private function showDir(dir:File):void{
        	for each (var file:File in dir.listDirectory()){
				if (file.isDirectory){
					showDir(file);
				}else{
					showFile(file);
				}
			}
		}
        
        private function showFile(file:File):void{
        	var name:String = file.name.toLowerCase();

        	if (name.indexOf(".txt")!=-1){
        		showTxt(file);
        	}else if (name.indexOf(".jpg")!=-1){
        		showPic(file);
        	}else if (name.indexOf(".png")!=-1){
        		showPic(file);
        	}else if (name.indexOf(".gif")!=-1){
        		showPic(file);
        	}else if (name.indexOf(".bmp")!=-1){
        		showPic(file);
        	}else if (name.indexOf(".flv")!=-1){
        		showVid(file);
        	}else if (name.indexOf(".mov")!=-1){
        		showVid(file);
        	}
//            	else Alert.show("Sorry, I'm not prepared to display this type of file.");
        }

        private function showTxt(file:File):void{
        	var stream:FileStream = new FileStream();
        	var contents:String = "";
			stream.open( file, FileMode.READ );
			contents = stream.readUTFBytes( stream.bytesAvailable );
        	Alert.show("Contents of "+file.name+": "+contents);
        	stream.close();        	
        }
        
        private function showPic(file:File):void{
    		var img:Image = new Image();
            img.load(file.nativePath);
            img.width = tn_width;
            img.height = tn_height;
            myCanvas.addChild(img);
        }
        
        private function showVid(file:File):void{
    		var vid:VideoDisplay = new VideoDisplay();
            vid.autoPlay = false;
            vid.source = file.nativePath;
            //vid.load(file.nativePath);
            myCanvas.addChild(vid);
        }
        
        private function clear( e:MouseEvent ) :void{
        	files_vb.removeAllChildren(); //if H/VBox
        	//files_vb.removeAll();//if arraycollection
        	for (var i:int=0;
        	i<=FileComponents.length && i<=filesToShow.length;//&& i<=files_vb.length; //if array
        	i++){
        		FileComponents.pop();
        		filesToShow.pop();
        	//	files_vb.pop(); //if array
        	}
        	show_btn.enabled = false;
        	clear_btn.enabled = false;
        	upload_btn.enabled = false;
        	myCanvas.removeAllChildren();
        }	
	}
}