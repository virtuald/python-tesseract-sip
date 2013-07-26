
import os
import sys

import tesseract_sip as tesseract

if __name__ == '__main__':
    
    if not os.path.exists('tessdata'):
        # if you get this error, you need to download tesseract-ocr-3.02.eng.tar.gz 
        # and unpack it in this directory. 
        print >> sys.stderr, 'WARNING: tesseract OCR data directory was not found'
    
    api = tesseract.TessBaseAPI()
    
    if not api.Init('tessdata', 'eng', tesseract.OEM_DEFAULT):
        print >> sys.stderr, "Error initializing tesseract"
        exit(1)

    api.SetPageSegMode(tesseract.PSM_AUTO)
    api.SetImageFile('phototest.tif')
    
    print api.GetUTF8Text()
    print api.AllWordConfidences()