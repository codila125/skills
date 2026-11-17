# Prototype

A prototype is throwaway code that answers one question. Use it when a spec
question cannot be settled on paper: a state model that might not hold, a flow
whose shape you cannot see, a UI nobody can picture.

1. **Name the question first.** "Does this reducer cover undo after a partial save?" A
   prototype without a question is just early production code.
2. **Smallest thing that answers it.** A single file, a scratch entry point, a
   script with a few inputs. Run it with one command and no setup.
3. **Throwaway from the first line.** Mark it (`scratch/`, `PROTOTYPE — delete
   me`), no persistence, no error handling beyond what makes it run, no tests, no
   abstractions.
4. **Surface the state.** After every action, print or render the full relevant
   state so the answer is visible, not inferred.
5. **Capture the decision, not the code.** Write the answer into `spec.md` (or
   `research.md` when it is a fact about the platform) and delete the prototype in
   the same commit. The branch keeps only what was decided.

A prototype never lands on the integration branch. If the answer changes the
plan, that is a plan change, recorded as one.
