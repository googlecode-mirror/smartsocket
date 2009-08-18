<?php
require_once("./Extensions/SmartLobby/Room.php");
require_once("./Extensions/SmartLobby/User.php");
Class SmartLobby implements Template{
	protected $s;
	protected $clients = array();
	
	//# Both the client and the server must have these two
	//# Secret word to further secure the md5 key
	protected $SecretWord = "smartlobby";
	//# Secret offset to the timestamp
	protected $SecretOffset = 420;
	
	//# This is an array they must be checked for each incoming message This may slow things down a little
	//# but it's more secure to have this in place, just in case someone is able to slip in
	protected $UserCount = 0;
	protected $UserObjects = array();
	
	protected $DebugClients = array();
	
	protected $RoomCount = 0;
	protected $RoomObjects = array();
	
	private function cd($class, $str) {
		if(CLIENT_DEBUG === true) {
			$this->s->Send($this->DebugClients, __CLASS__. "\t: ". $str);
		}
		return $str;
	}
	
	final public function SmartLobby() {
		Logger::log(__CLASS__, "Extension loaded.");
		define("CLIENT_DEBUG", true);
		
		//# Let's try and locate a configuration file. This is useful for making your own config for your extension.
		if(@file_exists("Extensions/SmartLobby/Config.xml")) {
			if($xml = simplexml_load_file("Extensions/SmartLobby/Config.xml")) {
				
				//# Let's setup the persistent mysql connection. We use this for registering users or checking usernames and credentials and perhaps even stats or profile tracking.
				if((string)$xml->mysql["enabled"] == "true") {
					$mysql = $xml->mysql->connection;					
					mysql_pconnect((string)$mysql["host"], (string)$mysql["username"], (string)$mysql["password"])or Logger::log(__CLASS__, "SmartLobby cannot contact MySQL. Please check your Config.xml: ".mysql_error(), true);
					mysql_select_db((string)$mysql["database"]) or Logger::log(__CLASS__, "SmartLobby cannot contact the database. Please check your Config.xml.", true);
				}
				
				//# Now, we look at the configurations and create some default rooms.
				
				//print_r($xml);
				$default_rooms = $xml->default_rooms;		
				foreach($xml->default_rooms->room as $room){
					$roomObj = new Room($this->RoomCount, $room);		
					array_push($this->RoomObjects, $roomObj);
				}
			}else {
				
			}
			
		}else {
			Logger::log(__CLASS__, "No extension config.xml file detected. Skipping...");
		}

		//# Let's create a new server instance.
		$this->s = new Server($this);

		//# Let's start the show.
		$this->s->Start();
		echo($this->s->master);

	}

	public function onConnect($socket) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, "The extension has received a connection."));
		
		/*
		 * You can add more connection logic here if you want, like sending the key to the client.
		 * I however prefer that the client send the key first, thus ensuring that the client is
		 * official and not some telnet hacker.
		 * 
		 * You could also do some stuff like creating ips and stuff like that.
		 */
		
	}

	public function onReceive($socket, $raw_data) {

		Logger::log(__CLASS__, $this->cd(__CLASS__, "Data Received: $socket, ".$raw_data));

		//# Let's write the received data fo a file for loging purposes.
		$file = fopen("ProtocolLog.txt", "a");
		fwrite($file, $raw_data);

		/*
		 * We are using XML here, so let's ensure that the data being sent to the server is in fact
		 * XML. If it isn't that means that someone has sent unauthorized packets and we should log
		 * their IP address, ban it, and disconnect that client.
		 */

		if(!$xml = @simplexml_load_string($raw_data, 'SimpleXMLElement', LIBXML_NOCDATA)) {
			Logger::log(__CLASS__, $this->cd(__CLASS__, "Invalid XML received from $socket. Disconnecting user."));
			$this->s->Handler->onDisconnect($socket, $this->s->master);
			return false;
		}
		
		/*
		 * Let's see if that user is authed or not.
		 * We check to see if the client has already been authed.
		 * If it hasn't, then it will check to see if the data that this method is recieving is a key
		 * to auth them. If it isnt' then they will be disconnected and their command will be discarded.
		 * If they ARE sending an auth key, then the 
		 */
		
		if( !isset($this->UserObjects[$socket]) ) {
			//# User has not been authed. The only command we will accept is
			//# the lock command. If the command is not the lock command, we
			//# should disconnect that user...
			if( (string)$xml->getName() != "lock" ) {
				//# Lock command not issued, let's dc them				
				Logger::log(__CLASS__, $this->cd(__CLASS__, "Client not authed and not sending auth key. Disconecting..."));
				$this->s->Handler->onDisconnect($socket, $this->s->master);
				return false;
			}else {
				//# Lock command was issued, let's check their key.				
				$KeyHoleShape = md5(((float)$xml["time"]+$this->SecretOffset)."$this->SecretWord");
				
				//# Compare Key to KeyHole
				if( (string)$xml["key"] != $KeyHoleShape ) {
					Logger::log(__CLASS__, $this->cd(__CLASS__, "Client sent invalid auth key ".$xml["key"]." to $KeyHoleShape... Disconecting..."));
					$this->s->Handler->onDisconnect($socket, $this->s->master);					
					return false;
				}else {
					//# Add them to the authed sockets array. We will delete them when they depart.
					$this->UserObjects[$socket] = "asdasdasd";
					if((string)$xml["debug"] == "true") {
						array_push($this->DebugClients, $socket);
					}
					//# No need to send them a message, if the client is still connected
					//# It will begin to transmit data immediately after sending the key to the server.
					Logger::log(__CLASS__, $this->cd(__CLASS__, "Client sent valid auth key ".(string)$xml["key"]." to $KeyHoleShape..."));
					return true;
				}
			}
			
			//# Let's go ahead and return here so make sure nothing gets though.
			return true;
		}
		
		/*
		 * Now we need to check that the command being sent to the server actually exists.
		 * Without this error checking, the server will crash with a FATAL error for calling a
		 * non existant method. This would not be good. Instead, we will simply disregard that command
		 * and possibly ban that client, if we know that our code is sound.
		 */
		if(!method_exists($this, $xml->getName()) and !isset($xml["object"])) {
			Logger::log(__CLASS__, $this->cd(__CLASS__, "Valid XML was received, however, no corresponding command exists."));
			return false;
		}else if(method_exists((string)$xml["object"], $xml->getName())){
			
			switch((string)$xml['object']) {
				
				case "Room":
					$command = $xml->getName();
					$room = $this->UserObjects[$socket]->room;
					$this->RoomObjects[0]->$command($socket, $xml, $this->s);
				break;
			}
			
		}else {
			$command = $xml->getName();
			$this->$command($socket, $xml);
		}
		//# We can send it back to the client like this
		//$this->s->Send($socket, $raw_data);

	}

	public function onDisconnect($socket) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, "User departed..."));
		
		$this->getUserObj($socket, $u, $r);
		
		unset($this->UserObjects[$socket]);
		
		if($r) {
			$r->onUserLeave($socket, $this->s);
			//# We need to send this to the main lobby. I need to make a revision later that checks
			//# all rooms for a usercountupdate property. If it's true, send the room a message so 
			//# that the user numbers stay current.
			//$this->s->Send($this->RoomObjects[0]->sockets, "<onRoomUpdate room='".(int)$xml['id']."' event='UserCountUpdate' int='-1' />");
		}
			
		//# If you want some other disconnect logic here, you can create it.
	}

	//## Begin SmartLobby (LOBBY) functions.

	//############### ACCOUNT CONTROL
	/**
	 * Create a registered user using MySQL or a database of your choice.
	 * @param $socket
	 * @param $xml
	 * @return bool
	 */
	public function register( $socket, $xml ) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called by $socket."));
		
		/*$sql = "
		SELECT `username`,`password`
		FROM `users` WHERE
		`username` = '".safe( (string)$xml["username"] )."' AND
		`password` = '".safe( $xml["password"] )."'
		LIMIT 1";
		$query = mysql_query($sql);*/

	}

	/**
	 * Login a registered user, or guest if guest accounts are enabled.
	 * @param $socket Resource
	 * @param $xml SimpleXMLElement
	 * @return bool
	 */
	public function login( $socket, $xml ) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

		$sql = "
		SELECT `username`,`password`
		FROM `users` WHERE
		`username` = '".safe( (string)$xml["username"] )."' AND
		`password` = '".safe( $xml["password"] )."'
		LIMIT 1";
		$query = mysql_query($sql);

		$sql = "
		SELECT `username`
		FROM `users_online` WHERE
		`username` = '".safe( $xml["username"] )."'
		LIMIT 1";
		$query2 = mysql_query($sql);

		if(mysql_num_rows($query) === 1 and mysql_num_rows($query2) === 0 or 1==1) {
			$u = mysql_fetch_assoc($query);
			mysql_free_result($query);
			mysql_free_result($query2);
			
			$cc = $this->UserCount;
			$this->UserCount++;
			$this->UserObjects[$socket] = new User(safe((string)$xml["username"]), $cc, $socket);
			print_r($this->UserObjects[$socket]);
			
			Logger::log(__CLASS__, $this->cd(__CLASS__, mysql_error()));
				
			$this->s->Send($socket, "<onLogin s='1' username='".(string)$xml['username']."' />");
			return true;
		}else {
			$this->s->Send($socket, "<onLogin s='0' e='Invalid login detected' />");
			return false;
		}

	}
	
	//############### LISTING FEATURES
	/**
	 * Obtain an XML formatted list of Room objects, and send the data to the client...
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function getRoomList($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));
		$x = "<onRoomList>\n";
		
		foreach($this->RoomObjects as $key=>$room) {
			$x .= "<room name='$room->name' id='$room->id' type='$room->type' count='$room->count' max_count='$room->max_count' />\n";
		}
		$x .= "</onRoomList>";
		$this->s->Send($socket, $x);

	}

	/**
	 * Join selected room.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function joinRoom($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));
		
		if( !( $this->RoomObjects[ (int)$xml["id"] ] instanceOf Room ) ) {
			Logger::log(__CLASS__, $this->cd(__CLASS__,"joinRoom: NOT Room object."));
			$this->s->Send($socket, "<onJoinRoom s='0' e='Error: Room ".(string)$xml['id']." does not exist.' />".chr(0));
			return false;
		}
		
		$r = &$this->RoomObjects[ (int)$xml["id"] ];
			
		$r->newUser($socket, $this->getUserObj($socket), $this->s);
		
		//# We need to send this to the main lobby. I need to make a revision later that checks
		//# all rooms for a usercountupdate property. If it's true, send the room a message so 
		//# that the user numbers stay current.
		/**
		 * @todo handle this on the client...
		 */
		$this->s->Send($this->RoomObjects[0]->sockets, "<onRoomUpdate event='RoomCountUpdate' id='".(int)$xml['id']."' int='1' />");
		
		return true;

	}

	/**
	 * Leave current room, and join the default lobby.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function leaveRoom($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}

	//############### CHAT CONTROL
	/**
	 * Send a chat message to current room.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function roomMessageT($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}

	/**
	 * Send a chat message to selected user.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function privateMessage($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}
	
	//# MISC
	
	public function client_data($socket , &$user=null) {
		$sql = "
		SELECT *
		FROM `users_online` WHERE
		`socket_id` = '$socket'
		LIMIT 1";
		$query = mysql_query($sql);
		$user = mysql_fetch_assoc($query);
		return $user;
	}
	
	/**
	 * This method allows you to easily collect data assigned to a specific socket, like username, room name, etc.
	 * @param $socket resource "The socket for which you wish to retrieve an user object."
	 * @param $userObj object "The user object will be passed by reference to this variable."
	 * @param $roomObj object "The user's room object will also be passed by reference should you need it."
	 * @return object "The user object"
	 */
	public function getUserObj($socket, &$userObj=false, &$roomObj=false) {
		if(isset($this->UserObjects[$socket])) {
			print_r($this->UserObjects[$socket]);
			$userObj = $this->UserObjects[$socket];
			if(isset($this->RoomObjects[$userObj->room])){
				echo("@@@\n");
				//# Passes the user's room information by reference if desired.
				$roomObj = $this->RoomObjects[(int)$userObj->room];
			}
		}
		return $userObj;
	}
















}
?>