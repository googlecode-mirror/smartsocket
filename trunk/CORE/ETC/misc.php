<?php

function Start() {
	$smartsocket_config = new Loader(); 
	echo("
*********************************************
*                                           *
* SmartSocket: Extensible PHP Socket Server *
* http://www.SmartSocket.net                *
* @Author: Jerome Doby                      *
* @Email: Jerome@SmartSocket.net            *
*                                           *
*********************************************
v".SMARTSOCKET_VERSION." Build ".SMARTSOCKET_BUILD."
\n\n");
	
	//# We check for auto updates here.
	if(SMARTSOCKET_AUTOUPDATE == "false") {
		
		Logger::log(__FUNCTION__ , "Skipping update check. Change SMARTSOCKET_AUTOUPDATE to true on Config.xml");
		
	} else {
		Logger::log(__FUNCTION__ , "Checking for updates...");
		
		if($latest = @(int)file_get_contents("http://smartsocket.googlecode.com/svn/trunk/DIST/BUILD")) {
			//# Compare build number
			if(SMARTSOCKET_BUILD < $latest) {
				Logger::log(__FUNCTION__ , "Update found...");
								
				if($file = @file_get_contents("http://smartsocket.googlecode.com/svn/trunk/DIST/libsmartsocket.dll", FILE_BINARY)) {
					Logger::log(__FUNCTION__ , "Update retrieved...");
					$update = fopen("libsmartsocket.dll", "wb");
					fwrite($update, $file);
					fclose($update);
					Logger::log(__FUNCTION__ , "Update applied.");
					Logger::log(__FUNCTION__ , "To see the changes, check out http://www.smartsocket.net");
					Logger::log(__FUNCTION__ , "You must now restart SmartSocket.", true);
				}else {
					Logger::log(__FUNCTION__ , "Skipping - Could not reach the latest stable build file.");
				}
				
			}elseif (SMARTSOCKET_BUILD > $latest) {
				Logger::log(__FUNCTION__ , "Skipping - Your build (".SMARTSOCKET_BUILD.") is newer than the public release ($latest).");
				
			}else {
				Logger::log(__FUNCTION__ , "You already have the latest build.");
				
			}
		}else {
			Logger::log(__FUNCTION__ , "Skipping - Could not reach the latest stable build report.");
		}
	}
	
	//# If update not needed, we will continue.
	echo("\n");
	$em = new ExtensionManager();
	$em->Start();

}

function safe($value){
	
	if ( get_magic_quotes_gpc() ){
		$value = stripslashes($value);
	}

	$value = mysql_real_escape_string($value);
	return $value;
}

?>