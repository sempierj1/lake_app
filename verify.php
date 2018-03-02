<?php 
error_reporting(E_ALL);
ini_set('display_errors', 1);

include '/var/www/lakeinc/includes/dbinfo.inc.php';

if(isset($_GET['email']) && !empty($_GET['email']) AND isset($_GET['hash']) && !empty($_GET['hash']))
{
    $email = mysqli_real_escape_string($db, $_GET['email']);
    $hash = mysqli_real_escape_string($db, $_GET['hash']);
    
    $search = mysqli_query($db, "SELECT Email, Password FROM Members WHERE Email='".$email."' AND Password='".$hash."'") or die(mysqli_error($db));
    $result = mysqli_num_rows($search);
    
    if($result > 0)
    {
    $continue = true;
    }
    else
    {
    echo "<div class=''>Invalid Access - Please use the link that was sent to your email.</div>";
    $continue = false;
    }
}
else 
{
    echo "<div class=''>Invalid Access - Please use the link that was sent to your email.</div>";
    $continue = false;
}
?>

<html>
<head>
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript" src="verify.js"></script>
	<link rel="stylesheet" href="pw.css">
	<script>
	window.onload = function hideForm()
    {
        var val = "<?php echo $continue?>";
        if(val!= 1)
        {
                document.getElementById("passwordDiv").style.display="none";
                document.getElementById("pswd_info").style.display="none";
        }
    }
	</script>
</head>
<body>
<div id = "passwordDiv">
  <form id = "register" action="password.php" method ="post">
    <input type="hidden" name = "email" id="email" value="<?php echo $email;?>">
    <label for="psw">Password</label>
    <input type="password" id="password" name="psw" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Must contain at least one number and one uppercase and lowercase letter, and at least 8 or more characters" required>
    <input type="password" id="confirm_password" name="confirm" placeholder="Confirm Password" required>
    <span id="result"></span>
    <span id="match"></span>
    <input type="submit" value="Submit">
  </form>
</div>

<div id="pswd_info">
    <h4>Password must meet the following requirements:</h4>
    <ul>
        <li id="letter" class="invalid">At least <strong>one letter</strong></li>
        <li id="capital" class="invalid">At least <strong>one capital letter</strong></li>
        <li id="number" class="invalid">At least <strong>one number</strong></li>
        <li id="length" class="invalid">Be at least <strong>8 characters</strong></li>
    </ul>
</div>
 


</body>

</html>
