--
-- Some configuration
-- This should also align with the EasyBuild configuration modules
--

-- Default directory for user EasyBuild-installed software
local default_user_prefix = os.getenv( 'VSC_DATA' ) .. '/EasyBuild'
-- Site-specific prefix for the environment variable names that are likely set either in the system profile or user profile.
local ebu =  'EBU'
-- Site-specific location of the modules
local module_prefix = '/apps/antwerpen/modules/'

-- -----------------------------------------------------------------------------
--
-- Generic part of the module file
--

local stack_version = myModuleVersion()
local stack_name =    myModuleName()

--
-- Some configuration that is the same for all stack_versions
--

local procarch  = os.getenv('VSC_ARCH_LOCAL')
local clusteros = os.getenv('VSC_OS_LOCAL')

local archspec_target = procarch
if procarch == 'rome' then
    archspec_target = 'zen2'
end

--
-- Read environment variables that may point to a user EasyBuild installation.
--
local user_prefix = os.getenv( ebu .. '_USER_PREFIX' )
if ( user_prefix    == nil ) then user_prefix    = default_user_prefix    end

local stack    = stack_name .. '-' .. stack_version
local archspec = clusteros .. '-' .. archspec_target
local user_installpath_modules =  pathJoin( user_prefix, 'stacks', stack, archspec, 'usermodules-' .. stack )

--
-- Information about the module (help information, family, etc)
--

local helpstring = string.gsub( [[
Description
===========
This module enables the CalcUA/VERSION software stack which consists mostly out
of software compiled with the intel/VERSION module or a compatible GNU compiler,
and a selection of software packages installed from binaries.

To get the precise versions of the compilers used, load the module and use
module help intel and module help GCC to get the help information on the compiler
modules.

We try to keep a specific version of a software stack working for two years, though
this may not always be possible as underlying changes in the OS may break
compatibility with some applications. Problems have occured in the past and are likely
to occur again (e.g., early versions of GCC 7 and all versions of the 2018 Intel
compilers are not fully compatible with CentOS 8).
]], 'VERSION', stack_version )

help( helpstring )

local whatisstring = string.gsub(
    'Description: Enables the local VERSION software stack and a selection of packages installed from binaries',
    'VERSION', stack_version )
whatis( whatisstring )

family('SoftwareStack')

--
-- Set a number of local non-VSC environment variables used to configure EasyBuild
--

setenv( 'CALCUA_STACK_VERSION',          stack_version )
setenv( 'CALCUA_STACK_NAME',             stack_name )
setenv( 'CALCUA_ARCHSPEC_ARCH',          'linux-' .. clusteros .. '-' .. archspec_target )
setenv( 'CALCUA_ARCHSPEC_PLATFORM',      'linux' )
setenv( 'CALCUA_ARCHSPEC_OS',            clusteros )
setenv( 'CALCUA_ARCHSPEC_TARGET_COMPAT', procarch )
setenv( 'CALCUA_ARCHSPEC_TARGET',        archspec_target )
-- setenv( 'VSC_TARGET_LOCAL',           archspec_target )

--
-- Build the MODULEPATH
--

-- Make EasyBuild-user and EasyBuild-production available
prepend_path( 'MODULEPATH', '/data/antwerpen/202/vsc20259/EasyBuildDev/EasyBuildLocalMod/Modules/Manual' )

-- Generic 64-bit software (usually installed from binaries)
prepend_path( 'MODULEPATH',   pathJoin( module_prefix, clusteros, 'software-x86_64' ) )

-- Modules compiled with the system compiler and not yet part of an official software stack
if not ( stack_version == 'system' ) then
  prepend_path( 'MODULEPATH', pathJoin( module_prefix, clusteros, 'software-' .. procarch, 'system' ) )
end

-- The actual software of the software stack
prepend_path( 'MODULEPATH',   pathJoin( module_prefix, clusteros, 'software-' .. procarch , stack_version ) )

-- Do we have user modules installed? If so, load them.
if isDir( user_installpath_modules ) then prepend_path( 'MODULEPATH', user_installpath_modules ) end

--- List of deprecated modules
setenv( 'LMOD_ADMIN_FILE', pathJoin( module_prefix, 'lmod/admin.list' ) )

