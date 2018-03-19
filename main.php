<?php
//error_reporting(E_ALL);
//ini_set('display_errors', 1);

include '/var/www/lakeinc/includes/dbinfo.inc.php';
//USE COMPOSER TO SETUP PHPMAILER AND IMPORT
require 'vendor/autoload.php';

if(isset($_POST['email']))
{
    $email = $_POST['email'];
	/*Check for email in members*/
	$stmt = $db->prepare("SELECT Email FROM Members WHERE Email = ?");
	$stmt->bind_param('s', $email);
	$stmt->execute();
	$result = $stmt->get_result();
	
	/*Check if email was found
	 If email was found, create verification email to send
	 Else return error
	*/
	if($result)
	{
	if(mysqli_num_rows($result) > 0)
	{
	    $row = $result->fetch_assoc();
		$email = $row["Email"];
		
		//Generate random hash
		$hash = md5(rand(0,1000));
		
		$query = "UPDATE Members SET Password = '$hash' WHERE Email = '$email'";
		if($db->query($query) === TRUE)
		{
			/*//Compile Email
			$to = $email; //Email Address to be sent to
			$subject = 'Email Verification - Lake Parsippany'; // Subject of email
			$message = '
			
			Please click the following link to complete your email verification and set up a password
			
			https://mediahomecraft.ddns.net/lake/verify.php?email='.$email.'&hash='.$hash.'
			';
			
			$headers = 'From:noreply@mediahomecraft.ddns.net' ."\r\n"; //Set From Headers
			if(mail($to, $subject, $message, $headers))
			{//Send Email
			echo "Email Sent";
			}
			else 
			{
			    echo "Not sent";
			}*/
			$mail = new PHPMailer\PHPMailer\PHPMailer();
			$mail->IsSMTP();
			//$mail->SMTPDebug=1;
			$mail->SMTPAuth = true;
			$mail->SMTPSecure='ssl';
			$mail->Host = "smtp.gmail.com";
			$mail->Port = 465;
			$mail->IsHTML(true);
			$mail->Username = "laketest110@gmail.com";
			$mail->Password = "laketestapp110";
			$mail->SetFrom("laketest110@gmail.com");
			$mail->Subject="Email Verification - Lake Parsippany";
			$mail->Body = '
					
			Please click the following link to complete your email verification and set up a password
					
			https://mediahomecraft.ddns.net/lake/verify.php?email='.$email.'&hash='.$hash.'
			';
			$mail->AddAddress($email);
			
			if(!$mail->Send())
			{
				echo "Mail Error: " . $mail->ErrorInfo;
			}
			else 
			{
				echo 0;
			}
		}
		else
		{
		    echo "Update Failed";
		}
	}
	else
	{
	    echo "Email not found";
	}
	}
	else 
	{
	    echo "Email not found";
	}
}
else
{ 
    echo "Email not found";
}
?>