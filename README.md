# Etude

To make committing information to memory easier, we want a program that will help build and order flash cards for better rote learning.

It should have these features:

* web browser access with (hopefully transferrable) persistent state
* the early version can generates math questions for addition, subtraction, multiplication and division
* selects which material to present based on how well the student knows a piece of info. we use a variety of methods to determine the likelihood of a piece of info being known, such as student indication, how often they have a quick response time, and how often they get the information wrong or right.

## Development Tasks

* refactor sortByCorrectnessRatioThenIndexes until it's not so complicated
* add in addition, multiplication, division
* make tests of 20 random questions each, but let them continue to pick from the least correct ones
* make the UI easier (enter should work)
* show the wrong answers properly
* think about the problems and what's needed when learning
  - we want to encourage automatic response (ie rote learning) for times tables and simple arithmetic.
  - the concern is either the student has it in their memory, or they don't. That's all we're going for here.
  - our premise is that to traverse from the short term to the long term memory one starts with the answer, then
    slowly take the answer away, increasing the amount of time between the same piece of information being repeated
  - we need to get the student to indicate if they know something or not (which we can sometimes work out by average time to respond, and/or give them a way to mark that they think they know it - it then goes into maintenance)

