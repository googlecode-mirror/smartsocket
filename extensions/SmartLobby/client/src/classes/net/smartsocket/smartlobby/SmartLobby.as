package net.smartsocket.smartlobby {
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.dynamicflash.util.Base64;
	
	import flash.events.*;
	import flash.net.Socket;
	
	import net.smartsocket.smartlobby.tools.*;
	 public class SmartLobby extends Socket{
		
		//############### CONNECTION CONTROL
		public function onConnect(e:Event):void{trace("onConnect method currently does nothing. "+e);}
		public function onDisconnect(e:Event):void{trace("onDisconnect method currently does nothing. "+e);}
		public function onError(e:Event):void{trace("onError method currently does nothing. "+e);}
		
		//############### ACCOUNT CONTROL
		public function onLogin(e:Object):void{trace("onLogin method currently does nothing. "+e);}
		public function onInitUserObject(e:Object):void{trace("onJoinLobby method currently does nothing. "+e);}

		//############### LISTING FEATURES
		//public function onRoomList(e:Array):void{trace("onRoomList method currently does nothing. "+e);}
		//public function onUserList(e:Array):void{trace("onUserList method currently does nothing. "+e.toString());}
		//public function onRoomUpdate(e:Array):void{trace("onRoomUpdate method currently does nothing. "+e);}

		//############### ROOM CONTROL
		//public function onCreateRoom(e:Array):void{trace("onCreateRoom method currently does nothing. "+e);}
		//public function onJoinRoom(e:Array):void{trace("onJoinRoom method currently does nothing. "+e);}
		//public function onLeaveRoom(e:Array):void{trace("onLeaveRoom method currently does nothing. "+e);}
		//public function onUserJoin(e:Array):void{trace("onUserJoin method currently does nothing. "+e);}
		//public function onUserLeave(e:Array):void{trace("onUserLeave method currently does nothing. "+e);}

		//############### CHAT CONTROL
		//public function onRoomMessage(e:JSON):void{};
		//public function onPrivateMessage(e:JSON):void{};

		//############### USER OBJECT CONTROL
		public var my:Object = {Username:null};

		public function init():void {
			addEventListener(ProgressEvent.SOCKET_DATA, this.onJSON);
			addEventListener(Event.CONNECT, this.onConnect);
			addEventListener(Event.CLOSE, this.onDisconnect);
			addEventListener(IOErrorEvent.IO_ERROR, this.onError);
			
		}
		
		protected function onJSON(event:ProgressEvent):void {
			
			var incoming:String = this.readUTFBytes(this.bytesAvailable);
			trace("SmartLobby => Received "+incoming);
			var arr:Array = incoming.split("\r");
			arr.pop();
			
			for(var i:Number = 0; i < arr.length; i++) {
				
				var data:String = com.dynamicflash.util.Base64.decode(arr[i]);
				trace("SmartLobby => Processing "+data);
				
				var decoder:JSONDecoder = new JSONDecoder(data);
				var json:Array = decoder.getValue();				
				var method:String = json[0];				
				var params = json[1];
				
				try {
					trace("Trying function on SmartLobby");
					Globals.lobby[method](params);
				}catch(e) {
					trace("Did not fire on SmartLobby: "+e);
					for(var j:String in Globals.customListeners) {
						 
						if(Globals.customListeners[j].hasOwnProperty(method)) {
							try {
								trace("SmartLobby => Trying "+method+" on "+Globals.customListeners[j]);
								Globals.customListeners[j][method](params);
							}catch(e) {
								trace("SmartLobby => "+method+" has errors: "+e);
							}finally {
								trace("=============");
							}
							break;
						}
						
					}
				}
			}
		}
			
		
		public function send(data:Object):Boolean {
			var json:String = JSON.encode(data);
			try {
				trace("SmartLobby => Sending "+json);
				this.writeUTFBytes( com.dynamicflash.util.Base64.encode(json)+"\r");
				this.flush();
				
				return true;
			}catch (e) {
				trace("SmartLobby => Send error ("+json+"):"+e);
				return false;
			}
			return false;
		}
		//##############
		
		//# SmartLobby core functions.
		public function login(details:Object) {
			var o:Object = ["login", details];				
			send(o);
		}
		
		public function joinLobby() {
			var o:Object = ["joinLobby",{}];
			send(o);
		}
		
		public function leaveLobby() {
			var o:Object = ["leaveLobby",{}];
			send(o);
		}
		
		public function joinRoom(room:Number) {
			var o:Object = ["joinRoom",{
				"_id" : room
			}];
			send(o);
		}
		
		public function getUserList() {
			var o:Object = ["getUserList",{}];
			send(o);
		}
		
		public function getRoomList() {
			var o:Object = ["getRoomList",{}];
			send(o);
		}
		
		public function createRoom(details:Object) {
			var o:Object = ["createRoom", details];			
			send(o);
		}
		
		public function leaveRoom() {
			var o:Object = ["leaveRoom",{}];			
			send(o);			
		}
		
		public function sendRoom(message:String) {
			var o:Object = ["sendRoom",{
				"_message" : message
			}];				
			send(o);
		}
		
		public function sendPrivate(target:String, message:String) {
			var o:Object = ["sendPrivate",{
				"_message" : message,
				"_target" : target
			}];				
			send(o);
		}		
	}
}