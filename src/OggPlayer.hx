/**
 * Copyright (c) 2010 Nathan Rajlich
 * 
 * This file is part of SoundJS.
 * 
 * SoundJS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 * 
 * SoundJS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with SoundJS.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

 /*
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.media.Sound;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundChannel;
import flash.utils.ByteArray;
import flash.utils.ByteArray;
import flash.events.EventDispatcher;
*/
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.Vector;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.ByteArray;



import org.xiph.foggy.Demuxer;
import org.xiph.system.ADQueue;
import org.xiph.system.Bytes;
import org.xiph.system.VSoundDecoder;

class OggPlayer  {
    var audioDataQueue : ADQueue; // audio data queue
    var decoder : VSoundDecoder;

    var _decoding : Bool;
    var _need_data : Bool;
    var _need_samples : Bool;
    var _data_min : Bool;
    var _data_complete : Bool;
    var _read_pending : Bool;

    var sound : flash.media.Sound;
    var soundChannel : flash.media.SoundChannel;

    var counterInt : Int;
    
    private var data : ByteArray;

    public static inline var SAMPLERATE : Int = 44100;
    public static inline var DATA_CHUNK_SIZE : Int = 16384;

    public function new(indata:ByteArray, offset:Float, volume:Float, pan:Float) {
				trace('new');
        //super();
        indata.position = 0;
        this.data = new ByteArray();
        indata.readBytes(this.data);
        indata.position = 0;
           trace(this.data.length);
        _need_data = false;
        _need_samples = true;
        _data_min = false; // FIXME: should be _samples_min !!
        _data_complete = true;
        _read_pending = false;
        _decoding = true;
        
        counterInt = 0;
        
        audioDataQueue = new ADQueue(Std.int(1000 * SAMPLERATE / 1000));
        audioDataQueue.over_min_cb = queueOverMinCallback;
        audioDataQueue.over_max_cb = queueOverMaxCallback;
        audioDataQueue.under_max_cb = queueUnderMaxCallback;

        decoder = new VSoundDecoder();
        decoder.decoded_cb = decodedCallback;
        
        haxe.Timer.delay(timerTryWriteData, 0);
		
        sound = new Sound();
        soundChannel = null;
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		
        haxe.Timer.delay(timerDecode, 0);
    }
    
    public  function stop() : Void {
				trace('stop');
        soundChannel.removeEventListener(Event.SOUND_COMPLETE, channelComplete);
        soundChannel.stop();
    }

    function timerTryWriteData() : Void {
				trace('timerTryWriteData');
        _read_pending = false;

        if (! _need_data)
            return;

        var to_read : Int = this.data.length;
		trace(to_read);
		
        if (to_read >= DATA_CHUNK_SIZE) {
            to_read = DATA_CHUNK_SIZE;
        } else if (_data_complete) {
            if (decoder.dmx.eos) {
                _need_data = false;
                return;
            }
            // pass
        } else {
            // we could reshedule read here, but if we don't have
            // enough data and we're still downloading then
            // on_progress should call us again... right?
            return;
        }
		trace(to_read);
		
        _need_data = false;

        decoder.dmx.read(this.data, to_read);

		
		
        //if (_data_complete)
        //    _dec.dmx.read(_ul, 0);

        if (_need_samples)
            haxe.Timer.delay(timerDecode, 0);
    }

    function timerDecode() : Void {
				trace('timerDecode');
        var result : Int = 0;

        while(_need_samples && (result = decoder.dmx.process(1)) == 1) {
            // pass
        }

        if (result == Demuxer.EOF) {
            // pass
        } else if (result == 0) {
            _need_data = true;
            if (!_read_pending) {
                _read_pending = true;
                haxe.Timer.delay(timerTryWriteData, 0);
            }
        }
    }
   
    

    // ADQueue callbacks
    function queueOverMinCallback() : Void {
				trace('queueOverMinCallback');
        _data_min = true;
        if (_decoding && soundChannel == null) {
            soundChannel = sound.play();
            soundChannel.addEventListener(Event.SOUND_COMPLETE, channelComplete);
        }
    }

    function queueOverMaxCallback() : Void {
				trace('queueOverMaxCallback');
        _need_samples = false;
    }

    function queueUnderMaxCallback() : Void {
		trace('queueUnderMaxCallback');
        _need_samples = true;
        haxe.Timer.delay(timerDecode, 0);
    }



    // VSoundDecoder callback
    function decodedCallback(pcm : Array<Vector<Float>>, index : Vector<Int>, samples : Int) : Void {
		//trace('decodedCallback');
        audioDataQueue.write(pcm, index, samples);
    }


	
    // Sound data callback
    function onSampleData(event : SampleDataEvent) : Void {
		trace('onSampleData $counterInt');
        var avail : Int = audioDataQueue._samples;
        var to_write = avail > 8192 ? 8192 : avail; // FIXME: unhardcode!

        if (to_write > 0) {
            audioDataQueue.read(event.data, to_write);
            counterInt += to_write;
        } else {
        }
    }
    
    private function channelComplete(e) {
        //dispatchEvent(new SoundEvent(Event.SOUND_COMPLETE));
    }
}
