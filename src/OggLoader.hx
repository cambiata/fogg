package ;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

/**
 * ...
 * @author 
 */
class OggLoader
{
	var _req:URLRequest;
	var _ul:URLStream;
    private var data : ByteArray;
	
    public function new(url:URLRequest) {
       // super();
        _req = url;
        _ul = new URLStream();
        _ul.addEventListener(Event.OPEN, onOpen);
        _ul.addEventListener(ProgressEvent.PROGRESS, onProgress);
        _ul.addEventListener(Event.COMPLETE, onLoaded);
        _ul.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity);
        try {
            _ul.load(_req);
        } catch (e:Dynamic) {
            var t = this;
            haxe.Timer.delay(function() {
                t.onSecurity(e);
            }, 0);
        }
    }
	
    // URLStream callbacks
    private function onOpen(e) {
        this.data = new ByteArray();
		trace('open');
        //dispatchEvent(new SoundEvent(SoundEvent.OPEN));
    }
    private function onProgress(e) {
        var newBytes : Int = e.bytesLoaded - this.data.length;
        if (newBytes > 0) {
            _ul.readBytes(this.data, this.data.length, newBytes);
        
            //dispatchEvent(new SoundEvent(SoundEvent.PROGRESS));
        }
		trace('progress');
    }
	
	
	
    private function onLoaded(e) {
        //dispatchEvent(new SoundEvent(SoundEvent.LOADED));
		trace('loaded');
		trace (this.data.length);
    }
    private function onError(e) {
        //dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }
    private function onSecurity(e) {
        //dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }	
	
	public function getData() return this.data;
	
	
}