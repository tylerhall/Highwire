<?PHP
    // Stick your DBOjbect subclasses in here (to help keep things tidy).

    class User extends DBObject
    {
        public function __construct($id = null)
        {
            parent::__construct('hw_users', array('username', 'password', 'email', 'dt_created', 'last_login', 'ip'), $id);
        }
    }

	class CPU extends DBObject
	{
		public function __construct($id = null)
		{
			parent::__construct('hw_cpus', array('user_id', 'guid', 'hostname', 'nickname', 'ip', 'port', 'dt_created', 'dt_updated'), $id);
		}
	}

	class Service extends DBObject
	{
		public function __construct($id = null)
		{
			parent::__construct('hw_services', array('cpu_id', 'dt', 'type', 'name', 'txt_record', 'port'), $id);
		}
	}
