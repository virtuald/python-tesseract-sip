
What is this?
=============

Yet another python library wrapper for Tesseract, this one uses SIP to do the
wrapping. Distributed using the same license as Tesseract. 

Why does this exist?
====================

python-tesseract is GPL licensed, and I needed something with an apache 
license.

Build Requirements
==================

You must have a compiler installed that is supported by python distutils.

On Windows, you need to 

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
    
Platforms
=========

    Windows 7 x64
        - Python 2.7 x86, MSVC

Support
=======

No support is provided. Good luck and have fun!
