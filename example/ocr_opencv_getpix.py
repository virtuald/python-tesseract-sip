
import os
import sys

import cv2
import numpy as np

import tesseract_sip as tesseract


def cv_from_pix(pix):
    '''
        Converts a leptonica Pix object into a numpy array suitable
        for using with OpenCV cv2 API
    '''
    
    # buffer length in pix object is expressed in bytes, so we
    # always use np.uint8 to read it
    
    if pix.d == 1:        
        img = np.frombuffer(pix, np.uint8)
        img.shape = (-1,4)
        img = img[:,[3,2,1,0]]  # byteswap
        
        # this makes a copy
        img = np.unpackbits(img)
        
        # unpackbits gives us 0 and 1, transform to 255 and 0
        img = np.array((255,0), dtype=np.uint8)[img]
        img.shape = (pix.h, pix.w, 1)

        return img
        
    elif pix.d == 8:
        img = np.frombuffer(pix, np.uint8)
        img.shape = (-1,4)
        img = img[:,[3,2,1,0]]  # byteswap
        
        # this makes a copy
        return img.reshape((pix.h, pix.w, 1))
        
    elif pix.d == 32:
        
        img = np.frombuffer(pix, np.uint8)
        img.shape = (pix.h, pix.w, 4)
        return img[:,:,[1, 2, 3, 0]]    # convert to BGRA
        
    raise RuntimeError("Unsupported depth %s" % pix.d)



if __name__ == '__main__':
    
    if not os.path.exists('tessdata'):
        # if you get this error, you need to download tesseract-ocr-3.02.eng.tar.gz 
        # and unpack it in this directory. 
        print >> sys.stderr, 'WARNING: tesseract OCR data directory was not found'
    
    image_file = 'phototest.tif'
    if len(sys.argv) == 2:
        image_file = sys.argv[1]
    
    api = tesseract.TessBaseAPI()
    
    if not api.Init('tessdata', 'eng', tesseract.OEM_DEFAULT):
        print >> sys.stderr, "Error initializing tesseract"
        exit(1)

    api.SetPageSegMode(tesseract.PSM_AUTO)
    
    cvimg = cv2.imread(image_file)
    api.SetImage(cvimg)
    
    #
    # Unpack a Pix using OpenCV/Numpy
    #
    
    timg = api.GetThresholdedImage()
    lpimg = cv_from_pix(timg)
    
    # display it to the user
    cv2.imshow('Tesseract Threshold Image', lpimg)
    cv2.waitKey()
