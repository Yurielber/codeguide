#!/bin/python

import random

myArray = []
length = 0

def init():
	for i in range(0, length):
		myArray.append(random.randint(0,100))

def printArray():
	for i in range(0,len(myArray)):
		print myArray[i],

def bubblesort():
	n = len(myArray)
	for i in range(n):
		for j in range(n-i-1):
			if myArray[j] > myArray[j+1]:
				myArray[j], myArray[j+1] = myArray[j+1], myArray[j]

if __name__=='__main__':
	length = 10
	init()
	printArray()
	bubblesort()
	print ''
	printArray()
