#!/usr/bin/env python
#
# Test program to ensure that the Pix to/from numpy conversion routines are
# actually functioning as we think they're functioning
#

import tesseract_sip as tesseract
import numpy as np


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


def test_array(w, h, d):

    # create an array
    original = np.linspace(0, 255, w*h*d).astype(np.uint8)
    
    # reshape
    original.shape = (w, h, d)

    # convert to pix
    pix = tesseract.Pix.from_buffer(original)

    # can help determine which part of the conversion is failing
    #pix.write('tmp.tif')
    #copy = cv2.imread('tmp.tif')
    
    # convert back
    copy = np_from_pix(pix)
    
    # compare
    if not np.all(copy == original):
    
        print original[:, :, d-1]
        print
        print copy[:, :, d-1]
        
        raise RuntimeError("Error: do not match: %s %s %s" % (w, h, d))


if __name__ == '__main__':

    np.set_printoptions(formatter={'int': lambda x: '%02x' % x})

    if True:
        for w in xrange(1, 75):
            for h in xrange(1, 75):
                for d in (1, 3):
                    test_array(w, h, d)
    else:
        test_array(10, 10, 4)

    print "All tests passed"
    exit(0)
