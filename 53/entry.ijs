map=:(ucp;._2~LF&=)freads'in.txt'

show=: [:echo*{"0 1 map,"0{.@":"0  NB. show matrices on top of map

NB. point down, right, up, left
'pd pr pu pl'=:p=:map e."_ 1]4 6$ucp'┐│┌┬┤├┌─└├┴┬└│┘┴├┤┘─┐┤┴┬'

assert ((0,pd)-:pu,0), (0,.pr)-:pl,.0  NB. check that lines are well connected

'c1 c2 c3 c4'=:(*"2~1=+/)turns=:(4$pr,:pl)*.2#pd,:pu NB. find possible corners
ci1=:(*+/\&.,)c1                                     NB. give id to every topleft corner

NB. find corresponding corners, gradually removing non-boxes
ci2=:(>./\ "1 ci1)*c2*(-[:>./\ @}:"1 0:,. (pl>pr)*])+/\ "1   c1   NB. top right
ci4=:(>./\    ci2)*c4*(-[:>./\ @}:   0 ,  (pu>pd)*])+/\    *ci2   NB. bot right
ci3=:(>./\."1 ci4)*c3*(-[:>./\.@}."1 0:,.~(pl<pr)*])+/\."1 *ci4   NB. bot left
ci1=:(>./\.   ci3)*c1*(-[:>./\.@}.   0 ,~ (pu<pd)*])+/\.   *ci3   NB. top left

NB. reassign IDs, now that we are sure that these are boxes (this is probably useless)
'i1 i2 i3 i4'=:(0,~.#~,ci1)(#@[|i.)ci1,ci2,ci3,:ci4

NB. check that corners match (this should always work, i think)
assert ((i1,.i2)-:&(+/)i3,.i4), (i1,i3)-:&:(+/"1)i2,i4

echo 'boxes:'
cov=: -&(+/\)|.!.0                     NB. 0 0 2 0 0 0 cov 0 0 0 0 2 0 <--> 0 0 2 2 2 0
show area=:(i1 cov i3)cov"1(i2 cov i4) NB. boxes including borders. print because pretty
inside   =:(i4 cov i2)cov"1(i3 cov i1) NB. i am very happy that this works
border   =:area-inside

assert 1>:(i1 cov&:*i3)cov"1(i2 cov&:*i4) NB. check for no box overlaps
assert -.inside*.+./turns                 NB. check that the boxes are empty
assert border>:1<+/turns                  NB. check all splits are in box borders

NB. remove boxes for pathfinding. "edges" is ed,er,eu,:el where er is "can walk from right"
sidelr=:area+(i2 cov i4)cov"1(i1 cov i3)
sideud=:area+(i3 cov i1)cov"1(i4 cov i2)
edges=:p>4$sidelr,:sideud

NB. l: starting positions of all lines with IDs. lid: map from line ID -> box no
'lid l'=:((#~*)@:,;(*+/\&.,)@:*)border*1<+/turns

echo 'lines (shown for your viewing pleasure):'
connects=:3 :0 i.0 0
while. +./,*l do. show l
    rot=.l,edges*l|.~"2 1+.0j1^i.4                  NB. rot has 5 items: original,rotated d,r,u,l
    y=.y,con=./:~@~.@-.&0"1(#~2<#@~."1),/1 2 0|:rot NB. new connections between different lines
    l=:(*[-.@e.,@con)>./rot                         NB. combine rot, removing connections
end.
/:~"1{&lid<:~.y
)
NB. check no double connections or self-connections between boxes
assert ((-:~.),[:*./~:/"1) connects
echo 'Yes'
