local toolchain =    '2020a'
local intelversion = '2020'
local gccversion =   '9.3.0'

-- -----------------------------------------------------------------------------
--
-- The part below here is generic
--

--
-- Some configuration that is the same for all toolchains
--

local module_prefix = '/apps/antwerpen/modules/'

local procarch  = os.getenv('VSC_ARCH_LOCAL')
local clusteros = os.getenv('VSC_OS_LOCAL')

local archspec_target = procarch
if procarch == 'rome' then
    archspec_target = 'zen2'
end

--
-- Information about the module (help information, family, etc)
--

local helpstring = string.gsub( string.gsub( string.gsub( [[
This module enables all toolchain-independent and TCVER toolchains modules for users.
The TCVER toolchains use the Intel INTELVER compilers and GNU compilers version GCCVER.
]], 'TCVER', toolchain), 'INTELVER', intelversion), 'GCCVER', gccversion)
help( helpstring )

local whatisstring = string.gsub( 'Description: Enables toolchain-independent and TCVER modules', 'TCVER', toolchain )
whatis( whatisstring )

family('SoftwareStack')

--
-- Set a number of local non-VSC environment variables used to configure EasyBuild
--

setenv( 'CALCUA_STACK_VERSION',          toolchain )
setenv( 'CALCUA_STACK_NAME',             'CalcUA' )
setenv( 'CALCUA_ARCHSPEC_ARCH',          'linux-' .. clusteros .. '-' .. archspec_target )
setenv( 'CALCUA_ARCHSPEC_PLATFORM',      'linux' )
setenv( 'CALCUA_ARCHSPEC_OS',            clusteros )
setenv( 'CALCUA_ARCHSPEC_TARGET_COMPAT', procarch )
setenv( 'CALCUA_ARCHSPEC_TARGET',        archspec_target )
setenv( 'VSC_TARGET_LOCAL',              archspec_target )

--
-- Build the MODULEPATH
--

-- Software stack supports EasyBuild
prepend_path('MODULEPATH', '/data/antwerpen/202/vsc20259/EasyBuildDev/EasyBuildLocalMod/Modules/Manual')

-- Generic 64-bit software
prepend_path('MODULEPATH', module_prefix .. clusteros .. '/software-x86_64')

-- Toolchain-independent modules
prepend_path('MODULEPATH', module_prefix .. clusteros .. '/software-' .. procarch .. '/system')

-- toolchain
prepend_path('MODULEPATH', module_prefix .. clusteros .. '/software-' .. procarch .. '/' .. toolchain)

--- List of deprecated modules
setenv( 'LMOD_ADMIN_FILE', module_prefix .. 'lmod/admin.list' )

