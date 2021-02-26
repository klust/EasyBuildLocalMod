whatis( 'Prepares EasyBuild for production installation in the system directories. Appropirate rights required.' )

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
local default_install_prefix = '/apps/antwerpen'
local site = 'CALCUA' -- Site-specific first part of the variable names.

local system_prefix =  os.getenv( 'EASYBUILD_SYSTEM_PREFIX' )
local install_prefix = os.getenv( 'EASYBUILD_INSTALL_PREFIX')

local stack_name =      os.getenv( site .. '_STACK_NAME' )
local stack_version =   os.getenv( site .. '_STACK_VERSION' )
local archspec_os =     os.getenv( site .. '_ARCHSPEC_OS' )
local archspec_target = os.getenv( site .. '_ARCHSPEC_TARGET' )
