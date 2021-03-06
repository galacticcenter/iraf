# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<imhdr.h>
include	<imio.h>

# IMBLN3 -- Get the length of the axes of a three dimensional subraster.
# Must be called immediately after the get or put call that created the
# buffer.

procedure imbln3 (imdes, nx, ny, nz)

pointer	imdes
int	nx, ny, nz
int	i, v[3]
pointer	bdes

begin
	# Get pointer to most recently used buffer descriptor.
	bdes = IM_LASTBDES(imdes)

	do i = 1, 3
	    v[i] = abs (BD_VE(bdes,i) - BD_VS(bdes,i)) + 1

	nx = v[1]
	ny = v[2]
	nz = v[3]
end
