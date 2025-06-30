\ Code by Jia Tan (<https://github.com/JiaT75>)

: pop ( src u -- src' u' c ) 1- swap dup c@ swap char+ -rot ;
: shift ( src u -- src' u' ) 1- swap char+ swap ;

: peek ( src u -- src u c ) over c@ ;
: ?peek ( src u -- src u c ) dup if peek else -1 then ;

: skip-'\' ( src u c -- src u c )
	dup '\' = if drop pop then
;

defer parenthesis
: terminal ( src u -- src u unrch? )
	pop 
	dup '(' = if drop parenthesis else
	dup '[' = if drop shift -1 else
		skip-'\' c, 0 then then
;
: kleene ( src u unrch? -- src u unrch? )
	third c@ '*' = if drop shift 0 then
;

: not-ending? ( src u -- src u continue? )
	dup if peek dup '|' <> swap ')' <> and else 0 then
;
: alternative ( src u -- src u unrch? )
	0 >r begin not-ending? while
		terminal kleene r> or >r
	repeat r>
;

: find-candidate ( src u -- start src u unrch? )
	here -rot  ( keep in stack, in case we need to restore )
	begin
		alternative while ( break if reachable )
		third ->here ( restore string )
		?peek '|' = if shift else -1 exit then
	repeat 0
;
: paren-depth ( c n -- n' )
	over '(' = if 1+ else over ')' = if 1- then then nip
;
: skip-until-')' ( src u -- src' u' )
	1 >r begin 
		dup 0= if exit then ( quit if empty )
		pop skip-'\' r> paren-depth dup >r while
	repeat rdrop
;

:noname ( src u -- src u unrch? )
	find-candidate >r rot drop skip-until-')' r>
; is parenthesis

: recover ( start -- str u ) here over - [ 1 chars ] literal / ;
: generate ( src u -- str u unrch? )
	find-candidate >r 2drop recover r>
;
: deallot ( src u -- ) chars negate allot drop ;
: main ( -- )
	generate if ." *unreachable*" else 2dup type cr then deallot
;

next-arg main bye
