--
-- Some site configuration, but there may be more as there are more parts currently
-- tuned for the UAntwerp configuration
--

-- User configuration
local default_user_prefix = os.getenv( 'VSC_DATA' ) .. '/EasyBuild'
-- System configuration
local default_system_prefix = '/apps/antwerpen/easybuild'

local site = 'CALCUA' -- Site-specific prefix for the environment variable names set in the software stack modules.
local ebu =  'EBU'    -- Site-specific prefix for the environment variable names that are likely set either in the system profile or user profile.

-- -----------------------------------------------------------------------------
--
-- Slightly more generic part of the configuration, though not yet
-- as generic as we would like
--


whatis( 'Prepares EasyBuild for installation in a user directory.' )

--
-- Packages that are needed
--

lfs =  require( 'lfs' )


-- Make sure EasyBuild is loaded.
-- We don't care which version is loaded but will load the default one ourselves.
if not isloaded( 'EasyBuild' ) then
    load( 'EasyBuild' )
end

--
-- Compute the configuration
--

-- - Read data from the environment or initialize with default values.
local user_prefix =    os.getenv( ebu .. '_USER_PREFIX' )
local system_prefix =  os.getenv( ebu .. '_SYSTEM_PREFIX' )
if ( user_prefix    == nil ) then user_prefix    = default_user_prefix    end
if ( system_prefix  == nil ) then system_prefix  = default_system_prefix  end

local stack_name =             os.getenv( site .. '_STACK_NAME' )
local stack_version =          os.getenv( site .. '_STACK_VERSION' )
local archspec_os =            os.getenv( site .. '_ARCHSPEC_OS' )
local archspec_target =        os.getenv( site .. '_ARCHSPEC_TARGET' )
local archspec_target_compat = os.getenv( site .. '_ARCHSPEC_TARGET_COMPAT' )

-- - Prepare some additional variables to reduce the length of some lines
local stack = stack_name .. '-' .. stack_version
local archspec = archspec_os .. '-' .. archspec_target
local archspec_compat = archspec_os .. '-' .. archspec_target_compat

-- - Compute a number of paths and file names
local user_sourcepath =           pathJoin( user_prefix, 'sources' )
local user_installpath_software = pathJoin( user_prefix, 'software', stack, archspec )
local user_installpath_modules =  pathJoin( user_prefix, 'modules',  stack, archspec, 'user-' .. stack )
local user_repositorypath =       pathJoin( user_prefix, 'repo',     stack, archspec )
local user_configdir =            pathJoin( user_prefix, 'config' )
local user_easyconfigdir =        pathJoin( user_prefix, 'easyconfigs' )
local user_buildpath =            pathJoin( '/dev/shm/', os.getenv('USER') )

local user_configfile_generic =   pathJoin( user_configdir, 'user.cfg' )
local user_configfile_stack =     pathJoin( user_configdir, 'user-' .. stack .. '.cfg' )

local system_repositorypath =     pathJoin( system_prefix, 'repo', stack, archspec_compat )
local system_configdir =          pathJoin( system_prefix, 'config' )
local system_easyconfigdir =      pathJoin( system_prefix, 'github/UAntwerpen-easyconfigs' )

local system_configfile_generic = pathJoin( system_configdir, 'production.cfg' )
local systen_configfile_stack =   pathJoin( system_configdir, 'production-' .. stack .. '.cfg' )

--
-- Set the EasyBuild variables that point to paths or files
--

-- - Single component paths

setenv( 'EASYBUILD_INSTALLPATH',          user_prefix )
setenv( 'EASYBUILD_SOURCEPATH',           user_sourcepath )
setenv( 'EASYBUILD_BUILDPATH',            user_buildpath )
setenv( 'EASYBUILD_INSTALLPATH_SOFTWARE', user_installpath_software )
setenv( 'EASYBUILD_INSTALLPATH_MODULES',  user_installpath_modules )
setenv( 'EASYBUILD_REPOSITORYPATH',       user_repositorypath )

-- - ROBOT_PATHS

local robot_paths = {user_repositorypath, system_repositorypath}

if lfs.attributes( user_easyconfigdir, 'mode' ) == 'directory' then
    table.insert( robot_paths, user_easyconfigdir )
end
table.insert( robot_paths, system_easyconfigdir )

setenv( 'EASYBUILD_ROBOT_PATHS', table.concat( robot_paths, ':' ) )

-- - List of configfiles

local configfiles = {}

if lfs.attributes( system_configfile_generic, 'mode') == 'file' then
    table.insert( configfiles, system_configfile_generic )
end
if lfs.attributes( user_configfile_generic,   'mode') == 'file' then
    table.insert( configfiles, user_configfile_generic )
end
if lfs.attributes( systen_configfile_stack,   'mode') == 'file' then
    table.insert( configfiles, systen_configfile_stack )
end
if lfs.attributes( user_configfile_stack,     'mode') == 'file' then
    table.insert( configfiles, user_configfile_stack )
end

if #configfiles > 0 then
    -- Omit the 'NOFILE,' at the front
    setenv( 'EASYBUILD_CONFIGFILES', table.concat( configfiles, ',' ) )
end

--
-- Other EasyBuild settings that do not depend on paths
--

-- Let's all use python3 for EasyBuild, but this assumes at least EasyBuild version 4.
setenv( 'EB_PYTHON', '/usr/bin/python3' )

-- Set optarch if needed.
if archspec_target == 'zen2' then
    setenv( 'EASYBUILD_OPTARCH', 'Intel:march=core-avx2 -mtune=core-avx2;GCC:march=znver2 -mtune=znver2' )
elseif archspec_target == 'x86_64' then
    setenv( 'EASYBUILD_OPTARCH', 'GENERIC' )
end

-- -----------------------------------------------------------------------------
--
-- Bash function to create the directory structure
--

local bash_func_init = [==[
    mkdir -p $EASYBUILD_SOURCEPATH ;
    mkdir -p $EASYBUILD_INSTALLPATH_SOFTWARE ;
    mkdir -p $EASYBUILD_INSTALLPATH_MODULES ;
    mkdir -p $EASYBUILD_REPOSITORYPATH ;
    mkdir -p $EASYBUILD_INSTALLPATH/config ;
    mkdir -p $EASYBUILD_INSTALLPATH/easyconfigs ;
]==]

local csh_func_init = bash_func_init

set_shell_function( 'EasyBuild-user-init', bash_func_init, csh_func_init )

-- -----------------------------------------------------------------------------
--
-- Make an adaptive help block: If the module is loaded, different information
-- will be shown.
--

helptext = [==[
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

The following user-specific directories and files are used by this module:
]==]

helptext = helptext .. '  * Directory for EasyConfig files:           ' .. user_easyconfigdir .. '\n'
helptext = helptext .. '  * Software installation:                    ' .. user_installpath_software .. '\n'
helptext = helptext .. '  * Module files:                             ' .. user_installpath_modules .. '\n'
helptext = helptext .. '  * EasyBuild configuration files:            ' .. user_configdir .. '\n'
helptext = helptext .. '     - Generic config file:                   user.cfg\n'
helptext = helptext .. '     - Software stack-specific config file:   user-'  .. stack .. '.cfg\n'
helptext = helptext .. '  * Sources of installed packages:            ' .. user_sourcepath .. '\n'
helptext = helptext .. '  * Repository of installed EasyConfigs       ' .. user_repositorypath .. '\n'
helptext = helptext .. '  * Builds are performed in:                  ' .. user_buildpath .. '\n'
helptext = helptext .. '    Don\'t forget to clean if a build fails!\n'
helptext = helptext .. '\nThe following system directories and files are used (if present):\n'
helptext = helptext .. '  * Generic config file:                      ' .. system_configfile_generic .. '\n'
helptext = helptext .. '  * Software stack-specific config file:      ' .. systen_configfile_stack .. '\n'
helptext = helptext .. '  * Directory of EasyConfig files:            ' .. system_easyconfigdir .. '\n'
helptext = helptext .. '  * Repository of installed EasyConfigs:      ' .. system_repositorypath .. '\n'
helptext = helptext .. [==[

If multiple configuration files are given, they are read in the following order:
  1. System generic configuration file
  2. User generic configuration file
  3. System stack-specific configuration file
  4. User stack-specific configuration file
Options that are redefined overwrite the old value. However, environment variables set by
this module do take precedence over the values computed from the configuration files.

To check the actual configuration used by EasyBuild, run ``eb --show-config``. This is
also a good syntax check for the files.

First use for a software stack
==============================
EasyBuild will auto-create most of these directories if they do not yet exist. However,
if you use the module for the first time for a specific software stack and for a specific
combination of processor and OS version, it may be a good idea to create the directories
and then reload the software stack module and the EasyBuild-user module (if the latter is
not reloaded automatically).

For this purpose, we created the command ``EasyBuild-user-init`` which is non-destructive,
so if you run it on top of an already initialised setup, it should not damage it.

]==]

help( helptext )

