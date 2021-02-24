# EasyBuildLocalMod: Modules to configure EasyBuild for production and users at UAntwerpen

This package provides two modules that are variants of one another:
  * EasyBuild-production to do production installs on the system.
  * EasyBuild-user to do an installation in the subdirectories of a user.

Both modules assume the presence of a number of variables:
  * CALCUA_BUILDSET: The build set, which determines the compilers that will be used
    and the directory in which software and modules will be installed.
  * VSC_OS_LOCAL (EasyBuild-production) or CALCUA_ARCHSPEC_OS (EasyBuild-user):
    The operating system. The suggestion is to use names compatible with
    Spack as both EasyBuild and Spack may rely in the future on the archspec package
    (which currently does not yest abstract at the OS level). This may also make it
    easier to implement a module that would build on top of the EESSI software stack
    should we ever implement that stack on our clusters.
  * VSC_ARCH_LOCAL (EasyBuild-production): The CPU architecture of the compute node according
    to the current conventions used at UAntwerpen.
  * CALCUA_ARCHSPEC_TARGET (EasyBuild-user): The CPU architecture of the compute node
    as reported by archspec. Using this instead of VSC_ARCH_LOCAL may help to make
    the module compatible with the EESSI software stack in the future.

