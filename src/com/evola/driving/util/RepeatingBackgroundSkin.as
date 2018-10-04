package com.evola.driving.util
{
	import flash.display.Bitmap;	
	import mx.skins.ProgrammaticSkin;

	public class RepeatingBackgroundSkin extends ProgrammaticSkin
	{
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var cls:Object = getStyle("backgroundImage");
			var bmp:Bitmap = new cls();
			graphics.clear();
			graphics.beginBitmapFill(bmp.bitmapData);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
		}
	}
}

