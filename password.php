<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

include '/var/www/lakeinc/includes/dbinfo.inc.php';
 
if(isset($_POST['email']) && !empty($_POST['email']) AND isset($_POST['psw']) && !empty($_POST['psw']))
{
    $pwescape = mysqli_real_escape_string($db, $_POST['psw']);
    $pw = password_hash($pwescape, PASSWORD_DEFAULT);
    $query = "UPDATE Members SET Password = ? WHERE Email = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("ss", $pw, $_POST['email']);
    if($stmt->execute())
    {
        echo "Success";
    }
    else 
    {
        echo "Failure";
    }
}
else
{
    echo "No Post";
}
?>