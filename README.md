# EasyBuildLocalMod: Modules to configure EasyBuild for production and users at UAntwerpen

This package provides two modules that are variants of one another:
  * EasyBuild-production to do production installs on the system.
  * EasyBuild-user to do an installation in the subdirectories of a user.

## Environment variables assumed present

Both modules assume the presence of a number of variables:
  * CALCUA_STACK_NAME: Not too important in the current setup at UAntwerpen but to
    prepare for a roll-out of EESSI should this ever be encouraged in the VSC, we use
    "CalcUA" for our own software stacks and "EESSI" for the EESSI stack (and may change
    this if they change their name).
  * CALCUA_STACK_VERSION: The version of the stack, which determines the compilers that
    will be used and the directory in which software and modules will be installed.
    If we'd build modules on top of EESSI we'd use the EESSI version number here, whatever
    scheme they may chose for release.
  * CALCUA_ARCHSPEC_OS: The operating system. The suggestion is to use names compatible with
    Spack as both EasyBuild and Spack may rely in the future on the archspec package
    (which currently does not yest abstract at the OS level). This may also make it
    easier to implement a module that would build on top of the EESSI software stack
    should we ever implement that stack on our clusters. When loading the EESSI stack,
    we can set CALCUA_ARCHSPEC_OS to GentooPrefix or to EESSI and in this ways will
    point to separate software install directories and separate module directories.
  * CALCUA_ARCHSPEC_TARGET_COMPAT (EasyBuild-production): The CPU architecture of the
    compute node according to the current conventions used at UAntwerpen (for CalcUA
    modules) or conventions used by archspec/EESSI (for EESSI modules).
  * CALCUA_ARCHSPEC_TARGET (EasyBuild-user): The CPU architecture of the compute node
    as reported by archspec. Using this instead of VSC_ARCH_LOCAL may help to make
    the module compatible with the EESSI software stack in the future.

At UAntwerpen, the above variables are either set in the system /etc/profile.d
directories or through the modules that load a particular version of the software stack.

## Optional environment variables to point to directories

### EasyBuild-production

  * EASYBUILD_SYSTEM_PREFIX: Directory where EasyBuild searches for the system config
    files and puts its repo directory.
    The default value is /apps/antwerpen/easybuild.
  * EASYBUILD_INSTALL_PREFIX: Prefix for the directories where EasyBuild will put
    binaries and modules.

Directories: The structure is a compromise between what EESSI does and what has been
done in the past at UAntwerpen to not make the changes too big.

  * Software packages: ``$EASYBUILD_INSTALL_PREFIX/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET``

    In principle we could have gone for additional levels in the directory structure
    also instead of the current approach. However, the last part of the name is rather
    similar to the Spack archspec so we decided to follow that idea.

    Examples:
      * ``/apps/antwerpen/CalcUA-2020a/centos8-rome``
      * ``/apps/antwerpen/EESSI-2020.12/GentooPrefix-zen2``

  * Modules: ``$EASYBUILD_INSTALL_PREFIX/Modules/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET_COMPAT/system-$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION``

    The basic idea here is not ease of maintenance (such as being able to delete
    a particular software stack with the minimal number of commands) but maximum readability
    for the user. Therefore we make sure that the last component of the directory really
    contains the important information for the user while the other components then
    depend on elements that should be the same for all modules on the system for that
    OS. Yet to keep the structure symmetric with that taken for the binaries and
    repos we do add the level ``$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION`` at the
    start even though that is not strictly needed.

    Examples:
      * ``/apps/antwerpen/Modules/CalcUA-2020a/centos8-rome/system-CalcUA-2020a``
      * ``/apps/antwerpen/Modules/EESSI-2020.12/GentooPrefix-zen2/system-EESSI-2020.12``

    We do use our own naming scheme that omits the ``all`` etc. level as this is not
    very practical. Many modules would belong in multiple classes which is impossible
    to arrange should we not want to force a user to load paths for multiple classes.
    Moreover, the assignement to classes in EasyBuild seems rather arbitrary.

  * System-wide configuration files of EasyBuild: ``$EASYBUILD_SYSTEM_PREFIX/config``

    As EasyBuild does not yet use the archspec database of compiler options for optimization,
    we still need to set ``optarch`` for some architectures (currently at least for
    AMD rome). This however can be embedded in the module file for now until EasyBuild
    would become more clever in setting this up.

    Even though EasyBuild-production does most of the settings in the module file,
    a configuration file may still be useful, e.g., to hide certain modules (as is
    done in the CSCS setup). To be able to evolve the setup, we still use a separate
    configuration file for each par ($CALCUA_STACK_NAME, $CALCUA_STACK_VERSION):
      * ``production.cfg`` with all the common settings for all toolchains.
      * ``production-$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION.cfg``.

  * Sources are stored in $EASYBUILD_INSTALL_PREFIX/sources
    for compatibility with the current setup. They do in general not depend on OS,
    architecture or versions of the software stack so it is not needed to further
    distinguish between them.

  * The repo-directory:
    $EASYBUILD_SYSTEM_PREFIX/repo/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET_COMPAT

    The repo directory is not used by users, and a single level makes it very easy
    to delete parts that are not needed anymore without even having to play around
    with the ``find`` command.

  * The build directory: /dev/shm/$USER


### EasyBuild-user

In addition to the variables needed for EasyBuild-production (which are needed here
too to find the existing installation):
  * EASYBUILD_USER_PREFIX: Place where to install all software. The default is
    $VSC_DATA/EasyBuild

Directories: The directory again takes into account possible future extension to also
support installation on top of EESSI should we ever roll this out on the CalcUA infrastructure.

  * Software packages: ``$EASYBUILD_USER_PREFIX/Software/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET``

    Examples:
      * ``/data/20z/vsc20xyz/EasyBuild/Software/CalcUA-2020a/centos8-zen2``
      * ``/data/20z/vsc20xyz/EasyBuild/Software/EESSI-2020.12/GentooPrefix-zen2``

  * Modules: ``$EASYBUILD_USER_PREFIX/Modules/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/user-$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION``

  * User config file (if needed, by default everything will be done by environment
    variables): $EASYBUILD_USER_PREFIX/config
      * ``user.cfg``
      * ``user-$$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION.cfg``, content overwrites
        the former and all system config files.

  * Sources are stored in ``$EASYBUILD_USER_PREFIX/Sources``

  * The repo-directory is
    ``$EASYBUILD_USER_PREFIX/Repo/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET

  * The build directory: ``/dev/shm/$USER``?

The one problem with this scheme is the use of ``/dev/shm`` as a failed compilation
will leave rubbish there without a user realising it is there and taking away from
the memory of others. However, compiling on a regular filesystem does put a high load
on that filesystem so is not a good option either. And some packages give problems
on ``$VSC_SCRATCH`` as we have seen that occasionaly opening files immediately after
closing causes trouble.

