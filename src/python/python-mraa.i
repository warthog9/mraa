%module(docstring="Python interface to libmraa") mraa

%feature("autodoc", "3");

%include typemaps.i
%include carrays.i

%array_class(uint8_t, uint8Array);

// i2c write()
%typemap(in) (const uint8_t *data, int length) {
  if (PyByteArray_Check($input)) {
    // whilst this may seem 'hopeful' it turns out this is safe
    $1 = (uint8_t*) PyByteArray_AsString($input);
    $2 = PyByteArray_Size($input);
  }
}

%typemap(out) uint8_t*
{
  // need to loop over length
  $result = PyByteArray_FromStringAndSize((char*) $1, arg2);
}

%newobject I2c::read(uint8_t *data, int length);

%typemap(in) (uint8_t *data, int length) {
   if (!PyInt_Check($input)) {
       PyErr_SetString(PyExc_ValueError, "Expecting an integer");
       return NULL;
   }
   $2 = PyInt_AsLong($input);
   if ($2 < 0) {
       PyErr_SetString(PyExc_ValueError, "Positive integer expected");
       return NULL;
   }
   $1 = (uint8_t*) malloc($2 * sizeof(uint8_t));
}

%typemap(argout) (uint8_t *data, int length) {
   Py_XDECREF($result);   /* Blow away any previous result */
   if (result < 0) {      /* Check for I/O error */
       free($1);
       PyErr_SetFromErrno(PyExc_IOError);
       return NULL;
   }
   // Append output value $1 to $result
   $result = PyByteArray_FromStringAndSize((char*) $1, result);
   free($1);
}

%include ../mraa.i

