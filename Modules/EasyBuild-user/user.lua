whatis( 'Prepares EasyBuild for installation in a user directory.' )

help( [[
Description
===========
The EasyBuild-user module configures EasyBuild through environment variables
for installation of software in a user directory.
    
The module works together with the software stack modules. Hence it is needed to first
load an appropriate software stack and only then load EasyBuild-user. After changing
the software stack it is needed to re-load this module (if it is not done automatically).
    
After loading the module, it is possible to simply use the eb command without further
need for aliases.
    
The module assumes the following environment variables:
  * EASYBUILD_USER_PREFIX: Prefix for the EasyBuild user installation. The default
    is $VSC_DATA/EasyBuild.
The following variables should correspond to those use in EasyBuild-production:
  * EASYBUILD_SYSTEM_PREFIX: Directory where EasyBuild searches for the system config
    files, system EasyConfig files and puts the repo. The default value is
    /apps/antwerpen/easybuild.
  * EASYBUILD_INSTALL_PREFIX: Directory where EasyBuild will put binaries, sources and
    modules. The default is /apps/antwerpen.
The following variables should be set by the software stack module:
  * CALCUA_STACK_NAME: The name of the software stack (typically the name of the module
    used to activate the software stack).
  * CALCUA_STACK_VERSION: The version number of the software stack.
  * CALCUA_ARCHSPEC_OS: The operating system.
  * CALCUA_ARCHSPEC_TARGET: The CPU architecture of the compute node
    as reported by archspec.
  * CALCUA_ARCHSPEC_TARGET (EasyBuild-user): The CPU architecture of the compute node
    as reported by archspec. Using this instead of VSC_ARCH_LOCAL may help to make
    the module compatible with the EESSI software stack in the future.
  * CALCUA_ARCHSPEC_TARGET_COMPAT: A hopefully temporary hack for UAntwerpen
    as we have used "rome" instead of "zen2".
    
]] )

local default_system_prefix = '/apps/antwerpen/easybuild'
local default_user_prefix = os.getenv( 'VSC_DATA ' ) .. '/EasyBuild'
local default_install_prefix = '/apps/antwerpen'
local site = 'CALCUA' -- Site-specific first part of the variable names.

local user_prefix =    os.getenv( 'EASYBUILD_USER_PREFIX' )
local system_prefix =  os.getenv( 'EASYBUILD_SYSTEM_PREFIX' )
local install_prefix = os.getenv( 'EASYBUILD_INSTALL_PREFIX')

local stack_name =      os.getenv( site .. '_STACK_NAME' )
local stack_version =   os.getenv( site .. '_STACK_VERSION' )
local archspec_os =     os.getenv( site .. '_ARCHSPEC_OS' )
local archspec_target = os.getenv( site .. '_ARCHSPEC_TARGET' )

-- Prepare some additional variables to reduce the length of some lines
local stack = stack_name .. '-' .. stack_version
local archspec = archspec_os .. '-' .. archspec_target 
local archspec_compat = archspec_os .. '-' .. archspec_target_compat

setenv( 'EASYBUILD_SOURCEPATH', user_prefix .. '/Sources' )
setenv( 'EASYBUILD_BUILDPATH', '/dev/shm/' .. os.getenv('USER') )
setenv( 'EASYBUILD_INSTALLPATH_SOFTWARE', user_prefix .. '/Software/' .. stack .. '/' .. archspec )
setenv( 'EASYBUILD_INSTALLPATH_MODULES', user_prefix .. '/Modules/' .. stack .. '/' .. archspec .. '/user-' .. stack )
setenv( 'EASYBUILD_REPOSITORYDIR', user_prefix.. '/Repo/' .. stack .. '/' .. archspec )

local robot_paths = ''
robot_paths =                       user_prefix.. '/Repo/' .. stack .. '/' .. archspec
robot_paths = robot_paths .. ':' .. repo .. stack .. '/' .. archspec_compat
robot_paths = robot_paths .. ':' .. system_prefix .. '/github/UAntwerpen-easyconfigs'
setenv( 'EASYBUILD_ROBOT_PATHS', robot_paths )

setenv( 'EB_PYTHON', '/usr/bin/python3' )