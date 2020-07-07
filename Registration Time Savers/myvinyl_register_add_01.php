<?php
		
			//session_start();
			$link = mysql_connect('localhost', 'myvinyl7841', 'V1NY1db_pw0552k');
			if (!$link) { 
    			die('Could not connect: ' . mysql_error()); 
			} 
			
			mysql_select_db(myvinyl_db);
			function user_login($userEmail, $serial){ 
				//take the username and prevent SQL injections 
				$userEmail = mysql_real_escape_string($userEmail); 
				$serial = mysql_real_escape_string($serial); 
				//begin the query 
				$sql = "SELECT * FROM usersTable WHERE `email` = '$userEmail' AND `serial` = '$serial'";
				$sql = mysql_query($sql);
				//check to see how many rows were returned 
				$rows = mysql_num_rows($sql); 
				if ($rows<=0 ){ 
					//Create User
					$addYou = "INSERT INTO usersTable (`userID`, `email`, `serial`) VALUES (NULL, '$userEmail', '$serial')";
					$addYou = mysql_query($addYou);
					echo "added $userEmail."; 
				} else { 
					//Already Exists
					echo "already exists.";
				}
				
			}
			
			if (isset($_GET['email']) && isset($_GET['serial'])) {
			user_login($_GET['email'], $_GET['serial']); 
			}

?>