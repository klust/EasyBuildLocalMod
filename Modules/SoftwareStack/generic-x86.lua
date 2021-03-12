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

local stack_version = ''
local stack_name =    myModuleName()

--
-- Some configuration that is the same for all toolchains
--

local procarch  = os.getenv('VSC_ARCH_LOCAL')
local clusteros = os.getenv('VSC_OS_LOCAL')

local archspec_target_vsc = procarch
if procarch == rome then
    archspec_target_vsc = 'zen2'
end
local archspec_target = 'x86_64'

--
-- Read environment variables that may point to a user EasyBuild installation.
--
local user_prefix = os.getenv( ebu .. '_USER_PREFIX' )
if ( user_prefix    == nil ) then user_prefix    = default_user_prefix    end

local stack    = stack_name
local archspec = clusteros .. '-' .. archspec_target
local user_installpath_modules =  pathJoin( user_prefix, 'stacks', stack, archspec, 'usermodules-' .. stack )

--
-- Information about the module (help information, family, etc)
--

help([[
This module enables only the generic Intel 64-bit modules.

This includes software installed from generic binaries for 64-bit x86, and
some packages that only need the system Python/Perl/... or the Java module
which is also included in this set.
]])

whatis('Description: Enables only the generic Intel 64-bit modules')

family('SoftwareStack')

--
-- Set a number of local non-VSC environment variables used to configure EasyBuild
--

setenv( 'CALCUA_STACK_NAME',             'generic-x86' )
setenv( 'CALCUA_STACK_VERSION',          '' )
setenv( 'CALCUA_ARCHSPEC_ARCH',          'linux-' .. clusteros .. '-' .. archspec_target )
setenv( 'CALCUA_ARCHSPEC_PLATFORM',      'linux' )
setenv( 'CALCUA_ARCHSPEC_OS',            clusteros )
setenv( 'CALCUA_ARCHSPEC_TARGET_COMPAT', archspec_target )
setenv( 'CALCUA_ARCHSPEC_TARGET',        archspec_target )
-- setenv( 'VSC_TARGET_LOCAL',           archspec_target_vsc )

--
-- Build the MODULEPATH
--

-- Make EasyBuild-user and EasyBuild-production available
prepend_path('MODULEPATH', '/data/antwerpen/202/vsc20259/EasyBuildDev/EasyBuildLocalMod/Modules/Manual')

-- Generic 64-bit software
prepend_path('MODULEPATH', pathJoin( module_prefix, clusteros, 'software-x86_64' ) )

-- Do we have user modules installed? If so, load them.
if isDir( user_installpath_modules ) then prepend_path( 'MODULEPATH', user_installpath_modules ) end

--- List of deprecated modules
setenv( 'LMOD_ADMIN_FILE', pathJoin( module_prefix, 'lmod/admin.list' ) )
