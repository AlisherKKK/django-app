#!/usr/bin/env python3
# run with `python3 test.py > out.txt`
from time import time
import math

def f(n):
	A = [[i+j for i in range(n)] for j in range(n)]
	B = [[i-j for i in range(n)] for j in range(n)]
	C = [[sum(A[i][k] * B[k][j] for k in range(n)) for i in range(n)] for j in range(n)]
	return C

for n in range(1,201):
	dt = math.inf
	for tries in range(0,5):
		startTime = time()
		f(n)
		endTime = time()
		dt = min(dt, endTime - startTime)
	print(n, dt)