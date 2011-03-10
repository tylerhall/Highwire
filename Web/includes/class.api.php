<?PHP
    class API
    {
        private $methods;
		private $authMethods;
        private $user;
        private $signature;

        public function __construct()
        {
            $this->methods     = array('createAccount');
            $this->authMethods = array('login', 'addMachine', 'removeMachine', 'listAllMachines', 'addService', 'removeService', 'listAllServices');

			foreach($_GET as $k => $v)
				$_GET[$k] = trim($v);

			$this->go();
        }

        public function go()
        {
			if(in_array($_GET['method'], $this->methods, true))
			{
				$this->$_GET['method']();
			}
			elseif(in_array($_GET['method'], $this->authMethods, true))
			{
				$this->authenticate();
               	$this->$_GET['method']();
			}
			else
			{
				$this->error('1', 'method not found');
			}
        }

        public function authenticate()
        {
			$this->requireGet('email', 'password');
			
			$db = Database::getDatabase();

			$username = $db->escape($_GET['email']);
			$password = $db->escape(md5($_GET['password'] . '87392676823sfdhkj'));

			$row = $db->getRow("SELECT * FROM hw_users WHERE username = '$username' AND password = '$password'");

			if($row === false)
				$this->error('Incorrect username or password.');
			
			$this->user = new User();
			$this->user->load($row);
        }

        public function requireGet($var)
        {
            $vars = func_get_args();
            foreach($vars as $v)
            {
                if(!isset($_GET[$v]))
                    $this->error("\"$v\" is a required GET parameter");
            }
        }

        public function requirePost($var)
        {
            $vars = func_get_args();
            foreach($vars as $v)
            {
                if(!isset($_POST[$v]))
                    $this->error("\"$v\" is a required POST parameter");
            }
        }

        public function out($arr)
        {
            //header('Content-Type: application/json');
            echo json_encode($arr);
            exit;
        }

		public function success()
		{
			$this->out(array('success' => 'true'));
		}

        public function error($msg)
        {
            $this->out(array('error' => $msg));
        }

		// YOUR METHODS GO HERE...

        public function createAccount()
        {
            $this->requireGet('email', 'password');

			$db = Database::getDatabase();
			$user_exists = $db->getValue('SELECT COUNT(*) FROM hw_users WHERE username = ' . $db->quote($_GET['email']));
			if(intval($user_exists) > 0)
				$this->error('That email address already exists.');

			$user = new User();
			$user->username = $_GET['email'];
			$user->password = md5($_GET['password'] . '87392676823sfdhkj');
			$user->dt_created = dater();
			$user->ip = $_SERVER['REMOTE_ADDR'];
            $user->last_login = dater();
			$user->insert();

            $this->success();
        }

        public function login()
        {
            $this->user->ip = $_SERVER['REMOTE_ADDR'];
            $this->user->last_login = dater();
            $this->user->update();
			$this->success();
        }

        public function addMachine()
        {
			$this->requireGet('hostname', 'port');

			$db = Database::getDatabase();
			$machine_id = $db->getValue('SELECT id FROM hw_cpus WHERE hostname = ' . $db->quote($_GET['hostname']) . ' AND user_id = ' . $this->user->id);
			if($machine_id === false)
			{
				$cpu = new CPU();
				$cpu->user_id = $this->user->id;
				$cpu->hostname = $_GET['hostname'];
				$cpu->ip = $_SERVER['REMOTE_ADDR'];
				$cpu->port = $_GET['port'];
				$cpu->dt_created = dater();
				$cpu->dt_updated = $cpu->dt_created;
				$cpu->insert();
			}
			else
			{
				$cpu = new CPU($machine_id);
				$cpu->ip = $_SERVER['REMOTE_ADDR'];
				$cpu->port = $_GET['port'];
				$cpu->dt_updated = dater();
				$cpu->update();
			}
			$this->success();
        }

        public function removeMachine()
        {
            $this->requireGet('hostname');

			$db = Database::getDatabase();
			$machine_id = $db->getValue('SELECT id FROM hw_cpus WHERE hostname = ' . $db->quote($_GET['hostname']) . ' AND user_id = ' . $this->user->id);
			if($machine_id === false)
				$this->error('machine does not exist');
			else
			{
				$cpu = new CPU($machine_id);
				$cpu->delete();
				$db->query("DELETE FROM hw_services WHERE cpu_id = '{$cpu->id}'");
				$this->success();
			}
        }

        public function listAllMachines()
        {
            $arr = array('cpus' => array());
            $cpus = DBObject::glob('CPU', 'SELECT * FROM hw_cpus WHERE user_id = ' . $this->user->id);
            foreach($cpus as $cpu)
            {
                $arr['cpus'][] = array('guid' => $cpu->guid, 'hostname' => $cpu->hostname, 'ip' => $cpu->ip, 'port' => $cpu->port);
            }
            $this->out($arr);
        }

		public function addService()
		{
			$this->requirePost('hostname', 'type', 'name', 'port');

			$db = Database::getDatabase();
			$machine_id = $db->getValue('SELECT id FROM hw_cpus WHERE hostname = ' . $db->quote($_POST['hostname']) . ' AND user_id = ' . $this->user->id);
			if($machine_id === false)
				$this->error('machine does not exist');
			else
			{
				$s = new Service();
				$s->cpu_id     = $machine_id;
				$s->dt         = dater();
				$s->type       = $_POST['type'];
				$s->name       = $_POST['name'];
				$s->txt_record = $_POST['txt_record'];
				$s->port       = $_POST['port'];
				$s->insert();
				$this->success();
			}
		}
		
		public function removeService()
		{
			$this->requirePost('hostname', 'type', 'name');
			
			$db = Database::getDatabase();
			$machine_id = $db->getValue('SELECT id FROM hw_cpus WHERE hostname = ' . $db->quote($_POST['hostname']) . ' AND user_id = ' . $this->user->id);
			if($machine_id === false)
				$this->error('machine does not exist');
			else
			{
				$type = $db->quote($_POST['type']);
				$name = $db->quote($_POST['name']);
				$db->query("DELETE FROM hw_services WHERE cpu_id = '$machine_id' AND `type` = $type AND `name` = $name");
				$this->success();
			}
		}
		
		public function listAllServices()
		{
			$this->requireGet('hostname');

			$db = Database::getDatabase();
			$machine_id = $db->getValue('SELECT id FROM hw_cpus WHERE hostname = ' . $db->quote($_GET['hostname']) . ' AND user_id = ' . $this->user->id);
			if($machine_id === false)
				$this->error('machine does not exist');
			else
			{
	            $arr = array('services' => array());
	            $services = DBObject::glob('Service', 'SELECT * FROM hw_services WHERE cpu_id = ' . $machine_id);
	            foreach($services as $s)
	            {
	                $arr['services'][] = array('type' => $s->type, 'name' => $s->name, 'txt_record' => $s->txt_record, 'port' => $s->port);
	            }
	            $this->out($arr);
			}
		}
    }
