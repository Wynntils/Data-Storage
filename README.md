# Wynntils Data-Storage

## worldmap
The `worldmap` directory contains all data needed to re-generate the in-game
worldmap/minimap.

The script `scripts/update-journeymap.sh` will help you with updating the
worldmap, to make sure this is done as smoothly as possible for you, and with
repeatable results.
### Preparations before first mapping

Select the Minecraft installation that you're planning to use. You can use your
normal Wynntils installation, there are no clashes (except UI). Install the
correct version of journeymap in the `mods` folder -- please use the one in
`worldmap/bin/journeymap-1.12.2-5.7.1.jar` so we stick to a single version.

Start up Minecraft and journeymap at least one. Press `J` to access journeymap
and confirm it works. Leave Minecraft.

Install the specific configurations using the `update-journeymap` script. Go to
your base Minecraft folder (`.minecraft`), which should contain a `journeymap`
folder. Run the script from there, e.g.
`~/Wynntils-devel/Data-Storage/scripts/update-journeymap.sh`. If everything is
OK, you will see a help screen:

```
Usage: ./Data-Storage/scripts/update-journeymap.sh [get-from-journeymap|install-in-journeymap|update-raw-map|install-wynntils-config|restore-orig-config]
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
override )`WYNNCRAFT_WORLD_NAME`)

Then go to `$DS`, do `git status` to verify that you have changed only the tiles
in `worldmap/journeymap-data`, and then commit and push your changes.
