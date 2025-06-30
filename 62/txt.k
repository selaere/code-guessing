#!/bin/awk /aw -ec/{system("stty raw -echo;k "ARGV[1]" $(stty size) "ARGV[2]";stty sane")}
(h;w):.'2#x; t:(~#:){,""}/0:fd:<`$fn:$[2=#x;`argv 1;x 2] /height;width, t:text(lines)
fcur:cur:scr:0 0; sel:0N 0N; clip:,"" /(fake)cursor, scroll, first selected, clipboard
CS:0x1b5b; CL:CS/" "\" H 2J"; (LI;TX;SE;BO):CS,/:" "\"37;100m 97;40m 90;47m 44m" /colors
foot:foot0:"^F Find Next  ^XCV Clipboard  ^E Eval  ^S Save  ^Q Quit" /footer
place:{[pos;str;a] $[~(0;h-1)'n:*pos-scr; a[n]:?[a[n];0|(w-4)&(pos-scr)1;str];]; a}
disp:{r:4$(4>#:)(4$-3$)//:$'1+no:scr[0]+!# m:(w-4)$scr[1]_/:((h-1)&#a)#a:scr[0]_t
 $[^*sel;s:!0;[(sa;sz):s:x@<x:(sel;cur); m:place[sa;SE]place[sz;TX]m]] /display selection
 `1:CL; `0:LI,/:r,'(TX;SE)[~(*'s)'no-1],'m,\:"\r"; f:"editing ",fn," at ",":"/$'1+cur
 `1:BO,(f,(-w-#f)$foot),CS,(";"/$'1 5+cur-scr),"H"} /r:ruler, m:main
read:{(sa;sz):sord`;$[^*sel;,t[*cur]; ~*sz-sa; ,(sz-sa)[1]#sa[1]_t[*sa] /selected lines
                      (,sa[1]_t[*sa]),((*sz-1+sa)#(1+*sa)_t),,sz[1]#t[*sz]]}
type:{(sa;sz):sord`;a:$[2>#x;,(sa[1]#t[*sa])    ,(    *x)       ,sz[1]_t@*sz /write lines
                            (,(sa[1]#t[*sa]),*x),(-1_1_x),,(*|x),sz[1]_t@*sz]
 t:: ?[t;(*sa;1+*sz);a]; desel (sa[0]+-1+#x;(sa[1]*2>#x)+#*|x)}; end:{l,#t@l:-1+#t};
sord:{a@<a:(cur^'sel;cur)}; desel:{sel::0N 0N;x}; up:{x*~0>*x}; dn:{~x[0]<#t}end/; /^v oob
sft:{ac[y]:{[f;x] $[x;;sel::cur];f 0}ac x}; scroll:{scr[0]:((#t)--2!h)&0|x+*scr;cur+x,0}
ac:(,"")!,0N; other:{[x;s] type@,(~0x1f<*x)`k/x}; /ac[key][selected?]>new cur, otherwise
ac[CS,"A"]:{x desel/up fcur-1 0}; ac[CS,"B"]:{x desel/dn fcur+1 0} /Up Down
ac[CS,"C"]:{{x[1]>#t@*x}{dn(1+*x;0)}/cur+0 1},{desel sord[] 1}     /Right
ac[CS,"D"]:{{0>x 1}{up a,#t@a:-1+*x}/cur-0 1},{desel sord[] 0}     /Left
ac[,0x13]:{fd 1:"\n"/t;>fd;fd::<`$fn;cur}; ac[,0x11]:{>fd;`1:CS,"0m",CL;`exit 0} /^S ^Q
ac[,0x05]:{$[x;type;{t::?[t;1+*cur;x];cur}]@"\n"\(~`C=@:)`k/.[.:;,"\n"/read`;::]} /^E
sprd:{t::@[t;&&(1--)\*'sord`;x]};ac[,"\t"]:{sprd@,[tw#" ";];$[x;sel+:0,tw;];cur+0,tw} /Tab
ac[CS,"Z"]:{sprd{(tw&+/&\x=" ")_x};$[x;sel::0|sel-0,tw;];0|cur-0,tw}; tw:4 /Sft+Tab, width
ac[,0x06]:{lb:&"\n"=tf:"\n"/t;m:(#a:"\n"/aa:read`)(a~)':tf; c:2+sa[1]+lb@-1+*sa:*sord` /^F
 c:c-lb@l:lb'c:$[^n:*&c_m;*&m;c+n];foot::"found ",$+/m;sel::1 -1+l,c;(l+#aa;0|c+-1+#*|aa)}
bs:{$[~+/(l;c):cur;0 0; ~c;[a:(l-1;#t l-1);t[l-1],:t[l];t_:l;a];[t[l]_:c-1;l,c-1]]} /Back
ac[,0x08]:ac[,0x7f]:bs,del:{type@,""};ac[,0x07]:{dn(-1+.,/-1_(|/~"A0"'){1:`}\"0";0)} /^G
ac[CS,"3~"]:{(l;c):cur;:[cur~end`;; c=#t@l;[t[l],:t[l+1];t_:l+1]; t[l]_:c];cur},del /Del
ac[CS,"H"]:{(l;c):cur;l,x*~c=x:+/&\" "=t l};ac[CS,"F"]:{x desel/cur[0],#t cur 0} /Home End
ac[CS,"1;5H"]:{0 0}; ac[CS,"1;5F"]:end; ac[,0x1b]:{desel`;cur}           /^Home ^End Esc
ac[CS,"5~"]:{up x desel/scroll@-h};ac[CS,"6~"]:{dn x desel/scroll h}     /PgUp PgDn
ac[CS,"1;5A"]:{up x desel/scroll -1};ac[CS,"1;5B"]:{dn x desel/scroll 1} /^Up ^Down
wc:,/`c$"0A_a"+!'10 26 1 26; wd:{a 0 1+(a:&^wc?t@*cur)'x} / wc:word chars. v ^Left ^Right
ac[CS,"1;5C"]:{cur[0],(#t@*cur)^wd[cur 1]1}; ac[CS,"1;5D"]:{cur[0],1+-1^wd[-2+cur 1]0}
ac[,"\r"]:{type("";(&\" "=)#t@*cur)};ac[,0x18]:{clip::read`;$[x;del`;[t_:l:*cur;l,0]]} /^X
ac[,0x03]:{clip::read`;cur};ac[,0x16]:{type clip};ac[,0x01]:{sel::0 0;end`} /^C ^V ^A
sft/'CS,/:/:{("1;",/:/:"56",\:/:x),("56",/:\:" "\"~ ;2~"),+1("1;2",)'\x}"ABCDFH" /shift+..
{1}{disp`; foot::foot0; fcur::{(other x)^ac x}[1:`][~^*sel][]; cur::{[l;c] l,c&#t@l}.fcur
 scr::cur&scr|cur-(h;w)-2 5; (cur~sel)desel/` }/`
/
needs ngn/k awk stty. usage: ./txt.k filename(optional). xterm/compatible recommended.
simple. usable. extensible. pick all three. type to a line and press Ctrl+E:
  TX:CS,"30;47m";SE:CS,"97;40m" / light mode
  foot0:"\"just do it and have fun while doing it\" - HelloBoi" / add your favorite quote
  ac[,0x0a]:{."\\eject";cur} / adds a new command in ^J
\
