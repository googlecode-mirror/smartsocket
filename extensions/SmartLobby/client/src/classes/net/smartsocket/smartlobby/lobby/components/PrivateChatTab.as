package net.smartsocket.smartlobby.lobby.components
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.events.TweenEvent;
	
	import flash.display.MovieClip;
	
	import net.smartsocket.smartlobby.tools.*;

	public class PrivateChatTab extends MovieClip
	{
		public var uid;
		public var blinkTween:TweenLite;
		public var blinking:Boolean = false;
		public function PrivateChatTab(myName:String)
		{
			this.name = myName;
			this.cacheAsBitmap = true;
			super();
		}
		
		public function blink(state:String):void {
			
			switch(state) {
				
				case "start":
				blinking = true;
				blinkTween = new TweenLite(this, .5, {y: this.y+5, ease: Strong.easeOut, onComplete: startYoyo});
				break;
				
				case "stop":
				blinking = false;
				this.y = 0;
				blinkTween.complete();
				break;
				
				
			}
		}
		
		public function startYoyo(e:TweenLite) {
			blinkTween.reverse();
		}
		
	}
}