# Wynntils Data-Storage

## Wynntils maps

Generating maps for Wynntils (both Artemis and Legacy) is a two-step process.
First, we must gather "tiles" of maps using Journeymap, and then we can process
these tiles into the png files and additional metadata needed by Wynntils.

It is important to keep a high quality of the tile data. This will allow us to
make minor updates to the map by just gathering the modified tiles, and then
easily update the map using a simple script.

### The worldmap directory

The `worldmap` directory contains all data needed to re-generate the in-game
worldmap/minimap.

`worldmap/journeymap-data` contains tiles that are created by Journeymap, and
special care must be taken to keep them correctly updated. Make sure to read the
following instructions carefully!

`worldmap/masks` contains black and white masks that determine which part of the
mapped areas that should be included, and which should be transparent. See below
on adding new areas on how to update these. The single mask used by Legacy is
instead stored in `reference/map-mask.png`.

The script `scripts/update-journeymap.sh` will help you with updating the
worldmap, to make sure this is done as smoothly as possible for you, and with
repeatable results.

## Gathering tiles data

The following sections describes the setup you need to do once to start
gathering tiles, preparations that you need to do before each mapping session,
how you do the actual mapping and how you save the tiles to the repository when
you are done.

### Preparations before first mapping

Select the Minecraft installation that you're planning to use. You can use your
normal Wynntils installation, there are no clashes (except UI). Install the
correct version of journeymap in the `mods` folder -- please use the one in
`worldmap/bin/journeymap-1.20.2-5.9.18-fabric.jar` so we stick to a single version.

Start up Minecraft and journeymap at least one. Press `J` to access journeymap
and confirm it works. Leave Minecraft.

Install the specific configurations using the `update-journeymap` script. Go to
your base Minecraft folder (`.minecraft`), which should contain a `journeymap`
folder. Run the script from there, e.g.
`~/Wynntils-devel/Data-Storage/scripts/update-journeymap.sh`. If everything is
OK, you will see a help screen:

```
Usage: ./Data-Storage/scripts/update-journeymap.sh [get-from-journeymap|install-in-journeymap|install-wynntils-config|restore-orig-config]
```

Now setup the wynntils configuration. (Don't worry, your original config will be
saved.) Run: `$DS/scripts/update-journeymap.sh install-wynntils-config` (where
`$DS` is short for where your Data-Storage is checked out)

### Preparation before each mapping session

Go to `$DS`, and do a `git pull` to make sure you've got the latest version.

Go to your Minecraft folder, and run `$DS/scripts/update-journeymap.sh
install-in-journeymap` to get the latest map data from the git repo into your
journeymap installation. (If your world is not named `Wynncraft`, you need to
override )`WYNNCRAFT_WORLD_NAME`)

If everything works out, you are likely to see a list of changed map tile files,
and the latest versions of these are copied to your installation.

Please announce in Discord that you will be doing mapping, since conflicts are
not very well handled (different updates to the same region will lead to data
loss).

### Do the mapping

Now start Minecraft, log into Wynncraft, and start running around in the areas
that need mapping. I found it helpful to have both the journeymap and Wynntils
minimap up at the same time, and to check the journeymap world map from time to
time. You can switch classes etc all you want, journeymap does not care about
that. When you are done, quit Minecraft.

### Save the mapping session

Go to your Minecraft folder, and run `$DS/scripts/update-journeymap.sh
get-from-journeymap` to copy the latest map data into the git repo from your
journeymap installation. (If your world is not named `Wynncraft`, you need to
override `WYNNCRAFT_WORLD_NAME`)

Then go to `$DS`, do `git status` to verify that you have changed only the tiles
in `worldmap/journeymap-data`. Now comes the tricky part. Journeymap will always
update all tiles you have visited, even if there are no visible changes. If we
blindly push all binary changes in this directory, the repository will quickly
grow in size. So, please double check all changed image tiles if you really
intended to update them. If you were just about remapping a specific area,
revert all changes except for that area. If you can't visibly spot any
difference in unrelated areas, just revert those files.

Finally, commit the real changed tiles, and push it upstream/open a PR.

## Generating maps from collected tiles

The next step is to use the scripts available here to generate the updated map
png files and associated metadata. Make sure you have updated the tiles properly
first as described above.

### Artemis

Run the shell script `scripts/update-maps-artemis.sh`. This will create a
directory `worldmap/out` (and also other data files). Do not commit these
generated files to the repository! Instead, copy them to the `maps` directory in
where you have checked out https://github.com/Wynntils/WynntilsWebsite-API
(called `$WWAPI` below). Note especially the updated maps.json, which contain
new md5 sums for these maps.

However **don't commit these files blindly** to `$WWAPI`! The script will
regenerate all maps, and they will get new md5 due to time stamps, but they are
visually identical, and it is just a waste of disk space and bandwith for us and
all our users to update them without need. Instead, revert those map files that
you know have not been changed. Also revert the corresponding md5 sums in
`maps.json`. So if you e.g. are updating just the main map, there should only be
a map-main.png file, and a single md5 line change in `maps.json`.

Now you can commit this to `$WWAPI`, and push upstream/open a PR.

### Adding a new map part to Artemis

In Artemis, multiple map parts are supported. (Legacy only has the main map.)

* To add a new area, first start by mapping the tiles.

* Then you need to figure out the bounding box of the region. You can easily
spot this in the set of new files in the git repo for the tiles directory.

* Set up a new area ("part") in `scripts/update-maps-artemis.sh`. Add a new line
like this: \
`do_map "Seaskipper" "seaskipper" 31 32 30 30`

  This reads as follows: `do_map` is the function call, `"Seaskipper"` is a human
friendly name for the area (currently not really used), `"seaskipper"` is a
identifier suitable for the resulting png file name etc. The four numbers are
the region bounding box. `31 32` is the X axis, `31` is the smallest (closest to
negative infinity) value, and `32` is the largest. `30 30` is the Z axis, from
smallest to largest. So if you have regions going from -3 to -4, make sure you
put them as `-4 -3`!

  A hint is to comment out the other `do_map` calls at this point, to speed up the
process.

* Now you can run the script `update-maps-artemis.sh`, and you will get the
processed output image file in image file in
`worldmap/out/map-<identifier>.png`. If this looks fine, you are done, but most
likely, you will need to create a mask for this file to filter out bad parts of
the terrain that is not supposed to be visible.

* To create a mask, open the generated map in a image editor (I prefer Gimp).
Make sure to not resize or translate the image. Now create a black and white
mask of the same size. Black means that areas will be removed on the map, white
that it will be kept.

  You can do this in many ways. I prefer to add a new layer, trace the contour of
the area I want to keep with e.g. the brush tool, and then fill the area outside
this contour. I personally think this looks better if the contour looks a bit
organic and not to strict. Make sure you have no dangling white spots where the
flood fill did not fully fill all the way in to the brushed contour.

  Regardless of how you produce the mask, at the end, make sure only the black and
white layer is visible (e.g. by removing the original image layer), and convert
the color model to a 2-color (1-bit) index color model. Now the mask is done.
Save it as `worldmap/masks/map-mask-<your-area-identifier>.png`.

* Now you can re-run the  `update-maps-artemis.sh` scripts. The image file in
`worldmap/out/map-<identifier>.png` should be updated with a new file, with the
mask applied. Check that it looks good.

* When you are happy, make a PR/commit with the new mask and the new line in
`update-maps-artemis.sh`.

### Legacy

Run the shell script `scripts/update-maps-legacy.sh`. This will create a file
`main-map.png` in `$DS`. Do not commit this generated files to the repository!
Instead, copy it to the `maps` directory in where you have checked out
https://github.com/Wynntils/WynntilsWebsite-API (called `$WWAPI` below).

The md5 sum will be updated after commit by a php script, so now you can commit
this to `$WWAPI`, and push upstream/open a PR.
