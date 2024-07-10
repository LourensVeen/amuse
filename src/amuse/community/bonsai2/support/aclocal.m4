# generated automatically by aclocal 1.16.5 -*- Autoconf -*-

# Copyright (C) 1996-2021 Free Software Foundation, Inc.

# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
# ===========================================================================
#      https://www.gnu.org/software/autoconf-archive/ax_count_cpus.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_COUNT_CPUS([ACTION-IF-DETECTED],[ACTION-IF-NOT-DETECTED])
#
# DESCRIPTION
#
#   Attempt to count the number of logical processor cores (including
#   virtual and HT cores) currently available to use on the machine and
#   place detected value in CPU_COUNT variable.
#
#   On successful detection, ACTION-IF-DETECTED is executed if present. If
#   the detection fails, then ACTION-IF-NOT-DETECTED is triggered. The
#   default ACTION-IF-NOT-DETECTED is to set CPU_COUNT to 1.
#
# LICENSE
#
#   Copyright (c) 2014,2016 Karlson2k (Evgeny Grin) <k2k@narod.ru>
#   Copyright (c) 2012 Brian Aker <brian@tangent.org>
#   Copyright (c) 2008 Michael Paul Bailey <jinxidoru@byu.net>
#   Copyright (c) 2008 Christophe Tournayre <turn3r@users.sourceforge.net>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 22

  AC_DEFUN([AX_COUNT_CPUS],[dnl
      AC_REQUIRE([AC_CANONICAL_HOST])dnl
      AC_REQUIRE([AC_PROG_EGREP])dnl
      AC_MSG_CHECKING([the number of available CPUs])
      CPU_COUNT="0"

      # Try generic methods

      # 'getconf' is POSIX utility, but '_NPROCESSORS_ONLN' and
      # 'NPROCESSORS_ONLN' are platform-specific
      command -v getconf >/dev/null 2>&1 && \
        CPU_COUNT=`getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null` || CPU_COUNT="0"
      AS_IF([[test "$CPU_COUNT" -gt "0" 2>/dev/null || ! command -v nproc >/dev/null 2>&1]],[[: # empty]],[dnl
        # 'nproc' is part of GNU Coreutils and is widely available
        CPU_COUNT=`OMP_NUM_THREADS='' nproc 2>/dev/null` || CPU_COUNT=`nproc 2>/dev/null` || CPU_COUNT="0"
      ])dnl

      AS_IF([[test "$CPU_COUNT" -gt "0" 2>/dev/null]],[[: # empty]],[dnl
        # Try platform-specific preferred methods
        AS_CASE([[$host_os]],dnl
          [[*linux*]],[[CPU_COUNT=`lscpu -p 2>/dev/null | $EGREP -e '^@<:@0-9@:>@+,' -c` || CPU_COUNT="0"]],dnl
          [[*darwin*]],[[CPU_COUNT=`sysctl -n hw.logicalcpu 2>/dev/null` || CPU_COUNT="0"]],dnl
          [[freebsd*]],[[command -v sysctl >/dev/null 2>&1 && CPU_COUNT=`sysctl -n kern.smp.cpus 2>/dev/null` || CPU_COUNT="0"]],dnl
          [[netbsd*]], [[command -v sysctl >/dev/null 2>&1 && CPU_COUNT=`sysctl -n hw.ncpuonline 2>/dev/null` || CPU_COUNT="0"]],dnl
          [[solaris*]],[[command -v psrinfo >/dev/null 2>&1 && CPU_COUNT=`psrinfo 2>/dev/null | $EGREP -e '^@<:@0-9@:>@.*on-line' -c 2>/dev/null` || CPU_COUNT="0"]],dnl
          [[mingw*]],[[CPU_COUNT=`ls -qpU1 /proc/registry/HKEY_LOCAL_MACHINE/HARDWARE/DESCRIPTION/System/CentralProcessor/ 2>/dev/null | $EGREP -e '^@<:@0-9@:>@+/' -c` || CPU_COUNT="0"]],dnl
          [[msys*]],[[CPU_COUNT=`ls -qpU1 /proc/registry/HKEY_LOCAL_MACHINE/HARDWARE/DESCRIPTION/System/CentralProcessor/ 2>/dev/null | $EGREP -e '^@<:@0-9@:>@+/' -c` || CPU_COUNT="0"]],dnl
          [[cygwin*]],[[CPU_COUNT=`ls -qpU1 /proc/registry/HKEY_LOCAL_MACHINE/HARDWARE/DESCRIPTION/System/CentralProcessor/ 2>/dev/null | $EGREP -e '^@<:@0-9@:>@+/' -c` || CPU_COUNT="0"]]dnl
        )dnl
      ])dnl

      AS_IF([[test "$CPU_COUNT" -gt "0" 2>/dev/null || ! command -v sysctl >/dev/null 2>&1]],[[: # empty]],[dnl
        # Try less preferred generic method
        # 'hw.ncpu' exist on many platforms, but not on GNU/Linux
        CPU_COUNT=`sysctl -n hw.ncpu 2>/dev/null` || CPU_COUNT="0"
      ])dnl

      AS_IF([[test "$CPU_COUNT" -gt "0" 2>/dev/null]],[[: # empty]],[dnl
      # Try platform-specific fallback methods
      # They can be less accurate and slower then preferred methods
        AS_CASE([[$host_os]],dnl
          [[*linux*]],[[CPU_COUNT=`$EGREP -e '^processor' -c /proc/cpuinfo 2>/dev/null` || CPU_COUNT="0"]],dnl
          [[*darwin*]],[[CPU_COUNT=`system_profiler SPHardwareDataType 2>/dev/null | $EGREP -i -e 'number of cores:'|cut -d : -f 2 -s|tr -d ' '` || CPU_COUNT="0"]],dnl
          [[freebsd*]],[[CPU_COUNT=`dmesg 2>/dev/null| $EGREP -e '^cpu@<:@0-9@:>@+: '|sort -u|$EGREP -e '^' -c` || CPU_COUNT="0"]],dnl
          [[netbsd*]], [[CPU_COUNT=`command -v cpuctl >/dev/null 2>&1 && cpuctl list 2>/dev/null| $EGREP -e '^@<:@0-9@:>@+ .* online ' -c` || \
                           CPU_COUNT=`dmesg 2>/dev/null| $EGREP -e '^cpu@<:@0-9@:>@+ at'|sort -u|$EGREP -e '^' -c` || CPU_COUNT="0"]],dnl
          [[solaris*]],[[command -v kstat >/dev/null 2>&1 && CPU_COUNT=`kstat -m cpu_info -s state -p 2>/dev/null | $EGREP -c -e 'on-line'` || \
                           CPU_COUNT=`kstat -m cpu_info 2>/dev/null | $EGREP -c -e 'module: cpu_info'` || CPU_COUNT="0"]],dnl
          [[mingw*]],[AS_IF([[CPU_COUNT=`reg query 'HKLM\\Hardware\\Description\\System\\CentralProcessor' 2>/dev/null | $EGREP -e '\\\\@<:@0-9@:>@+$' -c`]],dnl
                        [[: # empty]],[[test "$NUMBER_OF_PROCESSORS" -gt "0" 2>/dev/null && CPU_COUNT="$NUMBER_OF_PROCESSORS"]])],dnl
          [[msys*]],[[test "$NUMBER_OF_PROCESSORS" -gt "0" 2>/dev/null && CPU_COUNT="$NUMBER_OF_PROCESSORS"]],dnl
          [[cygwin*]],[[test "$NUMBER_OF_PROCESSORS" -gt "0" 2>/dev/null && CPU_COUNT="$NUMBER_OF_PROCESSORS"]]dnl
        )dnl
      ])dnl

      AS_IF([[test "x$CPU_COUNT" != "x0" && test "$CPU_COUNT" -gt 0 2>/dev/null]],[dnl
          AC_MSG_RESULT([[$CPU_COUNT]])
          m4_ifvaln([$1],[$1],)dnl
        ],[dnl
          m4_ifval([$2],[dnl
            AS_UNSET([[CPU_COUNT]])
            AC_MSG_RESULT([[unable to detect]])
            $2
          ], [dnl
            CPU_COUNT="1"
            AC_MSG_RESULT([[unable to detect (assuming 1)]])
          ])dnl
        ])dnl
      ])dnl

# ===========================================================================
#        https://www.gnu.org/software/autoconf-archive/ax_openmp.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_OPENMP([ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]])
#
# DESCRIPTION
#
#   This macro tries to find out how to compile programs that use OpenMP a
#   standard API and set of compiler directives for parallel programming
#   (see http://www-unix.mcs/)
#
#   On success, it sets the OPENMP_CFLAGS/OPENMP_CXXFLAGS/OPENMP_F77FLAGS
#   output variable to the flag (e.g. -omp) used both to compile *and* link
#   OpenMP programs in the current language.
#
#   NOTE: You are assumed to not only compile your program with these flags,
#   but also link it with them as well.
#
#   If you want to compile everything with OpenMP, you should set:
#
#     CFLAGS="$CFLAGS $OPENMP_CFLAGS"
#     #OR#  CXXFLAGS="$CXXFLAGS $OPENMP_CXXFLAGS"
#     #OR#  FFLAGS="$FFLAGS $OPENMP_FFLAGS"
#
#   (depending on the selected language).
#
#   The user can override the default choice by setting the corresponding
#   environment variable (e.g. OPENMP_CFLAGS).
#
#   ACTION-IF-FOUND is a list of shell commands to run if an OpenMP flag is
#   found, and ACTION-IF-NOT-FOUND is a list of commands to run it if it is
#   not found. If ACTION-IF-FOUND is not specified, the default action will
#   define HAVE_OPENMP.
#
# LICENSE
#
#   Copyright (c) 2008 Steven G. Johnson <stevenj@alum.mit.edu>
#   Copyright (c) 2015 John W. Peterson <jwpeterson@gmail.com>
#   Copyright (c) 2016 Nick R. Papior <nickpapior@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 13

AC_DEFUN([AX_OPENMP], [
AC_PREREQ([2.69]) dnl for _AC_LANG_PREFIX

AC_CACHE_CHECK([for OpenMP flag of _AC_LANG compiler], ax_cv_[]_AC_LANG_ABBREV[]_openmp, [save[]_AC_LANG_PREFIX[]FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
ax_cv_[]_AC_LANG_ABBREV[]_openmp=unknown
# Flags to try:  -fopenmp (gcc), -mp (SGI & PGI),
#                -qopenmp (icc>=15), -openmp (icc),
#                -xopenmp (Sun), -omp (Tru64),
#                -qsmp=omp (AIX),
#                none
ax_openmp_flags="-fopenmp -openmp -qopenmp -mp -xopenmp -omp -qsmp=omp none"
if test "x$OPENMP_[]_AC_LANG_PREFIX[]FLAGS" != x; then
  ax_openmp_flags="$OPENMP_[]_AC_LANG_PREFIX[]FLAGS $ax_openmp_flags"
fi
for ax_openmp_flag in $ax_openmp_flags; do
  case $ax_openmp_flag in
    none) []_AC_LANG_PREFIX[]FLAGS=$save[]_AC_LANG_PREFIX[] ;;
    *) []_AC_LANG_PREFIX[]FLAGS="$save[]_AC_LANG_PREFIX[]FLAGS $ax_openmp_flag" ;;
  esac
  AC_LINK_IFELSE([AC_LANG_SOURCE([[
@%:@include <omp.h>

static void
parallel_fill(int * data, int n)
{
  int i;
@%:@pragma omp parallel for
  for (i = 0; i < n; ++i)
    data[i] = i;
}

int
main()
{
  int arr[100000];
  omp_set_num_threads(2);
  parallel_fill(arr, 100000);
  return 0;
}
]])],[ax_cv_[]_AC_LANG_ABBREV[]_openmp=$ax_openmp_flag; break],[])
done
[]_AC_LANG_PREFIX[]FLAGS=$save[]_AC_LANG_PREFIX[]FLAGS
])
if test "x$ax_cv_[]_AC_LANG_ABBREV[]_openmp" = "xunknown"; then
  m4_default([$2],:)
else
  if test "x$ax_cv_[]_AC_LANG_ABBREV[]_openmp" != "xnone"; then
    OPENMP_[]_AC_LANG_PREFIX[]FLAGS=$ax_cv_[]_AC_LANG_ABBREV[]_openmp
  fi
  m4_default([$1], [AC_DEFINE(HAVE_OPENMP,1,[Define if OpenMP is enabled])])
fi
])dnl AX_OPENMP

m4_include([shared/m4/amuse_download.m4])
m4_include([shared/m4/amuse_lib.m4])
m4_include([shared/m4/amuse_venv.m4])
m4_include([shared/m4/ax_mpi.m4])
m4_include([shared/m4/cuda.m4])
m4_include([shared/m4/pkg.m4])
