#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

import tesseract_sip as tesseract

if __name__ == '__main__':

    tessdata_prefix = os.environ.get('TESSDATA_PREFIX')
    if not tessdata_prefix:
      tessdata_prefix = 'tessdata'

    if not os.path.exists(tessdata_prefix):
        # if you get this error, you need to download tesseract-ocr-3.02.eng.tar.gz 
        # and unpack it in this directory. 
        print >> sys.stderr, 'WARNING: tesseract OCR data directory was not found'
    
    image_file = 'phototest.tif'
    if len(sys.argv) == 2:
        image_file = sys.argv[1]

    api = tesseract.TessBaseAPI()

    if not api.Init(tessdata_prefix, 'eng', tesseract.OEM_DEFAULT):
        print >> sys.stderr, "Error initializing tesseract"
        exit(1)

    api.SetPageSegMode(tesseract.PSM_AUTO)
    api.SetImageFile(image_file)
    
    text = api.GetUTF8Text()
    # on Windows, the console can't print UTF-8 by default
    try:
        print text
    except UnicodeEncodeError:
        print text.encode(sys.getdefaultencoding(), 'backslashreplace')
    
    print api.AllWordConfidences()
