
#ifndef __PIX_BUFFER_H
#define __PIX_BUFFER_H

#include <leptonica/allheaders.h>

// container to build a python type around
struct PixBuffer
{
    unsigned char * buffer;
    int len;
    
    int h;
    int w;
    int d;
    
    PixBuffer(Pix * pix)
    {
        h = pix->h;
        w = pix->w;
        
        switch (pix->d)
        {
            case 1:  d = 1; break;
            case 2:  throw "depth 2 not implemented";
            case 4:  throw "depth 4 not implemented";
            case 8:  d = 1; break;
            case 16: throw "depth 16 not implemented";
            case 24: throw "depth 24 not implemented";
            case 32: d = 3; break;       // ignore the A channel, as it isn't used
            default:
                throw "Invalid depth";
        }
        
        // make a copy, and unpack the pix data to something
        // sensible, and convert to BGR
        
        len = h * w * d;
        buffer = new unsigned char[len];
        memset(buffer, 0x55, len);
        
        // unpack the pix data to something sensible
        if (pix->d == 1)
        {
            // unpack bits
            // TODO: Make this more efficient. Good enough for now. 
            unsigned char * bufPtr = buffer;
            l_uint32 * pixPtr = pix->data;
            
            l_uint32 pixStride = pix->wpl;
            
            for (int i = 0; i < h; ++i, pixPtr += pixStride)
            {
                for (l_uint32 j = 0; j < pixStride; ++j)
                {
                    l_uint32 pixData = pixPtr[j];
                    int kcount = 32;
                
                    // the last dword might have padding
                    if (j == pixStride-1)
                        kcount = ((w - 1) % 32) + 1;
                    
                    for (int k = kcount-1; k >= 0; --k, ++bufPtr)
                        *bufPtr = ((char)(pixData >> k) & 1)-1;
                }
            }
        }
        else if (pix->d == 8)
        {
            unsigned char * bufPtr = buffer;
            l_uint32 * pixPtr = pix->data;
            
            l_uint32 pixStride = pix->wpl;
        
            for (int i = 0; i < h; ++i, pixPtr += pixStride)
            {
                for (l_uint32 j = 0; j < pixStride; ++j)
                {
                    if (j != pixStride-1 || (w % 4) == 0)
                    {
                        #ifdef L_BIG_ENDIAN
                            // strictly speaking, this will fail on non-gcc compilers,
                            // but this is how leptonica does it
                            
                            *bufPtr = pixPtr[j];
                            
                        #else  
                        
                            // byteswap
                            l_uint32  pixData = pixPtr[j];
                            
                            *((l_uint32*)bufPtr) = (pixData >> 24) |
                                                  ((pixData >> 8) & 0x0000ff00) |
                                                  ((pixData << 8) & 0x00ff0000) |
                                                  (pixData << 24);
                        #endif
                        
                        bufPtr += 4;
                    }
                    else
                    {
                        int rem = w % 4;
                        
                        l_uint32  pixData = pixPtr[j];
                        
                        *bufPtr = (unsigned char)(pixData >> 24);
                        ++bufPtr;
                        
                        if (rem > 1)
                        {
                            *bufPtr = (unsigned char)(pixData >> 16);
                            ++bufPtr;
                        }
                        
                        if (rem > 2)
                        {
                            *bufPtr = (unsigned char)(pixData >> 8);
                            ++bufPtr;
                        }
                    }
                }
            }
        }
        else if (pix->d == 32)
        {
            int ilen = h * w;
            unsigned char * bufPtr = buffer;
            l_uint32 * pixPtr = (l_uint32*)pix->data;
            
            for (int i = 0; i < ilen; ++i, ++pixPtr, bufPtr += 3)
            {
                l_uint32  pixData = *pixPtr;
                
                // RGBA -> BGR
                *(bufPtr + 0) = GET_DATA_BYTE(pixPtr, COLOR_BLUE);
                *(bufPtr + 1) = GET_DATA_BYTE(pixPtr, COLOR_GREEN);
                *(bufPtr + 2) = GET_DATA_BYTE(pixPtr, COLOR_RED);
            }
        }
        else
        {
            // shouldn't ever happen
            throw "Buffer not implemented for specified depth";
        }
    }
    
    ~PixBuffer()
    {
        delete [] buffer;
        buffer = NULL;
    }
    
    
};

#endif
