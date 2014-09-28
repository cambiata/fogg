package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import flash.net.URLRequest;
import haxe.Timer;

/**
 * ...
 * @author 
 */

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
		
		org.xiph.fogg.Buffer._s_init();
        org.xiph.fvorbis.FuncFloor._s_init();
        org.xiph.fvorbis.FuncMapping._s_init();
        org.xiph.fvorbis.FuncTime._s_init();
        org.xiph.fvorbis.FuncResidue._s_init();
		
		var ogg = new OggLoader(new URLRequest('stars.ogg'));
		
		Timer.delay(function() {
						trace('loaded');
						var player = new OggPlayer(ogg.getData(), 0, 1, 0);
		}, 500);
		
		
	}
	
}