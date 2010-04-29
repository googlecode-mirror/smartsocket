/*
Version: MPL 1.1/LGPL 2.1/GPL 2.0

The contents of this file are subject to the Mozilla Public License Version 
1.1 (the "License"); you may not use this file except in compliance with
the License.

The Original Code is the SmartSocket ActionScript 3 API SmartLobby lobby options component class..

The Initial Developer of the Original Code is
Jerome Doby www.smartsocket.net.
Portions created by the Initial Developer are Copyright (C) 2009-2010
the Initial Developer. All Rights Reserved.

Alternatively, the contents of this file may be used under the terms of
either of the GNU General Public License Version 2 or later (the "GPL")
or
the terms of any one of the MPL, the GPL or the LGPL.
*/
package net.smartsocket.smartlobby.lobby.components
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import net.smartsocket.smartlobby.tools.*;
	import net.smartsocket.smartlobby.lobby.components.alertclips.CreateGame;
	import net.smartsocket.smartlobby.SmartLobby;

	public class Options extends MovieClip
	{
		
		var alert:Alert;
		public function Options()
		{
			tab.label.text = "Options";
			create_btn.addEventListener(MouseEvent.MOUSE_UP, handle_create);
		}
		
		public function handle_create(e:MouseEvent) {
			
			SmartLobby.customListeners["root"].alert = new Alert("MovieClip", CreateGame, "Create Game");
			SmartLobby.customListeners["root"].alert.ok.addEventListener(MouseEvent.MOUSE_UP, createRoom);
			SmartLobby.customListeners["root"].addChild(SmartLobby.customListeners["root"].alert);
			
			var roomOptions = SmartLobby.customListeners["root"].alert.cpane_mc.content;
			
			//# Add Maps
			roomOptions.map.addItem({label:"Standoff", data:"Standoff"});
			
		}
		
		private function createRoom(e:MouseEvent) {
			var roomOptions = SmartLobby.customListeners["root"].alert.cpane_mc.content;
			
			var o:Object = {
				"_name" : roomOptions.name_txt.text,
				"_maxUsers" : roomOptions.max_players.value,
				"_private" : roomOptions.isPrivate.selected,
				"_map" : roomOptions.map.value
			};
			SmartLobby.customListeners["server"].createRoom(o);
		}
		
	}
}