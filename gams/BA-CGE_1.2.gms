$title  Basic CGE Model 1.2

*----------------------------------------------------------------------------------------------------
*This is a simple single-region, single-sector, two-factor, close-economy CGE model.
*The firm maximizes its profit subjected to constant return-to-scale CES technology.
*The households allocate a fixed proportion of its income as savings, which turn to investments,
*and then maximize its utility (following a log function) subjected to the budget constraint.
*The government levies a production tax and a direct tax, and uses its income to purchase.
*It may operate with a constant (under FixGovSave) or flexible (under FixGovCons) fiscal surplus.
*There are no exports/imports.
*In total, there are three markets: the goods market & two factor markets.
*----------------------------------------------------------------------------------------------------

$offlisting
$eolcom //

*========A.Pre-settings & Options====================================================================

*--------1.Acronyms----------------------------------------------------------------------------------
Acronyms FixGovSave, FixGovCons;

*--------2.Key Closure Settings----------------------------------------------------------------------
$setGlobal  GovClosure  FixGovCons

*========B.Input Sets, Parameters & Basedata=========================================================

*--------1.Time framework----------------------------------------------------------------------------
Sets    
    t           time frame      /base,homo,labup,capup,totup/
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
    PTX     production tax
    HHD     households
    GOV     governments
    INV     investment-savings
    TOT     row and column sums
/;

*--------3.Alias for Sets----------------------------------------------------------------------------
Alias   (is,js);

*--------4.Pre-provided Parameters-------------------------------------------------------------------
Scalars
    esubt   elasticity of substitution between labor and capital     /1.0/
;

*--------5.Base Data Read-in-------------------------------------------------------------------------
Table   sam(is,js)  Social accounting matrix (billion yuan)
        ACT     LAB     CAP     PTX     HHD     GOV     INV     TOT
ACT                                     57193   17363   43352   117908
LAB     69222                                                   69222
CAP     39728                                                   39728
PTX     8958                                                    8958
HHD             69222   39728                                   108950
GOV                             8958    1413                    10371
INV                                     50343   -6991           43352
TOT     117908  69222   39728   8958    108950  10371   43352    
;

*========C.Load Model================================================================================

*--------1.Model Variables---------------------------------------------------------------------------
Variables
*Production module
    QL(t)       Quantities of labor demand
    QK(t)       Quantities of capital demand
    QA(t)       Quantities of activity output
    PAT(t)      Price of activity output (pre-tax)
    txp(t)      Tax rate on production
*Households module
    QP(t)       Quantities of households composite goods
    PP(t)       Price of households composite goods
    YPC(t)      Values of households consumption
    YPS(t)      Values of households savings
    betas(t)    Households saving propensity
    YP(t)       Values of households income
    txh(t)      Tax rate on households income
    UP(t)       Values of households utility
*Government module
    QG(t)       Quantities of government composite goods
    PG(t)       Price of government composite goods
    YGC(t)      Values of government purchase
    YGS(t)      Values of government fiscal surplus
    YG(t)       Values of government income
*Investment module
    QI(t)       Quantities of investment composite goods
    PI(t)       Price of investment composite goods
    YI(t)       Values of investment expenditures
*Market clearance
    PL(t)       Price of labor (wages)
    PK(t)       Price of capital (rents)
    PA(t)       Price of activity output
    D(t)        Dummy variable for WALRAS test
*Indices
    GDP(t)      Gross domestic production
;

*--------2.Model Parameters--------------------------------------------------------------------------
Parameters
*Production module
    alpl(t)     Cost share of labor in production function
    alpk(t)     Cost share of capital in production function
    a(t)        Total factor productivity in production function
    laml(t)     Labor-augmented technical shifter
    lamk(t)     Capital-augmented technical shifter
*Government module
    rgc(t)      Real government purchase
    rgs(t)      Real government savings
*Market clearance
    lb(t)       Exogenous labor endowment
    kb(t)       Exogenous capital endowment
;

*Flag parameters
Scalars
    govFlag     Government balance closure  /%GovClosure%/
;

*--------3.Equation Specifications-------------------------------------------------------------------
Equations
*Production module
    QL_eq(t)    Conditional labor demand function
    QK_eq(t)    Conditional capital demand function
    QA_eq(t)    Zero-profit -- activity output
    PAT_eq(t)   Calculation of pre-tax price (production tax)
*Households module
    QP_eq(t)    Zero-profit -- households composite goods
    PP_eq(t)    Market clearance -- households composite goods
    YPC_eq(t)   Calculation of households consumption
    YPS_eq(t)   Calculation of households savings
    YP_eq(t)    Households income balance
    UP_eq(t)    Households utility function
*Government module
    QG_eq(t)    Zero-profit -- government composite goods
    PG_eq(t)    Market clearance -- government composite goods
    YGC_eq(t)   Calculation of government purchase
    YGS_eq(t)   Calculation of government fiscal surplus
    YG_eq(t)    Government income balance
*Investment module
    QI_eq(t)    Zero-profit -- investment composite goods
    PI_eq(t)    Market clearance -- investment composite goods
    YI_eq(t)    Savings-investment balance
*Market module
    PL_eq(t)    Market clearance -- labor
    PK_eq(t)    Market clearance -- capital
    PA_eq(t)    Market clearance -- activity output
*Indices
    GDP_eq(t)   Calculation of GDP
;

*Production module
QL_eq(t)$(ts(t)).. // intermediate calculation -- QL
    QL(t)   =e= laml(t)**(esubt-1) * alpl(t) * (PAT(t)/PL(t))**esubt * QA(t);
QK_eq(t)$(ts(t)).. // intermediate calculation -- QK
    QK(t)   =e= lamk(t)**(esubt-1) * alpk(t) * (PAT(t)/PK(t))**esubt * QA(t);
QA_eq(t)$(ts(t)).. // zero-profit condition -- QA
    0       =g= (PAT(t)*a(t) - ((PL(t)/laml(t))/alpl(t))**alpl(t)*((PK(t)/lamk(t))/alpk(t))**alpk(t))$(esubt eq 1)
                + (PAT(t)**(1-esubt) - (alpl(t)*(PL(t)/laml(t))**(1-esubt)+alpk(t)*(PK(t)/lamk(t))**(1-esubt)))$(esubt ne 1);
PAT_eq(t)$(ts(t)).. // intermediate calculation -- PAT
    PAT(t)  =e= PA(t)/(1+txp(t));
*Households module
QP_eq(t)$(ts(t)).. // zero-profit condition -- QP
    0       =g= PP(t) - PA(t);
PP_eq(t)$(ts(t)).. // market clearance -- PP
    0       =g= YPC(t) - PP(t)*QP(t);
YPC_eq(t)$(ts(t)).. // intermediate calculation -- YPC
    YPC(t)  =e= (1-betas(t)) * YP(t);
YPS_eq(t)$(ts(t)).. // intermediate calculation -- YPS
    YPS(t)  =e= betas(t) * YP(t);
YP_eq(t)$(ts(t)).. // intermediate calculation -- YP
    YP(t)   =e= (PL(t)*QL(t) + PK(t)*QK(t))*(1-txh(t));
UP_eq(t)$(ts(t)).. // indicator calculation -- UP
    UP(t)   =e= log(QP(t));
*Government module   
QG_eq(t)$(ts(t)).. // zero-profit condition -- QG
    0       =g= PG(t) - PA(t);
PG_eq(t)$(ts(t)).. // market clearance -- PG
    0       =g= YGC(t) - PG(t)*QG(t);
YGC_eq(t)$(ts(t)).. // intermediate calculation -- YGC
    YGC(t)  =e= (YG(t) - YGS(t))$(govFlag eq FixGovSave)
                + (rgc(t)*PA(t))$(govFlag eq FixGovCons);
YGS_eq(t)$(ts(t)).. // intermediate calculation -- YGS
    YGS(t)  =e= (YG(t) - YGC(t))$(govFlag eq FixGovCons)
                + (rgs(t)*PA(t))$(govFlag eq FixGovSave);
YG_eq(t)$(ts(t)).. // intermediate calculation -- YG
    YG(t)   =e= QA(t)*PAT(t)*txp(t) + (PL(t)*QL(t) + PK(t)*QK(t))*txh(t);
*Investment module
QI_eq(t)$(ts(t)).. // zero-profit condition -- QI
    0       =g= PI(t) - PA(t);
PI_eq(t)$(ts(t)).. // market clearance -- PI
    0       =g= YI(t) - PI(t)*QI(t);
YI_eq(t)$(ts(t)).. // intermediate calculation -- YI
    YI(t)   =e= YPS(t) + YGS(t);
*Market module
PL_eq(t)$(ts(t)).. // market clearance -- PL
    0       =g= QL(t) - lb(t);
PK_eq(t)$(ts(t)).. // market clearance -- PK
    0       =g= QK(t) - kb(t);
PA_eq(t)$(ts(t)).. // market clearance -- PA (dummied because PA is set as numeraire)
    D(t)    =e= (QP(t)+QG(t)+QI(t)) - QA(t);
*Indices
GDP_eq(t)$(ts(t)).. // indicator calculation -- GDP
    GDP(t)  =e= PP(t)*QP(t) + PG(t)*QG(t) + PI(t)*QI(t);

*--------4.Model Specifications----------------------------------------------------------------------
Model   main_model  BA-CGE  /
    QL_eq.QL, QK_eq.QK, QA_eq.QA, PAT_eq.PAT,
    QP_eq.QP, PP_eq.PP, YPC_eq.YPC, YPS_eq.YPS, YP_eq.YP, UP_eq.UP,
    QG_eq.QG, PG_eq.PG, YGC_eq.YGC, YGS_eq.YGS, YG_eq.YG,
    QI_eq.QI, PI_eq.PI, YI_eq.YI,
    PL_eq.PL, PK_eq.PK, PA_eq.D,
    GDP_eq.GDP
/;

main_model.holdfixed   =   1;

*========D.Initialization & Calibration==============================================================
Scalar  vScl    base data scale factor  /1e-3/;

*--------1.Initialize Variables----------------------------------------------------------------------
PAT.l(t)    =   (sam('tot','act')-sam('ptx','act'))/sam('tot','act');
PP.l(t)     =   1;
PG.l(t)     =   1;
PI.l(t)     =   1;
PL.l(t)     =   1;
PK.l(t)     =   1;
PA.l(t)     =   1;

QL.l(t)     =   vScl*sam('lab','act')/PL.l(t);
QK.l(t)     =   vScl*sam('cap','act')/PK.l(t);
QA.l(t)     =   vScl*sam('tot','act')/PA.l(t);
QP.l(t)     =   vScl*sam('act','hhd')/PP.l(t);
QG.l(t)     =   vScl*sam('act','gov')/PG.l(t);
QI.l(t)     =   vScl*sam('act','inv')/PI.l(t);

YPC.l(t)    =   vScl*sam('act','hhd');
YPS.l(t)    =   vScl*sam('inv','hhd');
YP.l(t)     =   vScl*(sam('hhd','tot')-sam('gov','hhd'));
UP.l(t)     =   0;
YGC.l(t)    =   vScl*sam('act','gov');
YGS.l(t)    =   vScl*sam('inv','gov');
YG.l(t)     =   vScl*sam('gov','tot');
YI.l(t)     =   vScl*sam('act','inv');
D.l(t)      =   0;
GDP.l(t)    =   0;

display PAT.l,
        QL.l, QK.l, QA.l, QP.l, QG.l, QI.l, 
        YPC.l, YPS.l, YP.l, YGC.l, YGS.l, YG.l, YI.l;

*--------2.Calibrate Model Parameters----------------------------------------------------------------
alpl(t)     =   (QL.l(t)/QA.l(t)) * (PL.l(t)/PAT.l(t))**esubt;
alpk(t)     =   (QK.l(t)/QA.l(t)) * (PK.l(t)/PAT.l(t))**esubt;
a(t)        =   QA.l(t)/(QL.l(t)**alpl(t) * QK.l(t)**alpk(t));
laml(t)     =   1;
lamk(t)     =   1;
txp.l(t)    =   PA.l(t)/PAT.l(t) - 1;
betas.l(t)  =   YPS.l(t)/YP.l(t);
txh.l(t)    =   1 - YP.l(t)/(PL.l(t)*QL.l(t)+PK.l(t)*QK.l(t));
rgc(t)      =   YGC.l(t)/PA.l(t);
rgs(t)      =   YGS.l(t)/PA.l(t);
lb(t)       =   QL.l(t);
kb(t)       =   QK.l(t);

display alpl, alpk, a, txp.l, betas.l, txh.l, rgc, rgs, lb, kb;

*========E.Model Solution============================================================================

*--------1.Fix Exogenous Variables-------------------------------------------------------------------
*!!!PA is set as numeraire
PA.fx(t)    =   PA.l(t);
*!!!The standard government balance closure
txp.fx(t)   =   txp.l(t);
txh.fx(t)   =   txh.l(t);
*!!!The standard savings balance closure
betas.fx(t) =   betas.l(t);

*--------2.Lower Bounds on Variables-----------------------------------------------------------------
QA.lo(t)    =   0;
QP.lo(t)    =   0;
PP.lo(t)    =   0;
QG.lo(t)    =   0;
PG.lo(t)    =   0;
QI.lo(t)    =   0;
PI.lo(t)    =   0;
PL.lo(t)    =   0;
PK.lo(t)    =   0;

*--------3.Solve the model for each time period------------------------------------------------------
option limRow = 0, limCol = 0, solprint = off;

loop(tsim,
    ts(tsim) = yes;
*   !!!baseline replication
    if(sameas(tsim,'base'),
        PA.fx(tsim) =   PA.l(tsim);
*   !!!price homogeneity check
    elseif(sameas(tsim,'homo')),
        PA.fx(tsim) =   1.5*PA.l(tsim);
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
    qlck    Check changes in QL
    qkck    Check changes in QK
    qack    Check changes in QA
    patck   Check changes in PAT
    qpck    Check changes in QP
    ppck    Check changes in PP
    ypcck   Check changes in YPC
    ypsck   Check changes in YPS
    ypck    Check changes in YP
    upck    Check changes in UP
    qgck    Check changes in QG
    pgck    Check changes in PG
    ygcck   Check changes in YGC
    ygsck   Check changes in YGS
    ygck    Check changes in YG
    qick    Check changes in QI
    pick    Check changes in PI
    yick    Check changes in YI
    plck    Check changes in PL
    pkck    Check changes in PK
    pack    Check changes in PA
    gdpck   Check changes in GDP
;

$macro  Check(x,p)\
        p(t)$(x.l('base') and x.l(t-1)) = (100*(x.l(t)-x.l('base'))/x.l('base'))$(ifBase)\
                                          + (100*(x.l(t)-x.l(t-1))/x.l(t-1))$(not ifBase);
Check(QL,qlck);
Check(QK,qkck);
Check(QA,qack);
Check(PAT,patck);
Check(QP,qpck);
Check(PP,ppck);
Check(YPC,ypcck);
Check(YPS,ypsck);
Check(YP,ypck);
Check(UP,upck);
Check(QG,qgck);
Check(PG,pgck);
Check(YGC,ygcck);
Check(YGS,ygsck);
Check(YG,ygck);
Check(QI,qick);
Check(PI,pick);
Check(YI,yick);
Check(PL,plck);
Check(PK,pkck);
Check(PA,pack);
Check(GDP,gdpck);

display patck, ppck, pgck, pick, plck, pkck, pack 
;
display qlck, qkck, qack,
        qpck, ypcck, ypsck, ypck, upck,
        qgck, ygcck, ygsck, ygck,
        qick, yick,
        gdpck
;
display PAT.l, PP.l, PG.l, PI.l, PL.l, PK.l, PA.l
;
display QL.l, QK.l, QA.l,
        QP.l, YPC.l, YPS.l, YP.l, UP.l,
        QG.l, YGC.l, YGS.l, YG.l,
        QI.l, YI.l,
        GDP.l
;
display D.l;
$onText
$offText
