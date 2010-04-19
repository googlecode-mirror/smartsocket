package net.smartsocket.smartlobby.lobby.components
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.smartsocket.smartlobby.tools.*;
	import net.smartsocket.smartlobby.lobby.components.alertclips.CreateGame;

	public class Options extends MovieClip
	{
		
		var alert:Alert;
		public function Options()
		{
			tab.label.text = "Options";
			create_btn.addEventListener(MouseEvent.MOUSE_UP, handle_create);
		}
		
		public function handle_create(e:MouseEvent) {
			
			Globals.customListeners["root"].alert = new Alert("MovieClip", CreateGame, "Create Game");
			Globals.customListeners["root"].alert.ok.addEventListener(MouseEvent.MOUSE_UP, createRoom);
			Globals.customListeners["root"].addChild(Globals.customListeners["root"].alert);
			
			var roomOptions = Globals.customListeners["root"].alert.cpane_mc.content;
			
			//# Add Maps
			roomOptions.map.addItem({label:"Standoff", data:"Standoff"});
			
		}
		
		private function createRoom(e:MouseEvent) {
			var roomOptions = Globals.customListeners["root"].alert.cpane_mc.content;
			
			var o:Object = {
				"_name" : roomOptions.name_txt.text,
				"_maxUsers" : roomOptions.max_players.value,
				"_private" : roomOptions.isPrivate.selected,
				"_map" : roomOptions.map.value
			};
			Globals.customListeners["server"].createRoom(o);
		}
		
	}
}