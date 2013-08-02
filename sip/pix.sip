

class Pix /Abstract/
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
        
        // this is always true
        if (sipCpp == NULL)
            return;
    %End
    
    /*
        Utility methods to read/write to a file
    */
    
    static Pix* from_buffer(PyObject *);
    %MethodCode
    
        if (sipCanConvertToType(a0, sipType_Pix, SIP_NOT_NONE))
        {
            int sipResState = 0;
            int isError = 0;
            
            sipRes = (Pix*)sipConvertToType(a0, sipType_Pix, NULL, SIP_NOT_NONE, &sipResState, &isError);
            if (isError)
                return NULL;
        }
        else
        {
            PyErr_SetString(PyExc_TypeError, "Cannot convert from type");
            return NULL;
        }
    
    %End
    
    static Pix* read(const char * filename);
    %MethodCode
        sipRes = pixRead(a0);
    %End
    
    void write(const char * filename);
    %MethodCode
        pixWrite(a0, sipCpp, IFF_DEFAULT);
    %End
    
    // returns an object that implements the buffer interface
    // in a sensible way that can be used with numpy, as opposed
    // to the mess that you get with pix's internal format... 
    //
    // Object is a copy
    PixBuffer * get_buffer();
    %MethodCode
        Py_BEGIN_ALLOW_THREADS
        
        try
        {
            sipRes = new PixBuffer(sipCpp);
        }
        catch (const char * msg)
        {
            Py_BLOCK_THREADS
            
            PyErr_SetString(PyExc_TypeError, msg);
            return NULL;
        }
        
        Py_END_ALLOW_THREADS
    %End
    
    // returns the shape of the buffer object
    PyObject * get_buffer_shape();
    %MethodCode
        int d;
        
        switch (sipCpp->d)
        {
            case 1:  d = 1; break;
            case 8:  d = 1; break;
            case 24: d = 3; break;
            case 32: d = 3; break;  // 4th channel ignored
            default:
                PyErr_SetString(PyExc_ValueError, "Invalid depth");
                return NULL;
        }
        
        PyObject * ph = PyInt_FromLong(sipCpp->h);
        PyObject * pw = PyInt_FromLong(sipCpp->w);
        PyObject * pd = PyInt_FromLong(d);
        
        if (!ph || !pw || !pd)
        {
            Py_XDECREF(ph);
            Py_XDECREF(pw);
            Py_XDECREF(pd);
            return NULL;
        }
        
        sipRes = PyTuple_Pack(3, ph, pw, pd);
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
    
    // initialize this to error, unset it at the end when there is no error
    *sipIsErr = 1;
    
    if (PyObject_GetBuffer(sipPy, &view, PyBUF_STRIDES) == -1)
    {
        PyErr_SetString(PyExc_TypeError, "Buffer does not support strides");
        return NULL;
    }
        
    if (view.ndim != 2 && view.ndim != 3 && view.ndim != 4)
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
    {
        if (view.shape[2] > 3)
        {
            PyErr_SetString(PyExc_TypeError, "Dimension 3 must be <= 3 (Alpha channel would be ignored)");
            return NULL;
        }
    
        d = view.shape[2] * 8;
    }
    
    // create the pix and copy the data over
    Pix * pix = pixCreateNoInit(w, h, d);
    if (!pix)
    {
        PyErr_SetString(PyExc_TypeError, "Internal error: could not create PIX object");
        return NULL;
    }
    
    int pixLen = pix->h * (pix->wpl * 4);
    if (pixLen == view.len)
    {
        memcpy(pix->data, view.buf, view.len);
    }
    else if (pixLen > view.len)
    {
        // this mean that the header allocated padding for the buffer,
        // so we should copy it differently
        unsigned char * pixPtr = (unsigned char *)pix->data;
        unsigned char * bufPtr = (unsigned char *)view.buf;
        
        l_uint32 bufStride = w * (d/8);
        l_uint32 pixStride = pix->wpl * 4;
        
        for (l_int32 i = 0; i < h; ++i, bufPtr += bufStride, pixPtr += pixStride)
            memcpy(pixPtr, bufPtr, bufStride);
    }
    else
    {
        PyErr_SetString(PyExc_TypeError, "Internal error: pixLen < view.len");
        return NULL;
    }
    
    
    PyBuffer_Release(&view);
    
    if (d != 8 && d != 32)
    {
        // tesseract wants 32bpp only
        Pix * tmp = pixConvertTo32(pix);
        pixDestroy(&pix);
        pix = tmp;
    }
    
    if (pix->d == 8)
    {
        pixEndianByteSwap(pix);
    }
    else if (pix->d == 32)
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
