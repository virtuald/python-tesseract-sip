#!/usr/bin/env python

#
# Significantly derived from my setup file for pynetworktables... no
# sense reinventing the wheel, right?
#

import os
import os.path
import platform
import sys
from distutils.core import setup, Extension
from distutils.command.install_lib import install_lib

try:
    import sipdistutils
except ImportError:
    sys.stderr.write("ERROR: You must have SIP installed to build this extension\n")
    sys.stderr.write("-> http://www.riverbankcomputing.com/software/sip\n")
    exit(1)
    
    
root = os.path.split(os.path.abspath(__file__))[0]
src_dir = os.path.join(root, 'src')
sip_dir = os.path.join(root, 'sip')
  
class custom_build_ext(sipdistutils.build_ext):

    def finalize_options(self):
        sipdistutils.build_ext.finalize_options(self)
        self.sip_opts += ['-g', '-e', '-I', sip_dir]
        
    def build_extensions(self):
    
        if self.compiler.compiler_type == 'msvc':
            for e in self.extensions:
                e.include_dirs += [os.path.join(src_dir, 'msvc')]
                e.extra_compile_args += ['/DWIN32', '/EHsc']
                
        elif self.compiler.compiler_type == 'mingw32':
            for e in self.extensions:
                e.extra_compile_args += ['-DWIN32']
                
            # see http://bugs.python.org/issue12641
            if 'NO_MINGW_HACK' not in os.environ:
                keys = ['compiler', 'compiler_so', 'compiler_cxx', 'linker_exe', 'linker_so']
                for key in keys:
                    attr = getattr(self.compiler, key)
                    if '-mno-cygwin' in attr:
                        del attr[attr.index('-mno-cygwin')]
        
        sipdistutils.build_ext.build_extensions(self)

source_files = [os.path.join(sip_dir, 'module.sip'),]
if sys.platform == "win32":
  libraries = ['libtesseract302', 'liblept168']
else:
  libraries = ['tesseract', 'lept']
library_dirs = []
include_dirs = [src_dir, sip_dir]
extra_compile_args = None
extra_link_args = None

if sys.platform == "win32":
    libs_dir = os.path.join(root, '..', 'lib')
    include_dir = os.path.join(root, '..', 'include')
    
    library_dirs.append(libs_dir)
    include_dirs.append(include_dir)
    #include_dirs.append(os.path.join(include_dir, 'tesseract'))
    #include_dirs.append(os.path.join(include_dir, 'leptonica'))
    
    # Generate pdb files for debugging on msvc only
    if 'TESS_DEBUG' in os.environ and str(os.environ['TESS_DEBUG']) == "1":
        # TODO: figure out output directory name
        
        major, minor = platform.python_version_tuple()[:2]
        
        pdb_file = os.path.join(os.path.dirname(__file__), "tesseract_sip-%s%s.pdb" % (major, minor))
        extra_link_args = ['/DEBUG', '/PDB:"%s"' % pdb_file]
        extra_compile_args = ['/Zi', '/Od']
    
#else: TODO

class custom_install(install_lib):
    if sys.platform == "win32":
        def install(self):
            # copy the tesseract/leptonica DLL also
            self.copy_file(os.path.join(library_dirs[0], 'libtesseract302.dll'), self.build_dir)
            self.copy_file(os.path.join(library_dirs[0], 'liblept168.dll'), self.build_dir)
            return install_lib.install(self)
    
setup(
    name = 'tesseract_sip',
    version = '0.1.1',
    author = 'Dustin Spicuzza',
    author_email = 'dustin@virtualroadside.com',
    description = 'A SIP-based python wrapper around libtesseract',
    url = 'https://github.com/virtuald/python-tesseract-sip',
    license = 'Apache 2.0',
    ext_modules=[
        Extension("tesseract_sip", source_files,
                  include_dirs=include_dirs,
                  library_dirs=library_dirs,
                  libraries=libraries,
                  extra_compile_args=extra_compile_args,
                  extra_link_args=extra_link_args),
    ],

    cmdclass = {'build_ext': custom_build_ext,
                'install_lib': custom_install }
)
