#!/usr/bin/env swipl
p(eo,[],[],[]).
p(D,[D|X],X,[]).
p(D,[' '|X],Z,B):-p(D,X,Z,B).
p(D,['['|X],Z,[A|As]):-p('|',X,X1,C),p(']',X1,X2,B),p(D,X2,Z,As),lo(C,B,A).
p(D,[#|X],Z,[push(N)|As]):-pl(X,X1,N,0),p(D,X1,Z,As).
p(D,[+|X],Z,[add(N) |As]):-pl(X,X1,N,1),p(D,X1,Z,As).
p(D,[A|X],Z,[A|As]):-p(D,X,Z,As).
p(X,A):-p(eo,X,[],A).

pl(X,Z,N):-pl(X,Z,N,0).
pl([+|X],Z,N,N0):-N1 is N0+1,pl(X,Z,N,N1).
pl(X,X,N,N).

lo([push(0)],_,pop).
lo([push(N)],[],pop):-N\=0.
lo([push(N)],[add(M)],aff(M)):-N\=0.
lo([push(N)],B,for(B)):-N\=0.
lo(C,B,loop(C,B)).

i([],S,S).
i([A|As],S,S2):-i(A,S,S1),i(As,S1,S2).
i(add(N),[S|Ss]+M,[T|Ss]+M):-T is S+N.
i(add(N),[]+M,[N]+M).
i(push(N),S+M,[N|S]+M).
i(pop,[_|Ss]+M,Ss+M).
i(pop,[]+M,[]+M).
i(aff(_),[ ]+M,[]+M).
i(aff(N),[B]+M,[T]+M):-T is N*B.
i(aff(N),[B,A|Ss]+M,[T|Ss]+M):-T is A+N*B.
i(for(_),[0|Ss]+M,Ss+M).
i(for(_),[]+M,[]+M).
i(for(B),[I|S]+M,Sf):-I\=0,i(B,S+M,S1+M1),I2 is I-1,i(for(B),[I2|S1]+M1,Sf).
i(loop(C,_),[]+M,Sf):-i(C,[]+M,Sf).
i(loop(C,B),[I|Ss]+M,Sf):-i(C,Ss+M,S1_+M1),(S1_=[]->[]+M1=Sf;S1_=[L|S1],
  ((I=0;L=0)->S1+M1=Sf;i(B,S1+M1,S2+M2),I2 is I-1,i(loop(C,B),[I2|S2]+M2,Sf))).
i(@,[]+M,[B]+M):-g(M,0,B).
i(@,[A|Ss]+M,[B|Ss]+M):-g(M,A,B).
i(!,[]+M,[]+M2):-i(!,[0]+M,[]+M2).
i(!,[A]+M,[]+M2):-i(!,[A,0]+M,[]+M2).
i(!,[A,B|Ss]+M,Ss+M2):-s(M,A,B,M1),!,M1=M2.
i(?,[]+M,[]+M).
i(?,[A|Ss]+M/O,[B|Ss]+M/O1):-O1 is O*(A+1),between(0,A,B).

gg(a(A),_,A).
gg(a(L,_,B),N,V):-N/\B=:=0,gg(L,N,V).
gg(a(_,R,B),N,V):-N/\B=\=0,gg(R,N,V).
ss(a(_),_,V,a(V)).
ss(a(L,R,B),N,V,a(A,R,B)):-N/\B=:=0,ss(L,N,V,A).
ss(a(L,R,B),N,V,a(L,A,B)):-N/\B=\=0,ss(R,N,V,A).
s(a(L,R,B),N,V,A):-N< B<<1,ss(a(L,R,B),N,V,A).
s(a(L,R,B),N,V,A):-N>=B<<1,B1 is B<<1,e(B,R1),s(a(a(L,R,B),R1,B1),N,V,A).
s(A/O,N,V,B/O):-s(A,N,V,B).
g(a(L,R,B),N,V):-N< B<<1,gg(a(L,R,B),N,V).
g(a(_,_,B),N,0):-N>=B<<1.
g(A/_,N,V):-g(A,N,V).

e(0,a(0)).
e(N,a(L,R,N)):-N1 is N>>1,e(N1,L),e(N1,R).

t([],[]).
t([[S|_]+_/O|X],[t(S,N)|Y]):-N is 1 rdiv O,t(X,Y).
t([[]   +_/O|X],[t(0,N)|Y]):-N is 1 rdiv O,t(X,Y).

c([t(S,A)],[A-S]).
c([t(S,A),t(S,B)|As],Z):-C is A+B,c([t(S,C)|As],Z).
c([t(S,A),t(T,B)|As],[A-S|Z]):-S\=T,c([t(T,B)|As],Z).

o([]).
o([S-A|X]):-format('~t~2f~5+% ~t~d~5+~n',[S*100,A]),o(X).

:-initialization(main,main).
main([A|_]):-
  atom_chars(A,B),p(B,C),!,%writeln(C),
  e(1,M),bagof(D,i(C,[]+M/1,D),E),!,
  t(E,F),msort(F,G),c(G,H),msort(H,I),o(I).
