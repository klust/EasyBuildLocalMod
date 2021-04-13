--
-- Some site configuration, but there may be more as there are more parts currently
-- tuned for the UAntwerp configuration
--

local default_system_prefix =  '/apps/antwerpen/easybuild'
local default_install_prefix = '/apps/antwerpen'
local site = 'CALCUA' -- Site-specific first part of the variable names.
local ebu =  'EBU'    -- Site-specific prefix for the environment variable names that are likely set either in the system profile or user profile.

-- -----------------------------------------------------------------------------
--
-- Slightly more generic part of the configuration, though not yet
-- as generic as we would like
--

whatis( 'Prepares EasyBuild for production installation in the system directories. Appropirate rights required.' )

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
local system_prefix =  os.getenv( ebu .. '_SYSTEM_PREFIX' )
local install_prefix = os.getenv( ebu .. '_INSTALL_PREFIX')
if ( system_prefix  == nil ) then system_prefix  = default_system_prefix  end
if ( install_prefix == nil ) then install_prefix = default_install_prefix end

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

-- - Prepare some additional variables to reduce the length of some lines
local stack
if stack_version == '' then
  stack =               stack_name
else
  stack =               stack_name  .. '-' .. stack_version
end
local archspec =        archspec_os .. '-' .. archspec_target
local archspec_compat = archspec_os .. '-' .. archspec_target_compat

-- - Compute a number of system-related paths and file names.
--   Some of those should align with the EasyBuild-production module!

--    + Some easy ones that do not depend the software stack itself
local system_sourcepath =           pathJoin( install_prefix, 'sources' )
local system_configdir =            pathJoin( system_prefix,  'config' )
local system_easyconfigdir =        pathJoin( system_prefix,  'github/UAntwerpen-easyconfigs' )
local system_buildpath =            pathJoin( '/dev/shm', os.getenv( 'USER' ) )
local system_tmpdir =               os.getenv( 'VSC_SCRATCH_NODE' )
local system_installpath =          install_prefix
--    + The install path for software, were we need to distinguish between
--      software stacks before calcua/2020b and from calcua/2020b on
local system_installpath_software
if ( stack_name == 'calcua' ) then
  -- xxxxy is converted to 10*xxxx + 0 for a = 1, 1 otherwise.
  local version_number
  if ( stack_version == 'system' ) then
    -- Treat as an old-style software stack, give a low number
    version_number = 0
  elseif ( stack_version:len() ~= 5 ) then
    -- Unrecongnized format, certainly not an old-style toolchain so give a big number
    version_number = 99990
  elseif ( stack_version:find( '^%d%d%d%d%a' ) == nil ) then
    -- Unrecongnized format, certainly not an old-style toolchain so give a big number
    version_number = 99990
  else
    version_number = 10 * tonumber( stack_version:sub(1,4)) + ( stack_version:sub(5) == 'a' and 0 or 1 )
  end
  if ( version_number <= 20200 ) then
    system_installpath_software = pathJoin( install_prefix, archspec_target_compat, archspec_os )
  else
    system_installpath_software = pathJoin( install_prefix, archspec_target_compat, archspec_os, stack )
  end
else
  system_installpath_software = pathJoin( install_prefix, archspec_target_compat, archspec_os )
end
--    + The install path for modules, where "generic-x86" is a special case.
local system_installpath_modules
if ( stack_version == '' ) then
  system_installpath_modules =      pathJoin( install_prefix, 'modules', archspec_os, 'software-' .. archspec_target_compat )
else
  system_installpath_modules =      pathJoin( install_prefix, 'modules', archspec_os, 'software-' .. archspec_target_compat, stack_version )
end
--    + The repository path, where generic-x86 is a special case
local system_repositorypath
if ( stack_version == '' ) then
  system_repositorypath =           pathJoin( system_prefix, 'repo', archspec_target_compat .. '-' .. archspec_os )
else
  system_repositorypath =           pathJoin( system_prefix, 'repo', archspec_target_compat .. '-' .. archspec_os, stack_version )
end

local system_configfile_generic = pathJoin( system_configdir, 'production.cfg' )
local systen_configfile_stack =   pathJoin( system_configdir, 'production-' .. stack .. '.cfg' )

--
-- Set the EasyBuild variables that point to paths or files
--

-- - Single component paths

setenv( 'EASYBUILD_PREFIX',               system_prefix )
setenv( 'EASYBUILD_SOURCEPATH',           system_sourcepath )
setenv( 'EASYBUILD_BUILDPATH',            system_buildpath )
setenv( 'EASYBUILD_TMPDIR',               system_tmpdir )
setenv( 'EASYBUILD_INSTALLPATH',          system_installpath )
setenv( 'EASYBUILD_INSTALLPATH_SOFTWARE', system_installpath_software )
setenv( 'EASYBUILD_INSTALLPATH_MODULES',  system_installpath_modules )
setenv( 'EASYBUILD_REPOSITORY',           'FileRepository' )
setenv( 'EASYBUILD_REPOSITORYPATH',       system_repositorypath )

-- - ROBOT_PATHS

--   + Always included: the system repository for the software stack
local robot_paths = {system_repositorypath}

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

--   + And at the end, we include the system easyconfig directory.
table.insert( robot_paths, system_easyconfigdir )

setenv( 'EASYBUILD_ROBOT_PATHS', table.concat( robot_paths, ':' ) )

-- - List of configfiles

local configfiles = {}

if isFile( system_configfile_generic )  then table.insert( configfiles, system_configfile_generic ) end
if isFile( systen_configfile_stack )    then table.insert( configfiles, systen_configfile_stack )   end

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
-- Initializing the directory structure
--
-- Contrary to the EasyBuild-user module, the directory structure is not
-- automatically created when running the module. However, EasyBuild itself
-- should be able to do that without problems.
--
-- The reason is that this module is used in an account with higher privileges
-- (software installation) so if anything goes wrong (even though mkdir -p shouldn't
-- really pose a risk), we can make a mess in the system installation.
--
-- We will ensure that the software installation directory is in the module path
-- though as otherwise a newly installed module would not be found.
--

if mode() == 'doload' then

  if not isDir( system_installpath_modules )  then
    -- Ensure the module installation path is in the module search path.
    prepend_path( 'MODULEPATH', system_installpath_modules )
  end

end

-- -----------------------------------------------------------------------------
--
-- Make an adaptive help block: If the module is loaded, different information
-- will be shown.
--

help( [[
Description
===========
The EasyBuild-production module configures EasyBuild through environment variables
for installation of software in the system directories. Appropriate rights are required
for a successful install.

The module works together with the software stack modules. Hence it is needed to first
load an appropriate software stack and only then load EasyBuild-production. After changing
the software stack it is needed to re-load this module (if it is not done automatically).

After loading the module, it is possible to simply use the eb command without further
need for aliases.

The module assumes the following environment variables:
  * EBU_SYSTEM_PREFIX: Directory where EasyBuild searches for the system config
    files, system EasyConfig files and puts the repo. The default value is
    /apps/antwerpen/easybuild.
  * EBU_INSTALL_PREFIX: Directory where EasyBuild will put binaries, sources and
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

The following directories and files are used by this module:
  * Directory for EasyConfig files:           ]] .. system_easyconfigdir .. '\n' .. [[
  * Software installation:                    ]] .. system_installpath_software .. '\n' .. [[
  * Module files:                             ]] .. system_installpath_modules .. '\n' .. [[
  * EasyBuild configuration files:            ]] .. system_configdir .. '\n' .. [[
     - Generic config file:                   ]] .. system_configfile_generic .. '\n' .. [[
     - Software stack-specific config file:   ]] .. systen_configfile_stack .. '\n' .. [[
  * Sources of installed packages:            ]] .. system_sourcepath .. '\n' .. [[
  * Repository of installed EasyConfigs       ]] .. system_repositorypath .. '\n' .. [[
  * Builds are performed in:                  ]] .. system_buildpath .. '\n' .. [[
    Don't forget to clean if a build fails!
  * Temporary directory for logs etc.:        ]] .. system_tmpdir .. '\n' .. [[
    Don't forget to clean every now and then!

The following system directories and files are used (if present):
  * Generic config file:                      ]] .. system_configfile_generic .. '\n' .. [[
  * Software stack-specific config file:      ]] .. systen_configfile_stack .. '\n' .. [[

If multiple configuration files are given, they are read in the following order:
  1. System generic configuration file
  2. System stack-specific configuration file
Options that are redefined overwrite the old value. However, environment variables set by
this module do take precedence over the values computed from the configuration files.

To check the actual configuration used by EasyBuild, run ``eb --show-config``. This is
also a good syntax check for the configuration files.

First use for a software stack
==============================
Contrary to the EasyBuild-user module, this module does not itself create the
directory structure as this module is meant to be used from an account with
higher privileges and we want to avoid that any error in the module or loading
of the module in an unexpected configuration would mess up with the system.

The module installation path is added to the MODULEPATH though to ensure that
newly installed modules will be found immediately by EasyBuild.
]] )






