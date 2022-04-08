breed [crimes crime]                                                                                                       ;a breed for just crime points
breed [vacants vacant]                                                                                                     ;a breed denoting vacant buildings
breed [buyers buyer]

patches-own
 [
   street                                                                                                                  ;is the patch a street or not
   land-value                                                                                                              ;a measure of proximity to amenities or disamenities
   avenue                                                                                                                  ;the major north/south streets
   parcel                                                                                                                  ;whether some can or can't be built
   landUse                                                                                                                 ;what is built on a patch
   CBD_Dist                                                                                                                ;this is how we measure and scale distance to amenties
   CBD_Metric                                                                                                              ;more info below
   Avenue_Dist
   Avenue_Metric
   Vacant_Dist
   Vacant_Metric
   Crime_Dist
   Crime_Metric
   Park_Dist
   sold-yet                                                                                                                ;a placeholder: Imagine that if sold-yet = 0 then you can buy the parcel
 ]                                                                                                                         ;otherwise, nothing happens to that parcel

buyers-own
  [
    purchase-power                                                                                                         ;a placeholder: Maybe your simulation has buyers coming
  ]                                                                                                                        ;into the simulation

to buy                                                                                                                     ;also a placeholder
;this is where all your runtime code will code
;note that the setup routine is below
end


to setup
  ca
  ask patches with [pxcor != 0 and pycor != 0]                                                                       ;here we're setting up the street grid
   [
    if abs pxcor mod 6 = 0 or pycor mod 6 = 0
      [set pcolor 5 set street 1]
    ask patches with [pxcor = 0 or pxcor = 1 or pycor = 0 or pycor = 1]
      [set pcolor 5 set street 1 set avenue 1]
   ]

    ask patches with [street = 0 and count patches with [street = 1] in-radius 1 = 1 or                              ;here we're setting up the parcels
                      count patches with [street = 1] in-radius 1 = 2]
      [set parcel 1]

    ask patches with [parcel = 1] [set sold-yet "No"]                                                                ;to begin, in the context of a gentrification simulation, we'll set a variable denoting that a parcel has not sold yet

    ask n-of (count patches with [parcel = 1] * .75) patches with                                                    ;set a 75%/25% mix of residential and commercial parcels
      [landUse = 0 and parcel = 1] [set landUse "residential"]
    ask n-of (count patches with [parcel = 1] * .25) patches with
    [landUse = 0 and parcel = 1] [set landUse "commercial"]

    ;ask n-of (count patches with [parcel = 1] * .03) patches with                                                   ;maybe you would like parks. If so, use this code just don't forget to adjust the percentages
      ;[landUse = 0 and parcel = 1] [set landUse "park"]
    ;ask patches with [landUse = "park"] [ask neighbors with [street = 0]
      ;[set landUse "park" set parcel 1]]

  create-parcel-points                                                                                               ;a routine that creates parcel points like crimes or vacants
  calculate-land-value                                                                                               ;a routine that calculate land value based on distance to (dis)amenities
  update-patch-color                                                                                                 ;a routine that set the color of the patch
end

to calculate-land-value                                                                                              ;the way this routine works is to measure distance to an (dis)amenity (ie. 'CDB_Dist')
                                                                                                                     ;and then scale those distances in to deciles below (ie. 'CBC_Metric'. Note that
                                                                                                                     ;amenties run from 10-1 (nearest = good; farthest = bad) and disanenites are the opposite
  ask patches with [street = 0]                                                                                      ;only calculate land value for the parcels
   [
     ;Acess to Central Business District (CBD)
     set CBD_Dist distance patch 0 0                                                                                 ;so meausure distance to patch 0 0 (the center)
     ;Access to avenues
     set Avenue_Dist distance min-one-of patches with [avenue = 1] [distance myself]
     ;Proximity to Vacants
     let nearVacants min-n-of 3 vacants [distance myself]                                                             ;measure from each parcel to it's nearest vacants
     set Vacant_Dist mean [distance myself] of nearVacants
     ;Proximity to Crime
     let nearCrime min-n-of 3 crimes [distance myself]
     set Crime_Dist mean [distance myself] of nearCrime
   ]

     let a sort [CBD_Dist] of patches with [street = 0]                                                                                    ;create a list of sorted cbd distances for each parcel
     let nlist length a print nlist                                                                                                        ;let is a temporary variable that is the length of this list
     ask patches with [street = 0 and CBD_Dist <= item (.1 * (nlist + 1)) a] [set CBD_Metric 10]                                           ;the first 10% of distances (the closest) get the highest score of '10'
     ask patches with [street = 0 and CBD_Dist > item (.1 * (nlist + 1)) a and CBD_Dist <= item (.2 * (nlist + 1)) a] [set CBD_Metric 9]
     ask patches with [street = 0 and CBD_Dist > item (.2 * (nlist + 1)) a and CBD_Dist <= item (.3 * (nlist + 1)) a] [set CBD_Metric 8]
     ask patches with [street = 0 and CBD_Dist > item (.3 * (nlist + 1)) a and CBD_Dist <= item (.4 * (nlist + 1)) a] [set CBD_Metric 7]
     ask patches with [street = 0 and CBD_Dist > item (.4 * (nlist + 1)) a and CBD_Dist <= item (.5 * (nlist + 1)) a] [set CBD_Metric 6]
     ask patches with [street = 0 and CBD_Dist > item (.5 * (nlist + 1)) a and CBD_Dist <= item (.6 * (nlist + 1)) a] [set CBD_Metric 5]
     ask patches with [street = 0 and CBD_Dist > item (.6 * (nlist + 1)) a and CBD_Dist <= item (.7 * (nlist + 1)) a] [set CBD_Metric 4]
     ask patches with [street = 0 and CBD_Dist > item (.7 * (nlist + 1)) a and CBD_Dist <= item (.8 * (nlist + 1)) a] [set CBD_Metric 3]
     ask patches with [street = 0 and CBD_Dist > item (.8 * (nlist + 1)) a and CBD_Dist <= item (.9 * (nlist + 1)) a] [set CBD_Metric 2]
     ask patches with [street = 0 and CBD_Dist > item (.9 * (nlist + 1)) a ] [set CBD_Metric 1]                                            ;the last 10 percent get the lowest score of '1'

  let b sort [Avenue_Dist] of patches with [street = 0]                                                                                    ;do this for all the amenities (feel free to add your own)
     let nlist2 length b
     ask patches with [street = 0 and Avenue_Dist <= item (.1 * (nlist2 + 1)) b] [set Avenue_Metric 10]
     ask patches with [street = 0 and Avenue_Dist > item (.1 * (nlist2 + 1)) b and Avenue_Dist <= item (.2 * (nlist2 + 1)) b] [set Avenue_Metric 9]
     ask patches with [street = 0 and Avenue_Dist > item (.2 * (nlist2 + 1)) b and Avenue_Dist <= item (.3 * (nlist2 + 1)) b] [set Avenue_Metric 8]
     ask patches with [street = 0 and Avenue_Dist > item (.3 * (nlist2 + 1)) b and Avenue_Dist <= item (.4 * (nlist2 + 1)) b] [set Avenue_Metric 7]
     ask patches with [street = 0 and Avenue_Dist > item (.4 * (nlist2 + 1)) b and Avenue_Dist <= item (.5 * (nlist2 + 1)) b] [set Avenue_Metric 6]
     ask patches with [street = 0 and Avenue_Dist > item (.5 * (nlist2 + 1)) b and Avenue_Dist <= item (.6 * (nlist2 + 1)) b] [set Avenue_Metric 5]
     ask patches with [street = 0 and Avenue_Dist > item (.6 * (nlist2 + 1)) b and Avenue_Dist <= item (.7 * (nlist2 + 1)) b] [set Avenue_Metric 4]
     ask patches with [street = 0 and Avenue_Dist > item (.7 * (nlist2 + 1)) b and Avenue_Dist <= item (.8 * (nlist2 + 1)) b] [set Avenue_Metric 3]
     ask patches with [street = 0 and Avenue_Dist > item (.8 * (nlist2 + 1)) b and Avenue_Dist <= item (.9 * (nlist2 + 1)) b] [set Avenue_Metric 2]
     ask patches with [street = 0 and Avenue_Dist > item (.9 * (nlist2 + 1)) b ] [set Avenue_Metric 1]

  let c sort [Vacant_Dist] of patches with [street = 0]
     let nlist3 length c
     ask patches with [street = 0 and Vacant_Dist <= item (.1 * (nlist3 + 1)) c] [set Vacant_Metric 1]
     ask patches with [street = 0 and Vacant_Dist > item (.1 * (nlist3 + 1)) c and Vacant_Dist <= item (.2 * (nlist3 + 1)) c] [set Vacant_Metric 2]
     ask patches with [street = 0 and Vacant_Dist > item (.2 * (nlist3 + 1)) c and Vacant_Dist <= item (.3 * (nlist3 + 1)) c] [set Vacant_Metric 3]
     ask patches with [street = 0 and Vacant_Dist > item (.3 * (nlist3 + 1)) c and Vacant_Dist <= item (.4 * (nlist3 + 1)) c] [set Vacant_Metric 4]
     ask patches with [street = 0 and Vacant_Dist > item (.4 * (nlist3 + 1)) c and Vacant_Dist <= item (.5 * (nlist3 + 1)) c] [set Vacant_Metric 5]
     ask patches with [street = 0 and Vacant_Dist > item (.5 * (nlist3 + 1)) c and Vacant_Dist <= item (.6 * (nlist3 + 1)) c] [set Vacant_Metric 6]
     ask patches with [street = 0 and Vacant_Dist > item (.6 * (nlist3 + 1)) c and Vacant_Dist <= item (.7 * (nlist3 + 1)) c] [set Vacant_Metric 7]
     ask patches with [street = 0 and Vacant_Dist > item (.7 * (nlist3 + 1)) c and Vacant_Dist <= item (.8 * (nlist3 + 1)) c] [set Vacant_Metric 8]
     ask patches with [street = 0 and Vacant_Dist > item (.8 * (nlist3 + 1)) c and Vacant_Dist <= item (.9 * (nlist3 + 1)) c] [set Vacant_Metric 9]
     ask patches with [street = 0 and Vacant_Dist > item (.9 * (nlist3 + 1)) c ] [set Vacant_Metric 10]

  let d sort [Crime_Dist] of patches with [street = 0]
     let nlist4 length d
     ask patches with [street = 0 and Crime_Dist <= item (.1 * (nlist4 + 1)) d] [set Crime_Metric 1]
     ask patches with [street = 0 and Crime_Dist > item (.1 * (nlist4 + 1)) d and Crime_Dist <= item (.2 * (nlist4 + 1)) d] [set Crime_Metric 2]
     ask patches with [street = 0 and Crime_Dist > item (.2 * (nlist4 + 1)) d and Crime_Dist <= item (.3 * (nlist4 + 1)) d] [set Crime_Metric 3]
     ask patches with [street = 0 and Crime_Dist > item (.3 * (nlist4 + 1)) d and Crime_Dist <= item (.4 * (nlist4 + 1)) d] [set Crime_Metric 4]
     ask patches with [street = 0 and Crime_Dist > item (.4 * (nlist4 + 1)) d and Crime_Dist <= item (.5 * (nlist4 + 1)) d] [set Crime_Metric 5]
     ask patches with [street = 0 and Crime_Dist > item (.5 * (nlist4 + 1)) d and Crime_Dist <= item (.6 * (nlist4 + 1)) d] [set Crime_Metric 6]
     ask patches with [street = 0 and Crime_Dist > item (.6 * (nlist4 + 1)) d and Crime_Dist <= item (.7 * (nlist4 + 1)) d] [set Crime_Metric 7]
     ask patches with [street = 0 and Crime_Dist > item (.7 * (nlist4 + 1)) d and Crime_Dist <= item (.8 * (nlist4 + 1)) d] [set Crime_Metric 8]
     ask patches with [street = 0 and Crime_Dist > item (.8 * (nlist4 + 1)) d and Crime_Dist <= item (.9 * (nlist4 + 1)) d] [set Crime_Metric 9]
     ask patches with [street = 0 and Crime_Dist > item (.9 * (nlist4 + 1)) d ] [set Crime_Metric 10]

   ask patches with [street = 0]
   [
     set land-value (CBD_Metric * CBD_Multiplier) + (Avenue_Metric * Avenue_Multiplier) + (Vacant_Metric * Vacancy_Multiplier) +            ;set land value = to the scaled amenity score
                    (Crime_Metric * Crime_Multiplier)                                                                                       ;multiplied by a multiplier. There are seperate multipier
   ]                                                                                                                                        ;variables for each amenity set by the user on the interface.
end

to update-patch-color                                                                                                                       ;this routine is here in case you want to implement zoning change

  ask patches with [landUse = "residential"] [set pcolor green]
  ask patches with [landUse = "commercial"] [set pcolor blue]
  ask patches with [street = 0 and landUse = 0] [set pcolor black]
end

to create-parcel-points                                                                                                                    ;this routine allows us to create crime and vacant points
                                                                                                                                           ;and any other point you want to create
  ;crime------------------------
  let landValuelist sort [land-value] of patches with [parcel = 1]                                                                         ;let a temporary variable named landValueList = sorted land value of parcels
  let nLandValuelist length landValuelist
  ask n-of 20 patches with [parcel = 1 and land-value <= item (.2 * (nLandValuelist + 1)) landValuelist] [sprout-crimes 1]                  ;Have twenty of the top 20% lowest land values 'sprout' crimes
  ask crimes
   [
     set color red
     set shape "circle"
     set size .5
   ]

  ;vacant------------------------
  ask n-of (count patches with [parcel = 1] * Initial_Vacancy_Rate) patches with [parcel = 1] [sprout-vacants 1 ]                           ;Note that you can set Initial_Vacancy_Rate in the interface
  ask vacants
   [
     set color white
     set shape "x"
     set size .5
   ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
713
514
-1
-1
11.0
1
10
1
1
1
0
1
1
1
-22
22
-22
22
0
0
1
ticks
30.0

BUTTON
59
59
122
92
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
743
13
915
46
CBD_Multiplier
CBD_Multiplier
1
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
744
58
916
91
Avenue_Multiplier
Avenue_Multiplier
1
10
3.0
1
1
NIL
HORIZONTAL

BUTTON
21
130
142
163
Show land value
ask patches with [street = 0]\n    [\n      set pcolor scale-color blue land-value min [land-value] of patches max [land-value] of patches\n    ]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
21
176
132
209
Show land use
update-patch-color
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
745
241
917
274
Initial_Vacancy_Rate
Initial_Vacancy_Rate
0
1
0.2
.1
1
NIL
HORIZONTAL

BUTTON
20
222
181
255
Show vacancy distance
ask patches with [street = 0]\n    [\n      set pcolor scale-color red Vacant_Dist min [Vacant_Dist] of patches max [Vacant_Dist] of patches\n    ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
746
102
918
135
Vacancy_Multiplier
Vacancy_Multiplier
1
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
748
145
920
178
Crime_Multiplier
Crime_Multiplier
1
10
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
746
322
1025
351
Blue patches are commercial land use
15
94.0
1

TEXTBOX
743
351
1015
389
Green patches are residential land use
15
54.0
1

@#$#@#$#@
## WHAT IS IT?

This model provides a simple sandbox for students to play out different urban simulations. There are patches representing streets and parcels. There are agents
representing crimes and vacants. 

This model really only gives the demand-side of the equation by having each patch
calculate its distance to various amenities. These distances are scaled to give 'land value'.

Give me a brief overview and tell me what the motivation is for planning.

## HOW IT WORKS

Note the slider bars for the different amenities. The idea is to set those slider bars as you see your simulated resident preferences. Those weights are applied to a scaled distance metric to produce one land value statistic.

What is the intended agent/environment behavior or interaction?

## HOW TO USE IT

Once you figure out something to model (gentrification, crime, transit), you have to build a runtime (aka 'go') procedure. 

What should I click on?

## THINGS TO NOTICE

What is the emergent phenomenon?

## THINGS TO TRY

Are there any variables I should adjust? What do the plots tell me?

## EXTENDING THE MODEL

Where are the models shortcomings? Do you think the model is generalizable? Why or why not do you like the theory we set out to test? Do you have an alternative theory of gentrification and if so, what is it (be brief). How would you model this new theory with agents? If you like the current theory, how could you, given added time, experience and data, improve the current model?

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
