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
	for i in range(0,len(myArray)-1):
		for j in range(0,len(myArray)-i-1):
			if myArray[j] > myArray[j+1]:
				tmp = myArray[j]
				myArray[j] = myArray[j+1]
				myArray[j+1] = tmp

if __name__=='__main__':
	length = 10
	init()
	printArray()
	bubblesort()
	print ''
	printArray()
