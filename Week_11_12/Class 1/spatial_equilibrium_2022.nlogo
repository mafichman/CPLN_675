turtles-own [use wealth spillover moved-already plot-breed]
patches-own [land-value]
breed [house houses]
breed [biz businesses]
breed [factory factories]


to setup
clear-all
end

to build-city
 ; print [wealth] of turtles
if count turtles = count patches * .9
  [
    kill-bancrupt-turtles
    stop
  ]
crt 1

ask turtles with [moved-already = 0]
  [
    let birth-number first n-values 1 [random 100]
    if (birth-number <= 45)
      [set breed house]
      if (birth-number > 45) and (birth-number <= 75)
         [set breed biz]
         if (birth-number > 75)
           [set breed factory]

    move-to one-of patches with [count turtles-here = 0]
    set moved-already 1
    face patch 0 0
 calculate-tradeoffs
;ifelse count turtles < 100
;  [move-to one-of patches with [count turtles-here = 0]
;    set moved-already 1]
;  [move-to one-of patches with [count turtles-here = 0]
;    calculate-tradeoffs]

  ]

;print count house / count turtles
end


;ask turtles with [moved-already = 0]                                               ;to ensure that all subsequent movements are driven only by an agent's wealth being
;  [                                                                                ; <= 0.
;     set use one-of [1 2 3]
;     if use = 1 [set breed factory]                                               ;ensures roughly 3 equal groups of land users
;     if use = 2 [set breed house]
;     if use = 3 [set breed biz]
;
;     move-to one-of patches with [count turtles-here = 0]
;     set moved-already 1
;     face patch 0 0
;
;  ]
;calculate-tradeoffs
;end


to calculate-tradeoffs
if count turtles > 100
  [
    ask turtles with [breed = house and moved-already = 1]                                                   ; close to other houses, even closer to businesses and farther from factories.
      [
        let a sort [distance myself] of other turtles with [breed = house]
        let a1 mean sublist a 0 5
        let dist_house 1 / a1

        let b sort [distance myself] of other turtles with [breed = biz]
        let b1 mean sublist b 0 5
        let dist_biz 1 / b1

        let c sort [distance myself] of other turtles with [breed = factory]
        let c1 mean sublist c 0 5
        let dist_factory 1 / c1

        set wealth (dist_house * Residential_to_Residential)  + (dist_biz * Residential_to_Commercial) + (dist_factory * Residential_to_Factory)
        set color scale-color green wealth 2 0
     ]

   ask turtles with [breed = biz and moved-already = 1]                                                       ;closest to other businesses; far from houses and equally far from factories
     [
        let a sort [distance myself] of other turtles with [breed = biz]
        let a1 mean sublist a 0 5
        let dist_biz 1 / a1

        let b sort [distance myself] of other turtles with [breed = house]
        let b1 mean sublist b 0 5
        let dist_house 1 / b1

        let c sort [distance myself] of other turtles with [breed = factory]
        let c1 mean sublist c 0 5
        let dist_factory 1 / c1

        set wealth (dist_house * Commercial_to_Residential) + (dist_biz * Commercial_to_Commercial) + (dist_factory * Commercial_to_Factory)
        set color scale-color blue wealth 2 0
     ]

   ask turtles with [breed = factory and moved-already = 1]                                                   ;closest to other factories; close to houses far from business
     [
        let a sort [distance myself] of other turtles with [breed = biz]
        let a1 mean sublist a 0 5
        let dist_biz 1 / a1

        let b sort [distance myself] of other turtles with [breed = house]
        let b1 mean sublist b 0 5
        let dist_house 1 / b1

        let c sort [distance myself] of other turtles with [breed = factory]
        let c1 mean sublist c 0 5
        let dist_factory 1 / c1

        set wealth (dist_factory * Factory_to_Factory) + (dist_house * Factory_to_Residential) + (dist_biz * Factory_to_Commercial)
        set color scale-color yellow wealth 2 0
    ]
   ask turtles with [wealth <= 0] [die]
  ]


end

to kill-bancrupt-turtles
ask turtles with [wealth <= 0]                                                        ;if wealth goes below 0 then move to a random patch
  [
     ask patch-here [set pcolor black]
     die
  ]
end

to visualize-means                                                                      ;this will visualize mean wealth of all turtles by land use
ask turtles with [wealth > 0]
  [
    ask patch-here
      [
        let a mean [wealth] of turtles in-radius 2
        set pcolor scale-color magenta a 2 0
      ]
  ]

end

to visualize-uses                                                                        ;this visualizes the land use of all turtles

  ask turtles with [breed = house]
    [
       ask patch-here [set pcolor 61]
    ]

  ask turtles with [breed = factory]
    [
       ask patch-here [set pcolor 41]
    ]

  ask turtles with [breed = biz]
    [
       ask patch-here [set pcolor 92]
    ]
  ask patches with [count turtles-here = 0] [set pcolor black]
end

to do-plots
  set-current-plot "Houses"
  clear-plot
  set-plot-x-range 0 10
  set-plot-y-range 0 10
  if count turtles > 50
    [
      ask turtles with [breed = house]
        [
           let a sort [distance myself] of other turtles with [breed = house]
           let a1 item 0 a let a2 item 1 a let a3 item 2 a let a4 item 3 a let a5 item 4 a
           let a_sum (a1 + a2 + a3 + a4 + a5) / 5

           let b sort [distance myself] of other turtles with [breed != house]
           let b1 item 0 b let b2 item 1 b let b3 item 2 b let b4 item 3 b let b5 item 4 b
           let b_sum (b1 + b2 + b3 + b4 + b5) / 5

           plotxy b_sum a_sum
        ]
    ]

  set-current-plot "Business"
  clear-plot
  set-plot-x-range 0 10
  set-plot-y-range 0 10
  if count turtles > 50
    [
      ask turtles with [breed = biz]
        [
           let c sort [distance myself] of other turtles with [breed = biz]
           let c1 item 0 c let c2 item 1 c let c3 item 2 c let c4 item 3 c let c5 item 4 c
           let c_sum (c1 + c2 + c3 + c4 + c5) / 5

           let d sort [distance myself] of other turtles with [breed != biz]
           let d1 item 0 d let d2 item 1 d let d3 item 2 d let d4 item 3 d let d5 item 4 d
           let d_sum (d1 + d2 + d3 + d4 + d5) / 6

           plotxy d_sum c_sum
        ]
    ]

  set-current-plot "Factories"
  clear-plot
  set-plot-x-range 0 10
  set-plot-y-range 0 10
  if count turtles > 50
    [
      ask turtles with [breed = factory]
        [
           let f sort [distance myself] of other turtles with [breed = factory]
           let f1 item 0 f let f2 item 1 f let f3 item 2 f let f4 item 3 f let f5 item 4 f
           let f_sum (f1 + f2 + f3 + f4 + f5) / 5

           let g sort [distance myself] of other turtles with [breed != factory]
           let g1 item 0 g let g2 item 1 g let g3 item 2 g let g4 item 3 g let g5 item 4 g
           let g_sum (g1 + g2 + g3 + g4 + g5) / 5

           plotxy g_sum f_sum
        ]
    ]

  set-current-plot "Count of Land Uses"
;  set-plot-x-range 1 3
;  set-plot-y-range 0 50
ask turtles
 [
   if breed = house [set plot-breed 1]
   if breed = biz [set plot-breed 2]
   if breed = factory [set plot-breed 3]
 ]
 histogram [plot-breed] of turtles with [wealth > 0]
;set-histogram-num-bars 3
end
@#$#@#$#@
GRAPHICS-WINDOW
244
30
677
464
-1
-1
17.0
1
10
1
1
1
0
0
0
1
-12
12
-12
12
0
0
1
ticks
30.0

BUTTON
694
42
758
75
Setup
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

BUTTON
880
87
1081
120
Visualize Neighborhood Wealth
visualize-means
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
920
40
1026
73
Develop City!
build-city
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
696
87
869
120
Visualize Turtle Land Uses
visualize-uses
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
729
139
888
172
Hide Turltes
ask turtles [hide-turtle]
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
915
140
1018
173
Show Turtles
ask turtles [show-turtle]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
817
237
995
360
Houses
NIL
NIL
0.0
20.0
10.0
20.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

PLOT
816
362
995
491
Business
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

PLOT
816
493
995
616
Factories
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

PLOT
1423
176
1623
318
Count of Land Uses
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

BUTTON
790
40
891
73
Create Plots
do-plots
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
25
56
223
89
Residential_to_Residential
Residential_to_Residential
-2
2
1.0
.5
1
NIL
HORIZONTAL

SLIDER
25
100
222
133
Residential_to_Commercial
Residential_to_Commercial
-2
2
2.0
.5
1
NIL
HORIZONTAL

SLIDER
25
144
223
177
Residential_to_Factory
Residential_to_Factory
-2
2
-2.0
.5
1
NIL
HORIZONTAL

TEXTBOX
47
27
197
46
Residential Preferences
15
64.0
1

SLIDER
25
266
225
299
Commercial_to_Commercial
Commercial_to_Commercial
-2
2
1.5
.5
1
NIL
HORIZONTAL

SLIDER
25
223
227
256
Commercial_to_Residential
Commercial_to_Residential
-2
2
1.0
.5
1
NIL
HORIZONTAL

SLIDER
26
312
226
345
Commercial_to_Factory
Commercial_to_Factory
-2
2
-2.0
.5
1
NIL
HORIZONTAL

TEXTBOX
44
194
242
232
Commercial Preferences
15
94.0
1

SLIDER
26
391
209
424
Factory_to_Residential
Factory_to_Residential
-2
2
1.0
.5
1
NIL
HORIZONTAL

SLIDER
28
435
209
468
Factory_to_Commercial
Factory_to_Commercial
-2
2
-2.0
.5
1
NIL
HORIZONTAL

SLIDER
27
479
210
512
Factory_to_Factory
Factory_to_Factory
-2
2
2.0
.5
1
NIL
HORIZONTAL

TEXTBOX
49
361
199
380
Factory Preferences
15
44.0
1

TEXTBOX
726
395
801
508
Average distance to neighbors of the same land use
11
0.0
1

TEXTBOX
792
635
1066
663
Average distance to neighbors of the other land use
11
0.0
1

TEXTBOX
800
209
1073
247
How clustered is each land use?
15
0.0
1

@#$#@#$#@
Spatial Equilibrium Simulation of Land Use Segregation

Ken Steif - ksteif@upenn.edu

This model attempts to explain how different land users arrange themselves in space using distance (to both similar and different land uses) as the only variable.  There are three land uses - residential, commercial and industrial.  Compared to similar spatial equilibrium models, including Alonso (1969)there is no assumption that centralized land is the most 'productive.'  By getting rid of this assumption and allowing the initial agents to settle randomly, the pattern of land uses is only dependent on where other land uses have settled in a previous time period.


Hardwired in to the model are the following land use preferences:

## RESIDENTIAL:

- Perefers to be CLOSEST to commercial (as if to reduce commuting costs)
- Prefers to CLOSE to other houses (a preference for neighborhoods)
- Prefers to be FARTHER from Factories (as if to get away from pollution)

## COMMERCIAL:

- Prefers to be CLOSEST to other business (a preference for agglomeration)
- Prefers to be FARTHER from both houses and factories equally (for increasing agglomeration and reducing pollution respectively)

## INDUSTRIAL:

-Prefers to be CLOSEST to other factories (a preference for agglomeration)
-Prefers to be CLOSE to houses (to have access to a workforce)
-Prefers to be FARTHEST from business (a preference for industrial agglomeration over commercial agglomeration)

Distances are calculated by each agent taking the mean nearest neighbor (NN) distance to its own land uses and to the other two land uses.  The INVERSE of these distances are taken to make closer land uses more 'important'.

Next each agent uses these distance calculations as a basis for calculating their preferences as laid out above.  These preferences are translated into a variable called 'wealth' (more on that later).  For instance, the calculation for RESIDENTIAL preferences is:

WEALTH = (Distance to NN RESIDENTIAL) + (Distance to NN COMMERCIAL) * 2 - (Distance to NN INDUSTRIAL * 2)

The user can of course play with these preferences if they wish.

The action occurs when the wealth of any agent is equal to or less than 0.  At this point, a moving agent simply picks up and moves to a random empty patch.

The simulation ends when there are no free patches left for new agents to settle.  At this point, there will undoubtedly be agents who have wealth <= 0.  By clicking "Find Bankrupt Turtles", you can visualize the location of these agents.

When the simulation is running notice how different land uses compete for space.  Notice how land use clusters are created, degrated and moved.

There are numerous things to notice when the simulation finishes including the pattern of land use separation:

Does the pattern represent what we actually see in cities?
Why does residential land use seem to buffer the industrial and commercial land uses?
What explains the pattern of bankrupt agents at the end of the simulation?
What drives the pattern of neighborhood wealth?

## VISUALIZATIONS

There are several ways to visualize the simulation.  The default is to visualize the agents colored by their wealth and their land uses.  You can hide the turtles at any time and visualize their locations in patches.  The first option "Visualize Neighborhood Wealth" does just that.  The second, "Visualize Turtle Land Uses" just shows the land uses of each turtle.

## PLOTS

The 3 plots are for each land use type.  They are NN distance to different land uses as a function of NN distance to same land uses.  A relatively more compact gradient will mean that a land use is more clustered.
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
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
