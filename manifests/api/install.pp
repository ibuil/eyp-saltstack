class saltstack::api::install inherits saltstack::api {

  case $saltstack::api::package_ensure
  {
    'installed': { $pip_ensure='present' }
    'present': { $pip_ensure='present' }
    default: { $pip_ensure='absent' }
  }

  if($saltstack::api::manage_package)
  {
    include ::saltstack::repo

    Class['::saltstack::repo'] ->
    package { $saltstack::params::api_package_name:
      ensure => $saltstack::api::package_ensure,
    }

    if($saltstack::params::api_dependencies!=undef)
    {
      package { $saltstack::params::api_dependencies:
        ensure => $saltstack::api::package_ensure,
        before => Package[$saltstack::params::api_package_name],
      }
    }

    if($saltstack::params::api_pip_dependencies!=undef)
    {
      include ::python

      exec { 'update setuptools':
        command => 'pip install --upgrade pip setuptools',
        onlyif  => 'pip list 2>&1 | grep upgrade',
        path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      }

      pythonpip { $saltstack::params::api_pip_dependencies:
        ensure  => $pip_ensure,
        before  => Package[$saltstack::params::api_package_name],
        require => Exec['update setuptools'],
      }
    }
  }
}
