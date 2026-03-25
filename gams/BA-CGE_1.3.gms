$title  Basic CGE Model 1.3

*----------------------------------------------------------------------------------------------------
*This is a simple single-region, single-sector, two-factor, open-economy CGE model.
*The firm maximizes its profit subjected to constant return-to-scale CES technology.
*The households allocate a fixed proportion of its income as savings, which turn to investments,
*and then maximize its utility (following a log function) subjected to the budget constraint.
*The government levies a production tax, a direct tax, and an import tariff, and uses its income to purchase.
*It may operate with a constant (under FixGovSave) or flexible (under FixGovCons) fiscal surplus.
*Imports are specified using Armington assumption, while exports follow the CET function. 
*In total, there are seven markets: five goods markets (domestic output, exports, domestic sold,
*imports, armington composite) and two factor markets. 
*----------------------------------------------------------------------------------------------------

$offlisting
$eolcom %

*========A.Pre-settings & Options====================================================================

*========B.Input Sets, Parameters & Basedata=========================================================

*--------1.Sets Definition---------------------------------------------------------------------------
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

*--------2.Alias for Sets----------------------------------------------------------------------------
Alias   (is,js);

*--------3.Pre-provided Parameters-------------------------------------------------------------------
Scalars
    esubt   elasticity of substitution between labor and capital    /1.0/
    etrae   elasticity of transformation in export CET function     /2.0/
    esubm   elasticity of substitution in armington nest function   /0.5/
;

*--------4.Base Data Read-in-------------------------------------------------------------------------
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
    QL          Quantities of labor demand by activity
    QK          Quantities of capital demand by activity
    PP          Agents price of activity unit output (pre-tax)
    TXP         Tax rate on production
    PA          Basic price of activity unit output (after-tax)
*Domestic supply allocation module
    QA          Quantities of activity total output
    QD          Quantities of domestic produced & sold goods
    QE          Quantities of domestic produced & exported goods
    PE          Basic price of domestic produced & exported goods
*Armington import nest module
    PM          Basic price of imported goods
    TXM         Tax rate on imports
    PD          Basic price of domestic produced & sold goods
*   QD          Quantities of demand for domestic goods
    QM          Quantities of demand for imported goods
    PC          Basic price of armington composite goods
*Agents consumption module
    QC          Quantities of demand for composite goods
    QP          Quantities of households consumption
    QG          Quantities of government purchase
    QI          Quantities of investment consumption
*Agents income & allocation module
    TXH         Tax rate on households income
    BETS        Households saving propensity
    YPC         Values of households consumption
    YPS         Values of households savings
    YGC         Values of government purchase
    YGS         Values of goveenment savings
    YP          Values of households income
    YG          Values of government income
    UP          Values of households utility
*Endowments supply module
    PW          Price of labor factor (wages)
    PR          Price of capital factor (rents)
*Closure module
    YFS         Values of foreign savings
    YI          Values of investment expenditures
    D           Dummy variable for WALRAS test
;

*--------2.Model Parameters--------------------------------------------------------------------------
Parameters
*Production module
    alpl        CES dual share parameter of labor in production function
    alpk        CES dual share parameter of capital in production function
    aa          CES aggregate parameter in production function
*Domestic supply allocation module
    gamd        CET dual share parameter of domestic goods in domestic supply allocation
    game        CET dual share parameter of exported goods in domestic supply allocation
    pwe         Fixed world price of exported goods
*Armington import nest module
    pwm         Fixed world price of imported goods
    alpd        CES dual share parameter of domestic goods in armington nest
    alpm        CES dual share parameter of imported goods in armington nest
*Agents income & allocation module
    au          CES aggregate parameter in households utility
*Endowments supply module
    lb          Scale parameter in labor factor supply
    kb          Scale parameter in capital factor supply
;

*--------3.Equation Specifications-------------------------------------------------------------------
Equations
*Production module
    QL_eq       Conditional labor demand function
    QK_eq       Conditional capital demand function
    PP_eq       Goods supply function
    PA_eq       Connection between agents and basic price (through production tax)
*Domestic supply allocation module
    QA_eq       Demand for domestic produced goods (domestic sold & export)
    QD_eq       Supply of domestic produced & sold goods
    QE_eq       Supply of domestic produced & exported goods
    PE_eq       Determination of export price (from world price)
*Armington import nest module
    PM_eq       Determination of import price (from world price)
    PD_eq       Demand for domestic produced & sold goods
    QM_eq       Demand for imported goods
    PC_eq       Supply of armington composite goods
*Agents consumption module
    QC_eq       Demand for armington composite goods
    QP_eq       Goods demand function of households
    QG_eq       Goods demand function of government
    QI_eq       Goods demand function of investment
*Agents income & allocation module
    YPC_eq      Calculation of households total consumption
    YPS_eq      Calculation of households total savings
    YGC_eq      Calculation of governments total expenditure
    YP_eq       Sources of households income
    YG_eq       Sources of governments income
    UP_eq       Households utility function
*Endowments supply module
    PW_eq       Labor supply function
    PR_eq       Capital supply function
*Closure module
    YFS_eq      Calculation of net foreign savings
    YI_eq       Savings-Investments balance 
;

*Production module
QL_eq..
    QL  =e= alpl * QA * (PP/PW);
QK_eq..
    QK  =e= alpk * QA * (PP/PR);
PP_eq..
    PP*aa   =e= (PW/alpl)**alpl * (PR/alpk)**alpk;
PA_eq..
    PA  =e= PP*(1+TXP);
*Domestic supply allocation module
QA_eq.. % This equation implicitly works as output goods market clearing condition.
*   QAS =e= QAD;
    PA**(1+etrae)   =e= gamd*PD**(1+etrae) + game*PE**(1+etrae);
QD_eq..
    QD  =e= gamd * QA * (PD/PA)**etrae;
QE_eq..
    QE  =e= game * QA * (PE/PA)**etrae;
PE_eq.. % This equation implicitly works as export goods market clearing condition. 
    PE  =e= pwe * PC;
*Armington import nest module
PM_eq.. % This equation implicitly works as import goods market clearing condition.
    PM  =e= pwm * PC * (1+TXM);
PD_eq.. % This equation implicitly works as domestic goods market clearing condition.
*   QDS =e= QDD;
    QD  =e= alpd * QC * (PC/PD)**esubm;
QM_eq..
    QM  =e= alpm * QC * (PC/PM)**esubm;
PC_eq..
    PC**(1-esubm)   =e= alpd*PD**(1-esubm) + alpm*PM**(1-esubm);
*Agents consumption module
QC_eq.. % This equation implicitly works as armington goods market clearing condition (dummied).
    QC  =e= QP + QG + QI + D;
QP_eq..
    QP  =e= YPC/PC;
QG_eq..
    QG  =e= YGC/PC;
QI_eq..
    QI  =e= YI/PC;
*Agents income & allocation module
YPC_eq..
    YPC =e= (1-BETS) * YP;
YPS_eq..
    YPS =e= BETS * YP;
YGC_eq..
    YGC =e= YG - YGS;
YP_eq.. % Disposable income equals total income minus direct tax.
    YP  =e= (PW*QL + PR*QK)*(1-TXH);
YG_eq..
    YG  =e= QA*PP*TXP + (PW*QL + PR*QK)*TXH + pwm*PC*QM*TXM;
UP_eq..
    UP  =e= au * QP**(1-BETS) * (YPS/PC)**BETS;
*Endowments supply module
PW_eq..  % This equation implicitly works as labor market clearing condition.
    QL  =e= lb;
PR_eq..  % This equation implicitly works as capital market clearing condition.
    QK  =e= kb;
*Closure module
YFS_eq..
    YFS =e= pwm*PC*QM - pwe*PC*QE;
YI_eq.. % Investment-savings balance.
    YI  =e= YPS + YGS + YFS;

*--------4.Model Specifications----------------------------------------------------------------------
Model   main_model  BA-CGE  /
    QL_eq.QL, QK_eq.QK, PP_eq.PP, PA_eq.PA,
    QA_eq.QA, QD_eq.QD, QE_eq.QE, PE_eq.PE,
    PM_eq.PM, PD_eq.PD, QM_eq.QM, PC_eq,
    QC_eq.QC, QP_eq.QP, QG_eq.YGC, QI_eq.YI,
    YPC_eq.YPC, YPS_eq.YPS, YGC_eq.YGS, YP_eq.YP, YG_eq.YG, UP_eq.UP,
    PW_eq.PW, PR_eq.PR,
    YFS_eq.YFS, YI_eq
/;

main_model.holdfixed   =   1;

*========D.Initialization & Calibration==============================================================
Scalar  vScl    base data scale factor  /1e-3/;

*--------1.Initialize Variables----------------------------------------------------------------------
PP.l    =   (sam('tot','act')-sam('ptx','act'))/sam('tot','act');
PA.l    =   1;
PE.l    =   1;
PM.l    =   (sam('mtx','com')+sam('row','com'))/sam('row','com');
PD.l    =   1;
PC.l    =   1;
PW.l    =   1;
PR.l    =   1;

QL.l    =   vScl*sam('lab','act')/PW.l;
QK.l    =   vScl*sam('cap','act')/PR.l;
QA.l    =   vScl*sam('tot','act')/PA.l;
QD.l    =   vScl*(sam('act','com')-sam('com','row'))/PD.l;
QE.l    =   vScl*sam('com','row')/PE.l;
QM.l    =   vScl*(sam('tot','com')-sam('act','com'))/PM.l;
QC.l    =   vScl*(sam('com','tot')-sam('com','row'))/PC.l;
QP.l    =   vScl*sam('com','hhd')/PC.l;
QG.l    =   vScl*sam('com','gov')/PC.l;
QI.l    =   vScl*sam('com','inv')/PC.l;

TXP.l   =   sam('ptx','act')/(sam('tot','act')-sam('ptx','act'));
TXM.l   =   sam('mtx','com')/sam('row','com');
TXH.l   =   sam('gov','hhd')/sam('tot','hhd');
BETS.l  =   sam('inv','hhd')/(sam('tot','hhd')-sam('gov','hhd'));
YPC.l   =   vScl*sam('com','hhd');
YPS.l   =   vScl*sam('inv','hhd');
YGC.l   =   vScl*sam('com','gov');
YGS.l   =   vScl*sam('inv','gov');
YP.l    =   vScl*(sam('hhd','tot')-sam('gov','hhd'));
YG.l    =   vScl*sam('gov','tot');
UP.l    =   1;
YFS.l   =   vScl*sam('inv','row');
YI.l    =   vScl*sam('com','inv');
D.l     =   0;

display PP.l, PM.l, 
        QL.l, QK.l, QA.l, QD.l, QE.l, QM.l, QC.l, QP.l, QG.l, QI.l, 
        TXP.l, TXM.l, TXH.l, BETS.l, YPC.l, YPS.l, YGC.l, YGS.l, YP.l, YG.l, UP.l, YFS.l, YI.l;

*--------2.Calibrate Model Parameters----------------------------------------------------------------
alpl    =   (QL.l/QA.l) * (PW.l/PP.l);
alpk    =   (QK.l/QA.l) * (PR.l/PP.l);
aa      =   QA.l/(QL.l**alpl * QK.l**alpk);

gamd    =   (QD.l/QA.l) * (PA.l/PD.l)**etrae;
game    =   (QE.l/QA.l) * (PA.l/PE.l)**etrae;
pwe     =   PE.l/PC.l;

pwm     =   PM.l/(PC.l*(1+TXM.l));
alpd    =   (QD.l/QC.l) * (PD.l/PC.l)**esubm;
alpm    =   (QM.l/QC.l) * (PM.l/PC.l)**esubm;

au      =   UP.l/(QP.l**(1-BETS.l) * (YPS.l/PC.l)**BETS.l);

lb      =   QL.l;
kb      =   QK.l;

display alpl, alpk, aa, gamd, game, pwe, pwm, alpd, alpm, au, lb, kb;

*========E.Model Solution============================================================================

*--------1.Fix Exogenous Variables-------------------------------------------------------------------
*!!!Armington composite price PC is set as numeraire
PC.fx   =   PC.l;
if(1,
*!!!The standard government balance closure
    QG.fx   =   QG.l;
    TXP.fx  =   TXP.l;
    TXH.fx  =   TXH.l;
    TXM.fx  =   TXM.l;
);
if(1,
*!!!The standard savings balance closure
    BETS.fx =   BETS.l;
else
*!!!Alternative savings balance closure
    QI.fx   =   QI.l;
);

*--------2.Baseline Replication----------------------------------------------------------------------
option limRow = 0, limCol = 0;
solve   main_model  using mcp;
*!!!Record base levels of variables for comparison
Parameter
    QL0, QK0, PP0, TXP0, PA0,
    QA0, QD0, QE0, PE0,
    PM0, TXM0, PD0, QM0, PC0,
    QC0, QP0, QG0, QI0,
    TXH0, BETS0, YPC0, YPS0, YGC0, YGS0, YP0, YG0, UP0,
    PW0, PR0,
    YFS0, YI0
;
QL0     =   QL.l;
QK0     =   QK.l;
PP0     =   PP.l;
TXP0    =   TXP.l;
PA0     =   PA.l;
QA0     =   QA.l;
QD0     =   QD.l;
QE0     =   QE.l;
PE0     =   PE.l;
PM0     =   PM.l;
TXM0    =   TXM.l;
PD0     =   PD.l;
QM0     =   QM.l;
PC0     =   PC.l;
QC0     =   QC.l;
QP0     =   QP.l;
QG0     =   QG.l;
QI0     =   QI.l;
TXH0    =   TXH.l;
BETS0   =   BETS.l;
YPC0    =   YPC.l;
YPS0    =   YPS.l;
YGC0    =   YGC.l;
YGS0    =   YGS.l;
YP0     =   YP.l;
YG0     =   YG.l;
UP0     =   UP.l;
PW0     =   PW.l;
PR0     =   PR.l;
YFS0    =   YFS.l;
YI0     =   YI.l;

*--------3.Shocks Simulations------------------------------------------------------------------------
if(0,
    PC.fx   =   1.5*PC.l; 
);
if(0,
    lb      =   1.5*lb;
    kb      =   1.5*kb;
);
if(1,
    TXM.fx  =   TXM.l*0;
);
solve   main_model  using mcp;

*========F.Debug Check & Post-sim Analysis===========================================================

*--------1.Post-sim Analysis-------------------------------------------------------------------------
*!!!Calculate percentage changes of variables
Parameter
    qlck, qkck, ppck, txpck, pack,
    qack, qdck, qeck, peck,
    pmck, txmck, pdck, qmck, pcck,
    qcck, qpck, qgck, qick,
    txhck, betsck, ypcck, ypsck, ygcck, ygsck, ypck, ygck, upck,
    pwck, prck,
    yfsck, yick
;
$macro  Check(x,x0,p)  p$(x0) = 100*(x.l-x0)/x0;
Check(QL,QL0,qlck);
Check(QK,QK0,qkck);
Check(PP,PP0,ppck);
Check(TXP,TXP0,txpck);
Check(PA,PA0,pack);
Check(QA,QA0,qack);
Check(QD,QD0,qdck);
Check(QE,QE0,qeck);
Check(PE,PE0,peck);
Check(PM,PM0,pmck);
Check(TXM,TXM0,txmck);
Check(PD,PD0,pdck);
Check(QM,QM0,qmck);
Check(PC,PC0,pcck);
Check(QC,QC0,qcck);
Check(QP,QP0,qpck);
Check(QG,QG0,qgck);
Check(QI,QI0,qick);
Check(TXH,TXH0,txhck);
Check(BETS,BETS0,betsck);
Check(YPC,YPC0,ypcck);
Check(YPS,YPS0,ypsck);
Check(YGC,YGC0,ygcck);
Check(YGS,YGS0,ygsck);
Check(YP,YP0,ypck);
Check(YG,YG0,ygck);
Check(UP,UP0,upck);
Check(PW,PW0,pwck);
Check(PR,PR0,prck);
Check(YFS,YFS0,yfsck);
Check(YI,YI0,yick);

display ppck, pack, peck, pmck, pdck, pcck, pwck, prck
;
display qlck, qkck, txpck,
        qack, qdck, qeck,
        txmck, qmck,
        qcck, qpck, qgck, qick,
        txhck, betsck, ypcck, ypsck, ygcck, ygsck, ypck, ygck, upck,
        yfsck, yick
;
display PP.l, PA.l, PE.l, PM.l, PD.l, PC.l, PW.l, PR.l
;
display QL.l, QK.l, TXP.l,
        QA.l, QD.l, QE.l, 
        TXM.l, QM.l,
        QC.l, QP.l, QG.l, QI.l, 
        TXH.l, BETS.l, YPC.l, YPS.l, YGC.l, YGS.l, YP.l, YG.l, UP.l,
        YFS.l, YI.l, D.l
;
$onText
$offText
