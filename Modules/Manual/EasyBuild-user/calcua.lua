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
-- Avoid loading together with EasyBuild-production
--

family( 'EasyBuildConfig' )

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
if ( stack_name == nil ) then
  if ( mode() == 'load' ) then
    LmodError( 'The environment variable ' .. site .. '_STACK_NAME is missing, did you load a valid software stack module?' )
  elseif ( mode() == 'unload' ) then
    LmodMessage( 'The environment variable ' .. site .. '_STACK_NAME is missing, did you unload the software stack module?' )
  else
    stack_name = '<STACK>'
  end
end
local stack_version =          os.getenv( site .. '_STACK_VERSION' )
if ( stack_version == nil ) then
  if ( mode() == 'load' ) then
    LmodError( 'The environment variable ' .. site .. '_STACK_VERSION is missing, did you load a valid software stack module?' )
  elseif ( mode() == 'unload' ) then
    LmodMessage( 'The environment variable ' .. site .. '_STACK_VERSION is missing, did you unload the software stack module?' )
  else
    stack_version = '<VERSION>'
  end
end
local archspec_os =            os.getenv( site .. '_ARCHSPEC_OS' )
if ( archspec_os == nil ) then
  if ( mode() == 'load' ) then
    LmodError( 'The environment variable ' .. site .. '_ARCHSPEC_OS is missing, did you load a valid software stack module?' )
  elseif ( mode() == 'unload' ) then
    LmodMessage( 'The environment variable ' .. site .. '_ARCHSPEC_OS is missing, did you unload the software stack module?' )
  else
    archspec_os = '<OS>'
  end
end
local archspec_target =        os.getenv( site .. '_ARCHSPEC_TARGET' )
if ( archspec_target == nil ) then
  if ( mode() == 'load' ) then
    LmodError( 'The environment variable ' .. site .. '_ARCHSPEC_TARGET is missing, did you load a valid software stack module?' )
  elseif ( mode() == 'unload' ) then
    LmodMessage( 'The environment variable ' .. site .. '_ARCHSPEC_TARGET is missing, did you unload the software stack module?' )
  else
    archspec_target = '<ARCH>'
  end
end
local archspec_target_compat = os.getenv( site .. '_ARCHSPEC_TARGET_COMPAT' )
if ( archspec_target_compat == nil ) then
  if ( mode() == 'load' ) then
    LmodError( 'The environment variable ' .. site .. '_ARCHSPEC_TARGET_COMPAT is missing, did you load a valid software stack module?' )
  elseif ( mode() == 'unload' ) then
    LmodMessage( 'The environment variable ' .. site .. '_ARCHSPEC_TARGET_COMPAT is missing, did you unload the software stack module?' )
  else
    archspec_target_compat = '<ARCH_COMPAT>'
  end
end

local user_buildpath = os.getenv( 'XDG_RUNTIME_DIR' )
if ( user_buildpath == nil ) then
  -- We're not sure yet if XDG_RUNTIME_DIR exists everywhere where we want to use the module
  user_buildpath = pathJoin( '/dev/shm/', os.getenv('USER') )
else
  user_buildpath = pathJoin( user_buildpath, 'easybuild' )
end

-- - Prepare some additional variables to reduce the length of some lines
local stack
if stack_version == '' then
  stack =               stack_name
else
  stack =               stack_name  .. '-' .. stack_version
end
local archspec =        archspec_os .. '-' .. archspec_target
local archspec_compat = archspec_os .. '-' .. archspec_target_compat

-- - Compute a number of paths and file names in the user directory
local user_sourcepath =           pathJoin( user_prefix, 'sources' )
local user_configdir =            pathJoin( user_prefix, 'config' )
local user_easyconfigdir =        pathJoin( user_prefix, 'easyconfigs' )
local user_installpath =          pathJoin( user_prefix, 'stacks', stack, archspec )
local user_installpath_software = pathJoin( user_installpath, 'software' )
local user_installpath_modules =  pathJoin( user_installpath, 'usermodules-' .. stack )
local user_repositorypath =       pathJoin( user_installpath, 'ebfiles_repo' )

local user_configfile_generic =   pathJoin( user_configdir, 'user.cfg' )
local user_configfile_stack =     pathJoin( user_configdir, 'user-' .. stack .. '.cfg' )

-- - Compute a number of system-related paths and file names.
--   These should align with the EasyBuild-production module!
local system_repositorypath
if stack_version == '' then
  system_repositorypath =         pathJoin( system_prefix, 'repo', archspec_target_compat .. '-' .. archspec_os )
else
  system_repositorypath =         pathJoin( system_prefix, 'repo', archspec_target_compat .. '-' .. archspec_os, stack_version )
end
local system_configdir =          pathJoin( system_prefix, 'config' )
local system_easyconfigdir =      pathJoin( system_prefix, 'github/UAntwerpen-easyconfigs' )

local system_configfile_generic = pathJoin( system_configdir, 'production.cfg' )
local systen_configfile_stack =   pathJoin( system_configdir, 'production-' .. stack .. '.cfg' )

--
-- Set the EasyBuild variables that point to paths or files
--

-- - Single component paths

setenv( 'EASYBUILD_PREFIX',               user_prefix )
setenv( 'EASYBUILD_SOURCEPATH',           user_sourcepath )
setenv( 'EASYBUILD_BUILDPATH',            user_buildpath )
setenv( 'EASYBUILD_INSTALLPATH',          user_installpath )
setenv( 'EASYBUILD_INSTALLPATH_SOFTWARE', user_installpath_software )
setenv( 'EASYBUILD_INSTALLPATH_MODULES',  user_installpath_modules )
setenv( 'EASYBUILD_REPOSITORY',           'FileRepository' )
setenv( 'EASYBUILD_REPOSITORYPATH',       user_repositorypath )

-- - ROBOT_PATHS

--   + Always included: the user and system repository for the software stack
local robot_paths = {user_repositorypath, system_repositorypath}

--   + If we are using one the calcua/20xxx software stacks, we do need to include the
--     repository for the calcua/system software stack also.
if ( stack_name == 'calcua' ) and ( stack_version ~=  'system' ) then
  table.insert( robot_paths, pathJoin( system_prefix, 'repo', archspec_target_compat .. '-' .. archspec_os, 'system' ) )
end

--   + For any calcua software stack, we do need to include the repository for the
--     generic-x86 software stack also.
if stack_name == 'calcua' then
  table.insert( robot_paths, pathJoin( system_prefix, 'repo', 'x86_64' .. '-' .. archspec_os ) )
end

--   + As we will create the user easyconfigdir anyway, we can safely include it too.
table.insert( robot_paths, user_easyconfigdir )

--   + And at the end, we include the system easyconfig directory.
table.insert( robot_paths, system_easyconfigdir )

setenv( 'EASYBUILD_ROBOT_PATHS', table.concat( robot_paths, ':' ) )

-- - List of configfiles

local configfiles = {}

if isFile( system_configfile_generic )  then table.insert( configfiles, system_configfile_generic ) end
if isFile( user_configfile_generic )    then table.insert( configfiles, user_configfile_generic )   end
if isFile( systen_configfile_stack )    then table.insert( configfiles, systen_configfile_stack )   end
if isFile( user_configfile_stack)       then table.insert( configfiles, user_configfile_stack )     end

if #configfiles > 0 then
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
-- Create the directory structure
--
-- This isn't really needed as EasyBuild will create those that it needs on the
-- fly, but it does help to suggest to users right away where which files will
-- land.
--

if mode() == 'load' then

  if not isDir( user_repositorypath )       then execute{ cmd='mkdir -p ' .. user_repositorypath,       modeA={'load'} } end
  if not isDir( user_sourcepath )           then execute{ cmd='mkdir -p ' .. user_sourcepath,           modeA={'load'} } end
  if not isDir( user_easyconfigdir )        then execute{ cmd='mkdir -p ' .. user_easyconfigdir,        modeA={'load'} } end
  if not isDir( user_configdir )            then execute{ cmd='mkdir -p ' .. user_configdir,            modeA={'load'} } end
  if not isDir( user_installpath_software ) then execute{ cmd='mkdir -p ' .. user_installpath_software, modeA={'load'} } end
  if not isDir( user_installpath_modules )  then
    execute{ cmd='mkdir -p ' .. user_installpath_modules,  modeA={'load'} }
    -- We've just created the directory so it was not yet in the MODULEPATH.
    -- Add it and leave it to the software stack module which will find it when
    -- it does an unload to remove the directory from the MODULEPATH.
    prepend_path( 'MODULEPATH', user_installpath_modules )
  end

end

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
  * EBU_USER_PREFIX: Prefix for the EasyBuild user installation. The default
    is $VSC_DATA/EasyBuild.
The following variables should correspond to those use in EasyBuild-production:
  * EBU_SYSTEM_PREFIX: Directory where EasyBuild searches for the system config
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
helptext = helptext .. '     - Generic config file:                   ' .. user_configfile_generic .. '\n'
helptext = helptext .. '     - Software stack-specific config file:   ' .. user_configfile_stack .. '\n'
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
also a good syntax check for the configuration files.

First use for a software stack
==============================
The module will also take care of creating most of the subdirectories that it
sets, even though EasyBuild would do so anyway when you use it. It does however
give you a clear picture of the directory structure just after loading the
module, and it also ensures that the software stack modules can add your user
modules to the front of the module search path.
]==]

help( helptext )

