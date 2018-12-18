# Motivation
## Intro
	- Everyone knows Debugging and everyone hates debugging.
	- What if we could automate a large part of the debugging work?
	- It turns out we can do just that with DD!
## The DD Idea
	- Assume there is two known configurations of a program: Yesterday and Today
	- Yesterday the program worked, today it does not
	- Somewhere in between changes have been made that induce the failure Today
	- Delta Debugging tries to systematically find the changes responsible for the failure
## A first approach
	- A few basic terms have to be defined:
		- Let C be the set of all changes between Yd and Td
		- c subset C: a set of changes we call a configuration
		- The test function returns "pass", "fail" or "no result" when given a configuration
		- test applies the configuration to Yd and tries to run the program 
	- This is all we need to build a first dd algorithm: ddsimple
		- It's basically a binary search over the set of all Changes
		- test is recursively run on half the changes in the current change set until one change is found that induces failure
	- This is simple enough but there is two major difficulties that make it a little harder

# Difficulties
## Interference
	- ddsimple works for single failure inducing-changes.
		- In each recursion step it applies only the set of changes known to contain a failure inducing change.
		- But what if two changes exist that individually pass the tests but their combination induces failure?
	- Problem: Two changes c_1 and c_2 interfere
	- Solution: 
		- If both halves of the current configuration pass the test we leave one half applied and search one of the interfering changes in the other half. 
		- Repeat this for the other half and both interfering changes can be found.
## The dd algorithm
	- If we add the case of interference to simpledd we get the dd algorithm.
	- The algorithm still has the "found" cases, only the "interference" case has been added.
	- d_1 is the search in c_1 while leaving c_2 applied, d_2 vice versa

## Inconsistency
	- There is another problem with this still
		- dd combines changes arbitrarily, i.e. every subset of C might be applied to Yd and tested
		- It's possible that on certain subsets the test can not be executed correctly and deliver a pass/fail result.
		- In this case the test returns no result, indicated by the question mark. We call the confiduration inconsistent.
	- Solution:
		- The more changes are applied at once the higher the chances the configuration is inconsistent
		- We can try to search on smaller (more granular) subsets of C to increase the chances of consistent configurations
	- Necessary changes to dd:
		- We add the case of "try again". Repeat the process on double the number of subsets if no consistent configuration is found.
		- So our dd algorithm has to work on every number n of subsets.
		- The case of "interference" has to be modified slightly: Interference occurs when both the subset c_i and its complement (all other changes not in c_i) pass.
		- Add the case of preference: If c_i is an inconsistent configuration but its complement is consistent and passes we can deduce the failure inducing change has to be in c_i

## The dd+ algorithm
	- The result is the dd+ algorithm which deals with interference and inconsistency
	- It deals with the following four cases:
		- found
		- interference
		- preference
		- try again
	- The result of dd+ is always a failure inducing subset of C. 
	- The subset is a minimal failure inducing subset if the the changes are safe, i.e. they result in a consistent configuration
	- The time complexity of dd is at most linear in the number of changes

## Use case 1: Analyzing program input
	- We want to look at two use cases for DD.
	- First a simple use case: Using DD to find out which part of a program input is responsible for a program crash
	- As an example consider a C program fail.c which crashed GCC in a certain version
		- From a developers standpoint the program looks like proper C code
		- We'd like to know which part of fail.c is responsible for the crash
		- This would mean tedious manual work without DD
	- We can apply DD as follows:
		- Consider an empty C code file as the Yesterday configuration and fail.c as the Today configuration
		- Every C token in fail.c can then be considered one change from Yd to Td
		- So we just run dd+ and get a minimal failure inducing set of C tokens
	- As you can see here dd+ has to run 19 tests to determine "+ 1.0" is the set of C tokens responsible for the crash
		- tests 20 and 21 are confirming that "+ 1.0" is indeed minimal

## Use case 2: Analyzing program execution
	- "+ 1.0" is correct C syntax and it is not obvious why it leads to a crash
	- So after finding out what part of the input is responsible for the fail it would be great to know why the input results in a crash
	- We want to create a new inpu to GCC called pass.c by removing the failure inducing subset "+1.0" from fail.c
	- Removing "+1.0" is a small change in the input but it can have major consequences for the program execution.
		- How can we find out where in the execution of fail.c something goes wrong compared to pass.c?
	- We can use DD on program states to compare a succeeding run and a failing run of GCC
		- If we do this at different points of the program execution we can create a Cause-Effet-Chain
		- The CEC can be as detailled as necessary depending on the number of comparisons
	- How do we set up DD on program states:
		- At a point of comparison we consider the program state of the succeeding run Yesterday, and the one of the failing run Today
		- A program state is a set of (variable, value) pairs
		- The changes between the states of the succeeding and failing run can be
			- a different value or
			- a variable only present in one of the states
		- We test a program state by continuing execution from the point of comparison