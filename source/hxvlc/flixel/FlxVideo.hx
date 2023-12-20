package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import hxvlc.openfl.Video;
import sys.FileSystem;

class FlxVideo extends Video
{
	/**
	 * Whether you want the video to automatically be resized.
	 */
	public var autoResize:Bool = true;

	/**
	 * Initializes a FlxVideo object.
	 *
	 * @param smoothing Whether or not the video is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(smoothing);

		#if FLX_SOUND_SYSTEM
		onOpening.add(function()
		{
			volume = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * 100);
		});
		#end

		FlxG.addChildBelowMouse(this);
	}

	public override function load(location:String, repeat:Int = 0, ?options:Array<String>):Bool
	{
		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (!FlxG.signals.postUpdate.has(postUpdate))
			FlxG.signals.postUpdate.add(postUpdate);

		if (FileSystem.exists(Sys.getCwd() + location))
			return super.load(Sys.getCwd() + location, repeat, options);

		return super.load(location, repeat, options);
	}

	public override function dispose():Void
	{
		if (FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.remove(resume);

		if (FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.remove(pause);

		if (FlxG.signals.postUpdate.has(postUpdate))
			FlxG.signals.postUpdate.remove(postUpdate);

		super.dispose();

		FlxG.removeChild(this);
	}

	@:noCompletion
	private function postUpdate():Void
	{
		if (autoResize)
		{
			width = FlxG.scaleMode.gameSize.x;
			height = FlxG.scaleMode.gameSize.y;
		}

		#if FLX_SOUND_SYSTEM
		if (!mute)
		{
			final curVolume:Int = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * 100);

			if (volume != curVolume)
				volume = curVolume;
		}
		#end
	}
}
#end
