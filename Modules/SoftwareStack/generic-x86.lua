--
-- Some configuration that is the same for all toolchains
--

local module_prefix = '/apps/antwerpen/modules/'

local procarch  = os.getenv('VSC_ARCH_LOCAL')
local clusteros = os.getenv('VSC_OS_LOCAL')

local archspec_target = procarch
if procarch == rome then
    archspec_target = 'zen2'
end

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

setenv( 'CALCUA_STACK_VERSION',          'default' )
setenv( 'CALCUA_STACK_NAME',             'generic_x86' )
setenv( 'CALCUA_ARCHSPEC_ARCH',          'linux-' .. clusteros .. '-' .. archspec_target )
setenv( 'CALCUA_ARCHSPEC_PLATFORM',      'linux' )
setenv( 'CALCUA_ARCHSPEC_OS',            clusteros )
setenv( 'CALCUA_ARCHSPEC_TARGET_COMPAT', 'x86_64' )
setenv( 'CALCUA_ARCHSPEC_TARGET',        'x86_64' )
setenv( 'VSC_TARGET_LOCAL',              archspec_target )

--
-- Build the MODULEPATH
--

-- Software stack supports EasyBuild
prepend_path('MODULEPATH', '/data/antwerpen/202/vsc20259/EasyBuildDev/EasyBuildLocalMod/Modules/Manual')

-- Generic 64-bit software
prepend_path('MODULEPATH', module_prefix .. 'centos7/software-x86_64')

--- List of deprecated modules
setenv( 'LMOD_ADMIN_FILE', module_prefix .. 'lmod/admin.list' )
