<?PHP
    require 'includes/master.inc.php';

    $db = Database::getDatabase();
    
    if(isset($_POST['btnLogin']))
    {
        $username = mysql_real_escape_string($_POST['email'], $db->db);
        $password = mysql_real_escape_string(md5($_POST['password'] . '87392676823sfdhkj'), $db->db);
        $user_id = $db->getValue("SELECT id FROM hw_users WHERE username = '$username' AND password = '$password'");
        if($user_id !== false)
        {
            $hash = md5($user_id . 'x36x54f865865v6v56v6543v6');
            redirect('test.php?user_id=' . $user_id . '&hash=' . $hash);
        }
        else
        {
            echo "<h2>Incorrect username or password</h2>";
        }
    }
    
    if(isset($_GET['hash']))
    {
        if($_GET['hash'] != md5($_GET['user_id'] . 'x36x54f865865v6v56v6543v6')) exit;

        $user_id = intval($_GET['user_id']);
        $cpus = $db->getRows("SELECT * FROM hw_cpus WHERE user_id = '$user_id'");
        foreach($cpus as $k => $v)
        {
            $cpus[$k]['service_count'] = $db->getValue("SELECT COUNT(*) FROM hw_services WHERE cpu_id = " . $v['id']);
        }

		if(isset($_GET['test']))
		{
			$cpu = new CPU($_GET['test']);
			$test = shell_exec("/usr/bin/telnet {$cpu->ip} {$cpu->port}");
			$test = stripos($test, 'connected');
		}
    }
?>

<h1>Test your Highwire connection</h1>

<?PHP if(!isset($_GET['hash'])) : ?>
<form action="test.php" method="post">
    <p><label for="email">Highwire Email:</label> <input type="text" name="email" value="" id="email"></p>
    <p><label for="password">Password:</label> <input type="password" name="password" value="" id="password"></p>
    <p><input type="submit" name="btnLogin" value="Login" id="btnLogin"></p>    
</form>
<?PHP endif; ?>

<?PHP if(isset($_GET['hash'])) : ?>
<h2>Connected Machines</h2>
<p>These are your machines that having sharing turned on. Also listed are the number of services that machine is currently sharing.</p>
<ul>
    <?PHP foreach($cpus as $c) : ?>
    <li>
        <?PHP echo $c['hostname']; ?>
        (<?PHP echo $c['service_count']; ?> services shared) -
        <a href="test.php?user_id=<?PHP echo $_GET['user_id']; ?>&amp;hash=<?PHP echo $_GET['hash']; ?>&amp;test=<?PHP echo $c['id']; ?>">Test this connection</a>
    </li>
    <?PHP endforeach; ?>
</ul>

<?PHP if(isset($test)) : ?>

<?PHP if($test === false) : ?>
<h3>We were unable to connect to your machine.</h3>
<?PHP else : ?>
<h3>Yay! We were able to connect to your machine.</h3>
<?PHP endif; ?>

<?PHP endif; ?>

<?PHP endif; ?>