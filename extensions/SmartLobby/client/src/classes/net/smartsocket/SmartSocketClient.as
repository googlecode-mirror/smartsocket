package net.smartsocket {
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.dynamicflash.util.Base64;
	
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	
	import net.smartsocket.smartlobby.lobby.Lobby;
	
	public class SmartSocketClient extends Socket{
		
		
		
		//############### CONNECTION CONTROL
		public function onConnect(e:Event):void{trace("onConnect method currently does nothing. "+e);}
		public function onDisconnect(e:Event):void{trace("onDisconnect method currently does nothing. "+e);}
		public function onError(e:Event):void{trace("onError method currently does nothing. "+e);}
				
		public static var customListeners:Array = new Array();
		
		public static var useBase64:Boolean = false;
		
		public function SmartSocketClient() {
			addEventListener(ProgressEvent.SOCKET_DATA, this.onJSON);
			addEventListener(Event.CONNECT, this.onConnect);
			addEventListener(Event.CLOSE, this.onDisconnect);
			addEventListener(IOErrorEvent.IO_ERROR, this.onError);
		}
		
//		public function init():void {
//			addEventListener(ProgressEvent.SOCKET_DATA, this.onJSON);
//			addEventListener(Event.CONNECT, this.onConnect);
//			addEventListener(Event.CLOSE, this.onDisconnect);
//			addEventListener(IOErrorEvent.IO_ERROR, this.onError);			
//		}
		
		
		
		protected function onJSON(event:ProgressEvent):void {
			
			var incoming:String = this.readUTFBytes(this.bytesAvailable);
			trace("SmartSocketClient => Received "+incoming.replace("\r",""));
			var arr:Array = incoming.split("\r");
			arr.pop();
			
			for(var i:Number = 0; i < arr.length; i++) {
				var data:String;
				
				if(useBase64) {				
					data = com.dynamicflash.util.Base64.decode(arr[i]);
				}else {
					data = arr[i]
				}
				
				trace("SmartSocketClient => Processing "+data);
				
				var decoder:JSONDecoder = new JSONDecoder(data);
				var json:Array = decoder.getValue();				
				var method:String = json[0];				
				var params:* = json[1];
				
				
				for(var j:String in customListeners) {
					
					if(customListeners[j].hasOwnProperty(method)) {
						try {
							trace("SmartSocketClient => Trying "+method+" on "+customListeners[j]);
							customListeners[j][method](params);
						}catch(e:Error) {
							trace("SmartSocketClient => "+method+" has errors: "+e);
						}finally {
							
						}
						break;
					}
					
				}
				
			}
		}
		
		
		public function send(data:Object):Boolean {
			var json:String = JSON.encode(data);
			try {
				trace("SmartSocketClient => Sending "+json);
				
				if(useBase64) {				
					this.writeUTFBytes( com.dynamicflash.util.Base64.encode(json)+"\r");
				}else {
					this.writeUTFBytes( json+"\r");
				}
				
				this.flush();				
				return true;
			}catch (e:Error) {
				trace("SmartSocketClient => Send error ("+json+"):"+e);
				return false;
			}
			return false;
		}
		//##############
	}
}