# Design

StashSphere tries to achieve certain goals which are reflected in the design.

## Easy maintenance

StashSphere should not require much maintenance and operations effort.
Hence the backend is a single **monolithic** binary which has all assets
included (such as migrations). You can deploy using a single `scp` command!
StashSphere will try to solve as many features internally before requiring
external services.

## Privacy Protection

StashSphere removes [Exif](https://en.wikipedia.org/wiki/Exif) metadata from
images when they are uploaded to prevent unwanted leaks.

## Ownership is respected

When an user adds a thing it will be uploaded as `private`.
Even after it has been shared with others, the owner may later delete it or
make it `private` again.
Of course StashSphere cannot control whether other users made screenshots,
scraped the API or made a note.
However StashSphere *strives to respect the will of the owner* even when
it cannot guarantee it.
