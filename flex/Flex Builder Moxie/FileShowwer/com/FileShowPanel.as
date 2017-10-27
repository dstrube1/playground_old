package com
{
	import mx.containers.Panel;
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
	
	public class FileShowPanel extends Panel
	{
		private var filesToShow :Array;
		//public var files_vb:TileList;
		public var files_vb:HBox;
		//public var files_vb:Repeater;
		//[Bindable]
		//public var files_vb:ArrayCollection = new ArrayCollection();
		public var show_btn:Button;
		public var clear_btn:Button;
		private var FileComponents : Array = new Array();
		public var myCanvas:Canvas;
		/*
		 * Constructor
		 */
		public function App() :void
		{
			Alert.show("App constructor");
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		/*
		 * creationComplete
		 *
		 * called when the AIR has finishe loading, sets up drag/drop event listeners reference objects
		 *
		 */
		public static function creationCompleteHandler( event:FlexEvent ) :void
		{/*
			Alert.show("App creationComplete");
			addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER,	onDragEnter );
            addEventListener( NativeDragEvent.NATIVE_DRAG_DROP,		onDragDrop );
            show_btn.enabled = false;
            show_btn.addEventListener( MouseEvent.CLICK, show );
            clear_btn.enabled = false;
            clear_btn.addEventListener( MouseEvent.CLICK, clear );
            
            filesToShow = new Array();
		*/}
		
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
            Alert.show("onDragDrop");
            DragManager.dropAction = DragActions.COPY;
            var files:Array = event.transferable.dataForFormat( TransferableFormats.FILE_LIST_FORMAT ) as Array;
            for each (var f:File in files)
            {
               addFile( FileReference( f ) );
        	}
        	
        	show_btn.enabled = true;
        	clear_btn.enabled = true;
        }
        
        /*
		 * addFile
		 *
		 * ...add then to filesToUpload array, and the file upload listeners, 
		 * and create a progress component for each file
		 */
        private function addFile( f:FileReference ) :void
        {
        	Alert.show("addFile");
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
		
		/*
		 * show!
		 */
        private function show( e:MouseEvent ) :void
        {
        	var name:String = "";
        	
        	for each (var f:File in filesToShow)
            {
            	name = f.name.toLowerCase();
            	if (f.isDirectory)
            	{
            		showDir(f);
            	}
            	else if (name.indexOf(".txt")!=-1){
            		showTxt(f);
            	}
            	else if (name.indexOf(".jpg")!=-1){
            		showJpg(f);
            	}
//            	else Alert.show("Sorry, I'm not prepared to display this type of file.");
        	}
        }
        
        private function showDir(dir:File):void{
        	for each (var file:File in dir.listDirectory())
			{
				if (file.isDirectory){
					showDir(file);
				}
				else{
					if (file.name.indexOf(".txt")!=-1){
						showTxt(file);
					}
//					else Alert.show("Sorry, I'm not prepared to display this type of file.");
				}
			}
        }
        private function showTxt(f:File):void{
        	var stream:FileStream = new FileStream();
        	var contents:String = "";
			stream.open( f, FileMode.READ );
			contents = stream.readUTFBytes( stream.bytesAvailable );
        	Alert.show("Contents of "+f.name+": "+contents);
        	stream.close();        	
        }
        
        private function showJpg(file:File):void{
    		var img:Image = new Image();
            img.load(file.nativePath);
            myCanvas.addChild(img);
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
        }
	}
}