<?php
class Room {
	
	//# Array of socket resources
	public $sockets = array();
	public $name;
	public $type;
	public $count = 0;
	public $max_count;
	public $password;
	public $id;
	//# Array of user objects
	public $users = array();
	
	public function Room(&$id, $object) {
		$this->name = (string)$object["name"];
		$this->type = (string)$object["type"];
		$this->count = 0;
		$this->max_count = (int)$object["max_count"];
		$this->id = $id;
		$id++;
		$this->password = (string)$object["password"];
		Logger::log(__CLASS__, "New Room Object :");
		print_r($this);
		echo("**********\n");
	}
	
	public function newUser($socket, &$user, $server) {
		echo("???\n");
		print_r($user);
		if($user instanceOf User) {
			//# Create a variable with the name of $user->username and a value of $user (User class object)
			$this->users[(string)$user->username] = $user;
			$this->{(string)$socket} = (string)$user->username;
			Logger::log(__CLASS__, $this->{(string)$socket});
			print_r($this->users[$user->username]);
			//# If anyone is in that room, alert them of the new member
			if($this->count > 0) {
				$server->Send($this->sockets, "<onUserJoin username='$user->username' />");
			}
			//# Add them to the list of users and send them a successfull join packet
			$this->sockets[$user->id] = $socket;
			$this->count++;
			$user->room = $this->id;
			$server->Send($socket, "<onJoinRoom s='1' room='$this->id' name='$this->name' />");
			return true;
		}else {
			Logger::log(__CLASS__, __FUNCTION__.": This message should never appear.");
			return false;
		}
	}
	
	public function onUserLeave($socket, $server) {
		Logger::log(__CLASS__, "User Left");
		$this->getUser($socket, $u);
		$this->count--;
		unset($this->sockets[$u->id]);
		unset($this->users[$u->username]);
		
		if($this->count > 0) {
			$server->Send($this->sockets, "<onUserLeave username='$u->username' />");
		}
	}
	

	/**
	 * Obtain an XML formatted list of users in the current room.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function getUserList($socket, $xml, $server) {
		Logger::log(__CLASS__, __FUNCTION__." was called.");
		$x = "<onUserList>\n";
		
		foreach($this->users as $user=>$object) {
			$x .= "<user username='$user' />\n";
		}
		$x .= "</onUserList>";
		$server->Send($socket, $x);

	}

	//############### ROOM CONTROL
	/**
	 * Create a room with specified parameters.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function createRoom($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}
	
	public function roomMessage($socket, $xml, $server) {
		Logger::log(__CLASS__, __FUNCTION__." was called.");
		$this->getUser($socket, $user);
		$server->Send($this->sockets, "<onRoomMessage username='".$user->username."'><![CDATA[".(string)$xml."]]> </onRoomMessage>");
	}
	
	private function getUser($socket, &$userObj="") {
		$sockName = $this->{(string)$socket};
		$userObj = $this->users[(string)$sockName];
		
		return $userObj;
	}
	
}
?>
	
