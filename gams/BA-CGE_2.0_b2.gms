$title  Basic CGE Model 2.0_beta2

*----------------------------------------------------------------------------------------------------
*This is a simple single-region, single-sector, two-factor, open-economy CGE model.
*The firm maximizes its profit subjected to constant return-to-scale CES technology.
*The households allocate a fixed proportion of its income as savings, which turn to investments,
*and then maximize its utility (increasing & convex) subjected to the budget constraint.
*The government levies a production tax & a direct tax & an import tariff, and uses income to purchase.
*It operates with a constant fiscal surplus.
*Imports are specified using Armington assumption, while exports follow the CET function. 
*In total, there are seven markets: five goods markets (activity output, exports, domestic goods,
*imports, composite goods) and two factor markets.
*----------------------------------------------------------------------------------------------------

$offlisting
$eolcom //

*========A.Pre-settings & Options====================================================================

*========B.Input Sets, Parameters & Basedata=========================================================

*--------1.Time framework----------------------------------------------------------------------------
Sets    
    t           time frame      /base,homo,labup,capup,totup,notrf/
    t0(t)       base period     /base/
    ts(t)       time Flag
;
ts(t) = no;
Alias   (t,tsim);

display t;

*--------2.Sets Definition---------------------------------------------------------------------------
Sets is SAM accounts    /
    COM     commodity
    ACT     activity
    LAB     labor
    CAP     capital
    PTX     production tax
    MTX     import tariff
    HHD     households
    GOV     governments
    INV     investment-savings
    ROW     rest of world
    TOT     row and column sums
/;

*--------3.Alias for Sets----------------------------------------------------------------------------
Alias   (is,js);

*--------4.Pre-provided Parameters-------------------------------------------------------------------
Scalars
    esubt   elasticity of substitution between labor and capital    /1.0/
    etrax   elasticity of transformation in export CET function     /inf/
    esubm   elasticity of substitution in armington nest function   /1.0/
;

*--------5.Base Data Read-in-------------------------------------------------------------------------
$ifthen exist   ../data_input/sam_2.0.gdx
*Read from external data sources
Table   sam(is,js)  Social accounting matrix;
    $$gdxin ../data_input/sam_2.0.gdx
    $$load  sam = sam
$else
*Or define manually
Table   sam(is,js)  Social accounting matrix
        COM     ACT     LAB     CAP     PTX     MTX     HHD     GOV     INV     ROW     TOT
COM                                                     38401   17363   43352   18793   117908
ACT     101642                                                                          101642
LAB             52957                                                                   52957
CAP             39728                                                                   39728
PTX             8958                                                                    8958
MTX     256                                                                             256
HHD                     52957   39728                                                   92684
GOV                                     8958    256     1157                            10371
INV                                                     53127   -6991           -2783   43352
ROW     16009                                                                           16009
TOT     117908  101642  52957   39728   8958    256     92684   10371   43352   16009
;
$endif

*========C.Load Model================================================================================

*--------1.Model Variables---------------------------------------------------------------------------
Variables
*Production module
    QL(t)       Quantities of labor demand
    QK(t)       Quantities of capital demand
    QA(t)       Quantities of activity output supply
    PAT(t)      Price of activity output (pre-tax)
    txp(t)      Tax rate on production
*Trade (export) module
    QD(t)       Quantities of domestic goods supply
    QE(t)       Quantities of exported goods supply
*   QA(t)       Quantities of activity output demand
*Trade (import) module
    PMT(t)      Price of imported goods (pre-tax)
    txm(t)      Tax rate on imports
*   QD(t)       Quantities of domestic goods demand
    QM(t)       Quantities of imported goods demand
    QC(t)       Quantities of composite goods supply
*Trade (balance) module
    YFS(t)      Values of net foreign savings
*Households module
    QP(t)       Quantities of households composite goods
    PP(t)       Price of households composite goods
    YPC(t)      Values of households consumption
    YPS(t)      Values of households savings
    betas(t)    Households saving propensity
    YP(t)       Values of households income
    txh(t)      Tax rate on households income
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
    PD(t)       Price of domestic goods
    PE(t)       Price of exported goods
    PM(t)       Price of imported goods
    PC(t)       Price of composite goods
*Closure
    D(t)        Dummy variable for WALRAS test
*Indices
    GDP(t)      Gross domestic production
;

*--------2.Model Parameters--------------------------------------------------------------------------
Parameters
*Production module
    alpl(t)     Cost share of labor in production function
    alpk(t)     Cost share of capital in production function
    aa(t)       Scale parameter in production function
    laml(t)     Labor-augmented technical shifter
    lamk(t)     Capital-augmented technical shifter
*Trade module
    gamd(t)     Cost share of domestic goods in export CET function 
    game(t)     Cost share of exported goods in export CET function
    alpd(t)     Cost share of domestic goods in armington import nest function
    alpm(t)     Cost share of imported goods in armington import nest function
    am(t)       Scale parameter in armington import nest function
*Government module
    rgc(t)      Real government purchase
    rgs(t)      Real government savings
*Market clearance
    lb(t)       Exogenous labor supply
    kb(t)       Exogenous capital supply
    eb(t)       Exogenous export demand
    mb(t)       Exogenous import supply
    pwe(t)      Fixed world price of exported goods
    pwm(t)      Fixed world price of imported goods
;

*--------3.Equation Specifications-------------------------------------------------------------------
Equations
*Production module
    QL_eq(t)    Conditional labor demand function
    QK_eq(t)    Conditional capital demand function
    QA_eq(t)    Zero-profit -- activity output supply
    PAT_eq(t)   Calculation of pre-tax price (production tax)
*Trade (export) module
    QD_eq(t)    Conditional supply function of domestic goods
    QE_eq(t)    Conditional supply function of exported goods
*   QA_eq(t)    Zero-profit -- activity output demand
*Trade (import) module
    PMT_eq(t)   Calculation of pre-tax price (import tariff)
*   QD_eq(t)    Conditional demand function of domestic goods
    QM_eq(t)    Conditional demand function of imported goods
    QC_eq(t)    Zero-profit -- composite goods
*Trade (balance) module
    YFS_eq(t)   Calculation of net foreign savings
*Households module
    QP_eq(t)    Zero-profit -- households composite goods
    PP_eq(t)    Market clearance -- households composite goods
    YPC_eq(t)   Calculation of households consumption
    YPS_eq(t)   Calculation of households savings
    YP_eq(t)    Households income balance
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
*Market clearance
    PL_eq(t)    Market clearance -- labor
    PK_eq(t)    Market clearance -- capital
    PA_eq(t)    Market clearance -- activity output
    PD_eq(t)    Market clearance -- domestic goods
    PE_eq(t)    Market clearance -- exported goods
    PM_eq(t)    Market clearance -- imported goods
    PC_eq(t)    Market clearance -- composite goods
*Indices
    GDP_eq(t)   Calculation of GDP
;

*Production module
QL_eq(t)$(ts(t)).. // intermediate calculation -- QL
    QL(t)   =e= laml(t)**(esubt-1) * alpl(t) * (PAT(t)/PL(t))**esubt * QA(t);
QK_eq(t)$(ts(t)).. // intermediate calculation -- QK
    QK(t)   =e= lamk(t)**(esubt-1) * alpk(t) * (PAT(t)/PK(t))**esubt * QA(t);
QA_eq(t)$(ts(t)).. // zero-profit condition -- QA
    0       =g= (PAT(t)*aa(t) - ((PL(t)/laml(t))/alpl(t))**alpl(t)*((PK(t)/lamk(t))/alpk(t))**alpk(t))$(esubt eq 1)
                + (PAT(t)**(1-esubt) - (alpl(t)*(PL(t)/laml(t))**(1-esubt)+alpk(t)*(PK(t)/lamk(t))**(1-esubt)))$(esubt ne 1);
PAT_eq(t)$(ts(t)).. // intermediate calculation -- PAT
    PAT(t)  =e= PA(t)/(1+txp(t));
*Trade (export) module
QD_eq(t)$(ts(t)).. // intermediate calculation -- QD
    0       =e= (gamd(t) * (PD(t)/PA(t))**etrax * QA(t) - QD(t))$(etrax ne inf)
                + (PD(t) - PA(t))$(etrax eq inf);
QE_eq(t)$(ts(t)).. // intermediate calculation -- QE
    0       =e= (game(t) * (PE(t)/PA(t))**etrax * QA(t) - QE(t))$(etrax ne inf)
                + (PE(t) - PA(t))$(etrax eq inf);
*Trade (import) module
PMT_eq(t)$(ts(t)).. // intermediate calculation -- PMT
    PMT(t)  =e= PM(t)/(1+txm(t));
QM_eq(t)$(ts(t)).. // intermediate calculation -- QM
    QM(t)   =e= alpm(t) * (PC(t)/PM(t))**esubm * QC(t);
QC_eq(t)$(ts(t)).. // zero-profit condition -- QC
    0       =g= (PC(t)*am(t) - (PD(t)/alpd(t))**alpd(t)*(PM(t)/alpm(t))**alpm(t))$(esubm eq 1)
                + (PC(t)**(1-esubm) - (alpd(t)*PD(t)**(1-esubm) + alpm(t)*PM(t)**(1-esubm)))$(esubm ne 1);
*Trade (balance) module
YFS_eq(t)$(ts(t)).. // intermediate calculation -- YFS
    YFS(t)  =e= PMT(t)*QM(t) - PE(t)*QE(t);
*Households module
QP_eq(t)$(ts(t)).. // zero-profit condition -- QP
    0       =g= PP(t) - PC(t);
PP_eq(t)$(ts(t)).. // market clearance -- PP
    0       =g= YPC(t) - PP(t)*QP(t);
YPC_eq(t)$(ts(t)).. // intermediate calculation -- YPC
    YPC(t)  =e= (1-betas(t)) * YP(t);
YPS_eq(t)$(ts(t)).. // intermediate calculation -- YPS
    YPS(t)  =e= betas(t) * YP(t);
YP_eq(t)$(ts(t)).. // intermediate calculation -- YP
    YP(t)   =e= (PL(t)*QL(t)+PK(t)*QK(t))*(1-txh(t));
*Government module   
QG_eq(t)$(ts(t)).. // zero-profit condition -- QG
    0       =g= PG(t) - PC(t);
PG_eq(t)$(ts(t)).. // market clearance -- PG
    0       =g= YGC(t) - PG(t)*QG(t);
YGC_eq(t)$(ts(t)).. // intermediate calculation -- YGC
    YGC(t)  =e= YG(t) - YGS(t);
YGS_eq(t)$(ts(t)).. // intermediate calculation -- YGS
    YGS(t)  =e= rgs(t)*PG(t);
YG_eq(t)$(ts(t)).. // intermediate calculation -- YG
    YG(t)   =e= QA(t)*PAT(t)*txp(t) + QM(t)*PMT(t)*txm(t) + (PL(t)*QL(t)+PK(t)*QK(t))*txh(t);
*Investment module
QI_eq(t)$(ts(t)).. // zero-profit condition -- QI
    0       =g= PI(t) - PC(t);
PI_eq(t)$(ts(t)).. // market clearance -- PI
    0       =g= YI(t) - PI(t)*QI(t);
YI_eq(t)$(ts(t)).. // intermediate calculation -- YI
    YI(t)   =e= YPS(t) + YGS(t) + YFS(t);
*Market clearance
PL_eq(t)$(ts(t)).. // market clearance -- PL
    0       =g= QL(t) - lb(t);
PK_eq(t)$(ts(t)).. // market clearance -- PK
    0       =g= QK(t) - kb(t);
PA_eq(t)$(ts(t)).. // market clearance -- PA
    0       =g= (PA(t)**(1+etrax) - (gamd(t)*PD(t)**(1+etrax) + game(t)*PE(t)**(1+etrax)))$(etrax ne inf)
                + ((QD(t)+QE(t)) - QA(t))$(etrax eq inf);
PD_eq(t)$(ts(t)).. // market clearance -- PD
    0       =g= alpd(t) * (PC(t)/PD(t))**esubm * QC(t) - QD(t);
PE_eq(t)$(ts(t)).. // market clearance -- PE
    0       =e= (PE(t) - pwe(t)*PC(t))$(etrax ne inf)
                + (QE(t) - eb(t))$(etrax eq inf);
PM_eq(t)$(ts(t)).. // market clearance -- PM
    0       =e= PMT(t) - pwm(t)*PC(t);
PC_eq(t)$(ts(t)).. // market clearance -- PC (dummied because PC is set as numeraire)
    D(t)    =e= (QP(t)+QG(t)+QI(t)) - QC(t);
*Indices
GDP_eq(t)$(ts(t)).. // indicator calculation -- GDP
    GDP(t)  =e= PP(t)*QP(t) + PG(t)*QG(t) + PI(t)*QI(t) + PE(t)*QE(t) - PMT(t)*QM(t);

*--------4.Model Specifications----------------------------------------------------------------------
Model   main_model  BA-CGE  /
    QL_eq.QL, QK_eq.QK, QA_eq.QA, PAT_eq.PAT,
    QD_eq.QD, QE_eq.QE, PMT_eq.PMT, QM_eq.QM, QC_eq.QC, YFS_eq.YFS,
    QP_eq.QP, PP_eq.PP, YPC_eq.YPC, YPS_eq.YPS, YP_eq.YP,
    QG_eq.QG, PG_eq.PG, YGC_eq.YGC, YGS_eq.YGS, YG_eq.YG,
    QI_eq.QI, PI_eq.PI, YI_eq.YI,
    PL_eq.PL, PK_eq.PK, PA_eq.PA, PD_eq.PD, PE_eq.PE, PM_eq.PM, PC_eq.D,
    GDP_eq.GDP
/;

main_model.holdfixed   =   1;

*========D.Initialization & Calibration==============================================================
Scalar  vScl    base data scale factor  /1e-3/;

*--------1.Initialize Variables----------------------------------------------------------------------
PAT.l(t)    =   (sam('tot','act')-sam('ptx','act'))/sam('tot','act');
PMT.l(t)    =   sam('row','com')/(sam('row','com')+sam('mtx','com'));
PP.l(t)     =   1;
PG.l(t)     =   1;
PI.l(t)     =   1;
PL.l(t)     =   1;
PK.l(t)     =   1;
PA.l(t)     =   1;
PD.l(t)     =   1;
PE.l(t)     =   1;
PM.l(t)     =   1;
PC.l(t)     =   1;

QL.l(t)     =   vScl*sam('lab','act')/PL.l(t);
QK.l(t)     =   vScl*sam('cap','act')/PK.l(t);
QA.l(t)     =   vScl*sam('tot','act')/PA.l(t);
QD.l(t)     =   vScl*(sam('act','com')-sam('com','row'))/PD.l(t);
QE.l(t)     =   vScl*sam('com','row')/PE.l(t);
QM.l(t)     =   vScl*(sam('tot','com')-sam('act','com'))/PM.l(t);
QC.l(t)     =   vScl*(sam('tot','com')-sam('com','row'))/PC.l(t);
QP.l(t)     =   vScl*sam('com','hhd')/PP.l(t);
QG.l(t)     =   vScl*sam('com','gov')/PG.l(t);
QI.l(t)     =   vScl*sam('com','inv')/PI.l(t);

YFS.l(t)    =   vScl*sam('inv','row');
YPC.l(t)    =   vScl*sam('com','hhd');
YPS.l(t)    =   vScl*sam('inv','hhd');
YP.l(t)     =   vScl*(sam('hhd','tot')-sam('gov','hhd'));
YGC.l(t)    =   vScl*sam('com','gov');
YGS.l(t)    =   vScl*sam('inv','gov');
YG.l(t)     =   vScl*sam('gov','tot');
YI.l(t)     =   vScl*sam('inv','tot');

txp.l(t)    =   sam('ptx','act')/(sam('tot','act')-sam('ptx','act'));
txm.l(t)    =   sam('mtx','com')/sam('row','com');
betas.l(t)  =   sam('inv','hhd')/(sam('tot','hhd')-sam('gov','hhd'));
txh.l(t)    =   sam('gov','hhd')/sam('tot','hhd');

D.l(t)      =   0;
GDP.l(t)    =   0;

display PAT.l, PMT.l,
        QL.l, QK.l, QA.l, QD.l, QE.l, QM.l, QC.l, QP.l, QG.l, QI.l, 
        YFS.l, YPC.l, YPS.l, YP.l, YGC.l, YGS.l, YG.l, YI.l,
        txp.l, txm.l, betas.l, txh.l;

*--------2.Calibrate Model Parameters----------------------------------------------------------------
alpl(t)     =   (QL.l(t)/QA.l(t)) * (PL.l(t)/PAT.l(t))**esubt;
alpk(t)     =   (QK.l(t)/QA.l(t)) * (PK.l(t)/PAT.l(t))**esubt;
aa(t)       =   QA.l(t)/(QL.l(t)**alpl(t) * QK.l(t)**alpk(t));
laml(t)     =   1;
lamk(t)     =   1;

gamd(t)     =   ((QD.l(t)/QA.l(t)) * (PA.l(t)/PD.l(t))**etrax)$(etrax ne inf)
                + (QD.l(t)/QA.l(t))$(etrax eq inf);
game(t)     =   ((QE.l(t)/QA.l(t)) * (PA.l(t)/PE.l(t))**etrax)$(etrax ne inf)
                + (QE.l(t)/QA.l(t))$(etrax eq inf);
alpd(t)     =   (QD.l(t)/QC.l(t)) * (PD.l(t)/PC.l(t))**esubm;
alpm(t)     =   (QM.l(t)/QC.l(t)) * (PM.l(t)/PC.l(t))**esubm;
am(t)       =   QC.l(t)/(QD.l(t)**alpd(t) * QM.l(t)**alpm(t));

rgc(t)      =   YGC.l(t)/PG.l(t);
rgs(t)      =   YGS.l(t)/PG.l(t);

lb(t)       =   QL.l(t);
kb(t)       =   QK.l(t);
eb(t)       =   QE.l(t);
mb(t)       =   QM.l(t);
pwe(t)      =   PE.l(t)/PC.l(t);
pwm(t)      =   PMT.l(t)/PC.l(t);

display alpl, alpk, aa,
        gamd, game, alpd, alpm, am;

*========E.Model Solution============================================================================

*--------1.Fix Exogenous Variables-------------------------------------------------------------------
*!!!PC is set as numeraire
PC.fx(t)    =   PC.l(t);
*!!!The standard government balance closure
txp.fx(t)   =   txp.l(t);
txm.fx(t)   =   txm.l(t);
txh.fx(t)   =   txh.l(t);
*!!!The standard savings balance closure
betas.fx(t) =   betas.l(t);

*--------2.Lower Bounds on Variables-----------------------------------------------------------------
QA.lo(t)    =   0;
QC.lo(t)    =   0;
QP.lo(t)    =   0;
QG.lo(t)    =   0;
QI.lo(t)    =   0;

PP.lo(t)    =   0;
PG.lo(t)    =   0;
PI.lo(t)    =   0;
PL.lo(t)    =   0;
PK.lo(t)    =   0;
PA.lo(t)    =   0;
PD.lo(t)    =   0;
PE.lo(t)    =   0;
PM.lo(t)    =   0;

*--------3.Solve the model for each time period------------------------------------------------------
option limRow = 0, limCol = 0, solprint = off;

loop(tsim,
    ts(tsim) = yes;
*   !!!baseline replication
    if(sameas(tsim,'base'),
        PC.fx(tsim)     =   PC.l(tsim);
*   !!!price homogeneity check
    elseif(sameas(tsim,'homo')),
        PC.fx(tsim)     =   1.5*PC.l(tsim);
*   !!!shock simulation -- increase in labor productivity
    elseif(sameas(tsim,'labup')),
        laml(tsim)      =   1.5*laml(tsim);
*   !!!shock simulation -- increase in capital productivity
    elseif(sameas(tsim,'capup')),
        lamk(tsim)      =   1.5*lamk(tsim);
*   !!!shock simulation -- increase in total productivity
    elseif(sameas(tsim,'totup')),
        laml(tsim)      =   1.5*laml(tsim);
        lamk(tsim)      =   1.5*lamk(tsim);
*   !!!shock simulation -- eliminate tariffs
    elseif(sameas(tsim,'notrf')),
        txm.fx(tsim)    =   0;
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
    qdck    Check changes in QD
    qeck    Check changes in QE
    pmtck   Check changes in PMT
    qmck    Check changes in QM
    qcck    Check changes in QC
    yfsck   Check changes in YFS
    qpck    Check changes in QP
    ppck    Check changes in PP
    ypcck   Check changes in YPC
    ypsck   Check changes in YPS
    ypck    Check changes in YP
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
    pdck    Check changes in PD
    peck    Check changes in PE
    pmck    Check changes in PM
    pcck    Check changes in PC
    gdpck   Check changes in GDP
;

$macro  Check(x,p)\
        p(t)$(x.l('base') and x.l(t-1)) = (100*(x.l(t)-x.l('base'))/x.l('base'))$(ifBase)\
                                          + (100*(x.l(t)-x.l(t-1))/x.l(t-1))$(not ifBase);
Check(QL,qlck);
Check(QK,qkck);
Check(QA,qack);
Check(PAT,patck);
Check(QD,qdck);
Check(QE,qeck);
Check(PMT,pmtck);
Check(QM,qmck);
Check(QC,qcck);
Check(YFS,yfsck);
Check(QP,qpck);
Check(PP,ppck);
Check(YPC,ypcck);
Check(YPS,ypsck);
Check(YP,ypck);
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
Check(PD,pdck);
Check(PE,peck);
Check(PM,pmck);
Check(PC,pcck);
Check(GDP,gdpck);

display patck, pmtck,
        ppck, pgck, pick,
        plck, pkck, pack, pdck, peck, pmck, pcck
;
display qlck, qkck, qack,
        qdck, qeck, qmck, qcck, yfsck, 
        qpck, ypcck, ypsck, ypck, 
        qgck, ygcck, ygsck, ygck,
        qick, yick
;
display gdpck
;
display PAT.l, PMT.l,
        PP.l, PG.l, PI.l,
        PL.l, PK.l, PA.l, PD.l, PE.l, PM.l, PC.l
;
display QL.l, QK.l, QA.l,
        QD.l, QE.l, QM.l, QC.l, YFS.l,
        QP.l, YPC.l, YPS.l, YP.l,
        QG.l, YGC.l, YGS.l, YG.l,
        QI.l, YI.l
;
display GDP.l
;
display D.l;
$onText
$offText
