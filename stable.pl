/* Georgios Tsiris, 1115201700173 */

:- set_flag(print_depth,1000).

:- lib(fd).

stable(Marriage) :-
	def_vars(MenVars, WomenVars),
	state_constrs(MenVars, WomenVars),
	labeling(MenVars),
	men(Men),
	marriage_format(Men, MenVars, Marriage).

def_vars(MenVars, WomenVars) :-
	men(Men),
	length(Men, N1),
	length(MenVars, N1),
	women(Women),
	length(Women, N2),
	length(WomenVars, N2),
	N1 == N2,
	MenVars :: Women,
	WomenVars :: Men,
	alldifferent(MenVars),
	alldifferent(WomenVars).

state_constrs(MenVars, WomenVars) :-
	men(Men),
	women(Women),
	man_stability1(Men, MenVars, WomenVars),
	woman_stability1(Women, WomenVars, MenVars),
	compatibility1(Men, MenVars, WomenVars).

man_stability1([], [], _).
man_stability1([Man|Men], [ManVar|MenVars], WomenVars) :-
	prefers(Man, ManPref),
	element(WifeIndex, ManPref, ManVar),
	man_stability2(Man, ManPref, WifeIndex, 1, WomenVars),
	man_stability1(Men, MenVars, WomenVars).

man_stability2(_, [], _, _, _).
man_stability2(Man, [Woman|Women], WifeIndex, WomanIndex, WomenVars) :-
	prefers(Woman, WomanPref),
	women(AllWomen),
	get_woman_var(Woman, AllWomen, WomenVars, WomanVar),
	element(HusbandIndex, WomanPref, WomanVar),
	n_th(ManIndex, WomanPref, Man),
	WifeIndex #> WomanIndex #=> HusbandIndex #< ManIndex,
	NextWomanIndex is WomanIndex + 1,
	man_stability2(Man, Women, WifeIndex, NextWomanIndex, WomenVars).

get_woman_var(Woman, [Woman|_], [WomanVar|_], WomanVar).
get_woman_var(Woman, [CurrentWoman|Women], [_|WomenVars], WomanVar) :-
	CurrentWoman \= Woman,
	get_woman_var(Woman, Women, WomenVars, WomanVar).

n_th(1, [X|_], X).
n_th(Index1, [X|Xs], Y) :-
	X \= Y,
	n_th(Index2, Xs, Y),
	Index1 is Index2 + 1.

woman_stability1([], [], _).
woman_stability1([Woman|Women], [WomanVar|WomenVars], MenVars) :-
	prefers(Woman, WomanPref),
	element(HusbandIndex, WomanPref, WomanVar),
	woman_stability2(Woman, WomanPref, HusbandIndex, 1, MenVars),
	woman_stability1(Women, WomenVars, MenVars).

woman_stability2(_, [], _, _, _).
woman_stability2(Woman, [Man|Men], HusbandIndex, ManIndex, MenVars) :-
	prefers(Man, ManPref),
	men(AllMen),
	get_man_var(Man, AllMen, MenVars, ManVar),
	element(WifeIndex, ManPref, ManVar),
	n_th(WomanIndex, ManPref, Woman),
	HusbandIndex #> ManIndex #=> WifeIndex #< WomanIndex,
	NextManIndex is ManIndex + 1,
	woman_stability2(Woman, Men, HusbandIndex, NextManIndex, MenVars).

get_man_var(Man, [Man|_], [ManVar|_], ManVar).
get_man_var(Man, [CurrentMan|Men], [_|MenVars], ManVar) :-
	CurrentMan \= Man,
	get_man_var(Man, Men, MenVars, ManVar).

compatibility1([], [], _).
compatibility1([Man|Men], [ManVar|MenVars], WomenVars) :-
	women(Women),
	compatibility2(Man, ManVar, Women, WomenVars),
	compatibility1(Men, MenVars, WomenVars).

compatibility2(_, _, [], []).
compatibility2(Man, ManVar, [Woman|Women], [WomanVar|WomenVars]) :-
	ManVar #= Woman #<=> WomanVar #= Man,
	compatibility2(Man, ManVar, Women, WomenVars).

marriage_format([], [], []).
marriage_format([Man|Men], [ManVar|MenVars], Marriage) :-
	marriage_format(Men, MenVars, MarriageAcc),
	append([Man - ManVar], MarriageAcc, Marriage).