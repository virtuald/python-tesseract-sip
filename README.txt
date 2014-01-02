
python-tesseract-sip
====================

Yet another python library wrapper for Tesseract, this one uses SIP to do the
wrapping. Distributed using the same license as Tesseract. 

Why does this exist?
====================

python-tesseract is GPL licensed, and I needed something with an apache 
license.

Build Requirements
==================

You must have a compiler installed that is supported by python distutils.
Check out LIBS.txt for other dependency details. 

Additionally, SIP must be installed. You can get SIP at:

    http://www.riverbankcomputing.com/software/sip/

Usage
=====
    
There are working examples in the 'examples' folder. They require you to
unpack the tesseract OCR data to a directory called 'tessdata'. 

The python-tesseract wiki has some useful python code samples. Anything
that uses the TessBaseAPI will most likely be compatible with this library.
However, they have a bunch of other functions (which may or may not be 
useful for you) that are not implemented in this wrapper. See the wiki 
on their google code site for similar usage examples. 

    http://code.google.com/p/python-tesseract/
    
Platforms Tested
================

    Windows 7 x64
        - Python 2.7 x86, MSVC 2008 (Tesseract 3.02, Leptonica 1.68)
        - Python 2.7 x64, MSVC 2008 (custom x64 build of Tess/Lept)

Support
=======

If you do find bugs, please send fixes my way, and report them at the github
site for python-tesseract-sip. However, no technical support will be 
provided. Good luck and have fun! 

Dustin Spicuzza
dustin@virtualroadside.com

Get the latest version of this code at 
https://github.com/virtuald/python-tesseract-sip


