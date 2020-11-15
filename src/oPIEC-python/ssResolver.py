#oPIEC support set Resolver
import random
import smoothing
import sys

#DP tactic
def smallestRanges(support_set, new_entries, verbose=False):
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('\tS: ' + str(S))
	counter = 0
	temp_array = list()

	def find_longest_range(elemArray):
		max_size = -sys.maxsize
		max_elem = -1
		for i in range(0, len(elemArray)):
			my_size = elemArray[i][2]
			if my_size > max_size:
				max_size = my_size
				max_elem = i
		return max_elem, max_size

	while counter<m+k:
		if counter==0:
			score_range_size = sys.maxsize
		else:
			score_range_size = S[counter-1][1] - S[counter][1]
		if counter<k:
			temp_array.append((S[counter][0], S[counter][1], score_range_size))
			if counter==k-1:
				longest_elem = find_longest_range(temp_array)
		else:
			if score_range_size < longest_elem[1]:
				temp_array.pop(longest_elem[0])
				temp_array.append((S[counter][0], S[counter][1], score_range_size))
				longest_elem = find_longest_range(temp_array)
		counter+=1
	for elem in temp_array:
		S.remove((elem[0], elem[1]))
	support_set = S
	return support_set

## Remove random elements
def ssrandomResolver(support_set, new_entries, verbose=False):
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('\tS: ' + str(S))
	result = random.sample(S, m)
	if verbose:
		print('\tRandom selection to keep: ' + str(result))
	return result

## No change
def noResolver(support_set, new_entries):
	return support_set