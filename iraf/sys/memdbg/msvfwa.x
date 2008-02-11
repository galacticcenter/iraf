# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# MSVFWA -- Determine the buffer address which satisfies the maximum alignment
# criteria, save the buffer fwa in the integer cell immediately preceding
# this, and return a pointer to the user area of the buffer.

pointer procedure msvfwa (fwa, dtype, sz_align, fwa_align)

pointer	fwa
int	dtype
int	sz_align
pointer	fwa_align

pointer	bufptr, mgdptr()
pointer	coerce()

begin
	# Compute the pointer to the data area which satisfies the desired
	# alignment criteria.  Store the fwa of the actual OS allocated buffer
	# in the integer cell preceeding the data area.

	bufptr = mgdptr (fwa, TY_POINTER, sz_align, fwa_align)
	Memp[bufptr-1] = fwa

	# Return pointer of type dtype to the first cell of the data area.
	return (coerce (bufptr, TY_POINTER, dtype))
end
