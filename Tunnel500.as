package {
	
	import com.soulwire.geom.ColourMatrix;
	import com.soulwire.media.MotionTracker;

	import flash.filters.DropShadowFilter;
	
	import flash.media.*;
	import flash.net.*;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.Font;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.Timer;
	import flash.geom.*;
    import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.filters.BlurFilter;
	import flash.ui.Mouse;
	import flash.events.*;	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Tunnel500 extends MovieClip {
		
		private var _camera:Camera;
		private var _vid:Video;
		private var _wvid:Video;
		
		private var _camera2:Camera;
		private var _vid2:Video;

		private var sampvid:Video;
		
		private var _motionTracker:MotionTracker;
		private var _motionTracker2:MotionTracker;
		private var _target:Shape;
		private var _bounds:Shape;
		private var _output:Bitmap;
		private var _source:Bitmap;
		private var _video:BitmapData;
		private var _matrix:ColourMatrix;
		private var _dropfltr:DropShadowFilter;
		private var _glowfltr:GlowFilter;
		private var _colorChoice:int;
		private var _dropfltrMAN:DropShadowFilter;
		private var _blurfltrMAN:BlurFilter;
		
		private var bb:int;
		
		private var _moving:Boolean;

		private var _poem:Array;
		private var _poem2:Array;
		private var _poemNum:Array;
		private var _txtformats:Array;
		private var _counter:int;
		private var _poemWords:Array;
		private var _poemLetters:Array;
		private var _letterCount:int;
		private var _lineCounter:Array;
		private var _poemDefaultFormat:TextFormat;
		private var _poemDefaultFormat2:TextFormat;
		private var _poemDefaultFormat3:TextFormat;
		private var _cameraMaps:Array;
		private var _motionTotal:Number;
		
		private var _soundchannel:SoundChannel;
		private var _sound:Sound;
		
		private var _slot:int;
		
		private var _count:int;
		
		var xline:Number;
		var yline:Number;
		var lengthOfLine:Number;
		var firstHeight:Number;
		var manX:Number;

		var listOfLetters:Array;
		var listOfNames:Array;
		var listOfLetters2:Array;
		var listOfLetters3:Array;
		var listOfNames2:Array;
		
		var waxOn:Boolean;
					
		var tickTock:Boolean;
		var firstTime:Boolean;
		
		var countit:int;
		
		private var videoURL:String = "Longvideo-tunnelvision.flv";
        private var connection:NetConnection;
        private var stream:NetStream;
		
		public function Tunnel500() {
			
			var camW:int = 140;
			var camH:int = 140;
			var bandwidth:int = 0; 
			var quality:int = 50;
			
			waxOn = false;
			
			var index:int = 0;
			
			for ( var i : int = 0 ; i < Camera.names.length ; i ++ ) {    
				if ( Camera.names[ i ] == "USB Video Class Video" ) {
					index = i;
				}
			}
						
			_camera  = Camera.getCamera( String( index ) );
			
			_camera.setMode(camW,camH,50,true);
			_camera.setQuality(bandwidth, quality);
		
			_wvid = new Video(140,140);
			_wvid.attachCamera(_camera);
			
			connection = new NetConnection();
            connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            connection.connect(null);

			manX = 315;
			
			_moving = false;
			
			// Create the Motion Tracker
			_motionTracker = new MotionTracker(_wvid);
			
			// We flip the input as we want a mirror image
			_motionTracker.flipInput = true;			
			
			_matrix = new ColourMatrix();
			_matrix.brightness = _motionTracker.brightness;
			_matrix.contrast = _motionTracker.contrast;
			
			// Display the camera input with the same filters (minus the blur) as the MotionTracker is using
			_video = new BitmapData( camW, camH, false, 0 );
			
			_matrix = new ColourMatrix();
			_matrix.brightness = _motionTracker.brightness;
			_matrix.contrast = _motionTracker.contrast;
			
			// Display the camera input with the same filters (minus the blur) as the MotionTracker is using
			_video = new BitmapData( camW, camH, false, 0 );
			_source = new Bitmap( _video );
			_source.scaleX = -1;
			_source.x = camW;
			_source.filters = [ new ColorMatrixFilter( _matrix.getMatrix() ) ];
			
			// Show the image the MotionTracker is processing and using to track
			_output = new Bitmap( _motionTracker.trackingImage );
					
			//addChild( _output ); //Do I need this?
			
			_output.scaleX = _output.scaleY = 1.5;

			backCam.addChild(_output);
				backCam.alpha = 0.8;
				backCam.x = 405;
				backCam.y = 190;
				
			// A shape to represent the tracking point
			_target = new Shape();
			_target.graphics.lineStyle( 0, 0xFFFFFF );
			_target.graphics.drawCircle( 0, 0, 10 );
			//addChild( _target );
			
			// A box to represent the activity area
			_bounds = new Shape();
			_bounds.x = _output.x;
			_bounds.y = _output.y;	

			// Configure the UI
			setValues();
			
			_count = 0;
			
		
			_cameraMaps = new Array();
			
			formattingPoem(); // set up all of the filters for the text
						
			writePoem(); //put each of the 40+ lines in a separate array slot called _poem
			
			this.getChildByName("man").filters = [_dropfltrMAN, _blurfltrMAN]; //make the silhouette man look scary
			
			addEventListener(Event.ENTER_FRAME, track);
		
			changeWords();

			//var myTimer:Timer = new Timer(2000,0);
//			tickTock = true;
//			firstTime = true;
//			myTimer.addEventListener(TimerEvent.TIMER, swapClips);
//			myTimer.start();
//			
//			countit = 0;
			
		}



private function swapClips(e:TimerEvent):void {
	
	countit++;

	if(countit >= 4) {
	countit = 0;
	if(tickTock) {
		tickTock = true;
		_motionTracker.input = _wvid;
	
			_matrix = new ColourMatrix();
			_matrix.brightness = _motionTracker.brightness;
			_matrix.contrast = _motionTracker.contrast;
			
			// Display the camera input with the same filters (minus the blur) as the MotionTracker is using
			_video = new BitmapData( 140, 140, false, 0 );
			
			_matrix = new ColourMatrix();
			_matrix.brightness = _motionTracker.brightness;
			_matrix.contrast = _motionTracker.contrast;
			
			// Display the camera input with the same filters (minus the blur) as the MotionTracker is using
			_video = new BitmapData( 140, 140, false, 0 );
			_source = new Bitmap( _video );
			_source.scaleX = -1;
			_source.x = 140;
			_source.filters = [ new ColorMatrixFilter( _matrix.getMatrix() ) ];
			
			// Show the image the MotionTracker is processing and using to track
			_output = new Bitmap( _motionTracker.trackingImage );
					
			//addChild( _output ); //Do I need this?
			
			_output.scaleX = _output.scaleY = 1.5;

		backCam.addChild(_output);
		c2.removeChild(_vid);
		c2.addChild(_wvid);
		
		if((Math.floor(Math.random()*(1+5-1))+1) == 2) {
			trace("fast");
			countit = 4;
		}
		else {
			trace("slow");
			countit = 0;
		}
	}
	else {
		tickTock = true;
		_motionTracker.input = _wvid;
		
			_matrix = new ColourMatrix();
			_matrix.brightness = _motionTracker.brightness;
			_matrix.contrast = _motionTracker.contrast;
			
			// Display the camera input with the same filters (minus the blur) as the MotionTracker is using
			_video = new BitmapData( 140, 140, false, 0 );
			
			_matrix = new ColourMatrix();
			_matrix.brightness = _motionTracker.brightness;
			_matrix.contrast = _motionTracker.contrast;
			
			// Display the camera input with the same filters (minus the blur) as the MotionTracker is using
			_video = new BitmapData( 140, 140, false, 0 );
			_source = new Bitmap( _video );
			_source.scaleX = -1;
			_source.x = 140;
			_source.filters = [ new ColorMatrixFilter( _matrix.getMatrix() ) ];
			
			// Show the image the MotionTracker is processing and using to track
			_output = new Bitmap( _motionTracker.trackingImage );
					
			//addChild( _output ); //Do I need this?
			
			_output.scaleX = _output.scaleY = 1.5;
		
		backCam.addChild(_output);
		//c2.removeChild(_wvid);
		//c2.addChild(_vid);
	}
	setValues();
	
	for(var ms:int = 0; ms < backCam.numChildren; ms++) {
		backCam.removeChildAt(ms);
	}
	}
	
}

        private function netStatusHandler(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + videoURL);
                    break;
				case "NetStream.Play.Stop":
					trace("restarting video...");
					connectStream();
            }
        }

        private function connectStream():void {
            stream = new NetStream(connection);
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
            _vid = new Video(140,140);
            _vid.attachNetStream(stream);
            stream.play(videoURL);
            c2.addChild(_wvid);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
        
        private function asyncErrorHandler(event:AsyncErrorEvent):void {
            // ignore AsyncErrorEvent events.
        }

private function track( e:Event ):void {

			eraseWords();
			
			changeWords();

			_motionTracker.track();
	
			// Move the target with some easing
			_target.x += ((_motionTracker.x + _bounds.x) - _target.x) / 10;
			_target.y += ((_motionTracker.y + _bounds.y) - _target.y) / 10;
			
			this.getChildByName("man").filters = [_dropfltrMAN, _blurfltrMAN];
			
			_video.draw( _motionTracker.input );
			
			// If there is enough movement (see the MotionTracker's minArea property) then continue
			if ( !_motionTracker.hasMovement ) return;
			
			// Draw the motion bounds so we can see what the MotionTracker is doing
			_bounds.graphics.clear();
			_bounds.graphics.lineStyle( 0, 0xFFFFFF );
			_bounds.graphics.drawRect( _motionTracker.motionArea.x,
					_motionTracker.motionArea.y,
					_motionTracker.motionArea.width,
					_motionTracker.motionArea.height
				);
		}

	
private function writePoem():void {
	
	_poem = new Array();
	
		_poem[0] = "A man has been standing";
		_poem[1] = "in front of my house";
		_poem[2] = "for days, I peek";
		_poem[3] = "from the living room";
		_poem[4] = "window and at night,";
		_poem[5] = "unable to sleep,";
		_poem[6] = "I shine my flashlight";
		_poem[7] = "down on the lawn.";
		_poem[8] = "He is always there";
		// NEW STANZA
		_poem[9] = "After a while";
		_poem[10] = "I open the front door";
		_poem[11] = "just a crack and order";
		_poem[12] = "him out of my yard.";
		_poem[13] = "He narrows his eyes";
		_poem[14] = "and moans. I slam";
		_poem[15] = "the door and dash back";
		_poem[16] = "to the kitchen, then up";
		_poem[17] = "to the bedroom, then down.";
		// NEW STANZA
		_poem[18] = "I weep like a schoolgirl";
		_poem[19] = "and make obscene gestures";
		_poem[20] = "through the window. I";
		_poem[21] = "write large suicide notes";
		_poem[22] = "and place them so he";
		_poem[23] = "can read them easily.";
		_poem[24] = "I destroy the living";
		_poem[25] = "room furniture to prove";
		_poem[26] = "I own nothing of value.";
// NEW STANZA
		_poem[27] = "When he seems unmoved";
		_poem[28] = "I decide to dig a tunnel";
		_poem[29] = "to a neighboring yard.";
		_poem[30] = "I seal the basement off";
		_poem[31] = "from the upstairs with";
		_poem[32] = "a brick wall. I dig hard";
		_poem[33] = "and in no time the tunnel";
		_poem[34] = "is done. Leaving my pick";
		_poem[35] = "and shovel below.";
		// NEW STANZA
		_poem[36] = "I come out in front of a house";
		_poem[37] = "and stand there too tired to";
		_poem[38] = "move or even speak, hoping";
		_poem[39] = "someone will help me.";
		_poem[40] = "I feel I'm being watched";
		_poem[41] = "and sometimes I hear";
		_poem[42] = "a man's voice,";
		_poem[43] = "but nothing is done";
		_poem[44] = "and I have been waiting for days.";
		// NEW STANZA
		_poem[45] = "-- Mark Strand";
		

_poem2 = new Array();
	
		_poem2[0] = "A man has been standing";
		_poem2[1] = "in front of my house";
		_poem2[2] = "for days, I peek";
		_poem2[3] = "from the living room";
		_poem2[4] = "window and at night,";
		_poem2[5] = "unable to sleep,";
		_poem2[6] = "I shine my flashlight";
		_poem2[7] = "down on the lawn.";
		_poem2[8] = "He is always there";
		// NEW STANZA
		_poem2[9] = "After a while";
		_poem2[10] = "I open the front door";
		_poem2[11] = "just a crack and order";
		_poem2[12] = "him out of my yard.";
		_poem2[13] = "He narrows his eyes";
		_poem2[14] = "and moans. I slam";
		_poem2[15] = "the door and dash back";
		_poem2[16] = "to the kitchen, then up";
		_poem2[17] = "to the bedroom, then down.";
		// NEW STANZA
		_poem2[18] = "I weep like a schoolgirl";
		_poem2[19] = "and make obscene gestures";
		_poem2[20] = "through the window. I";
		_poem2[21] = "write large suicide notes";
		_poem2[22] = "and place them so he";
		_poem2[23] = "can read them easily.";
		_poem2[24] = "I destroy the living";
		_poem2[25] = "room furniture to prove";
		_poem2[26] = "I own nothing of value.";
// NEW STANZA
		_poem2[27] = "When he seems unmoved";
		_poem2[28] = "I decide to dig a tunnel";
		_poem2[29] = "to a neighboring yard.";
		_poem2[30] = "I seal the basement off";
		_poem2[31] = "from the upstairs with";
		_poem2[32] = "a brick wall. I dig hard";
		_poem2[33] = "and in no time the tunnel";
		_poem2[34] = "is done. Leaving my pick";
		_poem2[35] = "and shovel below.";
		// NEW STANZA
		_poem2[36] = "I come out in front of a house";
		_poem2[37] = "and stand there too tired to";
		_poem2[38] = "move or even speak, hoping";
		_poem2[39] = "someone will help me.";
		_poem2[40] = "I feel I'm being watched";
		_poem2[41] = "and sometimes I hear";
		_poem2[42] = "a man's voice,";
		_poem2[43] = "but nothing is done";
		_poem2[44] = "and I have been waiting for days.";
		// NEW STANZA
		_poem2[45] = "-- Mark Strand";
		
		listOfLetters = new Array();
		listOfLetters2 = new Array();
	
		listOfNames = new Array();
		
		for(var ln:int = 0;ln < _poem.length; ln++) {
			for(var wrd:int = 0; wrd < _poem[ln].length; wrd++) {
				
				var letter:TextField = new TextField();
				letter.name = "T" + ln + "_" + wrd;
				
				var envelope:Sprite = new Sprite();
				envelope.name = "E"+ ln + "_" + wrd;
				
				letter.text = _poem[ln].charAt(wrd);
				letter.setTextFormat(_poemDefaultFormat);
				letter.autoSize = TextFieldAutoSize.CENTER;
				letter.filters = [_glowfltr]; 
				
				envelope.addChild(TextField(letter));
				envelope.alpha = 0.1;
				listOfNames.push(ln);
				listOfLetters.push(Sprite(envelope));
				
				}
		}
		
		for(var ln2:int = 0;ln2 < _poem.length; ln2++) {
			for(var wrd2:int = 0; wrd2 < _poem[ln2].length; wrd2++) {
				
				var letter2:TextField = new TextField();
				letter2.name = "B" + ln2 + "_" + wrd2;
				
				var envelope2:Sprite = new Sprite();
				envelope2.name = "C"+ ln2 + "_" + wrd2;
				
				letter2.text = _poem[ln2].charAt(wrd2);
				letter2.setTextFormat(_poemDefaultFormat);
				letter2.autoSize = TextFieldAutoSize.CENTER;
				letter2.filters = [_glowfltr]; 
				
				envelope2.addChild(TextField(letter2));
				envelope2.alpha = 0.3;
				listOfLetters2.push(Sprite(envelope2));
				
				}
		}
		
		writeIt();
}

private function writeIt():void {
	
		var lengthOfLine:int = 0;
		var xline:int = 640;
		var yline:int = 60;
		var zline = 0;
		var verify:int = 0;
		
		for(var line:int = 0; line < _poem.length; line++) {
							
			if((line == 9) || (line == 18) || (line == 27) || (line == 36) || (line == 45)) {
				yline += 12;
				}
			
			for(var word:int = listOfNames.indexOf(line); word < listOfNames.lastIndexOf(line) + 1; word++) {
				listOfLetters[word].x = xline + lengthOfLine + 2;
				listOfLetters[word].y = yline + Math.random() * 0.2 - 0.1;
				listOfLetters[word].getChildAt(0).setTextFormat(_poemDefaultFormat);
				addChild(listOfLetters[word]);
				
				lengthOfLine += listOfLetters[word].getChildAt(0).textWidth;
			}
			lengthOfLine = 0;
			yline += 11;
			}
	}

private function formattingPoem():void {
	
		_poemDefaultFormat = new TextFormat();
			_poemDefaultFormat.color = 0x000000;
			_poemDefaultFormat.font = "Courier New";
        	_poemDefaultFormat.size = 14;
			_poemDefaultFormat.bold = true;
			_poemDefaultFormat.underline = false;

		_poemDefaultFormat2 = new TextFormat();
			_poemDefaultFormat2.color = 0x000000;
			_poemDefaultFormat2.font = "Courier New";
        	_poemDefaultFormat2.size = 20;
			_poemDefaultFormat2.bold = true;
			_poemDefaultFormat2.underline = false;
					
		_poemDefaultFormat3 = new TextFormat();
			_poemDefaultFormat3.color = 0xDEDEDE;
			_poemDefaultFormat3.font = "Courier New";
        	_poemDefaultFormat3.size = 30;
			_poemDefaultFormat3.bold = true;
			_poemDefaultFormat3.underline = false;
			
		_dropfltr = new DropShadowFilter();
			_dropfltr.blurX = 4;
			_dropfltr.blurY = 4;
			_dropfltr.distance = 1;
			_dropfltr.color = 0x666666;
			_dropfltr.angle = 240;
			_dropfltr.quality = 1;
		
		_glowfltr = new GlowFilter();
			_glowfltr.color = _colorChoice;
			_glowfltr.alpha = .5;
			_glowfltr.blurX = 3;
			_glowfltr.blurY = 3;
			
		_dropfltrMAN = new DropShadowFilter();
			_dropfltr.blurX = 15;
			_dropfltr.blurY = 15;
			_dropfltr.distance = -13;
			_dropfltr.color = 0x000000;
			_dropfltr.angle = 45;
			_dropfltr.quality = 1;

		_blurfltrMAN = new BlurFilter();
			_blurfltrMAN.blurX = 6;
			_blurfltrMAN.blurY = 6;
			_blurfltrMAN.quality = 3;

}

private function changeWords():void {

	if(_motionTracker.hasMovement) {
				
		if(waxOn) { 
			this.getChildByName("house").alpha = 0.9;
			waxOn = false;
			}
		else {
			this.getChildByName("house").alpha = 0.95;
			waxOn = true;
			}

		
		var widthOfText:int = Math.round(_motionTracker.motionArea.width / 4);
		var heightOfText:int = Math.round(_motionTracker.motionArea.height + 40 / 7);
		
		
		//this.getChildByName("man").z = widthOfText * .1;
		if(Math.random() > 0.4) {
			this.getChildByName("man").rotationY = - 3;
		}
			
			
		var xText:int = Math.round((_motionTracker.x - 50) / 11);
		var yText:int = Math.round((_motionTracker.y - 50) / 4);

		if(widthOfText < 0) {
				widthOfText = 0;
			}
			
		if(heightOfText < 0) {
				heightOfText = 0;
			}

		for(var h1:int = yText; h1 < (yText + heightOfText); h1++) {
			for(var h2:int = xText; h2 < (xText + widthOfText); h2++) {
				if(Sprite(this.getChildByName("E" + h1 + "_" + h2))) {
	
					if(Sprite(this.getChildByName("E" + h1 + "_" + h2)).alpha < 1.0) {
					Sprite(this.getChildByName("E" + h1 + "_" + h2)).alpha += 0.5;
					}
					
					}
				}
			}
	}
		}
			
private function setValues():void {
	
			_motionTracker.blur = 6;
			_motionTracker.brightness = _matrix.brightness = 42;
			_motionTracker.contrast = _matrix.contrast = 87;
			_motionTracker.minArea = 30;
					
			_source.filters = [ new ColorMatrixFilter( _matrix.getMatrix() ) ];
		}
		
private function eraseWords() {
	
	if(!(_motionTracker.hasMovement)) {
		this.getChildByName("man").z = - 10;
		this.getChildByName("man").rotationY = 0;
		for(var q1:int = 0; q1 < listOfLetters.length; q1++) {
				if(listOfLetters[q1].alpha > 0.0) {
					listOfLetters[q1].alpha -= 0.09;
						}
		}
	}
				
	
}
		
private function resetAlpha():void {
		
	for(var abc:int = 0; abc < listOfLetters.length - 1; abc++) {
		listOfLetters[abc].alpha = 0.3;
		}

	}

// Fin.
	}
}























