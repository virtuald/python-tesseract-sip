#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

import cv2
import numpy as np

import tesseract_sip as tesseract


def np_from_pix(pix):
    '''
        Converts a leptonica Pix object into a numpy array suitable
        for using with OpenCV cv2 API
    '''
    
    # buffer length in pix object is expressed in bytes, so we
    # always use np.uint8 to read it
    
    buf = np.frombuffer(pix.get_buffer(), np.uint8)
    buf.shape = pix.get_buffer_shape()
    
    return buf


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

    cvimg = cv2.imread(image_file)
    api.SetImage(cvimg)
    
    #
    # Unpack a Pix using OpenCV/Numpy
    #
    
    timg = api.GetThresholdedImage()
    lpimg = np_from_pix(timg)
    
    # display it to the user
    cv2.imshow('Tesseract Threshold Image', lpimg)
    cv2.waitKey()
