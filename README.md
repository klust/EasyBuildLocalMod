# EasyBuildLocalMod: Modules to configure EasyBuild for production and users at UAntwerpen

This package provides two modules that are variants of one another:
  * EasyBuild-production to do production installs on the system.
  * EasyBuild-user to do an installation in the subdirectories of a user.

## Environment variables assumed present

Both modules assume the presence of a number of variables:
  * CALCUA_STACK_NAME: Not too important in the current setup at UAntwerpen but to
    prepare for a roll-out of EESSI should this ever be encouraged in the VSC, we use
    "calcua" for our own software stacks and "EESSI" for the EESSI stack (and may change
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
    compute node according to the current conventions used at UAntwerpen (for calcua
    modules) or conventions used by archspec/EESSI (for EESSI modules).
  * CALCUA_ARCHSPEC_TARGET (EasyBuild-user): The CPU architecture of the compute node
    as reported by archspec. Using this instead of VSC_ARCH_LOCAL may help to make
    the module compatible with the EESSI software stack in the future.

At UAntwerpen, the above variables are either set in the system /etc/profile.d
directories or through the modules that load a particular version of the software stack.

## Optional environment variables to point to directories

### EasyBuild-production UAntwerpen version

  * EBU_SYSTEM_PREFIX: Directory where EasyBuild searches for the system config
    files and puts its repo directory.
    The default value is /apps/antwerpen/easybuild.
  * EBU_INSTALL_PREFIX: Prefix for the directories where EasyBuild will put
    binaries and modules.

### EasyBuild-user

In addition to the variables needed for EasyBuild-production (which are needed here
too to find the existing installation):
  * EBU_USER_PREFIX: Place where to install all software. The default is
    $VSC_DATA/EasyBuild


## EasyBuild configuration: Directory structure

*The current implementation is based on version 1 for the central system setup to
be able to roll out the modules with minimal changes to the existing software
installation.*

### EasyBuild-production UAntwerpen version

Directories: This text uses two directory structures:
 1. The current structure in use at UAntwerpen, which is not ideal and needs an
    additional dummy software stack module to enable installing software in what
    was called the ``system`` toolchain.
 2. A new structure which is a compromise between what EESSI does and what has been
    done in the past at UAntwerpen to not make the changes too big. The one major
    change is to no longer install all software for a given system in the same directory,
    but split it up according to the software stacks, and at the same time also
    almost completely eliminate what we used to call the ``system`` toolchain.
    We may not be able to eliminate it completely as we have a few packages we
    install from binaries that are not multi-architecture but separate optimized
    packages for various architectures:
      a. Gaussian
      b. NAMD: Due to compilation issues we install this from downloaded binaries
         but since the version is replaced rather often it is currently installed
         in a calcua/20xxx software stack.
    All other software that is currently installed in the system toolchain is so
    small in size that we can as well install it in each relevant calcua/20xxx
    toolchain and at the same time avoid confusion for the user, as some of that
    software is really meant to be used with a particular version of the software
    stack and not with the others.

    *Our suggestion is also to avoid installing software in there that is a
    dependency for software in one of the calcua/20xxx software stacks.*
 3. A very much cleaned-up structure using only $EBU_SYSTEM_PREFIX and with naming
    of directories more aligned with EasyBuild.


#### Version 1 paths for software and modules

Current directories
  * calcua/2020a
      * on AMD Rome CPUs:
          * Binaries: ``/apps/antwerpen/rome/centos8`` or with a symlink ``/apps/antwerpen/zen2/centos8``.
          * Modules: ``/apps/antwerpen/modules/centos8/software-rome/2020a``
          * Repo: ``/apps/antwerpen/easybuild/repo/rome-centos8/2020a``
      * on Intel broadwell CPUs:
          * Binaries: ``/apps/antwerpen/broadwell/centos7``
          * Modules: ``/apps/antwerpen/modules/centos7/software-broadwell/2020a''
          * Repo: ``/apps/antwerpen/easybuild/repo/broadwell-centos7/2020a``
  * calcua/system: Dummy module to compile with the system compilers in the former
    system toolchain:
      * on AMD Rome CPUs:
          * Binaries: ``/apps/antwerpen/rome/centos8`` or with a symlink ``/apps/antwerpen/zen2/centos8``.
          * Modules: ``/apps/antwerpen/modules/centos8/software-rome/system``
          * Repo: ``/apps/antwerpen/easybuild/repo/rome-centos8/system``
      * on Intel broadwell CPUs:
          * Binaries: ``/apps/antwerpen/broadwell/centos7``
          * Modules: ``/apps/antwerpen/modules/centos7/software-broadwell/system''
          * Repo: ``/apps/antwerpen/easybuild/repo/broadwell-centos7/system``
  * generic-x86:
      * on AMD Rome CPUs:
          * Binaries: ``/apps/antwerpen/x86_64/centos8``
          * Modules: ``/apps/antwerpen/modules/centos8/software-x86``
          * Repo: ``/apps/antwerpen/easybuild/repo/x86_64-centos8``
      * on Intel broadwell CPUs:
          * Binaries: ``/apps/antwerpen/x86_64/centos7``
          * Modules: ``/apps/antwerpen/modules/centos7/software-x86''
          * Repo: ``/apps/antwerpen/easybuild/repo/x86_64-centos8``

The structures for ``calcua/2020a`` and ``calcua/system`` follow the same pattern,
but this is not the case for the generic x86_64 software as the directories there
have one level less. Moreover, there is no consistent use of x86_64: sometimes simply
x86 is used.

One idea to make the directory structure more uniform is
  * To use an empty version for the generic-x86 module and see if we can get this to
    work with pathJoin to simply omit the last element of the path, i.e.,
    CALCUA_STACK_VERSION is set but set to an empty string (if this works).
    A possible alternative is to set the version to, e.g., ``default``, and catch
    that in the EasyBuild-production module.
  * And renaming/symlinking ``software-x86` to ``software-x86_64`` and
    set CALCUA_ARCHSPEC_TARGET and CALCUA_ARCHSPEC_TARGET_COMPAT to ``x86_64``.

Directories to set in the EasyBuild-production module:

  * Software packages:
    ``$EBU_INSTALL_PREFIX/$CALCUA_ARCHSPEC_TARGET_COMPAT/$CALCUA_ARCHSPEC_OS``
    though with some symbolic linking we could safely change that to
    ``$EBU_INSTALL_PREFIX/$CALCUA_ARCHSPEC_TARGET/$CALCUA_ARCHSPEC_OS``
    which would align us a little bit more with what's happening in Gent and likely
    on the Tier-1c system.

  * Modules:
    ``$EBU_INSTALL_PREFIX/modules/$CALCUA_ARCHSPEC_OS/software-$CALCUA_ARCHSPEC_TARGET_COMPAT/$CALCUA_STACK_VERSION``
    where we could again replace ``CALCUA_ARCHSPEC_TARGET_COMPAT`` by ``CALCUA_ARCHSPEC_TARGET``
    with some symbolic linking.

  * Repository of installed easyconfigs:
    ``$EBU_SYSTEM_PREFIX/repo/$CALCUA_ARCHSPEC_TARGET_COMPAT-$CALCUA_ARCHSPEC_OS``
    though weith some symbolic linking we couls safely change that to
    ``$EBU_SYSTEM_PREFIX/repo/$CALCUA_ARCHSPEC_TARGET-$CALCUA_ARCHSPEC_OS``.

There are other directories common to all three variants that are given below.


#### Version 2 paths for software and modules

  * Software packages:
    ``$EBU_INSTALL_PREFIX/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET``
    where ``-$CALCUA_STACK_VERSION`` is omitted if ``$CALCUA_STACK_VERSION`` is empty.

    In principle we could have gone for additional levels in the directory structure
    also instead of the current approach. However, the last part of the name is rather
    similar to the Spack archspec so we decided to follow that idea.

    Examples:
      * ``calcua/2020a``:  ``/apps/antwerpen/calcua-2020a/centos8-rome``
      * ``generic-x86``:   ``/apps/antwerpen/generic-x86/centos8-x86_64``
      * ``EESSI/2020.12``: ``/apps/antwerpen/EESSI-2020.12/GentooPrefix-zen2``

  * Modules:
    ``$EBU_INSTALL_PREFIX/modules/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET_COMPAT/system-$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION``
    where ``-$CALCUA_STACK_VERSION`` is omitted if ``$CALCUA_STACK_VERSION`` is empty.

    The basic idea here is not ease of maintenance (such as being able to delete
    a particular software stack with the minimal number of commands) but maximum readability
    for the user. Therefore we make sure that the last component of the directory really
    contains the important information for the user while the other components then
    depend on elements that should be the same for all modules on the system for that
    OS. Yet to keep the structure symmetric with that taken for the binaries and
    repos we do add the level ``$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION`` at the
    start even though that is not strictly needed.

    Examples:
      * ``calcua/2020a``:  ``/apps/antwerpen/modules/calcua-2020a/centos8-rome/systemmodules-calcua-2020a``
      * ``generic-x86``:   ``/apps/antwerpen/modules/generic-x86/centos8-x86_64-systemmodules-generix-x86``
      * ``EESSI/2020.12``: ``/apps/antwerpen/modules/EESSI-2020.12/GentooPrefix-zen2/systemmodules-EESSI-2020.12``

    We do use our own naming scheme that omits the ``all`` etc. level as this is not
    very practical. Many modules would belong in multiple classes which is impossible
    to arrange should we not want to force a user to load paths for multiple classes.
    Moreover, the assignement to classes in EasyBuild seems rather arbitrary.

  * The repo-directory:
    $EBU_SYSTEM_PREFIX/ebfiles_repo/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$CALCUA_ARCHSPEC_TARGET_COMPAT
    where ``-$CALCUA_STACK_VERSION`` is omitted if ``$CALCUA_STACK_VERSION`` is empty.

    Compared to the present situation:
      * ``repo`` is renamed to ``ebfiles_repo`` to align with the default name used
        by EasyBuild.
      * The internal structure is changed to now also include the name of the software
        stack (usefull if we would start building on top of EESSI also) and to align
        with the directory structure proposed for the software installations.

    Examples:
      * ``calcua/2020a``:  ``/apps/antwerpen/easybuild/ebfiles_repo/calcua-2020a/centos8-rome``
      * ``generic-x86``:   ``/apps/antwerpen/easybuild/ebfiles_repo/generic-x86/centos8-x86_64``
      * ``EESSI/2020.12``: ``/apps/antwerpen/easybuild/ebfiles_repo//EESSI-2020.12/GentooPrefix-zen2/systemmodules-EESSI-2020.12``


#### Version 3 paths for software and modules

The directory structure here mirrors directly the directory structure for user installs.

  * Software packages:
    ``$EBU_INSTALL_PREFIX/stacks/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/software``

    For unversioned software stacks ``-$CALCUA_STACK_VERSION`` is omitted.

    Examples:
      * ``calcua/2020a``:  ``/apps/antwerpen/stacks/calcua-2020a/centos8-zen2/software``
      * ``generic-x86``:   ``/apps/antwerpen/stacks/generic-x86/centos8-x86_64/software``
      * ``EESSI/2020.12``: ``/apps/antwerpen/stacks/EESSI-2020.12/GentooPrefix-zen2/software``

  * Modules:
    ``$EBU_INSTALL_PREFIX/stacks/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/usermodules-$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION``

    For unversioned software stacks ``-$CALCUA_STACK_VERSION`` is omitted.

    Examples:
      * ``calcua/2020a``:  ``/apps/antwerpen/stacks/calcua-2020a/centos8-zen2/usermodules-calcua-2020``
      * ``generic-x86``:   ``/apps/antwerpen/stacks/generic-x86/centos8-x86_64/usermodules-generic-x86``
      * ``EESSI/2020.12``: ``/apps/antwerpen/stacks/EESSI-2020.12/GentooPrefix-zen2/usermodules-EESSI-2020.12``

  * The repo-directory is
    ``$EBU_INSTALL_PREFIX/stacks/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/ebfiles_repo``

    For unversioned software stacks ``-$CALCUA_STACK_VERSION`` is omitted.

    Even though EasyBuild doesn't use ``EASYBUILD_INSTALLPATH`` to put it
    where the binaries and module files are put, we decided to keep the
    repository with the modules and binaries as it also reflects which packages
    are installed and as it also simplifies maintenance to ensure that the repo
    entry for a package is deleted when the module file and binaries are deleted.

    Examples:
      * ``calcua/2020a``:  ``/data/20z/vsc20xyz/EasyBuild/stacks/calcua-2020a/centos8-zen2/ebfiles_repo``
      * ``generic-x86``:   ``/data/20z/vsc20xyz/EasyBuild/stacks/generic-x86/centos8-x86_64/ebfiles_repo``
      * ``EESSI/2020.12``: ``/data/20z/vsc20xyz/EasyBuild/stacks/EESSI-2020.12/GentooPrefix-zen2/ebfiles_repo``


#### Common to all three proposals

  * System-wide configuration files of EasyBuild: ``$EBU_SYSTEM_PREFIX/config``

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

  * Sources are stored in $EBU_INSTALL_PREFIX/sources
    for compatibility with the current setup. They do in general not depend on OS,
    architecture or versions of the software stack so it is not needed to further
    distinguish between them.

  * The build directory: /dev/shm/$USER

  * The local EasyConfig files are currently at
    ``$EBU_SYSTEM_PREFIX/github/UAntwerpen-easyconfigs``.


### EasyBuild-user

Directories: The directory again takes into account possible future extension to also
support installation on top of EESSI should we ever roll this out on the calcua infrastructure.
Moreover, unlike the production version of the module, we do try to follow EasyBuild
naming a bit more to make the installation more recognizable, but we do add the concept
of software stacks for various machines.

  * Directories specific to a software stack:

      * Software packages:
        ``$EBU_USER_PREFIX/stacks/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/software``

        For unversioned software stacks ``-$CALCUA_STACK_VERSION`` is omitted.

        Examples:
          * ``calcua/2020a``:  ``/data/20z/vsc20xyz/EasyBuild/stacks/calcua-2020a/centos8-zen2/software``
          * ``generic-x86``:   ``/data/20z/vsc20xyz/EasyBuild/stacks/generic-x86/centos8-x86_64/software``
          * ``EESSI/2020.12``: ``/data/20z/vsc20xyz/EasyBuild/stacks/EESSI-2020.12/GentooPrefix-zen2/software``

      * Modules:
        ``$EBU_USER_PREFIX/stacks/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/usermodules-$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION``

        For unversioned software stacks ``-$CALCUA_STACK_VERSION`` is omitted.

        Examples:
          * ``calcua/2020a``:  ``/data/20z/vsc20xyz/EasyBuild/stacks/calcua-2020a/centos8-zen2/usermodules-calcua-2020``
          * ``generic-x86``:   ``/data/20z/vsc20xyz/EasyBuild/stacks/generic-x86/centos8-x86_64/usermodules-generic-x86``
          * ``EESSI/2020.12``: ``/data/20z/vsc20xyz/EasyBuild/stacks/EESSI-2020.12/GentooPrefix-zen2/usermodules-EESSI-2020.12``

      * The repo-directory is
        ``$EBU_USER_PREFIX/stacks/$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION/$CALCUA_ARCHSPEC_OS-$VALCUA_ARCHSPEC_TARGET/ebfiles_repo``

        Even though EasyBuild doesn't use ``EASYBUILD_INSTALLPATH`` to put it
        where the binaries and module files are put, we decided to keep the
        repository with the modules and binaries as it also reflects which packages
        are installed and as it also simplifies maintenance to ensure that the repo
        entry for a package is deleted when the module file and binaries are deleted.

        For unversioned software stacks ``-$CALCUA_STACK_VERSION`` is omitted.

        Examples:
          * ``calcua/2020a``:  ``/data/20z/vsc20xyz/EasyBuild/stacks/calcua-2020a/centos8-zen2/ebfiles_repo``
          * ``generic-x86``:   ``/data/20z/vsc20xyz/EasyBuild/stacks/generic-x86/centos8-x86_64/ebfiles_repo``
          * ``EESSI/2020.12``: ``/data/20z/vsc20xyz/EasyBuild/stacks/EESSI-2020.12/GentooPrefix-zen2/ebfiles_repo``

  * Directories common for all software stacks

      * User config file (if needed, by default everything will be done by environment
        variables): $EBU_USER_PREFIX/config
          * ``user.cfg``
          * ``user-$$CALCUA_STACK_NAME-$CALCUA_STACK_VERSION.cfg``, content overwrites
            the former and all system config files.

      * Sources are stored in ``$EBU_USER_PREFIX/Sources``

      * The build directory: ``$XDG_RUNTIME_DIR/easybuild`` which is smaller than ''/dev/shm''
        but has the advantage that it is cleared automatically when the last session of
        a user ends, so we avoid uncareful users clogging up the temporary file system
        in RAM memory.


## EasyBuild configuration: Other settings

### robot-path

There are two options here:
  * Either we put the ``ebfies_repo``-directories in the front of the path to ensure
    that EasyBuild will pick the EasyConfig files that are actually installed on the
    system whenever it encounters already installed software in the list of dependencies
    and hence make the right decisions about further dependencies.
    This implies that we need to build up that list in the module files if we want
    to avoid separate configuration files for each software stack.
  * Or we don't include the ``ebfiles_repo`` in the search path. However, besides the
    UAntwerpen central repository we would probably also need to include the user
    easyconfig directory which means that we would still have to build the path in
    the module file (at least for the user side) as we don't want to auto-generate
    configfiles.

*Note that we do not add the EasyBuild defaults to `ÈASYBUILD_ROBOTPATH``.* The reason
is that some software is installed differently at UAntwerpen: Sometimes several separate
packages in the default EasyBuilders repository are bundled in a single bundle, and
our list of Python and R-pcakges installed in the main Python- and R modules is also
different. This means that we do need to check dependencies and should not automatically
pick up dependencies from the default repository as in that way we may pull in a lot
of already installed software. Also, sometimes we install packages before there is
official EasyBuild support so we may have chosen a different name for those packages
or a different choices of versions for dependencies.

Issues that complicate things: We do consider ``generic-x86``, ``calcua/system`` and
the various ``calua/20xxx`` stacks as separate software stacks but do no completely
separate them as we do make software that actually belongs to ``generic-x86`` also
available in ``calcua/system`` and software from both ``generic-x86`` and ``calcua/system``
in the various ``calcua/20xxx`` stacks. This does complicate the construction of
the ``EASYBUILD_ROBOTPATH``.

*Note: We currently do not support this for the user-installed software to not
make our module files more complicated than needed. At the user level, we consider
the software stacks to be completely separated for now.*


### Architecture-specific optimisations

The default EasyBuild settings are used, except for the generic-x86 software stack
and AMD Rome systems. For these we set separate options through the
``EASYBUILD_OPTARCH`` environment variable.



