package net.smartsocket.smartlobby.lobby
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.smartsocket.smartlobby.lobby.components.*;
	import net.smartsocket.smartlobby.tools.*;
	
	public class Lobby extends MovieClip
	
	{
		
		public var pm:PrivateMessages;
		
		public function Lobby()
		{
			Globals.lobby = this;
			trace("Lobby has been initialized.");
			
			if(Globals.customListeners["home"]) {
				Globals.customListeners["root"].removeChild(Globals.customListeners["home"]);
			}
						
			pm = new PrivateMessages();
			pm.tab.addEventListener(MouseEvent.MOUSE_DOWN, pm.startDragListener);
			pm.tab.addEventListener(MouseEvent.MOUSE_UP, pm.stopDragListener);
			pm.visible = false;			
			pm.x = 140;
			pm.y = 220;
			addChild(pm);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			try{
				Globals.customListeners["server"].initCustomLobbyFunctions();
			}catch(e) {
				trace("No custom lobby functions on server class.");
			}
		}
		
		
		
		private function init(e:Event) {
			Globals.customListeners["server"].joinRoom(0);
		}
		
		//# User event handling.
		
		/**
		 * Processes another user joining the current room
		 * @params user:Object The object of the user joining the room.
		 * @return void
		 */
		public function onUserJoin(user:Object):void {
			var o:Object = {label:user.Username, data:user.uid}
			ul._list.addItem(o);
		}
		
		/**
		 * Processes another user leaving the current room
		 * @params user:Object The object of the user leaving the room.
		 * @return void
		 */
		public function onUserLeave(user:Object):void {
			//# Delete them from our user list.
			for(var i:Number = 0; i < ul._list.length; i++) {
				var curr:Object = ul._list.getItemAt(i);
				trace(i+" ... "+curr.label);
				if(curr.label == user.Username) {
					ul._list.removeItem(curr);
					break;
				}
			}
			
			//# We need to check and see if we also need to delete them from the team lists
			if(Globals.my.room != 0) {
				//# We are not in the lobby so we definitely need to fin them in the team list and delete them
				for(i = 0; i < gl.listType[user.Team].dataProvider.length; i++) {
					var curr:Object = gl.listType[user.Team].dataProvider.getItemAt(i);
					
					if(curr.Username == user.Username) {
						gl.listType[user.Team].dataProvider.removeItem(curr);
						
						//# Need to add some more logic here to delete all of the user's players
						//# From the field if the game has been launched!!!
						
						break;
					}
				}
			}
		}
		
		/**
		 * Processes a user list
		 * @params userList:Array An array of user objects in the room.
		 * @return void
		 */
		public function onUserList(userList:Array):void {
			ul._list.removeAll();
			for(var i:Number = 0; i < userList.length; i++) {
				var user:Object = userList[i];
				//trace(user.Username);
				var o:Object = {label:user.Username, data:user.uid}
				ul._list.addItem(o);
				
				//# Lets do a quick test to see if this removes using the object....
				//ul._list.removeItem(o);//This works
			}		
		}
		
		//# Room event handling.
		
		public function onCreateRoom(room:Object):void {
			Globals.my.createdRoom = room._id;
			Globals.customListeners["server"].joinRoom(room._id);
		}
		
		/**
		 * Processes this client's join of a room
		 * @params room:Object The object of the newly joined room.
		 * @return void
		 */
		public function onRoomJoin(room:Object):void {
			Globals.my.room = room.ID;
			try {
				Globals.customListeners["root"].alert.animate_out();
				
			}catch(e) {
				
			}
			Globals.customListeners["server"].getUserList();
			
			if(room.ID != 0) {
				gl.switchTo("tl");
				Globals.customListeners["server"].getTeamList();
				Globals.customListeners["server"].joinTeam("unassigned");
							
			}else {
				Globals.my.createdRoom = null;
				gl.switchTo("gl");
				Globals.customListeners["server"].getRoomList();
			}
		}
		
		/**
		 * Processes this client's leave of a room
		 * @params room:Object The object of the room being left.
		 * @return void
		 */
		public function onRoomLeave(room:Object):void {
			if(room.ID != 0) {
				Globals.customListeners["server"].joinRoom(0);				
			}	
		}
		
		/**
		 * Processes a list of rooms to be displayed
		 * @params roomList:Array An array of room objects.
		 * @return void
		 */
		public function onRoomList(roomList:Array):void {
			gl.listType._list.removeAll();
			for(var i:Number = 0; i < roomList.length; i++) {
				var room:Object = roomList[i];
				
//				var o:Object = {
//					ID : room._id,
//					Name : room._name,
//					Current : room._currentUsers,
//					Max : room._maxUsers,
//					Creator : room._creator._username,
//					Status : room._status,
//					Private : room._private
//				}
				
				
			}
			gl.listType._list.dataProvider.addItems(roomList);
		}
		
		/**
		 * Processes the addition of a newly created room
		 * @params room:Object The object newly created room.
		 * @return void
		 */
		public function onRoomAdd(room:Object):void {
//			var o:Object = {
//					ID : room._id,
//					Name : room._name,
//					Current : room._currentUsers,
//					Max : room._maxUsers,
//					Creator : room._creator._username,
//					Status : room._status,
//					Private : room._private
//				}
				
				gl.listType._list.dataProvider.addItem(room);
		}
		
		/**
		 * Processes the deletion room
		 * @params room:Object The object of the room to be deleted
		 * @return void
		 */
		public function onRoomDelete(room:Object):void {
			for(var i:Number = 0; i < gl.listType._list.dataProvider.length; i++) {
				var curr:Object = gl.listType._list.dataProvider.getItemAt(i);
				//trace(i+" ... "+curr._id);
				if(Number(curr.ID) == Number(room.ID)) {
					gl.listType._list.dataProvider.removeItem(curr);
					break;
				}
			}
		}
		
		/**
		 * Processes the event of a user joining or leaving a room (As seen *only* from a lobby)
		 * @params room:Object The object of the changed room.
		 * @return void
		 */
		public function onRoomCountUpdate(room:Object):void {
			
			for(var i:Number = 0; i < gl.listType._list.dataProvider.length; i++) {
				var curr:Object = gl.listType._list.dataProvider.getItemAt(i);
				
				if(Number(curr.ID) == Number(room.ID)) {
					trace("THIS IS THE CORRECT ROOM TO UPDATE. Room Stuff: "+[curr.Current,room.Current]);
					curr.Current = room.Current;
					trace(curr.Current);
					gl.listType._list.dataProvider.invalidateItem(curr);
					break;
				}
			}
		}
		
		//# Message event handling.
		/**
		 * Processes a new chat message to a room
		 * @params message:Object The object of the message. Contains the _sender and the _message
		 * @return void
		 */
		public function onMessageRoom(message:Object):void {
			chat.in_txt.htmlText += message.Username+": "+message.Message;
			chat.chat_scrollbar.update();
			chat.chat_scrollbar.scrollPosition = chat.chat_scrollbar.maxScrollPosition;
		}
		
		/**
		 * Processes a new private message to this client
		 * @params message:Object The object of the message. Contains the _sender and the _message.
		 * @return void
		 */
		public function onMessagePrivate(message:Object):void {
			pm.visible = true;
			pm.newMessage(message);
		}
		
		public function onTeamList(o:Object):void {
		 	gl.listType.unassigned.dataProvider.removeAll();
		 	gl.listType.red.dataProvider.removeAll();
		 	gl.listType.blue.dataProvider.removeAll();
		 	
		 	gl.listType.unassigned.dataProvider.addItems(o.unassigned);
		 	gl.listType.red.dataProvider.addItems(o.red);
		 	gl.listType.blue.dataProvider.addItems(o.blue);
		 	
		 	
		 }
		 
		 public function onTeamListChange(o:Object):void {
		 	trace(gl.listType[o.From]);
		 	
		 	//# Remove old
		 	if(o.From != o.To) {
		 		
			 	for(var i:Number = 0; i < gl.listType[o.From].dataProvider.length; i++) {
					var curr:Object = gl.listType[o.From].dataProvider.getItemAt(i);
					//trace(i+" ... "+curr.label);
					if(curr.Username == o.Username) {
						gl.listType[o.From].removeItem(curr);
						break;
					}
				}				
		 	}
		 	
		 	if(o.From != o.To || o.To == "unassigned") {
		 		gl.listType[o.To].addItem({Username:o.Username, Status:o.Status});
		 	}
		 	
		 	if(o.Username == Globals.my.Username) {
		 		
		 		Globals.my.Team = o.To;
		 		trace("This is me, my team is now "+Globals.my.Team);
		 	}
		 }
		 
		 public function onTeamReadyStatusChange(o:Object) {
		 	
		 	for(var i:Number = 0; i < gl.listType[o.Team].dataProvider.length; i++) {
				var curr:Object = gl.listType[o.Team].dataProvider.getItemAt(i);
				
				if(curr.Username == o.Username) {
					curr.Status = o.Status;
					gl.listType[o.Team].dataProvider.invalidateItem(curr);
					break;
				}
			}
		 	
		 }
	}
}