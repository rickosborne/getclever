# getclever

Code related to the Clever API and getclever.com

## `avg-students-per-section.sh`

Per the Full Stack Engineer test, use the Clever API to fetch and calculate the number of students per section.

Usage:

```
./avg-students-per-section.sh
```

Options:

```
-v		Verbose mode
-c		Cache fetched files
```

The script will try to use `wget` or `curl`, whichever is available.  It also uses some basic *nix utilities, like `bc`, `tr`, `wc`, and `grep`, all of which should be available on pretty much any modern system.

There are some hacks in place to keep it relatively simple:

1. It doesn't do any _real_ JSON parsing, so it doesn't need any 3rd-party JSON libraries.  Should the JSON format change significantly the code would need to be updated.
2. It's got some hard-coded URLs, and not just for the API but also to GitHub for the certs.

Total time to complete: **~90 minutes**, including a refresher on BASH and the utilities listed above.  The API docs are pretty solid and took ~45 seconds to find what I needed.

## ColdFusion

There's a ColdFusion version of the script, because:

1. I don't do much CF these days, but I did it for almost 15 years so ... why not?
2. The more interesting languages already have libraries in the Clever GitHub, and that doesn't show a ton of skill to use an existing library.

I had the thought that I could build/translate one of the other libraries to CF.  It would probably take an hour or two ... but the utility seemed limited.

## Android

This _should_ work with anything Froyo or newer.  Like the rest, it's not pretty but it gets it done.

