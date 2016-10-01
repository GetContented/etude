# Etude

To improve simple math skill, we want a program that will generate and ask a bunch of maths questions.

It should have these features:

* web browser access with persistent state
* generates math questions for addition, subtraction, multiplication and division
* selects questions to ask based on a weighted scale using history of incorrect answers to drive frequency

## Development Stages

1. √ hello world
2. √ what's 1 + 1 (hard-coded), and take the answer then display it
3. √ give a PointValue to the answer, and display it
4. change so that the answer is only calculated on a button press
5. make it work in a loop, tallying correct and incorrect answers
6. make it work with three questions, iterating over them
7. make it generate the questions from permutations
8. make it randomize the question order
9. make it keep the past questions and show incorrectly answered items more frequently
