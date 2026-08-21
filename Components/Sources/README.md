# Sources

TD build: 2025.32460

Named input sources. One Select TOP per source, named for what it is rather than for the
node that produces it, so everything downstream refers to `mario` and `gem` instead of
`src_mario` and `2818_163160472_medium`.

**Looks like:** nothing on its own. It's a name-plate, not an artwork.

**Needs:** the nodes it points at to exist in `/project1`.

**Names:** `mario`, `skull`, `gem`, `underworld`, `scroll`, `generative`,
`syphon1`–`syphon6`.

`generative` is the existing feedback / ramp / HSV chain (`comp2`), not a file. The six
`syphon` entries are the live Syphon inputs — black until something publishes to them.

Layers pick a source by name through their `Source` menu, which builds the path
`/project1/sources/<name>`. Renaming an entry here breaks any layer pointing at it, so
add new names rather than renaming old ones.
