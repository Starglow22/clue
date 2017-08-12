# Clue
Just me making a simple single-player version of the classic board game Clue (Cluedo) to familiarize myself with Swift

Yes, I know this is pretty terrible. But it's the largest project I've ever tackled solo, the first thing with an actual UI I made, and it served its purpose of teaching me stuff.

### What I learned
- Learn about asynchronism _before_ trying to code something of an inherently synchronous nature but requiring user interaction.
  It would have been way better to do some sort of fork/join than that weird callback thing I did.
- Modularity is important. It's already bad enough that my human player needed logic wholly different from all the computer players, baking that into the UI was a _terrible_ idea. 
  - It's more or less impossible to test thoroughly and even write tests for
  - Makes no sense
  - Is really hard to debug and fix because it's all just crammed into key handlers
- Don't put UI code in the model classes, that's just awful. No. Why.
- When doing something for the first time picking a use case with somewhat more relevant frameworks and documentation would be wise.
- It would probably be a good idea to join some sort of project to learn something new, so I can see common conventions and practices and learn stuff instead of doing weird hacky things like listed above.
  - Swift doesn't have "private"? Combined with the total lack of modularity that led to be just giving everything access to pretty much everything else instead of writing stuff properly
- Write tests. Okay so I purposely wasn't writing tests because this was a project just for my own fun but I eventually realized that only gets you so far when you have computerized players whose entire logic is almost entirely purpisely hidden so I had to write some in the end. Also writing tests is boring but I don't even play this game myself because I got fed up of clicking through it to test stuff...
