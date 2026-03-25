$title  Basic CGE Model 1.0

*----------------------------------------------------------------------------------------------------
*This is a simple single-region, single-sector, two-factor, close-economy CGE model.
*The firm maximizes its profit subjected to constant return-to-scale CES technology.
*The households exhaust its income (no savings),
*and maximize its utility (following a log function) subjected to the budget constraint.
*There are no governments, investments, nor the exports/imports.
*In total, there are three markets: the goods market and two factor markets.
*----------------------------------------------------------------------------------------------------

$offlisting
$eolcom //

*========A.Pre-settings & Options====================================================================

*========B.Input Sets, Parameters & Basedata=========================================================

*--------1.Time framework----------------------------------------------------------------------------
Sets    
    t           time frame      /base, homo, labup, capup, totup/
    t0(t)       base period     /base/
    ts(t)       time Flag
;
ts(t) = no;
Alias   (t,tsim);

display t;

*--------2.Sets Definition---------------------------------------------------------------------------
Sets is SAM accounts    /
    ACT     activity
    LAB     labor
    CAP     capital
    HHD     households
    TOT     row and column sums
/;

*--------3.Alias for Sets----------------------------------------------------------------------------
Alias   (is,js);

*--------4.Pre-provided Parameters-------------------------------------------------------------------
Scalars
    esubt   elasticity of substitution between labor and capital     /1/
;

*--------5.Base Data Read-in-------------------------------------------------------------------------
Table   sam(is,js)  Social accounting matrix
        ACT     LAB     CAP     HHD     TOT
ACT                             117908  117908
LAB     78180                           78180
CAP     39728                           39728
HHD             78180   39728           117908
TOT     117908  78180   39728   117908
;

*========C.Load Model================================================================================

*--------1.Model Variables---------------------------------------------------------------------------
Variables
    L(t)        Quantities of labor
    K(t)        Quantities of capital
    Q(t)        Quantities of goods
    U(t)        Values of households utility
    Y(t)        Values of households income
    W(t)        Price of labor (wages)
    R(t)        Price of capital (rents)
    P(t)        Price of goods
    D(t)        Dummy variable for WALRAS test
;

*--------2.Model Parameters--------------------------------------------------------------------------
Parameters
    alpl(t)     Cost share of labor in production function
    alpk(t)     Cost share of capital in production function
    a(t)        Total factor productivity in production function
    laml(t)     Labor-augmented technical shifter
    lamk(t)     Capital-augmented technical shifter
    lb(t)       Exogenous labor endowment
    kb(t)       Exogenous capital endowment
;

*--------3.Equation Specifications-------------------------------------------------------------------
Equations
    L_eq(t)     Conditional labor demand function
    K_eq(t)     Conditional capital demand function
    Q_eq(t)     Zero-profit -- goods output
    U_eq(t)     Households utility function
    Y_eq(t)     Households income balance
    W_eq(t)     Market clearance -- labor
    R_eq(t)     Market clearance -- capital
    P_eq(t)     Market clearance -- goods
;

L_eq(t)$(ts(t)).. // intermediate calculation -- L
    L(t)    =e= laml(t)**(esubt-1) * alpl(t) * (P(t)/W(t))**esubt * Q(t);
K_eq(t)$(ts(t)).. // intermediate calculation -- K
    K(t)    =e= lamk(t)**(esubt-1) * alpk(t) * (P(t)/R(t))**esubt * Q(t);
Q_eq(t)$(ts(t)).. // zero-profit condition -- Q
    0       =g= (P(t)*a(t) - ((W(t)/laml(t))/alpl(t))**alpl(t) * ((R(t)/lamk(t))/alpk(t))**alpk(t))$(esubt eq 1)
                + (P(t)**(1-esubt) - (alpl(t)*(W(t)/laml(t))**(1-esubt)+alpk(t)*(R(t)/lamk(t))**(1-esubt)))$(esubt ne 1);
U_eq(t)$(ts(t)).. // indicator calculation -- U
    U(t)    =e= log(Q(t));
Y_eq(t)$(ts(t)).. // intermediate calculation -- Y
    Y(t)    =e= W(t)*L(t) + R(t)*K(t);
W_eq(t)$(ts(t)).. // market clearance -- W
    0       =g= L(t) - lb(t);
R_eq(t)$(ts(t)).. // market clearance -- R
    0       =g= K(t) - kb(t);
P_eq(t)$(ts(t)).. // market clearance -- P (dummied because P is set as numeraire)
    D(t)    =e= Y(t)/P(t) - Q(t);

*--------4.Model Specifications----------------------------------------------------------------------
Model   main_model  BA-CGE  /
    L_eq.L, K_eq.K, Q_eq.Q, U_eq.U, Y_eq.Y, W_eq.W, R_eq.R, P_eq.D
/;

main_model.holdfixed   =   1;

*========D.Initialization & Calibration==============================================================
Scalar  vScl    base data scale factor  /1e-3/;

*--------1.Initialize Variables----------------------------------------------------------------------
P.l(t)  =   1;
W.l(t)  =   1;
R.l(t)  =   1;

L.l(t)  =   vScl*sam('lab','act')/W.l(t);
K.l(t)  =   vScl*sam('cap','act')/R.l(t);
Q.l(t)  =   vScl*sam('tot','act')/P.l(t);

U.l(t)  =   log(vScl*sam('act','hhd')/P.l(t));
Y.l(t)  =   vScl*sam('hhd','tot');

display L.l, K.l, Q.l, U.l, Y.l;

*--------2.Calibrate Model Parameters----------------------------------------------------------------
alpl(t) =   (L.l(t)/Q.l(t)) * (W.l(t)/P.l(t))**esubt;
alpk(t) =   (K.l(t)/Q.l(t)) * (R.l(t)/P.l(t))**esubt;
a(t)    =   Q.l(t)/(L.l(t)**alpl(t) * K.l(t)**alpk(t));
laml(t) =   1;
lamk(t) =   1;
lb(t)   =   L.l(t);
kb(t)   =   K.l(t);

display alpl, alpk, a;

*========E.Model Solution============================================================================

*--------1.Fix Exogenous Variables-------------------------------------------------------------------
*!!!Goods price P is set as numeraire
P.fx(t) =   P.l(t);

*--------2.Lower Bounds on Variables-----------------------------------------------------------------
Q.lo(t) =   0;
W.lo(t) =   0;
R.lo(t) =   0;

*--------3.Solve the model for each time period------------------------------------------------------
option limRow = 0, limCol = 0, solprint = off;

loop(tsim,
    ts(tsim) = yes;
*   !!!baseline replication
    if(sameas(tsim,'base'),
        P.fx(tsim)  =   P.l(tsim);
*   !!!price homogeneity check
    elseif(sameas(tsim,'homo')),
        P.fx(tsim)  =   1.5*P.l(tsim);
*   !!!shock simulation -- increase in labor productivity
    elseif(sameas(tsim,'labup')),
        laml(tsim)  =   1.5*laml(tsim);
*   !!!shock simulation -- increase in capital productivity
    elseif(sameas(tsim,'capup')),
        lamk(tsim)  =   1.5*lamk(tsim);
*   !!!shock simulation -- increase in total productivity
    elseif(sameas(tsim,'totup')),
        laml(tsim)  =   1.5*laml(tsim);
        lamk(tsim)  =   1.5*lamk(tsim);
    );
    solve   main_model  using mcp;
    ts(tsim) = no;
);

*========F.Debug Check & Post-sim Analysis===========================================================

*--------1.Post-sim Analysis-------------------------------------------------------------------------
*!!!Calculate percentage changes of variables
Scalar ifBase  if compared with base period   /1/;

Parameters
    lck(t)  Check changes in L
    kck(t)  Check changes in K
    qck(t)  Check changes in Q
    uck(t)  Check changes in U
    yck(t)  Check changes in Y
    pck(t)  Check changes in P
    wck(t)  Check changes in W
    rck(t)  Check changes in R
;

$macro  Check(x,p)\
        p(t)$(x.l('base') and x.l(t-1)) = (100*(x.l(t)-x.l('base'))/x.l('base'))$(ifBase)\
                                          + (100*(x.l(t)-x.l(t-1))/x.l(t-1))$(not ifBase);
Check(L,lck);
Check(K,kck);
Check(Q,qck);
Check(U,uck);
Check(Y,yck);
Check(P,pck);
Check(W,wck);
Check(R,rck);

display pck, wck, rck;
display lck, kck, qck, uck, yck;

display P.l, W.l, R.l;
display L.l, K.l, Q.l, U.l, Y.l, D.l;
$onText
$offText
