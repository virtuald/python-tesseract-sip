

class PixBuffer /Abstract/
{
    %TypeHeaderCode
        #include "PixBuffer.h"
    %End

public:

    int h;
    int w;
    int d;      // 1 or 3

    int len;

    //
    //  Buffer interface
    //

    //%BIGetBufferCode      // python 3
    //%End

    //%BIReleaseBufferCode  // python 3
    //%End

    %BIGetReadBufferCode    // python 2
        *sipPtrPtr = sipCpp->buffer;
        sipRes = sipCpp->len;
    %End

    %BIGetSegCountCode      // python 2
        if (sipLenPtr)
            *sipLenPtr = sipCpp->len;
        sipRes = 1;
    %End

    %BIGetWriteBufferCode   // python 2
        *sipPtrPtr = sipCpp->buffer;
        sipRes = sipCpp->len;
    %End

    //
    // Shape property
    //

    %Property(name=shape, get=get_shape)

    PyObject * get_shape();
    %MethodCode
        #if PY_MAJOR_VERSION >= 3
            PyObject * ph = PyLong_FromLong(sipCpp->h);
            PyObject * pw = PyLong_FromLong(sipCpp->w);
            PyObject * pd = PyLong_FromLong(sipCpp->d);
        #else
            PyObject * ph = PyInt_FromLong(sipCpp->h);
            PyObject * pw = PyInt_FromLong(sipCpp->w);
            PyObject * pd = PyInt_FromLong(sipCpp->d);
        #endif

        if (!ph || !pw || !pd)
        {
            Py_XDECREF(ph);
            Py_XDECREF(pw);
            Py_XDECREF(pd);
            return NULL;
        }

        sipRes = PyTuple_Pack(3, ph, pw, pd);
    %End
};
