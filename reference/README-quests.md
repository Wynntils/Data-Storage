How quests.json were created
============================
The quests.json file has been compiled from several sources.

* The `name`, `level`, `length` and `starter-mission` fields has been extracted from the in-game Quest Book in Wynntils.
* The `reward` data (`experience`, `emeralds`, `access` and `items`) has been extracted from the `infobox` structure found in each Quest page on the wiki.
* The `province` and `starter-npc` has been extracted from the list on the main Quests page on the wiki.
* The `additional-npc` field was calculated from the list on the Quest NPCs page (but substracting the starter NPC) on the wiki.

In some cases, manual cleanup was needed. Especially the `items` and `access` fields were commonly free-form on the wiki, and a consistent
style was applied, using "," to separate multiple items, and "/" to separate mutually exclusive alternatives.

The rewards data shows the best possible rewards. Not all quests guarantee the best possible rewards. This ambiguity is not reflected in the data set.

The data above were consolidated into a CSV file, quests.csv. This was processed online at [https://www.convertcsv.com/csv-to-json.htm]
using the following custom template:

Top:
```
{ "quests":  [{br}
```

Repeating part:
```
{lb}
"{h1}":"{f1}" ,"{h2}":{(f2)==""?"null":f2}, "{h3}":"{f3}",
"rewards": {
  "{h4}":{f4}
  {f5!="" ? ", \""+h5+"\": " + f5 + "" : ""}
  {f6!="" ? ", \""+h6+"\": \"" + f6 + "\"" : ""}
  {f7!="" ? ", \""+h7+"\": \"" + f7 + "\"" : ""}
},
"{h8}":"{f8}", "{h9}":"{f9}" {f10!="" ? ", \""+h10+"\": \"" + f10 + "\"" : ""}
{f11!="" ? ", \"additional-npc\": [ \"" + f11 + "\"" : ""}
  {f12!="" ? ", \""+ f12 + "\"" : ""}
  {f13!="" ? ", \""+ f13 + "\"" : ""}
  {f14!="" ? ", \""+ f14 + "\"" : ""}
  {f15!="" ? ", \""+ f15 + "\"" : ""}
  {f16!="" ? ", \""+ f16 + "\"" : ""}
  {f17!="" ? ", \""+ f17 + "\"" : ""}
{f11!="" ? "]" : ""}
{rb}
```

Bottom:
```
{br}] }
```

The resulting file was quite ugly, and was given proper formatting by piping into `jq . > quests.json`.

The resulting quests.json is up-to-date and correct (inasfar as the wiki is correct) as of July 19, 2020.

Ask @magicus if you have any questions.

