# The EasyBuild-production and EasyBuild-user modules

The EasyBuild-production and EasyBuild-user modules work together with the software
stack modules to make it possible to install software with EasyBuild in the system
and user directories respectively using just the standard ``eb`` command and a minimal
number of configuration files.

The software stack modules will provide some basic information through environment
variables that is then picked up by the EasyBuild-production and EasyBuild-user modules
to determine in which directories software should be installed and - in some cases
- how the compilers should be configured for correct host-specific optimisation.

The modules are constructed in such a way that it should be easy to write equivalent
modules or to extend the module files to also install software on top of the EESSI
software stack for machines that support that stack when it will be released.

## Software stacks on the CaclUA cluster

On the UAntwerpen clusters the idea of software stacks is not as well developed as
in EESSI or in some other supercomputer centres. Therefore some compromises are made
in the UAntwerp software stack modules. We distinguish the following software stacks:

  * ``generic-x86``: This software stack contains software that should run on all
    sufficiently recent 64-bit x86 systems, and consists mostly of software installed
    from binaries and scripts that run using the OS Perl or Python.
  * ``calcua/system``: This software stack contains software that is optimised for the
    machine that you are on, but is compiled with the default system compilers or
    installed from binaries (e.g., Gaussian). However, we also make all software from
    the ``generic-x86`` software stack available.
  * ``calcua/20xxy``: These are actually the main software stacks for the CalcUA clusters.
    They consist of a collection of software packages that should be compatible with
    each other and are compiled with compilers selected for each package, which is
    typically a mix of the system compilers for software that sit really at the bottom
    of the stack and is needed to install other software, a particular version of GCC
    and a particular version of the Intel compilers.

    Within the stack there can be some divergence, mostly caused by the MPI implementations.
    We try to use Intel MPI as much as possible, though some versions of the ``calcua``
    software stacks also contain packages compiled with Open MPI. Packages compiled
    with Open MPI and Intel MPI cannot be loaded simultaneously. Packages with `intel``
    in their name that use MPI, will be using Intel MPI, while packages with ``foss``
    in their name that use MPI, will be using Open MPI. In principle we could configure
    the module system in such a way that those packages cannot be loaded simultaneously,
    but given that it would complicate working with modules for many users, we have
    chosen not to do so at this point.

    The ``calcua/20xxy`` software stacks also make all software in the ``calcua/system``
    and ``generic-x86`` software stacks available.

Each of the modules will also ensure the corresponding user-installed software is
activated, with one exception:
  * ``generic-x86`` will activate all software a user installed in his or her
    extension of that software stack (while the ``generic-x86`` module was loaded).
  * ``calcua/system`` will activate all software a user installed in his or her
    extension of that software stack (while the ``calcua/system`` module was loaded)
    but *will not*  install the software that the user installed in his or her
    extension of the ``generic-x86`` software stack.

For compatibility reasons, the ``calcua/supported`` module is still available and makes
all software from all software stacks that we consider sufficiently recent, available.
Note however that trying to load modules that belong to different ``calcua/20xxy``
software stacks will often lead to modules being unloaded again, warning messages or
unexpected behaviour. *Note that this module will not work with EasyBuild-production
and EasyBuild-user.*

For compatibility reasons we still provide the old ``hopper``, ``leibniz``, ``vaughan``,
``ivybridge``, ``broadwell`` and ``skylake`` names but we do discourage their use as
we might use them for other purposes in the future. *Note that these will not work
with EasyBuild-production and EasyBuild-user.*

The concept of the ``calcua/20xxy`` modules follows the current concept of the EESSI
prototype (which only uses the GNU compilers and Open MPI). The EESSI prototype also
works with versioned software stacks, consisting of particular versions of the
compilers and software that is sometimes compiled with the compilers from the
compatibility layer (which replaces the OS) and software compiled with a particular
recent version of the GNU compiler collection. In principle it should be possible to
make the EESSI software stack available through modules in the same way as the ``calcua``
software stacks and build on top of those stacks in the same way as we would build
in the system ``calcua`` stack or - as a user - on top of it.

## EasyBuild as provided by EasyBuild-production and EasyBuild-user

The EasyBuild-production and EasyBuild-user modules fully exploit the hierarchy
of configuration files, environment variables and command line flags of EasyBuild
to set the correct configuration of EasyBuild for a particular build. The idea is to
ensure that common settings are specified as much as possible in a common place to
reduce the chance of making mistakes when one of those settings has to change.

The opportunity was also taken to bring a few options more in line with the advise
in the EasyBuild manual in recent versions of EasyBuild. In particular,
  * We now use ``robot-paths`` rather than ``robot`` as advised by the manual.
    (The manual advises to use ``robot`` only on the command line as it can have
    a double effect: setting the search path for missing EasyConfig files and telling
    EasyBuild to look for them and install them.)

    This change implies that now by default EasyBuild will not build the missing
    packages automatically. This behaviour can be re-instated by running ``eb -r``
    or ``eb --robot`` instead, and it is not needed to specify the search path
    with that option as it has already been specified by ``robot-paths``.
  * We do use ``search-paths`` to specify additional EasyConfig repositories from
    which EasyBuild cannot install software directly but can be searched by the two
    search options of the ``eb`` command: ``--search`` which will give the result
    with the fully expanded paths to the EasyConfig file, and ``-S`` which tries
    to condense the paths by using variables for common parts. Therefore we no
    longer need a separate config file with a long ``robot-paths`` just to enable
    EasyBuild search.

Other changes, not initiated by the manual:
  * The default EasyConfig files that come with each version of EasyBuild are no
    longer in the robot search path. They can still be found using ``eb -S`` or
    ``eb --search`` but need to be copied explicitly to the UAntwerpen EasyConfig
    repository before installation. This is done for various reasons:
      * We have repackaged some base libraries in bundles, so dependencies in the
        default packages may need to be changed to those bundles or otherwise lots
        of already software may accidentally be pulled in again.
      * We sometimes start a new toolchain before it has been completely defined
        in EasyBuild, so we may chose different versions of packages as they were
        not yet in the EasyBuild version of the software stack.
      * Our own repository should give a complete overview of all installed software
        and contain the right versions of the EasyConfig files. This makes it a
        lot easier to re-install a software stack or to test if a software stack
        still installs properly after an Operating System or EasyBuild upgrade
        (something that we don't do right now until we really have to reinstall
        software...)
      * We do have a habit of adding additional information to the EasyConfig file
        that lands in the whatis and help blocks of the module file to make those
        files more searchable and to provide additional information to our users.

    In fact, the original idea was that the EasyBuild recipes that come with EasyBuild
    should only serve as an example, and this is still the case if you want to use
    a different toolchain than the two common ``foss`` and ``intel`` toolchains and their
    subtoolchains.

EasyBuild-production and EasyBuild-user use three optional environment variables
to point to the locations of various files in the EasyBuild installation. However,
reasonable defaults are encoded in the module so these variables need not be set.
  * EBU_SYSTEM_PREFIX: Directory where EasyBuild searches for the system config
    files, system EasyConfig files and puts the repo. The default value is
    /apps/antwerpen/easybuild.
  * EBU_INSTALL_PREFIX: Directory where EasyBuild will put binaries, sources and
    modules. The default is /apps/antwerpen.

    We could have done with one variable rather than both, but wanted to make the
    module easier to adapt for those sites that want to use different file systems
    for the EasyBuild configuration and the actuall installation directories of
    software and modules.
  * EBU_USER_PREFIX: Prefix for the EasyBuild user installation. The default
    is $VSC_DATA/EasyBuild.

Both modules provide extensive help information explaining the directory structure.
Moreover, if a compatible software stack is loaded and the optional EBU-variables
are set (if they would be used), the help option of the module command will also
display all software stack-dependent directories that the module will use
(and even some others).

The module works by setting various EASYBUILD_ environment variables whose values
are computed from hidden variables in the software stack module, the EBU_ variables
and reasonable defaults. They augment settings that are specified in up to 4
EasyBuild configuration files:
 1. ``production.cfg`` in the system config directory. This is the one file that
    you may want to have to define a number of site-dependend EasyBuild settings
    such as the module naming scheme, customized EasyBlocks and toolchains, modules
    that should be hidden on the system, etc. The search path can also be defined in
    that file as it is something that typically does not depend on the software stack.

    This file is used by both EasyBuild-production and EasyBuild-user as any user
    installation should build upon the settings used for the system as a whole.
 2. ``user.cfg`` (EasyBuild-user) is as its name implies the equivalent of that
    file but in the user config directory. A user can use that file to overwrite or
    add to system settings.
 3. ``production-<stack>.cfg`` in the system config directory. In this file, it is
    possible to overwrite settings for a specific software stack. ``<stack`` is either
    just the name of the software stack for versionless stacks or
    ``<stack_name>-<stack_version>`` for stacks with version numbers.
 4. ``user-<stack>.cfg``: The equivalent file to the previous one but in the user
    directory.

    Note that both stack-specific files are read after the generic files. Hence it
    is possible that ``production-<stack>.cfg`` overwrites settings in ``user.cfg``.
    However, a user can always overwrite them again via ``user-<stack>.cfg``.

To see the settings that will be used effectively by EasyBuild, simply run
``eb --show-config``.

## Some internals

### Information provided by the software stacks

The software stack modules set environment variables that can tell other modules
which software stack (name and version) is loaded and for which OS and CPU architecture
The latter are not strictly needed on the UAntwerpen system as they are already defined
in VSC_ environment variables, but are still set to make the concept more portable
to other sites and to make it easier to support EESSI also.

For the operating system and CPU architecture, we suggest to use names that are
compatible with the information returned by
[the archspec library and tools](https://github.com/archspec/archspec).
This library is already used internally in Spack and the EasyBuild community also uses
it in the EESSI project. There are also contributions to the code from the EasyBuild
group. It is already used by at least one EasyBlock to set configurations flags
during the configure process.

At UAntwerpen, we did however chose the name "Rome" for the AMD EPYC 7xx2 processors
as we were not yet aware of the ``archspec`` package and as using the code name seemed
reasonable as this was already what was done for Intel CPUs. Archspec however names
the architecture ``zen2``.

For now, we deal with this by setting two names for the architecture: one compatible
with archspec and one as in use at UAntwerpen. When doing user installations we
currently use the CPU architecture names as used by ``archspec`` as they are also
used in EESSI and may be less confusing for the user in the future. However, to not
have to redo our current software installation for our AMD system (which is far from
trivial as it is to be expected that OS updates may already break some software
installations that worked in the past) we use ``rome`` for the AMD EPYC 7xx2
processors on the system. *NOTE: We may decide to revise this and keep the current
installation working with some clever play with symbolic links. However, changing
the value of ``VSC_ARCH_LOCAL`` may cause problems in job scripts so is not something
that we should do lightly even if vaughan is still in pilot.*

The list of variables provided by the software stacks at UAntwerpen and expected
by EasyBuild-production and EasyBuild-user are:
  * CALCUA_STACK_NAME: The name of the software stack (``calcua`` or ``generic-x86``
    on the CalcUA systems)
  * CALCUA_STACK_VERSION: The version of the software stack. This should be an empty
    string for versionless software stacks.
  * CALCUA_ARCHSPEC_OS: The name of the OS, preferably something that is compatible
    with archspec (``centos7`` or ``centos8`` on the CalcUA systems)
  * CALCUA_ARCHSPEC_TARGET: The name of the CPU architecture as used by archspec.
    At CalcUA this can be ``ivybridge``, ``broadwell`` or ``zen2``, and we still need
    to check for Skylake (likely ``skylake_avx512``).
  * CALCUA_ARCHSPEC_TARGET_COMPAT: The name that is currently used for the CPU architecture
    at UAntwerp[en, currently ``rome`` instead of ``zen2`` and we may need it for
    the Skylake machine also.

Users should not manually (re)set these variables unless they really now how it may
influence loading and unloading of modules!

Additional variables for future use:
  * CALCUA__ARCHSPEC_PLATFORM: The platform as defined by archspec. This is
    ``linux`` for all CalcUA systems but would be different on a Cray system.
  * CALCUA_ARCHSPEC_ARCH: The arch string as would be used by Spack.
    This consists of platform, OS and target separated by dashes.

These environment variables may be useful for power users who want to experiment with
Spack.


### Directory setup for EasyBuild-production


### Directory setup for EasyBuild-user



### The EasyBuild-production and EasyBuild-user modules

Both modules set a number of EASYBUILD_ environment variables that set (or would
overwrite settings in the config files) a number of software stack dependent and
independent settings of EasyBuild.

Variables that do not depend on the software stack are:
  * EASYBUILD_PREFIX: Will be set to either EBU_SYSTEM_PREFIX or EBU_USER_PREFIX
    depending on the module and ensure that all directories that EasyBuild would
    create and are not covered by the modules or config files end up in
    subdirectories of that prefix.
  * EASYBUILD_SOURCEPATH: Directory where the sources for installed packages will
    be stored. This directory is of course different for the -production and
    -user versions as a user cannot write in the system directories.
  * EASYBUILD_BUILDPATH: For performance reasons, we build on RAM-based file
    systems.
      * For EasyBuild-production, we currently use ``/dev/shm/$USER`` as this
        module will only be used by sysadmins who we trust to clean up their
        mess after a failed build.
      * For EasyBuild-user we prefer to use ``$XDG_RUNTIME_DIR/easybuild`` if
        that environment variable exists as this directory is automatically
        cleaned when a user logs out. If that environment variable does not
        exist, ``/dev/shm/$USER`` is used instead.

Variables that depend on the software stack:
  * EASYBUILD_INSTALLDIR: It is set but currently not really used as we also
    separately set EASYBUILD_INSTALLDIR_SOFTWARE and EASYBUILD_INSTALLDIR_MODULES.
       * For EasyBuild-production it is currently just ``EBU_SYSTEM_INSTALLPATH``
         or its default.
       * For EasyBuild-user it is software stack specific and the highest common
         part of the subdirectories for software and modules.
  * EASYBUILD_INSTALLDIR_SOFTWARE: The installation directory for the software
    packages
  * EASYBUILD_INSTALLDIR_MODULES: The installation directory for the module files


