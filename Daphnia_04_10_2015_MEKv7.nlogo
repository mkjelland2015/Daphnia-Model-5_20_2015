 extensions [ bitmap profiler ]; bitmap takes a screenshot of view
globals [ 
  ; max-energy-reserves - moved to interface
  ; energy-gain - moved to interface
  ; energy-expenditure - moved to interface
  second; second is reporting the second being simulated, hence the number of seconds simulated,
  minute; minute is reporting the minute being simulated, hence the number of minutes simulated,
  hour; hour is reporting the hour being simulated, hence the number of hours simulated,
  day ; day is reporting the day being simulated, hence the number of days simulated,
  daphnia
  minx
  maxx
  miny
  maxy
 ;transgene-upregulate-growth-factor
 ;transgene-upregulate-growth-genes
 dead 
 dead-harvest
 dead!!!-tox ; Tox mortality 
 dead!!!!-Temperature ; Temperature induced mortality
 experiment-selection
 setup-experiment-again
  q
  age-at-death
  after-light-off-counter
  after-light-off-stamp
  after-light-off-limit
  after-chemical-off-counter
  after-chemical-off-stamp
  after-chemical-off-limit
  after-temperature-off-counter
  after-temperature-off-stamp
  after-temperature-off-limit
  tester
  harvest; moved to interface (off = False and on = True)
   energy-loss; random variable determines how much energy is lost based on logistic equations for salinity, temperature, and TSS conditions
  energy-intake; random variable determines how much energy is gained based on logistic equations for salinity, temperature, and TSS conditions
  energy-balance ; based on energy intake minus energy loss and shell is gained if there is a postive result
   spawn ; designates if reproduction event is happening or not
 ;harvest-daphnia?; harvest (remove the offspring) or not
 ;harvest-day; day to harvest; moved to interface
 ;harvest-minute; minute to harvest; moved to interface
 ;harvest-second; second to harvest; moved to interface
 ;spawn-day; day to reproduce; moved to interface
 ;spawn-minute; minute to reproduce; moved to interface
 ;spawn-second; second to reproduce; moved to interface
 
 
  ;days-to-simulate; moved to interface
  ;tox-condition; moved to interface (off = 0 and on = 1)
  ;light-condition; moved to interface (off = 0 and on = 1)
  ;light-start-time; moved to interface (tick # to start on)
  ;light-duration-time; moved to interface (# of ticks)
  ;setup-experiment; moved to interface (1 = light, 2 = chemical, and 3 = temperature experiment)
  ; chemical-source-start-time; moved to interface
  ; temperature-start-time; moved to interface
  ]

patches-own [light value1 value new-value ideal-value light-level id light-counter chemical-level chemical-counter temperature-level temperature-counter 
  tox                            ; measured in ppm
tox-duration                   ; measured in number of consecutive days that salinity is above a specified level
temperature                         ; measured in degrees Celsius
  temperature-duration                ; measured in number of consecutive days that temperature is above a specified level
 
  ]
turtles-own [comfort-level light-exposure temperature-exposure chemical-exposure myID start-patch start-patch-id sex identity total-dist prob mark
  energy-reserves                     ; energy-reserves = number of days that a daphnia can last using stored energy reserves before death occurs
  energy-acquired                     ; the amount of energy that is aquired by a daphnia per day based on logistic equations for env. conditions
  age                                 ; age of the daphnia in days
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  BEGIN SETUP PROCEDURE  ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
   bitmap:export bitmap:from-view "Screenshot"                                       ; takes a screenshot of the view, bitmap file named Screenshot, quality of image is better this way.
  ca
  set second 0
  set minute 0
  set hour 0
  set day 1
  set minx 0 ; Left. Setting NetLogo extent.
  set maxx 249 ; Right
  set miny 0 ; Bottom
  set maxy 349 ; Top
  set-default-shape turtles "bug"
  set daphnia turtles
  crt num-daphnia 
  ask daphnia [set color brown set comfort-level 10 set light-exposure 0 set chemical-exposure 0 set temperature-exposure 0 set myID self set prob 0
   setxy random-xcor random-ycor     ; position the turtles randomly  
    set size 5 set start-patch patch-here set start-patch-id id set identity 0 set total-dist 0 set sex "F"
   
    set energy-reserves random max-energy-reserves                                                                 ; allows energy reserves to vary among individuals at initialization
    set energy-acquired random-float (energy-gain) ]                                                               ; allows energy aquired to vary among individuals at initialization
  set q 0.4                                                                                                        ; sets the threshold probability for moving or not from one patch to another
   
 
  if setup-experiment = "light" [set experiment-selection 1 ]                                                      ; used to select which experiment to run at setup
  if setup-experiment = "chemical" [set experiment-selection 2 ] 
  if setup-experiment = "temperature" [set experiment-selection 3 ] 
  
 if experiment-selection = 1 and second = light-start-time [
  ifelse light-condition = True[
 ask patches [
  set light-level (pycor / max-pycor * 6750)
   set pcolor scale-color yellow light-level 730 6750 ]][ask patches [set light-level (0) set pcolor black]]]      ; setting up environmental light conditions
    
 if experiment-selection = 2 and second = chemical-source-start-time [
  ifelse chemical-condition = True[
 ask patches [
  set chemical-level (pycor / max-pycor * 100)
  
   set pcolor scale-color green chemical-level 0 100 ]][ask patches [set chemical-level (0) set pcolor black]]]      ; setting up environmental chemical conditions

  if experiment-selection = 3 and second = temperature-start-time [
  ifelse temperature-condition = True[
 ask patches [
  set temperature-level (pycor / max-pycor * 100)
  
   set pcolor scale-color red temperature-level 0 100 ]][ask patches [set temperature-level (0) set pcolor black]]] ; setting up environmental temperature conditions

    
  reset-ticks
  
  
  
  
movie-start "out.mov"
movie-set-frame-rate 5
movie-grab-view ;; show the initial state
repeat 150
[go movie-grab-view ]
movie-close        


        
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  START GO PROCEDURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
   ;bitmap:export bitmap:from-view "Screenshot"
   tick
   counter 
ask patches [light-duration-counter chemical-duration-counter temperature-duration-counter]
   ask daphnia [ move? daphnia-ageing ]  ; movement of turtles 
  update-daphnia
  harvest-daphnia
  
  if day > days-to-simulate [stop]
  if daphnia = 0 [stop]   
  
  setup-reproduction
  
           
  ;diffuse light 0.5         ; rate of light penetration
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  END GO PROCEDURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to update-daphnia
  ask daphnia 
  [     
    daphnia-mortality light-exposure-counter chemical-exposure-counter temperature-exposure-counter
    
    ifelse transgene-upregulate-growth-factor = True and mark = 7 [set size (size + 1)][set size size]
   
    
  ]                                   ; ask each individual daphnia to move and age accordingly                                                                                         
end

to daphnia-mortality; begin mortality procedure

  if energy-reserves <= 0 and energy-balance <= 0 [ 
     set age-at-death age 
     set color 5 
     stamp die!
     ]                                                                                                                                       ; if daphnia have a 0 energy balance then they die
  
  if age > max-age [                                                                                                                          ;We are assuming age is correlated with size. A maximum size class of 320 to 325 mm was imposed to reflect the largest size that any daphnia would be likely to attain (Kennedy et al. 1996; Vølstad et al. 2007).                  
     set age-at-death age 
     set color 5 
     stamp die!
     ]                    
 let rand-num random-float 1                                                             ; for counter to keep track of the number of days a.k.a. time
 if age >= 0
  [
  
    ifelse tox < tox1 and tox-duration < 12 and rand-num <= tox1-probability[die!!!-tox]                                  ; defining toxicity and mortality relationship, as well as the effect of duration of toxin exposure                                                            
           [if tox < tox1 and tox-duration >= 12 and rand-num <= tox1-probabilityb[die!!!-tox]] 
    ifelse tox >= tox1 and tox <= tox2 and tox-duration < 12 and rand-num <= tox2-probability[die!!!-tox]
           [if tox >= tox1 and tox <= tox2 and tox-duration >= 12 and rand-num <= tox2-probabilityb[die!!!-tox]]                                                         
    
    ifelse tox > tox2 and tox <= tox3 and tox-duration < 12 and rand-num <= tox3-probability[die!!!-tox]                                                        
           [if tox > tox2 and tox <= tox3 and tox-duration >= 12 and rand-num <= tox3-probabilityb[die!!!-tox]]  
    ifelse tox > tox3 and tox <= tox4 and tox-duration < 12 and rand-num <= tox4-probability[die!!!-tox]
           [if tox > tox3 and tox <= tox4 and tox-duration >= 12 and rand-num <= tox4-probabilityb[die!!!-tox]]                                                          
    
    ifelse tox > tox4 and tox <= tox5 and tox-duration < 12 and rand-num <= tox5-probability[die!!!-tox]  
           [if tox > tox4 and tox <= tox5 and tox-duration >= 12 and rand-num <= tox5-probabilityb[die!!!-tox]]  
    ifelse tox > tox5 and tox-duration < 12 and rand-num <= tox6-probability[die!!!-tox]
           [if tox > tox5 and tox-duration >= 12 and rand-num <= tox6-probabilityb[die!!!-tox]]
    
    ifelse temperature <= Temp1 and temperature-duration < 7 and rand-num <= Temp1-probability[die!!!!-Temperature]                 ; defining temperature and mortality relationship, as well as the effect of duration of temperature exposure                                          
           [ifelse temperature <= Temp1 and temperature-duration >= 7 and rand-num <= Temp1-probabilityb[die!!!!-Temperature]
             [if temperature > Temp1 and temperature <= Temp2 and rand-num <= Temp2-probability[die!!!!-Temperature]]]                                  
    ifelse temperature > Temp2 and temperature <= Temp3 and rand-num <= Temp3-probability[die!!!!-Temperature]                                
           [if temperature > Temp3 and temperature <= Temp4 and rand-num <= Temp4-probability[die!!!!-Temperature]]                                 
    ifelse temperature > Temp4 and temperature <= Temp5 and temperature-duration < 7 and rand-num <= Temp5-probability[die!!!!-Temperature] 
           [ifelse temperature > Temp4 and temperature <= Temp5 and temperature-duration >= 7 and rand-num <= Temp5-probabilityb[die!!!!-Temperature]
             [if temperature > Temp5 and rand-num <= Temp6-probability[die!!!!-Temperature]]]]
  end
  
  to harvest-daphnia ; begin to harvest daphnia or not to harvest daphnia
   
    if harvest-daphnia? = TRUE and harvest-day = day and harvest-minute = minute and harvest-second = second [
        ask daphnia with [size = 1 or size = 2 or size > 5 ] [die!-harvest]
        ]
  
end ; end harvest daphnia
                                  



to die! ; begin to die procedure (for determining stats of all dead daphnia)
set color 5
stamp
  set dead dead + 1                                                                                                                                      ; a daphnia runs this;; the daphnia contributes to the statistics, then dies.                                                                                                                                                         ;; later, we can divide total-age-at-death by dead to get mean-age-at-death
  die
end ; end to die procedure

to die!!!-tox ; begin to die!!! procedure (for determining stats of only TSS death induced dead daphnia)
set color 5
stamp 
  set dead!!!-tox dead!!!-tox + 1                                                                                                                        ; a daphnia runs this;; the daphnia contributes to the statistics, then dies.                                                                                                                                                         ;; later, we can divide total-age-at-death by dead to get mean-age-at-death
  die
end  ; end to die!!! procedure
  
to die!!!!-Temperature ; begin to die!!!! procedure (for determining stats of only Temperature death induced dead daphnia)                               
set color 5
stamp 
  set dead!!!!-Temperature dead!!!!-Temperature + 1                                                                                                      ; a daphnia runs this;; the daphnia contributes to the statistics, then dies.                                                                                                                                                         ;; later, we can divide total-age-at-death by dead to get mean-age-at-death
  die
end  ; end to die!!!! procedure

to die!-harvest ; begin to die from harvest procedure (for determining stats of all dead daphnia)
set color 5
  set dead-harvest dead-harvest + 1                                                                                                                                      ; a daphnia runs this;; the daphnia contributes to the statistics, then dies.                                                                                                                                                         ;; later, we can divide total-age-at-death by dead to get mean-age-at-death
  die
end ; end to die harvest procedure
to setup-reproduction ; begin "setup-reproduction.nls"
                                            
  ifelse day = spawn-day and minute = spawn-minute and second = spawn-second [set spawn 1][set spawn 0];setting up the reproduction variable to distinguish from no event versus reproduction events on given days
  if spawn = 1 
 
 [ask daphnia [ set prob random-float 1 hatch random 4 [set size 1 set shape "bug" set chemical-exposure 0 set temperature-exposure 0 move-to one-of neighbors  
      
 ifelse experiment-selection = 1 [ifelse light-exposure >= 10 [ifelse prob < 0.9 [set sex "F"] [set sex "M"]]
 [ifelse prob < 0.4 [set sex "M"] [set sex "F"]]]; setting female sex during spawning as "F" when female and "M" when not
      
 [ifelse experiment-selection = 2 [ifelse chemical-exposure >= 10 [ifelse prob < 0.9 [set sex "F"] [set sex "M"]]
[ifelse prob < 0.4 [set sex "M"] [set sex "F"]]];
      
 [if experiment-selection = 3 [ifelse temperature-exposure >= 10 [ifelse prob < 0.9 [set sex "F"] [set sex "M"]]
 [ifelse prob < 0.4 [set sex "M"] [set sex "F"]]]]];    
  if sex = "F" [set color pink - 2] 
  if sex = "M" [set color blue - 2]
       set comfort-level 10 set light-exposure 0 set prob random-float 1 set myID self       
       set start-patch patch-here set start-patch-id id set identity self set total-dist 0 set age 0 set mark 007
        ifelse transgene-upregulate-development-genes = True and mark = 7 [set size (size + 1)][set size size]
        
       ]
 ]]  ;set color brown + 1
end
  
to move? ; move turtles procedure
; ifelse random-float 1 < q [
;   downhill light-level downhill chemical-level downhill temperature-level] ;downhill lightsource fd random 2]
;   [move-to one-of neighbors] ;[move-to one-of neighbors fd random 2]                                                                    ; daphnia will move downward if environmental conditions dictate but if no stimulus then they move to a random neighbor patch
; 
 
 if light-level > 0 or chemical-level > 0 or temperature-level > 0 [
   fd random 3 downhill light-level fd random 3 downhill chemical-level fd random 3 downhill temperature-level] 
 ifelse after-light-off-counter > 1 or after-chemical-off-counter > 1 or after-temperature-off-counter > 1 [fd random 3 uphill pycor move-to one-of neighbors] [fd random -10 move-to one-of neighbors fd random 10 move-to one-of neighbors ]

 
end

to counter ; begin counter procedure 
                
  set second (second + 1)                                                          
  if second = 60 [set minute (minute + 1)] 
  if second = 60 [set second 1]
 if minute = 60 [set hour (hour + 1)] ; define the number of days in a year
  if minute = 60 [set minute 1]
  if hour = 24 [set day (day + 1)]  
   if hour = 24 [set hour 1] 
  
  if experiment-selection = 1 and ticks = light-start-time [
  ifelse light-condition = True[
 ask patches [
  set light-level (pycor / max-pycor * 6750)
   set pcolor scale-color yellow light-level 730 6750 ]][ask patches [set light-level (0) set pcolor black]]]
      ask patches [if light-counter = light-duration-time [set light-level (0) set pcolor black]]

  
   if experiment-selection = 2 and ticks = chemical-source-start-time [
  ifelse chemical-condition = True[
 ask patches [
  set chemical-level (pycor / max-pycor * 100)
  
   set pcolor scale-color green chemical-level 0 100 ]][ask patches [set chemical-level (0) set pcolor black]]]
  ask patches [if chemical-counter = chemical-duration-time [set chemical-level (0) set pcolor black]]
  
   if experiment-selection = 3 and ticks = temperature-start-time [
  ifelse temperature-condition = True[
 ask patches [
  set temperature-level (pycor / max-pycor * 100)
  
   set pcolor scale-color red temperature-level 0 100 ]][ask patches [set temperature-level (0) set pcolor black]]]
  ask patches [if temperature-counter = temperature-duration-time [set temperature-level (0) set pcolor black]]
  
 end ; end of counter

to daphnia-ageing ; begin ageing procedure                                                         ; ages the daphnia                                                              
   
   if second > 0 [
     set age (age + 1)
     ]
     
    
end ; end of ageing

to light-duration-counter; begin light-duration counter procedure 
  
 ifelse light-condition = True and light-level > 0 [set light-counter (light-counter + 1)] [set light-counter 0]
   if light-counter = light-duration-time [set after-light-off-stamp  (light-duration-time + 1)]
  if light-counter = light-duration-time [set after-light-off-limit after-light-off-stamp]
  ifelse after-light-off-counter < (after-light-off-limit * 2) [set after-light-off-counter ticks + 1][set after-light-off-counter 0]
 
  end ; end of light-duration counter

to chemical-duration-counter; begin tox-duration counter procedure 
  
  ifelse chemical-condition = True and chemical-level > 0 [set chemical-counter (chemical-counter + 1)] [set chemical-counter 0]
   if chemical-counter = chemical-duration-time [set after-chemical-off-stamp  (chemical-duration-time + 1)]
  if chemical-counter = chemical-duration-time [set after-chemical-off-limit after-chemical-off-stamp]
  ifelse after-chemical-off-counter < (after-chemical-off-limit * 2) [set after-chemical-off-counter ticks + 1][set after-chemical-off-counter 0] 
  
  end ; end of tox-duration counter

to temperature-duration-counter; begin temperature-duration counter procedure 
  
  ifelse temperature-condition = True and temperature-level > 0 [set temperature-counter (temperature-counter + 1)] [set temperature-counter 0]
   if temperature-counter = temperature-duration-time [set after-temperature-off-stamp  (temperature-duration-time + 1)]
  if temperature-counter = temperature-duration-time [set after-temperature-off-limit after-temperature-off-stamp]
  ifelse after-temperature-off-counter < (after-temperature-off-limit * 2) [set after-temperature-off-counter ticks + 1][set after-temperature-off-counter 0] 
  
  end ; end of temperature-duration counter


to light-exposure-counter; begin light exposure counter for Daphnia
if light-condition = True and light-level > 0 [set light-exposure  (light-exposure  + 1)] 

end; end light exposure counter for Daphnia


to chemical-exposure-counter; begin chemical exposure counter for Daphnia
if chemical-condition = True and chemical-level > 0 [set chemical-exposure  (chemical-exposure  + 1)] 

end; end chemical exposure counter for Daphnia


to temperature-exposure-counter; begin temperature exposure counter for Daphnia
if temperature-condition = True and temperature-level > 0 [set temperature-exposure  (temperature-exposure  + 1)] 

end; end temperature exposure counter for Daphnia



@#$#@#$#@
GRAPHICS-WINDOW
288
16
910
904
-1
-1
2.45
1
10
1
1
1
0
0
0
1
0
249
0
349
1
1
1
ticks
30.0

SLIDER
7
36
242
69
num-daphnia
num-daphnia
1
100
12
1
1
NIL
HORIZONTAL

BUTTON
51
84
121
118
setup
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
133
84
202
118
go
go
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
96
136
159
169
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
72
308
205
341
light-condition
light-condition
0
1
-1000

INPUTBOX
140
346
240
406
light-duration-time
50
1
0
Number

INPUTBOX
51
346
136
406
light-start-time
10
1
0
Number

INPUTBOX
92
231
182
291
days-to-simulate
19
1
0
Number

SWITCH
72
423
209
456
chemical-condition
chemical-condition
1
1
-1000

INPUTBOX
13
461
151
521
chemical-source-start-time
10
1
0
Number

TEXTBOX
1260
306
1545
423
Ant farm dimensions: Height = 350 mm\nWidth = 250 mm\n\nWhat about ports, need to change to accessible dimensions of Height = 350 mm and Width = 170 mm only?\n\nOne port on right, 2 cm from bottom\nTwo ports on top (left and right sides), 2 cm from top
11
0.0
1

TEXTBOX
953
248
1204
402
Light (lux)\n\ny = distance from water surface (cm)\nx = Percent of water surface light\n\ny = -14.79ln(x) - 0.4659\nR^2 = 0.9971\n\nWater surface: 0 cm = 6750 lux\nMid: 16.5 cm = 2000 lux\nBottom: 33 cm = 730 lux
11
0.0
1

SWITCH
51
540
211
573
temperature-condition
temperature-condition
1
1
-1000

INPUTBOX
20
578
136
638
temperature-start-time
10
1
0
Number

CHOOSER
1
182
270
227
setup-experiment
setup-experiment
"light" "chemical" "temperature"
0

MONITOR
918
10
977
55
Second
second
17
1
11

MONITOR
980
10
1037
55
Minute
minute
17
1
11

MONITOR
1040
10
1097
55
Hour
hour
17
1
11

MONITOR
1100
10
1157
55
Day
day
17
1
11

INPUTBOX
155
461
280
521
chemical-duration-time
50
1
0
Number

INPUTBOX
140
578
276
638
temperature-duration-time
50
1
0
Number

SLIDER
956
429
1130
462
max-energy-reserves
max-energy-reserves
0
15
10.5
.1
1
NIL
HORIZONTAL

SLIDER
956
473
1128
506
energy-gain
energy-gain
0
10
2.8
.1
1
NIL
HORIZONTAL

SLIDER
958
516
1130
549
energy-expenditure
energy-expenditure
0
10
1.2
.1
1
NIL
HORIZONTAL

SLIDER
958
558
1130
591
max-age
max-age
0
1000000
100000
1
1
NIL
HORIZONTAL

TEXTBOX
32
1003
589
1059
if tox < tox1 and tox-duration < 7 and age >= 0 and age < 100 and rand-num <= probability1 then die 
11
0.0
1

TEXTBOX
36
1095
571
1151
if tox < tox1 and tox-duration >= 7 and age >= 0 and age < 100 and rand-num <= probability1b then die
11
0.0
1

INPUTBOX
352
1029
439
1089
tox1-probability
2.0E-4
1
0
Number

INPUTBOX
350
1121
442
1181
tox1-probabilityb
2.0E-4
1
0
Number

TEXTBOX
27
1204
639
1260
if tox >= tox1 and tox <= tox2 and tox-duration < 12 and age >= 0 and age < 100 and rand-num <= probability2 then die 
11
0.0
1

INPUTBOX
353
1229
438
1289
tox2-probability
2.0E-4
1
0
Number

TEXTBOX
17
1304
676
1360
if tox >= tox1 and tox <= tox2 and tox-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability2b then die 
11
0.0
1

INPUTBOX
350
1329
443
1389
tox2-probabilityb
2.0E-4
1
0
Number

TEXTBOX
28
1403
638
1473
if tox > tox2 and tox <= tox3 and tox-duration < 12 and age >= 0 and age < 100 and rand-num <= probability3 then die
11
0.0
1

TEXTBOX
26
1512
655
1582
if tox > tox2 and tox <= tox3 and tox-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability3b then die 
11
0.0
1

INPUTBOX
356
1431
443
1491
tox3-probability
2.0E-4
1
0
Number

INPUTBOX
355
1543
446
1603
tox3-probabilityb
2.0E-4
1
0
Number

TEXTBOX
26
1620
620
1690
if tox > tox3 and tox <= tox4 and tox-duration < 12 and age >= 0 and age < 100 and rand-num <= probability4 then die
11
0.0
1

TEXTBOX
22
1733
634
1803
if tox > tox3 and tox <= tox4 and tox-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability4b then die
11
0.0
1

INPUTBOX
356
1650
443
1710
tox4-probability
2.0E-4
1
0
Number

INPUTBOX
353
1761
444
1821
tox4-probabilityb
0.0010
1
0
Number

TEXTBOX
28
1838
644
1908
if tox > tox4 and tox <= tox5 and tox-duration < 12 and age >= 0 and age < 100 and rand-num <= probability5 then die
11
0.0
1

TEXTBOX
27
1953
633
2023
if tox > tox4 and tox <= tox5 and tox-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability5b then die
11
0.0
1

INPUTBOX
351
1865
438
1925
tox5-probability
0.0010
1
0
Number

INPUTBOX
344
1987
439
2047
tox5-probabilityb
0.0010
1
0
Number

TEXTBOX
653
1006
1193
1076
if Temp < Temp1 and Temp-duration < 7 and age >= 0 and age < 100 and rand-num <= probability1 then die 
11
0.0
1

TEXTBOX
653
1099
1204
1169
if Temp < Temp1 and Temp-duration >= 7 and age >= 0 and age < 100 and rand-num <= probability1b then die
11
0.0
1

INPUTBOX
968
1032
1069
1092
Temp1-probability
1.0E-4
1
0
Number

INPUTBOX
967
1123
1073
1183
Temp1-probabilityb
1.0E-4
1
0
Number

TEXTBOX
653
1197
1304
1267
if Temp >= Temp1 and tox <= Temp2 and Temp-duration < 12 and age >= 0 and age < 100 and rand-num <= probability2 then die 
11
0.0
1

INPUTBOX
966
1224
1074
1284
Temp2-probability
1.0E-4
1
0
Number

TEXTBOX
654
1307
1319
1377
if Temp >= Temp1 and Temp <= Temp2 and Temp-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability2b then die
11
0.0
1

INPUTBOX
968
1331
1075
1391
Temp2-probabilityb
5.0E-4
1
0
Number

TEXTBOX
653
1411
1304
1481
if Temp > Temp2 and Temp <= Temp3 and Temp-duration < 12 and age >= 0 and age < 100 and rand-num <= probability3 then die
11
0.0
1

INPUTBOX
972
1442
1075
1502
Temp3-probability
1.0E-4
1
0
Number

TEXTBOX
651
1520
1306
1590
if Temp > Temp2 and Temp <= Temp3 and Temp-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability3b then die 
11
0.0
1

INPUTBOX
973
1547
1080
1607
Temp3-probabilityb
1.0E-4
1
0
Number

TEXTBOX
651
1632
1295
1702
if Temp > Temp3 and Temp <= Temp4 and Temp-duration < 12 and age >= 0 and age < 100 and rand-num <= probability4 then die
11
0.0
1

INPUTBOX
977
1660
1078
1720
Temp4-probability
1.0E-4
1
0
Number

TEXTBOX
649
1750
1307
1820
if Temp > Temp3 and Temp <= Temp4 and Temp-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability4b then die
11
0.0
1

INPUTBOX
978
1781
1084
1841
Temp4-probabilityb
1.0E-4
1
0
Number

TEXTBOX
647
1854
1294
1924
if Temp > Temp4 and Temp <= Temp5 and Temp-duration < 12 and age >= 0 and age < 100 and rand-num <= probability5 then die
11
0.0
1

TEXTBOX
646
1973
1302
2043
if Temp > Temp4 and Temp <= Temp5 and Temp-duration >= 12 and age >= 0 and age < 100 and rand-num <= probability5b then die
11
0.0
1

INPUTBOX
982
1881
1085
1941
Temp5-probability
0.015
1
0
Number

INPUTBOX
984
1999
1091
2059
Temp5-probabilityb
0.01
1
0
Number

TEXTBOX
718
2082
1074
2100
if Temp > Temp5 and age >= 0 and rand-num <= probability6 then die
11
0.0
1

INPUTBOX
987
2104
1090
2164
Temp6-probability
0.2
1
0
Number

INPUTBOX
351
2093
439
2153
tox6-probability
0.0050
1
0
Number

INPUTBOX
348
2210
443
2270
tox6-probabilityb
0.0010
1
0
Number

TEXTBOX
112
2067
523
2137
if tox > tox5 and tox-duration < 12 and rand-num <= tox6-probability then die\n\n
11
0.0
1

TEXTBOX
109
2177
522
2219
if tox > tox5 and tox-duration >= 12 and rand-num <= tox6-probabilityb then die
11
0.0
1

SLIDER
99
1036
271
1069
tox1
tox1
0
10
5
1
1
NIL
HORIZONTAL

SLIDER
102
1240
274
1273
tox2
tox2
0
15
10
1
1
NIL
HORIZONTAL

SLIDER
101
1444
273
1477
tox3
tox3
0
25
20
1
1
NIL
HORIZONTAL

SLIDER
106
1672
278
1705
tox4
tox4
0
30
25
1
1
NIL
HORIZONTAL

SLIDER
108
1880
280
1913
tox5
tox5
0
40
30
1
1
NIL
HORIZONTAL

SLIDER
726
1043
898
1076
Temp1
Temp1
0
10
4
1
1
NIL
HORIZONTAL

SLIDER
732
1237
904
1270
Temp2
Temp2
0
10
8
1
1
NIL
HORIZONTAL

SLIDER
733
1451
905
1484
Temp3
Temp3
0
15
10
1
1
NIL
HORIZONTAL

SLIDER
748
1674
920
1707
Temp4
Temp4
0
25
20
1
1
NIL
HORIZONTAL

SLIDER
752
1892
924
1925
Temp5
Temp5
0
40
32
1
1
NIL
HORIZONTAL

SWITCH
1182
42
1318
75
harvest-daphnia?
harvest-daphnia?
1
1
-1000

INPUTBOX
1233
85
1302
145
harvest-day
1
1
0
Number

INPUTBOX
1230
154
1313
214
harvest-minute
1
1
0
Number

INPUTBOX
1227
228
1382
288
harvest-second
20
1
0
Number

INPUTBOX
1181
328
1246
388
spawn-day
1
1
0
Number

INPUTBOX
1177
396
1254
456
spawn-minute
1
1
0
Number

INPUTBOX
1178
465
1257
525
spawn-second
8
1
0
Number

MONITOR
941
654
1077
699
after-light-off-counter
after-light-off-counter
17
1
11

MONITOR
943
705
1070
750
after-light-off-stamp
after-light-off-stamp
17
1
11

MONITOR
943
753
1057
798
after-light-off-limit
after-light-off-limit
17
1
11

MONITOR
953
810
1010
855
tester
tester
17
1
11

MONITOR
1116
655
1255
700
after-chemical-off-counter
after-chemical-off-counter
17
1
11

MONITOR
1283
655
1446
700
after-temperature-off-counter
after-temperature-off-counter
17
1
11

MONITOR
1119
705
1253
750
after-chemical-off-stamp
after-chemical-off-stamp
17
1
11

MONITOR
1290
705
1442
750
after-temperature-off-stamp
after-temperature-off-stamp
17
1
11

MONITOR
1124
754
1250
799
after-chemical-off-limit
after-chemical-off-limit
17
1
11

MONITOR
1297
753
1436
798
after-temperature-off-limit
after-temperature-off-limit
17
1
11

SWITCH
1164
528
1389
561
transgene-upregulate-growth-factor
transgene-upregulate-growth-factor
1
1
-1000

SWITCH
1176
586
1466
619
transgene-upregulate-development-genes
transgene-upregulate-development-genes
0
1
-1000

PLOT
921
66
1121
216
Number of Daphnia
NIL
NIL
0.0
10.0
0.0
40.0
true
true
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot count turtles"
"Female" 1.0 0 -2064490 true "" "plot count turtles with [sex = \"F\"]"
"Male" 1.0 0 -13791810 true "" "plot count turtles with [sex = \"M\"]"

@#$#@#$#@
## WHAT IS IT?


## HOW IT WORKS


## HOW TO USE IT


## THINGS TO NOTICE



## THINGS TO TRY

## EXTENDING THE MODEL


## NETLOGO FEATURES


## RELATED MODELS




## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (1997).  NetLogo Diffusion Graphics model.  http://ccl.northwestern.edu/netlogo/models/DiffusionGraphics.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.
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
3
Circle -6459832 true true 81 182 108
Circle -6459832 true true 110 127 80
Circle -6459832 true true 95 75 80
Line -1184463 false 120 85 60 90
Line -1184463 false 120 270 90 285
Line -1184463 false 120 90 60 105
Line -1184463 false 120 270 75 285
Line -1184463 false 60 105 45 120
Line -1184463 false 60 90 45 105

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
NetLogo 5.1.0
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
