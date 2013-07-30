
class Pix
{
%TypeHeaderCode
    #include <leptonica/allheaders.h>
%End

public:

    //
    // Attributes
    //
    
    long w;
    long h;
    long d;
    long wpl;
    long xres;
    long yres;

    //
    // Methods
    //

    ~Pix();
    %MethodCode
        Py_BEGIN_ALLOW_THREADS
        pixDestroy(&sipCpp);
        Py_END_ALLOW_THREADS
    %End
    
    /*
        Utility methods to read/write to a file
    */
    
    static Pix* read(const char * filename);
    %MethodCode
        sipRes = pixRead(a0);
    %End
    
    void write(const char * filename);
    %MethodCode
        pixWrite(a0, sipCpp, IFF_DEFAULT);
    %End
    
    
    
//
//  Buffer interface
//

//%BIGetBufferCode      // python 3
//%End

//%BIReleaseBufferCode  // python 3
//%End

%BIGetReadBufferCode    // python 2
    *sipPtrPtr = pixGetData(sipCpp);
    sipRes = sipCpp->h * (sipCpp->wpl * 4);
%End

%BIGetSegCountCode      // python 2
    if (sipLenPtr)
        *sipLenPtr = sipCpp->h * (sipCpp->wpl * 4);
    sipRes = 1;
%End

%BIGetWriteBufferCode   // python 2
    *sipPtrPtr = pixGetData(sipCpp);
    sipRes = sipCpp->h * (sipCpp->wpl * 4);
%End

//
// Conversion
//

%ConvertToTypeCode

    //
    // Uses buffer protocol compatible with python 2.7
    //
    
    // input is expected to be in BGR format, for compatibility
    // with OpenCV

    if (!sipIsErr)
        return PyObject_CheckBuffer(sipPy);
    
    Py_buffer view;
    
    if (PyObject_GetBuffer(sipPy, &view, PyBUF_STRIDES) == -1)
        return NULL;
        
    if (view.ndim == 2 && view.ndim != 3 && view.ndim != 4)
    {
        PyErr_SetString(PyExc_TypeError, "Number of dimensions must be 2, 3, or 4");
        return NULL;
    }
    
    if (view.format != NULL && strcmp(view.format, "B"))
    {
        PyErr_SetString(PyExc_TypeError, "Buffer must contain unsigned bytes");
        return NULL;
    }
    
    // extract information from the buffer
    int h = view.shape[0];
    int w = view.shape[1];
    int d = 8;              // number of bits
    
    if (view.ndim == 3)
        d = view.shape[2] * 8;
        
    if (view.ndim == 4)
    {
        if (view.shape[3] != 1)
        {
            PyErr_SetString(PyExc_TypeError, "Dimension 4 must be 1");
            return NULL;
        }
    
        d += 1;
    }
    
    // create the pix and copy the data over
    Pix * pix = pixCreateNoInit(w, h, d);
    if (!pix)
    {
        PyErr_SetString(PyExc_TypeError, "Internal error: could not create PIX object");
        return NULL;
    }
    
    int pixLen = pix->h * (pix->wpl * 4);
    if (pixLen != view.len)
    {
        PyErr_SetString(PyExc_TypeError, "Internal error: pixLen != view.len");
        return NULL;
    }
    
    memcpy(pix->data, view.buf, view.len);
    PyBuffer_Release(&view);
    
    if (d != 8 && d != 32)
    {
        // tesseract wants 32bpp only
        Pix * tmp = pixConvertTo32(pix);
        pixDestroy(&pix);
        pix = tmp;
    }
    
    if (pix->d == 32)
    {
        // convert BGRA to RGBA (derived from lept byteswap code)
        l_uint32 * data = pix->data;
        l_uint32 wpl = pix->wpl;
        l_int32 h = pix->h;
        l_uint32 word;
        
        for (l_int32 i = 0; i < h; i++)
        {
            for (l_int32 j = 0; j < wpl; ++j, data++)
            {
                word = *data;
                *data = (word & 0x00ff00ff) |
                        ((word >> 16) & 0x0000ff00) |
                        ((word << 16) & 0xff000000);
            }
        }
    }
    
    *sipCppPtr = pix;
    *sipIsErr = 0;
    
    return sipGetState(sipTransferObj);
%End

};