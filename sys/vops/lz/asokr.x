# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# ASOK -- Select the Kth smallest element from a vector.  The algorithm used
# is selection by tail recursion (Gonnet 1984).  In each iteration a pivot key
# is selected (somewhat arbitrarily) from the array.  The array is then split
# into two subarrays, those with key values less than or equal to the pivot key
# and those with values greater than the pivot.  The size of the two subarrays
# determines which contains the median value, and the process is repeated
# on that subarray, and so on until all of the elements of the subarray
# are equal, e.g., there is only one element left in the subarray.  For a
# randomly ordered array the expected running time is O(3.38N).  The selection
# is carried out in place, leaving the array in a partially ordered state.
#
# N.B.: Behaviour is O(N) if the input array is sorted.
# N.B.: The cases ksel=1 and ksel=npix, i.e., selection of the minimum and
# maximum values, are more efficiently handled by ALIM which is O(2N).

real procedure asokr (a, npix, ksel)

real	a[ARB]			# input array
int	npix			# number of pixels
int	ksel			# element to be selected

int	lo, up, i, j, k
real	temp

begin
	lo = 1
	up = npix
	k  = max (lo, min (up, ksel))

	while (up >= k && k >= lo) {
	    i = lo
	    j = up
	    temp = a[k];  a[k] = a[lo];  a[lo] = temp

	    # Split array into two.
	    while (i < j) {
		while (a[j] > temp)
		    j = j - 1
		a[i] = a[j]
		while (i < j && a[i] <= temp)
		    i = i + 1
		a[j] = a[i]
	    }
	    a[i] = temp

	    # Select the subarray containing the Kth element.
	    if (k < i)
		up = i - 1
	    else
		lo = i + 1
	}

	return (a[k])
end