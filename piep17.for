c ###### P1 #######                                                            1
c #######======= 001                                                           2
c  main program                                                                3
c                                                                              4
c       ********************************************                           5
c       *  =PIEP=    A PROGRAM FOR INTERPRETING    *                           6
c       *           ELECTRON DIFFRACTION PATTERNS  *                           7
c       *------------------------------------------*                           8
c       *  Darmstadt                    (G.MIEHE)  *                           9
c       *  update    14-jun-2017                   *                          10
c       ********************************************                          11
c                                                                             12
c                                                                             13
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20,jj5=100,jj6=40)              14
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20,jj5=100,jj6=40)           15
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,      16
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,         17
     2jfw                                                                     18
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,          19
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,      20
     2difa,difg,dc0                                                           21
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,       22
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                         23
      common /j8/ j8(jj3),j9(jj3),j85(6)                                      24
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                       25
      common /files/ file1,file2,file3,file4,file5,fdd                        26
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                    27
      common /its/ ftst(9),itst(9)                                            28
      common /cm12/ be01,be00,rbe1,rbe0                                       29
      dimension d(26), id(7), idd(2)                                          30
      equivalence (wiw,d(1)), (id(1),iho), (idd(1),ifdi)                      31
      character*20 file1,file2,file3,file4,file5,filep,filed,fdd              32
      character*1 aw                                                          33
      character*2 j8,j9                                                       34
      character*5 j85                                                         35
      character*9 datum                                                       36
      character*12 iden,iden1,iden2,iden3(4)                                  37
      logical law                                                             38
      data ftst,itst/9*0.,9*0/                                                39
      data iden1,iden2,datum/'93822','TEST','14-jun-17'/                      40
      data filep/'piep.par'/                                                  41
c-p      data filep/'piet.par'/                                               42
      data ipar,ntst/40,0/                                                    43
c IPAR=unit for paramater file piep.par                                       44
c                                                                             45
      itst(1)=1                                                               46
      itst(2)=0                                                               47
      ftst(1)=sr1                                                             48
      idi=jj1                                                                 49
      ibe=jj2                                                                 50
      nsb=jj3                                                                 51
      nx=jj4                                                                  52
      nso=jj5                                                                 53
      nlc=jj6                                                                 54
c                                                                             55
c NWM=default value for maximum number of solutions to be output              56
c                                                                             57
      nwm=ibe                                                                 58
c                                                                             59
      write (io,150) datum                                                    60
      write (ioa,160)                                                         61
      read (in,170,end=120) aw                                                62
      if (law(aw)) go to 120                                                  63
      write (ioa,180) filep                                                   64
      read (in,220) filed                                                     65
      if (filed.ne.' ') filep=filed                                           66
      open (unit=ipar,file=filep,status='OLD')                                67
      read (ipar,190) iden,iden3                                              68
      if (iden.ne.iden1) go to 10                                             69
      ntst=1                                                                  70
      iden=iden2                                                              71
c +++                                                                         72
      ihead=1                                                                 73
c +++                                                                         74
   10 if (ihead.eq.1) write (ioa,200) iden,iden3                              75
      read (ipar,190) iden,iden3                                              76
      if (iden.eq.'%%e7%2017--%') go to 20                                    77
      if (iden3(1).eq.' ') iden3(1)=' 24-DEC-1871'                            78
      write (ioa,210) iden3(1),datum                                          79
      stop                                                                    80
   20 read (ipar,170) aw                                                      81
      if (aw.ne.'$') go to 20                                                 82
      read (ipar,220) file1                                                   83
      read (ipar,220) file2                                                   84
      read (ipar,220) file4                                                   85
      read (ipar,220) file3                                                   86
      read (ipar,220) file5                                                   87
c                                                                             88
   30 call les (ipar)                                                         89
      if (n.eq.0) go to 30                                                    90
      itst(6)=c(6)                                                            91
      if (c(7).gt.0.) write (6,130) c                                         92
      c(1)=1                                                                  93
      c(2)=1                                                                  94
      c(3)=1                                                                  95
      itst(3)=0                                                               96
      itst(4)=0                                                               97
      itst(5)=0                                                               98
      koma=0                                                                  99
      if (n.ne.0.and.c(1).gt.0.) itst(3)=1                                   100
      if (n.ne.0.and.c(2).gt.0.) itst(4)=1                                   101
      if (n.ne.0) koma=c(3)                                                  102
      if (n.ne.0.and.c(4).eq.0.) itst(5)=1                                   103
      ittest=0                                                               104
      if (n.ne.0.and.c(5).ne.0.) ittest=1                                    105
c                                                                            106
      m=1                                                                    107
   40 call les (ipar)                                                        108
      if (n.eq.0) go to 40                                                   109
      d(m)=c(1)                                                              110
      m=m+1                                                                  111
      if (m.lt.27) go to 40                                                  112
      m=1                                                                    113
   50 call les (ipar)                                                        114
      if (n.eq.0.or.ndi(1).gt.mdi) go to 50                                  115
      id(m)=c(1)+.5                                                          116
      if (m.gt.1) go to 60                                                   117
      if (id(1).ne.3) go to 60                                               118
      be01=c(2)                                                              119
      be00=c(3)                                                              120
      if (be01.le.0.) be01=1.                                                121
      write (6,140) be01,be00                                                122
   60 m=m+1                                                                  123
      if (m.lt.7) go to 50                                                   124
      m=1                                                                    125
   70 call les (ipar)                                                        126
      if (n.eq.0.or.ndi(1).gt.mdi) go to 70                                  127
      idd(m)=c(1)+.5                                                         128
      m=m+1                                                                  129
      if (m.lt.3) go to 70                                                   130
      istt=10                                                                131
      ftst(1)=sr1                                                            132
c                                                                            133
   80 read (ipar,170,end=120) aw                                             134
      if (aw.eq.'*'.and.ntst.ne.0) go to 100                                 135
      if (aw.ne.'%') go to 80                                                136
      read (ipar,230) j9                                                     137
      read (ipar,230) j8                                                     138
      if (ntst.eq.0) go to 120                                               139
   90 read (ipar,170,end=120) aw                                             140
      if (aw.ne.'*') go to 90                                                141
  100 call les (ipar)                                                        142
      if (n.eq.0) go to 100                                                  143
      fd=c(1)                                                                144
      fw=c(2)                                                                145
      itst(1)=c(3)                                                           146
      ftst(1)=c(4)                                                           147
      istt=c(5)                                                              148
      itst(2)=c(6)                                                           149
      write (io,240) fd,fw,itst(1),ftst(1),istt,itst(2)                      150
  110 call les (ipar)                                                        151
      if (n.eq.0) go to 110                                                  152
      flim=c(1)                                                              153
      write (io,250) flim,ifdi,mdi                                           154
c                                                                            155
  120 ddv=.5*ddv                                                             156
      nwm=min0(nwm,ibe)                                                      157
      yzx=amin1(yzx,4.)                                                      158
      yzx=amax1(yzx,.3)                                                      159
      ydx=amin1(ydx,4.)                                                      160
      ydx=amax1(ydx,.3)                                                      161
      ny=max0(ny,7)                                                          162
      ny=min0(ny,20)                                                         163
      dc0=da0                                                                164
      call clos (ipar)                                                       165
c                                                                            166
      call such (ittest)                                                     167
c                                                                            168
      stop                                                                   169
c                                                                            170
c                                                                            171
c                                                                            172
  130 format (1x,15f3.0)                                                     173
  140 format ('   double tilt, beta(?) =',f5.2,'*value +',f6.1)              174
  150 format (/16x,33('#')/16x,'=======      P I E P      ======='/16x,'     175
     1======= VERSION ',a9,' ======='/16x,33('#')/)                          176
  160 format (' default parameters from file? (def.=yes)')                   177
  170 format (a1)                                                            178
  180 format (' parameter-file ',a20,'? (blank), otherwise name')            179
  190 format (5a12)                                                          180
  200 format (1x,72('*')/' comment: ',5a12/1x,72('*')/)                      181
  210 format ('  unsuitable parameter file'/'  version date (',a12,') mu     182
     1st be ',a9)                                                            183
  220 format (a20)                                                           184
  230 format (17x,11(a2,3x),10(/7x,13(a2,3x)))                               185
  240 format (' FD:',f8.3,', FW:',f8.3/' ITST(1):',i2,', FTST(1):',f5.3,     186
     1', ISTT:',i3,', ITST(2):',i3)                                          187
  250 format (' FLIM:',f10.2,', alog10(size):',2i4/1x,72('*')/)              188
      end                                                                    189
c #######======= 002                                                         190
      block data                                                             191
c                                                                            192
c jj1=max(max(hkl mit r=r1+-delta , hkl mit r=r2+-delta))                    193
c     muss bei grossen problemen evtl. erhoeht werden.                       194
c Jj2=maximalzahl der besten hkl-paare fuer ausgabe                          195
c jj3=zahl der befehle (darf nicht geaendert werden)                         196
c jj4=maximalzahl der datensaetze im A-speicher                              197
c                                                                            198
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20)                            199
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20)                         200
c                                                                            201
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,     202
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,        203
     2jfw                                                                    204
      common /cd1/ d1d(jj1),d2d(jj1),h1h(3,jj1),h2h(3,jj1)                   205
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                      206
      common /cgg/ gg(14,jj2),ac(jj2)/izz/izm(jj2),i6(jj3)                   207
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,         208
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,     209
     2difa,difg,dc0                                                          210
      common /j8/ j8(jj3),j9(jj3),j85(6)                                     211
      common /prz/ kp(3,3,7),kz(3,3,7),kf(7)                                 212
      common /b/ ii,jj,ila,ke,nq(jj4)                                        213
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,       214
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,       215
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                         216
      common /sb1/ jsm(7),jsml(7),ivo(2),s1(2),p7(2),p7l(2),p9(2),p8(2),     217
     1rs,holder(3)                                                           218
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                    219
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv             220
      common /cons2/ fk(7),sq3,a9                                            221
      common /tran/ acp(3,3),apc(3,3)                                        222
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                       223
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik      224
      common /ti/ titel(18),text(17),tit(18,jj4)                             225
      common /cm12/ be01,be00,rbe1,rbe0                                      226
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,      227
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                        228
      common /dd1/ jc(4,4),ncl(30),iq(27),nvv(8),iiv(7,7),inc(3,7),          229
     1kis(8,30),it1(432),it2(333),mvv(8),lvv(8),itt(20,14),isb(30),          230
     2idt(13)                                                                231
      common /xc/ xc(4),xm                                                   232
      common /dd2/ pp(4,4,6),gg6(4,4)                                        233
      common /ngk/ ngk                                                       234
      common /iskip/ iskip,isig,isig0                                        235
      common /files/ file1,file2,file3,file4,file5,fdd                       236
      character*20 file1,file2,file3,file4,file5,fdd                         237
      character*1 jsm,jsml,ivo,s1,p7,p7l,p9,p8,s4                            238
      character*2 j9,j8                                                      239
      character*3 s2                                                         240
      character*4 isys,ta0,ta0l,ta1,titel,tit,text,p6                        241
      character*5 j85                                                        242
      character rs*10,holder*11                                              243
c                                                                            244
c********                                                                    245
c             Parameters(1)                                                  246
c********                                                                    247
c                                                                            248
c IN=input unit (terminal)                                                   249
c IO=standard output unit (terminal)                                         250
c                                                                            251
      data in,io,ioa/5,6,6/                                                  252
c FD, FW : factors for sigma generation (in LDINI etc.)                      253
c     data fd,fw/.55,.5/                                                     254
      data fd,fw/.55,.65/                                                    255
c                                                                            256
c IUL=lowest logical unit for protocol file                                  257
c IUH=highest    -- ' --      protocol file                                  258
c                                                                            259
c IGL=lowest     -- ' --      lattice constant file                          260
c IGH=highest    -- ' --      lattice constant file                          261
c                                                                            262
c IRU=lowest     -- ' --      reflection file                                263
c IRO=highest    -- ' --      reflection file                                264
c                                                                            265
c    These three ranges should not overlap                                   266
c                                                                            267
      data iul,iuh,igl,igh,iru,iro/8,19,20,29,30,39/                         268
c                                                                            269
c********                                                                    270
c Parameters(2) (if no file PIEP.PAR is present)                             271
c********                                                                    272
c                                                                            273
c                                                                            274
c WIW=default value of weight for error in angle (deg.)                      275
c WIV=              -- ' --             in R1/R2(%)                          276
c WIK=              -- ' --             in camera constant(%)                277
c      for the figure of merit (sum(weight*ABS(error)))                      278
c1                                                                           279
      data wiw,wiv,wik/0.6,0.8,0.3/                                          280
c                                                                            281
c SK=default value of sigma(camera constant) (relative)                      282
c SR1=     -- ' --         (radii) (relative)                                283
c SWI=     -- ' --         (angle) (deg.)                                    284
c2                                                                           285
      data sk,sr1,swi/0.05,0.03,3.0/                                         286
c                                                                            287
c HV0=default value for high tension (volt)                                  288
c3                                                                           289
      data hv0/200000./                                                      290
c                                                                            291
c YZX=default value for ratio height/width of a character                    292
c YDX= same for lineprinter                                                  293
c3a                                                                          294
      data yzx,ydx/1.8,2.0/                                                  295
c                                                                            296
c XL : X-ray wavelength for 2-theta calculations                             297
c4                                                                           298
      data xl/1.54056/                                                       299
c                                                                            300
c DA0,CSIG0,RSIG0,ASUG0: default values for increment f,                     301
c5 default temporary errors in lattice constant determination routine        302
      data da0,csig0,rsig0,asig0/.035,.01,.01,.5/                            303
c                                                                            304
c DIFW: maximum difference in angle                                          305
c DAZB:        - " -          a/c, b/c for check of equivalence              306
c       in lattice constant determination routine                            307
c6                                                                           308
      data difw,dazb/2.,0.05/                                                309
c                                                                            310
c DDW: max. deviation of angle                                               311
c DDV: max. deviation of ratio of axes                                       312
c               in Delaunay reduction, from the value                        313
c               prescribed by crystal class                                  314
c7                                                                           315
      data ddw,ddv/4.0,0.1/                                                  316
c                                                                            317
c DIFA: max. relative difference of two lengths to be considered as          318
c        being equal (in cell parameter determination)                       319
c DIFG: max. deviation of an angel to be considered as 90 deg.               320
c        from 90 deg. (in cell parameter determination)                      321
c8                                                                           322
      data difa,difg/.001,0.2/                                               323
c                                                                            324
c VDD=default value for largest accepted deviation in volume (%)             325
c DL0=default value   sigma(radius 0. Laue zone) (absolute, mm)              326
c DW0=default value   sigma(tilt angle) (deg.)                               327
c DL1=     -- ' --         (difference radius 1.-0. Laue zone)(abs., mm)     328
c10                                                                          329
      data vdd,dl0,dw0,dl1/50.0,5.0,1.0,5.0/                                 330
c                                                                            331
c                                                                            332
c XJ,YJ: scale factors for x- and y-deflector coils                          333
      data xj,yj/.46312,.41377/                                              334
c XJH,YJH: scale factors for x- and y-deflector coils, hexadec. input        335
      data xjh,yjh/.065,.063/                                                336
c                                                                            337
c  JEM3010, 3000mm camera length                                             338
c                                                                            339
      data be01,be00/3.0,-30./                                               340
c====== INTEGERS =====                                                       341
c                                                                            342
c IHO: default type of holder: 1: double tilt, 2: rotation,                  343
c                              3: CM12 double t                              344
c                                                                            345
c MUL2: max. multiplicity of primitive mesh enforced by <LD>                 346
c                                                                            347
c NSTOP= approximate number of lattice constant generations                  348
c        between two inquiries (if ISTP=1)                                   349
c                                                                            350
c ISTT: cycles in Delaunay reduction                                         351
c                                                                            352
c LIMAX: Zeilen/Bildschirm                                                   353
c                                                                            354
c NY: lines/row for graphic representation of zone axes                      355
c                                                                            356
c IFDI: log10(maximum floating point size)                                   357
c                                                                            358
c MDI: log10(maximum integer size)                                           359
c                                                                            360
      data iho,mul2,nstop,limax,ny,istt,ifdi,mdi/1,2,10000,18,8,10,27,7/     361
c                                                                            362
c commands                                                                   363
      data j9/'CP','WT','NR','CC','R1','R2','R3','AN','EN','I ','L ','LG     364
     1','TI','A ','B ','C ','AL','BE','GA','CN','PO','IR','MU','RL','EC'     365
     2,'E1','E2','E3','EA','RW','SC','SF','PS','PG','PW','LN','H ','HV',     366
     3'OR','OD','L0','L1','D0','D1','LY','VN','VY','EV','RD','NP','S1','     367
     4AG','AP','SA','AW','AD','RN','RY','CM','PC','DC','DE','CW','BR','C     368
     5G','EQ','BP','BG','BD','CR','CD','LD','RF','SS','BS','ZA','BW','XW     369
     6','GS','GR','GC','ND','V ','DS','LW','. ','+ ','- ','* ',': ','**'     370
     7,'< ','> ','<>','LX','MP','MG','SI','CO','TG','AS','AC','AT','.1',     371
     8'.2','.3','.4','..','UN','RO','YX','NL','C0','LO','E*','SD','HH','     372
     9AX','CZ','IS','TE','JE','NC','HD','JH','OZ','AB','CS','RE','SQ','R     373
     xT','.M','LA','AI','MV','GU',4*'DU'/                                    374
      data j8/'cp','wt','nr','cc','r1','r2','r3','an','en','i ','l ','lg     375
     1','ti','a ','b ','c ','al','be','ga','cn','po','ir','mu','rl','ec'     376
     2,'e1','e2','e3','ea','rw','sc','sf','ps','pg','pw','ln','h ','hv',     377
     3'or','od','l0','l1','d0','d1','ly','vn','vy','ev','rd','np','s1','     378
     4ag','ap','sa','aw','ad','rn','ry','cm','pc','dc','de','cw','br','c     379
     5g','eq','bp','bg','bd','cr','cd','ld','rf','ss','bs','za','bw','xw     380
     6','gs','gr','gc','nd','v ','ds','lw','. ','+ ','- ','* ','/ ','**'     381
     7,'< ','> ','<>','lx','mp','mg','si','co','tg','as','ac','at','.1',     382
     8'.2','.3','.4','..','un','ro','yx','nl','c0','lo','e*','sd','hh','     383
     9ax','cz','is','te','je','nc','hd','jh','oz','ab','cs','re','sq','r     384
     xt','.m','la','ai','mv','gu',4*'du'/                                    385
c                                                                            386
c************                                                                387
c  Parameters(2) (if no file PIEP.PAR is present): end                       388
c************                                                                389
c                                                                            390
      data s4/'c','l'/                                                       391
      data jsm,p7,ta0/'P','A','B','C','R','I','F','N','Y','.   '/            392
      data jsml,p7l,ta0l/'p','a','b','c','r','i','f','n','y',',  '/          393
c                                                                            394
      data ivo,s1,p9,p8/'-','+','r','d',':','>',':','<'/                     395
      data isys/'trik','mcl.','hexa','orth','tetr','cub.'/                   396
      data j85/'    a','    b','    c','alpha',' beta','gamma'/              397
      data rs,holder/' (***)    ','double tilt','rotation h.','CM12 db.t     398
     1. '/                                                                   399
      data nu,nru,nnn,ivr,iy,ix,isf,ila,iv,iop,ngk/0,9,3*0,4*1,2,0/          400
      data irw,icm,l,ira,ine,np,lq,l7,l8,j4,lqq,ivv/2,2,2*0,8*1/             401
      data fk,sq3,r0,r0m,sr0,rl1,su1,ph,tl,vca,a9,fakr,al0,be0/1.,3*2.,      402
     13.,2.,4.,1.732050808,8*0.,999999.,57.2957795,0.,0./                    403
      data i6/1,1,0,5*1,3*0,1,0,7*1,0,10*1,0,0,1,0,1,0,1,0,0,14*1,5*0,1,     404
     11,1,0,0,1,1,0,1,0,0,0,1,0,1,9*0,1,24*0,1,1,5*0,1,3*0,1,0,1,0,0,1,      405
     29*0,1,5*0/                                                             406
      data kp/1,3*0,1,3*0,1,2,3*0,1,1,0,-1,1,1,0,-1,0,2,0,1,0,3*1,0,-1,      407
     11,3*0,2,2,1,1,-1,1,1,-1,-2,1,-1,3*1,-1,3*1,-1,0,3*1,0,3*1,0/           408
c                                                                            409
      data iskip,isig,isig0,kf,istp1,flim/0,3*1,3*2,3,2,2,2,2./              410
c                                                                            411
      data kz/1,3*0,1,3*0,1,1,3*0,1,-1,0,3*1,0,1,0,1,0,-1,0,1,1,-1,0,1,      412
     11,3*0,1,1,-1,0,0,1,-1,3*1,0,3*1,0,3*1,0,-1,3*1,-1,3*1,-1/              413
      data p6,s2/'L1-0','1/d*',' +-',';mm'/                                  414
      data an0,r1/0.,0./                                                     415
      data gg6,xc,xm/21*0./                                                  416
c                                                                            417
      data jc/0,12,13,14,12,0,23,24,13,23,0,34,14,24,34,0/,ncl/30*0/,iq/     418
     11,1,4,1,1,2,3,2,2,1,1,3,1,1,4,4,3*2,3,3,4,2,3,4,4,1/                   419
c                                                                            420
      data pp/-1.,3*0.,1.,0.,1.,2*0.,1.,2*0.,1.,2*0.,1.,-1.,3*0.,2*1.,4*     421
     10.,1.,0.,1.,2*0.,1.,-1.,3*0.,2*1.,5*0.,2*1.,0.,1.,2*0.,-1.,2*0.,2*     422
     21.,4*0.,1.,2*0.,1.,0.,1.,0.,-1.,2*0.,2*1.,5*0.,1.,0.,2*1.,3*0.,-1.     423
     3,0.,1.,0.,1.,4*0.,1.,0.,2*1.,0./                                       424
c                                                                            425
      data nvv/14,15,19,14,14,17,18,16/,iiv/0,5,6,7,2,3,4,5,0,7,6,1,4,3,     426
     16,7,0,5,4,1,2,7,6,5,0,3,2,1,2,1,4,3,0,0,0,3,4,1,2,3*0,4,3,2,1,3*0/     427
c                                                                            428
      data inc/1,3*0,1,3*0,1,3*-1,1,1,0,1,0,1,0,1,1/                         429
c                                                                            430
      data kis/0,0,14,0,2*14,1,61,0,0,3*14,0,2,61,0,4*13,0,3,65,6*12,4,      431
     166,12,0,12,0,12,34,1,51,0,3*13,24,0,5,57,2*12,14,12,2*14,6,57,0,0,     432
     214,0,14,34,1,41,0,0,2*14,24,0,2,41,0,0,14,23,0,23,13,41,0,4*13,34,     433
     37,46,12,4*13,12,4,46,0,0,14,0,24,34,1,31,0,0,14,23,24,0,2,31,0,13,     434
     42*14,13,0,4,36,0,2*13,2*23,0,7,36,12,0,14,0,12,34,8,34,12,0,14,0,      435
     514,34,9,34,0,2*13,2*23,34,7,36,12,13,2*14,13,12,4,36,12,4*13,34,3,     436
     635,0,13,14,0,24,34,1,21,0,13,14,2*23,0,10,26,0,13,14,23,13,0,28,       437
     726,0,13,2*14,13,34,11,26,0,13,14,13,14,34,12,26,0,13,14,2*23,34,       438
     810,26,12,13,2*14,13,34,11,26,12,13,14,13,14,34,12,26,12,13,14,23,      439
     924,34,1,11/                                                            440
c                                                                            441
      data it1/1,3*0,1,3*0,1,1,4*0,1,0,4*1,0,-1,1,0,1,1,2,0,3*1,0,3*1,0,     442
     11,4*0,1,1,3,2,1,-1,0,0,1,-1,4*1,3*0,1,0,1,1,2,2,1,0,0,1,3*0,1,1,-      443
     21,0,1,1,3*0,1,2*-1,-2,0,1,0,1,3*0,4*1,0,-1,0,4*-1,1,-1,3*0,1,0,1,      444
     30,0,3*1,0,0,1,3*0,1,3*0,1,0,-1,0,-1,4*0,-1,2*0,-1,0,-1,0,-1,3*0,1,     445
     43*0,1,1,4*0,1,1,3*0,1,0,-1,4*0,-1,0,-1,0,1,3*0,-1,0,-1,0,-1,2*0,-      446
     51,0,1,0,1,0,1,1,0,1,0,1,0,-1,2*0,1,0,1,0,-1,3*0,-1,1,3*0,1,3*0,2*      447
     61,3*0,-1,3*0,2*-1,3*0,1,3*0,2*-1,3*0,-1,3*0,3*1,0,0,1,1,-1,0,-1,1,     448
     71,0,0,-1,1,1,4*-1,0,0,1,1,-1,1,2*-1,1,0,0,4*-1,1,1,0,1,1,0,-1,0,1,     449
     80,0,1,1,0,-1,1,1,4*0,3*1,0,-1,1,-1,0,0,1,1,-1,0,1,1,-1,1,3*0,1,1,      450
     92*-1,1,1,3*0,-1,1,3*-1,0,1,0,1,0,1,1,2*-1,0,1,0,1,0,5*-1,1,3*0,1,      451
     x1,0,0,1,3*0,1,0,-1,0,1,0,-1,1,1,4*0,1,0,1,3*0,1,1,-1,0,0,3*1,4*0,-     452
     x1,1,0,-1,0,1,3*0,1,1,0,0,1,2,3*0,1,0,1,0,-2,-1,3*0,1,1,2,1,1,4*0,-     453
     x1/                                                                     454
c                                                                            455
      data it2/1,0,-1,1,2,3*0,1,-1,4*1,3*0,-1,1,1,2*-1,1,3*0,1,2,1,1,0,      456
     11,3*0,1,0,0,1,2,1,0,0,1,-1,6,-6,0,0,6,-6,3*3,6,6,0,0,-6,6,3,2*-3,      457
     22*-6,0,0,6,6,-3,3,-3,-6,6,0,0,2*-6,2*-3,3,3,-3,3,6,6,0,-3,3,3,2*-      458
     33,3,6,-6,0,3*3,-3,3,3,6,0,6,3,3,-3,3*3,6,0,-6,-3,3,-3,3,3,-3,0,6,      459
     46,3,-3,3,3,2*-3,0,6,-6,4*3,-3,0,3,3,3*0,6,3,0,3,3,0,-3,0,6,0,0,3,      460
     53,0,-3,3,6,0,0,3,-3,0,0,3,-3,3*6,3,3,0,0,-3,3,6,2*-6,2*-3,0,0,3,3,     461
     6-6,6,-6,-3,3,0,0,2*-3,2*-6,6,0,0,6,3,3,0,-3,3,3*0,6,3,-3,0,3,3,0,      462
     76,3*0,3,3,0,-3,3,6,3*0,-3,3,0,2*-3,0,6,0,3,0,3,3,0,-3,0,6,0,3,0,2*     463
     8-3,0,-3,0,0,6,6,0,0,2,4,-2,2,2*-2,6,6,3*0,6,4,2,-2,0,6,3*0,6,0,-3,     464
     93,6,3*0,3,3,3,0,-3,0,6,0,3,0,3*3,3*0,6,3,-3,0,-2,-4,-2,6,0,0,-4,-      465
     x8,2,2,2*-2,6,6,0,4,-4,2,4,2,-2,0,6,0,8,4,2/                            466
c                                                                            467
      data mvv/14,15,14,17,19,14,18,16/,lvv/14,14,20,22,16,21,14,23/,        468
     1itt/141,1741,1841,657,2957,3057,3157,131,934,3234,3334,121,1721,       469
     21821,3426,3526,3626,3726,3826,3926,146,1746,1846,5457,5557,5657,       470
     35757,136,935,3235,3335,126,1726,1826,5826,5926,6026,6126,6226,         471
     46326,6446,6546,6646,6757,6857,6957,7057,135,6436,6536,6636,6426,       472
     56526,6626,7126,7226,7326,7426,7526,7626,131,934,121,1721,1821,         473
     63426,3526,13*0,136,935,126,1726,1826,5826,5926,13*0,4634,934,4734,     474
     7121,4826,4926,5026,5126,5226,5326,10*0,7726,7826,7926,17*0,121,        475
     81721,1821,17*0,8021,4026,4126,17*0,8121,4226,4326,17*0,8221,4426,      476
     94526,17*0,8026,8126,8226,17*0,126,1726,1826,17*0,8326,8426,8526,       477
     x17*0/                                                                  478
c                                                                            479
      data isb/4*21,11,4,4,5*8,9*4,9*1/,idt/61,66,65,41,46,51,57,31,32,      480
     133,34,35,36/                                                           481
c                                                                            482
      end                                                                    483
c #######======= 003                                                         484
      subroutine opn (iun,ifil,ie,its)                                       485
c open and close files                                                       486
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,     487
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,        488
     2jfw                                                                    489
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                    490
      common /files/ file1,file2,file3,file4,file5,fdd                       491
      character*20 file1,file2,file3,file4,file5,file10,file20,file30,       492
     1fdd,fd1,dummy                                                          493
      character*4 isys,ta0,ta0l,ta1,p6                                       494
      character*3 s2                                                         495
      character*1 s4                                                         496
c                                                                            497
      ie=1                                                                   498
      go to (10,60,90),ifil                                                  499
c                                                                            500
c cell parameter file (read only)                                            501
   10 if (its.le.0) go to 20                                                 502
      fdd=' '                                                                503
      go to 30                                                               504
   20 write (ioa,130) file1                                                  505
      read (in,120,end=100) fdd                                              506
      if (fdd.eq.ta0.or.fdd.eq.ta0l) go to 100                               507
   30 if (fdd.eq.' ') fdd=file1                                              508
      if (file1.eq.file10) go to 20                                          509
      if (fdd.eq.file10) go to 110                                           510
      file10=fdd                                                             511
      open (iun,file=file10,status='OLD')                                    512
      m=0                                                                    513
   40 read (iun,120,end=50) dummy                                            514
      m=m+1                                                                  515
      go to 40                                                               516
   50 m=m/3                                                                  517
      write (ioa,150) file10,m                                               518
      return                                                                 519
c                                                                            520
c SAD file (read/write)                                                      521
   60 if (its.le.0) go to 70                                                 522
      fd1=' '                                                                523
      go to 80                                                               524
   70 write (ioa,140) file2                                                  525
      read (in,120,end=100) fd1                                              526
      if (fd1.eq.ta0.or.fd1.eq.ta0l) go to 100                               527
   80 file20=fd1                                                             528
      if (file20.eq.' ') file20=file2                                        529
      open (unit=iun,file=file20,status='UNKNOWN')                           530
      return                                                                 531
c                                                                            532
c protokol file (write only)                                                 533
c  90 write (ioa,150) file3                                                  534
c     read (in,120,end=100) fd1                                              535
c     if (fd1.eq.ta0.or.fd1.eq.ta0l) go to 100                               536
c     file30=fd1                                                             537
c     if (file30.eq.' ') file30=file3                                        538
c     open (unit=iun,file=file30,status='UNKNOWN')                           539
   90 iun=8                                                                  540
c  90 iun=6                                                                  541
      return                                                                 542
c                                                                            543
  100 ie=0                                                                   544
      return                                                                 545
  110 ie=2                                                                   546
      return                                                                 547
c                                                                            548
c #######======= 004                                                         549
      entry clos(iun)                                                        550
c close file iun                                                             551
      close (iun)                                                            552
      return                                                                 553
c                                                                            554
c                                                                            555
c                                                                            556
  120 format (a20)                                                           557
  130 format (1x,'cell parameter file? def.:  ',a20,';  "," or "." to es     558
     1cape')                                                                 559
  140 format (1x,'SAD-data file? def.: ',a20,';  "." or "," to escape')      560
  150 format (1x,72('-')/2x,'cell parameter file assigned: ',a20,',',i6,     561
     1' sets')                                                               562
      end                                                                    563
c #######======= 005                                                         564
      subroutine edit (iun,lx,ibr)                                           565
c output current data (work area)                                            566
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20)                            567
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20)                         568
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,     569
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,        570
     2jfw                                                                    571
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,         572
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,     573
     2difa,difg,dc0                                                          574
      common /b/ ii,jj,ila,ke,nq(jj4)                                        575
      common /sb1/ jsm(7),jsml(7),ivo(2),s1(2),p7(2),p7l(2),p9(2),p8(2),     576
     1rs,holder(3)                                                           577
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                    578
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv             579
      common /cons2/ fk(7),sq3,a9                                            580
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,       581
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,       582
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                         583
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik      584
      common /ti/ titel(18),text(17),tit(18,jj4)                             585
      common /j8/ j8(jj3),j9(jj3),j85(6)                                     586
      common /iskip/ iskip,isig,isig0                                        587
      dimension cl0(2)                                                       588
      character*7 cl0                                                        589
      character*1 jsm,jsml,ivo,s1,p7,p7l,p9,p8,aw,aw1,s4                     590
      character*3 s2                                                         591
      character*4 isys,titel,tit,text,ta1,ta0,ta0l,p6                        592
      character*2 j8,j9                                                      593
      character*5 j85                                                        594
      character rs*10,holder*11                                              595
      data cl0/';   L0:',';  phi:'/                                          596
      ish=0                                                                  597
      ilb=ila                                                                598
      ihot=an0                                                               599
      if (ibr.eq.51) ilb=1                                                   600
      if (iop.eq.0) go to 10                                                 601
      if (ibr.ne.51.and.ibr.ne.54) go to 10                                  602
      if (iop.gt.1) return                                                   603
      ish=1                                                                  604
c      write (6,*) iun,iun,iun,iun,iun                                       605
      go to 30                                                               606
c                                                                            607
   10 go to (20,40),lx                                                       608
cioioio!!!  ok                                                               609
   20 if (ta1.ne.'    ') write (iun,70) ta1,(text(i),i=1,16)                 610
      g(2)=r1                                                                611
      g(3)=dr1                                                               612
      g(4)=r2                                                                613
      g(5)=dr2                                                               614
      g(6)=amax1(r3,.001)                                                    615
      g(7)=amax1(dr3,.001)                                                   616
      g(8)=rl1                                                               617
      g(9)=su1                                                               618
      g(10)=ak                                                               619
      g(11)=dak                                                              620
      g(12)=amin1(r0,99999.)                                                 621
      aw=p9(j4)                                                              622
      aw1=p8(j4)                                                             623
c                                                                            624
      v3=vca+vca                                                             625
      v4=v3+vca                                                              626
      v5=v4+vca                                                              627
      vv=fk(ilb)*vca                                                         628
c                                                                            629
      if (np.eq.1) go to 30                                                  630
      g(3)=amin1(99.99,g(3)*ak/g(2)**2)                                      631
      g(5)=amin1(99.99,g(5)*ak/g(4)**2)                                      632
      g(7)=amin1(99.99,g(7)*ak/g(6)**2)                                      633
      g(2)=amin1(9999.99,ak/g(2))                                            634
      g(4)=amin1(9999.99,ak/g(4))                                            635
      g(6)=amin1(9999.99,ak/g(6))                                            636
      g(8)=vca*sin(wi*fak)/(g(2)*g(4))                                       637
      g(9)=0.                                                                638
      if (g(8).gt..0001) g(9)=ak/g(8)                                        639
      g(10)=akl                                                              640
      g(11)=amin1(999.99,akl*dak/ak)                                         641
      g(12)=ph                                                               642
      aw=p8(j4)                                                              643
c                                                                            644
   30 if (ibr.eq.51.and.ish.eq.0) write (iun,110)                            645
      if (iy.lt.2) write (iun,50) dg(1),dg(2),dg(3),dgw,jsm(ila),v0,         646
     1isys(ke+1),rg(1),rg(2),rg(3),rgw,jsm(ilb),rs                           647
c                                                                            648
      if (mbr(ke,ila).ne.0) write (iun,130) jsm(ila),isys(ke+1),j9(62)       649
c                                                                            650
      write (iun,140)                                                        651
c                                                                            652
      if (ish.eq.1) return                                                   653
c                                                                            654
      write (iun,70) titel                                                   655
c                                                                            656
      write (iun,80) s1(np),g(2),g(3),wi,dwi,cl0(np),g(12),viw,s1(np),       657
     1g(4),g(5),s4(np),g(10),g(11),p6(np),aw,g(8),viv,s1(np),g(6),g(7),      658
     2hv,jsm(ilb),aw1,vv,vik                                                 659
      if (ihot.ne.0) write (iun,60) holder(ihot),an1,an2                     660
c                                                                            661
      if (ibr.eq.51.and.vca.gt.0.) write (iun,100) aw1,vca,aw1,v3,aw1,       662
     1v4,aw1,v5                                                              663
c                                                                            664
   40 nbs=nbb                                                                665
      icj=icm                                                                666
      if (icj.eq.0) icj=99999                                                667
      if (iskip.eq.1) nbs=-nbs                                               668
      if (isig.ne.2) write (iun,90) icj,jsm(ilb),j9(24),ira,p7(irw),         669
     1j9(3),nbs                                                              670
      if (isig.eq.2) write (iun,120) icj,jsm(ilb),j9(24),ira,p7(irw),        671
     1j9(3),nbs,j9(121)                                                      672
      if (ibr.eq.51.and.ish.eq.0) write (iun,110)                            673
      return                                                                 674
c                                                                            675
c                                                                            676
c                                                                            677
   50 format (1x,'dir.lc.:',3f9.4,3f7.2,', V(',a1,'):',f8.1,1x,a4/1x,'re     678
     1c.lc.:',3f9.6,3f7.2,', SG. ',a1,a10)                                   679
   60 format (10x,a11,' :',2f10.2,'  (beta, alpha)')                         680
   70 format (19a4)                                                          681
   80 format (3x,a1,'1:',f7.2,' +-',f5.2,'; ang.:',f8.2,' +-',f6.2,a7,       682
     1f8.2,'; wgt(angle):',f4.1/3x,a1,'2:',f7.2,' +-',f5.2,'; c.',a1,'.:     683
     2',f8.2,' +-',f6.2,'; ',a4,a1,f8.2,'; wgt(r1/r2):',f4.1/3x,a1,'3:',     684
     3f7.2,' +-',f5.2,'; volt:',f12.0,'     ; V(',a1,')',a1,f8.1,'; wgt(     685
     4c.c.) :',f4.1)                                                         686
   90 format (1x,'mul.:',i5,', cent.:',a1,', ',a2,':',i2,', rewind: ',       687
     1a1,', ',a2,': ',i5)                                                    688
  100 format (3x,'V(P)',a1,f9.1,', V(A,B,C,I)',a1,f9.1,', V(R)',a1,f9.1,     689
     1', V(F)',a1,f9.1)                                                      690
  110 format (1x,60('=')/)                                                   691
  120 format (1x,'mul.:',i3,', cent.:',a1,', ',a2,':',i2,', rewind: ',       692
     1a1,', ',a2,': ',i5,',  ** temp. sigmas! ** <',a2,'>')                  693
  130 format (/4x,'*** centering ',a1,' not permitted for ',a4,', if app     694
     1licable use <',a2,'> ***')                                             695
  140 format (' ')                                                           696
      end                                                                    697
c #######======= 006                                                         698
      subroutine atoh (n)                                                    699
c work area > A-memory                                                       700
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20)                            701
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20)                         702
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,       703
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,       704
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                         705
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                       706
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv             707
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik      708
      common /b/ ii,jj,ila,ke,nq(jj4)                                        709
      common /ti/ titel(18),text(17),tit(18,jj4)                             710
      dimension c(39)                                                        711
      dimension icc(8)                                                       712
      equivalence (c(1),ak), (icc(1),lq)                                     713
      character*4 tit,titel,text                                             714
      do 10 i=1,39                                                           715
   10   rf(i,n)=c(i)                                                         716
      rf(40,n)=0.                                                            717
c    hier auch noch V2?                                                      718
      do 20 i=1,18                                                           719
   20   tit(i,n)=titel(i)                                                    720
      do 30 i=1,8                                                            721
   30   irf(i,n)=icc(i)                                                      722
      return                                                                 723
c                                                                            724
c #######======= 007                                                         725
      entry htoa(n)                                                          726
c A-memory > work area                                                       727
      do 40 i=1,39                                                           728
   40   c(i)=rf(i,n)                                                         729
      do 50 i=1,18                                                           730
   50   titel(i)=tit(i,n)                                                    731
      do 60 i=1,8                                                            732
   60   icc(i)=irf(i,n)                                                      733
      return                                                                 734
      end                                                                    735
c #######======= 008                                                         736
      subroutine ltoh (jsm,ila,rs,in,ioa,text,ta1,dg,dgw)                    737
c cell parameters > B-memory                                                 738
      parameter (jj6=40)                                                     739
c                                                                            740
      dimension jsm(7), text(17), dg(6), dgw(3)                              741
      common /bmem/ rss(jj6),nam1(jj6),nam2(17,jj6),la(jj6),dgg(3,jj6),      742
     1dggw(3,jj6),adel(3,3,jj6),bdel(3,3,jj6)                                743
      common /tran/ acp(3,3),apc(3,3)                                        744
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)/ngk/ngk              745
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                   746
      common /files/ file1,file2,file3,file4,file5,fdd                       747
      character*4 nam1,nam2,text,ta1                                         748
      character*1 jsm                                                        749
      character* 10rs,rss                                                    750
      character*20 file1,file2,file3,file4,file5,fdd                         751
c                                                                            752
      n=1                                                                    753
      if (ngk.lt.nlc) go to 10                                               754
      write (ioa,90) nlc                                                     755
      write (ioa,100) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j)),      756
     1rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,nlc)                              757
      write (ioa,110)                                                        758
      call les (in)                                                          759
      if (n.eq.0.or.ndi(1).gt.mdi) return                                    760
      i=c(1)                                                                 761
      if (i.le.nlc.and.i.gt.0) go to 20                                      762
      n=0                                                                    763
      return                                                                 764
   10 ngk=ngk+1                                                              765
      i=ngk                                                                  766
   20 write (ioa,120)                                                        767
      read (in,130,end=80) nam1(i),(nam2(j,i),j=1,17)                        768
      if (nam1(i).ne.'    ') go to 40                                        769
      nam1(i)=ta1                                                            770
      do 30 j=1,17                                                           771
   30   nam2(j,i)=text(j)                                                    772
   40 do 50 j=1,3                                                            773
        dgg(j,i)=dg(j)                                                       774
   50   dggw(j,i)=dgw(j)                                                     775
c                                                                            776
      la(i)=ila                                                              777
      rss(i)=rs                                                              778
      do 70 k=1,3                                                            779
        do 60 j=1,3                                                          780
          bdel(j,k,i)=apc(j,k)                                               781
   60     adel(j,k,i)=acp(j,k)                                               782
   70 continue                                                               783
      return                                                                 784
   80 ngk=ngk-1                                                              785
      n=0                                                                    786
      return                                                                 787
c                                                                            788
c                                                                            789
c                                                                            790
   90 format (' capacity (',i2,') exhausted')                                791
  100 format (1x,i2,1x,3f8.3,3f7.2,1x,a1,a10,4a4)                            792
  110 format (' replace  #')                                                 793
  120 format (' label? (col.1-4: identifier)')                               794
  130 format (18a4)                                                          795
      end                                                                    796
c #######======= 009                                                         797
      subroutine htol (dg,dgw,jsm,ila,rs,in,io,ioa,text,ta1)                 798
      parameter (jj6=40)                                                     799
      dimension dg(6), dgw(3), jsm(7), text(17)                              800
      common /bmem/ rss(jj6),nam1(jj6),nam2(17,jj6),la(jj6),dgg(3,jj6),      801
     1dggw(3,jj6),adel(3,3,jj6),bdel(3,3,jj6)                                802
      common /tran/ acp(3,3),apc(3,3)                                        803
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                      804
      common /ngk/ ngk                                                       805
      character*4 nam1,nam2,text,ta1                                         806
      character*1 jsm                                                        807
      character* 10rs,rss                                                    808
c                                                                            809
c cell parameters B-memory > work area                                       810
      if (ngk.gt.0) go to 10                                                 811
      write (ioa,80)                                                         812
      n=0                                                                    813
      return                                                                 814
   10 write (io,70) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j)),        815
     1rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,ngk)                              816
      if (io.ne.ioa) write (ioa,70) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,      817
     13),jsm(la(j)),rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,ngk)                818
      n=1                                                                    819
      write (ioa,90)                                                         820
      call les (in)                                                          821
      if (n.eq.0.or.ndi(1).gt.mdi) return                                    822
      j=c(1)                                                                 823
      if (j.le.ngk.and.j.gt.0) go to 20                                      824
      n=0                                                                    825
      return                                                                 826
   20 do 30 i=1,3                                                            827
        dg(i)=dgg(i,j)                                                       828
   30   dgw(i)=dggw(i,j)                                                     829
c                                                                            830
      ila=la(j)                                                              831
      rs=rss(j)                                                              832
      ta1=nam1(j)                                                            833
      do 40 i=1,17                                                           834
   40   text(i)=nam2(i,j)                                                    835
      do 60 i=1,3                                                            836
        do 50 k=1,3                                                          837
          apc(k,i)=bdel(k,i,j)                                               838
   50     acp(k,i)=adel(k,i,j)                                               839
   60 continue                                                               840
      return                                                                 841
c                                                                            842
c                                                                            843
c                                                                            844
   70 format (1x,i2,1x,3f8.3,3f7.2,1x,a1,a10,4a4)                            845
   80 format (' no data')                                                    846
   90 format (' load #')                                                     847
      end                                                                    848
c #######======= 010                                                         849
      subroutine dlgk (jsm,in,ioa,ibr,jfw)                                   850
c                                                                            851
c deletes cell parameters from B-memory                                      852
c                                                                            853
      parameter (jj6=40)                                                     854
      dimension jsm(7)                                                       855
      common /bmem/ rss(jj6),nam1(jj6),nam2(17,jj6),la(jj6),dgg(3,jj6),      856
     1dggw(3,jj6),adel(3,3,jj6),bdel(3,3,jj6)                                857
c                                                                            858
      common /tran/ acp(3,3),apc(3,3)                                        859
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                      860
      common /ngk/ ngk                                                       861
      character*4 nam1,nam2                                                  862
      character*1 jsm,aw                                                     863
      character* 10rss                                                       864
      logical law                                                            865
c                                                                            866
      m=0                                                                    867
      if (ngk.gt.0) go to 20                                                 868
      write (ioa,140)                                                        869
   10 n=0                                                                    870
      return                                                                 871
c                                                                            872
   20 do 30 j=1,ngk                                                          873
cio   30   write (ioa,130) j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j     874
cio     1   rss(j),nam1(j),(nam2(i,j),i=1,3)                                 875
        write (6,130) j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j)),       876
     1   rss(j),nam1(j),(nam2(i,j),i=1,3)                                    877
   30   if (jfw.ne.0) write (88,130) j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,      878
     1   3),jsm(la(j)),rss(j),nam1(j),(nam2(i,j),i=1,3)                      879
      if (m.eq.2) return                                                     880
c                                                                            881
      n=1                                                                    882
      if (ibr.eq.77) return                                                  883
      write (ioa,150)                                                        884
      call les (in)                                                          885
      if (n.eq.0.or.ndi(1).gt.mdi) return                                    886
      k=c(1)                                                                 887
      if (k.lt.0) go to 90                                                   888
      if (k.gt.ngk.or.k.eq.0) go to 10                                       889
      if (k.eq.ngk) go to 80                                                 890
      do 70 i=k,ngk-1                                                        891
        do 40 ii=1,3                                                         892
          dgg(ii,i)=dgg(ii,i+1)                                              893
   40     dggw(ii,i)=dggw(ii,i+1)                                            894
c                                                                            895
        la(i)=la(i+1)                                                        896
        rss(i)=rss(i+1)                                                      897
        nam1(i)=nam1(i+1)                                                    898
        do 50 j=1,17                                                         899
   50     nam2(j,i)=nam2(j,i+1)                                              900
        do 70 j=1,3                                                          901
        do 60 ii=1,3                                                         902
          bdel(ii,j,i)=bdel(ii,j,i+1)                                        903
   60     adel(ii,j,i)=adel(ii,j,i+1)                                        904
   70 continue                                                               905
   80 ngk=ngk-1                                                              906
cio      write (ioa,130) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j)     907
cio     1rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,ngk)                           908
      write (6,130) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j)),        909
     1rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,ngk)                              910
      if (jfw.ne.0) write (88,130) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3)     911
     1,jsm(la(j)),rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,ngk)                  912
      return                                                                 913
c                                                                            914
   90 write (6,160)                                                          915
      read (in,170,end=100) aw                                               916
      if (law(aw)) go to 110                                                 917
      ngk=0                                                                  918
  100 return                                                                 919
  110 m=2                                                                    920
      write (6,120)                                                          921
      go to 20                                                               922
c                                                                            923
c                                                                            924
c                                                                            925
  120 format (' * no action *')                                              926
  130 format (1x,i2,1x,3f8.3,3f7.2,1x,a1,a10,4a4)                            927
  140 format (' no data')                                                    928
  150 format (' delete #  (<0: all)')                                        929
  160 format ('   are you sure?')                                            930
  170 format (a1)                                                            931
      end                                                                    932
c #######======= 011                                                         933
      subroutine htof (jsm,in,ioa,isl,if4,nsc,file)                          934
c cell parameters from B-memory to file                                      935
      parameter (jj6=40)                                                     936
c                                                                            937
      dimension jsm(7)                                                       938
      common /bmem/ rss(jj6),nam1(jj6),nam2(17,jj6),la(jj6),dgg(3,jj6),      939
     1dggw(3,jj6),adel(3,3,jj6),bdel(3,3,jj6)                                940
c   hier war "ni"                                                            941
c                                                                            942
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                      943
      common /ngk/ ngk                                                       944
      common /files/ file1,file2,file3,file4,file5,fdd                       945
      character*4 nam1,nam2,nam3                                             946
      character*1 jsm,aw                                                     947
      character* 10rss                                                       948
      character*20 file1,file2,file3,file4,file5,file,fdd                    949
      logical law                                                            950
c                                                                            951
      if (ngk.le.0) go to 90                                                 952
      write (ioa,130) (j,(dgg(k,j),k=1,3),(dggw(k,j),k=1,3),jsm(la(j)),      953
     1rss(j),nam1(j),(nam2(i,j),i=1,3),j=1,ngk)                              954
c                                                                            955
      n=1                                                                    956
   10 write (ioa,160)                                                        957
      call les (in)                                                          958
      if (n.eq.0.or.ndi(1).gt.mdi) return                                    959
      j=c(1)                                                                 960
      if (j.gt.ngk.or.j.eq.0) go to 100                                      961
      if (if4.eq.1) go to 50                                                 962
      write (ioa,170) file5                                                  963
      read (in,180,end=100) file                                             964
      if (file.eq.'. '.or.file.eq.', ') go to 100                            965
      if (file.eq.'    ') file=file5                                         966
      write (ioa,200)                                                        967
c                                                                            968
      read (in,210,end=100) aw                                               969
      if (.not.law(aw)) go to 40                                             970
c                                                                            971
      write (6,110) file                                                     972
      read (in,210,end=100) aw                                               973
      if (law(aw)) go to 10                                                  974
      open (unit=isl,file=file,status='OLD')                                 975
      rewind isl                                                             976
      i=0                                                                    977
   20 read (isl,140,end=30) nam3                                             978
      if (nam3.eq.'END$') go to 30                                           979
      read (isl,140,end=30)                                                  980
      read (isl,140,end=30)                                                  981
      i=i+1                                                                  982
      go to 20                                                               983
   30 nsc=i                                                                  984
      write (6,220) i,file                                                   985
      if4=1                                                                  986
      go to 50                                                               987
   40 write (6,120)                                                          988
      read (in,210,end=100) aw                                               989
      if (law(aw)) go to 10                                                  990
      open (unit=isl,file=file,status='UNKNOWN')                             991
      if4=1                                                                  992
      go to 70                                                               993
   50 rewind isl                                                             994
      nsc3=3*nsc                                                             995
      do 60 i=1,nsc3                                                         996
   60   read (isl,180,end=70)                                                997
   70 if (j.lt.0) go to 80                                                   998
      write (isl,190) nam1(j),(nam2(i,j),i=1,17),(dgg(k,j),k=1,3),           999
     1(dggw(k,j),k=1,3),jsm(la(j)),rss(j)                                   1000
      nsc=nsc+1                                                             1001
      return                                                                1002
   80 write (isl,190) (nam1(j),(nam2(i,j),i=1,17),(dgg(k,j),k=1,3),         1003
     1(dggw(k,j),k=1,3),jsm(la(j)),rss(j),j=1,ngk)                          1004
      nsc=nsc+ngk                                                           1005
      return                                                                1006
   90 write (ioa,150)                                                       1007
  100 n=0                                                                   1008
      return                                                                1009
c                                                                           1010
c                                                                           1011
c                                                                           1012
  110 format ('  File "',a20,'" has to exist, new sets will be appended.    1013
     1 ok?')                                                                1014
  120 format ('  If this file already exists it will be overwritten! ok?    1015
     1')                                                                    1016
  130 format (1x,i2,1x,3f8.3,3f7.2,1x,a1,a10,4a4)                           1017
  140 format (18a4)                                                         1018
  150 format (' no data')                                                   1019
  160 format (' save # (<0: all)')                                          1020
  170 format (' filename? (not yet assigned!) (def.:',a20,'"." or "," to    1021
     1 escape)')                                                            1022
  180 format (a20)                                                          1023
  190 format (18a4/3f9.3,3f7.2/a1,a10)                                      1024
  200 format (' Is this file new or - if not - may it be overwritten?')     1025
  210 format (a1)                                                           1026
  220 format ('  New sets have been appended to set #',i5,' of file ',      1027
     1a20/'  (prior to further save operations this message is suppresse    1028
     2d)')                                                                  1029
      end                                                                   1030
c #######======= 012                                                        1031
      subroutine clt (text)                                                 1032
c  clear text                                                               1033
      dimension text(17)                                                    1034
      character*4 text                                                      1035
      do 10 i=1,17                                                          1036
   10   text(i)='    '                                                      1037
      return                                                                1038
      end                                                                   1039
c #######======= 013                                                        1040
      subroutine pos (n3,ipos,nrr,j)                                        1041
c controls SAD-file                                                         1042
      n31=n3-ipos                                                           1043
      if (n31) 10,40,20                                                     1044
c     if (n31) 1,1,2                                                        1045
   10 rewind nrr                                                            1046
      n31=n3-1                                                              1047
      if (n31.eq.0) return                                                  1048
   20 j3=j*n31                                                              1049
      do 30 i=1,j3                                                          1050
   30   read (nrr,50)                                                       1051
   40 return                                                                1052
c                                                                           1053
c                                                                           1054
c                                                                           1055
   50 format (a1)                                                           1056
      end                                                                   1057
c #######======= 014                                                        1058
      function ra (r0,c,i,a,v)                                              1059
c L.z.1 - L.z.0                                                             1060
      b=c/a                                                                 1061
      d=atan(r0/b)                                                          1062
      e=cos(d)-v*float(i)/b                                                 1063
      ra=b*tan(arco(e)-d)                                                   1064
      return                                                                1065
      end                                                                   1066
c #######======= 015                                                        1067
      integer function mbr(ke,ila)                                          1068
c admissibility of centering                                                1069
c trk:all, (mkl.,orh.):all except R, tetr.: C,I,F, hex.:R, kub.:I,F         1070
      mbr=0                                                                 1071
      if (ila.eq.1.or.ke.eq.0) return                                       1072
      if (ila.gt.5.and.ke.ne.2) return                                      1073
      if (ila.eq.5.and.ke.eq.2) return                                      1074
      if (ila.eq.5) go to 10                                                1075
      if (ke.eq.1.or.ke.eq.3) return                                        1076
      if (ila.eq.4.and.ke.eq.4) return                                      1077
   10 mbr=1                                                                 1078
      return                                                                1079
      end                                                                   1080
c #######======= 016                                                        1081
      subroutine resto (isr,ihv)                                            1082
c calculates additional values from restored parameters                     1083
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20,jj5=100)                   1084
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20,jj5=100)                1085
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    1086
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       1087
     2jfw                                                                   1088
      common /b/ ii,jj,ila,ke,nq(jj4)                                       1089
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      1090
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      1091
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        1092
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        1093
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    1094
     2difa,difg,dc0                                                         1095
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                   1096
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv            1097
      common /cons2/ fk(7),sq3,a9                                           1098
      common /ti/ titel(18),text(17),tit(18,jj4)                            1099
      common /its/ ftst(9),itst(9)                                          1100
      character*3 s2                                                        1101
      character*1 s4                                                        1102
      character*4 isys,titel,tit,text,ta1,ta0,ta0l,p6                       1103
      lq=lqq                                                                1104
      iv=ivv                                                                1105
      if (isr.eq.0) go to 10                                                1106
      if (r0m.ne.0.) go to 10                                               1107
      lq=1                                                                  1108
      iv=1                                                                  1109
c? 10 if (r0.lt.0.) r0=a9                                                   1110
   10 if (sr0.lt..0001) sr0=dl0                                             1111
c?    if (r0.eq.a9) sr0=0.                                                  1112
      rl1=abs(r0m)                                                          1113
      j4=1                                                                  1114
      if (r0m.lt.0.) j4=2                                                   1115
      if (su1.lt..0001) su1=dl1                                             1116
      if (j4.eq.2) su1=0.                                                   1117
      s1u=amax1(0.1,rl1-su1)                                                1118
      s1o=rl1+su1                                                           1119
      if (j4.eq.2) s1o=1.e20                                                1120
      l7=1                                                                  1121
      if (rl1.gt.0.) l7=2                                                   1122
      aku2=(amax1(.2*ak,ak-dak))**2                                         1123
      ako2=(ak+dak)**2                                                      1124
      if (hv.le.0.) hv=hv0                                                  1125
      ihv=jhv(hv)                                                           1126
      ala=alam(hv)                                                          1127
      if (itst(2).ne.0) write (ioa,20)                                      1128
      return                                                                1129
c                                                                           1130
c                                                                           1131
c                                                                           1132
   20 format ('  RESTORE')                                                  1133
      end                                                                   1134
c #######======= 017                                                        1135
      subroutine prep1                                                      1136
c additional quantities for SAD data from file                              1137
c                                                                           1138
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    1139
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       1140
     2jfw                                                                   1141
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      1142
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      1143
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        1144
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     1145
      common /its/ ftst(9),itst(9)                                          1146
c                                                                           1147
      du(1)=(amax1(0.1,r1-dr1))**2/ako2                                     1148
      du(2)=(amax1(0.1,r2-dr2))**2/ako2                                     1149
      do(1)=(r1+dr1)**2/aku2                                                1150
      do(2)=(r2+dr2)**2/aku2                                                1151
      sa=wi*fak                                                             1152
      sb=dwi*fak                                                            1153
      cw1=cos(sa)                                                           1154
      if (cw1.eq.0.) cw1=1.e-15                                             1155
      w=cos(sa+sb)                                                          1156
      v=cos(amax1(0.,sa-sb))                                                1157
      if (wi+dwi.ge.180.) w=-1.                                             1158
      if (wi.lt.dwi) v=1.                                                   1159
      wo=amax1(abs(w),abs(v))                                               1160
      wu=amin1(abs(w),abs(v))                                               1161
      if (w*v.le.0.) wu=0.                                                  1162
      d4=sqrt(amax1(do(1),do(2)))                                           1163
      if (itst(2).ne.0) write (ioa,10)                                      1164
      return                                                                1165
c                                                                           1166
c                                                                           1167
c                                                                           1168
   10 format ('  PREP1')                                                    1169
      end                                                                   1170
c #######======= 018                                                        1171
      function jhv (hv)                                                     1172
c high tension in kV                                                        1173
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     1174
      jhv=min1(.5+hv*.001,10.**mdi)                                         1175
      return                                                                1176
      end                                                                   1177
c #######======= 019                                                        1178
      subroutine les (in)                                                   1179
c subr. for interpretation of free format and check in col.1                1180
c                                                                           1181
c The labeled common /cc/ contains the following values                     1182
c ifu    : indicator: protokol file 1 assigned (1=yes)                      1183
c iou    : logical unit for protocol file 1                                 1184
c koma   : If = 1:  ',' interpreted as decimal '.' (in addition)            1185
c ifdi   : max. exponent of 10 for floating point                           1186
c mdi    : max. exponent of 10 for integers                                 1187
c          For mdi .gt. 7 the last digit is not reliable.                   1188
c c(15)  : the numbers, tailing numbers are zeroed                          1189
c ndi(15): ndi(i)=iabs(int(alog10(c(i))))                                   1190
c ie  : 0: all normal                                                       1191
c       1: non numeric symbol in col. 1                                     1192
c       2: at least one abs(c(i)) > 10**ifdi or < 10**(-ifdi)               1193
c       3: end of file                                                      1194
c       4: misplaced "." or "-"                                             1195
c remark: interpretation stops after the first occurence of b(13)(;)        1196
c         the remaining c's are zeroed. Any other character except          1197
c         figures, "." and "-" is a separator between two numbers.          1198
c                                                                           1199
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),ier,ndi(15)                   1200
      common /xc/ xc(4),xm                                                  1201
      dimension k(15), a(70), f(15), b(15)                                  1202
      character*1 b,a                                                       1203
      data b/'1','2','3','4','5','6','7','8','9','0','.','-',';',' ','!'    1204
     1/                                                                     1205
c             ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^     1206
c             1   2   3   4   5   6   7   8   9  10  11  12  13  14  15     1207
      data ioa/6/                                                           1208
      read (in,220,end=180) a                                               1209
      if (ifu.gt.0.and.in.eq.5) write (iou,260) a                           1210
      ier=1                                                                 1211
c     ie=0                                                                  1212
      i1=1                                                                  1213
ccccc                                                                       1214
      if (koma.eq.1.and.a(1).eq.',') a(1)='.'                               1215
ccccc                                                                       1216
      do 10 i=1,15                                                          1217
        if (a(1).eq.b(i)) go to 20                                          1218
   10 continue                                                              1219
      ier=0                                                                 1220
c     ie=1                                                                  1221
      return                                                                1222
   20 do 30 i=1,15                                                          1223
        ndi(i)=0                                                            1224
   30   c(i)=0.                                                             1225
      if (a(1).eq.b(15)) go to 200                                          1226
      n=0                                                                   1227
      i2=1                                                                  1228
      im=1                                                                  1229
      i0=1                                                                  1230
      do 140 i=1,70                                                         1231
ccccc                                                                       1232
        if (koma.eq.1.and.a(i).eq.',') a(i)='.'                             1233
ccccc                                                                       1234
        if (a(i).eq.' ') go to 130                                          1235
        do 40 j=1,13                                                        1236
          if (a(i).eq.b(j)) go to (50,60),i2                                1237
   40   continue                                                            1238
        go to 130                                                           1239
c                                                                           1240
   50   if (j.eq.10) i0=2                                                   1241
        i2=2                                                                1242
        if (n.eq.15) go to 150                                              1243
        n=n+1                                                               1244
        k(n)=0                                                              1245
        i1=1                                                                1246
        f(n)=1.                                                             1247
   60   if (j-11) 70,110,120                                                1248
   70   if (j.eq.10.and.i0.eq.2) go to 80                                   1249
        i0=1                                                                1250
        ndi(n)=ndi(n)+1                                                     1251
        if (ndi(n).gt.ifdi) go to 90                                        1252
   80   c(n)=10.*c(n)+float(mod(j,10))                                      1253
        go to (140,100),i1                                                  1254
   90   if (iabs(ndi(n)-k(n)).gt.ifdi) go to 170                            1255
        go to 140                                                           1256
c                                                                           1257
  100   k(n)=k(n)+1                                                         1258
        go to 140                                                           1259
c                                                                           1260
  110   if (i1.eq.2) go to 190                                              1261
        i1=2                                                                1262
        i0=1                                                                1263
        go to 140                                                           1264
c                                                                           1265
  120   if (j.eq.13) go to 150                                              1266
        if (c(n).gt.0..or.i1.eq.2) go to 190                                1267
        if (im.eq.2.or.i0.eq.2) go to 190                                   1268
        f(n)=-1.                                                            1269
        im=2                                                                1270
        go to 140                                                           1271
c                                                                           1272
  130   i2=1                                                                1273
        i0=1                                                                1274
        im=1                                                                1275
  140 continue                                                              1276
  150 if (n.eq.0) return                                                    1277
      do 160 i=1,n                                                          1278
        c(i)=f(i)*c(i)/10.**k(i)                                            1279
  160   ndi(i)=ndi(i)-k(i)                                                  1280
      return                                                                1281
  170 ier=0                                                                 1282
c     ie=2                                                                  1283
      write (ioa,230) ifdi                                                  1284
      return                                                                1285
  180 ier=0                                                                 1286
c     ie=3                                                                  1287
      write (ioa,240)                                                       1288
      return                                                                1289
  190 ier=0                                                                 1290
c     ie=4                                                                  1291
      write (ioa,250)                                                       1292
      return                                                                1293
  200 c(1)=xc(1)                                                            1294
      do 210 i=2,4                                                          1295
  210   if (a(2).eq.b(i)) c(1)=xc(i)                                        1296
c      if (a(2).eq.b(15)) c(1)=xm                                           1297
      if (a(2).eq.'m'.or.a(2).eq.'M') c(1)=xm                               1298
      return                                                                1299
c                                                                           1300
c                                                                           1301
c                                                                           1302
  220 format (80a1)                                                         1303
  230 format (' real number exceeds 10**(+-)',i2)                           1304
  240 format (' command not executed or end of file')                       1305
  250 format (' misplaced "." or "-"')                                      1306
  260 format (1x,'===>> ',70a1)                                             1307
      end                                                                   1308
c #######======= 020                                                        1309
      subroutine delc (ngkk,rs,rs0,ier,isy,id33,idid)                       1310
c Delaunay reduction, scan through mem. C                                   1311
      parameter (jj5=100)                                                   1312
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     1313
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     1314
      common /srsr/ imx(jj5),xna(jj5),xnb(jj5),xnc(jj5),x1,x2,x3,           1315
     1ffom(jj5),dgld(6,jj5),vld(jj5),azb(jj5),czb(jj5)                      1316
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    1317
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       1318
     2jfw                                                                   1319
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        1320
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    1321
     2difa,difg,dc0                                                         1322
      dimension dcd(6), dcdw(3)                                             1323
      character rs*10,rs0*10,aw*1,isy*1,isyd*1                              1324
      logical law                                                           1325
c                                                                           1326
      if (ngkk.le.0) go to 90                                               1327
      write (ioa,100) ngkk                                                  1328
      do 10 i=1,3                                                           1329
        dcd(i)=dg(i)                                                        1330
        dcd(i+3)=dg(i+3)                                                    1331
   10   dcdw(i)=dgw(i)                                                      1332
      rs0=rs                                                                1333
      isyd=isy                                                              1334
      call les (in)                                                         1335
      if (n.eq.0.or.ndi(1).gt.mdi) go to 50                                 1336
      nnm=max1(abs(c(1)),1.)                                                1337
      nwr=-c(1)                                                             1338
c                                                                           1339
      if (nwr.eq.0) nwr=-1                                                  1340
c                                                                           1341
      if (nnm.gt.ngkk) go to 50                                             1342
      isx=1                                                                 1343
   20 nn=imx(nnm)                                                           1344
      do 30 i=1,3                                                           1345
        dg(i)=dgld(i,nn)                                                    1346
        dg(i+3)=cos(fak*dgld(i+3,nn))                                       1347
   30   dgw(i)=dgld(i+3,nn)                                                 1348
      ila=1                                                                 1349
      call del (dg,dgw,ddw,ddv,ila,ntr,ntr0,rs,rs0,isx,nrt,id33,0)          1350
      if (n.eq.0.or.n.eq.100) go to 50                                      1351
      if (nrt.gt.0) write (ioa,110) nnm,ffom(nn),vld(nn)                    1352
      if (nrt.gt.0) idid=1                                                  1353
      if (io.ne.ioa.and.nrt.gt.0) write (io,110) nnm,ffom(nn),vld(nn)       1354
      if (nn.le.0) go to 50                                                 1355
      if (nnm.eq.ngkk) go to 60                                             1356
      if (nwr.lt.0.and.nrt.eq.0) go to 40                                   1357
c      idid=1                                                               1358
      write (ioa,130)                                                       1359
      read (in,120,end=50) aw                                               1360
      if (law(aw)) go to 60                                                 1361
   40 nnm=nnm+1                                                             1362
      go to 20                                                              1363
c                                                                           1364
   50 ier=1                                                                 1365
      go to 70                                                              1366
c                                                                           1367
   60 ier=2                                                                 1368
   70 do 80 i=1,3                                                           1369
        dg(i)=dcd(i)                                                        1370
        dg(i+3)=dcd(i+3)                                                    1371
   80   dgw(i)=dcdw(i)                                                      1372
      rs=rs0                                                                1373
      isy=isyd                                                              1374
      return                                                                1375
c                                                                           1376
   90 ier=3                                                                 1377
      return                                                                1378
c                                                                           1379
c                                                                           1380
c                                                                           1381
  100 format (' start at which solution? (def.=1, max.:',i4,'); <0: brea    1382
     1k after each set')                                                    1383
  110 format (' sol. #',i3,',  R :',f5.2,', V:',f6.0)                       1384
  120 format (a1)                                                           1385
  130 format (' cont.?')                                                    1386
      end                                                                   1387
c #######======= 021                                                        1388
      subroutine indi (dg,cr,nda,idi,ie)                                    1389
c loops for indexing                                                        1390
c                                                                           1391
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20)                           1392
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20)                        1393
      common /cd1/ d1d(jj1),d2d(jj1),h1h(3,jj1),h2h(3,jj1)                  1394
      common /b/ ii,jj,ila,ke,nq(jj4)                                       1395
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      1396
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      1397
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        1398
      dimension cr(6), dg(6)                                                1399
c                                                                           1400
      ie=0                                                                  1401
      ihm=d4*dg(1)                                                          1402
      ikm=d4*dg(2)                                                          1403
      ilm=d4*dg(3)                                                          1404
      ii=0                                                                  1405
      jj=0                                                                  1406
      nda=0                                                                 1407
      if (ihm.eq.0) go to 60                                                1408
c                                                                           1409
c h 0 0                                                                     1410
c                                                                           1411
      do 50 j=1,ihm                                                         1412
        if (ii.ge.idi.or.jj.ge.idi) go to 290                               1413
        go to (30,30,10,10,20,10,10),ila                                    1414
   10   if (mod(j,2)) 50,30,50                                              1415
   20   if (mod(j,3)) 50,30,50                                              1416
   30   bh=j                                                                1417
        hh=bh*cr(1)                                                         1418
        d=hh*hh                                                             1419
        if (d.lt.du(1).or.d.gt.do(1)) go to 40                              1420
        ii=ii+1                                                             1421
        d1d(ii)=d                                                           1422
        h1h(1,ii)=hh                                                        1423
        h1h(2,ii)=0.                                                        1424
        h1h(3,ii)=0.                                                        1425
   40   if (d.lt.du(2).or.d.gt.do(2)) go to 50                              1426
        jj=jj+1                                                             1427
        d2d(jj)=d                                                           1428
        h2h(1,jj)=hh                                                        1429
        h2h(2,jj)=0.                                                        1430
        h2h(3,jj)=0.                                                        1431
   50 continue                                                              1432
c                                                                           1433
c h k 0                                                                     1434
c                                                                           1435
   60 maxh=2*ihm+1                                                          1436
      ihm1=ihm+1                                                            1437
      if (ikm.eq.0) go to 160                                               1438
c                                                                           1439
      do 150 ik=1,ikm                                                       1440
        bk2=float(ik)*cr(2)                                                 1441
        hk=float(ik)*cr(4)                                                  1442
        hk2=hk*hk                                                           1443
        do 150 j=1,maxh                                                     1444
        if (ii.ge.idi.or.jj.ge.idi) go to 290                               1445
        ih=j-ihm1                                                           1446
c                                                                           1447
        go to (120,70,80,90,100,90,110),ila                                 1448
   70   if (mod(ik,2)) 150,120,150                                          1449
   80   if (mod(ih,2)) 150,120,150                                          1450
   90   if (mod(ih+ik,2)) 150,120,150                                       1451
  100   if (mod(ik-ih,3)) 150,120,150                                       1452
  110   if (mod(ih,2).ne.0.or.mod(ik,2).ne.0) go to 150                     1453
  120   bh=ih                                                               1454
        bk=ik                                                               1455
        hh=bh*cr(1)+bk2                                                     1456
        hl=0.                                                               1457
        d=hh*hh+hk2                                                         1458
        if (d.lt.du(1).or.d.gt.do(1)) go to 130                             1459
        ii=ii+1                                                             1460
        d1d(ii)=d                                                           1461
        h1h(1,ii)=hh                                                        1462
        h1h(2,ii)=hk                                                        1463
        h1h(3,ii)=0.                                                        1464
  130   if (d.lt.du(2).or.d.gt.do(2)) go to 150                             1465
        if (ke.eq.0) go to 140                                              1466
        if (ik.lt.0.or.ih.lt.0) go to 150                                   1467
        if (ke.eq.1) go to 140                                              1468
        if (ih.lt.0) go to 150                                              1469
        if (ke.eq.3) go to 140                                              1470
        if (ik.gt.ih) go to 150                                             1471
        if (ke.ne.5) go to 140                                              1472
        if (ik.le.0) go to 150                                              1473
  140   jj=jj+1                                                             1474
        d2d(jj)=d                                                           1475
        h2h(1,jj)=hh                                                        1476
        h2h(2,jj)=hk                                                        1477
        h2h(3,jj)=0.                                                        1478
  150 continue                                                              1479
c                                                                           1480
c  h k l                                                                    1481
c                                                                           1482
  160 if (ilm.eq.0) return                                                  1483
      maxk=2*ikm+1                                                          1484
      ikm1=ikm+1                                                            1485
c                                                                           1486
c                                                                           1487
      do 280 il=1,ilm                                                       1488
        bl=il                                                               1489
        bl3=bl*cr(3)                                                        1490
        bl5=bl*cr(5)                                                        1491
        hl=bl*cr(6)                                                         1492
        hl2=hl*hl                                                           1493
        do 270 k=1,maxk                                                     1494
          ik=k-ikm1                                                         1495
          hk=float(ik)*cr(4)+bl5                                            1496
          hk2=hk*hk                                                         1497
          bk2=float(ik)*cr(2)+bl3                                           1498
          do 260 j=1,maxh                                                   1499
            if (ii.ge.idi.or.jj.ge.idi) go to 290                           1500
            ih=j-ihm1                                                       1501
c                                                                           1502
            go to (230,170,180,190,200,210,220),ila                         1503
  170       if (mod(ik+il,2)) 260,230,260                                   1504
  180       if (mod(ih+il,2)) 260,230,260                                   1505
  190       if (mod(ih+ik,2)) 260,230,260                                   1506
  200       if (mod(ik+il-ih,3)) 260,230,260                                1507
  210       if (mod(ih+ik+il,2)) 260,230,260                                1508
  220       if (mod(ih+ik,2).ne.0.or.mod(ik+il,2).ne.0) go to 260           1509
  230       bh=ih                                                           1510
            hh=bh*cr(1)+bk2                                                 1511
            d=hh*hh+hk2+hl2                                                 1512
            if (d.lt.du(1).or.d.gt.do(1)) go to 240                         1513
            ii=ii+1                                                         1514
            d1d(ii)=d                                                       1515
            h1h(1,ii)=hh                                                    1516
            h1h(2,ii)=hk                                                    1517
            h1h(3,ii)=hl                                                    1518
  240       if (d.lt.du(2).or.d.gt.do(2)) go to 260                         1519
            if (ke.eq.0) go to 250                                          1520
            if (ik.lt.0.or.(il.eq.0.and.ih.lt.0)) go to 260                 1521
            if (ke.eq.1) go to 250                                          1522
            if (ih.lt.0) go to 260                                          1523
            if (ke.eq.3.or.ila.eq.5) go to 250                              1524
            if (ik.gt.ih) go to 260                                         1525
            if (ke.ne.5) go to 250                                          1526
            if (il.gt.ik) go to 260                                         1527
  250       jj=jj+1                                                         1528
            d2d(jj)=d                                                       1529
            h2h(1,jj)=hh                                                    1530
            h2h(2,jj)=hk                                                    1531
            h2h(3,jj)=hl                                                    1532
  260     continue                                                          1533
  270   continue                                                            1534
  280 continue                                                              1535
c                                                                           1536
      return                                                                1537
c                                                                           1538
  290 ie=1                                                                  1539
      return                                                                1540
      end                                                                   1541
c #######======= 022                                                        1542
      subroutine eva (cd,ild,ibr,iun,isr,isr0,ier,nls,m,i4,nda,il1,flim)    1543
c                                                                           1544
c evaluate and store indexing                                               1545
c                                                                           1546
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20)                           1547
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20)                        1548
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     1549
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    1550
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       1551
     2jfw                                                                   1552
      common /cd1/ d1d(jj1),d2d(jj1),h1h(3,jj1),h2h(3,jj1)                  1553
      common /b/ ii,jj,ila,ke,nq(jj4)                                       1554
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      1555
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      1556
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        1557
      common /ti/ titel(18),text(17),tit(18,jj4)                            1558
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                   1559
      common /cgg/ gg(14,jj2),ac(jj2)/izz/izm(jj2),i6(jj3)                  1560
      common /sb1/ jsm(7),jsml(7),ivo(2),s1(2),p7(2),p7l(2),p9(2),p8(2),    1561
     1rs,holder(3)                                                          1562
      common /cons2/ fk(7),sq3,a9                                           1563
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv            1564
      dimension ixj(3)                                                      1565
      character*4 isys,titel,tit,text,ta1,ta0,ta0l,p6                       1566
      character rs*10,holder*11                                             1567
      character*1 jsm,jsml,ivo,s1,p7,p7l,p9,p8,s4                           1568
      character*3 s2                                                        1569
c                                                                           1570
      dimension cd(6), i4(6)                                                1571
      aa=0.                                                                 1572
      ier=0                                                                 1573
c                                                                           1574
      do 120 j=1,jj                                                         1575
        sa=h2h(1,j)                                                         1576
        sb=h2h(2,j)                                                         1577
        sg=h2h(3,j)                                                         1578
        d2=sqrt(d2d(j))                                                     1579
        g(4)=sa*cd(1)+sb*cd(2)+sg*cd(3)                                     1580
        g(5)=sb*cd(4)+sg*cd(5)                                              1581
        g(6)=sg*cd(6)                                                       1582
c                                                                           1583
        do 110 i=1,ii                                                       1584
          h1=h1h(1,i)                                                       1585
          h2=h1h(2,i)                                                       1586
          h3=h1h(3,i)                                                       1587
          d1=sqrt(d1d(i))                                                   1588
          w=(h1*sa+h2*sb+h3*sg)/(d1*d2)                                     1589
          w=amin1(w,1.)                                                     1590
          w=amax1(w,-1.)                                                    1591
          if (abs(w).lt.wu.or.abs(w).gt.wo) go to 110                       1592
          g(11)=(r1+r2)/(d1+d2)                                             1593
          g(7)=d1*g(11)                                                     1594
          g(8)=d2*g(11)                                                     1595
          if (ira.eq.1) go to 10                                            1596
          if (abs(g(11)-ak).gt.dak.or.abs(g(7)-r1).gt.dr1.or.abs(g(8)-      1597
     1     r2).gt.dr2) go to 110                                            1598
   10     g(1)=h1*cd(1)+h2*cd(2)+h3*cd(3)                                   1599
          g(2)=h2*cd(4)+h3*cd(5)                                            1600
          g(3)=h3*cd(6)                                                     1601
          if (icm.eq.0.and.lq.eq.1) go to 30                                1602
c                                                                           1603
          do 20 k=1,6                                                       1604
   20       i4(k)=g(k)+sign(.5,g(k))                                        1605
c                                                                           1606
          call chec (ila,i4,iz,ixj)                                         1607
          if (iz.gt.icm.and.icm.ne.0) go to 110                             1608
          if (flim.lt.1.) go to 30                                          1609
          if (il1.eq.1.and.ixj(1).eq.0.and.ixj(2).eq.0) go to 110           1610
   30     g(9)=acos(w)*fakr                                                 1611
          if (w*cw1.ge.0..or.(abs(w).lt..00001.and.abs(cw1).lt..00001))     1612
     1     go to 40                                                         1613
          g(9)=180.-g(9)                                                    1614
          g(1)=-g(1)                                                        1615
          g(2)=-g(2)                                                        1616
          g(3)=-g(3)                                                        1617
   40     g(10)=g(11)*fk(ila)/(v0*d1*d2*amax1(.00001,sin(g(9)*fak)))        1618
          g11=g(10)                                                         1619
          g(10)=amin1(g(10),9999.99)                                        1620
          g(10)=amax1(g(10),-999.99)                                        1621
          if (lq.eq.1) go to 50                                             1622
          g(13)=ra(amax1(r0-sr0,0.),g(11),iz,ala,g11)                       1623
          g(14)=ra(r0+sr0,g(11),iz,ala,g11)                                 1624
          if (g(13).lt.s1u.or.g(14).gt.s1o) go to 110                       1625
c                                                                           1626
   50     if (ibr.ne.54.or.nls.eq.1) go to 60                               1627
          if (isr0.lt.isr) go to 130                                        1628
          nls=1                                                             1629
cioioio!!! ok                                                               1630
c       write(6,*)iun,io,ioa,isr0,isr                                       1631
c                                                                           1632
c          if (iop.eq.0) write (iun,160)                                    1633
c          if (ild.eq.0) write (iun,150) ta1,text                           1634
c          if (ild.eq.0) write (iun,140) (dg(k),k=1,3),dgw,jsm(ila),v0,     1635
c     1     (rg(k),k=1,3),rgw,jsm(ila),rs                                   1636
c?          if (iop.eq.0) write (iun,160)                                   1637
          isr0=0                                                            1638
          go to 130                                                         1639
c                                                                           1640
   60     g(12)=wi-g(9)                                                     1641
          g(13)=200.*(d1*r2-d2*r1)/(d1*r2+d2*r1)                            1642
          g(14)=100.*(g(11)-ak)/ak                                          1643
          h1=viw*abs(g(12))+viv*abs(g(13))+vik*abs(g(14))                   1644
          nda=nda+1                                                         1645
          if (nda.le.nbb) go to 70                                          1646
          ll=kk                                                             1647
          if (h1-aa) 80,110,110                                             1648
   70     ll=nda                                                            1649
c                                                                           1650
   80     do 90 k=1,14                                                      1651
   90       gg(k,ll)=g(k)                                                   1652
c                                                                           1653
          izm(ll)=iz                                                        1654
          ac(ll)=h1                                                         1655
          m=min0(nbb,nda)                                                   1656
          aa=0.                                                             1657
c                                                                           1658
          do 100 k=1,m                                                      1659
            if (ac(k).lt.aa) go to 100                                      1660
            aa=ac(k)                                                        1661
            kk=k                                                            1662
  100     continue                                                          1663
c                                                                           1664
  110   continue                                                            1665
  120 continue                                                              1666
      return                                                                1667
  130 ier=1                                                                 1668
      return                                                                1669
c                                                                           1670
c                                                                           1671
      end                                                                   1672
c #######======= 023                                                        1673
      subroutine outp (i7,jz,m,sfom,ild,ier,iwr,i4,i5,iwi,iun,nli,iza,      1674
     1ns,m0,isr0,ibr,nexc)                                                  1675
c                                                                           1676
c  sorted output of solutions                                               1677
c                                                                           1678
      parameter (jj2=199,jj3=140,jj4=20,jj9=20)                             1679
c-p      parameter (jj2=999,jj3=140,jj4=20,jj9=20)                          1680
c                                                                           1681
      common /cgg/ gg(14,jj2),ac(jj2)/izz/izm(jj2),i6(jj3)                  1682
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv            1683
      common /b/ ii,jj,ila,ke,nq(jj4)                                       1684
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     1685
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      1686
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      1687
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        1688
      common /cons2/ fk(7),sq3,a9                                           1689
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        1690
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    1691
     2difa,difg,dc0                                                         1692
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    1693
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       1694
     2jfw                                                                   1695
      common /tran/ acp(3,3),apc(3,3)                                       1696
      common /iskip/ iskip,isig,isig0                                       1697
c                                                                           1698
      dimension i4(6), i5(6), jz(3), i7(4), ixj(3), ih1(6,jj9), ih2(3,      1699
     1jj9), ww1(jj9), ww2(jj9), ww3(jj9), ie2(jj9), imu(jj9)                1700
      character*1 aw,bl                                                     1701
      data bl/' '/                                                          1702
      logical law                                                           1703
c                                                                           1704
      j7=jj9                                                                1705
      nexc=0                                                                1706
      ier=0                                                                 1707
      do 10 j=1,j7                                                          1708
        ww1(j)=-1.                                                          1709
        ww2(j)=-1.                                                          1710
        ww3(j)=-1.                                                          1711
c imu etc. vorlaeufige Loesung (Beispiel R)                                 1712
        imu(j)=-100                                                         1713
        do 10 i=1,3                                                         1714
        ih1(i,j)=0                                                          1715
        ih1(i+3,j)=0                                                        1716
   10   ih2(i,j)=0                                                          1717
c                                                                           1718
      do 270 i=1,m                                                          1719
        iirh2=0                                                             1720
        d=1.e10                                                             1721
c                                                                           1722
        do 20 j=1,m                                                         1723
          if (ac(j).gt.d) go to 20                                          1724
          d=ac(j)                                                           1725
          ij=j                                                              1726
   20   continue                                                            1727
        if (i.eq.1) sfom=sfom+ac(ij)                                        1728
        if (ild.gt.0) return                                                1729
c                                                                           1730
        if (i.eq.1) mu1=izm(ij)                                             1731
        if (i.eq.1) ac1=ac(ij)                                              1732
        if ((i.gt.m0.or.iwr.eq.1).and.ine.eq.0) go to 240                   1733
c                                                                           1734
        do 30 k=1,6                                                         1735
   30     i4(k)=gg(k,ij)+sign(.5,gg(k,ij))                                  1736
c                                                                           1737
        if (icm.eq.0.and.ine.ne.0) call chec (ila,i4,izm(ij),ixj)           1738
        g(10)=ra(r0,gg(11,ij),izm(ij),ala,gg(10,ij))                        1739
        g10=g(10)                                                           1740
        g(7)=gg(7,ij)                                                       1741
        g(8)=gg(8,ij)                                                       1742
        g(11)=gg(11,ij)                                                     1743
        if (np.eq.1) go to 50                                               1744
        g(11)=g(11)/ala                                                     1745
        g(7)=gg(11,ij)/g(7)                                                 1746
        g(8)=gg(11,ij)/g(8)                                                 1747
        g(10)=v0*amax1(.00001,sin(gg(9,ij)*fak))/(g(7)*g(8)*                1748
     1   float(izm(ij))*fk(ila))                                            1749
        if (iwi.eq.0) go to 50                                              1750
        if (abs(g(7)/g(8)-1.).gt..001) go to 40                             1751
        g(10)=0.                                                            1752
        xzth=.5*xl/g(7)                                                     1753
        if (xzth.gt.1.) go to 50                                            1754
        g(10)=fakr*2.*asin(xzth)                                            1755
c    xl=Roe-lambda                                                          1756
        if (i.eq.1.and.iun.ne.8) write (iun,330) xl                         1757
        go to 50                                                            1758
   40   g(10)=0.                                                            1759
   50   if (ild.gt.0.or.iwr.eq.1) go to 240                                 1760
        if (ke.eq.0) go to 140                                              1761
c                                                                           1762
c check for equivalence                                                     1763
c                                                                           1764
        do 60 kl=1,j7                                                       1765
   60     ie2(kl)=0                                                         1766
        call vp (i4,jz(1),jz(2),jz(3),1,igg)                                1767
cccc                                                                        1768
        do 70 kl=1,j7                                                       1769
          iee=0                                                             1770
          kll=kl                                                            1771
          if (abs(ww1(kl)-gg(12,ij))+abs(abs(ww2(kl))-abs(gg(13,ij)))+      1772
     1     abs(ww3(kl)-gg(14,ij)).gt..001) go to 80                         1773
          if (iskip.eq.0) call ckout (ke,i4,jz,ih1,ih2,iee,ila,kll)         1774
          ie2(kl)=iee                                                       1775
          if (imu(kl).ne.izm(ij)) ie2(kl)=0                                 1776
   70   continue                                                            1777
c                                                                           1778
   80   if (ie2(kll).ne.0) go to 130                                        1779
        do 90 kl=j7,2,-1                                                    1780
          imu(kl)=imu(kl-1)                                                 1781
          ww1(kl)=ww1(kl-1)                                                 1782
          ww2(kl)=ww2(kl-1)                                                 1783
   90     ww3(kl)=ww3(kl-1)                                                 1784
        ww1(1)=gg(12,ij)                                                    1785
        ww2(1)=gg(13,ij)                                                    1786
        ww3(1)=gg(14,ij)                                                    1787
        imu(1)=izm(ij)                                                      1788
        do 100 kl=j7,2,-1                                                   1789
          do 100 k=1,3                                                      1790
          ih1(k,kl)=ih1(k,kl-1)                                             1791
          ih1(k+3,kl)=ih1(k+3,kl-1)                                         1792
  100     ih2(k,kl)=ih2(k,kl-1)                                             1793
        do 110 k=1,3                                                        1794
          ih1(k,1)=i4(k)                                                    1795
          ih1(k+3,1)=i4(k+3)                                                1796
  110     ih2(k,1)=jz(k)                                                    1797
        isi=0                                                               1798
        do 120 kl=1,j7                                                      1799
  120     isi=isi+ie2(kl)                                                   1800
        if (isi.eq.0) go to 140                                             1801
  130   nexc=nexc+1                                                         1802
        go to 240                                                           1803
c check end                                                                 1804
  140   iirh2=1                                                             1805
        if (izm(ij).gt.1) go to 190                                         1806
        if (nli.lt.limax.or.iun.ne.io) go to 160                            1807
        nli=1                                                               1808
        write (ioa,350)                                                     1809
        read (in,360,end=150) aw                                            1810
        if (.not.law(aw)) go to 160                                         1811
  150   iwr=1                                                               1812
        go to 240                                                           1813
  160   call chgs (i4)                                                      1814
c+++++                                                                      1815
        if (g(10).eq.0.) return                                             1816
c+++++                                                                      1817
cioioio???  ok                                                              1818
        if (iun.ne.8) write (iun,320) i4(1),i4(2),i4(3),g(7),i4(4),i4(5)    1819
     1   ,i4(6),g(8),gg(9,ij),g(10),g(11),(gg(k,ij),k=12,14),ac(ij)         1820
        nli=nli+1                                                           1821
        if (iza.eq.0) go to 170                                             1822
        call vp (i4,jz(1),jz(2),jz(3),1,igg)                                1823
cioioio??? ok                                                               1824
        if (iun.ne.8) write (iun,340) jz                                    1825
        nli=nli+1                                                           1826
  170   if (nru.eq.0) go to 240                                             1827
        call vp (i4,j1,j2,j3,1,izz)                                         1828
        if (i.gt.1) go to 180                                               1829
        if (iy.eq.2.and.i.le.nru) write (io,370) ns,i4,ac(ij),j1,j2,j3,     1830
     1   g10                                                                1831
        if (iy.eq.2.and.i.le.nru.and.io.ne.ioa) write (ioa,370) ns,i4,      1832
     1   ac(ij),j1,j2,j3,g10                                                1833
        go to 240                                                           1834
c                                                                           1835
  180   if (iy.eq.2.and.i.le.nru) write (io,390) ns,i4,ac(ij),j1,j2,j3,     1836
     1   g10                                                                1837
        if (iy.eq.2.and.i.le.nru.and.io.ne.ioa) write (ioa,390) ns,i4,      1838
     1   ac(ij),j1,j2,j3,g10                                                1839
        go to 240                                                           1840
c                                                                           1841
  190   call prim (ila,i4,i5)                                               1842
        call vert (i4,i5)                                                   1843
        call chgs (i4)                                                      1844
        call chgs (i5)                                                      1845
        if (nli.lt.limax.or.iun.ne.io) go to 200                            1846
        nli=1                                                               1847
        write (ioa,350)                                                     1848
        read (in,360,end=150) aw                                            1849
        if (.not.law(aw)) go to 200                                         1850
        iwr=1                                                               1851
        go to 240                                                           1852
  200   call lind (i4,i5,i7)                                                1853
        if (iza.ne.0) go to 210                                             1854
cioioio!!!  ok                                                              1855
        if (iun.ne.8) write (iun,320) i4(1),i4(2),i4(3),g(7),i4(4),i4(5)    1856
     1   ,i4(6),g(8),gg(9,ij),g(10),g(11),(gg(k,ij),k=12,14),ac(ij),        1857
     2   izm(ij),i5,i7                                                      1858
        nli=nli+2                                                           1859
        go to 220                                                           1860
  210   call vp (i4,jz(1),jz(2),jz(3),1,igg)                                1861
cioioio!!!  ok                                                              1862
        if (iun.ne.8) write (iun,320) i4(1),i4(2),i4(3),g(7),i4(4),i4(5)    1863
     1   ,i4(6),g(8),gg(9,ij),g(10),g(11),(gg(k,ij),k=12,14),ac(ij),        1864
     2   izm(ij),i5,i7,bl,jz                                                1865
        nli=nli+2                                                           1866
c?                                                                          1867
  220   if (nru.eq.0) go to 240                                             1868
c???                                                                        1869
        call vp (i4,j1,j2,j3,0,izz)                                         1870
        j1=j1/izm(ij)                                                       1871
        j2=j2/izm(ij)                                                       1872
        j3=j3/izm(ij)                                                       1873
        if (i.gt.1) go to 230                                               1874
        if (iy.eq.2.and.i.le.nru) write (io,380) ns,i4,ac(ij),izm(ij),      1875
     1   j1,j2,j3,g10                                                       1876
        if (iy.eq.2.and.i.le.nru.and.io.ne.ioa) write (ioa,380) ns,i4,      1877
     1   ac(ij),izm(ij),j1,j2,j3,g10                                        1878
        go to 240                                                           1879
c                                                                           1880
  230   if (iy.eq.2.and.i.le.nru) write (io,400) ns,i4,ac(ij),izm(ij),      1881
     1   j1,j2,j3,g10                                                       1882
        if (iy.eq.2.and.i.le.nru.and.io.ne.ioa) write (ioa,400) ns,i4,      1883
     1   ac(ij),izm(ij),j1,j2,j3,g10                                        1884
  240   ac(ij)=1.e11*(ac(ij)+1.)                                            1885
c                                                                           1886
c   special case: rhombohedral u+v=3n, w=3n                                 1887
        if (ke.ne.2) go to 270                                              1888
        if (ila.ne.5) go to 270                                             1889
        if (iirh2.ne.1) go to 270                                           1890
c                                                                           1891
        if (mod(jz(1)+jz(2),3).ne.0) go to 270                              1892
c #######                                                                   1893
c       if (jz(1).eq.0.and.jz(2).eq.0) go to 270                            1894
        if (jz(1).eq.0.or.jz(2).eq.0) go to 270                             1895
        if (jz(1).eq.jz(2)) go to 270                                       1896
c                                                                           1897
c hhl h=3n, l=3m+(1od.2), hh-l, 1.LZ gespiegelt (?)                         1898
c                                                                           1899
        if (jz(3).eq.0) go to 270                                           1900
        if (mod(jz(1),3).ne.0.and.mod(jz(3),3).ne.0) go to 270              1901
        i4(3)=-i4(3)                                                        1902
        i4(6)=-i4(6)                                                        1903
        if (iza.ne.0) go to 250                                             1904
cioioio!!!  ok                                                              1905
        write (6,300) i4                                                    1906
        if (jfw.ne.0) write (88,300) i4                                     1907
        go to 260                                                           1908
  250   jz(1)=-jz(1)                                                        1909
        jz(2)=-jz(2)                                                        1910
cioioio!!!  ok                                                              1911
c                                                                           1912
        write (6,310) i4,jz(1),jz(2),jz(3)                                  1913
        if (jfw.ne.0) write (88,310) i4,jz(1),jz(2),jz(3)                   1914
  260   nli=nli+1                                                           1915
  270 continue                                                              1916
      if (iy.ne.2.or.isr0.ge.2) return                                      1917
      if (nru.gt.0.or.ibr.eq.54) go to 280                                  1918
      if (mu1.eq.1) write (6,410) ac1                                       1919
      if (mu1.ne.1) write (6,420) ac1,mu1                                   1920
      if (mu1.eq.1.and.jfw.ne.0) write (88,410) ac1                         1921
      if (mu1.ne.1.and.jfw.ne.0) write (88,420) ac1,mu1                     1922
  280 if (istp1.eq.0.or.ibr.eq.54) return                                   1923
      write (ioa,350)                                                       1924
      read (in,360,end=290) aw                                              1925
      if (law(aw)) ier=1                                                    1926
      return                                                                1927
c                                                                           1928
  290 ier=1                                                                 1929
      return                                                                1930
c                                                                           1931
c                                                                           1932
c                                                                           1933
  300 format (1x,2(3i3,'   -"- '),2('   -"-'),5x,11('-'),' " ',11('-'))     1934
  310 format (1x,2(3i3,'   -"- '),2('   -"-'),5x,'[',3i6,']',2(3x,'"')/)    1935
  320 format (1x,2(3i3,f7.3),f6.1,2f7.1,f5.1,3f6.2,i3/'(',3i3,6x,i4,2i3,    1936
     12(';',i4,',',i3),')',4x,a1,'[',3i6,']')                               1937
  330 format (38x,'wl.:',f10.6)                                             1938
  340 format (50x,'[',3i6,']')                                              1939
  350 format (' cont.?')                                                    1940
  360 format (a1)                                                           1941
  370 format (1x,i4,2x,2(3i4,2x),'R:',f6.2,6x,'[',3i4,'], L1:',f9.1)        1942
  380 format (1x,i4,2x,2(3i4,2x),'R:',f6.2,' (',i2,')',1x,'[',3i4,'], L1    1943
     1:',f9.1)                                                              1944
  390 format (i7,2(3i4,2x),f6.2,8x,'[',3i4,'], L1:',f9.1)                   1945
  400 format (i7,2(3i4,2x),f6.2,' (',i3,')',2x,'[',3i4,'], L1:',f9.1)       1946
  410 format ('   R :',f8.2/)                                               1947
  420 format ('   R :',f8.2,' (',i3,' )'/)                                  1948
      end                                                                   1949
c #######======= 024                                                        1950
      subroutine ckout (ke,i4,jz,ih1,ih2,iee,ila,m)                         1951
c check for equivalence of indexings (1)                                    1952
c                                                                           1953
      parameter (jj9=20)                                                    1954
      dimension i4(6), jz(3), ih1(6,jj9), ih2(3,jj9)                        1955
      call ck3 (ke,i4(4),i4(5),i4(6),ih1(4,m),ih1(5,m),ih1(6,m),iee,ila,    1956
     10)                                                                    1957
      if (iee.eq.0) return                                                  1958
      call ck3 (ke,i4(1),i4(2),i4(3),ih1(1,m),ih1(2,m),ih1(3,m),iee,ila,    1959
     10)                                                                    1960
      if (iee.eq.0) return                                                  1961
      if (ke.eq.5.or.ke.eq.2) call ck3 (ke,jz(1),jz(2),jz(3),ih2(1,m),      1962
     1ih2(2,m),ih2(3,m),iee,ila,1)                                          1963
      return                                                                1964
      end                                                                   1965
c #######======= 025                                                        1966
      subroutine ck3 (ke,i1,i2,i3,j1,j2,j3,ie,ila,n)                        1967
c check for equivalence of indexings (2)                                    1968
c                                                                           1969
      ie=0                                                                  1970
      i11=iabs(i1)                                                          1971
      i22=iabs(i2)                                                          1972
      i33=iabs(i3)                                                          1973
      j11=iabs(j1)                                                          1974
      j22=iabs(j2)                                                          1975
      j33=iabs(j3)                                                          1976
      go to (10,30,10,20,80),ke                                             1977
c mon.,  orh.                                                               1978
c                                                                           1979
   10 if (i11.ne.j11.or.i22.ne.j22.or.i33.ne.j33) return                    1980
      if (ke.eq.3) go to 90                                                 1981
      if (i1*i3.eq.j1*j3) go to 90                                          1982
      return                                                                1983
c tetr.                                                                     1984
   20 if (i33.ne.j33) return                                                1985
      ii=i11+i22                                                            1986
      jj=j11+j22                                                            1987
      iia=max0(i11,i22)                                                     1988
      iim=ii-iia                                                            1989
      jja=max0(j11,j22)                                                     1990
      jjm=jj-jja                                                            1991
      if (iia.ne.jja.or.iim.ne.jjm) return                                  1992
      go to 90                                                              1993
c hex.                                                                      1994
   30 if (i33.ne.j33) return                                                1995
      i12=-(i1+i2)                                                          1996
      if (n.ne.0) i12=i1-i2                                                 1997
      i1212=iabs(i12)                                                       1998
      if (j11.ne.i11.and.j11.ne.i22.and.j11.ne.i1212) return                1999
      if (j22.ne.i11.and.j22.ne.i22.and.j22.ne.i1212) return                2000
      if (n.ne.0) go to 40                                                  2001
      j12=j1*j2                                                             2002
      if (j12.eq.i1*i2.or.j12.eq.i1*i12.or.j12.eq.i2*i12) go to 90          2003
      return                                                                2004
c                                                                           2005
c zone axis, hexagonal                                                      2006
   40 j11=j1                                                                2007
      j22=j2                                                                2008
      iz=0                                                                  2009
      if (i3.eq.j3.or.ila.ne.5) go to 50                                    2010
      j11=-j11                                                              2011
      j22=-j22                                                              2012
   50 if (j11.eq.i1.and.j22.eq.i2) go to 90                                 2013
      j111=j11                                                              2014
      j222=j22                                                              2015
      do 70 j=1,2                                                           2016
        do 60 i=1,3                                                         2017
          jd=-j22                                                           2018
          j22=j11-j22                                                       2019
          j11=jd                                                            2020
          if (j11.eq.i1.and.j22.eq.i2) go to 90                             2021
   60   continue                                                            2022
   70   j22=j11-j22                                                         2023
c      if ((i3.ne.0.and.ila.eq.5).or.iz.eq.1) return                        2024
      if (iz.eq.1) return                                                   2025
      j11=-j111                                                             2026
      j22=-j222                                                             2027
      iz=1                                                                  2028
      go to 50                                                              2029
c                                                                           2030
c cubic                                                                     2031
   80 ii=i11+i22+i33                                                        2032
      iia=max0(i11,i22)                                                     2033
      iia=max0(iia,i33)                                                     2034
      iii=min0(i11,i22)                                                     2035
      iii=min0(iii,i33)                                                     2036
      iim=ii-iia-iii                                                        2037
      jj=j11+j22+j33                                                        2038
      jja=max0(j11,j22)                                                     2039
      jja=max0(jja,j33)                                                     2040
      jji=min0(j11,j22)                                                     2041
      jji=min0(jji,j33)                                                     2042
      jjm=jj-jja-jji                                                        2043
      if (iia.ne.jja.or.iii.ne.jji.or.iim.ne.jjm) return                    2044
   90 ie=1                                                                  2045
      return                                                                2046
      end                                                                   2047
c ####### P2 ########                                                       2048
c #######======= 026                                                        2049
      subroutine rpl (ioa,jk,rmi,rma,wi,yzx,fakr,ak1,akl,a,rz0,rz1,dhd1,    2050
     1w13,ny,nz)                                                            2051
c graphic representation of a zone                                          2052
      parameter (llin=78)                                                   2053
      dimension jk(3,2)                                                     2054
      character*1 a(llin),ze(2)                                             2055
      data ze/'+',' '/                                                      2056
      jlin=llin                                                             2057
      fak=1./fakr                                                           2058
      lin=1                                                                 2059
      cwi=cos(wi*fak)                                                       2060
      swi=sin(wi*fak)                                                       2061
      cwi13=cos(w13*fak)                                                    2062
      swi13=sin(w13*fak)                                                    2063
      znx=rmi*yzx*float(ny)/(rma*swi)                                       2064
      znx0=2.*znx*cwi*rma/rmi                                               2065
      nyl1=float(ny)*(1.-dhd1*swi13/(rma*swi))+.5                           2066
      xlz1=.5*znx0+float(ny)*yzx*cwi13*dhd1/(rma*swi)                       2067
c                                                                           2068
      ilay=2                                                                2069
      x0=znx0                                                               2070
   10 if (x0.lt.0.) go to 30                                                2071
      x0=x0-znx                                                             2072
      if (ilay.ne.1) go to 10                                               2073
      do 20 i=1,3                                                           2074
   20   jk(i,2)=jk(i,2)-jk(i,1)                                             2075
      go to 10                                                              2076
   30 xx=x0-znx                                                             2077
      do 40 i=1,jlin                                                        2078
   40   a(i)=' '                                                            2079
      if (ilay.ne.1.or.nyl1.ne.ny) go to 60                                 2080
      xxl1=xlz1-3.*znx                                                      2081
   50 xxl1=xxl1+znx                                                         2082
      j=xxl1+1.5                                                            2083
      if (j.le.0) go to 50                                                  2084
      if (j.gt.jlin) go to 60                                               2085
      a(j)=ze(nz)                                                           2086
      go to 50                                                              2087
   60 iij=0                                                                 2088
c                                                                           2089
   70 xx=xx+znx                                                             2090
      j=xx+.5                                                               2091
      if (j.lt.0.and.ilay.eq.1) go to 80                                    2092
      if (j.lt.0) go to 70                                                  2093
      if (j.gt.jlin) go to 100                                              2094
      if (a(j+1).eq.ze(1)) a(j+1)='%'                                       2095
      if (a(j+1).eq.' ') a(j+1)='#'                                         2096
      if (iij.eq.0) iij=j+1                                                 2097
      go to 70                                                              2098
   80 do 90 k=1,3                                                           2099
   90   jk(k,2)=jk(k,2)+jk(k,1)                                             2100
      go to 70                                                              2101
  100 write (ioa,230) a                                                     2102
      if (ilay.eq.0) go to 200                                              2103
      if (ilay.eq.2) go to 120                                              2104
      do 110 i=1,jlin                                                       2105
  110   a(i)=' '                                                            2106
      a(iij)='^'                                                            2107
      write (ioa,230) a                                                     2108
      write (ioa,240) (jk(i,2),i=1,3),rma                                   2109
  120 do 170 i=1,ny-lin                                                     2110
        if (ilay.ne.2.or.i.ne.nyl1) go to 160                               2111
        xxl1=xlz1-3.*znx                                                    2112
c                                                                           2113
        do 130 j=1,jlin                                                     2114
  130     a(j)=' '                                                          2115
  140   xxl1=xxl1+znx                                                       2116
        j=xxl1+1.5                                                          2117
        if (j.le.0) go to 140                                               2118
        if (j.gt.jlin) go to 150                                            2119
        a(j)=ze(nz)                                                         2120
        go to 140                                                           2121
  150   write (ioa,230) a                                                   2122
        go to 170                                                           2123
  160   write (ioa,250)                                                     2124
  170 continue                                                              2125
      if (ilay.ne.1) go to 180                                              2126
      rzo=amin1(rz0,999999.9)                                               2127
      write (ioa,260) rzo                                                   2128
      write (ioa,270) rz1                                                   2129
      write (ioa,280) wi,akl,(jk(i,1),i=1,3),rmi,ak1                        2130
  180 lin=7                                                                 2131
      if (ilay.eq.1) go to 190                                              2132
      znx0=znx0/2.                                                          2133
      x0=znx0                                                               2134
      ilay=1                                                                2135
      go to 10                                                              2136
  190 znx0=0.                                                               2137
      x0=0.                                                                 2138
      ilay=0                                                                2139
      go to 10                                                              2140
  200 xx=alog10(.2*znx/rmi)                                                 2141
      x0=amod(xx+100.,1.)                                                   2142
      ix0=5.*10.**x0+.5                                                     2143
      i=xx+100.                                                             2144
      i=i-100                                                               2145
      xx=1./10.**i                                                          2146
      do 210 j=1,52                                                         2147
  210   a(j)=' '                                                            2148
      a(1)='I'                                                              2149
      do 220 j=2,ix0                                                        2150
  220   a(j)='-'                                                            2151
      a(ix0+1)='I'                                                          2152
      write (ioa,290) (a(j),j=1,52),xx                                      2153
      return                                                                2154
c                                                                           2155
c                                                                           2156
c                                                                           2157
  230 format (2x,78a1)                                                      2158
  240 format (i5,2i4,f8.1,'mm (h2)')                                        2159
  250 format (' ')                                                          2160
  260 format (59x,'L.Z.0:',f8.1,'mm')                                       2161
  270 format (54x,'L.Z.(1.-0):',f8.1,'mm')                                  2162
  280 format (f5.1,'deg.',51x,'c.l.:',f8.1,'mm'/' 000 -->',3i4,f8.1,'mm'    2163
     1,' (h1)',25x,'c.c.:',f8.1,'Amm')                                      2164
  290 format (2x,52a1/f11.2,' mm')                                          2165
      end                                                                   2166
c #######======= 027                                                        2167
      subroutine rlgen2 (kk,mm,vv,dd,rrgg,fakr,dgd,dgdw,ie,rg5,xx12,        2168
     1xx22)                                                                 2169
c cell parameter determination for <SS>                                     2170
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     2171
      dimension rrgg(6), dgd(6), dgdw(3)                                    2172
      ie=0                                                                  2173
      d=dd/vv                                                               2174
      mm=mm+1                                                               2175
      rrgg(5)=rg5                                                           2176
      if (kk.lt.0.or.mm.eq.2) rrgg(5)=-rrgg(5)                              2177
c                                                                           2178
      xx13=rrgg(3)*rrgg(5)                                                  2179
      xx23=amax1(0.,rrgg(3)**2-xx13**2-d**2)                                2180
      xx23=sqrt(xx23)                                                       2181
      rrgg(4)=(xx12*xx13+xx22*xx23)/(rrgg(2)*rrgg(3))                       2182
      call dire (rrgg,dg,dgw,fakr,v0,ie)                                    2183
      if (ie.ne.0) return                                                   2184
      call dire (dg,rg,rgw,fakr,v0,ie)                                      2185
      call del1 (dg,gdw,v0,dgd,dgdw)                                        2186
      do 10 ll=1,3                                                          2187
        dg(ll)=dgd(ll)                                                      2188
        dgw(ll)=dgdw(ll)                                                    2189
   10   dg(ll+3)=dgd(ll+3)                                                  2190
      return                                                                2191
      end                                                                   2192
c #######======= 028                                                        2193
      subroutine ck (ngkk,fom,ssfom,swt,ie,ddifw,ddazb,nsub,ddx,ddy,ddz,    2194
     1sfmx,fkk)                                                             2195
c controls solutions from <DC>                                              2196
      parameter (jj5=100)                                                   2197
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     2198
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        2199
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    2200
     2difa,difg,dc0                                                         2201
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     2202
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       2203
      common /srsr/ imx(jj5),xna(jj5),xnb(jj5),xnc(jj5),x1,x2,x3,           2204
     1ffom(jj5),dgld(6,jj5),vld(jj5),azb(jj5),czb(jj5)                      2205
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                  2206
      dimension isub(jj5), ssfom(jj5)                                       2207
      azub=dg(1)/dg(2)                                                      2208
      czub=dg(3)/dg(2)                                                      2209
      ie=0                                                                  2210
      if (ngkk.lt.nso) go to 10                                             2211
c                                                                           2212
      fom=amax1(fom,1.e-10)                                                 2213
c                                                                           2214
      if (fom.ge.ffom(imx(nso))) go to 110                                  2215
   10 if (ngkk.eq.0) go to 70                                               2216
      nl=min0(ngkk,nso)                                                     2217
c                                                                           2218
      do 30 ll=nl,1,-1                                                      2219
        i=imx(ll)                                                           2220
c                                                                           2221
        if (abs(x1-xna(i)).lt.ddx.and.abs(x2-xnb(i)).lt.ddy.and.abs(x3-     2222
     1   xnc(i)).lt.ddz.and.fom.gt.ffom(i)) go to 110                       2223
c                                                                           2224
        if (abs(azub/azb(i)-1.).gt.ddazb) go to 30                          2225
        if (abs(czub/czb(i)-1.).gt.ddazb) go to 30                          2226
        if (abs(dgw(1)-dgld(4,i)).gt.ddifw) go to 30                        2227
        if (abs(dgw(2)-dgld(5,i)).gt.ddifw) go to 30                        2228
        if (abs(dgw(3)-dgld(6,i)).gt.ddifw) go to 30                        2229
        if (fom.ge.ffom(i)) go to 110                                       2230
c                                                                           2231
        ngkk=ngkk-1                                                         2232
        nsub=nsub+1                                                         2233
        isub(nsub)=i                                                        2234
        if (ll.eq.ngkk+1) go to 30                                          2235
c                                                                           2236
        do 20 j=ll,ngkk                                                     2237
   20     imx(j)=imx(j+1)                                                   2238
   30 continue                                                              2239
c                                                                           2240
      if (ngkk.eq.0) go to 70                                               2241
      if (fom.ge.ffom(imx(ngkk))) go to 70                                  2242
c                                                                           2243
      if (ngkk.lt.nso) go to 40                                             2244
      nsub=nsub+1                                                           2245
      isub(nsub)=imx(ngkk)                                                  2246
      ngkk=ngkk-1                                                           2247
   40 do 50 i=ngkk,1,-1                                                     2248
        iki=i                                                               2249
        if (fom.ge.ffom(imx(i))) go to 60                                   2250
   50   imx(i+1)=imx(i)                                                     2251
      nn=1                                                                  2252
      go to 80                                                              2253
c                                                                           2254
   60 nn=iki+1                                                              2255
      go to 80                                                              2256
c                                                                           2257
   70 nn=ngkk+1                                                             2258
   80 ngkk=ngkk+1                                                           2259
      imx(nn)=ngkk                                                          2260
      if (nsub.eq.0) go to 90                                               2261
      imx(nn)=isub(nsub)                                                    2262
      nsub=nsub-1                                                           2263
   90 ll=imx(nn)                                                            2264
      do 100 k=1,3                                                          2265
        dgld(k,ll)=dg(k)                                                    2266
  100   dgld(k+3,ll)=dgw(k)                                                 2267
      xna(ll)=x1                                                            2268
      xnb(ll)=x2                                                            2269
      xnc(ll)=x3                                                            2270
      ffom(ll)=fom                                                          2271
      ssfom(ll)=1./(1.+fkk*fom/swt)                                         2272
      sfmx=amax1(sfmx,ssfom(ll))                                            2273
      vld(ll)=v0                                                            2274
      azb(ll)=dg(1)/dg(2)                                                   2275
      czb(ll)=dg(3)/dg(2)                                                   2276
      return                                                                2277
c                                                                           2278
  110 ie=1                                                                  2279
c 5. = fkk                                                                  2280
      ssfom(i)=ssfom(i)+1./(1.+fkk*fom/swt)                                 2281
      sfmx=amax1(sfmx,ssfom(i))                                             2282
      return                                                                2283
      end                                                                   2284
c #######======= 029                                                        2285
      subroutine vlim (in,io,ioa,vmin,vmax,vminp,vmaxp,vmi,vma,sv,ie)       2286
c minimum and maximum volume for <DC> and <SA>                              2287
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    2288
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     2289
      ie=0                                                                  2290
      write (ioa,40) vmin,vmax,sv,vminp,vmaxp                               2291
c                                                                           2292
      call les (in)                                                         2293
      if (n.eq.0) return                                                    2294
      if (c(1).le.0..and.c(2).lt.10.) go to 10                              2295
      if (c(2).le.0.) c(2)=c(1)                                             2296
      c(1)=amax1(c(1),vmn)                                                  2297
      c(2)=amax1(c(2),vmn)                                                  2298
      vma=amax1(c(1),c(2))                                                  2299
      vmi=c(1)+c(2)-vma                                                     2300
      go to 20                                                              2301
c                                                                           2302
   10 if (vmaxp.lt.10.) go to 30                                            2303
      vmi=vminp                                                             2304
      vma=vmaxp                                                             2305
   20 write (io,50) vmi,vma                                                 2306
      if (io.ne.ioa) write (ioa,50) vmi,vma                                 2307
      return                                                                2308
   30 ie=1                                                                  2309
      return                                                                2310
c                                                                           2311
c                                                                           2312
c                                                                           2313
   40 format (/' V(P)(min), V(P)(max)? (calc.: min:',f7.0,' max:',f7.0,'    2314
     1, mean:',f7.0,')'/' def.:',2f7.0)                                     2315
   50 format (1x,2f7.0)                                                     2316
      end                                                                   2317
c #######======= 030                                                        2318
      subroutine del (dg,dgw,ddw,ddv,ila,ntr,ntr0,rs,r0,isx,nrt,id33,iu)    2319
c Delaunay reduction                                                        2320
c                                                                           2321
c     Modified code of: H. Zimmermann, H. Burzlaff, DELOS - a computer      2322
c     program for the determination of a unique conventional cell.          2323
c     Z. Kristallogr. 170, 241-246 (1985). (With kind pemission of H.Z.     2324
c                                                                           2325
c transformations with non-integer matrix elements excluded                 2326
c                                                                           2327
      parameter (jj5=100,jj7=100)                                           2328
c jj7: maximum number of Delaunay transformations                           2329
c                                                                           2330
c iu.ne.0 : Aufruf von SS, 0 sonst                                          2331
      dimension dg(6), dgw(3), dgwd(3), kj(3), ig(4,4), nq(7), mq(7),       2332
     1itr(3,3,85), nl(4), ixt(jj7), ixe(jj7), gn(4,4), a(4,4), aw(3,3),     2333
     2av(4,4), gw(3,3), ac(6), e(4,4), gv(4,4), gs(7,7), ad(4,4), o(7,7)    2334
     3, cp(6), xxt(6,jj7)                                                   2335
c                                                                           2336
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    2337
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       2338
     2jfw                                                                   2339
      common /cc/ ifu,iou,koma,ifdi,mdi,cles(15),nnj,ndi(15)                2340
      common /tran/ acp(3,3),apc(3,3)                                       2341
      common /srsr/ imx(jj5),xna(jj5),xnb(jj5),xnc(jj5),x1,x2,x3,           2342
     1ffom(jj5),dgld(6,jj5),vld(jj5),azb(jj5),czb(jj5)                      2343
      common /dd1/ jc(4,4),ncl(30),iq(27),nvv(8),iiv(7,7),inc(3,7),         2344
     1kis(8,30),it1(432),it2(333),mvv(8),lvv(8),itt(20,14),isb(30),         2345
     2idt(13)                                                               2346
      common /dd2/ pp(4,4,6),g(4,4)                                         2347
c                                                                           2348
      equivalence (nl(1),ip), (nl(2),jp), (nl(3),kp), (nl(4),mp)            2349
      equivalence (it1(1),itr(1,1,1)), (it2(1),itr(1,1,49))                 2350
c                                                                           2351
      character rs*10,r0*10                                                 2352
      character*3 y(6)                                                      2353
      character*1 aww,ht(7),yy(6),yyy                                       2354
      logical law                                                           2355
c                                                                           2356
      data ht/'P','A','B','C','F','I','R'/                                  2357
      data y/'   ','mcl','orh','tet','hex','cub'/                           2358
      data yy/' ',' ','.','-','+','#'/                                      2359
      data fp/.0025/                                                        2360
c                                                                           2361
      fakr=45./atan(1.)                                                     2362
      nli=0                                                                 2363
      nrt=0                                                                 2364
      do 10 i=1,4                                                           2365
        do 10 j=1,4                                                         2366
        av(j,i)=0.                                                          2367
   10   ad(j,i)=0.                                                          2368
      do 20 i=1,4                                                           2369
   20   ad(i,i)=1.                                                          2370
      do 30 i=1,7                                                           2371
   30   nq(i)=i                                                             2372
      do 40 i=1,7                                                           2373
        do 40 j=1,7                                                         2374
   40   o(j,i)=0.                                                           2375
      isys=1                                                                2376
      nbr=1                                                                 2377
      nti=5                                                                 2378
      ise=1                                                                 2379
      iz=1                                                                  2380
      zw4=0.                                                                2381
      ncp=0                                                                 2382
      do 50 i=1,3                                                           2383
        do 50 j=1,3                                                         2384
        gw(i,j)=0.                                                          2385
   50   aw(i,j)=0.                                                          2386
      do 60 i=1,30                                                          2387
   60   ncl(i)=0                                                            2388
      do 70 i=1,4                                                           2389
        do 70 j=1,4                                                         2390
   70   g(i,j)=0.                                                           2391
      ntr=0                                                                 2392
      if (isx.eq.0) isyx=1                                                  2393
      if (isx.eq.0) isyz=0                                                  2394
      if (isx-1) 100,80,120                                                 2395
   80 write (io,780)                                                        2396
      if (io.ne.ioa) write (ioa,780)                                        2397
      call les (in)                                                         2398
      if (nnj.eq.0.or.ndi(1).gt.mdi) return                                 2399
      ntr0=0                                                                2400
      iwm=0                                                                 2401
      isx=2                                                                 2402
      isyz=cles(1)                                                          2403
   90 isyx=iabs(isyz)+1                                                     2404
      if (isyx.gt.6) go to 760                                              2405
      isyx=max0(isyx,1)                                                     2406
      isyx=min0(6,isyx)                                                     2407
      go to 120                                                             2408
  100 if (iu.eq.0) go to 110                                                2409
      isyz=iu                                                               2410
      go to 90                                                              2411
  110 write (io,800)                                                        2412
      if (io.ne.ioa) write (ioa,800)                                        2413
      call les (in)                                                         2414
      if (nnj.eq.0.or.ndi(1).gt.mdi.or.ndi(2).gt.mdi.or.ndi(3).gt.mdi)      2415
     1return                                                                2416
      ntr0=cles(1)                                                          2417
      iwm=cles(2)                                                           2418
      isyz=cles(3)                                                          2419
      go to 90                                                              2420
c                                                                           2421
  120 do 130 i=1,6                                                          2422
  130   cp(i)=dg(i)                                                         2423
      if (ila.eq.1) go to 140                                               2424
      call cepr (cp,ila)                                                    2425
      dgwd(1)=fakr*acos(cp(4))                                              2426
      dgwd(2)=fakr*acos(cp(5))                                              2427
      dgwd(3)=fakr*acos(cp(6))                                              2428
      if (iwm.eq.0) go to 140                                               2429
      write (io,810) cp(1),cp(2),cp(3),dgwd                                 2430
      if (io.ne.ioa) write (ioa,810) cp(1),cp(2),cp(3),dgwd                 2431
      nli=nli+1                                                             2432
  140 noi=1                                                                 2433
      ac(1)=cp(1)*cp(1)                                                     2434
      ac(2)=cp(2)*cp(2)                                                     2435
      ac(3)=cp(3)*cp(3)                                                     2436
      ac(4)=cp(1)*cp(2)*cp(6)                                               2437
      ac(5)=cp(2)*cp(3)*cp(4)                                               2438
      ac(6)=cp(1)*cp(3)*cp(5)                                               2439
c                                                                           2440
c   extension of metric tensor                                              2441
      do 150 i=1,3                                                          2442
        j=i+1-3*(i/3)                                                       2443
        if (ac(i).le.0..or.ac(i+3)*ac(i+3)/(ac(i)*ac(j)).ge.1.0) go to      2444
     1   740                                                                2445
        g(i,i)=ac(i)                                                        2446
        g(i,j)=ac(i+3)                                                      2447
        g(4,4)=g(4,4)+g(i,i)+2.0*g(i,j)                                     2448
        g(i,4)=-g(i,i)-g(i,j)-ac(9-i-j)                                     2449
        g(4,i)=g(i,4)                                                       2450
  150   g(j,i)=g(i,j)                                                       2451
c   search for positive element in g                                        2452
  160 mc=0                                                                  2453
      do 170 i=1,4                                                          2454
        do 170 j=1,4                                                        2455
        a(i,j)=ad(i,j)                                                      2456
        gn(i,j)=g(i,j)                                                      2457
        if (abs(g(i,j)).lt.0.00006) g(i,j)=0.0                              2458
  170   if (mc.eq.0.and.j.gt.i.and.g(i,j).gt.0.0) mc=j+2*i-3-i/3            2459
      if (mc.eq.0) go to 190                                                2460
c   transformation of matrix ad and metric tensor g                         2461
      do 180 i=1,4                                                          2462
        do 180 j=1,4                                                        2463
        g(i,j)=0.0                                                          2464
        ad(i,j)=0.0                                                         2465
        do 180 k=1,4                                                        2466
        ad(i,j)=ad(i,j)+a(i,k)*pp(k,j,mc)                                   2467
        do 180 l=1,4                                                        2468
  180   g(i,j)=g(i,j)+gn(k,l)*pp(k,i,mc)*pp(l,j,mc)                         2469
      go to 160                                                             2470
c   construction of identification matrix ig                                2471
  190 do 730 ist=0,istt                                                     2472
        do 200 i=1,4                                                        2473
          do 200 j=1,4                                                      2474
          ig(i,j)=jc(i,j)                                                   2475
  200     a(i,j)=ad(i,j)                                                    2476
        do 220 i=1,3                                                        2477
          do 220 j=i,4                                                      2478
          zw1=fp*(g(i,i)+g(j,j))*float(ist)                                 2479
          if (abs(g(i,j)).lt.zw1) ig(i,j)=0                                 2480
          do 210 k=1,3                                                      2481
            do 210 l=k,4                                                    2482
  210       if (ig(k,l).eq.10*k+l.and.(k.gt.i.or.l.gt.j).and.abs(g(i,j)-    2483
     1       g(k,l)).lt.3.*(zw1+fp*(g(k,k)+g(l,l))*float(ist))) ig(k,l)=    2484
     2       ig(i,j)                                                        2485
  220     ig(j,i)=ig(i,j)                                                   2486
c   identification of delaunay type                                         2487
        do 730 ic=1,30                                                      2488
        do 730 ip=1,4                                                       2489
        do 720 jp=1,4                                                       2490
          if (ip.eq.jp) go to 720                                           2491
          do 710 kp=1,4                                                     2492
            if (kp.eq.ip.or.kp.eq.jp) go to 710                             2493
            mp=10-ip-jp-kp                                                  2494
            do 240 mx=1,6                                                   2495
              m1=nl(1+mx/4+mx/6)                                            2496
              m2=nl(1+mx-2*(mx/4)-mx/6)                                     2497
              if (ig(m1,m2)-5*kis(mx,ic)) 230,240,710                       2498
  230         n1=nl(kis(mx,ic)/10)                                          2499
              n2=nl(kis(mx,ic)-10*(kis(mx,ic)/10))                          2500
              if (ig(m1,m2).ne.ig(n1,n2)) go to 710                         2501
  240       continue                                                        2502
            if (ncp.eq.0) go to 260                                         2503
            do 250 i=1,ncp                                                  2504
              if (ic.eq.ncl(i)) go to 710                                   2505
  250       continue                                                        2506
  260       ncp=ncp+1                                                       2507
            ncl(ncp)=ic                                                     2508
            if (noi.eq.1) ise=isb(ic)                                       2509
            do 700 is=1,ise                                                 2510
              if (ic.ne.30) go to 350                                       2511
c   triclinic case                                                          2512
c   search for a basis of shortest vectors                                  2513
              do 270 i=1,7                                                  2514
                do 270 j=1,7                                                2515
                if (i.lt.4.and.j.lt.4) a(i,j)=a(i,j)-a(4,j)                 2516
                gs(i,j)=0.0                                                 2517
                do 270 k=1,3                                                2518
                do 270 l=1,3                                                2519
  270           gs(i,j)=gs(i,j)+g(k,l)*float(inc(k,i)*inc(l,j))             2520
              do 280 i=1,6                                                  2521
                do 280 j=i,7                                                2522
                o(i,j)=gs(i,i)*gs(j,j)-gs(i,j)*gs(i,j)                      2523
                if (gs(i,i).le.gs(j,j)) go to 280                           2524
                nq(i)=nq(i)+1                                               2525
                nq(j)=nq(j)-1                                               2526
  280           o(j,i)=o(i,j)                                               2527
              do 290 i=1,7                                                  2528
  290           mq(nq(i))=i                                                 2529
c   test of surface condition                                               2530
              zw1=gs(mq(1),mq(1))                                           2531
              zw2=gs(mq(2),mq(2))                                           2532
              zw3=gs(mq(3),mq(3))                                           2533
              if (iiv(mq(1),mq(2)).eq.mq(3)) zw3=gs(mq(4),mq(4))            2534
              do 320 i=1,5                                                  2535
                id=mq(i)                                                    2536
                if (zw1.lt.gs(id,id)) go to 320                             2537
                do 310 j=i,6                                                2538
                  jd=mq(j)                                                  2539
                  if (j.eq.i.or.zw2.lt.gs(jd,jd)) go to 310                 2540
                  do 300 k=j,7                                              2541
                    kd=mq(k)                                                2542
                    if (k.eq.j.or.zw3.lt.gs(kd,kd).or.kd.eq.iiv(id,jd))     2543
     1               go to 300                                              2544
                    if (o(id,jd)+o(jd,kd)+o(id,kd).lt.zw4) go to 300        2545
                    kj(1)=id                                                2546
                    kj(2)=jd                                                2547
                    kj(3)=kd                                                2548
                    zw4=o(id,jd)+o(id,kd)+o(jd,kd)                          2549
  300             continue                                                  2550
  310           continue                                                    2551
  320         continue                                                      2552
c   standardization                                                         2553
              do 330 m=1,3                                                  2554
                do 330 l=1,3                                                2555
                gv(m,l)=gs(kj(m),kj(l))                                     2556
                gn(m,l)=0.0                                                 2557
                if (gv(m,l).ne.0.0) gn(m,l)=gv(m,l)/abs(gv(m,l))            2558
                do 330 j=1,3                                                2559
  330           av(l,m)=av(l,m)+a(l,j)*float(inc(j,kj(m)))                  2560
              n=14.5+gn(1,2)+3.0*gn(1,3)+9.0*gn(2,3)                        2561
              if (gv(1,1).eq.gv(2,2).and.abs(gv(2,3)).gt.abs(gv(1,3)))      2562
     1         iz=iz+1                                                      2563
              if (gv(3,3).eq.gv(2,2).and.abs(gv(1,3)).gt.abs(gv(1,2)))      2564
     1         iz=iz+2                                                      2565
              if (gv(1,1).eq.gv(3,3).and.abs(gv(2,3)).gt.abs(gv(1,2)))      2566
     1         iz=iz+4                                                      2567
              do 340 i=1,3                                                  2568
                do 340 j=1,3                                                2569
                e(i,j)=0.0                                                  2570
                do 340 k=1,3                                                2571
  340           e(i,j)=e(i,j)+float(itr(i,k,23+iq(n))*itr(k,j,nvv(iz)))     2572
              go to 480                                                     2573
c                                                                           2574
c   transformation to standard delaunay type                                2575
  350         if (is.gt.1) go to 400                                        2576
              do 370 i=1,4                                                  2577
                do 360 j=1,4                                                2578
                  gv(j,i)=0.0                                               2579
  360             e(j,i)=0.0                                                2580
  370           e(nl(i),i)=1.0                                              2581
              do 380 i=1,4                                                  2582
                do 380 j=1,4                                                2583
                a(i,j)=ad(i,1)*e(1,j)+ad(i,2)*e(2,j)+ad(i,3)*e(3,j)+        2584
     1           ad(i,4)*e(4,j)                                             2585
                do 380 k=1,4                                                2586
                do 380 l=1,4                                                2587
  380           gv(i,j)=gv(i,j)+g(k,l)*e(l,j)*e(k,i)                        2588
c   reduction to 3*3-matrix                                                 2589
              do 390 i=1,3                                                  2590
                do 390 j=1,3                                                2591
                gn(i,j)=gv(i,j)                                             2592
  390           a(i,j)=a(i,j)-a(4,j)                                        2593
c   transformation to conventional cell                                     2594
  400         isys=kis(8,ic)/10                                             2595
              nbr=kis(8,ic)-10*isys                                         2596
              n=kis(7,ic)                                                   2597
              if (is.eq.1) go to 420                                        2598
              do 410 i=1,3                                                  2599
                do 410 j=1,3                                                2600
                a(i,j)=aw(i,j)                                              2601
  410           gn(i,j)=gw(i,j)                                             2602
              n=itt(is-1,ik)/100                                            2603
              isys=(itt(is-1,ik)-100*n)/10                                  2604
              nbr=itt(is-1,ik)-100*n-10*isys                                2605
  420         zw1=1.0-5.*float(n/54)/6.                                     2606
              do 430 i=1,3                                                  2607
                do 430 j=1,3                                                2608
                av(i,j)=0.0                                                 2609
                gv(i,j)=0.0                                                 2610
                do 430 k=1,3                                                2611
                av(i,j)=av(i,j)+a(i,k)*zw1*float(itr(k,j,n))                2612
                do 430 l=1,3                                                2613
  430           gv(i,j)=gv(i,j)+zw1*zw1*gn(k,l)*float(itr(l,j,n)*itr(k,     2614
     1           i,n))                                                      2615
              iz=1                                                          2616
              if (isys-3) 460,440,510                                       2617
c   orthorhombic case                                                       2618
  440         if (gv(1,1).gt.gv(2,2)) iz=iz+1                               2619
              if (gv(1,1).gt.gv(3,3)) iz=iz+2                               2620
              if (gv(2,2).gt.gv(3,3)) iz=iz+4                               2621
              do 450 l=1,3                                                  2622
                do 450 m=1,3                                                2623
  450           e(l,m)=itr(l,m,mvv(iz))                                     2624
              if (nbr.gt.1.and.nbr.lt.5) nbr=4-iz/3                         2625
              go to 480                                                     2626
c                                                                           2627
c   monoclinic case                                                         2628
  460         zw=gv(1,1)+gv(3,3)-gv(1,3)*sign(2.0,gv(1,3))                  2629
              if (zw.lt.gv(1,1)) iz=iz+1                                    2630
              if (zw.lt.gv(3,3)) iz=iz+2                                    2631
              if (gv(3,3).lt.gv(1,1)) iz=iz+4                               2632
              if (nbr.eq.6) nbr=2*(mod(iz+2,4)+(iz/6)*(6/iz))               2633
              do 470 i=1,3                                                  2634
                do 470 j=1,3                                                2635
                e(i,j)=itr(i,j,lvv(iz))                                     2636
  470           if (i.ne.1) e(i,j)=-e(i,j)*sign(1.0,gv(1,3))                2637
  480         do 490 i=1,3                                                  2638
                do 490 j=1,3                                                2639
                a(i,j)=av(i,j)                                              2640
  490           gn(i,j)=gv(i,j)                                             2641
              do 500 i=1,3                                                  2642
                do 500 j=1,3                                                2643
                av(i,j)=a(i,1)*e(1,j)+a(i,2)*e(2,j)+a(i,3)*e(3,j)           2644
                gv(i,j)=0.0                                                 2645
                do 500 k=1,3                                                2646
                do 500 l=1,3                                                2647
  500           gv(i,j)=gv(i,j)+gn(k,l)*e(l,j)*e(k,i)                       2648
c   inversion of av                                                         2649
  510         do 520 i=1,2                                                  2650
                ii=i+1                                                      2651
                do 520 j=ii,3                                               2652
                n=6-i-j                                                     2653
                a(n,n)=av(i,i)*av(j,j)-av(i,j)*av(j,i)                      2654
                a(j,i)=av(n,i)*av(j,n)-av(n,n)*av(j,i)                      2655
  520           a(i,j)=av(n,j)*av(i,n)-av(n,n)*av(i,j)                      2656
              zw1=a(1,1)*av(1,1)+a(1,2)*av(2,1)+a(1,3)*av(3,1)              2657
c   preparation of output                                                   2658
              do 540 i=1,3                                                  2659
                do 530 j=1,3                                                2660
                  if (is.eq.1) aw(i,j)=av(i,j)                              2661
                  if (is.eq.1) gw(i,j)=gv(i,j)                              2662
  530             a(j,i)=a(j,i)/zw1                                         2663
                ac(i)=sqrt(gv(i,i))                                         2664
                j=i+1-3*(i/3)                                               2665
                zw=gv(i,j)/sqrt(gv(i,i)*gv(j,j))                            2666
  540           ac(9-i-j)=fakr*atan2(sqrt(1.0-zw*zw),zw)                    2667
              isj=is-1                                                      2668
              call cksys (isys,ac,iers,ddw,ddv)                             2669
              if (iers.ne.0) go to 680                                      2670
c                                                                           2671
              ii=1                                                          2672
              if (nbr.eq.7) ii=2                                            2673
              do 550 k=1,3                                                  2674
                do 550 i=1,3                                                2675
  550           if (abs(amod(av(i,k),1.)).gt..01) ii=3                      2676
c  check for equivalence, begin                                             2677
              if (ntr.eq.0) go to 590                                       2678
c                                                                           2679
c exclude transformations with non-integer matrix elements                  2680
              if (id33.ne.0.and.ii.eq.3) go to 680                          2681
c                                                                           2682
              do 570 i=1,ntr                                                2683
                if (isys.ne.ixt(i).or.ii.ne.ixe(i)) go to 570               2684
                do 560 j=1,6                                                2685
                  if (abs(ac(j)-xxt(j,i)).gt..001) go to 570                2686
  560           continue                                                    2687
                go to 680                                                   2688
  570         continue                                                      2689
              ntr=ntr+1                                                     2690
              ixt(ntr)=isys                                                 2691
              ixe(ntr)=ii                                                   2692
              do 580 i=1,6                                                  2693
  580           xxt(i,ntr)=ac(i)                                            2694
              go to 610                                                     2695
  590         ntr=1                                                         2696
              do 600 i=1,6                                                  2697
  600           xxt(i,ntr)=ac(i)                                            2698
              ixt(ntr)=isys                                                 2699
              ixe(ntr)=ii                                                   2700
c  check for equivalence, end                                               2701
c                                                                           2702
  610         if (isyz.ge.0.and.isys.lt.isyx.or.isyz.lt.0.and.isyx.ne.      2703
     1         isys) go to 660                                              2704
              if (ntr0.gt.0) go to 620                                      2705
              yyy=yy(isys)                                                  2706
c ????????    if (ii.eq.3) yyy=ni(ii)                                       2707
              write (io,820) ntr,yyy,y(isys),ht(nbr),(ac(i),i=1,6)          2708
              if (io.ne.ioa) write (ioa,820) ntr,yyy,y(isys),ht(nbr),       2709
     1         (ac(i),i=1,6)                                                2710
              nrt=nrt+1                                                     2711
              nli=nli+1                                                     2712
              if (iwm.eq.0) go to 660                                       2713
              write (io,830) ((av(i,k),i=1,3),k=1,3)                        2714
              if (io.ne.ioa) write (ioa,830) ((av(i,k),i=1,3),k=1,3)        2715
              nli=nli+2                                                     2716
              go to 660                                                     2717
c                                                                           2718
  620         if (ntr.lt.ntr0) go to 670                                    2719
              do 630 i=1,3                                                  2720
                dg(i)=ac(i)                                                 2721
                dgw(i)=ac(i+3)                                              2722
  630           dg(i+3)=cos(dgw(i)/fakr)                                    2723
              do 640 i=1,3                                                  2724
  640           if (abs(dgw(i)-90.).lt..001) dgw(i)=90.                     2725
              if (abs(dgw(3)-120.).lt..001) dgw(3)=120.                     2726
              if (abs(dgw(3)-60.).lt..001) dgw(3)=60.                       2727
              ila=nbr                                                       2728
              rs=r0                                                         2729
c                                                                           2730
              do 650 k=1,3                                                  2731
                do 650 i=1,3                                                2732
c                                                                           2733
                acp(i,k)=a(i,k)                                             2734
  650           apc(i,k)=av(i,k)                                            2735
              if (ila.eq.5.or.ila.eq.7) ila=12-ila                          2736
c                                                                           2737
              write (io,830) ((av(i,k),i=1,3),k=1,3)                        2738
              if (io.ne.ioa) write (ioa,830) ((av(i,k),i=1,3),k=1,3)        2739
c             nli=nli+1                                                     2740
              return                                                        2741
  660         if (nli.lt.limax-4) go to 680                                 2742
              write (ioa,840)                                               2743
              read (in,850,end=750) aww                                     2744
              if (law(aww)) return                                          2745
  670         nli=0                                                         2746
  680         do 690 i=1,13                                                 2747
  690           if (is.eq.1.and.10*isys+nbr.eq.idt(i)) ik=i                 2748
  700         if (ik.eq.7.and.ic.eq.6) ik=14                                2749
  710     continue                                                          2750
  720   continue                                                            2751
  730 continue                                                              2752
  740 if (g(3,3).lt.0.00001) write (ioa,790)                                2753
      if (ntr0.gt.0) write (ioa,860) ntr                                    2754
  750 return                                                                2755
  760 write (io,770)                                                        2756
      nnj=100                                                               2757
      return                                                                2758
c                                                                           2759
c                                                                           2760
c                                                                           2761
  770 format ('  *** symmetry indicator outside range -5 ... 5!')           2762
  780 format (' min. symm.: 1:mon., 2:orh., 3:tet., 4:hex., 5:cub.,',' <    2763
     10: only')                                                             2764
  790 format (/,' no finite volume'/)                                       2765
  800 format (' one line: # of transf. to be loaded (0: list all transf.    2766
     1)'/11x,'write matrix? (0:no, >0:yes)'/11x,'minim. symmetry? (0(=de    2767
     2f.):trk.,1:mcl.,2:orh.,3:tet.,4:hex.,5:cub.)')                        2768
  810 format (1x,'matrix refers to primitive setting'/15x,3f10.3,3f10.2/    2769
     1)                                                                     2770
  820 format (i8,a1,2x,a3,1x,a1,3f10.3,f9.2,2f8.2)                          2771
  830 format (17x,3(3f6.2,';',1x)/)                                         2772
  840 format (' cont.?')                                                    2773
  850 format (a1)                                                           2774
  860 format (' merely',i4,' transformations')                              2775
      end                                                                   2776
c #######===                                                                2777
      subroutine nrat (isu,ie,ioa,ncmi,ncma)                                2778
c number of c*-vektors in LD                                                2779
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     2780
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       2781
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    2782
      x33=xx(3,3)/dc                                                        2783
      isu=0                                                                 2784
      ncmi=10000                                                            2785
      ncma=0                                                                2786
      do 10 i=0,nce                                                         2787
        x33=x33*dc                                                          2788
        isum=npl(x33,ie,ioa,nx1,ny1)                                        2789
        ncmi=min0(ncmi,nci)                                                 2790
        ncma=max0(ncma,nci)                                                 2791
        ncmi=min0(ncmi,nx1/2)                                               2792
        ncmi=min0(ncmi,ny1/2)                                               2793
        ncma=min0(ncma,nx1/2)                                               2794
        ncma=min0(ncma,ny1/2)                                               2795
        if (ie.eq.1) return                                                 2796
        asu=isu+isum                                                        2797
        ie=0                                                                2798
        if (asu.lt.z8) go to 10                                             2799
        ie=1                                                                2800
        write (ioa,20)                                                      2801
        return                                                              2802
   10   isu=isu+isum                                                        2803
      return                                                                2804
c                                                                           2805
c                                                                           2806
c                                                                           2807
   20 format (' * too much grid points *')                                  2808
      end                                                                   2809
c #######======= 031                                                        2810
      function npl (x33,ie,ioa,nx1,ny1)                                     2811
c number of c*-vektors in a plane (LD)                                      2812
      parameter (jj4=20)                                                    2813
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     2814
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       2815
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    2816
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      2817
      ie=0                                                                  2818
      if (i05.lt.6) go to 10                                                2819
      npl=2                                                                 2820
      return                                                                2821
   10 del=da*x33                                                            2822
      nx=max1(rga2/del+.5,1.)                                               2823
      ny=max1(rgb2/del+.5,1.)                                               2824
      nx1=nx+1                                                              2825
      ny1=ny+1                                                              2826
      ncal=nx1*ny1                                                          2827
      if (i05.eq.0) go to 20                                                2828
      nci=1                                                                 2829
      if (db.gt.0.) nci=db/del+1.5                                          2830
      npl=ncal-max0(0,nx1-2*nci)*max0(0,ny1-i05*nci)                        2831
      if (float(npl).gt.z8) go to 30                                        2832
      return                                                                2833
   20 if (inda.gt.1) npl=ncal                                               2834
      if (inda.eq.1) npl=ncal+ny*(nx-1)                                     2835
      if (float(npl).le.z8) return                                          2836
c                                                                           2837
   30 ie=1                                                                  2838
      npl=0                                                                 2839
      write (ioa,40)                                                        2840
      return                                                                2841
c                                                                           2842
c                                                                           2843
c                                                                           2844
   40 format (' * too much grid points *')                                  2845
      end                                                                   2846
c #######======= 032                                                        2847
      subroutine ldini (a,b,ga,vmi,vma,io,ioa,in,iii,ipabs,mul3,ilim,       2848
     1ibr,iret)                                                             2849
c   determines a*, b*, gamma* and additional param. for <DC>                2850
c                                                                           2851
      parameter (jj4=20,jj3=140,jj5=100)                                    2852
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     2853
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        2854
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    2855
     2difa,difg,dc0                                                         2856
      common /b/ ii,jj,ila,ke,nq(jj4)                                       2857
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      2858
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      2859
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        2860
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     2861
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       2862
      common /cons2/ fk(7),sq3,a9                                           2863
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     2864
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      2865
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    2866
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                  2867
      common /j8/ j8(jj3),j9(jj3),j85(6)                                    2868
      character*2 j8,j9                                                     2869
      character*5 j85                                                       2870
      character*1 aw                                                        2871
      logical law                                                           2872
c dummy to use mul3                                                         2873
      nci=mul3                                                              2874
c                                                                           2875
      iret=0                                                                2876
      nci=1                                                                 2877
      ibrr=ibr                                                              2878
c                                                                           2879
      j=0                                                                   2880
      do 10 i=1,nx                                                          2881
   10   if (rf(1,i).gt..001.and.rf(40,i).eq.0.) j=j+1                       2882
      if (j.gt.1) go to 20                                                  2883
      write (ioa,150) j,j9(53),j9(118)                                      2884
      n=10                                                                  2885
      return                                                                2886
   20 call cksg (io,ioa,in,sv,vmin,vmax,iii,1,ilim,ibrr,iall)               2887
      if (n.eq.0.or.n.eq.10) return                                         2888
   30 a=r1/ak                                                               2889
      b=r2/ak                                                               2890
      vmaxp=0.                                                              2891
      vminp=0.                                                              2892
      if (vmax.lt..1.or.vmax.eq.vmin) go to 40                              2893
      dvr=amax1(sv-vmin,vmax-sv)+.05*sv                                     2894
      vminp=amax1(sv-dvr,10.)                                               2895
      vmaxp=sv+dvr                                                          2896
   40 rrgg(1)=a                                                             2897
      rrgg(2)=b                                                             2898
      ga=wi                                                                 2899
c                                                                           2900
      rrgg(6)=cos(ga*fak)                                                   2901
      cga2=rrgg(6)**2                                                       2902
      sga2=1.-cga2                                                          2903
      sga=sqrt(sga2)                                                        2904
      flc=rrgg(1)*rrgg(2)*sga                                               2905
c                                                                           2906
      h0=sqrt(flc)                                                          2907
      do 50 i=1,3                                                           2908
        do 50 j=1,3                                                         2909
   50   x(j,i)=0.                                                           2910
      x(1,1)=rrgg(1)                                                        2911
      x(1,2)=rrgg(2)*rrgg(6)                                                2912
      x(2,2)=rrgg(2)*sga                                                    2913
      x(3,3)=h0                                                             2914
c                                                                           2915
      do 60 i=1,2                                                           2916
        call mini1 (x,1,2)                                                  2917
   60   call mini1 (x,2,1)                                                  2918
c                                                                           2919
      call xtodg (x,rrgg)                                                   2920
      rrgg(6)=abs(rrgg(6))                                                  2921
      ga=acos(rrgg(6))/fak                                                  2922
      d=rrgg(1)+rrgg(2)                                                     2923
      rrgg(1)=amin1(rrgg(1),rrgg(2))                                        2924
      rrgg(2)=d-rrgg(1)                                                     2925
c                                                                           2926
c gleichschenkliges Dreieck                                                 2927
c                                                                           2928
      if (abs(ga-90.).lt.difg) go to 70                                     2929
      if (abs(rrgg(1)/rrgg(2)-1.).gt.difa) go to 70                         2930
      rrgg(2)=sqrt(rrgg(1)*rrgg(2))                                         2931
      rrgg(1)=rrgg(2)*sqrt(2.*(1.-rrgg(6)))                                 2932
      ga=90.-.5*ga                                                          2933
      rrgg(6)=cos(ga*fak)                                                   2934
c                                                                           2935
   70 cga2=rrgg(6)**2                                                       2936
      sga2=1.-cga2                                                          2937
      sga=sqrt(sga2)                                                        2938
      a=rrgg(1)                                                             2939
      b=rrgg(2)                                                             2940
c                                                                           2941
c  d-Wert fuer V(min)                                                       2942
c                                                                           2943
      vmn=1.e09                                                             2944
      do 80 i=1,iii                                                         2945
        j=ind(i)                                                            2946
   80   vmn=amin1(vmn,amax1(rf(3,j)+rf(4,j),rf(5,j)+rf(6,j))/(rf(1,j)-      2947
     1   rf(2,j)))                                                          2948
c                                                                           2949
      vmn=1./(vmn*a*b*sga)                                                  2950
c                                                                           2951
      call vlim (in,io,ioa,vmin,vmax,vminp,vmaxp,vmi,vma,sv,ie)             2952
      if (n.eq.0) return                                                    2953
      if (ie.eq.1) go to 30                                                 2954
      vsma=1./vmi                                                           2955
      vsmi=1./vma                                                           2956
      hmis=vsmi/flc                                                         2957
      hmas=vsma/flc                                                         2958
      q1=h0/hmas                                                            2959
      q2=h0/hmis                                                            2960
c                                                                           2961
      if (q2.le.15.) go to 90                                               2962
      write (ioa,130) q2                                                    2963
      read (in,140) aw                                                      2964
      if (law(aw)) go to 90                                                 2965
      iret=1                                                                2966
      return                                                                2967
c                                                                           2968
   90 do 100 i=1,3                                                          2969
        do 100 j=1,3                                                        2970
  100   x(j,i)=0.                                                           2971
      x(1,1)=rrgg(1)                                                        2972
      x(1,2)=rrgg(2)*rrgg(6)                                                2973
      x(2,2)=rrgg(2)*sga                                                    2974
      x(3,3)=hmas                                                           2975
      do 110 i=1,3                                                          2976
        do 110 j=1,3                                                        2977
  110   xx(j,i)=x(j,i)                                                      2978
      rrgg(3)=hmas                                                          2979
      rrgg(4)=0.                                                            2980
      rrgg(5)=0.                                                            2981
      rga2=.5*rrgg(1)                                                       2982
      rgb2=.5*rrgg(2)*sga                                                   2983
c                                                                           2984
      write (ioa,160) da0                                                   2985
      call les (in)                                                         2986
      if (n.eq.0) return                                                    2987
      if (abs(c(1)).le..0001.or.c(1).gt.6..or.c(1).lt.-.2) c(1)=1.          2988
      da=c(1)*da0                                                           2989
      if (c(1).lt.0.) da=-c(1)                                              2990
      dec5=fd*da                                                            2991
      dc=1.-da                                                              2992
c                                                                           2993
      c(2)=c(1)                                                             2994
c???   if (abs(c(2)).le..0001.or.c(2).gt.6..or.c(2).lt.-.2) c(2)=c(1)       2995
      daa=c(2)*dc0                                                          2996
      if (c(2).lt.0.) daa=-c(2)                                             2997
      dew=fw*daa/fak                                                        2998
      write (io,170) da                                                     2999
      if (io.ne.ioa) write (ioa,170) da                                     3000
c                                                                           3001
      nce=max1(1.,alog(hmis/hmas)/alog(dc)+0.5)                             3002
      dc=exp(alog(hmis/hmas)/amax0(nce,1))                                  3003
c                                                                           3004
      if (vma-vmi.lt..1) nce=0                                              3005
      call nrat (isu,ier,ioa,ncmi,ncma)                                     3006
      if (ier.eq.0) go to 120                                               3007
      n=0                                                                   3008
      return                                                                3009
  120 nca=nce+1                                                             3010
      if (db.eq.0.) write (ioa,180) isu,nca,q1,q2                           3011
      ncmi=min0(ncmi,999)                                                   3012
      ncma=min0(ncma,9999)                                                  3013
      if (db.gt.0.) write (ioa,190) isu,nca,q1,q2,ncmi,ncma                 3014
c                                                                           3015
      ipabs=0                                                               3016
      nc=-1                                                                 3017
      xx(2,3)=0.                                                            3018
      n4=0                                                                  3019
      xx(3,3)=xx(3,3)/dc                                                    3020
      return                                                                3021
c                                                                           3022
c                                                                           3023
c                                                                           3024
  130 format ('  *** warning *** :',/'  p(max) =',f5.1,' > 15. !'/'  low    3025
     1er V(P)max?')                                                         3026
  140 format (a1)                                                           3027
  150 format (i3,' (non excluded) data in memory A, at least 2 required     3028
     1(<',a2,'>,<',a2,'>)')                                                 3029
  160 format (' factor for default increment (',f5.3,'), def.:1., max:6;    3030
     1 <0 : increment')                                                     3031
  170 format (1x,2f8.3)                                                     3032
  180 format (/i10,' sets within',i4,' layers, p:',f7.3,' -',f7.3)          3033
  190 format (/i10,' sets within',i4,' layers, p:',f7.3,' -',f7.3,', cyc    3034
     1les:',i3,' -',i4)                                                     3035
      end                                                                   3036
c #######======= 033                                                        3037
      subroutine cksg (io,ioa,in,sv,vmi,vma,iii,ll,ilim,ibr,iall)           3038
c determines sequence etc. in A-mem. for <DC> and <SA>                      3039
      parameter (jj3=140,jj4=20)                                            3040
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      3041
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      3042
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        3043
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    3044
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        3045
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    3046
     2difa,difg,dc0                                                         3047
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      3048
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     3049
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                  3050
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     3051
      common /j8/ j8(jj3),j9(jj3),j85(6)                                    3052
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     3053
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       3054
      common /temper/ csig,rsig,asig                                        3055
      common /iskip/ iskip,isig,isig0                                       3056
      common /its/ ftst(9),itst(9)                                          3057
      dimension kg(2), st(7), f(jj4), ind1(jj4), ax(2), ay(2)               3058
      character*1 kg,st,kgg,kg1                                             3059
      character*2 j8,j9                                                     3060
      character*5 j85                                                       3061
      data kg,st/' ','<',' ','L','<','>','V','4','6'/                       3062
      jve=0                                                                 3063
      ilim=0                                                                3064
      cc2=0.                                                                3065
      jjj=0                                                                 3066
      ild=max0(ll,0)                                                        3067
      it=0                                                                  3068
      iii=0                                                                 3069
      ism=0                                                                 3070
      iex=0                                                                 3071
c                                                                           3072
c symmetry of the pattern                                                   3073
      do 30 i=1,nx                                                          3074
        f(i)=1.e10                                                          3075
        ind(i)=i                                                            3076
        irf(5,i)=1                                                          3077
        if (rf(1,i).le.0.) go to 30                                         3078
        if (abs(rf(3,i)/rf(7,i)-1.).lt.difa) irf(5,i)=4                     3079
        if (abs(rf(3,i)/rf(5,i)-1.).lt.difa) irf(5,i)=3                     3080
        if (abs(rf(5,i)/rf(7,i)-1.).lt.difa) irf(5,i)=5                     3081
        if (abs(rf(9,i)-90.).lt.difg) irf(5,i)=2                            3082
        if (abs((rf(3,i)-rf(5,i))/(rf(3,i)+rf(5,i))).gt..0001) go to 10     3083
        if (abs(rf(9,i)-90.).lt..005) irf(5,i)=6                            3084
        if (abs(rf(9,i)-60.).lt..005) irf(5,i)=7                            3085
   10   if (rf(40,i).eq.0.) go to 20                                        3086
        iex=iex+1                                                           3087
        go to 30                                                            3088
   20   iii=iii+1                                                           3089
        ism=max0(ism,irf(5,i))                                              3090
c                                                                           3091
c  sequence determining quantity                                            3092
c                                                                           3093
        f(i)=sqrt(rf(3,i)*rf(5,i)*sin(rf(9,i)*fak))/rf(1,i)                 3094
   30 continue                                                              3095
      iall=iex+iii                                                          3096
c                                                                           3097
      if (iall.eq.0) return                                                 3098
c                                                                           3099
c sort by f(i), if new a*-b* has been selected, ijb=3                       3100
c                                                                           3101
      ijb=2                                                                 3102
   40 ij=0                                                                  3103
      do 50 i=ijb,nx                                                        3104
        if (f(ind(i)).ge.f(ind(i-1))) go to 50                              3105
        ij=ind(i)                                                           3106
        ind(i)=ind(i-1)                                                     3107
        ind(i-1)=ij                                                         3108
   50 continue                                                              3109
      if (ij.ne.0) go to 40                                                 3110
c                                                                           3111
   60 write (io,490)                                                        3112
      if (io.ne.ioa) write (ioa,490)                                        3113
      sv=0.                                                                 3114
      vmi=1.e10                                                             3115
      vma=0.                                                                3116
      ii=0                                                                  3117
c                                                                           3118
c ild: 1 for PC, 0 for SA                                                   3119
c                                                                           3120
      do 70 i=1,nx                                                          3121
   70   ind1(ind(i))=i-ild                                                  3122
c                                                                           3123
      do 100 i=1,nx                                                         3124
        if (rf(1,i).eq.0.) go to 100                                        3125
        s1=100.*rf(4,i)/rf(3,i)                                             3126
        s2=100.*rf(6,i)/rf(5,i)                                             3127
        c(1)=rf(1,i)/rf(3,i)                                                3128
        c(2)=rf(1,i)/rf(5,i)                                                3129
        c(3)=rf(1,i)/rf(7,i)                                                3130
        c(4)=1./f(i)                                                        3131
        nn=1                                                                3132
        if (rf(13,i).lt.0.) nn=2                                            3133
        kgg=' '                                                             3134
        if (rf(40,i).ne.0.) kgg='e'                                         3135
        kg1=' '                                                             3136
        if (rf(25,i).eq.1.) kg1='d'                                         3137
        if (rf(25,i).eq.2.) kg1='r'                                         3138
        if (itst(6).gt.0) go to 80                                          3139
        write (io,500) i,st(irf(5,i)),kgg,kg1,c(1),s1,c(2),s2,c(3),rf(9,    3140
     1   i),rf(10,i),kg(nn),rf(22,i),c(4),ind1(i)                           3141
        if (io.ne.ioa) write (ioa,500) i,st(irf(5,i)),kgg,kg1,c(1),s1,      3142
     1   c(2),s2,c(3),rf(9,i),rf(10,i),kg(nn),rf(22,i),c(4),ind1(i)         3143
        if (rf(22,i).lt..01.or.rf(13,i).lt.0..or.rf(40,i).ne.0.) go to      3144
     1   100                                                                3145
        go to 90                                                            3146
c                                                                           3147
   80   write (io,510) i,st(irf(5,i)),kgg,kg1,c(1),s1,c(2),s2,c(3),rf(9,    3148
     1   i),rf(10,i),kg(nn),rf(22,i),c(4),ind1(i)                           3149
        if (io.ne.ioa) write (ioa,500) i,st(irf(5,i)),kgg,kg1,c(1),s1,      3150
     1   c(2),s2,c(3),rf(9,i),rf(10,i),kg(nn),rf(22,i),c(4),ind1(i)         3151
        if (rf(22,i).lt..01.or.rf(13,i).lt.0..or.rf(40,i).ne.0.) go to      3152
     1   100                                                                3153
c                                                                           3154
   90   vmi=amin1(vmi,rf(22,i))                                             3155
        vma=amax1(vma,rf(22,i))                                             3156
        sv=sv+rf(22,i)                                                      3157
        ii=ii+1                                                             3158
  100 continue                                                              3159
c                                                                           3160
      if (isig.eq.2.and.ibr.eq.60) write (ioa,590) csig,rsig,asig,          3161
     1j9(121)                                                               3162
c                                                                           3163
      do 110 i=1,nx                                                         3164
  110   if (rf(40,i).ne.0.) irf(5,i)=1                                      3165
c                                                                           3166
      if (ii.gt.0) sv=sv/float(ii)                                          3167
      if (ii.eq.0) vmi=0.                                                   3168
      if (ll) 410,420,120                                                   3169
c                                                                           3170
c  type of run:                                                             3171
c i05: 0: p2; 1: cmm; 2: pmm; 6: p4m; 7: p6m                                3172
c                                                                           3173
  120 if (it.eq.1) go to 150                                                3174
      i05=1                                                                 3175
      if (irf(5,ind(1)).eq.1) i05=0                                         3176
      if (irf(5,ind(1)).eq.2) i05=2                                         3177
      if (irf(5,ind(1)).gt.5) i05=irf(5,ind(1))                             3178
      if (cc2.lt.0.) i05=0                                                  3179
      if (cc2.lt.0.) go to 150                                              3180
      if (i05.gt.5) go to 150                                               3181
      if (i05.gt.0.and.ism.lt.6) go to 150                                  3182
c                                                                           3183
      do 140 i=2,iii                                                        3184
        if (irf(5,ind(i)).eq.1) go to 140                                   3185
        if (ism.gt.5.and.irf(5,ind(i)).lt.6) go to 140                      3186
        jj=ind(i)                                                           3187
        jjj=i                                                               3188
        do 130 ii=i,2,-1                                                    3189
  130     ind(ii)=ind(ii-1)                                                 3190
        ind(1)=jj                                                           3191
        i05=1                                                               3192
        if (irf(5,ind(1)).eq.2) i05=2                                       3193
        if (irf(5,ind(1)).gt.5) i05=irf(5,ind(1))                           3194
        if (cc2.lt.0.) i05=0                                                3195
        go to 150                                                           3196
  140 continue                                                              3197
c                                                                           3198
  150 thi1=.5*(rf(4,ind(1))+rf(6,ind(1)))                                   3199
      thi=thi1/rf(1,ind(1))                                                 3200
      write (ioa,520) ind(1),st(irf(5,ind(1))),(ind(i),st(irf(5,ind(i)))    3201
     1,i=2,iii)                                                             3202
      if (io.ne.ioa) write (io,520) ind(1),st(irf(5,ind(1))),(ind(i),       3203
     1st(irf(5,ind(i))),i=2,iii)                                            3204
      i05=1                                                                 3205
      if (irf(5,ind(1)).eq.1) i05=0                                         3206
      if (irf(5,ind(1)).eq.2) i05=2                                         3207
      if (irf(5,ind(1)).gt.5) i05=irf(5,ind(1))                             3208
      if (cc2.lt.0.) i05=0                                                  3209
c                                                                           3210
      if (iii.gt.2) go to 240                                               3211
c 2 patterns                                                                3212
      ddd=.01                                                               3213
c .01 hinterfragen!                                                         3214
      if (i05.gt.0) go to 170                                               3215
      do 160 i=3,7,2                                                        3216
        ax(1)=rf(i,ind(1))/rf(1,ind(1))                                     3217
        do 160 j=3,7,2                                                      3218
        ax(2)=rf(j,ind(2))/rf(1,ind(2))                                     3219
        if (abs(ax(1)-ax(2))/(ax(1)+ax(2)).lt.ddd) go to 230                3220
  160 continue                                                              3221
      go to 240                                                             3222
c                                                                           3223
  170 if (irf(5,ind(1)).gt.5.or.irf(5,ind(2)).eq.1) go to 240               3224
c                                                                           3225
c check for 'underdetermined'                                               3226
c                                                                           3227
      do 220 i=1,2                                                          3228
        rr3=rf(3,ind(i))/rf(1,ind(i))                                       3229
        rr5=rf(5,ind(i))/rf(1,ind(i))                                       3230
        if (irf(5,ind(i)).eq.2) go to 210                                   3231
c                                                                           3232
        rr7=rf(7,ind(i))/rf(1,ind(i))                                       3233
        go to (180,190,200),irf(5,ind(i))-2                                 3234
  180   ax(i)=sqrt((rr3+rr5)**2-rr7**2)                                     3235
        ay(i)=rr7                                                           3236
        go to 220                                                           3237
  190   ax(i)=sqrt((rr3+rr7)**2-rr5**2)                                     3238
        ay(i)=rr5                                                           3239
        go to 220                                                           3240
  200   ax(i)=sqrt((rr5+rr7)**2-rr3**2)                                     3241
        ay(i)=rr3                                                           3242
        go to 220                                                           3243
c                                                                           3244
  210   ax(i)=rr3                                                           3245
        ay(i)=rr5                                                           3246
  220 continue                                                              3247
c                                                                           3248
      if (abs(ax(1)-ax(2))/(ax(1)+ax(2)).gt.ddd.and.abs(ax(1)-ay(2))/       3249
     1(ax(1)+ay(2)).gt.ddd.and.abs(ay(1)-ax(2))/(ay(1)+ax(2)).gt.ddd.       3250
     2and.abs(ay(1)-ay(2))/(ay(1)+ay(2)).gt.ddd) go to 240                  3251
  230 write (ioa,480)                                                       3252
c                                                                           3253
c check end                                                                 3254
c                                                                           3255
c  'ok?'                                                                    3256
  240 write (ioa,530) thi1                                                  3257
      if (jve.gt.0) write (ioa,580)                                         3258
      jve=1                                                                 3259
      if (i05.lt.6) go to 250                                               3260
      write (ioa,440) ind(1)                                                3261
      if (i05.eq.6) write (ioa,450)                                         3262
      if (i05.eq.7) write (ioa,460)                                         3263
  250 db=0.                                                                 3264
      call les (in)                                                         3265
      if (ndi(1).gt.mdi) n=0                                                3266
      if (n.eq.0) n=10                                                      3267
      if (n.eq.10) return                                                   3268
      cc2=c(2)                                                              3269
      if (cc2) 260,280,270                                                  3270
c full grid                                                                 3271
  260 i05=0                                                                 3272
      go to 280                                                             3273
c 'wall'                                                                    3274
  270 db=c(2)*thi                                                           3275
c no changes                                                                3276
  280 if (c(1).eq.0.) go to 380                                             3277
c                                                                           3278
      jj=abs(c(1))+.5                                                       3279
      if (jj.gt.nx) go to 300                                               3280
      if (rf(1,jj).le.0.) go to 290                                         3281
      if (rf(40,jj).eq.0.) go to 310                                        3282
      write (ioa,470) jj                                                    3283
      go to 240                                                             3284
c                                                                           3285
  290 write (ioa,540) jj                                                    3286
      go to 240                                                             3287
c                                                                           3288
  300 write (ioa,550) nx                                                    3289
      go to 240                                                             3290
c                                                                           3291
  310 it=1                                                                  3292
      do 320 i=iii,2,-1                                                     3293
        if (ind(i).eq.jj) go to 330                                         3294
  320 continue                                                              3295
c                                                                           3296
c a*-b* ok                                                                  3297
c                                                                           3298
      write (ioa,560) (ind(i),i=1,iii)                                      3299
      go to 380                                                             3300
c                                                                           3301
  330 if (jjj.eq.0) go to 350                                               3302
      i=ind(jjj)                                                            3303
      ind(jjj)=ind(1)                                                       3304
      ind(1)=i                                                              3305
      do 340 i=iii,2,-1                                                     3306
        if (ind(i).eq.jj) go to 350                                         3307
  340 continue                                                              3308
c                                                                           3309
      go to 370                                                             3310
c                                                                           3311
  350 do 360 ii=i,2,-1                                                      3312
  360   ind(ii)=ind(ii-1)                                                   3313
      ind(1)=jj                                                             3314
c                                                                           3315
  370 if (nx.lt.3) go to 60                                                 3316
      ijb=3                                                                 3317
      go to 40                                                              3318
c                                                                           3319
  380 call htoa (ind(1))                                                    3320
      inda=irf(5,ind(1))                                                    3321
      do 390 i=1,iii-1                                                      3322
  390   ind(i)=ind(i+1)                                                     3323
      iii=iii-1                                                             3324
c#####                                                                      3325
      call uni (r1,r2,wi,r1n,r2n,win,r3n,fak,ier)                           3326
      do 400 j=1,iii                                                        3327
        i=ind(j)                                                            3328
        call uni (rf(3,i),rf(5,i),rf(9,i),r1m,r2m,wim,r3m,fak,ier1)         3329
        d=ak/rf(1,i)                                                        3330
        if (abs(1.-d*r1m/r1n).gt.2.*dr1/r1.or.abs(1.-d*r2m/r2n).gt.2.*      3331
     1   dr2/r2.or.abs(wim-win).gt.2.*dwi) go to 400                        3332
        write (ioa,430) i                                                   3333
        ilim=ilim+1                                                         3334
  400 continue                                                              3335
c                                                                           3336
  410 return                                                                3337
c                                                                           3338
  420 if (iii.eq.0) return                                                  3339
      write (io,570) (ind(i),i=1,iii)                                       3340
      if (io.ne.ioa) write (ioa,570) (ind(i),i=1,iii)                       3341
      return                                                                3342
c                                                                           3343
c                                                                           3344
c                                                                           3345
  430 format (' ** pattern',i3,' close to the a*,b*-defining pattern')      3346
  440 format (/12x,'****** warning: with pattern',i3,' a*,b*-defining')     3347
  450 format (12x,'****** all cells will be tetragonal or cubic')           3348
  460 format (12x,'****** all cells will be hexag., trig. R or cubic')      3349
  470 format (' ** pattern',i3,' excluded! **')                             3350
  480 format (1x,34('*')/' ****  warning, indeterminate  ****'/1x,34('*'    3351
     1))                                                                    3352
  490 format ('  #',9x,'d1   s/d(%)    d2  s/d(%)   d3     ang. sig.        3353
     1 V      d-m  seq.')                                                   3354
  500 format (i3,1x,a1,1x,2a1,2(f9.4,f5.2),f9.4,f6.1,f5.1,1x,a1,f7.1,f7.    3355
     13,i3)                                                                 3356
  510 format (i3,1x,a1,1x,2a1,2(f9.2,f5.2),f9.2,f6.1,f5.1,1x,a1,f7.1,f7.    3357
     13,i3)                                                                 3358
  520 format (/' a*,b*-defining:',i3,';',a1/7x,'sequence:     ',10(i3,';    3359
     1',a1)/21x,10(i3,';',a1))                                              3360
  530 format (/'   1st: new a*,b* defining number (0: no changes)'/'   2    3361
     1nd: <0: enforce full grid, >0: * sigma (',f4.2,'mm) = "wall thickn    3362
     2ess"')                                                                3363
  540 format (i4,' is empty')                                               3364
  550 format (' out of range (max.:',i2,')')                                3365
  560 format (' sequence not changed, ',15i3)                               3366
  570 format (' sequence:',13i3)                                            3367
  580 format (' 0 or <return> if ok')                                       3368
  590 format (/' *** temporary sigmas for cc, r, ang.:',2f7.3,'(rel.)',     3369
     1f7.3,'(deg.)'/5x,'will be applied; <',a2,'> and "n" to switch to o    3370
     2riginal individual sigmas')                                           3371
      end                                                                   3372
c #######======= 034                                                        3373
      subroutine rlgen (ie,nrlc,ipabs,ngkk,nall,dx,dy,dz,ittest)            3374
c generates cell parameters for <DC>                                        3375
c                                                                           3376
      parameter (jj4=20,jj5=100)                                            3377
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    3378
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       3379
     2jfw                                                                   3380
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     3381
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     3382
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       3383
      common /srsr/ imx(jj5),xna(jj5),xnb(jj5),xnc(jj5),x1,x2,x3,           3384
     1ffom(jj5),dgld(6,jj5),vld(jj5),azb(jj5),czb(jj5)                      3385
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      3386
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    3387
      dimension xxx(3,3)                                                    3388
      character*1 aw                                                        3389
      logical law                                                           3390
      ie=0                                                                  3391
c                                                                           3392
      if (n4.gt.1) go to 40                                                 3393
      if (n4.eq.0) go to 30                                                 3394
c                                                                           3395
   10 nm=min0(nru,ngkk)                                                     3396
      if (nm.gt.0) write (ioa,80)                                           3397
      if (nm.gt.0) write (io,90) (ffom(imx(j)),(dgld(i,imx(j)),i=1,6),      3398
     1xna(imx(j)),xnb(imx(j)),xnc(imx(j)),vld(imx(j)),j=1,nm)               3399
      if (nm.gt.0.and.io.ne.ioa) write (ioa,90) (ffom(imx(j)),(dgld(i,      3400
     1imx(j)),i=1,6),xna(imx(j)),xnb(imx(j)),xnc(imx(j)),vld(imx(j)),j=     3401
     21,nm)                                                                 3402
c                                                                           3403
      if (nc.ge.nce) go to 60                                               3404
c                                                                           3405
      x33=xx(3,3)*dc                                                        3406
      dz=xx(3,3)-x33                                                        3407
      ipab=npl(x33,ier,ioa,nx1,ny1)                                         3408
      ipabs=ipabs+ipab                                                      3409
c                                                                           3410
      vv=v/dc                                                               3411
      flc1=flcc/dc                                                          3412
      nco=nci0-1                                                            3413
      if (i05.eq.0) nco=999                                                 3414
      if (nru.gt.0) write (io,100) nall,ngkk,vv,flc1,ipab,ipabs,nco         3415
      if (io.ne.ioa.and.nru.gt.0) write (ioa,100) nall,ngkk,vv,flc1,        3416
     1ipab,ipabs,nco                                                        3417
      if (istp1.lt.2.or.nall.eq.0) go to 20                                 3418
      write (ioa,110)                                                       3419
      read (in,120,end=60) aw                                               3420
      if (law(aw)) go to 60                                                 3421
   20 if (nall.gt.0.and.(istp1.eq.0.or.istp1.eq.2)) go to 30                3422
      nrlc=nrlc+ipab                                                        3423
      if (nrlc.gt.nstop) ie=2                                               3424
c                                                                           3425
   30 xx(3,3)=xx(3,3)*dc                                                    3426
      flcc=h0/xx(3,3)                                                       3427
c                                                                           3428
      del=da*xx(3,3)                                                        3429
      nci=1                                                                 3430
      if (db.gt.0.) nci=db/del+1.5                                          3431
      v=1./(flc*xx(3,3))                                                    3432
      nc=nc+1                                                               3433
      n4=1                                                                  3434
c                                                                           3435
   40 call rlg (rga2,rgb2,del,x1,x2,i05,nci,n4,dx,dy,nci0,ittest)           3436
      if (n4.eq.1) go to 10                                                 3437
c#######                                                                    3438
      if (ittest.ne.0) write (6,70) rga2,rgb2,del,x1,x2,i05,nci,n4,dx,      3439
     1dy,nci0                                                               3440
      xx(1,3)=x1                                                            3441
      xx(2,3)=x2                                                            3442
      x3=xx(3,3)                                                            3443
c#######                                                                    3444
      if (ittest.ne.0) write (6,70) x1,x2,x3                                3445
      if (ittest.ne.0) read (5,*) jhjhjh                                    3446
c#######                                                                    3447
      do 50 i=1,3                                                           3448
        do 50 j=1,3                                                         3449
   50   xxx(j,i)=xx(j,i)                                                    3450
      call xtodg (xxx,rg)                                                   3451
cc                                                                          3452
      if (abs(rg(4)).lt.flim.and.abs(rg(5)).lt.flim) return                 3453
      call minni (xxx,1)                                                    3454
      call xtodg (xxx,rg)                                                   3455
      return                                                                3456
c                                                                           3457
   60 ie=1                                                                  3458
      return                                                                3459
c                                                                           3460
c                                                                           3461
c                                                                           3462
   70 format (2f9.5,f9.6,2x,2f8.5,2x,3i3,2f8.5,i3)                          3463
   80 format (6x,' R ',6x,'a',6x,'b',6x,'c     al    be    ga',6x,'x        3464
     1 y     z      V')                                                     3465
   90 format (4x,f6.2,1x,3f7.2,f7.1,2f6.1,1x,3f6.3,f7.0)                    3466
  100 format (i10,' solutions,',i4,' stored'//1x,'V:',f7.0,',p:',f6.3,',    3467
     1 n:',i6,', total',i8,', cycles:',i4)                                  3468
  110 format (' cont.?')                                                    3469
  120 format (a1)                                                           3470
      end                                                                   3471
c #######======= 035                                                        3472
      subroutine rlg (aa,bb,del,xjx,xjy,i05,nci,n1,dx,dy,nci0,ittest)       3473
c generates xjx(=x1) and xjy(=x2)                                           3474
      parameter (jj4=20)                                                    3475
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      3476
c                                                                           3477
c i05: 0: tricl., 1: centered, 2: rectang.,6:quadr., 7:hexag.               3478
c                                                                           3479
c n1: 1: new layer                                                          3480
c     2: cont. vertical                                                     3481
c     3: cont: horizontal                                                   3482
c     4: begin, triclinic case                                              3483
c     5: cont.,    "       "                                                3484
c                                                                           3485
      if (i05.gt.5) go to 140                                               3486
      go to (10,30,60,100,130),n1                                           3487
c                                                                           3488
c new layer                                                                 3489
c                                                                           3490
   10 nx=max1(aa/del+.5,1.)                                                 3491
      ny=max1(bb/del+.5,1.)                                                 3492
      dx=aa/float(nx)                                                       3493
      dy=bb/float(ny)                                                       3494
c                                                                           3495
      if (i05.eq.0) go to 90                                                3496
      xb=-1.                                                                3497
      xe=float(nx+1)                                                        3498
      yb=-1.                                                                3499
      ye=float(ny+1)                                                        3500
c                                                                           3501
      nci1=min0(nci,1+min0(nx,ny)/2)                                        3502
      if (i05.eq.1) nci1=min0(nci,1+nx/2)                                   3503
      nci=nci1                                                              3504
      nci0=0                                                                3505
c                                                                           3506
c new cycle                                                                 3507
c                                                                           3508
   20 nci0=nci0+1                                                           3509
      if (nci0.gt.nci) go to 80                                             3510
      n1=2                                                                  3511
      isw=0                                                                 3512
      xb=xb+1.                                                              3513
      xe=xe-1.                                                              3514
      yb=yb+1.                                                              3515
      ye=ye-1.                                                              3516
c                                                                           3517
c 1st vertical line                                                         3518
c                                                                           3519
      x=xb                                                                  3520
      y=yb-1.                                                               3521
      if (i05.eq.1) ye=float(ny)                                            3522
c                                                                           3523
c new vertical line                                                         3524
c                                                                           3525
   30 isw=mod(isw+1,2)                                                      3526
      if (isw.eq.0) go to 40                                                3527
      y=y+1.                                                                3528
      if (y.gt.ye) go to 50                                                 3529
      xjy=y*dy                                                              3530
      xjx=xb*dx                                                             3531
      return                                                                3532
   40 if (xe.le.xb) go to 30                                                3533
      xjx=xe*dx                                                             3534
      return                                                                3535
c                                                                           3536
c new horizontal line                                                       3537
c                                                                           3538
   50 n1=3                                                                  3539
      isw=0                                                                 3540
      x=xb                                                                  3541
   60 isw=mod(isw+1,2)                                                      3542
c#####                                                                      3543
      iiii=6                                                                3544
      if (ittest.ne.0) write (6,*) iiii,isw,i05,x                           3545
      if (ittest.ne.0) read (5,*) iiij                                      3546
c#####                                                                      3547
      if (isw.eq.0.and.i05.eq.2) go to 70                                   3548
      x=x+1.                                                                3549
      if (x.ge.xe) go to 20                                                 3550
      xjx=x*dx                                                              3551
      xjy=yb*dy                                                             3552
      return                                                                3553
ccccccc .le. !                                                              3554
c#######                                                                    3555
   70 if (ye.le.yb.or.x.ge.xe) go to 60                                     3556
      xjy=ye*dy                                                             3557
      return                                                                3558
c                                                                           3559
c layer finished                                                            3560
c                                                                           3561
   80 n1=1                                                                  3562
      return                                                                3563
c                                                                           3564
c triclinic case                                                            3565
c                                                                           3566
   90 x=-1                                                                  3567
      xb=-float(nx)                                                         3568
      if (inda.gt.1) xb=-1                                                  3569
      xe=float(nx)                                                          3570
      ye=float(ny)                                                          3571
      y=0.                                                                  3572
      xjy=0.                                                                3573
      n1=4                                                                  3574
c                                                                           3575
  100 x=x+1.                                                                3576
      if (x.gt.xe) go to 110                                                3577
      xjx=x*dx                                                              3578
      return                                                                3579
c                                                                           3580
  110 n1=5                                                                  3581
  120 x=xb                                                                  3582
      y=y+1.                                                                3583
      if (y.gt.ye) go to 80                                                 3584
  130 x=x+1.                                                                3585
      if (x.gt.xe) go to 120                                                3586
      xjx=x*dx                                                              3587
      xjy=y*dy                                                              3588
      return                                                                3589
c                                                                           3590
  140 if (n1.eq.2) go to 150                                                3591
      if (n1.eq.3) go to 80                                                 3592
      xjx=0.                                                                3593
      xjy=0.                                                                3594
      n1=2                                                                  3595
      return                                                                3596
c                                                                           3597
  150 n1=3                                                                  3598
      xjx=aa                                                                3599
      xjy=bb                                                                3600
      if (i05.eq.7) xjy=2.*bb/3.                                            3601
      return                                                                3602
      end                                                                   3603
c ----------------------                                                    3604
c          Hier war CEN                                                     3605
c #######======= 036                                                        3606
      logical function amea(a,b)                                            3607
c checks condition a=b                                                      3608
      amea=.false.                                                          3609
      if (2.*abs(a-b)/(a+b).lt..00001) amea=.true.                          3610
      return                                                                3611
      end                                                                   3612
c #######======= 037                                                        3613
      subroutine srt (kim,ngkk,imx,v,val1,valk)                             3614
c sorting by integral or V                                                  3615
      parameter (jj5=100)                                                   3616
      dimension imx(jj5), v(jj5)                                            3617
c                                                                           3618
      do 10 i=1,ngkk                                                        3619
   10   imx(i)=i                                                            3620
c                                                                           3621
   20 nn=0                                                                  3622
      do 50 i=1,ngkk-1                                                      3623
        if (kim.eq.1) go to 30                                              3624
        if (v(imx(i+1)).ge.v(imx(i))) go to 50                              3625
        go to 40                                                            3626
   30   if (v(imx(i+1)).le.v(imx(i))) go to 50                              3627
   40   k=imx(i)                                                            3628
        imx(i)=imx(i+1)                                                     3629
        imx(i+1)=k                                                          3630
        nn=1                                                                3631
   50 continue                                                              3632
      if (nn.gt.0) go to 20                                                 3633
      val1=v(imx(1))                                                        3634
      valk=v(imx(ngkk))                                                     3635
      if (kim.ne.1) return                                                  3636
      valk=valk/val1                                                        3637
      val1=1.                                                               3638
      return                                                                3639
      end                                                                   3640
c #######======= 038                                                        3641
      function htod (b)                                                     3642
c hexadec. integers >0 -> decimal                                           3643
c                                                                           3644
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     3645
      character*1 a,b                                                       3646
      dimension a(17), b(22)                                                3647
      data a/'1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'    3648
     1,'0',' '/                                                             3649
      htod=0.                                                               3650
c hexadec. col.1 - max. 21                                                  3651
      do 10 i=1,16                                                          3652
        if (b(22).eq.a(i)) go to 70                                         3653
   10 continue                                                              3654
c                                                                           3655
      do 20 i=21,1,-1                                                       3656
        k=i                                                                 3657
        if (b(i).ne.' ') go to 30                                           3658
   20 continue                                                              3659
      return                                                                3660
c                                                                           3661
   30 do 60 i=1,k                                                           3662
        do 40 j=1,17                                                        3663
          jj=j                                                              3664
          if (b(i).eq.a(j)) go to 50                                        3665
   40   continue                                                            3666
        htod=-1.                                                            3667
        return                                                              3668
c                                                                           3669
   50   if (jj.gt.15) jj=0                                                  3670
        htod=htod+float(jj)                                                 3671
        if (i.eq.k) return                                                  3672
   60   htod=htod*16.                                                       3673
      return                                                                3674
   70 write (6,80)                                                          3675
      htod=-1.                                                              3676
      return                                                                3677
c                                                                           3678
c                                                                           3679
c                                                                           3680
   80 format (' *** number too large ***')                                  3681
      end                                                                   3682
c #######======= 039                                                        3683
      subroutine hex (in,ioa,ajex,ajey,ak)                                  3684
c SAD data from hexadec. readouts (prtest m2)                               3685
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     3686
      dimension cc(8)                                                       3687
      character*1 b(22)                                                     3688
      n=1                                                                   3689
      write (ioa,150)                                                       3690
      read (in,160,end=140) b                                               3691
      d=htod(b)                                                             3692
      if (d) 140,20,10                                                      3693
   10 cc(1)=d                                                               3694
c                                                                           3695
   20 write (ioa,170)                                                       3696
      read (in,160,end=140) b                                               3697
      d=htod(b)                                                             3698
      if (d) 140,40,30                                                      3699
   30 cc(2)=d                                                               3700
c                                                                           3701
   40 write (ioa,180)                                                       3702
      read (in,160,end=140) b                                               3703
      d=htod(b)                                                             3704
      if (d) 140,60,50                                                      3705
   50 cc(3)=d                                                               3706
c                                                                           3707
   60 write (ioa,190)                                                       3708
      read (in,160,end=140) b                                               3709
      d=htod(b)                                                             3710
      if (d) 140,80,70                                                      3711
   70 cc(4)=d                                                               3712
      d=sqrt((ajex*(cc(1)-cc(3)))**2+(ajey*(cc(2)-cc(4)))**2)               3713
      c(15)=ak/amax1(d,1.e-5)                                               3714
      write (ioa,200) d,c(15)                                               3715
c                                                                           3716
      write (ioa,210)                                                       3717
      call les (in)                                                         3718
      if (n.eq.0) go to 140                                                 3719
      cc(5)=c(1)                                                            3720
c                                                                           3721
   80 write (ioa,220)                                                       3722
      read (in,160,end=140) b                                               3723
      d=htod(b)                                                             3724
      if (d) 140,100,90                                                     3725
   90 cc(6)=d                                                               3726
c                                                                           3727
  100 write (ioa,230)                                                       3728
      read (in,160,end=140) b                                               3729
      d=htod(b)                                                             3730
      if (d) 140,120,110                                                    3731
  110 cc(7)=d                                                               3732
      d=sqrt((ajex*(cc(1)-cc(6)))**2+(ajey*(cc(2)-cc(7)))**2)               3733
      c(15)=ak/amax1(d,1.e-5)                                               3734
      write (ioa,200) d,c(15)                                               3735
c                                                                           3736
      write (ioa,210)                                                       3737
      call les (in)                                                         3738
      if (n.eq.0) go to 140                                                 3739
      cc(8)=c(1)                                                            3740
c                                                                           3741
  120 do 130 i=1,8                                                          3742
  130   c(i)=cc(i)                                                          3743
      return                                                                3744
c                                                                           3745
  140 n=0                                                                   3746
      return                                                                3747
c                                                                           3748
c                                                                           3749
c                                                                           3750
  150 format (' x0? (always: 0=keep, "g" - "z" to escape)')                 3751
  160 format (25a1)                                                         3752
  170 format (' y0?')                                                       3753
  180 format (' x1?')                                                       3754
  190 format (' y1?')                                                       3755
  200 format (2x,f10.3,' mm, d:',f8.5)                                      3756
  210 format ('  n? (0 or <ret.> = 1)')                                     3757
  220 format (' x2?')                                                       3758
  230 format (' y2?')                                                       3759
      end                                                                   3760
c #######======= 040                                                        3761
      subroutine rfo (rf,dew2,dec5,fak,c,i)                                 3762
c forms additional quantities for temporary errors                          3763
c                                                                           3764
      parameter (jj4=20)                                                    3765
      dimension rf(40,jj4), c(15)                                           3766
      do 10 j=2,6,2                                                         3767
   10   if (rf(j,i)/rf(j-1,i).lt.dec5) rf(j,i)=dec5*rf(j-1,i)               3768
c                                                                           3769
      rf(32,i)=(rf(1,i)+rf(2,i))**2                                         3770
      rf(33,i)=(amax1(.2*rf(1,i),rf(1,i)-rf(2,i)))**2                       3771
      rf(26,i)=(amax1(.1,rf(3,i)-rf(4,i)))**2/rf(32,i)                      3772
      rf(27,i)=(amax1(.1,rf(5,i)-rf(6,i)))**2/rf(32,i)                      3773
      rf(28,i)=(rf(3,i)+rf(4,i))**2/rf(33,i)                                3774
      rf(29,i)=(rf(5,i)+rf(6,i))**2/rf(33,i)                                3775
      rf(37,i)=sqrt(amax1(rf(28,i),rf(29,i)))                               3776
      rf(10,i)=amax1(rf(10,i),dew2)                                         3777
c                                                                           3778
      c(1)=rf(9,i)*fak                                                      3779
      c(2)=rf(10,i)*fak                                                     3780
      c(3)=cos(c(1))                                                        3781
      if (c(3).eq.0.) c(3)=1.e-15                                           3782
      c(4)=cos(c(1)+c(2))                                                   3783
      c(5)=cos(amax1(0.,c(1)-c(2)))                                         3784
      if (rf(9,i)+rf(10,i).ge.180.) c(4)=-1.                                3785
      if (rf(9,i).lt.rf(10,i)) c(5)=1.                                      3786
      rf(35,i)=amax1(abs(c(4)),abs(c(5)))                                   3787
      rf(36,i)=amin1(abs(c(4)),abs(c(5)))                                   3788
      if (c(4)*c(5).le.0.) rf(36,i)=0.                                      3789
      return                                                                3790
      end                                                                   3791
c #######======= 041                                                        3792
      subroutine hexrh (iz)                                                 3793
c prepares check for trig.R, u+v=3n, w=3n                                   3794
c                                                                           3795
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     3796
      iz=0                                                                  3797
      do 10 i=1,6                                                           3798
   10   if (amod(c(i),1.).ne.0.) iz=1                                       3799
      if (iz.eq.1) return                                                   3800
      c(11)=igt(int(c(1)),int(c(2)),int(c(3)))                              3801
      c(12)=igt(int(c(4)),int(c(5)),int(c(6)))                              3802
      do 20 i=1,3                                                           3803
        c(i)=c(i)/c(11)                                                     3804
   20   c(i+3)=c(i+3)/c(12)                                                 3805
      return                                                                3806
      end                                                                   3807
c ####### P3 ########                                                       3808
c #######======= 042                                                        3809
      subroutine such (ittest)                                              3810
c  master program                                                           3811
c                                                                           3812
c letzte Aenderung: if ...  fdd=fsc                                         3813
c ke00 eingefuehrt (Raumgruppensymbol anpassen)                             3814
c  L0< : tilt                                                               3815
c                                                                           3816
      parameter (jj1=1999,jj2=199,jj3=140,jj4=20,jj5=100,llin=78)           3817
c-p      parameter (jj1=5999,jj2=999,jj3=140,jj4=20,jj5=100,llin=78)        3818
      dimension ormx(3)                                                     3819
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    3820
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       3821
     2jfw                                                                   3822
      common /tran/ acp(3,3),apc(3,3)                                       3823
      common /cd1/ d1d(jj1),d2d(jj1),h1h(3,jj1),h2h(3,jj1)                  3824
      common /cgg/ gg(14,jj2),ac(jj2)/izz/izm(jj2),i6(jj3)                  3825
      common /b/ ii,jj,ila,ke,nq(jj4)                                       3826
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      3827
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      3828
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        3829
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        3830
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    3831
     2difa,difg,dc0                                                         3832
      common /j8/ j8(jj3),j9(jj3),j85(6)                                    3833
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     3834
      common /sb1/ jsm(7),jsml(7),ivo(2),s1(2),p7(2),p7l(2),p9(2),p8(2),    3835
     1rs,holder(3)                                                          3836
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                   3837
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv            3838
      common /cons2/ fk(7),sq3,a9                                           3839
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      3840
      common /ti/ titel(18),text(17),tit(18,jj4)                            3841
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     3842
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     3843
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       3844
      common /srsr/ imx(jj5),xna(jj5),xnb(jj5),xnc(jj5),x1,x2,x3,           3845
     1ffom(jj5),dgld(6,jj5),vld(jj5),azb(jj5),czb(jj5)                      3846
      common /ldcon/ rga2,rgb2,n4,z8,vmn,i05,nci,ism,thi                    3847
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                  3848
      common /files/ file1,file2,file3,file4,file5,fdd                      3849
      common /its/ ftst(9),itst(9)                                          3850
      common /iskip/ iskip,isig,isig0                                       3851
c                                                                           3852
      common /wis/ a1(48),a2(48),a3(48),wn(48),nn                           3853
c Vorsicht, x1 --> xx1 etc. !                                               3854
      common /wi/ xx1,xx2,xx3,dd                                            3855
c                                                                           3856
      common /xc/ xc(4),xm                                                  3857
      common /temper/ csig,rsig,asig                                        3858
      common /zone/ izo(3),zoo(3,3),gow(2,3)                                3859
      dimension cd(6), cr(6), i4(6), i5(6), tex(17), skd(13,jj4), dgd(6)    3860
     1, dg0(6), dgw0(3), dgdw(3), jz(3), tid(18), rc(3), aq(llin), i7(4)    3861
     2, ssfom(jj5), ifree(jj4), nex(jj4), ju(13), cvm(6)                    3862
      character*1 jsm,jsml,isy,ivo,s1,p7,p7l,p9,p8,aw,aq,kgg,s4,chd(32)     3863
      character*2 j8,j9,cha2(5),zzz                                         3864
      character*3 s2,ormx                                                   3865
      character*4 isys,titel,tit,text,ta,ta1,tex,ta0,ta0l,p6,s3,tid,ta2     3866
      character*5 j85,tstp(3),tout(3)                                       3867
      character rs*10,rs0*10,rs00*10,rs000*10,holder*11                     3868
      character*20 file1,file2,file3,file4,file5,filer,file6,fdd,fsc        3869
      logical law,amea                                                      3870
      data tstp,tout/'layer','match',' none',' full',' red.','minim'/       3871
      data isl,ioo,nsc,istp,if4,if5,ngkk,iiv,isr,nls,ibeg,ild,ldst/1,88,    3872
     111*0/                                                                 3873
      data fkk,nz,ilo,nra,jze,kim/2.,4,4*0/                                 3874
      data tid/18*'    '/                                                   3875
      data ormx/' R ','int',' V '/                                          3876
      data ju/2,4,6,10,35,36,26,27,28,29,37,32,33/                          3877
c                                                                           3878
c nz: number of lines/set in SAD-file                                       3879
c                                                                           3880
c     ittest=0                                                              3881
c ############                                                              3882
c     iwww=0    ????????????????????????                                    3883
c ############                                                              3884
      iou=ioo                                                               3885
      ifu=if5                                                               3886
      ivm=0                                                                 3887
      msca=0                                                                3888
      fsc=file5                                                             3889
      iza=1                                                                 3890
      csig=csig0                                                            3891
      rsig=rsig0                                                            3892
      asig=asig0                                                            3893
      ajex=xj                                                               3894
      ajey=yj                                                               3895
      ahex=xjh                                                              3896
      ahey=yjh                                                              3897
      ngkk=0                                                                3898
      mul3=mul2                                                             3899
      jlin=llin                                                             3900
      ihot=iho                                                              3901
      ihon=iho                                                              3902
      if (ihot.eq.3) ihot=1                                                 3903
      id33=itst(5)                                                          3904
      ke00=0                                                                3905
      z8=10.**mdi                                                           3906
      fdi=ifdi                                                              3907
      flim0=flim                                                            3908
      icmd=icm                                                              3909
      pftst1=100.*ftst(1)                                                   3910
      s0k=sk                                                                3911
      s0r1=sr1                                                              3912
      s0wi=swi                                                              3913
      yzx0=yzx                                                              3914
      ydx0=ydx                                                              3915
c                                                                           3916
      do 10 i=1,nx                                                          3917
        rf(1,i)=0.                                                          3918
   10   ind(i)=i                                                            3919
c                                                                           3920
      nsub=0                                                                3921
      ssr=100.*sr1                                                          3922
      rs0=rs                                                                3923
      xla=xl                                                                3924
      nwm=min0(nwm,ibe)                                                     3925
      nbb=nwm                                                               3926
      iun=io                                                                3927
      ddifw=difw                                                            3928
      ddazb=dazb                                                            3929
      ddl0=dl0                                                              3930
      ddl1=dl1                                                              3931
      fak=1./fakr                                                           3932
      ski=100.*sk                                                           3933
      hv=hv0                                                                3934
      ihv=jhv(hv)                                                           3935
      vd=vdd/100.+1.                                                        3936
      vj=vdd                                                                3937
      ala=alam(hv)                                                          3938
      ig=in                                                                 3939
      ig1=in                                                                3940
      izo(1)=0                                                              3941
      izo(2)=0                                                              3942
      izo(3)=0                                                              3943
c                                                                           3944
c TI  ----- titel --------                                                  3945
c                                                                           3946
   20 if (ibr.ne.50) go to 30                                               3947
      write (ioa,3780)                                                      3948
      read (in,4440,end=3170) aw                                            3949
      if (law(aw)) go to 3170                                               3950
   30 if (itst(3).gt.0) go to 90                                            3951
      write (ioa,4340)                                                      3952
      do 40 i=1,18                                                          3953
   40   tid(i)=titel(i)                                                     3954
      read (in,4350,end=50) titel                                           3955
c                                                                           3956
c NP - new pattern ------                                                   3957
c                                                                           3958
      if (ibr.ne.50) go to 80                                               3959
      if (titel(1).ne.'.'.and.titel(1).ne.',') go to 70                     3960
   50 if (r1.eq.0.) go to 30                                                3961
      do 60 i=1,18                                                          3962
   60   titel(i)=tid(i)                                                     3963
      go to 3170                                                            3964
   70 l=-1                                                                  3965
      l7=1                                                                  3966
      j4=1                                                                  3967
      an0=0.                                                                3968
      an1=0.                                                                3969
      an2=0.                                                                3970
      ph=0.                                                                 3971
      ihot=0                                                                3972
      r0=0.                                                                 3973
c spaeter raus                                                              3974
      r01=0.                                                                3975
c                                                                           3976
      rl1=0.                                                                3977
      r0m=0.                                                                3978
      sr0=dl0                                                               3979
      su1=dl1                                                               3980
      vca=0.                                                                3981
      ild=0                                                                 3982
   80 if (l) 570,90,3180                                                    3983
c                                                                           3984
c CP -- cell parameters ----                                                3985
c                                                                           3986
   90 if (itst(3).le.0) go to 100                                           3987
      ig=igl                                                                3988
      go to 130                                                             3989
  100 write (ioa,4360) igl,igh,in,ig1                                       3990
      write (6,3320) igl,file1                                              3991
      write (6,3330) ig1,fdd                                                3992
      if (if4.ne.0) write (ioa,3790) isl                                    3993
      call les (in)                                                         3994
      if (n.eq.0.or.ndi(1).gt.mdi) go to (90,3170),l+1                      3995
      titel(18)='    '                                                      3996
      ig=c(1)                                                               3997
      if (ig.eq.in) go to 220                                               3998
      if (ig) 110,210,120                                                   3999
  110 ig=ig1                                                                4000
      if (ig.ne.in) go to 140                                               4001
      go to 220                                                             4002
c                                                                           4003
  120 if (if4.eq.0.or.ig.ne.isl) go to 130                                  4004
      ig1=ig                                                                4005
      rewind ig                                                             4006
      write (6,5120) fsc                                                    4007
      go to 140                                                             4008
  130 if (ig.gt.igh.or.ig.lt.igl) go to 90                                  4009
      if (ig.eq.ig1) go to 140                                              4010
      call opn (ig,1,n,itst(3))                                             4011
      rewind ig                                                             4012
      if (n.eq.0) go to (3170,90,3170),l+2                                  4013
      if (n.eq.2.and.ig1.ne.isl) ig=ig1                                     4014
      if (ig1.ne.in.and.ig.ne.ig1.and.ig1.ne.isl) call clos (ig1)           4015
      ig1=ig                                                                4016
  140 if (itst(3).gt.0) go to 160                                           4017
      write (ioa,4370)                                                      4018
      read (in,4350,end=3170) ta                                            4019
      if (ta.eq.ta0.or.ta.eq.ta0l) go to (90,3170),l+1                      4020
      if (ta.eq.'    ') go to 160                                           4021
      rewind ig                                                             4022
c                                                                           4023
      if (ild.eq.1) go to 2360                                              4024
      i=0                                                                   4025
  150 read (ig,4350,end=190) ta1,text                                       4026
      if (ta1.eq.'END$') go to 190                                          4027
      i=i+1                                                                 4028
      ta2=ta1                                                               4029
      if (ta1.eq.ta) go to 200                                              4030
      read (ig,4350,end=190)                                                4031
      read (ig,4350,end=190)                                                4032
      go to 150                                                             4033
c                                                                           4034
c      v?                                                                   4035
  160 irh=0                                                                 4036
      if (ild.eq.1) go to 2360                                              4037
      read (ig,4350,end=170) ta1,text                                       4038
      if (ta1.ne.'END$') go to 200                                          4039
c                                                                           4040
  170 if (ig.eq.1) fdd=fsc                                                  4041
      write (ioa,4380) ig,fdd                                               4042
c  4960: ============                                                       4043
      if (iy.eq.2.and.iop.eq.0.and.iun.ne.8) write (iun,5010)               4044
      iun=io                                                                4045
      iy=0                                                                  4046
      isf=1                                                                 4047
      rewind ig                                                             4048
      if (ibr.ne.54) go to 180                                              4049
cc end=20 ok??                                                              4050
      read (ig,4350,end=190) ta,text                                        4051
      ta1=ta                                                                4052
      ibr=12                                                                4053
      jze=0                                                                 4054
      msca=1                                                                4055
      l=1                                                                   4056
      write (ioa,3300) ta                                                   4057
      go to 240                                                             4058
  180 if (l) 90,90,3180                                                     4059
c      "i" sh. "ta2=ta1" (ca. label 15)                                     4060
  190 write (ioa,4390) ta,i,ta2                                             4061
      rewind ig                                                             4062
      ta1=' '                                                               4063
      call clt (text)                                                       4064
      if (l) 90,90,3180                                                     4065
  200 if (itst(3).gt.0) go to 230                                           4066
      if (iy.eq.0) write (io,4570) ta1,(text(i),i=1,16)                     4067
      if (iy.eq.0.and.io.ne.ioa) write (ioa,4570) ta1,(text(i),i=1,16)      4068
      go to 230                                                             4069
c                                                                           4070
  210 ig=in                                                                 4071
  220 write (ioa,4400)                                                      4072
  230 if (ig.ne.in) go to 240                                               4073
      call les (ig)                                                         4074
      if (n.eq.0) go to (220,3170),l+1                                      4075
      if (c(1).eq.0.) go to 90                                              4076
      go to 250                                                             4077
  240 read (ig,*) (c(i),i=1,6)                                              4078
  250 ad=c(1)                                                               4079
      if (ig.ne.in) go to 260                                               4080
      ta1='    '                                                            4081
      call clt (text)                                                       4082
c                                                                           4083
  260 do 270 i=1,3                                                          4084
        dg(i)=abs(c(i))                                                     4085
        if (dg(i).eq.0.) dg(i)=1.                                           4086
        dgw(i)=abs(c(i+3))                                                  4087
  270   if (dgw(i).eq.0.) dgw(i)=90.                                        4088
c                                                                           4089
c                                                                           4090
      if (ibr.ne.54) go to 310                                              4091
      dg(4)=cos(dgw(1)*fak)                                                 4092
      dg(5)=cos(dgw(2)*fak)                                                 4093
      dg(6)=cos(dgw(3)*fak)                                                 4094
      read (ig,4440) isy,rs                                                 4095
      jze=1                                                                 4096
      if (rs.eq.'          ') rs=rs0                                        4097
c                                                                           4098
      do 280 i=1,7                                                          4099
        if (isy.eq.jsm(i).or.isy.eq.jsml(i)) go to 290                      4100
  280 continue                                                              4101
      ila=1                                                                 4102
      go to 300                                                             4103
  290 ila=i                                                                 4104
      if (ila.eq.5.and.dgw(3).ne.120.) ila=1                                4105
  300 v3=dg(1)*dg(2)*dg(3)*sqrt(1.-dg(4)**2-dg(5)**2-dg(6)**2+2.*dg(4)*     4106
     1dg(5)*dg(6))/fk(ila)                                                  4107
      if (v3.lt.vmi.or.v3.gt.vma) go to 160                                 4108
c                                                                           4109
  310 ke=0                                                                  4110
      irh=0                                                                 4111
      if (amea(dg(1),dg(2))) dg(1)=dg(2)                                    4112
      if (amea(dg(1),dg(3))) dg(3)=dg(1)                                    4113
      if (abs(dgw(1)-90.).lt..005) go to 340                                4114
      if (dgw(2).ne.dgw(1).or.dgw(3).ne.dgw(1).or.dg(1).ne.dg(2).or.        4115
     1dg(1).ne.dg(3)) go to 370                                             4116
      if (dgw(1).ge.120..or.dgw(1).lt..0001) go to 400                      4117
c                                                                           4118
c  rhombohedral  P -> R                                                     4119
c                                                                           4120
      if (ad.ge.0.) go to 330                                               4121
      dg(4)=cos(dgw(1)*fak)                                                 4122
      dg(5)=dg(4)                                                           4123
      dg(6)=dg(4)                                                           4124
c                                                                           4125
      do 320 i=1,6                                                          4126
  320   rg(i)=dg(i)                                                         4127
c                                                                           4128
      call dire (rg,dg,dgw,fakr,v0,ier)                                     4129
      if (ier.eq.1) go to 400                                               4130
      c(1)=1.                                                               4131
  330 call rhrh (dg,dgw,fak,sq3)                                            4132
c                                                                           4133
      irh=1                                                                 4134
      rs=rs0                                                                4135
      if (iy.eq.0) write (io,4650)                                          4136
      if (iy.eq.0.and.io.ne.ioa) write (ioa,4650)                           4137
      ke=2                                                                  4138
      ila=5                                                                 4139
      go to 370                                                             4140
c                                                                           4141
c  rhombohedral  P -> R:  end                                               4142
c                                                                           4143
  340 dgw(1)=90.                                                            4144
      if (abs(dgw(2)-90.).lt..005) go to 350                                4145
      if (abs(dgw(3)-90.).lt..005) ke=1                                     4146
      go to 370                                                             4147
c                                                                           4148
  350 dgw(2)=90.                                                            4149
      if (abs(dgw(3)-90.).lt..005) go to 360                                4150
      if (abs(dgw(3)-120.).lt..005.and.amea(dg(1),dg(2))) ke=2              4151
      go to 370                                                             4152
c                                                                           4153
  360 dgw(3)=90.                                                            4154
      ke=3                                                                  4155
      if (.not.amea(dg(1),dg(2))) go to 370                                 4156
      ke=4                                                                  4157
      if (amea(dg(2),dg(3))) ke=5                                           4158
  370 if (ke.eq.1) dgw(3)=90.                                               4159
      if (ke.eq.2) dgw(3)=120.                                              4160
      dg(4)=cos(dgw(1)*fak)                                                 4161
      dg(5)=cos(dgw(2)*fak)                                                 4162
      dg(6)=cos(dgw(3)*fak)                                                 4163
      ke00=ke                                                               4164
      if (c(1).ge.0.) go to 390                                             4165
c                                                                           4166
      do 380 i=1,6                                                          4167
  380   rg(i)=dg(i)                                                         4168
c                                                                           4169
      call dire (rg,dg,dgw,fakr,v0,ier)                                     4170
      if (ier.eq.1) go to 400                                               4171
  390 call dire (dg,rg,rgw,fakr,v0,ier)                                     4172
      if (ier.eq.0) go to 420                                               4173
  400 irh=0                                                                 4174
      if (ig.eq.in) go to 410                                               4175
      write (ioa,5000) ta1                                                  4176
      read (ig,4440)                                                        4177
c    if (iun.ne.ioa) write (iun,4970) ta1                                   4178
      if (iun.ne.8) write (iun,5000) ta1                                    4179
      go to (3180,160,160,160),iy+1                                         4180
c                                                                           4181
  410 write (ioa,4410)                                                      4182
      if (l) 90,90,3180                                                     4183
c                                                                           4184
  420 v3=v0/fk(ila)                                                         4185
c                                                                           4186
      if (ke.ne.ke00) rs=rs0                                                4187
      if (iy.eq.0.and.ig.eq.in) write (io,4420) (dg(i),i=1,3),dgw,          4188
     1jsm(ila),v0,isys(ke+1),(rg(i),i=1,3),rgw,jsm(ila),rs                  4189
      if (iy.eq.0.and.ig.eq.in.and.io.ne.ioa) write (ioa,4420) (dg(i),i=    4190
     11,3),dgw,jsm(ila),v0,isys(ke+1),(rg(i),i=1,3),rgw,jsm(ila),rs         4191
  430 call orth (rg,dg,cr,cd,v0,sg)                                         4192
c                                                                           4193
      if (ibr.eq.1.and.ig.eq.in) go to 450                                  4194
      if (ivm.ne.0) go to 450                                               4195
      sfom=0.                                                               4196
      if (ibr.eq.74.or.ibr.eq.62.or.ibr.eq.65) go to 3180                   4197
      if (ild.eq.1) go to 540                                               4198
      ig2=ig                                                                4199
      if (ig2.eq.in) go to 440                                              4200
      if (irh.eq.0.or.ibr.eq.54) go to 460                                  4201
      read (ig2,4440)                                                       4202
      irh=0                                                                 4203
      go to 510                                                             4204
  440 if (l.gt.0) go to 3180                                                4205
c                                                                           4206
c CN  --- centering ----                                                    4207
c                                                                           4208
  450 write (ioa,4430) jsm                                                  4209
      ig2=in                                                                4210
c                                                                           4211
      if (irh.eq.1) rs=rs0                                                  4212
      if (irh.eq.1) go to 500                                               4213
  460 if (jze.eq.1) go to 530                                               4214
      read (ig2,4440,end=3170) isy,rs                                       4215
      if (rs.eq.'          ') rs=rs0                                        4216
c                                                                           4217
c                                                                           4218
      do 470 i=1,7                                                          4219
        if (isy.eq.jsm(i).or.isy.eq.jsml(i)) go to 480                      4220
  470 continue                                                              4221
c                                                                           4222
      ila=1                                                                 4223
      go to 490                                                             4224
c                                                                           4225
  480 ila=i                                                                 4226
  490 if (irh.eq.0) go to 510                                               4227
      ila=5                                                                 4228
  500 irh=0                                                                 4229
  510 v3=v0/fk(ila)                                                         4230
c                                                                           4231
c wenn nicht gescannt wird (RH,SC etc.) aber vom file gelesen wird (GF)?    4232
c                                                                           4233
      if (msca.eq.1) go to 3180                                             4234
      if (itst(3).le.0) go to 520                                           4235
c                                                                           4236
      write (ioa,3310) igl,file1                                            4237
      go to 530                                                             4238
  520 if (iy.eq.0.and.ig2.ne.in) write (io,4420) (dg(i),i=1,3),dgw,         4239
     1jsm(ila),v0,isys(ke+1),(rg(i),i=1,3),rgw,jsm(ila),rs                  4240
      if (iy.eq.0.and.ig2.ne.in.and.io.ne.ioa) write (ioa,4420) (dg(i),     4241
     1i=1,3),dgw,jsm(ila),v0,isys(ke+1),(rg(i),i=1,3),rgw,jsm(ila),rs       4242
c                                                                           4243
c centering, (nearly) end                                                   4244
c wenn weder RH noch LD: (auch IY<2 moeglich?)                              4245
c                                                                           4246
  530 if (isr.eq.0) go to 560                                               4247
c                                                                           4248
  540 isr0=0                                                                4249
  550 isr0=isr0+1                                                           4250
c                                                                           4251
      ns=ind(isr0)                                                          4252
      call htoa (ns)                                                        4253
      ix=2                                                                  4254
c                                                                           4255
c> restore                                                                  4256
      go to 1890                                                            4257
c                                                                           4258
c> ST (IX=2 nach ST (ueberspringt Aufbereitung der Aufnahme), 1 sonst)      4259
  560 if (iy.gt.0) go to (960,970),ix                                       4260
      if (ig2.eq.in) write (io,4450) jsm(ila),rs                            4261
      if (ig2.eq.in.and.io.ne.ioa) write (ioa,4450) jsm(ila),rs             4262
      ig=in                                                                 4263
      if (l.gt.0) go to 3180                                                4264
c                                                                           4265
c centering, end                                                            4266
c                                                                           4267
c CC -- camera constant ----                                                4268
c                                                                           4269
  570 if (itst(3).gt.0) go to 1770                                          4270
      write (ioa,4460) ski                                                  4271
      call les (in)                                                         4272
      l=max0(l,0)                                                           4273
      if (n.eq.0) go to (570,3170),l+1                                      4274
      if (c(1)) 590,580,600                                                 4275
  580 ibr=34                                                                4276
      ine=i6(ibr)                                                           4277
      go to 1780                                                            4278
c                                                                           4279
  590 write (ioa,3800) hv                                                   4280
      akl0=c(1)                                                             4281
      dak0=c(2)                                                             4282
      call les (in)                                                         4283
      if (n.eq.0) go to 570                                                 4284
      if (c(1).le.0.) c(1)=hv                                               4285
      hv=c(1)                                                               4286
      ihv=jhv(hv)                                                           4287
      ala=alam(hv)                                                          4288
      c(1)=akl0                                                             4289
      c(2)=dak0                                                             4290
c                                                                           4291
      akl=-c(1)                                                             4292
      ak=ala*akl                                                            4293
      dak=c(2)*ala                                                          4294
      ix=1                                                                  4295
      go to 610                                                             4296
c                                                                           4297
  600 ix=1                                                                  4298
      dak=c(2)                                                              4299
      ak=c(1)                                                               4300
      akl=ak/ala                                                            4301
  610 write (io,3810) hv,ala                                                4302
      if (io.ne.ioa) write (ioa,3810) hv,ala                                4303
c                                                                           4304
      call cvol (v,fk,ila)                                                  4305
c                                                                           4306
  620 if (dak.lt.1.e-10) dak=sk*ak                                          4307
      dakl=akl*dak/ak                                                       4308
      write (io,3820) ak,dak,akl,dakl                                       4309
      if (io.ne.ioa) write (ioa,3820) ak,dak,akl,dakl                       4310
      aku2=amax1(.2*ak,ak-dak)                                              4311
      if (dak.gt.0.8*ak) write (ioa,4470) aku2                              4312
      aku2=aku2**2                                                          4313
      ako2=(ak+dak)**2                                                      4314
      if (l.gt.0) go to 3180                                                4315
c                                                                           4316
c R1 ---- 1st radius -----                                                  4317
c                                                                           4318
  630 j=1                                                                   4319
      if (itst(4).eq.0) write (ioa,4510) j,ssr                              4320
      if (itst(4).ne.0) write (ioa,4530) j,ssr                              4321
      call les (in)                                                         4322
      if (n.eq.0) go to (630,3170),l+1                                      4323
      if (abs(c(1)).lt..0001) go to 630                                     4324
c                                                                           4325
      if (itst(4).eq.0) go to 640                                           4326
      c(8)=c(2)                                                             4327
      c(2)=c(3)                                                             4328
      c(3)=c(8)                                                             4329
c                                                                           4330
  640 ix=1                                                                  4331
      d=c(3)                                                                4332
      if (d.lt.0.01) d=1.                                                   4333
      if (c(1).lt.0.) go to 650                                             4334
      r1=c(1)/d                                                             4335
      dr1=abs(c(2))/d                                                       4336
      go to 660                                                             4337
  650 r1=-ak/(c(1)*d)                                                       4338
      dr1=ak*abs(c(2))/c(1)**2                                              4339
  660 if (dr1.lt.0.0001) dr1=sr1*r1                                         4340
      c(1)=ak/r1                                                            4341
      c(2)=amin1(999.999,dr1*ak/r1**2)                                      4342
      write (ioa,3830) r1,dr1,c(1),c(2)                                     4343
      call cvol (v,fk,ila)                                                  4344
      if (l.gt.0) go to 710                                                 4345
c                                                                           4346
c R2 ---- 2nd radius -----                                                  4347
c                                                                           4348
  670 j=2                                                                   4349
      if (itst(4).eq.0) write (ioa,4510) j,ssr                              4350
      if (itst(4).ne.0) write (ioa,4530) j,ssr                              4351
      call les (in)                                                         4352
      if (n.eq.0) go to (670,3170),l+1                                      4353
      if (abs(c(1)).lt..0001) go to 670                                     4354
c                                                                           4355
      if (itst(4).eq.0) go to 680                                           4356
      c(8)=c(2)                                                             4357
      c(2)=c(3)                                                             4358
      c(3)=c(8)                                                             4359
c                                                                           4360
  680 ix=1                                                                  4361
      d=c(3)                                                                4362
      if (d.lt.0.01) d=1.                                                   4363
      if (c(1).lt.0.) go to 690                                             4364
      r2=c(1)/d                                                             4365
      dr2=abs(c(2))/d                                                       4366
      go to 700                                                             4367
  690 r2=-ak/(c(1)*d)                                                       4368
      dr2=ak*abs(c(2))/c(1)**2                                              4369
  700 if (dr2.lt.0.0001) dr2=sr1*r2                                         4370
      c(1)=ak/r2                                                            4371
      c(2)=amin1(999.999,dr2*ak/r2**2)                                      4372
      call cvol (v,fk,ila)                                                  4373
      write (ioa,3830) r2,dr2,c(1),c(2)                                     4374
      if (l.le.0) go to 720                                                 4375
  710 dr3=0.                                                                4376
      r3=rr33(r1,r2,fak,wi)                                                 4377
      if (ibr+l.eq.35) go to 1200                                           4378
      if (l) 850,850,3180                                                   4379
c                                                                           4380
c AN ------ angle ------                                                    4381
c                                                                           4382
  720 write (ioa,4550) swi                                                  4383
      call les (in)                                                         4384
      if (n.eq.0) go to (720,3170),l+1                                      4385
      ix=1                                                                  4386
      if (c(1).eq.0.) go to 740                                             4387
      wi=abs(c(1))                                                          4388
      wi=amod(wi,360.)                                                      4389
      if (wi.gt.180.) wi=360.-wi                                            4390
      dwi=abs(c(2))                                                         4391
  730 if (dwi.lt.0.001) dwi=swi                                             4392
      dwi=amax1(dwi,.006)                                                   4393
      call cvol (v,fk,ila)                                                  4394
      write (ioa,3940) wi,dwi                                               4395
      go to 710                                                             4396
c                                                                           4397
c R3 ---- 3rd radius -----                                                  4398
c                                                                           4399
  740 if (itst(4).eq.0) write (ioa,4520) ssr                                4400
      if (itst(4).eq.1) write (ioa,4540) ssr                                4401
      call les (in)                                                         4402
      if (n.eq.0) go to (720,3170),l+1                                      4403
      if (abs(c(1)).lt..0001) go to 740                                     4404
      if (r1.eq.0..or.r2.eq.0.) go to 3160                                  4405
c                                                                           4406
      if (itst(4).eq.0) go to 750                                           4407
      c(8)=c(2)                                                             4408
      c(2)=c(3)                                                             4409
      c(3)=c(8)                                                             4410
      c(8)=c(5)                                                             4411
      c(5)=c(6)                                                             4412
      c(6)=c(8)                                                             4413
c                                                                           4414
  750 ix=1                                                                  4415
c                                                                           4416
      d=c(3)                                                                4417
      if (d.lt.0.01) d=1.                                                   4418
      if (c(1).lt.0.) go to 760                                             4419
      r3=c(1)/d                                                             4420
      dr3=abs(c(2))/d                                                       4421
      go to 770                                                             4422
  760 r3=-ak/(c(1)*d)                                                       4423
      dr3=ak*abs(c(2))/c(1)**2                                              4424
  770 if (dr3.lt.0.0001) dr3=sr1*r3                                         4425
c                                                                           4426
      g(1)=abs(r1-r2)                                                       4427
      g(2)=r1+r2                                                            4428
      if (r3.ge.g(1).and.r3.le.g(2)) go to 780                              4429
      write (ioa,4560) r3,g(1),g(2)                                         4430
      go to 740                                                             4431
  780 if (c(4).eq.0.) go to 820                                             4432
      d=c(6)                                                                4433
      if (d.lt.0.01) d=1.                                                   4434
      if (c(4).lt.0.) go to 790                                             4435
      r4=c(4)/d                                                             4436
      dr4=c(5)/d                                                            4437
      go to 800                                                             4438
  790 r4=-ak/(c(4)*d)                                                       4439
      dr4=ak*abs(c(5))/c(4)**2                                              4440
  800 if (dr4.lt.0.0001) dr4=sr1*r4                                         4441
      if (r4.ge.g(1).and.r4.le.g(2)) go to 810                              4442
      write (ioa,4560) r4,g(1),g(2)                                         4443
      go to 740                                                             4444
c                                                                           4445
  810 call test (r1,r2,r3,r4,wi,swi,dwi,fakr,ie,in,io,ioa)                  4446
      if (ie.le.0) r3=rr33(r1,r2,fak,wi)                                    4447
      if (ie) 840,840,740                                                   4448
c                                                                           4449
  820 wi=fakr*arco((r1*r1+r2*r2-r3*r3)/(2.*r1*r2))                          4450
      dwi=0.                                                                4451
      call cvol (v,fk,ila)                                                  4452
c                                                                           4453
      do 830 i=1,3,2                                                        4454
        sa=amax1(1.e-10,r1+dr1*float(i-2))                                  4455
        do 830 j=1,3,2                                                      4456
        sb=amax1(1.e-10,r2+dr2*float(j-2))                                  4457
        do 830 k=1,3,2                                                      4458
        sg=r3+dr3*float(k-2)                                                4459
  830   dwi=amax1(dwi,abs(wi-fakr*arco((sa*sa+sb*sb-sg*sg)/(2.*sa*sb))))    4460
      dwi=amax1(dwi,.1)                                                     4461
c new:                                                                      4462
      dwi=amin1(dwi,5.)                                                     4463
c                                                                           4464
  840 c(1)=ak/r3                                                            4465
      c(2)=amin1(999.999,dr3*ak/r3**2)                                      4466
      write (ioa,3840) r3,dr3,c(1),c(2),wi,dwi                              4467
      if (ibr+l.eq.35) go to 1200                                           4468
      if (l) 850,850,3180                                                   4469
c                                                                           4470
c WT -- weights for FOM ---                                                 4471
c                                                                           4472
  850 if (itst(3).le.0) write (ioa,4480) wiw,wiv,wik                        4473
      if (l.eq.0) go to 860                                                 4474
      call les (in)                                                         4475
      if (n.eq.0) go to 3170                                                4476
      viw=abs(c(1))                                                         4477
      viv=abs(c(2))                                                         4478
      vik=abs(c(3))                                                         4479
      if (viw+viv+vik.gt.1.e-10) go to 870                                  4480
  860 viw=wiw                                                               4481
      viv=wiv                                                               4482
      vik=wik                                                               4483
      l=1                                                                   4484
  870 viw=amax1(.0001*(viv+vik),viw)                                        4485
      viv=amax1(.0001*(viw+vik),viv)                                        4486
      vik=amax1(.0001*(viw+viv),vik)                                        4487
      if (itst(3).le.0) write (ioa,3940) viw,viv,vik                        4488
      swt=viw+viv+vik                                                       4489
      if (itst(3).le.0) go to 880                                           4490
      itst(3)=0                                                             4491
      go to 1200                                                            4492
  880 if (ibr-34) 3180,1200,3180                                            4493
c                                                                           4494
c ND -- new default errors ---                                              4495
c                                                                           4496
  890 write (ioa,3850) sk,sr1,swi,dl0,dl1,s0k,s0r1,s0wi,ddl0,ddl1           4497
      call les (in)                                                         4498
      if (n.eq.0) go to 3170                                                4499
      sk=c(1)                                                               4500
      if (sk.lt..001.or.sk.gt..9) sk=s0k                                    4501
      ski=100.*sk                                                           4502
      sr1=c(2)                                                              4503
      if (sr1.lt..001.or.sr1.gt..9) sr1=s0r1                                4504
      ssr=100.*sr1                                                          4505
      swi=c(3)                                                              4506
      if (swi.lt..001.or.swi.gt.45.) swi=s0wi                               4507
      dl0=c(4)                                                              4508
      if (dl0.lt..001.or.dl0.gt.40.) dl0=ddl0                               4509
      dl1=c(5)                                                              4510
      if (dl1.lt..001.or.dl1.gt.40.) dl1=ddl1                               4511
      write (ioa,3940) sk,sr1,swi,dl0,dl1                                   4512
      go to 3180                                                            4513
c                                                                           4514
c TE -- temporary errors for DC ---                                         4515
c                                                                           4516
  900 isig0=isig                                                            4517
      write (ioa,3510)                                                      4518
      read (in,4440,end=3170) aw                                            4519
      isig=1                                                                4520
      if (.not.law(aw)) isig=2                                              4521
      ldst=0                                                                4522
      if (isig.eq.1) go to 3180                                             4523
      write (ioa,3520) csig,rsig,asig,csig0,rsig0,asig0                     4524
      call les (in)                                                         4525
      if (n.eq.0) isig=isig0                                                4526
      if (n.eq.0) go to 3170                                                4527
      if (c(1).gt.0..or.c(2).gt.0..or.c(3).gt.0.) go to 910                 4528
      if (c(1).ge.0.) go to 920                                             4529
      csig=csig0                                                            4530
      rsig=rsig0                                                            4531
      asig=asig0                                                            4532
      go to 920                                                             4533
  910 if (c(1).ge..0001.and.c(1).le..9) csig=c(1)                           4534
      if (c(2).ge..0001.and.c(2).le..9) rsig=c(2)                           4535
      if (c(3).ge..001.and.c(2).le.46.) asig=c(3)                           4536
  920 write (ioa,3530) csig,rsig,asig                                       4537
      go to 3180                                                            4538
c                                                                           4539
c DS -- replace sigmas by default sigmas --                                 4540
c                                                                           4541
  930 write (ioa,3860)                                                      4542
      read (in,4440,end=3170) aw                                            4543
      if (law(aw)) go to 3170                                               4544
      dwi=swi                                                               4545
      dr1=sr1*r1                                                            4546
      dr2=sr1*r2                                                            4547
      dr3=sr1*r3                                                            4548
      dr4=sr1*r4                                                            4549
      dak=sk*ak                                                             4550
      call resto (isr,ihv)                                                  4551
cio   iooo=1                                                                4552
cio   iooi=10                                                               4553
cio   write (6,*) iooo,ioa,iun,io,iooi                                      4554
      call edit (ioa,1,10)                                                  4555
      ix=1                                                                  4556
      go to 3180                                                            4557
c                                                                           4558
c NR -- max. number of solutions --                                         4559
c                                                                           4560
  940 write (ioa,4490) ibe,nwm                                              4561
      call les (in)                                                         4562
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               4563
      iskip=0                                                               4564
      if (c(1).lt.0.) iskip=1                                               4565
      nbb=abs(c(1))                                                         4566
      if (nbb.eq.0) nbb=nwm                                                 4567
      nbb=min0(nbb,ibe)                                                     4568
      write (ioa,4500) nbb                                                  4569
      if (ine.eq.1) go to 3180                                              4570
      if (nbb.gt.m) ine=1                                                   4571
      m0=min0(m,nbb)                                                        4572
      go to 3180                                                            4573
c                                                                           4574
c I  ------- index a pattern ------                                         4575
c                                                                           4576
  950 if (ix.eq.2) go to 970                                                4577
      if (r1.eq.0..or.r2.eq.0.) go to 3160                                  4578
      if (ine.eq.0) go to 1040                                              4579
  960 ix=2                                                                  4580
      call prep1                                                            4581
  970 if (ine.eq.0) go to 1040                                              4582
      if (mbr(ke,ila).eq.0) go to 980                                       4583
      tex(1)='    '                                                         4584
      if (ig.ne.in) tex(1)=ta1                                              4585
      write (ioa,4980) ta1,text(1),text(2),jsm(ila),isys(ke+1),j9(62)       4586
c      if (isf.eq.2.and.iun.ne.8)                                           4587
c     1 write (iun,4950) ta1,text(1),text(2),jsm(ila),isys(ke+1),j9(62)     4588
      if (jfw.ne.0) write (88,4980) ta1,text(1),text(2),jsm(ila),           4589
     1isys(ke+1),j9(62)                                                     4590
c                                                                           4591
      ine=1                                                                 4592
      if (iy.eq.2) go to 160                                                4593
      iy=0                                                                  4594
      isf=1                                                                 4595
      ig=in                                                                 4596
      go to 1200                                                            4597
c                                                                           4598
  980 if (iy.eq.2.and.ibr.ne.51) go to 1020                                 4599
      if ((lq.eq.1.and.iv.eq.1).or.l7.eq.2) go to 990                       4600
      write (ioa,4870) j9(42),r0m,j9(36),j9(46)                             4601
      lq=1                                                                  4602
      iv=1                                                                  4603
  990 if (iv.eq.1) go to 1020                                               4604
      go to (1000,1010),j4                                                  4605
c                                                                           4606
 1000 if (v3.gt.vca*vd.or.v3.lt.vca/vd) go to (1160,160,160),iy+1           4607
      go to 1020                                                            4608
c                                                                           4609
 1010 if (v3.gt.vca*vd) go to (1160,160,160),iy+1                           4610
 1020 m=0                                                                   4611
c                                                                           4612
c  find hkl(d)                                                              4613
c                                                                           4614
      call indi (dg,cr,nda,idi,j)                                           4615
      if (j.eq.1) go to 1170                                                4616
      if (ii.eq.0.or.jj.eq.0) go to (1160,160,160),iy+1                     4617
c                                                                           4618
c evaluate and store indexing, start                                        4619
c                                                                           4620
      call eva (cd,ild,ibr,iun,isr,isr0,ieo,nls,m,i4,nda,il1,flim)          4621
      if (ieo.eq.1) go to 550                                               4622
c                                                                           4623
c evaluate and store indexing - end                                         4624
c                                                                           4625
      m0=m                                                                  4626
      if (isr.eq.0) go to 1040                                              4627
      if (m.gt.0) go to 1040                                                4628
 1030 isr0=0                                                                4629
      go to 160                                                             4630
c                                                                           4631
 1040 if (m.eq.0) go to (1160,160,160),iy+1                                 4632
c                                                                           4633
c no solution                                                               4634
c                                                                           4635
      if (ild.eq.1) go to 1100                                              4636
      iwi=0                                                                 4637
      if (wi.lt..11) iwi=1                                                  4638
c                                                                           4639
cioioio!!!                                                                  4640
      if (iun.eq.8) go to 1050                                              4641
c                                                                           4642
      if (iy.gt.0.and.ibr.ne.54) write (iun,4570) ta1,text                  4643
      if (iy.gt.0.and.ibr.ne.54) write (iun,4420) dg(1),dg(2),dg(3),dgw,    4644
     1jsm(ila),v0,isys(ke+1),rg(1),rg(2),rg(3),rgw,jsm(ila),rs              4645
      if (m0.lt.nda) write (iun,4590) m0,nda                                4646
      if (m0.ge.nda) write (iun,3600) nda                                   4647
c                                                                           4648
 1050 iooo=2                                                                4649
c     write (6,*) iooo,ioa,iun,io,ibr,ine                                   4650
      if (itst(1).ne.1.and.iun.eq.io.and.iy.eq.0) call edit (iun,1,ibr)     4651
      if ((lq.eq.2.or.iv.eq.2).and.iun.eq.io) write (iun,4880) p9(j4),      4652
     1rl1,p7(lq),p7(iv),vj                                                  4653
      if (iun.ne.io.and.iy.ne.2) write (io,4590) m0,nda                     4654
      if (iun.ne.io.and.iy.ne.2) write (io,3600) nda                        4655
      if (iy.eq.2.and.isr0.lt.2) write (io,4570) ta1,(text(i),i=1,16)       4656
      if (iy.eq.2.and.isr0.lt.2) write (io,3950) dg(1),dg(2),dg(3),dgw,     4657
     1jsm(ila),rs,jsm(ila),v0                                               4658
      if (iun.ne.io.and.iy.ne.2.and.io.ne.ioa) write (ioa,4590) m0,nda      4659
      if (iun.ne.io.and.iy.ne.2.and.io.ne.ioa) write (ioa,3600) nda         4660
      if (iy.eq.2.and.isr0.lt.2.and.io.ne.ioa) write (ioa,4570) ta1,        4661
     1(text(i),i=1,16)                                                      4662
      if (iy.eq.2.and.isr0.lt.2.and.io.ne.ioa) write (ioa,3950) dg(1),      4663
     1dg(2),dg(3),dgw,jsm(ila),rs,jsm(ila),v0                               4664
cioioio!!!                                                                  4665
      if (iun.eq.8) go to 1060                                              4666
      if (np.eq.1) write (iun,4950) r0,ihv                                  4667
      if (np.eq.2) write (iun,3890)                                         4668
c                                                                           4669
 1060 s3=p6(np)                                                             4670
      if (iwi.eq.1.and.np.eq.2) s3='2 th'                                   4671
cjfw                                                                        4672
      if (iun.eq.8) go to 1070                                              4673
      write (6,3870) s1(np),s1(np),s3,s4(np)                                4674
      if (jfw.ne.0) write (88,3870) s1(np),s1(np),s3,s4(np)                 4675
c                                                                           4676
 1070 c(1)=r1                                                               4677
      c(2)=r2                                                               4678
      c(3)=rl1                                                              4679
      c(4)=ak                                                               4680
      if (np.eq.1) go to 1080                                               4681
      c(1)=ak/r1                                                            4682
      c(2)=ak/r2                                                            4683
      c(4)=ak/ala                                                           4684
      if (rl1.ne.0.) c(3)=vca*sin(wi*fak)/(c(1)*c(2))                       4685
c                                                                           4686
cjfw                                                                        4687
c 1060 if (iun.ne.8) write (iun,3850) c(1),c(2),wi,c(3),c(4),s4(np)         4688
 1080 if (iun.eq.8) go to 1090                                              4689
      write (6,3880) c(1),c(2),wi,c(3),c(4),s4(np)                          4690
      if (jfw.ne.0) write (88,3880) c(1),c(2),wi,c(3),c(4),s4(np)           4691
 1090 nli=4                                                                 4692
 1100 if (ine.eq.1) go to 1120                                              4693
c                                                                           4694
      do 1110 i=1,m                                                         4695
 1110   ac(i)=ac(i)/1.e11-1.                                                4696
c                                                                           4697
c  sorted output                                                            4698
c                                                                           4699
 1120 call outp (i7,jz,m,sfom,ild,ieo,iwr,i4,i5,iwi,iun,nli,iza,ns,m0,      4700
     1isr0,ibr,nexc)                                                        4701
c                                                                           4702
      if (ieo.eq.1) go to 3180                                              4703
c                                                                           4704
 1130 if (iun.eq.io) go to 1150                                             4705
cioioio!!!                                                                  4706
c      if (ild.eq.0) write (iun,4650)                                       4707
c                                                                           4708
      if (ibr.eq.54.and.isr0.lt.isr) go to 550                              4709
      nls=0                                                                 4710
      if (iy.ne.2) go to 1150                                               4711
c!                                                                          4712
      if (isr0.ne.isr.or.ibr.ne.54) go to 160                               4713
c!                                                                          4714
      sfom=sfom/float(isr)                                                  4715
cjfw                                                                        4716
      if (ild.eq.0) write (6,3910) sfom                                     4717
      if (ild.eq.0.and.jfw.ne.0) write (88,3910) sfom                       4718
      if (ild.eq.0) go to (160,1140,1140),istp1+1                           4719
c                                                                           4720
      nall=nall+1                                                           4721
      call del1 (dg,dgw,v0,dgd,dgdw)                                        4722
      call ck (ngkk,sfom,ssfom,swt,ie,ddifw,ddazb,nsub,ddx,ddy,ddz,sfmx,    4723
     1fkk)                                                                  4724
      if (ie.ne.0.or.istp1.ne.1) go to 2360                                 4725
cjfw                                                                        4726
      if (ngkk.eq.1) write (6,3680)                                         4727
      if (ngkk.eq.1.and.jfw.ne.0) write (88,3680)                           4728
c     write (io,498) sfom,dg(1),dg(2),dg(3),dgw,x1,x2,x3,v0                 4729
c     if (io.ne.ioa) write (ioa,498) sfom,dg(1),dg(2),dg(3),dgw,x1,x2,      4730
c    1x3,v0                                                                 4731
cjfw   write (io,5050) sfom,dg(1),dg(2),dg(3),dgw,x1,x2,v0                  4732
c      if (io.ne.ioa) write (ioa,5050) sfom,dg(1),dg(2),dg(3),dgw,x1,x2,    4733
c     1v0                                                                   4734
      write (6,5080) sfom,dg(1),dg(2),dg(3),dgw,x1,x2,v0                    4735
      if (jfw.ne.0) write (88,5080) sfom,dg(1),dg(2),dg(3),dgw,x1,x2,v0     4736
 1140 write (ioa,3930)                                                      4737
      read (in,4440,end=3180) aw                                            4738
      if (law(aw)) go to (3180,2400),ild+1                                  4739
      go to 160                                                             4740
c                                                                           4741
 1150 ine=0                                                                 4742
      ig=in                                                                 4743
      if (nexc.gt.0) write (ioa,5100) nexc                                  4744
      if (nexc.gt.0.and.io.ne.ioa) write (io,5100) nexc                     4745
      go to 3180                                                            4746
cjfw                                                                        4747
 1160 if (ild.eq.0) write (6,4600)                                          4748
      if (ild.eq.0.and.jfw.ne.0) write (88,4600)                            4749
      if ((lq.eq.2.or.iv.eq.2).and.ild.eq.0) write (6,4880) p9(j4),rl1,     4750
     1p7(lq),p7(iv),vj                                                      4751
      if ((lq.eq.2.or.iv.eq.2).and.ild.eq.0.and.jfw.ne.0) write (88,        4752
     14880) p9(j4),rl1,p7(lq),p7(iv),vj                                     4753
      go to 1130                                                            4754
cjfw                                                                        4755
 1170 write (6,4610)                                                        4756
      if (jfw.ne.0) write (88,4610)                                         4757
      if (iy.lt.2) go to 1180                                               4758
      if (ild.eq.1) go to 160                                               4759
      if (iy.eq.2.and.isr0.lt.2) write (6,4580) ta1,(text(i),i=1,16)        4760
      if (iy.eq.2.and.isr0.lt.2) write (6,3950) dg(1),dg(2),dg(3),dgw,      4761
     1jsm(ila),rs,jsm(ila),v0                                               4762
      if (iy.eq.2.and.isr0.lt.2.and.jfw.ne.0) write (88,4580) ta1,          4763
     1(text(i),i=1,16)                                                      4764
      if (iy.eq.2.and.isr0.lt.2.and.jfw.ne.0) write (88,3950) dg(1),        4765
     1dg(2),dg(3),dgw,jsm(ila),rs,jsm(ila),v0                               4766
      write (6,4580) ta1,(text(i),i=1,16)                                   4767
      write (6,4420) (dg(i),i=1,3),dgw,jsm(ila),v0,isys(ke+1),(rg(i),i=     4768
     11,3),rgw,jsm(ila),rs                                                  4769
      if (jfw.ne.0) write (88,4580) ta1,(text(i),i=1,16)                    4770
      if (jfw.ne.0) write (6,4420) (dg(i),i=1,3),dgw,jsm(ila),v0,           4771
     1isys(ke+1),(rg(i),i=1,3),rgw,jsm(ila),rs                              4772
      write (6,4700)                                                        4773
      if (jfw.ne.0) write (88,4700)                                         4774
      go to 160                                                             4775
c                                                                           4776
 1180 if (r1.gt.r2) write (6,4620) j9(109),j9(10)                           4777
      if (r1.gt.r2.and.jfw.ne.0) write (88,4620) j9(109),j9(10)             4778
      go to 3180                                                            4779
c                                                                           4780
c1160 k=8                                                                   4781
 1190 k=6                                                                   4782
      iun=io                                                                4783
      call opn (k,3,n,itst(3))                                              4784
      if (n.eq.0) go to (3170,3110),ild+1                                   4785
      nu=k                                                                  4786
      if (isf.eq.1) write (ioa,4500) nu                                     4787
      if (isf.eq.2) iun=nu                                                  4788
      if (isf.eq.1) go to 3180                                              4789
      if (ibr.eq.54) go to 1670                                             4790
c                                                                           4791
c L  -- list of current data ---                                            4792
c                                                                           4793
cio 1180 iooo=3                                                             4794
cio  write (6,*) iooo,ioa,iun,io,ibr                                        4795
c1180 call edit (iun,1,ibr)                                                 4796
 1200 call edit (6,1,ibr)                                                   4797
      if (jfw.ne.0) call edit (88,1,ibr)                                    4798
      if (iy.eq.2) go to 1670                                               4799
      go to (3180,950),isf                                                  4800
c                                                                           4801
c-- A B C AL BE GA ----(cell param., separately) --                         4802
c                                                                           4803
 1210 write (ioa,4630) j85(ibr-13)                                          4804
      call les (in)                                                         4805
      if (n.eq.0.or.c(1).eq.0.) go to 3170                                  4806
      ke00=ke                                                               4807
      titel(18)='    '                                                      4808
      ta1='    '                                                            4809
      call clt (text)                                                       4810
      if (c(1).lt.0.) go to 1230                                            4811
      if (ibr.gt.16) go to 1220                                             4812
      dg(ibr-13)=c(1)                                                       4813
      go to 310                                                             4814
c                                                                           4815
 1220 dgw(ibr-16)=c(1)                                                      4816
      go to 310                                                             4817
c                                                                           4818
 1230 c(1)=-c(1)                                                            4819
      if (ibr.gt.16) go to 1240                                             4820
      rg(ibr-13)=c(1)                                                       4821
      call dire (rg,dg,dgw,fakr,v0,ier)                                     4822
      if (ier.eq.1) go to 400                                               4823
      go to 310                                                             4824
c                                                                           4825
 1240 rg(ibr-13)=cos(c(1)*fak)                                              4826
      call dire (rg,dg,dgw,fakr,v0,ier)                                     4827
      if (ier.eq.1) go to 400                                               4828
      go to 310                                                             4829
c                                                                           4830
c EC E1 E2 E3 EA ----- sigmas ---                                           4831
c                                                                           4832
 1250 d=-sr1                                                                4833
      if (iabs(ibr-27).lt.2) write (ioa,4680) j9(ibr-21),d,ssr              4834
      d=-sk                                                                 4835
      c(1)=ski                                                              4836
      if (ibr.eq.25) write (ioa,4680) j9(4),d,c(1)                          4837
      if (ibr.eq.29) write (ioa,4690) j9(8),swi                             4838
      call les (in)                                                         4839
      if (n.eq.0) go to 3170                                                4840
      ix=1                                                                  4841
      d=abs(c(1))                                                           4842
      go to (1300,1260,1270,1280,1290),ibr-24                               4843
c                                                                           4844
 1260 dr1=d                                                                 4845
      if (c(1).lt.0.) dr1=d*r1                                              4846
      go to 660                                                             4847
c                                                                           4848
 1270 dr2=d                                                                 4849
      if (c(1).lt.0.) dr2=d*r2                                              4850
      go to 700                                                             4851
c                                                                           4852
 1280 dr3=d                                                                 4853
      if (c(1).lt.0.) dr3=d*r3                                              4854
      go to 770                                                             4855
c                                                                           4856
 1290 dwi=d                                                                 4857
      go to 730                                                             4858
c                                                                           4859
 1300 dak=d                                                                 4860
      if (c(1).lt.0.) dak=d*ak                                              4861
      go to 620                                                             4862
c                                                                           4863
c PO --- parallel output on file ----                                       4864
c                                                                           4865
 1310 if (io.ne.ioa) go to 1330                                             4866
      if (if5.eq.1) go to 1320                                              4867
      write (io,3960) j9(21)                                                4868
      write (ioa,3970) file4                                                4869
      read (in,3980,end=3180) filer                                         4870
      if (filer.eq.'. '.or.filer.eq.', ') go to 3180                        4871
      if (filer.eq.'    ') filer=file4                                      4872
      ioo=88                                                                4873
      open (unit=ioo,file=filer,status='UNKNOWN')                           4874
      if5=1                                                                 4875
      ifu=1                                                                 4876
 1320 io=ioo                                                                4877
      jfw=1                                                                 4878
      go to 3180                                                            4879
 1330 write (io,4700)                                                       4880
      io=ioa                                                                4881
      ifw=0                                                                 4882
      write (io,3990)                                                       4883
      go to 3180                                                            4884
c                                                                           4885
c IR -- interchange R1, R2 ---                                              4886
c                                                                           4887
 1340 d=r1                                                                  4888
      r1=r2                                                                 4889
      r2=d                                                                  4890
      d=dr1                                                                 4891
      dr1=dr2                                                               4892
      dr2=d                                                                 4893
      ix=1                                                                  4894
      write (ioa,4640)                                                      4895
      go to 3180                                                            4896
c                                                                           4897
c RO -- rotate R1, R2, R3                                                   4898
c                                                                           4899
 1350 write (ioa,3670)                                                      4900
      read (in,4440,end=3170) aw                                            4901
      if (law(aw)) go to 3170                                               4902
      d=r1                                                                  4903
      r1=r3                                                                 4904
      r3=r2                                                                 4905
      r2=d                                                                  4906
      dr3=dr2                                                               4907
      dr2=dr1                                                               4908
      dr1=r1*(dr2+dr3)/(r3+r2)                                              4909
      ix=1                                                                  4910
      wi=fakr*arco((r1*r1+r2*r2-r3*r3)/(2.*r1*r2))                          4911
      dwi=amax1(swi,dwi)                                                    4912
cio      iooo=4                                                             4913
cio      iooi=10                                                            4914
cio      write (6,*) iooo,ioa,iun,io,iooi                                   4915
      call edit (6,1,10)                                                    4916
      if (jfw.ne.0) call edit (88,1,10)                                     4917
      go to 3180                                                            4918
c                                                                           4919
c RL --- rigid limits? ---                                                  4920
c                                                                           4921
 1360 write (ioa,4670)                                                      4922
      call les (in)                                                         4923
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               4924
      ira=min1(abs(c(1)),1.)                                                4925
      if (ira.eq.0) write (ioa,3260)                                        4926
      if (ira.ne.0) write (ioa,3270)                                        4927
      go to 3180                                                            4928
c                                                                           4929
c MU -- max. multiplicity ---                                               4930
c                                                                           4931
 1370 write (ioa,4660) j9(61),mul2                                          4932
      call les (in)                                                         4933
      if (n.eq.0.or.ndi(1).gt.mdi.or.ndi(2).gt.mdi) go to 3170              4934
      icm=c(1)                                                              4935
      if (icm.eq.0) icm=2                                                   4936
      icm=max0(icm,0)                                                       4937
      icmd=icm                                                              4938
      icmw=icm                                                              4939
      if (icmw.eq.0) icmw=999999                                            4940
      mul3=c(2)                                                             4941
      mul3=min0(2,mul3)                                                     4942
      if (mul3.le.0) mul3=mul2                                              4943
      write (ioa,4500) icmw,mul3                                            4944
      go to 3180                                                            4945
c                                                                           4946
c HV -- high voltage ----                                                   4947
c                                                                           4948
 1380 write (ioa,4840) hv0                                                  4949
      call les (in)                                                         4950
      if (n.eq.0) go to 3170                                                4951
      hv=c(1)                                                               4952
      if (hv.eq.0.) hv=hv0                                                  4953
      if (hv.lt.0.) go to 1390                                              4954
      ala=alam(hv)                                                          4955
      go to 1400                                                            4956
c                                                                           4957
 1390 ala=-hv                                                               4958
      hv=(sqrt(1.+.588648e-03/ala**2)-1.)*511012.                           4959
 1400 akl=ak/ala                                                            4960
      ihv=jhv(hv)                                                           4961
      write (ioa,4850) hv,ala,akl                                           4962
      call cvol (v,fk,ila)                                                  4963
      go to 3180                                                            4964
c                                                                           4965
c L0 -- radius Laue zone 0 ---                                              4966
c                                                                           4967
 1410 write (ioa,4860) sr0,dw0                                              4968
      call les (in)                                                         4969
      if (n.eq.0) go to 3170                                                4970
 1420 r0=c(1)                                                               4971
      l7=1                                                                  4972
      c(2)=abs(c(2))                                                        4973
      if (rl1.gt.0.) l7=2                                                   4974
      if (r0.ge.0.) go to 1430                                              4975
c                                                                           4976
      ph=-c(1)                                                              4977
      ph=amod(ph,180.)                                                      4978
      if (ph.gt.90.) ph=180.-ph                                             4979
      ph=amin1(ph,89.999)                                                   4980
      tl=ph*fak                                                             4981
      r0=akl*tan(fak*ph)                                                    4982
      if (c(2).eq.0.) c(2)=dw0                                              4983
      sr0=abs(c(2))*akl*fak/amax1(1.e-6,(cos(fak*ph))**2)                   4984
      go to 1440                                                            4985
c                                                                           4986
 1430 tl=atan(r0/akl)                                                       4987
      ph=fakr*tl                                                            4988
      sr0=c(2)                                                              4989
 1440 if (sr0.lt..0001) sr0=dl0                                             4990
      vca=0.                                                                4991
      ro=amin1(r0,999999.9)                                                 4992
      sro=amin1(sr0,999.9)                                                  4993
      if (l7.eq.1) write (ioa,4000) ro,sro,hv,ph                            4994
      if (l7.eq.1) go to 3180                                               4995
      call cvol (v,fk,ila)                                                  4996
      if (ila.eq.1) write (io,4010) ro,sro,p9(j4),rl1,su1,jsm(1),p8(j4),    4997
     1vca,hv,ph                                                             4998
      if (ila.gt.1) write (io,4020) ro,sro,p9(j4),rl1,su1,jsm(1),p8(j4),    4999
     1vca,jsm(ila),p8(j4),v,hv,ph                                           5000
      if (ila.eq.1.and.io.ne.ioa) write (ioa,4010) ro,sro,p9(j4),rl1,       5001
     1su1,jsm(1),p8(j4),vca,hv,ph                                           5002
      if (ila.gt.1.and.io.ne.ioa) write (ioa,4020) ro,sro,p9(j4),rl1,       5003
     1su1,jsm(1),p8(j4),vca,jsm(ila),p8(j4),v,hv,ph                         5004
      go to 3180                                                            5005
c                                                                           5006
c L1 -- radius Laue zone 1 (-Lz. 0) ---                                     5007
c                                                                           5008
 1450 write (ioa,4890) su1                                                  5009
      call les (in)                                                         5010
      if (n.eq.0) go to (3170,1450),iv                                      5011
      if (c(1).ge.0.) go to 1460                                            5012
      c(1)=abs(c(1))                                                        5013
      c(2)=amin1(999.999,c(2)*ak/c(1)**2)                                   5014
      c(1)=ak/c(1)                                                          5015
c                                                                           5016
 1460 r0m=c(1)                                                              5017
      rl1=r0m                                                               5018
      if (c(3).ne.0.) r0m=-r0m                                              5019
      j4=1                                                                  5020
      if (r0m.lt.0.) j4=2                                                   5021
      su1=abs(c(2))                                                         5022
      l7=2                                                                  5023
      if (rl1.le.0.1) l7=1                                                  5024
      if (r0m.ne.0..or.iv.eq.1) go to 1470                                  5025
      write (ioa,4920) j9(47)                                               5026
      read (in,4440,end=1450) aw                                            5027
      if (law(aw)) go to 1450                                               5028
      iv=1                                                                  5029
 1470 if (su1.lt..0001) su1=dl1                                             5030
      if (j4.eq.2) su1=0.                                                   5031
      if (rl1.gt..1) go to 1480                                             5032
      vca=0.                                                                5033
      write (ioa,4000) r0m,su1,hv,ph                                        5034
      go to 1490                                                            5035
 1480 call cvol (v,fk,ila)                                                  5036
      if (ila.eq.1) write (io,4010) ro,sro,p9(j4),rl1,su1,jsm(1),p8(j4),    5037
     1vca,hv,ph                                                             5038
      if (ila.gt.1) write (io,4020) ro,sro,p9(j4),rl1,su1,jsm(1),p8(j4),    5039
     1vca,jsm(ila),p8(j4),v,hv,ph                                           5040
      if (ila.eq.1.and.io.ne.ioa) write (ioa,4010) ro,sro,p9(j4),rl1,       5041
     1su1,jsm(1),p8(j4),vca,hv,ph                                           5042
      if (ila.gt.1.and.io.ne.ioa) write (ioa,4020) ro,sro,p9(j4),rl1,       5043
     1su1,jsm(1),p8(j4),vca,jsm(ila),p8(j4),v,hv,ph                         5044
 1490 s1u=amax1(0.,rl1-su1)                                                 5045
      s1o=rl1+su1                                                           5046
      if (j4.eq.2) s1o=1.e20                                                5047
      go to 3180                                                            5048
c                                                                           5049
c D1 , D0 -- sigmas for L0, L1 ---                                          5050
c                                                                           5051
 1500 write (ioa,4690) j9(ibr-2),dl1                                        5052
      call les (in)                                                         5053
      if (n.eq.0) go to 3170                                                5054
      if (ibr.eq.43) go to 1510                                             5055
      su1=abs(c(1))                                                         5056
      go to 1470                                                            5057
c                                                                           5058
 1510 sr0=abs(c(1))                                                         5059
      sro=amin1(sr0,999.9)                                                  5060
      go to 1440                                                            5061
c                                                                           5062
c LY -- Laue zone criterion: yes ---                                        5063
c                                                                           5064
 1520 write (ioa,3540) j9(45)                                               5065
c      lq=2                                                                 5066
c      lqq=2                                                                5067
c      if (l7.eq.1) go to 128                                               5068
      go to 3180                                                            5069
c                                                                           5070
c LN -- Laue zone criterion: no ----                                        5071
c                                                                           5072
 1530 write (ioa,3540) j9(36)                                               5073
c      lq=1                                                                 5074
c      lqq=1                                                                5075
      go to 3180                                                            5076
c                                                                           5077
c VY -- volume criterion: yes ---                                           5078
c                                                                           5079
 1540 write (ioa,3540) j9(47)                                               5080
c      iv=2                                                                 5081
c      ivv=2                                                                5082
c      if (l7.eq.1) go to 128                                               5083
      go to 3180                                                            5084
c                                                                           5085
c VN -- volume criterion: no ---                                            5086
c                                                                           5087
 1550 write (ioa,3540) j9(46)                                               5088
c      iv=1                                                                 5089
c      ivv=1                                                                5090
      go to 3180                                                            5091
c                                                                           5092
c EV -- sigma for volume ---                                                5093
c                                                                           5094
 1560 write (ioa,4900) vdd                                                  5095
      call les (in)                                                         5096
      if (n.eq.0) go to 3170                                                5097
      vj=abs(c(1))                                                          5098
      if (vj.lt..1) vj=vdd                                                  5099
      write (ioa,3940) vj                                                   5100
      vd=vj/100.+1.                                                         5101
      go to 3180                                                            5102
c                                                                           5103
c OR --- output radii ---                                                   5104
c                                                                           5105
 1570 np=1                                                                  5106
cio      iooo=5                                                             5107
cio      iooi=10                                                            5108
cio      write (6,*) iooo,ioa,iun,io,iooi                                   5109
      call edit (6,1,10)                                                    5110
      if (jfw.ne.0) call edit (88,1,10)                                     5111
      go to 3180                                                            5112
c                                                                           5113
c OD --- output d-values ---                                                5114
c                                                                           5115
 1580 np=2                                                                  5116
cio      iooo=6                                                             5117
cio      iooi=10                                                            5118
cio      write (6,*) iooo,ioa,iun,io,iooi                                   5119
c      call edit (io,1,10)                                                  5120
      call edit (6,1,10)                                                    5121
      if (jfw.ne.0) call edit (88,1,10)                                     5122
      go to 3180                                                            5123
c                                                                           5124
c RW --- rewind cell parameter file ---                                     5125
c                                                                           5126
 1590 if (ig1.eq.in) write (ioa,4970) j9(12)                                5127
      if (ig1.eq.in) go to 3170                                             5128
      rewind ig1                                                            5129
      write (ioa,4810) ig1,fdd                                              5130
      go to 3180                                                            5131
c                                                                           5132
c  RN , RY -- automatic rewind: n/y ---                                     5133
c                                                                           5134
 1600 irw=ibr-56                                                            5135
      if (irw.eq.2) write (ioa,3280)                                        5136
      if (irw.eq.1) write (ioa,3290)                                        5137
      if (irw.eq.2.and.jfw.ne.0) write (88,3280)                            5138
      if (irw.eq.1.and.jfw.ne.0) write (88,3290)                            5139
      go to 3180                                                            5140
c                                                                           5141
c  LW  -- write cell parameter file --                                      5142
c                                                                           5143
 1610 if (ig1.eq.in) write (ioa,4970) j9(12)                                5144
      if (ig1.eq.in.and.jfw.ne.0) write (88,4970) j9(12)                    5145
      if (ig1.eq.in) go to 3170                                             5146
      ig=ig1                                                                5147
      write (ioa,4030) p7(irw)                                              5148
      if (jfw.ne.0) write (88,4030) p7(irw)                                 5149
      call les (in)                                                         5150
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5151
      i=c(1)                                                                5152
      nli=1                                                                 5153
      if (irw.eq.2) rewind ig                                               5154
 1620 read (ig,4350,end=1660) tid                                           5155
      if (tid(1).eq.'END$') go to 1660                                      5156
      write (ioa,4570) tid                                                  5157
      if (jfw.ne.0) write (88,4570) tid                                     5158
      nli=nli+1                                                             5159
      read (ig,4350,end=1640) tid                                           5160
      if (i.le.0) write (ioa,4040) tid                                      5161
      if (i.le.0.and.jfw.ne.0) write (88,4040) tid                          5162
      read (ig,4350,end=1640) tid                                           5163
      if (i.le.0) write (ioa,4040) tid                                      5164
      if (i.le.0.and.jfw.ne.0) write (ioa,4040) tid                         5165
      if (i.le.0) nli=nli+2                                                 5166
      if (nli.lt.limax) go to 1620                                          5167
      write (ioa,3930)                                                      5168
      read (in,4440,end=1630) aw                                            5169
      if (.not.law(aw)) go to 1650                                          5170
 1630 if (irw.eq.2) go to 1640                                              5171
      write (ioa,4050) ig                                                   5172
      go to 3180                                                            5173
 1640 write (ioa,4810) ig,fdd                                               5174
      rewind ig                                                             5175
      go to 3180                                                            5176
 1650 nli=1                                                                 5177
      go to 1620                                                            5178
 1660 if (ig.eq.1) fdd=fsc                                                  5179
      write (ioa,4380) ig,fdd                                               5180
      rewind ig                                                             5181
      go to 3180                                                            5182
c                                                                           5183
c SC --- scan through cell param. file ---                                  5184
c                                                                           5185
 1670 if (ild.eq.1) go to 1680                                              5186
      if (ig1.eq.in) write (ioa,4970) j9(12)                                5187
      if (ig1.eq.in) go to 3170                                             5188
      ig=ig1                                                                5189
      if (iy.lt.2) iy=1                                                     5190
      if (iy.eq.2.and.irw.eq.2) rewind ig                                   5191
 1680 if (isr.gt.0) go to 1030                                              5192
      go to 160                                                             5193
c                                                                           5194
c SF , S1 -- save indexing on file; scan, 1 pattern ---                     5195
c                                                                           5196
 1690 if (ig1.eq.in) go to 1590                                             5197
      write (ioa,4990)                                                      5198
      call les (in)                                                         5199
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5200
      nru=abs(c(1))                                                         5201
      isr0=0                                                                5202
      iy=2                                                                  5203
 1700 isf=2                                                                 5204
      ibeg=0                                                                5205
      if (nu.eq.0) go to 1190                                               5206
      iun=nu                                                                5207
      if (isr.gt.0) go to 1670                                              5208
      go to 1200                                                            5209
c                                                                           5210
c SA - scan through data base, indexibility of mem. A                       5211
c                                                                           5212
 1710 if (ig1.eq.in) go to 1590                                             5213
      call cksg (io,ioa,in,sv,vmin,vmax,iii,0,ilim,0,iall)                  5214
      if (iii.gt.0) go to 1720                                              5215
      write (ioa,4780)                                                      5216
      go to 3170                                                            5217
 1720 vmaxp=0.                                                              5218
      vminp=0.                                                              5219
      if (vmax.lt..1.or.vmax.eq.vmin) go to 1730                            5220
      dvr=amax1(sv-vmin,vmax-sv)+.05*sv                                     5221
      vminp=amax1(sv-dvr,5.)                                                5222
      vmaxp=sv+dvr                                                          5223
 1730 vmn=5.                                                                5224
      call vlim (in,io,ioa,vmin,vmax,vminp,vmaxp,vmi,vma,sv,ie)             5225
      if (n.eq.0) go to 3170                                                5226
      if (ie.eq.1) go to 1730                                               5227
c                                                                           5228
c                                                                           5229
      i=max0(istp,1)+1                                                      5230
cioioio                                                                     5231
      write (6,4060) j9(64),j9(23),j9(59),j9(57),j9(58),j9(24),tstp(i),     5232
     1istp,icm,tout(iop+1),iop,p7(irw),ira,vmi,vma                          5233
      if (jfw.ne.0) write (88,4060) j9(64),j9(23),j9(59),j9(57),j9(58),     5234
     1j9(24),tstp(i),istp,icm,tout(iop+1),iop,p7(irw),ira,vmi,vma           5235
c                                                                           5236
      write (ioa,5040)                                                      5237
cioioio 5010 format (1x,' # of solutions to be echoed? (def.: 0)')          5238
      call les (in)                                                         5239
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5240
c                                                                           5241
      nru=max1(c(1),0.)                                                     5242
      if (c(1).eq.0..and.ild.eq.1) nru=9                                    5243
c                                                                           5244
 1740 isr0=0                                                                5245
      isr=iii                                                               5246
      if (ild.eq.1) go to 1750                                              5247
      if (ig1.eq.in) write (ioa,4970) j9(12)                                5248
      if (ig1.eq.in) go to 3170                                             5249
      ig=ig1                                                                5250
      if (irw.eq.2) rewind ig                                               5251
 1750 ibeg=1                                                                5252
      iy=2                                                                  5253
      if (istp1.gt.0.and.nru.eq.0.and.ild.eq.1) nru=9                       5254
      ns=ind(1)                                                             5255
      call htoa (ns)                                                        5256
      ix=2                                                                  5257
      go to 1890                                                            5258
c                                                                           5259
c LG -- get l.c. from file ---                                              5260
c                                                                           5261
 1760 if (ig1.eq.in) go to 90                                               5262
      go to 110                                                             5263
c                                                                           5264
c PP , PG , PW -- put, get, write SAD pattern ----                          5265
c                                                                           5266
 1770 nrr=iru                                                               5267
      go to 1790                                                            5268
 1780 if (nnn.gt.0) go to (1840,1860,1900),ibr-32                           5269
      write (ioa,4800) iru,iro                                              5270
      call les (in)                                                         5271
      if (n.eq.0.or.ndi(1).gt.mdi) go to (570,3170),l+1                     5272
      nrr=c(1)                                                              5273
      if (nrr.lt.iru.or.nrr.gt.iro) go to 1780                              5274
 1790 call opn (nrr,2,n,itst(3))                                            5275
      if (itst(3).gt.0) go to 1820                                          5276
      if (n.eq.0) go to 1780                                                5277
      write (ioa,4790) nrr                                                  5278
      read (in,4440,end=1800) aw                                            5279
      if (.not.law(aw)) go to 1820                                          5280
 1800 if (ibr.eq.33) go to 1810                                             5281
      write (ioa,4780)                                                      5282
      go to (570,3180),l+1                                                  5283
c                                                                           5284
 1810 nnn=nnn+1                                                             5285
      write (nrr,5140) nnn,(titel(i),i=1,13)                                5286
      an9=an1                                                               5287
      be9=an2                                                               5288
      if (an0.eq.2.) an9=an9-al0                                            5289
      if (an0.eq.1.) be9=be9-be0                                            5290
      write (nrr,4770) ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,an9,be9,an0,      5291
     1r0,sr0,r0m,su1,hv                                                     5292
      ipos=nnn+1                                                            5293
      ivr=1                                                                 5294
      write (ioa,4070)                                                      5295
      go to 3180                                                            5296
c                                                                           5297
c determine number of data sets                                             5298
c                                                                           5299
 1820 read (nrr,4350,end=1830) tex(1)                                       5300
      if (tex(1).eq.'END$') go to 1830                                      5301
      nnn=nnn+1                                                             5302
      go to 1820                                                            5303
c                                                                           5304
 1830 nnn=nnn/nz                                                            5305
      write (ioa,4080) nrr,file2,nnn                                        5306
      if (itst(3).gt.0) write (ioa,4090)                                    5307
      rewind nrr                                                            5308
      ipos=1                                                                5309
      if (itst(3).le.0) go to 1780                                          5310
      ipos=1                                                                5311
      c(1)=1                                                                5312
      go to 1870                                                            5313
c                                                                           5314
c PS --- save pattern ---                                                   5315
c                                                                           5316
 1840 write (ioa,4100) titel(1)                                             5317
      read (in,4440,end=3170) aw                                            5318
      if (law(aw)) go to 3170                                               5319
      n3=(nnn-ipos+1)*nz                                                    5320
      if (n3.eq.0) go to 1810                                               5321
c                                                                           5322
      do 1850 i=1,n3                                                        5323
 1850   read (nrr,4350) tex(1)                                              5324
c                                                                           5325
      go to 1810                                                            5326
c                                                                           5327
c PG -- get pattern ---                                                     5328
c                                                                           5329
 1860 write (ioa,4760) ipos                                                 5330
      call les (in)                                                         5331
      if (n.eq.0.and.ak.eq.0.) go to 570                                    5332
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5333
 1870 n3=c(1)                                                               5334
      if (n3.le.0) n3=ipos                                                  5335
      if (n3.le.nnn) go to 1880                                             5336
      write (ioa,4750) nnn                                                  5337
      if (itst(3).gt.0) stop                                                5338
      if (l) 570,570,3180                                                   5339
 1880 call pos (n3,ipos,nrr,nz)                                             5340
      read (nrr,4350) ta,titel                                              5341
      read (nrr,4770) ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,an1,an2,an0,r0,    5342
     1sr0,r0m,su1,hv                                                        5343
      if (ak.eq.0.) go to 3160                                              5344
      if (an0.eq.2.) an1=an1+al0                                            5345
      if (an0.eq.1.) an2=an2+be0                                            5346
c                                                                           5347
      call resto (isr,ihv)                                                  5348
      akl=ak/ala                                                            5349
      vca=0.                                                                5350
c                                                                           5351
      call cvol (v,fk,ila)                                                  5352
c                                                                           5353
      call prep1                                                            5354
 1890 if (ibr.eq.52) go to 3180                                             5355
      if (ibeg.eq.1) go to 1700                                             5356
c      iooo=7                                                               5357
c      write(6,*) iooo,ioa,iun,io,ibr                                       5358
      if (nls.eq.1.and.ild.eq.0) call edit (iun,1,ibr)                      5359
      if (isr.gt.0) go to 950                                               5360
      ipos=n3+1                                                             5361
      if (dwi.gt.0.) go to 710                                              5362
      go to 820                                                             5363
c                                                                           5364
c PW  -- list SAD file ---                                                  5365
c                                                                           5366
 1900 ipos6=min0(nnn,ipos+6)                                                5367
      write (ioa,4740) ipos,ipos6                                           5368
      call les (in)                                                         5369
      if (n.eq.0.or.ndi(1).gt.mdi.or.ndi(2).gt.mdi) go to 3170              5370
      if (c(1).ne.0.) go to 1910                                            5371
      if (ipos.gt.nnn) write (ioa,4750) nnn                                 5372
      if (ipos.gt.nnn) go to 1900                                           5373
      n3=ipos                                                               5374
      n31=ipos6                                                             5375
      go to 1920                                                            5376
c                                                                           5377
 1910 n3=amax1(1.,abs(c(1)))                                                5378
      n31=c(2)                                                              5379
      if (n31.lt.0) n31=n3-n31-1                                            5380
      if (n31.lt.n3) n31=n3                                                 5381
      if (n31.gt.nnn) n31=nnn                                               5382
      if (n3.gt.nnn) n3=nnn                                                 5383
 1920 call pos (n3,ipos,nrr,nz)                                             5384
c                                                                           5385
      nli=1                                                                 5386
      do 1940 i=n3,n31                                                      5387
        read (nrr,4350) ta,tex                                              5388
        read (nrr,4770) g,(c(j),j=4,7)                                      5389
        if (c(1).le.0.) write (io,3890)                                     5390
        if (c(1).le.0.) nli=nli+1                                           5391
        zzz='  '                                                            5392
        if (g(13).eq.1.) zzz=' d'                                           5393
        if (g(13).eq.2.) zzz=' r'                                           5394
        write (io,4720) zzz,i,(tex(k),k=1,15)                               5395
        nli=nli+1                                                           5396
        if (io.ne.ioa) write (ioa,4720) zzz,i,(tex(k),k=1,15)               5397
        iki=i                                                               5398
        if (c(1).gt.0.) go to 1930                                          5399
        write (io,4910) (g(j),j=1,10),g(14),(c(j),j=4,7),g(13),g(11),       5400
     1   g(12)                                                              5401
        if (io.ne.ioa) write (ioa,4910) (g(j),j=1,10),g(14),(c(j),j=4,7)    5402
     1   ,g(13),g(11),g(12)                                                 5403
        nli=nli+2                                                           5404
 1930   if (nli.lt.limax-3) go to 1940                                      5405
        write (ioa,3930)                                                    5406
        read (in,4440,end=1950) aw                                          5407
        if (law(aw)) go to 1950                                             5408
        nli=1                                                               5409
 1940 continue                                                              5410
c                                                                           5411
 1950 ipos=iki+1                                                            5412
      go to 3180                                                            5413
c                                                                           5414
c AW -- list A-mem. ---                                                     5415
c                                                                           5416
 1960 if (nra.le.0) go to 2010                                              5417
      nnex=0.                                                               5418
      do 1970 i=1,nx                                                        5419
        if (rf(40,i).eq.0.) go to 1970                                      5420
        nnex=nnex+1                                                         5421
        nex(nnex)=i                                                         5422
 1970   ifree(i)=0                                                          5423
      nfree=0                                                               5424
      do 2000 i=1,nx                                                        5425
        if (rf(1,i).ne.0.) go to 1980                                       5426
        nfree=nfree+1                                                       5427
        ifree(nfree)=i                                                      5428
        go to 1990                                                          5429
 1980   kgg=' '                                                             5430
        if (rf(40,i).ne.0.) kgg='e'                                         5431
        write (ioa,4730) i,kgg,(tit(j,i),j=1,15)                            5432
        if (io.ne.ioa.and.ibr.eq.55) write (io,4710) i,(tit(j,i),j=1,15)    5433
        write (io,4910) (rf(j,i),j=1,10),rf(17,i),(rf(j,i),j=12,15),        5434
     1   (rf(j,i),j=22,25)                                                  5435
        if (io.ne.ioa) write (ioa,4910) (rf(j,i),j=1,10),rf(17,i),(rf(j,    5436
     1   i),j=12,15),(rf(j,i),j=22,25)                                      5437
        nli=nli+4                                                           5438
 1990   if (nli.lt.limax-1) go to 2000                                      5439
        write (ioa,3930)                                                    5440
        read (in,4440,end=3180) aw                                          5441
        if (law(aw)) go to 3180                                             5442
        nli=1                                                               5443
 2000 continue                                                              5444
      if (nfree.gt.0) write (ioa,3580) (ifree(i),i=1,nfree)                 5445
      if (nnex.gt.0) write (ioa,5070) (nex(i),i=1,nnex)                     5446
      go to 3180                                                            5447
c                                                                           5448
c AD -- deletes from A-mem. ---                                             5449
c                                                                           5450
 2010 if (nra.gt.0) go to 2020                                              5451
      write (ioa,4780)                                                      5452
      go to 3180                                                            5453
 2020 write (ioa,3700)                                                      5454
      do 2030 i=1,nx                                                        5455
        if (rf(1,i).eq.0.) go to 2030                                       5456
        kgg=' '                                                             5457
        if (rf(40,i).ne.0.) kgg='e'                                         5458
        dx1=rf(1,i)/rf(3,i)                                                 5459
        dx2=rf(1,i)/rf(5,i)                                                 5460
        dx3=rf(1,i)/rf(7,i)                                                 5461
        write (ioa,3690) i,kgg,(tit(j,i),j=1,3),rf(1,i),rf(3,i),rf(5,i),    5462
     1   rf(9,i),dx1,dx2,dx3                                                5463
 2030 continue                                                              5464
c                                                                           5465
      write (ioa,5020)                                                      5466
      call les (in)                                                         5467
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5468
      n=c(1)                                                                5469
      if (n.gt.nx) go to 3170                                               5470
      if (n) 2040,3170,2050                                                 5471
 2040 write (6,3240)                                                        5472
      read (in,4440,end=3170) aw                                            5473
      if (law(aw)) go to 3170                                               5474
 2050 ldst=0                                                                5475
      i=max0(n,1)                                                           5476
      if (n.lt.0) n=nx                                                      5477
      if (rf(1,i).gt.0.) nra=nra-1                                          5478
c                                                                           5479
      do 2060 j=i,n                                                         5480
        if (rf(40,j).ne.0.) nnex=nnex-1                                     5481
        rf(40,j)=0.                                                         5482
 2060   rf(1,j)=0.                                                          5483
      if (c(1).lt.0.) nra=0                                                 5484
      go to 3180                                                            5485
c                                                                           5486
c AP , AG --- put, get A-mem. data ---                                      5487
c                                                                           5488
 2070 nxg=0                                                                 5489
c                                                                           5490
      do 2080 i=1,nx                                                        5491
        if (rf(1,i).le.0.) go to 2080                                       5492
        nxg=nxg+1                                                           5493
        nq(nxg)=i                                                           5494
 2080 continue                                                              5495
c                                                                           5496
      if (nxg.gt.0) go to 2090                                              5497
      write (ioa,4780)                                                      5498
      go to 3180                                                            5499
 2090 if (ibr.eq.52) write (ioa,5050) (nq(i),i=1,nxg)                       5500
      nfree=0                                                               5501
      do 2100 i=1,nx                                                        5502
        if (rf(1,i).gt.0.) go to 2100                                       5503
        nfree=nfree+1                                                       5504
        ifree(nfree)=i                                                      5505
 2100 continue                                                              5506
      if (ibr.eq.53.and.nfree.gt.0) write (ioa,3580) (ifree(i),i=1,         5507
     1nfree)                                                                5508
      if (ibr.eq.53.and.nfree.eq.0) write (ioa,5060) nx                     5509
      write (ioa,3590)                                                      5510
      call les (in)                                                         5511
      if (n.eq.0) go to 3170                                                5512
      if (c(1).le.0..or.c(1).gt.float(nx).or.ndi(1).gt.mdi) go to 3170      5513
      nxx=c(1)                                                              5514
      if (ibr.eq.52) go to 2120                                             5515
c                                                                           5516
c AP --- put data to A-mem. ---                                             5517
c                                                                           5518
      call uni (r1,r2,wi,r1n,r2n,win,r3n,fak,ier)                           5519
      do 2110 i=1,nx                                                        5520
        if (rf(1,i).eq.0..or.i.eq.nxx) go to 2110                           5521
        call uni (rf(3,i),rf(5,i),rf(9,i),r1m,r2m,wim,r3m,fak,ier1)         5522
        d=ak/rf(1,i)                                                        5523
        if (abs(1.-d*r1m/r1n).gt.2.*dr1/r1.or.abs(1.-d*r2m/r2n).gt.2.*      5524
     1   dr2/r2.or.abs(wim-win).gt.2.*dwi) go to 2110                       5525
        ier2=3*ier+ier1                                                     5526
        c(1)=ak/r1n                                                         5527
        c(2)=ak/r2n                                                         5528
        c(3)=rf(1,i)/r1m                                                    5529
        c(4)=rf(1,i)/r2m                                                    5530
        c(5)=win-wim                                                        5531
        c(6)=100.*(1.-r1n*r2m/(r1m*r2n))                                    5532
        c(7)=100.*(1.-d*(r1m+r2m)/(r1n+r2n))                                5533
        d=viw*abs(c(5))+viv*abs(c(6))+vik*abs(c(7))                         5534
        write (ioa,3710) i                                                  5535
        if (ier.eq.1.or.ier1.eq.1) write (ioa,3720)                         5536
        if (ier2.eq.2.or.ier2.eq.6.or.ier2.eq.8) write (ioa,3730)           5537
        write (ioa,3740) c(1),c(2),win,i,c(3),c(4),wim,d                    5538
        write (ioa,3750)                                                    5539
        read (in,4440,end=2110) aw                                          5540
        if (.not.law(aw)) go to 3170                                        5541
 2110 continue                                                              5542
      if (rf(1,nxx).eq.0.) nra=nra+1                                        5543
      call prep1                                                            5544
      call atoh (nxx)                                                       5545
      ldst=0                                                                5546
      ibr=133                                                               5547
      go to 2800                                                            5548
c                                                                           5549
c AG --- get A-mem. data ---                                                5550
c                                                                           5551
 2120 if (rf(1,nxx).le.0.) go to 2140                                       5552
      call htoa (nxx)                                                       5553
      ix=2                                                                  5554
      ihv=jhv(hv)                                                           5555
      lq=lqq                                                                5556
      iv=ivv                                                                5557
      if (isr.eq.0.or.r0m.ne.0) go to 2130                                  5558
      lq=1                                                                  5559
      iv=1                                                                  5560
cio 2110 iooo=8                                                             5561
cio      iooi=10                                                            5562
cio      write (6,*) iooo,ioa,iun,io,iooi                                   5563
cio      call edit (io,1,10)                                                5564
cio 2110 call edit (io,1,10)                                                5565
 2130 call edit (6,1,10)                                                    5566
      if (jfw.ne.0) call edit (88,1,10)                                     5567
      go to 1890                                                            5568
c                                                                           5569
 2140 write (ioa,5030) nxx                                                  5570
      go to 3180                                                            5571
c                                                                           5572
c RD - reset defaults ------                                                5573
c                                                                           5574
 2150 write (ioa,4110)                                                      5575
      read (in,4440,end=3170) aw                                            5576
      if (law(aw)) go to 3170                                               5577
      ira=0                                                                 5578
      icm=2                                                                 5579
      mul3=mul2                                                             5580
      iop=2                                                                 5581
      istp=0                                                                5582
c      ihot=iho                                                             5583
      irw=2                                                                 5584
      lq=1                                                                  5585
      lqq=1                                                                 5586
      iv=1                                                                  5587
      ivv=1                                                                 5588
      sk=s0k                                                                5589
      sr1=s0r1                                                              5590
      swi=s0wi                                                              5591
      viw=wiw                                                               5592
      viv=wiv                                                               5593
      vik=wik                                                               5594
      ddifw=difw                                                            5595
      ddazb=dazb                                                            5596
      sr0=dl0                                                               5597
      su1=dl1                                                               5598
      vj=vdd                                                                5599
      vd=vj/100.+1.                                                         5600
      go to 2640                                                            5601
c                                                                           5602
c CG - get c.p. from C-mem. ---                                             5603
c                                                                           5604
 2160 if (ngkk.le.0) go to 2420                                             5605
      write (ioa,4120) ngkk                                                 5606
      call les (in)                                                         5607
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5608
      n=max1(abs(c(1)),1.)                                                  5609
      if (n.gt.ngkk) go to 3170                                             5610
 2170 n=imx(n)                                                              5611
      do 2180 i=1,3                                                         5612
        dg(i)=dgld(i,n)                                                     5613
        dg(i+3)=cos(fak*dgld(i+3,n))                                        5614
 2180   dgw(i)=dgld(i+3,n)                                                  5615
c                                                                           5616
      ila=1                                                                 5617
      rs=rs0                                                                5618
      do 2190 i=1,17                                                        5619
 2190   text(i)='    '                                                      5620
c                                                                           5621
      ta1='-DC-'                                                            5622
      call clt (text)                                                       5623
      c(1)=1.                                                               5624
      ig=in                                                                 5625
      go to 310                                                             5626
c                                                                           5627
c CM --- compreh. of output on file ---                                     5628
c                                                                           5629
 2200 write (ioa,4130)                                                      5630
      call les (in)                                                         5631
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5632
      iop=min1(abs(c(1)),2.)                                                5633
      go to 3180                                                            5634
c                                                                           5635
c PC --- prepare c.p. determination ---                                     5636
c                                                                           5637
 2210 if (mul3.eq.mul2) go to 2220                                          5638
      write (ioa,4140) mul3                                                 5639
      read (in,4440,end=3140) aw                                            5640
      if (law(aw)) go to 3140                                               5641
c                                                                           5642
 2220 call ldini (as,bs,gas,vmi,vma,io,ioa,in,iii,ipabs,mul3,ilim,ibr,      5643
     1iret)                                                                 5644
      if (iret.ne.0) go to 2210                                             5645
      if (n.eq.1) go to 2230                                                5646
      if (n.eq.0) write (ioa,4150)                                          5647
      go to 3170                                                            5648
c                                                                           5649
 2230 ldst=1                                                                5650
      istp1=2-istp                                                          5651
      go to 3180                                                            5652
c                                                                           5653
c  DC --- determine c.p. ---                                                5654
c                                                                           5655
 2240 if (ldst.eq.1) go to 2250                                             5656
      write (ioa,4160) j9(60),j9(60)                                        5657
      go to 3180                                                            5658
c                                                                           5659
 2250 ipabs=npl(x(3,3),ier,ioa,nx1,ny1)                                     5660
      if (ier.eq.0) go to 2260                                              5661
      write (ioa,4150)                                                      5662
      go to 3140                                                            5663
c                                                                           5664
 2260 flcc=sqrt(flc)/x(3,3)                                                 5665
      flc1=flcc                                                             5666
      icmd=icm                                                              5667
      icm=mul3                                                              5668
      il1=1                                                                 5669
      if (ilim.ne.0) flim=1.5                                               5670
      c(1)=100.*dec5                                                        5671
      dew2=dew*sqrt(2.)                                                     5672
c                                                                           5673
c     write (io,4060) j9(64),j9(23),j9(59),j9(66),j9(24),tstp(istp+1),      5674
c    1istp,icm,tout(iop+1),iop,ddifw,ddazb,ira,c(1),dew2,vmi,flcc,ipabs     5675
c     if (io.ne.ioa) write (ioa,4060) j9(64),j9(23),j9(59),j9(66),j9(24)    5676
c    1,tstp(istp+1),istp,icm,tout(iop+1),iop,ddifw,ddazb,ira,c(1),dew2,     5677
c    2vmi,flcc,ipabs                                                        5678
c                                                                           5679
      write (ioa,4170) j9(23),icm,j9(24),ira,vmi,ipabs,flcc                 5680
      if (io.ne.ioa) write (io,4170) j9(23),icm,j9(24),ira,vmi,ipabs,       5681
     1flcc                                                                  5682
c                                                                           5683
      read (in,4440,end=3180) aw                                            5684
      if (law(aw)) go to 3180                                               5685
c                                                                           5686
c                                                                           5687
 2270 ioioio=0                                                              5688
c     write (ioa,4120)                                                      5689
c+++                                                                        5690
      if (ioioi.eq.0) go to 2280                                            5691
      call les (in)                                                         5692
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3140                               5693
c+++                                                                        5694
 2280 c(1)=0.                                                               5695
      c(2)=0.                                                               5696
      c(3)=0.                                                               5697
c+++                                                                        5698
      iistp=istp                                                            5699
      iistp1=istp1                                                          5700
      istp=2                                                                5701
      istp1=0                                                               5702
      nru=max1(c(1),0.)                                                     5703
      if (istp1.gt.0.and.nru.eq.0) nru=1                                    5704
c                                                                           5705
      jwr=c(3)                                                              5706
      if (c(2).eq.0.) flim=.5                                               5707
      iwst=1                                                                5708
ccc                                                                         5709
      if (jwr.eq.0) go to 2290                                              5710
      write (ioa,3610)                                                      5711
      read (in,3980,end=2270) file6                                         5712
      if (file6.eq.'. '.or.file6.eq.', ') go to 2270                        5713
      if (file6.eq.'    ') file6='a.a'                                      5714
      open (unit=45,file=file6,status='unknown')                            5715
      write (45,5090) vmi,vma,rga2,rgb2,rrgg(3)                             5716
ccc                                                                         5717
 2290 if (ngkk.eq.0) go to 2300                                             5718
c                                                                           5719
      write (ioa,4180) ngkk                                                 5720
      read (in,4440,end=2320) aw                                            5721
      if (law(aw)) go to 2320                                               5722
c                                                                           5723
 2300 ngkk=0                                                                5724
      nall=0                                                                5725
      nsub=0                                                                5726
      sfmx=0.                                                               5727
      do 2310 i=1,nso                                                       5728
 2310   ssfom(i)=0.                                                         5729
c                                                                           5730
 2320 ild=1                                                                 5731
      ila=1                                                                 5732
      rs=rs0                                                                5733
      ke=0                                                                  5734
      nrlc=0                                                                5735
      iopd=iop                                                              5736
      iop=1                                                                 5737
      irh=0                                                                 5738
      nrud=nru                                                              5739
      ibr=54                                                                5740
      nbd=nbb                                                               5741
      nbb=1                                                                 5742
ccc                                                                         5743
      ssfox=100000.                                                         5744
      rg6=cos(gas*fak)                                                      5745
      rg(1)=as                                                              5746
      rg(2)=bs                                                              5747
      rg(6)=rg6                                                             5748
c                                                                           5749
      do 2350 i=1,nx                                                        5750
        k=i                                                                 5751
c                                                                           5752
        if (rf(1,i).lt..00001) go to 2350                                   5753
        do 2330 j=1,13                                                      5754
 2330     skd(j,i)=rf(ju(j),i)                                              5755
c                                                                           5756
        if (isig.ne.2) go to 2340                                           5757
        rf(2,i)=csig*rf(1,i)                                                5758
        rf(4,i)=rsig*rf(3,i)                                                5759
        rf(6,i)=rsig*rf(5,i)                                                5760
        rf(10,i)=asig                                                       5761
c                                                                           5762
 2340   call rfo (rf,dew2,dec5,fak,c,k)                                     5763
c                                                                           5764
        if (itst(2).eq.0) go to 2350                                        5765
        write (6,3550) (skd(j,i),j=1,7)                                     5766
        write (6,3550) rf(2,i),rf(4,i),rf(6,i),rf(10,i),rf(35,i),rf(36,     5767
     1   i),rf(26,i)                                                        5768
        write (6,3550) (skd(j,i),j=8,13)                                    5769
        write (6,3550) rf(27,i),rf(28,i),rf(29,i),rf(37,i),rf(32,i),        5770
     1   rf(33,i)                                                           5771
c  gggg                ????                                                 5772
c        if (itst(2).ne.0) read (in,4390) aw                                5773
        read (in,4440) aw                                                   5774
c                                                                           5775
 2350 continue                                                              5776
c                                                                           5777
      go to 1740                                                            5778
cccc                                                                        5779
 2360 if (jwr.eq.0.or.iwst.ne.0) go to 2370                                 5780
      ssfo=sfom                                                             5781
      if (abs(sfom).lt.0.00001) go to 2370                                  5782
      ssfo=sfom/swt                                                         5783
      ssfox=amin1(ssfox,ssfo)                                               5784
c gggg                                                                      5785
c      iwww=iwww+1                                                          5786
c     if (ittest.eq.1) write (6,3570) x1,x2,ssfo,x3,iwww                    5787
c     write (45,3570) x1,x2,ssfo,x3,iwww                                    5788
      if (ittest.eq.1) write (6,3620) x1,x2,ssfo,x3                         5789
      write (45,3620) x1,x2,ssfo,x3                                         5790
cccc                                                                        5791
 2370 rg(1)=as                                                              5792
      rg(2)=bs                                                              5793
      rg(6)=rg6                                                             5794
      call rlgen (ie,nrlc,ipabs,ngkk,nall,dx,dy,dz,ittest)                  5795
      ddx=1.5*dx                                                            5796
      ddy=1.5*dy                                                            5797
      ddz=1.5*dz                                                            5798
cccc                                                                        5799
      iwst=0                                                                5800
      sfom=0.                                                               5801
cccc                                                                        5802
      go to (2390,2400,2380),ie+1                                           5803
c                                                                           5804
 2380 write (ioa,3930)                                                      5805
      nrlc=0                                                                5806
      read (in,4440,end=2400) aw                                            5807
      if (law(aw)) go to 2400                                               5808
c kann DIRE evtl. nur im Erfolgsfalle aufgerufen werden? nur V* berechne    5809
 2390 call dire (rg,dg,dgw,fakr,v0,ier)                                     5810
      v0=1./v0                                                              5811
      v3=v0                                                                 5812
      go to 430                                                             5813
cioioio                                                                     5814
 2400 if (ngkk.gt.0.and.iun.ne.8) write (iun,4190) (i,ffom(imx(i)),         5815
     1xna(imx(i)),xnb(imx(i)),xnc(imx(i)),(dgld(j,imx(i)),j=1,6),           5816
     2vld(imx(i)),i=1,ngkk)                                                 5817
      ldst=0                                                                5818
c                                                                           5819
c  CW --- write C-mem. ---                                                  5820
c                                                                           5821
      k=min0(nso,ngkk)                                                      5822
      val1=ffom(imx(1))                                                     5823
      valk=ffom(imx(k))                                                     5824
 2410 if (ngkk.gt.0) go to 2430                                             5825
 2420 write (ioa,4200) j9(61)                                               5826
      go to (3180,3090),ild+1                                               5827
c                                                                           5828
 2430 ldst=0                                                                5829
c                                                                           5830
c 0.03 noch hinterfragen                                                    5831
c                                                                           5832
      dela=.03*rga2                                                         5833
      delb=.03*rgb2                                                         5834
      write (io,4210) k,ormx(kim+1),val1,valk,nall                          5835
      if (io.ne.ioa) write (ioa,4210) k,ormx(kim+1),val1,valk,nall          5836
      write (ioa,3680)                                                      5837
      istp=iistp                                                            5838
      istp1=iistp1                                                          5839
      if (jwr.ge.0) go to 2450                                              5840
ccccc                                                                       5841
      fofo=0.8*ssfox                                                        5842
      do 2440 ll=1,k                                                        5843
        i=imx(ll)                                                           5844
        if (ittest.eq.0) write (45,3620) xna(i),xnb(i),fofo,xnc(i),iwww     5845
c ###                                                                       5846
 2440   if (ittest.eq.0) write (6,3620) xna(i),xnb(i),fofo,xnc(i),iwww      5847
ccccc                                                                       5848
 2450 do 2460 ll=1,k                                                        5849
        i=imx(ll)                                                           5850
        xza=.5*xna(i)/rga2                                                  5851
        yzb=.5*xnb(i)/rgb2                                                  5852
        d=ssfom(i)/sfmx                                                     5853
        write (io,3920) ll,ffom(i),(dgld(j,i),j=1,6),xza,yzb,vld(i),d       5854
        if (io.ne.ioa) write (ioa,3920) ll,ffom(i),(dgld(j,i),j=1,6),       5855
     1   xza,yzb,vld(i),d                                                   5856
        if (mod(ll,limax-3).ne.0) go to 2460                                5857
        write (ioa,3930)                                                    5858
        read (in,4440,end=3180) aw                                          5859
        if (law(aw)) go to (3180,3090),ild+1                                5860
 2460 continue                                                              5861
c                                                                           5862
      go to (3180,3090),ild+1                                               5863
c                                                                           5864
c BR --- break condition ---                                                5865
c                                                                           5866
 2470 write (ioa,4220) j9(51),j9(54)                                        5867
      call les (in)                                                         5868
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               5869
      istp=min1(abs(c(1)),2.)                                               5870
      write (ioa,3920) istp                                                 5871
      istp1=2-istp                                                          5872
      go to 3180                                                            5873
c                                                                           5874
c ---- RF ------                                                            5875
c                                                                           5876
c  refinement, dummy                                                        5877
 2480 write (io,4230) (i,j9(i),i6(i),i=1,nsb)                               5878
      write (ioa,3380)                                                      5879
      call les (in)                                                         5880
      if (n.eq.0) go to 3170                                                5881
      fkk=c(1)                                                              5882
      if (fkk.le..1.or.fkk.gt.100.) fkk=5.                                  5883
      write (ioa,*) fkk                                                     5884
      go to 3180                                                            5885
c                                                                           5886
c EQ --- limits for equivalence in DC ---                                   5887
c                                                                           5888
 2490 write (io,4240) j9(61),difw,dazb,ddifw,ddazb                          5889
      if (io.ne.ioa) write (ioa,4240) j9(61),difw,dazb,ddifw,ddazb          5890
      call les (in)                                                         5891
      if (n.eq.0) go to 3170                                                5892
      ddifw=c(1)                                                            5893
      if (ddifw.gt.10..or.ddifw.lt..1) ddifw=difw                           5894
      ddazb=c(2)                                                            5895
      if (ddazb.gt..2.or.ddazb.lt..001) ddazb=dazb                          5896
      write (io,4250) ddifw,ddazb                                           5897
      if (io.ne.ioa) write (ioa,4250) ddifw,ddazb                           5898
      go to 3180                                                            5899
c                                                                           5900
c SD --- Delaunay reduction scan C-mem. ---                                 5901
c                                                                           5902
 2500 idid=0                                                                5903
      call delc (ngkk,rs,rs0,ier,isy,id33,idid)                             5904
      if (idid.eq.0.and.n.ne.100) write (io,5130)                           5905
      go to (3170,3180,2420),ier                                            5906
c                                                                           5907
c DE --- Delaunay reduction ---                                             5908
c                                                                           5909
 2510 isx=0                                                                 5910
      call del (dg,dgw,ddw,ddv,ila,ntr,ntr0,rs,rs0,isx,nrt,id33,0)          5911
      if (n.le.0) go to 3170                                                5912
      if (ntr0.le.0.or.ntr.lt.ntr0) go to 3180                              5913
      ig=in                                                                 5914
      go to 310                                                             5915
c                                                                           5916
c BP put c.p. to B-mem. ---                                                 5917
c                                                                           5918
 2520 if (mbr(ke,ila).ne.0) go to 2570                                      5919
      call ltoh (jsm,ila,rs,in,ioa,text,ta1,dg,dgw)                         5920
      go to (3170,3180),n+1                                                 5921
c                                                                           5922
c BG --- get c.p. from B-mem. ---                                           5923
c                                                                           5924
 2530 call htol (dg,dgw,jsm,ila,rs,in,io,ioa,text,ta1)                      5925
      if (n.eq.0) go to 3170                                                5926
c                                                                           5927
c                                                                           5928
      write (ioa,4570) ta1,(text(i),i=1,16)                                 5929
      ig=in                                                                 5930
      go to 310                                                             5931
c                                                                           5932
c BD --- delete c.p. from B-mem. ---                                        5933
c                                                                           5934
 2540 call dlgk (jsm,in,ioa,ibr,jfw)                                        5935
      go to (3170,3180),n+1                                                 5936
c                                                                           5937
c BS --- save B-mem. on file ---                                            5938
c                                                                           5939
 2550 call htof (jsm,in,ioa,isl,if4,nsc,file)                               5940
      go to (3170,3180),n+1                                                 5941
c                                                                           5942
c CR , CD --- calc. in dir. and rec. space ---                              5943
c                                                                           5944
 2560 if (mbr(ke,ila).ne.0) go to 2570                                      5945
      iiv=0                                                                 5946
      if (ibr.eq.71) iiv=1                                                  5947
      call ca (cr,cd,v0,in,io,ioa,fk,ila,jsm,iiv,ilo,rc,rz0,rz1,wic,yzx,    5948
     1ydx,aq,ny)                                                            5949
      go to 3180                                                            5950
c                                                                           5951
 2570 write (ioa,4980) ta1,text(1),text(2),jsm(ila),isys(ke+1),j9(62)       5952
      go to 3170                                                            5953
c                                                                           5954
c LD --- load calculated SAD data ---                                       5955
c                                                                           5956
 2580 if (ilo.gt.0) go to 2590                                              5957
      write (ioa,4260) j9(70)                                               5958
      go to 3180                                                            5959
 2590 rz0=amin1(rz0,99999.9)                                                5960
      write (ioa,4270) ak,rc,wic,rz0,rz1                                    5961
      read (in,4440,end=3170) aw                                            5962
      if (law(aw)) go to 3170                                               5963
      write (ioa,4340)                                                      5964
      read (in,4350,end=3170) titel                                         5965
      if (titel(1).eq.'.   '.or.titel(1).eq.',   ') go to 3170              5966
      ilo=0                                                                 5967
      wi=wic                                                                5968
      dwi=swi                                                               5969
      r1=rc(1)                                                              5970
      dr1=sr1*r1                                                            5971
      r2=rc(2)                                                              5972
      dr2=sr1*r2                                                            5973
c?                                                                          5974
      dak=sk*ak                                                             5975
c                                                                           5976
      r3=rc(3)                                                              5977
      dr3=0.                                                                5978
      l7=2                                                                  5979
      j4=1                                                                  5980
      l=1                                                                   5981
      ix=1                                                                  5982
      r0=rz0                                                                5983
      tl=atan(r0/akl)                                                       5984
      se=r1*r2*sin(wi*fak)                                                  5985
      ph=fakr*tl                                                            5986
      sr0=dl0                                                               5987
      rl1=rz1                                                               5988
      r0m=rl1                                                               5989
      su1=dl1                                                               5990
      v=v0                                                                  5991
      an0=0.                                                                5992
      an1=0.                                                                5993
      an2=0.                                                                5994
      vca=v/fk(ila)                                                         5995
      call resto (0,ihv)                                                    5996
      go to 1200                                                            5997
c                                                                           5998
c SS --- cell parameters from two patterns ---                              5999
c                                                                           6000
 2600 ier=ibr                                                               6001
      call ss (ig,isr,pftst1,rs0,rs,ier,id33)                               6002
      go to (3170,310),ier                                                  6003
c                                                                           6004
c GS --- calc. angles between zones from gonio. setting ---                 6005
c GR --- read goniometer data ---                                           6006
c GC --- calc. zone angles for patterns in A-mem. ---                       6007
c                                                                           6008
 2610 call gon (holder,ibr,ihot,ihon,nx,ier)                                6009
      go to (3170,3180),ier                                                 6010
c                                                                           6011
c ZA --- write zone axes ---                                                6012
c                                                                           6013
 2620 iza=mod(iza+1,2)                                                      6014
      write (ioa,4280) p7l(iza+1)                                           6015
      go to 3180                                                            6016
c                                                                           6017
c XW --- "x-ray" wave length ---                                            6018
c                                                                           6019
 2630 write (ioa,4290) xla                                                  6020
      call les (in)                                                         6021
      if (n.eq.0.or.c(1).gt.50.) go to 3170                                 6022
      xl=c(1)                                                               6023
      if (xl.eq.0.) xl=xla                                                  6024
      if (xl.lt.0.) xl=-.2*xl*fak                                           6025
      write (ioa,3900) xl                                                   6026
      go to 3180                                                            6027
c                                                                           6028
c V  --- view (list conditions) ---                                         6029
c                                                                           6030
 2640 write (6,3320) igl,file1                                              6031
      write (6,3330) ig1,fdd                                                6032
      if (if4.ne.0) write (6,3340) if4,fsc                                  6033
      write (6,3890)                                                        6034
c                                                                           6035
      do 2650 i=1,jlin                                                      6036
 2650   aq(i)=' '                                                           6037
      if (ira.ne.0) aq(1)='*'                                               6038
      if (icm.ne.2) aq(2)='*'                                               6039
      if (mul3.ne.mul2) aq(3)='*'                                           6040
      if (iop.ne.2) aq(4)='*'                                               6041
      if (istp.ne.0) aq(5)='*'                                              6042
c ihon!                                                                     6043
c     if (ihot.ne.iho.and.ihot.ne.0) aq(6)='*'                              6044
c neu:                                                                      6045
      if (ihon.ne.1) aq(6)='*'                                              6046
c                                                                           6047
      if (irw.ne.2) aq(7)='*'                                               6048
      cha2(1)=j9(57)                                                        6049
      if (irw.eq.2) cha2(1)=j9(58)                                          6050
      if (lq.ne.1) aq(8)='*'                                                6051
      cha2(2)=j9(45)                                                        6052
      if (lq.eq.1) cha2(2)=j9(36)                                           6053
      if (iv.ne.1) aq(9)='*'                                                6054
      cha2(3)=j9(47)                                                        6055
      if (iv.eq.1) cha2(3)=j9(46)                                           6056
      if (sk.ne.s0k) aq(10)='*'                                             6057
      if (sr1.ne.s0r1) aq(11)='*'                                           6058
      if (swi.ne.s0wi) aq(12)='*'                                           6059
      if (viw.ne.wiw) aq(13)='*'                                            6060
      if (viv.ne.wiv) aq(14)='*'                                            6061
      if (vik.ne.wik) aq(15)='*'                                            6062
      if (ddifw.ne.difw) aq(16)='*'                                         6063
      if (ddazb.ne.dazb) aq(17)='*'                                         6064
      if (dl0.ne.ddl0) aq(18)='*'                                           6065
      if (dl1.ne.ddl1) aq(19)='*'                                           6066
      if (vj.ne.vdd) aq(20)='*'                                             6067
      icj=icm                                                               6068
      if (icj.eq.0) icj=-1                                                  6069
      write (ioa,4300)                                                      6070
      write (ioa,4310) j9(24),ira,aq(1),j9(23),icj,aq(2),mul3,aq(3),        6071
     1j9(59),iop,aq(4),j9(64),istp,aq(5),j9(79),ihon,aq(6),j9(57),j9(58)    6072
     2,cha2(1),aq(7),j9(36),j9(45),cha2(2),aq(8),j9(46),j9(47),cha2(3),     6073
     3aq(9)                                                                 6074
      write (ioa,4320) j9(82),sk,aq(10),sr1,aq(11),swi,aq(12),j9(2),viw,    6075
     1aq(13),viv,aq(14),vik,aq(15),j9(66),ddifw,aq(16),ddazb,aq(17),        6076
     2j9(43),j9(44),dl0,aq(18),dl1,aq(19),j9(48),vj,aq(20)                  6077
      go to 3180                                                            6078
c                                                                           6079
c . + - * / < > <> SI CO TG AS AC AT MP MG LX ("." = enter)                 6080
c                                                                           6081
 2660 call upn (ibr,ier,fak,in,ioa)                                         6082
      go to (3170,3180),ier                                                 6083
c                                                                           6084
c UN -- unify pattern --                                                    6085
c                                                                           6086
 2670 call uni (r1,r2,wi,r1n,r2n,win,r3n,fak,ier)                           6087
      if (ier.ne.0) go to 2680                                              6088
      write (ioa,3760)                                                      6089
      go to 3180                                                            6090
 2680 if (ier.eq.2) write (ioa,4640)                                        6091
      write (ioa,3770) r1,r2,r3,wi,r1n,r2n,r3n,win                          6092
      read (in,4440,end=3170) aw                                            6093
      if (law(aw)) go to 3170                                               6094
      dr3=.5*(dr1/r1+dr2/r2)                                                6095
      dr1=dr3*r1n                                                           6096
      dr2=dr3*r2n                                                           6097
      dr3=0.                                                                6098
      r1=r1n                                                                6099
      r2=r2n                                                                6100
      r3=r3n                                                                6101
      wi=win                                                                6102
      call prep1                                                            6103
cio      iooo=9                                                             6104
cio      iooi=10                                                            6105
cio      write (6,*) iooo,ioa,iun,io,iooi                                   6106
cio     call edit (ioa,1,10)                                                6107
      call edit (6,1,10)                                                    6108
      if (jfw.ne.0) call edit (88,1,10)                                     6109
      go to 3180                                                            6110
c                                                                           6111
c C0 -- radius 0.LZ from tilt angle                                         6112
c                                                                           6113
 2690 write (ioa,3630)                                                      6114
      call les (in)                                                         6115
      if (n.eq.0.or.abs(c(1)).gt.89.9) go to 3170                           6116
      c(1)=akl*tan(fak*c(1))                                                6117
      write (ioa,4960) c(1),ihv                                             6118
      write (ioa,5110) j9(41)                                               6119
      read (in,4440,end=3170) aw                                            6120
      if (law(aw)) go to 3180                                               6121
      go to 1420                                                            6122
c                                                                           6123
c YX -- hight/width for screen and lineprinter                              6124
c                                                                           6125
 2700 write (ioa,3650) ny,yzx,ydx                                           6126
      call les (in)                                                         6127
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               6128
      if (c(2)) 2710,2720,2730                                              6129
 2710 yzx=-c(2)*yzx                                                         6130
      yzx0=yzx                                                              6131
      go to 2740                                                            6132
 2720 yzx=yzx0                                                              6133
      go to 2740                                                            6134
 2730 yzx=c(2)                                                              6135
      yzx0=yzx                                                              6136
 2740 yzx=amax1(yzx,.3)                                                     6137
      yzx=amin1(yzx,4.)                                                     6138
      yzx0=amax1(yzx0,.3)                                                   6139
      yzx0=amin1(yzx0,4.)                                                   6140
c                                                                           6141
      if (c(3)) 2750,2760,2770                                              6142
 2750 ydx=-c(3)*ydx                                                         6143
      ydx0=ydx                                                              6144
      go to 2780                                                            6145
 2760 ydx=ydx0                                                              6146
      go to 2780                                                            6147
 2770 ydx=c(3)                                                              6148
      ydx0=ydx                                                              6149
 2780 ydx=amax1(ydx,.3)                                                     6150
      ydx=amin1(ydx,4.)                                                     6151
      ydx0=amax1(ydx0,.3)                                                   6152
      ydx0=amin1(ydx0,4.)                                                   6153
c                                                                           6154
      if (abs(c(1)).ge.6..and.abs(c(1)).le.20.) ny=c(1)                     6155
      write (ioa,3660) ny,yzx,ydx                                           6156
      go to 3180                                                            6157
c                                                                           6158
c NL --- lines per screen                                                   6159
c                                                                           6160
 2790 write (ioa,3640) limax                                                6161
      call les (in)                                                         6162
      if (n.eq.0.or.ndi(1).gt.mdi.or.c(1).le.0.) go to 3170                 6163
      limax=max1(10.,c(1))                                                  6164
      limax=min0(50,limax)                                                  6165
      write (ioa,3660) limax                                                6166
      go to 3180                                                            6167
c                                                                           6168
c AX --- exclude data in memory A from DC and SA                            6169
c AI --- invert exclusion key                                               6170
c LA --- list A-memory (d-values) ---                                       6171
c                                                                           6172
 2800 call cksg (io,ioa,in,sv,vmin,vmax,iii,-1,ilim,0,iall)                 6173
      if (nrff.eq.0.and.iall.eq.0) go to 2810                               6174
      if (nrff.eq.iall) go to 3180                                          6175
      if (iall.gt.0) go to 2820                                             6176
 2810 write (ioa,4780)                                                      6177
      go to 3180                                                            6178
 2820 if (ibr.eq.133) go to 3180                                            6179
      if (ibr.eq.134) go to 2840                                            6180
      write (ioa,3570) nx                                                   6181
      call les (in)                                                         6182
      if (n.eq.0.or.ndi(1).gt.mdi.or.c(1).eq.0.) go to 3170                 6183
      j=abs(c(1))                                                           6184
      if (j.le.nx) go to 2860                                               6185
c                                                                           6186
      nrff=0                                                                6187
      do 2830 i=1,nx                                                        6188
        if (rf(1,i).lt..001) go to 2830                                     6189
        rf(40,i)=2.                                                         6190
        nrff=nrff+1                                                         6191
        if (c(1).lt.0.) rf(40,i)=0.                                         6192
 2830 continue                                                              6193
      go to 2800                                                            6194
c                                                                           6195
c  AI                                                                       6196
 2840 do 2850 i=1,nx                                                        6197
        if (rf(1,i).lt..001) go to 2850                                     6198
        rf(40,i)=2.-rf(40,i)                                                6199
 2850 continue                                                              6200
      write (ioa,3250)                                                      6201
      call cksg (io,ioa,in,sv,vmin,vmax,iii,-1,ilim,0,iall)                 6202
      go to 3180                                                            6203
c                                                                           6204
 2860 if (rf(1,j).lt..001) go to 3170                                       6205
      rf(40,j)=2.                                                           6206
      if (c(1).lt.0.) rf(40,j)=0.                                           6207
      ibr=133                                                               6208
      go to 2800                                                            6209
c                                                                           6210
c JE JH  --- r1, r2 from JEM3010 projective                                 6211
c                                                                           6212
 2870 bjex=ajex                                                             6213
      bjey=ajey                                                             6214
      if (ibr.eq.122) go to 2880                                            6215
      write (ioa,3390)                                                      6216
      bjex=ahex                                                             6217
      bjey=ahey                                                             6218
      call hex (in,ioa,bjex,bjey,ak)                                        6219
      go to 2890                                                            6220
 2880 write (ioa,3460)                                                      6221
      call les (in)                                                         6222
 2890 if (n.eq.0) go to 3170                                                6223
      if (c(5).le.0.) c(5)=1.                                               6224
      if (c(8).le.0.) c(8)=1.                                               6225
      c(11)=sqrt((bjex*(c(1)-c(3)))**2+(bjey*(c(2)-c(4)))**2)               6226
      c(12)=sqrt((bjex*(c(1)-c(6)))**2+(bjey*(c(2)-c(7)))**2)               6227
      c(13)=sqrt((bjex*(c(3)-c(6)))**2+(bjey*(c(4)-c(7)))**2)               6228
      c(9)=c(11)/c(5)                                                       6229
      c(10)=c(12)/c(8)                                                      6230
      if (c(11).eq.0..or.c(12).eq.0.) go to 2900                            6231
      c(14)=(c(11)**2+c(12)**2-c(13)**2)/(2.*c(11)*c(12))                   6232
      if (abs(c(14)).le.1.) go to 2910                                      6233
      write (6,3470)                                                        6234
      go to 3170                                                            6235
 2900 write (ioa,3370)                                                      6236
      go to 3180                                                            6237
 2910 d=fakr*arco(c(14))                                                    6238
      c(1)=ak/c(9)                                                          6239
      c(2)=ak/c(10)                                                         6240
      write (ioa,3400) c(9),c(10),c(1),c(2),d                               6241
      read (in,4440,end=3170) aw                                            6242
      if (law(aw)) go to 3170                                               6243
      write (ioa,4340)                                                      6244
      read (in,4350,end=3170) titel                                         6245
      if (titel(1).eq.'.   '.or.titel(1).eq.',   ') go to 3170              6246
      r1=c(9)                                                               6247
      r2=c(10)                                                              6248
      dr1=sr1*r1                                                            6249
      dr2=sr1*r2                                                            6250
      wi=d                                                                  6251
      r3=sqrt(amax1(0.,r1*r1+r2*r2-2.*r1*r2*c(14)))                         6252
      dr3=sr1*r3                                                            6253
      dwi=swi                                                               6254
cio      iooo=10                                                            6255
cio      write (6,*) iooo,ioa,iun,io,ibr                                    6256
cio      call edit (ioa,1,ibr)                                              6257
      call edit (6,1,ibr)                                                   6258
      if (jfw.ne.0) call edit (88,1,ibr)                                    6259
      go to 3180                                                            6260
c                                                                           6261
c NC  --- new calibration of deflector coils                                6262
c                                                                           6263
 2920 write (ioa,3360) j9(125),j9(122)                                      6264
      call les (in)                                                         6265
      if (n.eq.0.or.c(1).lt.0) go to 3170                                   6266
      ibr=125                                                               6267
      if (c(1).ne.0.) ibr=122                                               6268
      write (ioa,3480)                                                      6269
      call les (in)                                                         6270
      if (n.eq.0.or.ndi(1).gt.mdi) go to 3170                               6271
      i=c(1)                                                                6272
      if (i.lt.0.or.i.gt.2) go to 3170                                      6273
c                                                                           6274
      bjex=ajex                                                             6275
      bjey=ajey                                                             6276
      xxj=xj                                                                6277
      yyj=yj                                                                6278
      if (ibr.eq.122) go to 2930                                            6279
c                                                                           6280
      bjex=ahex                                                             6281
      bjey=ahey                                                             6282
      xxj=xjh                                                               6283
      yyj=yjh                                                               6284
c                                                                           6285
 2930 write (ioa,3490) bjex,bjey,xxj,yyj                                    6286
      call les (in)                                                         6287
      if (n.eq.0) go to 3170                                                6288
      if (c(1)) 2950,3170,2940                                              6289
 2940 if (i.lt.2) bjex=c(1)                                                 6290
      if (i.eq.2) bjey=c(1)                                                 6291
      if (i.ne.0) go to 2960                                                6292
      bjey=c(2)                                                             6293
      if (bjey.eq.0.) bjey=bjex                                             6294
      if (bjey.lt.0.) bjey=yyj                                              6295
      go to 2960                                                            6296
 2950 if (i.lt.2) bjex=xxj                                                  6297
      if (i.eq.0.or.i.eq.2) bjey=yyj                                        6298
 2960 write (ioa,3500) bjex,bjey                                            6299
      if (ibr.eq.125) go to 2970                                            6300
      ajex=bjex                                                             6301
      ajey=bjey                                                             6302
      go to 3180                                                            6303
 2970 ahex=bjex                                                             6304
      ahey=bjey                                                             6305
      go to 3180                                                            6306
c                                                                           6307
c CZ  --- closest zone                                                      6308
c                                                                           6309
 2980 tid(1)=isys(ke+1)                                                     6310
      tid(2)=')   '                                                         6311
      itri=0                                                                6312
      if (ila.ne.5.or.ke.ne.2) go to 2990                                   6313
      tid(1)='trig'                                                         6314
      tid(2)='. R)'                                                         6315
      itri=1                                                                6316
 2990 write (ioa,3560) tid(1),tid(2)                                        6317
      call czrh (ila,ke,cd,fakr,in,io,ioa,itri,limax)                       6318
      go to 3180                                                            6319
c                                                                           6320
c OZ  ------- set up reference zones                                        6321
c                                                                           6322
 3000 ihoz=ihot                                                             6323
c !!!!! ihoz: temporaere Strategie fuer ihot=0                              6324
      if (ihoz.le.0) ihoz=iho                                               6325
      call zo (ie,ihoz,fakr,cd,dg,dgw,rs,rs0,dg0,dgw0,rs00,rs000,ila0,      6326
     1ihon,jsm)                                                             6327
      if (ie.gt.0) go to 3170                                               6328
      go to 3180                                                            6329
c                                                                           6330
c AB  ------- calculate gon.angles  (double tilt)                           6331
c                                                                           6332
 3010 if (izo(1).ne.0.and.izo(2).ne.0) go to 3020                           6333
      write (ioa,3350) j9(126)                                              6334
      go to 3180                                                            6335
 3020 call ab1 (cd,fakr,dg,dgw,rs,ihoz,dg0,dgw0,rs00,ila0,j9,jsm,ie,        6336
     1ihon,0)                                                               6337
c ie?                                                                       6338
      go to 3180                                                            6339
c                                                                           6340
c GO  ------- goniometer angles up to alpha-beta(max.) (double tilt)        6341
c                                                                           6342
 3030 ke1=ke                                                                6343
      ke=0                                                                  6344
      call uvwgen (cd,fakr,dg,dgw,rs,ihoz,dg0,dgw0,rs00,ila0,j9,jsm,ie,     6345
     1ihon)                                                                 6346
      ke=ke1                                                                6347
      go to 3180                                                            6348
c                                                                           6349
c HD  ----- hexadecimal to decimal                                          6350
c                                                                           6351
 3040 write (ioa,3410)                                                      6352
      read (in,3420,end=3170) chd                                           6353
      d=htod(chd)                                                           6354
      if (d.lt.0.) go to 3170                                               6355
      write (ioa,*) d                                                       6356
      write (ioa,3430)                                                      6357
      call les (in)                                                         6358
      if (n.eq.0.or.c(1).lt.1.or.c(1).gt.5.) go to 3170                     6359
      j=c(1)                                                                6360
      if (j.lt.5) xc(j)=d                                                   6361
      if (j.eq.5) xm=d                                                      6362
      write (ioa,3440) xc,xm                                                6363
      go to 3180                                                            6364
c                                                                           6365
c CW  -----  write memory C                                                 6366
c                                                                           6367
 3050 if (ngkk.le.0) go to 2420                                             6368
      write (ioa,3450)                                                      6369
      call les (in)                                                         6370
      if (n.eq.0) go to 3180                                                6371
      if (c(1).lt.0..or.c(1).gt.2.) c(1)=0.                                 6372
      kim=c(1)                                                              6373
      k=min0(nso,ngkk)                                                      6374
      if (kim.eq.2) call srt (kim,k,imx,vld,val1,valk)                      6375
      if (kim.eq.1) call srt (kim,k,imx,ssfom,val1,valk)                    6376
      if (kim.eq.0) call srt (kim,k,imx,ffom,val1,valk)                     6377
      go to 2410                                                            6378
c                                                                           6379
c --- IS idealize symmetry                                                  6380
c                                                                           6381
 3060 call idsy (ierr,isys,in,io,ioa,ila,jsm)                               6382
      go to (310,3180),ierr+1                                               6383
c                                                                           6384
c --- MV matrix-vector operations (135)                                     6385
c                                                                           6386
 3070 call mvvm (cd,dg,dgw,fakr,cvm,ivm)                                    6387
c     write (6,3160) (cvm(i),i=1,6)                                         6388
      do 3080 i=1,6                                                         6389
 3080   c(i)=cvm(i)                                                         6390
      if (ivm.ne.0) go to 260                                               6391
      go to 3180                                                            6392
c                                                                           6393
c --- no action ---                                                         6394
c                                                                           6395
 3090 j=ind(1)                                                              6396
      do 3100 i=1,nx                                                        6397
 3100   ind(i)=i                                                            6398
      ldst=0                                                                6399
c                                                                           6400
 3110 do 3130 i=1,nx                                                        6401
c                                                                           6402
        if (rf(1,i).lt..00001) go to 3130                                   6403
c restore original sigmas                                                   6404
        do 3120 k=1,13                                                      6405
 3120     rf(ju(k),i)=skd(k,i)                                              6406
 3130 continue                                                              6407
      call htoa (j)                                                         6408
c                                                                           6409
c                                                                           6410
      iop=iopd                                                              6411
      nru=nrud                                                              6412
      nbb=nbd                                                               6413
 3140 icm=icmd                                                              6414
c                                                                           6415
      if (ild.eq.0.or.ngkk.le.0) go to 3150                                 6416
      n=1                                                                   6417
      ild=0                                                                 6418
      go to 2170                                                            6419
 3150 if (ngkk) 3170,3180,3180                                              6420
c                                                                           6421
 3160 write (ioa,4830)                                                      6422
 3170 n=1                                                                   6423
      if (.not.(isr.ne.0.and.r1.eq.0.)) write (ioa,4820)                    6424
c                                                                           6425
c branching ---                                                             6426
c                                                                           6427
 3180 if (jwr.ne.0) call clos (45)                                          6428
      jwr=0                                                                 6429
      nrff=0                                                                6430
      if (ivm.ne.0) go to 3070                                              6431
      call bra (in,io,ioa,ibr,j9,j8,if5)                                    6432
      nexc=0                                                                6433
      jze=0                                                                 6434
      iy=0                                                                  6435
      isf=1                                                                 6436
      nls=0                                                                 6437
      ild=0                                                                 6438
      iun=io                                                                6439
      if (i6(ibr).eq.1) ine=1                                               6440
c                                                                           6441
      if (ilo.gt.0) ilo=ilo+1                                               6442
      if (ilo.ge.3) ilo=0                                                   6443
      isr=0                                                                 6444
      lq=lqq                                                                6445
      iv=ivv                                                                6446
      ibeg=0                                                                6447
      iwr=0                                                                 6448
      nli=1                                                                 6449
      il1=0                                                                 6450
      kim=0                                                                 6451
      msca=0                                                                6452
      flim=flim0                                                            6453
      if (ibr.gt.50) go to 3190                                             6454
      go to (210,850,940,570,630,670,740,720,3200,950,1200,1760,20,1210,    6455
     11210,1210,1210,1210,1210,450,1310,1340,1370,1360,1250,1250,1250,      6456
     21250,1250,1590,1670,1700,1780,1780,1780,1530,3180,1380,1570,1580,     6457
     31410,1450,1500,1500,1520,1550,1540,1560,2150,20),ibr                  6458
 3190 go to (1690,2070,2090,1710,1960,2010,1600,1600,2200,2210,2240,        6459
     12510,3050,2470,2160,2490,2520,2530,2540,2560,2560,2580,2480,2600,     6460
     22550,2620,2540,2630,2610,2610,2610,890,2640,930,1610,2660,2660,       6461
     32660,2660,2660,2660,2660,2660,2660,2660,2660,2660,2660,2660,2660,     6462
     42660,2660,2660,2660,2660,2660,2660,2660,2670,1350,2700,2790,2690,     6463
     52660,2660,2500,3180,2800,2980,3060,900,2870,2920,3040,2870,3000,      6464
     63010,2660,2660,2660,2660,2660,2800,2800,3070,3030),ibr-50             6465
c                                                                           6466
c EN , QU , EX --- END ---                                                  6467
c                                                                           6468
 3200 write (ioa,4330)                                                      6469
      read (in,4440,end=3180) aw                                            6470
      if (law(aw)) go to 3180                                               6471
      if (nnn.eq.0.or.ivr.eq.0) go to 3220                                  6472
      rewind nrr                                                            6473
      nz=nz*nnn                                                             6474
c                                                                           6475
      do 3210 i=1,nz                                                        6476
 3210   read (nrr,4350) tex(1)                                              6477
c                                                                           6478
      write (nrr,4940)                                                      6479
      end file nrr                                                          6480
 3220 if (nu.gt.0) end file nu                                              6481
      write (ioa,4930)                                                      6482
      if (if4.eq.0) return                                                  6483
      nsc=3*nsc                                                             6484
      rewind isl                                                            6485
      do 3230 i=1,nsc                                                       6486
 3230   read (isl,4350)                                                     6487
      write (isl,4940)                                                      6488
      end file isl                                                          6489
      return                                                                6490
c                                                                           6491
c                                                                           6492
c                                                                           6493
 3240 format ('   are you sure (delete all)?')                              6494
 3250 format (' converted to:')                                             6495
 3260 format (' sigmas for radii and camera constant: separated')           6496
 3270 format (' sigmas for radii and camera constant: merged')              6497
 3280 format (' cell parameter file rewound before scans and search')       6498
 3290 format (' search and scans through c. p. file start after the curr    6499
     1ent position')                                                        6500
 3300 format ('   ===== 1st cell parameter set loaded, code: "',a4,'"')     6501
 3310 format ('  1st set read, unit:',i3,', file: ',a20/1x,72('-'))         6502
 3320 format (2x,'ig0, file1:',i4,2x,a20)                                   6503
 3330 format (2x,'ig1,  fdd :',i4,2x,a20)                                   6504
 3340 format (2x,'scratch  :',i4,2x,a20)                                    6505
 3350 format (' not prepared (<',a2,'>)')                                   6506
 3360 format ('  0 = <',a2,'>, >0 = <',a2,'>; <0: no action')               6507
 3370 format (' r1 or r2 = 0, pattern not loaded')                          6508
 3380 format (' fkk? (def.=5., integral=1./(1.+fkk*fom/sum))')              6509
 3390 format (' hexadec. representation (lower case) of xi and yi !')       6510
 3400 format (' r1:',f8.2,', r2:',f8.2,', d1:',f7.4,', d2:',f7.4,', angl    6511
     1e:',f7.2,' : load?')                                                  6512
 3410 format (' hexadecimal number?')                                       6513
 3420 format (70a1)                                                         6514
 3430 format (' shift to stack ("1" to "4") or to rpn memory("5")?',' "0    6515
     1"=no')                                                                6516
 3440 format (4g14.7,', M:',g14.7)                                          6517
 3450 format (' 0: sorted by R, 1: by integral, 2: by V')                   6518
 3460 format (' x0,y0; x1,y1,n1; x2,y2,n2')                                 6519
 3470 format (' imaginary area')                                            6520
 3480 format (' new calibration factors (x,y) (blank: no changes)'/' val    6521
     1ue(x,y)=(r calc. for current cc)/(difference of meter read-out(x,y    6522
     2))'/' which? both =0 or x =1 or y =2')                                6523
 3490 format (/' current values: x:',f10.5,', y:',f10.5,'; <0: x:',f10.     6524
     15,', y:',f10.5)                                                       6525
 3500 format (' x:',f10.5,', y:',f10.5)                                     6526
 3510 format (' apply temporary sigmas?')                                   6527
 3520 format (' temp. err. for camera const.(rel.), radii(rel), angle','    6528
     1(deg.)'/8x,'all zero:',3(f7.3,10x)/10x,'1st <0:',3(f7.3,10x))         6529
 3530 format (17x,3(f7.3,10x))                                              6530
 3540 format (' *** command <',a2,'> disabled in this version ***')         6531
 3550 format (7f10.3)                                                       6532
 3560 format (' two zone axes (1st fixed), max. angle (0=90,<0=180) ','(    6533
     1system:',2a4)                                                         6534
 3570 format (' exclude or (<0) include which number?'/' abs. value >',     6535
     1i3,' : exclude or include all')                                       6536
 3580 format ('  free:    ',20i3)                                           6537
 3590 format (1x,'which number?')                                           6538
 3600 format (i8,' solution(s)')                                            6539
 3610 format (' filename? (def.: a.a);  "." or "," to escape')              6540
 3620 format (2f8.5,f8.4,f8.5,i8)                                           6541
 3630 format (' tilt angle? (< 90.0 deg.)')                                 6542
 3640 format (' lines/screen? def.:',i3,', min.:10, max.:50')               6543
 3650 format (16x,'scale for graph: def.:',i3,', min.: 6, max.: 20, <0:     6544
     11.Lz. omitted'/' character hight/width: screen : def.:',f5.2,',  <    6545
     20: factor'/23x,' printer: def.:',f5.2,/)                              6546
 3660 format (i6,2f8.3)                                                     6547
 3670 format ('  r3 -> r1, r1 -> r2, r2 -> r3, load?')                      6548
 3680 format (6x,' R ',5x,'a',5x,'b',5x,'c     al    be    ga',6x,'x        6549
     1  y      V    int.')                                                  6550
 3690 format (1x,i2,a1,3a4,' ...,',4f7.2,3f8.4)                             6551
 3700 format (1x,' #',4x,'titel',12x,'c.c.   r1     r2     an     d1','     6552
     1     d2      d3')                                                     6553
 3710 format (' WARNING, the pattern might be equivalent to pattern',i3)    6554
 3720 format (' after transformation :')                                    6555
 3730 format (' after interchanging r1 and r2 :')                           6556
 3740 format (' current pattern (d-val.):',2f10.4,f8.2/9x,'pattern',i3,     6557
     16x,':',2f10.4,f8.2,' ,  R :',f6.2)                                    6558
 3750 format (' cancel command?')                                           6559
 3760 format (' no changes')                                                6560
 3770 format (12x,'r1',8x,'r2',8x,'r3',6x,'angle'/' old:',4f10.2/' new:'    6561
     1,4f10.2,/' replace?')                                                 6562
 3780 format (' are you sure? (new pattern will overwrite the current','    6563
     1 one)')                                                               6564
 3790 format (i5,' : scratch file')                                         6565
 3800 format (' high voltage? (def:',f11.0,' V)')                           6566
 3810 format (1x,f11.0,' volt, lambda:',f11.7,' A')                         6567
 3820 format ('  camera constant:',f11.2,' +-',f6.2,' A*mm'/4x,'camera l    6568
     1ength:',f11.0,' +-',f6.0,' mm')                                       6569
 3830 format (' r:',f10.3,' +-',f7.3,',  d:',f10.3,' +-',f7.3)              6570
 3840 format (' r:',f10.3,' +-',f7.3,',  d:',f10.3,' +-',f7.3,', angle:'    6571
     1,f8.3,' +-',f7.3)                                                     6572
 3850 format (' def. err. for camera const.(rel.), radii(rel), angle','(    6573
     1deg.), L0, L1(mm)'/' current values:',5f6.2/10x,'blank:',5f6.2)       6574
 3860 format (' replace sigmas by default sigmas - are you sure?')          6575
 3870 format (3x,'h1 k1 l1   ',a1,'1  h2 k2 l2    ',a1,'2  angle  ',1x,     6576
     1a4,'   c.',a1,'.  ---- errors ----  R  mul')                          6577
 3880 format ('  obs.:',4x,f6.2,9x,f7.2,f6.1,2f7.1,' ang. r1/r2% c.',a1,    6578
     1'.%'/1x,78('-'))                                                      6579
 3890 format (' ')                                                          6580
 3900 format (38x,'wl.:',f10.6)                                             6581
 3910 format (5x,'mean  R :',f8.3/)                                         6582
 3920 format (i4,f6.2,3f6.2,f7.1,2f6.1,2f7.3,f8.1,f6.2)                     6583
 3930 format (' cont.?')                                                    6584
 3940 format (1x,4f8.2,2f7.2,3x,a1,a10,' V(',a1,'):',f9.1)                  6585
 3950 format (1x,3f8.3,1x,3f7.2,3x,a1,a10,' V(',a1,'):',f9.1)               6586
 3960 format (1x,'parallel output to protocol file 1, finish with ',a2)     6587
 3970 format (' filename? def.: ',a20,';  "." or "," to escape')            6588
 3980 format (a20)                                                          6589
 3990 format (1x,'parallel output finished')                                6590
 4000 format (1x,'L0:',f8.1,' +-',f5.1,' mm, HV:',f12.0,' V, phi:',f5.1)    6591
 4010 format (1x,'L0:',f8.1,'+-',f5.1,', L1',a1,f6.1,'+-',f4.1,', V(',      6592
     1a1,')',a1,f8.1,',',f11.0,'V, phi:',f5.1)                              6593
 4020 format (2x,'L0:',f8.1,'+-',f5.1,', L1',a1,f6.1,'+-',f4.1,', V(',      6594
     1a1,')',a1,f8.1,', V(',a1,')',a1,f8.1,',',f10.0,'V'/' phi:',f8.1)      6595
 4030 format (1x,'>0: identfier and title only; rewind: ',a1)               6596
 4040 format (19a4)                                                         6597
 4050 format (' file',i3,' not(!) rewound')                                 6598
 4060 format (/' break<',a2,'>  mult.<',a2,'> output<',a2,'> rewind<',      6599
     1a2,',',a2,'>, limits<',a2,'>   V'/2x,a5,'<',i1,'>',i7,5x,a5,'<',      6600
     2i1,'>',6x,a1,14x,i1,f11.0,' -',f8.0/)                                 6601
 4070 format (' pattern stored')                                            6602
 4080 format (2x,'SAD data file: unit',i3,', file: ',a20,',',i6,' sets')    6603
 4090 format (2x,'1st set loaded'/1x,72('-')/)                              6604
 4100 format (' store pattern (',a4,'...) ?')                               6605
 4110 format (' reset to default conditions - are you sure?')               6606
 4120 format (' number of solution? (def.=1, max.:',i4,')')                 6607
 4130 format (' protocol: 0: complete, 1: short, >1: none')                 6608
 4140 format (' multiplicity',i2,' ok?')                                    6609
 4150 format (' * last SAD data overwritten *')                             6610
 4160 format (' not prepared (<',a2,'>) or parameters changed since last    6611
     1 <',a2,'>')                                                           6612
 4170 format ('  mult.<',a2,'>:',i2,'; <',a2,'>:',i2,';  1st layer: V:',    6613
     1f6.1,'; n:',i5,'; p:',f7.3/'  ok?')                                   6614
 4180 format (1x,'***',i3,' solutions in C-memory, delete? ("n" will fal    6615
     1sify int.!)')                                                         6616
 4190 format (i4,'   R :',f7.2,', xyz:',3f10.5/6f8.2,f10.1/'P')             6617
 4200 format (' no solution from <',a2,'> in C-memory')                     6618
 4210 format (/1x,i8,' solutions stored, ',a3,':',f9.2,' - ',f6.2,', inc    6619
     1l. equiv.:',i10)                                                      6620
 4220 format (' break for <',a2,'>,<',a2,'>:'/' 0 or 1: after each match    6621
     1'/' 2: none')                                                         6622
 4230 format ((4x,5(i3,': ',a2,i2,' ;  ')))                                 6623
 4240 format (' upper limits for equivalence of angles and ratios of ','    6624
     1axis lengths in <',a2,'>:'/'    def.:',f6.1,2x,f6.3/'  current:',     6625
     2f6.1,2x,f6.3)                                                         6626
 4250 format (f8.1,f8.3)                                                    6627
 4260 format (' Nothing to be loaded. Possibly modification of data'/' (    6628
     1load directly after exit from <',a2,'>); or improper indices')        6629
 4270 format (' load? :c.c.',8x,'r1',8x,'r2',8x,'r3',5x,'angle',4x,'r(Lz    6630
     10)  r(Lz1-0)'/f12.2,6f10.2)                                           6631
 4280 format (' zone axes output: ',a1)                                     6632
 4290 format (' X-ray wavelength? (def.:',f12.6,' , max: 50.)'/20x,'<0 :    6633
     1 camera constant (scales ring diameter to cm)')                       6634
 4300 format ('   * : differs from default setting ')                       6635
 4310 format (2x,a2,4x,':',i3,a1/2x,a2,4x,':',2(i3,a1),/2x,a2,4x,':',i3,    6636
     1a1,/2x,a2,4x,':',i3,a1,/2x,a2,4x,':',i3,a1,/2(2x,a2),': ',a2,a1,/     6637
     22(2x,a2),': ',a2,a1,/2(2x,a2),': ',a2,a1)                             6638
 4320 format (2(2x,a2,4x,':',3(f6.2,a1)/),2x,a2,4x,':',2(f6.2,a1)/2(2x,     6639
     1a2),':',2(f6.2,a1)/2x,a2,4x,':',f6.2,a1)                              6640
 4330 format (' exit?')                                                     6641
 4340 format (1x,'comment for SAD pattern')                                 6642
 4350 format (19a4)                                                         6643
 4360 format (1x,'input unit for lattice constants? (',i2,'-',i2,', 0=',    6644
     1i2,'(keyboard), <0=',i2,')')                                          6645
 4370 format (1x,'name?  (blank : next (if rewound: first) set; "." or',    6646
     1' "," to escape)')                                                    6647
 4380 format (1x,'end of file; file',i3,' rewound: ',a20)                   6648
 4390 format (1x,'name "',a4,'" not found;',i8,'. (last) set: "',a4,'"')    6649
 4400 format (1x,'lattice constants ? (Angstroem, degree), A<0: recipr.'    6650
     1,', 0: file')                                                         6651
 4410 format (1x,'*** imaginary or zero volume ***')                        6652
 4420 format (1x,'dir.lc.:',3f9.4,3f7.2,', V(',a1,'):',f8.1,1x,a4/1x,'re    6653
     1c.lc.:',3f9.6,3f7.2,', SG. ',a1,a10)                                  6654
 4430 format (1x,'centering (col.1) (or space group)? (',6(a1,','),a1,')    6655
     1')                                                                    6656
 4440 format (a1,a10)                                                       6657
 4450 format (1x,'space group: ',a1,a10)                                    6658
 4460 format (1x,'camera constant, delta(def.:',f4.1,'%) ? (<0: camera l    6659
     1ength, delta)'/18x,'blank: data from file')                           6660
 4470 format (1x,'lower limit restricted to',f8.2)                          6661
 4480 format (1x,'weights for angle(deg.), r1/r2(%), c.c.(%) ,',' def.:'    6662
     1,3f5.2)                                                               6663
 4490 format (1x,'max. number of displayed solutions (<',i3,'), def.:',     6664
     1i4/10x,'<0 : skip check for equivalence')                             6665
 4500 format (i7,i5)                                                        6666
 4510 format (1x,'radius',i2,'. reflection (<0: d), delta(def.:',f4.1,'%    6667
     1), mult.(def.:1)')                                                    6668
 4520 format (1x,'radius refl.(r1-r2)(<0:d), delta(def.:',f4.1,'%),mult.    6669
     1','(def.:1)'/14x,'and optionally r1+r2, delta, mult. (one line)')     6670
 4530 format (1x,'radius',i2,'. reflection (<0: d), mult.(def.:1), delta    6671
     1(def.:',f4.1,'%)')                                                    6672
 4540 format (1x,'radius refl.(r1-r2)(<0:d),mult.(def.:1), delta(def.:',    6673
     1f4.1,'%)'/14x,'and optionally r1+r2, mult., delta (one line)')        6674
 4550 format (1x,'angle, delta(def.:',f4.1,' deg.)'/1x,'blank for calcul    6675
     1ation from r3 = r1-r2 (and r1+r2)')                                   6676
 4560 format (1x,'*** R3 (',f8.2,') impossible, range is:',f8.2,' < R3 <    6677
     1',f8.2)                                                               6678
 4570 format (19a4)                                                         6679
 4580 format (2x,': *** ',17a4)                                             6680
 4590 format (/1x,i4,' solution(s)  of',i11)                                6681
 4600 format (1x,'*** NO SOLUTION ***')                                     6682
 4610 format (1x,'***problem too large; lower sigmas')                      6683
 4620 format (5x,'perhaps <',a2,'> and then <',a2,'> will do')              6684
 4630 format (1x,a5,'?  <0 : reciprocal')                                   6685
 4640 format (1x,'** r1 and r2 interchanged')                               6686
 4650 format (1x,'rhombohedral transformed to trig. R-centered')            6687
 4660 format (1x,'max. multiple of primitive mesh (def:2, <0:infin.)'/      6688
     11x,'max. multiple for ',a2,' (def:',i2,', max.: 2)')                  6689
 4670 format (1x,'rigid limits for r1, r2, c.c. ? (0=yes, 1=no)')           6690
 4680 format (1x,'sigma(',a2,') ? (<0 : rel.; def.:',f6.3,'(=',f4.1,'%))    6691
     1')                                                                    6692
 4690 format (1x,'sigma(',a2,') ? (def.:',f5.2,')')                         6693
 4700 format (1x,75('-')/)                                                  6694
 4710 format (1x,'**',i5,' ** ',19a4)                                       6695
 4720 format (1x,a2,i5,' ** ',19a4)                                         6696
 4730 format (1x,'**',i3,a1,' ** ',19a4)                                    6697
 4740 format (1x,'number(s) (from  to) ? (0 : ',i4,' -',i4,')'/'    1st     6698
     1< or = 0: title+data, 2nd <0: number of sets')                        6699
 4750 format (1x,'only',i5,' data sets in file')                            6700
 4760 format (1x,'consec. # of data set? 0 or <0: next set (',i4,' )')      6701
 4770 format (6f9.4/4f9.4,3f9.2/4f9.2,f9.0)                                 6702
 4780 format (1x,'no data')                                                 6703
 4790 format (1x,'already data in file',i3,'?')                             6704
 4800 format (1x,'I/O-unit for reflexion data? allowed ',i3,' -',i3)        6705
 4810 format (1x,'file',i3,' rewound: ',a20)                                6706
 4820 format (1x,'* no action *')                                           6707
 4830 format (1x,'r1 or r2 = 0.')                                           6708
 4840 format (1x,'high voltage(V) or (<0) lambda(A) (def.:',f9.0,' V)')     6709
 4850 format (1x,f10.0,' volt, lambda:',f10.7,' A , camera length:',f10.    6710
     12)                                                                    6711
 4860 format (4x,'radius 0. Laue zone (mm), sigma (def.:',f5.1,')'/' or     6712
     1<0: tilt angle (deg.), sigma (def.:',f5.1,')')                        6713
 4870 format (1x,'** modified: ',a2,' = ',f5.1,', <',a2,'> and <',a2,'>'    6714
     1)                                                                     6715
 4880 format (8x,'L1',a1,f12.1,',',7x,'rej(L1): ',a1,',  rej(V): ',a1,',    6716
     1 sigma(V):',f6.1,'%')                                                 6717
 4890 format (1x,'L1 - L0 (<0: d), sigma ?(def.:',f5.1,')'/9x,'3rd value    6718
     1 not equal 0: 1st value is minimum for L1-L0')                        6719
 4900 format (1x,'maximum accepted dev. of volume (%)? (def.:',f6.1,')')    6720
 4910 format (1x,5(f7.2,'+-',f5.2,',')/1x,2(f7.1,'+-',f5.1,','),f13.0,',    6721
     1',f9.0,f7.1,f7.1,f12.0)                                               6722
 4920 format (1x,'cancel <',a2,'> ?')                                       6723
 4930 format (1x,'*** END ***')                                             6724
 4940 format ('END$')                                                       6725
 4950 format (40x,'L0:',f6.1,10x,i5,'kV')                                   6726
 4960 format (3x,'L0:',f9.2,',',i5,'kV')                                    6727
 4970 format (1x,'file for lattice constants not assigned <',a2,'>')        6728
 4980 format (1x,'*** ',3a4,'...: centering ',a1,' for ',a4,' not permit    6729
     1ted   ***'/18x,'*** first apply Delaunay reduction (',a2,')  ***')    6730
 4990 format (1x,'maximum number of best solutions to be output')           6731
 5000 format (1x,'*** imaginary or zero volume ***',2x,a4/1x,75('='))       6732
 5010 format (1x,75('=')/)                                                  6733
 5020 format (1x,'delete #? (<0 : all)')                                    6734
 5030 format (1x,i3,' is empty')                                            6735
 5040 format (1x,' # of solutions to be echoed? (def.: 0)')                 6736
 5050 format (1x,'  data at pos.',20i3)                                     6737
 5060 format (1x,' memory A full, override which set (max.:',i2,')?')       6738
 5070 format ('  excluded:',20i3)                                           6739
 5080 format (4x,f6.2,1x,3f7.2,f7.1,2f6.1,1x,2f6.3,f8.1)                    6740
 5090 format (2f12.4,3f9.5)                                                 6741
 5100 format (/30x,i8,' equivalent solution(s) not listed')                 6742
 5110 format (' use the value as ',a2,'?')                                  6743
 5120 format (' cell parameters from scratch file (read/write): ',a20)      6744
 5130 format (' no match, scan finished')                                   6745
 5140 format (i4,17a4)                                                      6746
      end                                                                   6747
c########## P4 #########                                                    6748
c #######======= 043                                                        6749
      function rr33 (r1,r2,fak,wi)                                          6750
c  r3 aus r1,r2,wi (Cosinussatz)                                            6751
      rr33=sqrt(r1*r1+r2*r2-2.*r1*r2*cos(fak*wi))                           6752
      return                                                                6753
      end                                                                   6754
c #######======= 044                                                        6755
      subroutine zo (ie,ihot,fakr,cd,dg,dgw,rs,rs0,dg0,dgw0,rs00,rs000,     6756
     1ila0,ihon,jsm)                                                        6757
c set up goniometer settings for reference zones                            6758
      parameter (jj4=20)                                                    6759
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    6760
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       6761
     2jfw                                                                   6762
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     6763
      common /zone/ izo(3),zoo(3,3),gow(2,3)                                6764
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      6765
      common /b/ ii,jj,ila,ke,nq(jj4)                                       6766
      common /wis/ a1(48),a2(48),a3(48),wn(48),nn                           6767
      common /cm12/ be01,be00,rbe1,rbe0                                     6768
      dimension cd(6), sb(2), dg(6), dgw(3), dg0(6), dgw0(3), jsm(7)        6769
      character*1 aw,sb,jsm                                                 6770
      character*5 sb0(2)                                                    6771
c!!!!  TIDY                                                                 6772
c      character*10 rs,rs0,rs00,rs000                                       6773
      character rs*10,rs0*10,rs00*10,rs000*10                               6774
      logical law                                                           6775
      data sb/'-','+'/                                                      6776
      data sb0/'alpha',' beta'/                                             6777
c                                                                           6778
      if (izo(1).ne.0.or.izo(2).ne.0.or.izo(3).ne.0) go to 20               6779
      do 10 i=1,3                                                           6780
        dgw0(i)=dgw(i)                                                      6781
   10   dg0(i)=dg(i)                                                        6782
      rs00=rs                                                               6783
      rs000=rs0                                                             6784
      ila0=ila                                                              6785
      go to 60                                                              6786
c                                                                           6787
   20 do 30 i=1,3                                                           6788
        if (abs(dg(i)-dg0(i)).gt.0.05.or.abs(dgw(i)-dgw0(i)).gt.0.1) go     6789
     1   to 40                                                              6790
   30 continue                                                              6791
      go to 60                                                              6792
c                   dg: current, dg0: Matrix                                6793
   40 write (ioa,260) (dg(i),i=1,3),dgw,jsm(ila),rs,(dg0(i),i=1,3),dgw0,    6794
     1jsm(ila0),rs00                                                        6795
      read (in,360,end=50) aw                                               6796
      if (law(aw)) go to 50                                                 6797
      write (6,240)                                                         6798
      read (in,360,end=50) aw                                               6799
      if (law(aw)) go to 50                                                 6800
      go to 80                                                              6801
   50 write (ioa,270)                                                       6802
      return                                                                6803
c                                                                           6804
   60 j4=jj4                                                                6805
c                                                                           6806
      ie=0                                                                  6807
c                                                                           6808
      d0=be0                                                                6809
      if (ihot.eq.2) d0=al0                                                 6810
c                                                                           6811
c   Orientierungmatrix ######                                               6812
      write (ioa,330) (i,sb(izo(i)+1),(zoo(j,i),j=1,3),gow(1,i),gow(2,i)    6813
     1,i=1,3)                                                               6814
      write (ioa,340)                                                       6815
      call les (in)                                                         6816
      if (n.eq.0.or.ndi(1).gt.mdi) go to 230                                6817
      i=c(1)                                                                6818
      if (i.eq.0.or.i.gt.3) go to 230                                       6819
      if (i.lt.3) go to 70                                                  6820
      if (izo(1)+izo(2).eq.2) go to 70                                      6821
      write (ioa,250)                                                       6822
      return                                                                6823
   70 if (i.gt.0) go to 100                                                 6824
      write (ioa,300)                                                       6825
      read (in,360,end=160) aw                                              6826
c?                                                                          6827
      if (law(aw)) go to 160                                                6828
   80 do 90 j=1,3                                                           6829
        izo(j)=0                                                            6830
        zoo(1,j)=0.                                                         6831
        zoo(2,j)=0.                                                         6832
        zoo(3,j)=0.                                                         6833
        gow(1,j)=0.                                                         6834
   90   gow(2,j)=0.                                                         6835
      write (ioa,410)                                                       6836
      ie=0                                                                  6837
      return                                                                6838
c                                                                           6839
  100 write (ioa,350)                                                       6840
      read (in,360,end=210) aw                                              6841
      if (law(aw)) write (ioa,310)                                          6842
      if (.not.law(aw)) write (ioa,320)                                     6843
      call les (in)                                                         6844
      if (n.eq.0.) go to 230                                                6845
      if (c(1).eq.0..and.c(2).eq.0..and.c(3).eq.0.) go to 150               6846
cccc                                                                        6847
      if (law(aw)) go to 110                                                6848
      i4=c(4)                                                               6849
      if (rf(1,i4).lt..001.or.rf(25,i4).eq.0.) go to 220                    6850
ccccc                                                                       6851
  110 izo(i)=1                                                              6852
      zoo(1,i)=c(1)                                                         6853
      zoo(2,i)=c(2)                                                         6854
      zoo(3,i)=c(3)                                                         6855
      if (izo(1)+izo(2)+izo(3).ne.3) go to 120                              6856
c Matrix komplett                                                           6857
      dd=det(zoo)                                                           6858
      if (abs(dd).gt..3) go to 120                                          6859
      write (ioa,290) c(1),c(2),c(3)                                        6860
      go to 150                                                             6861
c                                                                           6862
  120 if (izo(1).eq.0.or.izo(2).eq.0) go to 130                             6863
      if ((zoo(2,1)*zoo(3,2)-zoo(2,2)*zoo(3,1))**2+(zoo(3,1)*zoo(1,2)-      6864
     1zoo(3,2)*zoo(1,1))**2+(zoo(1,1)*zoo(2,2)-zoo(1,2)*zoo(2,1))**2.gt.    6865
     20.3) go to 130                                                        6866
c 2 identische Zonen                                                        6867
      write (ioa,280)                                                       6868
      go to 150                                                             6869
c                                                                           6870
  130 if (.not.law(aw)) go to 140                                           6871
      gow(1,i)=c(4)                                                         6872
      gow(2,i)=c(5)                                                         6873
      if (ihon.eq.3) gow(2,i)=be01*c(5)+be00                                6874
      go to 160                                                             6875
  140 j=c(4)                                                                6876
      if (j.lt.1.or.j.gt.j4) go to 230                                      6877
      if (rf(1,j).lt..001.or.rf(25,j).eq.0.) go to 220                      6878
      gow(1,i)=rf(23,j)                                                     6879
      gow(2,i)=rf(24,j)                                                     6880
      go to 160                                                             6881
c                                                                           6882
  150 izo(i)=0                                                              6883
      zoo(1,i)=0.                                                           6884
      zoo(2,i)=0.                                                           6885
      zoo(3,i)=0.                                                           6886
      gow(1,i)=0.                                                           6887
      gow(2,i)=0.                                                           6888
  160 write (ioa,330) (i,sb(izo(i)+1),(zoo(j,i),j=1,3),gow(1,i),gow(2,i)    6889
     1,i=1,3)                                                               6890
cioioio                                                                     6891
c iou=88                                                                    6892
      if (ifu.gt.0) write (iou,330) (i,sb(izo(i)+1),(zoo(j,i),j=1,3),       6893
     1gow(1,i),gow(2,i),i=1,3)                                              6894
c                                                                           6895
  170 if (izo(1)+izo(2)+izo(3).gt.1) write (ioa,370) sb0(ihot),d0           6896
      dm=0.                                                                 6897
      do 200 i=1,2                                                          6898
        if (izo(i).eq.0) go to 200                                          6899
        do 190 j=i+1,3                                                      6900
          if (izo(j).eq.0) go to 190                                        6901
          w=zwi(gow(1,i),gow(2,i),gow(1,j),gow(2,j),ihot,al0,be0)           6902
          do 180 k=1,3                                                      6903
            c(k)=zoo(k,i)                                                   6904
  180       c(k+3)=zoo(k,j)                                                 6905
          call cz (ila,0,cd,fakr,90.,io,ioa,1,limax,in)                     6906
          d=w-wn(1)                                                         6907
c  obs-calc Winkel zwischen Zonen                                           6908
          write (ioa,380) i,j,w,wn(1),d                                     6909
cioioio                                                                     6910
          if (ifu.gt.0) write (88,380) i,j,w,wn(1),d                        6911
          dm=amax1(dm,abs(d))                                               6912
  190   continue                                                            6913
  200 continue                                                              6914
      if (dm.gt.5.) write (ioa,400) sb0(ihot),d0,dg(1),dg(2),dg(3),dgw,     6915
     1dm                                                                    6916
  210 return                                                                6917
  220 write (ioa,390)                                                       6918
  230 ie=1                                                                  6919
      go to 170                                                             6920
c                                                                           6921
c                                                                           6922
c                                                                           6923
  240 format ('   are you sure?')                                           6924
  250 format ('  **** first define both zones 1 and 2 ****')                6925
  260 format (' current:',3f9.3,3f8.2,2x,a1,a10/' matrix :',3f9.3,3f8.2,    6926
     12x,a1,a10/20x,'delete matrix?')                                       6927
  270 format (' ** matrix not deleted, load cell parameters "matrix" **'    6928
     1)                                                                     6929
  280 format (2x,31('*')/'  *** zones 1 and 2 identical ***'/2x,31('*'))    6930
  290 format (2x,57('*')/'  ***** zone',3f5.1,' not suited (determ. = 0.    6931
     1) *****'/2x,57('*'))                                                  6932
  300 format (' clear all zones?')                                          6933
  310 format (' zone (u,v,w), goniometer angles beta, alpha',' (0,0,0 or    6934
     1 blank to clear)')                                                    6935
  320 format (' zone (u,v,w), #  of data set in memory A',' (0,0,0 or bl    6936
     1ank to clear)')                                                       6937
  330 format ('   #       u     v     w    beta    alpha'/(i4,2x,a1,3f6.    6938
     11,2f8.3))                                                             6939
  340 format (' which number? <0 clears all data, 0 or blank to escape')    6940
  350 format (' get angles from mem. A?')                                   6941
  360 format (a1)                                                           6942
  370 format ('  angles: zones   obs.  calc.   dif.,  ',a5,'(0):',f5.1)     6943
  380 format (9x,2i3,3f7.2)                                                 6944
  390 format (' no goniometer data')                                        6945
  400 format (' *** serious discrepancies :  ',a5,'(0):',f5.1/' current     6946
     1cell parameters:',4f8.2,2f7.2/' max. deviation:',f5.1)                6947
  410 format (' matrix deleted')                                            6948
      end                                                                   6949
c #######======= 045                                                        6950
      subroutine uvwgen (cd,fakr,dg,dgw,rs,ihoz,dg0,dgw0,rs00,ila0,j9,      6951
     1jsm,ie,ihon)                                                          6952
c  determines all zones accessible up to max. alpha, beta, u, v, w          6953
c                                                                           6954
c  ke wird beim Aufruf auf 0 gesetzt, danach wieder auf den alten Wert      6955
c                                                                           6956
      parameter (jj4=20,jj0=48,jj3=140)                                     6957
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    6958
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       6959
     2jfw                                                                   6960
      common /zone/ izo(3),zoo(3,3),gow(2,3)                                6961
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     6962
      common /b/ ii,jj,ila,ke,nq(jj4)                                       6963
      common /wis/ a1(48),a2(48),a3(48),wn(48),nn                           6964
      common /cm12/ be01,be00,rbe1,rbe0                                     6965
      common /uvw/ mmu,mmv,mmw,wimb,wima,wmx1,wmx2,aaq1,aaq2,aaq3,iaq       6966
      dimension cd(6), zz(3), rr(2), p1(jj0), p2(jj0), p3(jj0), pa(jj0),    6967
     1 nm(2), xn(2,3), yn(2,3), ik(8), dg(6), dgw(3), dg0(6), dgw0(3)       6968
      dimension j9(jj3), jsm(7)                                             6969
      character*1 aw,jsm                                                    6970
      character rs*10,rs00*10                                               6971
      character j9*2                                                        6972
      logical law                                                           6973
      data wmx,wmx0/170.,60./                                               6974
c                                                                           6975
      do 10 i=1,3                                                           6976
        if (abs(dg(i)-dg0(i)).gt.0.05.or.abs(dgw(i)-dgw0(i)).gt.0.1) go     6977
     1   to 20                                                              6978
   10 continue                                                              6979
      go to 30                                                              6980
   20 write (ioa,100) (dg(i),i=1,3),dgw,jsm(ila),rs,(dg0(i),i=1,3),dgw0,    6981
     1jsm(ila0),rs00                                                        6982
      read (in,180,end=70) aw                                               6983
      if (.not.law(aw)) go to 30                                            6984
      write (ioa,110)                                                       6985
      return                                                                6986
c                                                                           6987
c                                                                           6988
   30 if (zoo(1,3).ne.0..or.zoo(2,3).ne.0..or.zoo(1,3).ne.0.) go to 40      6989
      write (6,130)                                                         6990
      return                                                                6991
   40 write (6,150)                                                         6992
c                                                                           6993
      call les (in)                                                         6994
      if (n.eq.0) go to 70                                                  6995
c                                                                           6996
      wb=c(4)                                                               6997
      wa=c(5)                                                               6998
      if (wa.eq.0.) wa=wb                                                   6999
      if (wb.eq.0.) go to 80                                                7000
      wb=-wb                                                                7001
      wima=abs(wa)                                                          7002
      wimb=abs(wb)                                                          7003
c                                                                           7004
      iuu=int(abs(c(1)))                                                    7005
      ivv=int(abs(c(2)))                                                    7006
      iww=int(abs(c(3)))                                                    7007
      if (iuu+ivv+iww.eq.0) return                                          7008
      write (6,140)                                                         7009
      nuz=0                                                                 7010
      nli=1                                                                 7011
c                                                                           7012
      do 60 mmw=0,iww                                                       7013
        ivvv=-ivv                                                           7014
        if (mmw.eq.0) ivvv=0                                                7015
c                                                                           7016
        do 60 mmv=ivvv,ivv                                                  7017
c                                                                           7018
        do 60 mmu=-iuu,iuu                                                  7019
        if (mmu.le.0.and.mmv.eq.0.and.mmw.eq.0) go to 60                    7020
        kgt=igt(mmu,mmv,mmw)                                                7021
        if (kgt.gt.1) go to 60                                              7022
        iaq=0                                                               7023
        call ab1 (cd,fakr,dg,dgw,rs,ihoz,dg0,dgw0,rs00,ila0,j9,jsm,ie,      7024
     1   ihon,1)                                                            7025
        if (iaq.eq.0) go to 60                                              7026
        if (wb.lt.0.) go to 50                                              7027
        write (6,160) mmu,mmv,mmw,aaq1,aaq2,aaq3                            7028
        nuz=nuz+1                                                           7029
        read (5,180,end=70) aw                                              7030
        if (law(aw)) go to 70                                               7031
        go to 60                                                            7032
c                                                                           7033
   50   write (6,170) mmu,mmv,mmw,aaq1,aaq2,aaq3                            7034
        nuz=nuz+1                                                           7035
        nli=nli+1                                                           7036
        if (nli.lt.limax) go to 60                                          7037
        nli=1                                                               7038
        write (6,190)                                                       7039
        read (5,180) aw                                                     7040
        if (law(aw)) return                                                 7041
   60 continue                                                              7042
      if (nuz.eq.0) write (6,120) wimb,wima                                 7043
   70 return                                                                7044
   80 write (6,90)                                                          7045
      return                                                                7046
c                                                                           7047
c                                                                           7048
c                                                                           7049
   90 format (' *** beta must not be 0.0 ***')                              7050
  100 format (' current:',3f9.3,3f8.2,2x,a1,a10/' matrix :',3f9.3,3f8.2,    7051
     12x,a1,a10/20x,'delete matrix?')                                       7052
  110 format (' ** matrix not deleted, load cell parameters "matrix" **'    7053
     1)                                                                     7054
  120 format (' no zones below beta=',f4.1,' deg, alpha=',f4.1,' deg.')     7055
  130 format (' **** 3rd orientation determining zone is missing ****')     7056
  140 format ('    u   v   w    beta   alpha    error'/1x,37('-'))          7057
  150 format (' u(max),v(max),w(max);'/'  max(beta)(<0: break after each    7058
     1 zone)'/'   max(alpha)(if 0: max(alpha)=max(beta)  (one line)')       7059
  160 format (1x,3i4,2f8.2,f9.3,'    cont.?')                               7060
  170 format (1x,3i4,2f8.2,f9.3)                                            7061
  180 format (a1)                                                           7062
  190 format ('  cont.?')                                                   7063
      end                                                                   7064
c####                                                                       7065
c                                                                           7066
c #######======= 046                                                        7067
      subroutine ab1 (cd,fakr,dg,dgw,rs,ihot,dg0,dgw0,rs00,ila0,j9,jsm,     7068
     1ie,ihon,i321)                                                         7069
c  calculates goniometer settings for a given zone                          7070
c ie?                                                                       7071
      parameter (jj4=20,jj0=48,jj3=140)                                     7072
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    7073
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       7074
     2jfw                                                                   7075
      common /zone/ izo(3),zoo(3,3),gow(2,3)                                7076
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     7077
      common /b/ ii,jj,ila,ke,nq(jj4)                                       7078
      common /wis/ a1(48),a2(48),a3(48),wn(48),nn                           7079
      common /cm12/ be01,be00,rbe1,rbe0                                     7080
      common /uvw/ mmu,mmv,mmw,wimb,wima,wmx1,wmx2,aaq1,aaq2,aaq3,iaq       7081
      dimension cd(6), zz(3), rr(2), p1(jj0), p2(jj0), p3(jj0), pa(jj0),    7082
     1 nm(2), xn(2,3), yn(2,3), ik(8), dg(6), dgw(3), dg0(6), dgw0(3)       7083
      dimension j9(jj3), jsm(7)                                             7084
      character*1 aw,jsm                                                    7085
      character rs*10,rs00*10                                               7086
      character j9*2                                                        7087
      logical law                                                           7088
      data wmx,wmx0/170.,60./                                               7089
c                                                                           7090
c !!!!!   ################   kj  ???  ############                          7091
c                                                                           7092
c i321=0: normal, i321=1: uvwgen                                            7093
      fak=1./fakr                                                           7094
      wmxx=.5*wmx                                                           7095
      if (i321.eq.0) go to 10                                               7096
c                                                                           7097
      wmx1=wimb                                                             7098
      wmx2=wima                                                             7099
      if (wimb.gt.0.) wmx1=amin1(wimb,wmxx)                                 7100
      if (wima.gt.0.) wmx2=amin1(wima,wmxx)                                 7101
      kj=1                                                                  7102
c ...  kj=4 ?                                                               7103
      ij0=jj0                                                               7104
      c(1)=mmu                                                              7105
      c(2)=mmv                                                              7106
      c(3)=mmw                                                              7107
      ij0=jj0                                                               7108
      al1=gow(1,1)                                                          7109
      be1=gow(2,1)                                                          7110
      al2=gow(1,2)                                                          7111
      be2=gow(2,2)                                                          7112
      go to 70                                                              7113
   10 ij=0                                                                  7114
      irh=0                                                                 7115
      if (ke.eq.2.and.ila.eq.5) irh=1                                       7116
c                                                                           7117
      do 20 i=1,3                                                           7118
        if (abs(dg(i)-dg0(i)).gt.0.05.or.abs(dgw(i)-dgw0(i)).gt.0.1) go     7119
     1   to 390                                                             7120
   20 continue                                                              7121
      kj=1                                                                  7122
c ...  kj=4 ?                                                               7123
c      wmxx=.5*wmx                                                          7124
      ij0=jj0                                                               7125
      al1=gow(1,1)                                                          7126
      be1=gow(2,1)                                                          7127
      al2=gow(1,2)                                                          7128
      be2=gow(2,2)                                                          7129
      write (ioa,530) dg(1),dg(2),dg(3),dgw                                 7130
c                                                                           7131
   30 isen=0                                                                7132
   40 if (isen.eq.0) go to 60                                               7133
      if (irh.eq.0) go to 60                                                7134
      if (c3.eq.0.) go to 60                                                7135
      if (abs(amod(c1+c2,3.)).gt..1) go to 60                               7136
      if (abs(c1*c2).lt..01) go to 60                                       7137
      if (c1.eq.c2) go to 60                                                7138
      if (abs(amod(c1,3.)).gt..5.and.abs(amod(c3,3.)).lt..5) go to 50       7139
      if (abs(amod(c1,3.)).lt..5) go to 50                                  7140
      go to 60                                                              7141
c                                                                           7142
   50 c3=-c3                                                                7143
      ihh1=iint(c1)                                                         7144
      ihh2=iint(c2)                                                         7145
      ihh3=iint(c3)                                                         7146
      write (ioa,550) ihh1,ihh2,ihh3                                        7147
      isen=0                                                                7148
      read (in,440,end=30) aw                                               7149
      if (law(aw)) go to 30                                                 7150
      c(1)=c1                                                               7151
      c(2)=c2                                                               7152
      c(3)=c3                                                               7153
      go to 80                                                              7154
c                                                                           7155
   60 if (kj.ne.1) write (ioa,540)                                          7156
      write (ioa,500) wmx0,wmxx                                             7157
      call les (in)                                                         7158
      if (n.eq.0.or.ndi(1).gt.mdi) go to 400                                7159
      if (abs(c(1))+abs(c(2))+abs(c(3)).eq.0.) go to 400                    7160
      isen=1                                                                7161
      wmx1=wmx0                                                             7162
      if (c(4).gt.0.) wmx1=amin1(c(4),wmxx)                                 7163
      wmx0=wmx1                                                             7164
      c(11)=igt(int(c(1)),int(c(2)),int(c(3)))                              7165
      c(1)=c(1)/c(11)                                                       7166
      c(2)=c(2)/c(11)                                                       7167
      c(3)=c(3)/c(11)                                                       7168
   70 c1=c(1)                                                               7169
      c2=c(2)                                                               7170
      c3=c(3)                                                               7171
   80 zz(1)=c(1)                                                            7172
      zz(2)=c(2)                                                            7173
      zz(3)=c(3)                                                            7174
      nl=0                                                                  7175
      nz=1                                                                  7176
      j0=0                                                                  7177
      if (i321.eq.0) write (ioa,460)                                        7178
      if (i321.eq.0) write (ioa,490)                                        7179
      nl=nl+2                                                               7180
c                                                                           7181
   90 if (nl.lt.limax-4) go to 100                                          7182
      write (ioa,430)                                                       7183
      read (in,440,end=40) aw                                               7184
      if (law(aw)) go to 40                                                 7185
      nl=0                                                                  7186
  100 do 110 i=1,3                                                          7187
  110   c(i+3)=c(i)                                                         7188
      do 140 kk=1,2                                                         7189
        do 120 i=1,3                                                        7190
  120     c(i)=zoo(i,kk)                                                    7191
        call cz (ila,ke,cd,fakr,wmx,io,ioa,1,limax,in)                      7192
        if (kk.eq.2) go to 140                                              7193
        if (nn.eq.0) go to 380                                              7194
        nn=min0(ij0,nn)                                                     7195
        do 130 i=1,nn                                                       7196
          p1(i)=a1(i)                                                       7197
          p2(i)=a2(i)                                                       7198
          p3(i)=a3(i)                                                       7199
  130     pa(i)=wn(i)                                                       7200
c nn=0? (kk=2)                                                              7201
  140   nm(kk)=nn                                                           7202
c                                                                           7203
      nzz=0                                                                 7204
      do 160 i=1,nm(1)                                                      7205
        ii=i                                                                7206
        do 150 k=1,nm(2)                                                    7207
          kk=k                                                              7208
          if (abs(p1(i)-a1(k)).gt..001.or.abs(p2(i)-a2(k)).gt..001.or.      7209
     1     abs(p3(i)-a3(k)).gt..001) go to 150                              7210
          nzz=nzz+1                                                         7211
          if (nz.eq.nzz) go to 170                                          7212
  150   continue                                                            7213
  160 continue                                                              7214
      go to 380                                                             7215
c                                                                           7216
  170 hh1=a1(kk)                                                            7217
      hh2=a2(kk)                                                            7218
      hh3=a3(kk)                                                            7219
      rr(1)=pa(ii)                                                          7220
      rr(2)=wn(kk)                                                          7221
c                                                                           7222
      call iza (fak,al1,be1,rr(1),al2,be2,rr(2),xn(1,1),yn(1,1),xn(2,1),    7223
     1yn(2,1),ihot,ie)                                                      7224
      if (ie.gt.0) write (ioa,510)                                          7225
c                                                                           7226
      if (izo(3).ne.0) go to 230                                            7227
      if (ihot.eq.2) go to 180                                              7228
c double tilt                                                               7229
      if ((abs(xn(1,1)).gt.wmx1.or.abs(yn(1,1)).gt.wmx1).and.(abs(xn(2,     7230
     11)).gt.wmx1.or.abs(yn(2,1)).gt.wmx1)) go to 340                       7231
      go to 190                                                             7232
c rotation tilt                                                             7233
  180 if (abs(xn(1,1)).gt.wmx1.and.abs(xn(2,1)).gt.wmx1) go to 340          7234
c                                                                           7235
  190 yyn1=cm14(ihon,yn(1,1))                                               7236
      yyn2=cm14(ihon,yn(2,1))                                               7237
      write (ioa,470) xn(1,1),yyn1                                          7238
      write (ioa,470) xn(2,1),yyn2                                          7239
      if (ihot.ne.2) go to 200                                              7240
      xn(1,1)=-xn(1,1)+2.*al0                                               7241
      xn(2,1)=-xn(2,1)+2.*al0                                               7242
      yn(1,1)=f360(yn(1,1))                                                 7243
      yn(2,1)=f360(yn(2,1))                                                 7244
      write (ioa,450)                                                       7245
      yyn1=cm14(ihon,yn(1,1))                                               7246
      yyn2=cm14(ihon,yn(2,1))                                               7247
      write (ioa,470) xn(1,1),yyn1                                          7248
      write (ioa,470) xn(2,1),yyn2                                          7249
      nl=nl+3                                                               7250
  200 if (amod(hh1,1.).ne.0..or.amod(hh2,1.).ne.0..or.mod(hh3,1.).ne.0.)    7251
     1 go to 210                                                            7252
      ihh1=iint(hh1)                                                        7253
      ihh2=iint(hh2)                                                        7254
      ihh3=iint(hh3)                                                        7255
      write (ioa,480) ihh1,ihh2,ihh3                                        7256
      go to 220                                                             7257
  210 write (ioa,410) hh1,hh2,hh3                                           7258
  220 write (ioa,490)                                                       7259
      nl=nl+4                                                               7260
      j0=1                                                                  7261
      go to 340                                                             7262
c                                                                           7263
  230 do 240 i=1,3                                                          7264
  240   c(i)=zoo(i,3)                                                       7265
      c(4)=a1(kk)                                                           7266
      c(5)=a2(kk)                                                           7267
      c(6)=a3(kk)                                                           7268
      call cz (ila,0,cd,fakr,wmx,io,ioa,1,limax,in)                         7269
      call iza (fak,gow(1,3),gow(2,3),wn(1),al2,be2,rr(2),xn(1,2),yn(1,     7270
     12),xn(2,2),yn(2,2),ihot,ie)                                           7271
      if (ie.gt.0) write (ioa,510)                                          7272
c                                                                           7273
      call iza (fak,gow(1,3),gow(2,3),wn(1),al1,be1,rr(1),xn(1,3),yn(1,     7274
     13),xn(2,3),yn(2,3),ihot,ie)                                           7275
      if (ie.gt.0) write (ioa,510)                                          7276
c                                                                           7277
      dm=100000.                                                            7278
      ij=0                                                                  7279
      do 250 i=1,2                                                          7280
        do 250 j=1,2                                                        7281
        do 250 k=1,2                                                        7282
        ij=ij+1                                                             7283
        a3(ij)=(xn(i,1)-xn(j,2))**2+(yn(i,1)-yn(j,2))**2+(xn(i,1)-xn(k,     7284
     1   3))**2+(yn(i,1)-yn(k,3))**2+(xn(j,2)-xn(k,3))**2+(yn(j,2)-yn(k,    7285
     2   3))**2                                                             7286
        a3(ij)=sqrt(a3(ij))/3.                                              7287
        if (a3(ij).gt.dm) go to 250                                         7288
c                                                                           7289
        a1(ij)=(xn(i,1)+xn(j,2)+xn(k,3))/3.                                 7290
        a2(ij)=(yn(i,1)+yn(j,2)+yn(k,3))/3.                                 7291
  250 continue                                                              7292
c                                                                           7293
      do 260 i=1,8                                                          7294
  260   ik(i)=i                                                             7295
  270 n=0                                                                   7296
      do 280 i=1,7                                                          7297
        if (a3(ik(i)).le.a3(ik(i+1))) go to 280                             7298
        j=ik(i)                                                             7299
        ik(i)=ik(i+1)                                                       7300
        ik(i+1)=j                                                           7301
        n=1                                                                 7302
  280 continue                                                              7303
      if (n.eq.1) go to 270                                                 7304
      ij=0                                                                  7305
c                                                                           7306
      do 330 i=1,kj                                                         7307
        if (ihot.eq.2) go to 290                                            7308
        wawa=wmx1                                                           7309
        if (i321.eq.1) wawa=wmx2                                            7310
        if (abs(a1(ik(i))).gt.wmx1.or.abs(a2(ik(i))).gt.wawa) go to 330     7311
        go to 300                                                           7312
  290   if (abs(a1(ik(i))).gt.wmx1) go to 330                               7313
  300   if (a3(ik(i)).gt.10.) go to 330                                     7314
        yyn1=cm14(ihon,a2(ik(i)))                                           7315
        if (i321.eq.0) write (ioa,470) a1(ik(i)),yyn1,a3(ik(i))             7316
        if (i321.eq.0) go to 310                                            7317
c                                                                           7318
        aaq1=a1(ik(i))                                                      7319
        aaq2=yyn1                                                           7320
        aaq3=a3(ik(i))                                                      7321
        iaq=1                                                               7322
        go to 400                                                           7323
c                                                                           7324
  310   if (ihot.ne.2) go to 320                                            7325
        c(1)=-a1(ik(i))+2.*al0                                              7326
        c(2)=f360(a2(ik(i)))                                                7327
        write (ioa,470) c(1),c(2)                                           7328
        nl=nl+1                                                             7329
  320   nl=nl+1                                                             7330
        j0=1                                                                7331
        ij=ij+1                                                             7332
        if (nl.lt.limax-4) go to 330                                        7333
        write (ioa,430)                                                     7334
        read (in,440,end=400) aw                                            7335
        if (law(aw)) go to 400                                              7336
        nl=0                                                                7337
  330 continue                                                              7338
c                                                                           7339
  340 if (ij.eq.0) go to 370                                                7340
      if (amod(hh1,1.).ne.0..or.amod(hh2,1.).ne.0..or.mod(hh3,1.).ne.0.)    7341
     1 go to 350                                                            7342
      ihh1=iint(hh1)                                                        7343
      ihh2=iint(hh2)                                                        7344
      ihh3=iint(hh3)                                                        7345
      write (ioa,480) ihh1,ihh2,ihh3                                        7346
      go to 360                                                             7347
  350 write (ioa,410) hh1,hh2,hh3                                           7348
  360 write (ioa,490)                                                       7349
      nl=nl+2                                                               7350
  370 c(1)=zz(1)                                                            7351
      c(2)=zz(2)                                                            7352
      c(3)=zz(3)                                                            7353
      nz=nz+1                                                               7354
      go to 90                                                              7355
c                                                                           7356
  380 if (i321.eq.1) return                                                 7357
      if (j0.eq.0) write (ioa,520) wmx1                                     7358
      go to 40                                                              7359
c                                                                           7360
  390 write (ioa,420) (dg(i),i=1,3),dgw,jsm(ila),rs,(dg0(i),i=1,3),dgw0,    7361
     1jsm(ila0),rs00,j9(126)                                                7362
  400 return                                                                7363
c                                                                           7364
c                                                                           7365
c                                                                           7366
  410 format (1x,'[',3f6.2,']')                                             7367
  420 format (' current:',3f9.3,3f8.2,2x,a1,a10/' matrix :',3f9.3,3f8.2,    7368
     12x,a1,a10/'*** restore cell parameters or build new',' matrix (<',    7369
     2a2,'>)')                                                              7370
  430 format (' cont.?')                                                    7371
  440 format (a1)                                                           7372
  450 format (' or (equiv.)')                                               7373
  460 format (18x,' beta   alpha   error')                                  7374
  470 format (15x,2f8.2,f8.3)                                               7375
  480 format (1x,'[',3i4,']')                                               7376
  490 format (' ',38('-'))                                                  7377
  500 format (' u, v, w, max.angle (def.=',f5.1,' deg., max.:',f5.1,')')    7378
  510 format ('  no common point')                                          7379
  520 format (' *** no equivalent accessible within +-',f5.1,' deg. ***'    7380
     1/)                                                                    7381
  530 format (' cell parameters:',4f9.2,2f7.2)                              7382
  540 format (' *** determinant = 0, orientation not yet definite ***')     7383
  550 format ('  ****************** try also [',3i4,'] ? (y/n)')            7384
      end                                                                   7385
c #######======= 047                                                        7386
      integer function iint(a)                                              7387
      iint=int(a+.5*sign(1.,a))                                             7388
      return                                                                7389
      end                                                                   7390
c #######======= 048                                                        7391
      function cm14 (ihon,x)                                                7392
c interprets beta tilt depending on goniometer type                         7393
      common /cm12/ be01,be00,rbe1,rbe0                                     7394
      cm14=x                                                                7395
      if (ihon.eq.3) cm14=rbe1*x+rbe0                                       7396
      return                                                                7397
      end                                                                   7398
c #######======= 049                                                        7399
      function f360 (x)                                                     7400
c angle x:  -180 =< x+180(!) =< +180                                        7401
      f360=amod(540.-x,360.)                                                7402
      if (f360.gt.180.) f360=f360-360.                                      7403
      f360=-f360                                                            7404
      return                                                                7405
      end                                                                   7406
c #######======= 050                                                        7407
      subroutine iza (f,al1,be1,r1,al2,be2,r2,a1,b1,a2,b2,ihot,ie)          7408
c  calculates alpha, beta as intersections of two or three circles          7409
c                                                                           7410
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    7411
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       7412
     2jfw                                                                   7413
      a11=al1                                                               7414
      b11=be1                                                               7415
      a21=al2                                                               7416
      b21=be2                                                               7417
      if (ihot.ne.2) go to 10                                               7418
c rotation tilt                                                             7419
      a11=a11-al0                                                           7420
      a21=a21-al0                                                           7421
      call abtoxyr (a11,b11,x,y,f)                                          7422
      go to 20                                                              7423
c double tilt                                                               7424
   10 b11=b11-be0                                                           7425
      b21=b21-be0                                                           7426
      call abtoxy (a11,b11,x,y,f)                                           7427
   20 call xyr (x,y,r1,f,x01,y01,rr1)                                       7428
c                                                                           7429
      if (ihot.ne.2) go to 30                                               7430
c rotation tilt                                                             7431
      call abtoxyr (a21,b21,x,y,f)                                          7432
      go to 40                                                              7433
c double tilt                                                               7434
   30 call abtoxy (a21,b21,x,y,f)                                           7435
   40 call xyr (x,y,r2,f,x02,y02,rr2)                                       7436
c                                                                           7437
      call sec (x01,y01,rr1,x02,y02,rr2,xx1,yy1,xx2,yy2,ie)                 7438
      if (ie.ne.0) return                                                   7439
c                                                                           7440
      if (ihot.eq.1) call xytoab (a1,b1,xx1,yy1,f,be0)                      7441
      if (ihot.eq.2) call xytoabr (a1,b1,xx1,yy1,f,al0)                     7442
c                                                                           7443
      if (ihot.eq.1) call xytoab (a2,b2,xx2,yy2,f,be0)                      7444
      if (ihot.eq.2) call xytoabr (a2,b2,xx2,yy2,f,al0)                     7445
      end                                                                   7446
c #######======= 051                                                        7447
      subroutine xyr (x,y,r1,f,x0,y0,rr1)                                   7448
c calculates x0,y0,radius in cartesian coordinates                          7449
      dd=sqrt(x*x+y*y)                                                      7450
      a0=2.*atan(dd)                                                        7451
      dm=tan(.5*(a0-r1*f))                                                  7452
      dp=tan(.5*(a0+r1*f))                                                  7453
      rr1=.5*(dp-dm)                                                        7454
      d0=.5*(dm+dp)                                                         7455
      if (dd.lt..001) go to 10                                              7456
      x0=x*d0/dd                                                            7457
      y0=y*d0/dd                                                            7458
      return                                                                7459
   10 x0=x                                                                  7460
      y0=y                                                                  7461
      return                                                                7462
      end                                                                   7463
c #######======= 052                                                        7464
      subroutine abtoxyr (a,b,x,y,f)                                        7465
c alpha, beta --> x,y (rotation tilt)                                       7466
c                                                                           7467
      r=tan(.5*a*f)                                                         7468
      x=r*cos(b*f)                                                          7469
      y=r*sin(b*f)                                                          7470
      return                                                                7471
      end                                                                   7472
c #######======= 053                                                        7473
      subroutine abtoxy (a,b,x,y,f)                                         7474
c alpha, beta --> x,y (double tilt)                                         7475
c                                                                           7476
      sa=sign(1.,a)                                                         7477
      sb=sign(1.,b)                                                         7478
      a=abs(a)                                                              7479
      b=abs(b)                                                              7480
c                                                                           7481
      a2=.5*f*a                                                             7482
      b2=.5*f*b                                                             7483
      ta=tan(a2)                                                            7484
      tb=tan(b2)                                                            7485
c                                                                           7486
      if (ta/f.lt..1) go to 20                                              7487
      ra=.5*(ta+1./ta)                                                      7488
      if (tb/f.lt..1) go to 30                                              7489
      rb=-.5*(tb-1./tb)                                                     7490
c                                                                           7491
      y0a=ta-ra                                                             7492
      x0b=tb+rb                                                             7493
c                                                                           7494
      call sec (x0b,0.,rb,0.,y0a,ra,x1,y1,x2,y2,ie)                         7495
      if (x1.lt.0..or.y1.lt.0.) go to 10                                    7496
c      if(x1**2+y1**2.gt.1.) go to 1                                        7497
      x=x1                                                                  7498
      y=y1                                                                  7499
      go to 40                                                              7500
   10 x=x2                                                                  7501
      y=y2                                                                  7502
      go to 40                                                              7503
c                                                                           7504
   20 x=tb                                                                  7505
      y=0.                                                                  7506
      go to 40                                                              7507
   30 y=ta                                                                  7508
      x=0.                                                                  7509
   40 x=x*sb                                                                7510
      y=y*sa                                                                7511
      return                                                                7512
      end                                                                   7513
c #######======= 054                                                        7514
      subroutine xytoabr (a,b,x,y,f,al0)                                    7515
c x,y --> alpha,beta                                                        7516
c                                                                           7517
      r=sqrt(x*x+y*y)                                                       7518
      a=2.*atan(r)/f                                                        7519
      b=0.                                                                  7520
      if (a.gt..05) b=atan2(y,x)/f                                          7521
      a=a+al0                                                               7522
      return                                                                7523
      end                                                                   7524
c #######======= 055                                                        7525
      subroutine xytoab (a,b,x,y,f,be0)                                     7526
c x,y --> alpha,beta                                                        7527
c                                                                           7528
      sa=sign(1.,x)                                                         7529
      sb=sign(1.,y)                                                         7530
      xx=abs(x)                                                             7531
      yy=abs(y)                                                             7532
      if (yy.lt..001) go to 10                                              7533
c                                                                           7534
      y0=(xx*xx+yy*yy-1.)/(2.*yy)                                           7535
      d=sqrt(1.+y0*y0)                                                      7536
      a=180.-2.*atan(d-y0)/f                                                7537
c                                                                           7538
      if (xx.lt..001) go to 20                                              7539
      x0=yy*(yy-y0)/xx+xx                                                   7540
      rx=sqrt((x0-xx)**2+yy**2)                                             7541
      b=2.*atan(x0-rx)/f                                                    7542
      go to 30                                                              7543
c                                                                           7544
   10 a=0.                                                                  7545
      b=2.*atan(xx)/f                                                       7546
      go to 30                                                              7547
   20 b=0.                                                                  7548
      a=2.*atan(yy)/f                                                       7549
   30 a=sb*a                                                                7550
      b=sa*b+be0                                                            7551
      return                                                                7552
c                                                                           7553
      end                                                                   7554
c #######======= 056                                                        7555
      subroutine sec (x01,y01,rr1,x02,y02,rr2,xx1,yy1,xx2,yy2,ie)           7556
c common points of two circles                                              7557
c                                                                           7558
      ie=0                                                                  7559
      xx1=0.                                                                7560
      yy1=0.                                                                7561
      xx2=0.                                                                7562
      yy2=0.                                                                7563
c y1=y2                                                                     7564
      if (abs(y01-y02).gt..0001) go to 10                                   7565
      if (abs(x01-x02).lt..0001) go to 20                                   7566
      xx1=.5*(rr1**2-rr2**2+x02**2-x01**2)/(x02-x01)                        7567
      xx2=xx1                                                               7568
      de=rr1**2-(xx1-x01)**2                                                7569
      if (de.lt.0.) de=0.                                                   7570
      de=sqrt(de)                                                           7571
      yy1=y01+de                                                            7572
      yy2=y01-de                                                            7573
      return                                                                7574
c y=ax*x + bx                                                               7575
   10 ax=(x02-x01)/(y01-y02)                                                7576
      bx=.5*(x01**2+y01**2+rr2**2-x02**2-y02**2-rr1**2)/(y01-y02)           7577
      a1=1.+ax**2                                                           7578
      d=bx-y01                                                              7579
      p=2.*(d*ax-x01)                                                       7580
      q=x01**2+d**2-rr1**2                                                  7581
      p=.5*p/a1                                                             7582
      q=q/a1                                                                7583
      de=p**2-q                                                             7584
c      if (abs(de).lt..0001) de=0.                                          7585
      if (de.lt.0.) de=0.                                                   7586
      de=sqrt(de)                                                           7587
      xx1=-p+de                                                             7588
      xx2=-p-de                                                             7589
      yy1=ax*xx1+bx                                                         7590
      yy2=ax*xx2+bx                                                         7591
      return                                                                7592
c                                                                           7593
   20 ie=1                                                                  7594
      return                                                                7595
      end                                                                   7596
c #######======= 057                                                        7597
      subroutine idsy (ie,isys,in,io,ioa,ila,jsm)                           7598
c  generates a cell of high symmetry from approxinate c.p.                  7599
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     7600
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     7601
      dimension tdg(3), tdgw(3), isys(6), jsm(7)                            7602
      character*1 aw,jsm                                                    7603
      character*4 isys                                                      7604
      logical law                                                           7605
c                                                                           7606
      kk=1                                                                  7607
      ie=0                                                                  7608
      dw=3.                                                                 7609
      dv=5.                                                                 7610
c                                                                           7611
      do 10 i=1,3                                                           7612
        tdg(i)=dg(i)                                                        7613
   10   tdgw(i)=dgw(i)                                                      7614
c                                                                           7615
      write (ioa,110) tdg,tdgw,dv,dw                                        7616
      dv=.01*dv                                                             7617
      call les (in)                                                         7618
      if (n.eq.0) go to 100                                                 7619
      if (c(1).gt..001) dv=.01*c(1)                                         7620
      if (c(2).gt.0.01) dw=c(2)                                             7621
c                                                                           7622
      if (ila.eq.5) go to 30                                                7623
      if (abs(dgw(1)-90.).gt.dw) go to 90                                   7624
      if (abs(dgw(3)-90.).gt.dw) go to 20                                   7625
      if (abs(dgw(2)-90.).gt.dw) go to 40                                   7626
c                                                                           7627
      if (abs(dg(1)/dg(2)-1.).gt.dv) go to 50                               7628
      if (ila.eq.2.or.ila.eq.3) go to 50                                    7629
      if (abs(.5*(dg(1)+dg(2))/dg(3)-1.).gt.dv) go to 60                    7630
c cub.                                                                      7631
      if (ila.eq.4) go to 60                                                7632
      if (ila.eq.2.or.ila.eq.3) go to 50                                    7633
      tdg(1)=(dg(1)*dg(2)*dg(3))**0.33333333                                7634
      tdg(2)=tdg(1)                                                         7635
      tdg(3)=tdg(1)                                                         7636
      tdgw(1)=90.                                                           7637
      tdgw(2)=90.                                                           7638
      tdgw(3)=90.                                                           7639
      kk=6                                                                  7640
      go to 70                                                              7641
c hex                                                                       7642
   20 if (abs(dgw(2)-90.).gt.dw) go to 90                                   7643
   30 if (abs(dgw(3)-120.).gt.dw) go to 90                                  7644
      if (abs(dg(1)/dg(2)-1.).gt.dv) go to 90                               7645
      if (ila.ne.1.and.ila.ne.5) go to 90                                   7646
      tdg(1)=.5*(dg(1)+dg(2))                                               7647
      tdg(2)=tdg(1)                                                         7648
      tdgw(1)=90.                                                           7649
      tdgw(2)=90.                                                           7650
      tdgw(3)=120.                                                          7651
      kk=3                                                                  7652
      go to 70                                                              7653
c monocl                                                                    7654
   40 tdgw(1)=90.                                                           7655
      tdgw(3)=90.                                                           7656
      kk=2                                                                  7657
      go to 70                                                              7658
c orh                                                                       7659
   50 tdgw(1)=90.                                                           7660
      tdgw(2)=90.                                                           7661
      tdgw(3)=90.                                                           7662
      kk=4                                                                  7663
      go to 70                                                              7664
c tetr.                                                                     7665
   60 tdg(1)=.5*(dg(1)+dg(2))                                               7666
      tdg(2)=tdg(1)                                                         7667
      tdgw(1)=90.                                                           7668
      tdgw(2)=90.                                                           7669
      tdgw(3)=90.                                                           7670
      kk=5                                                                  7671
   70 write (ioa,120) tdg,tdgw,isys(kk),jsm(ila)                            7672
      if (io.ne.ioa) write (io,120) tdg,tdgw,isys(kk),jsm(ila)              7673
      read (5,130,end=100) aw                                               7674
      if (law(aw)) go to 100                                                7675
      do 80 i=1,3                                                           7676
        dg(i)=tdg(i)                                                        7677
   80   dgw(i)=tdgw(i)                                                      7678
      return                                                                7679
c                                                                           7680
   90 ie=1                                                                  7681
      dv=100.*dv                                                            7682
      write (ioa,140) dv,dw,jsm(ila)                                        7683
      return                                                                7684
  100 ie=1                                                                  7685
      return                                                                7686
c                                                                           7687
c                                                                           7688
c                                                                           7689
  110 format (8x,3f9.3,2x,3f7.2/' tolerance',f4.1,'% (axes),',f5.1,' deg    7690
     1. (angle) ok?'/' otherwise new values. 0 or <return>: no changes')    7691
  120 format (' load? :',3f9.3,2x,3f7.2,3x,a4,1x,a1)                        7692
  130 format (a1)                                                           7693
  140 format (' no new crystal system found within',f4.1,'% and',f5.1,'     7694
     1deg., centering: ',a1)                                                7695
      end                                                                   7696
c #######======= 058                                                        7697
      subroutine cvol (v,fk,ila)                                            7698
c calculate volume from Laue zone radii                                     7699
      dimension fk(7)                                                       7700
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      7701
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      7702
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        7703
c                                                                           7704
      tl=atan(r0/akl)                                                       7705
      ph=tl*fakr                                                            7706
      se=r1*r2*sin(wi/fakr)                                                 7707
      if (rl1.lt.0.0001) return                                             7708
      vca=ak**3/(se*akl*(cos(tl)-cos(atan(rl1/akl)+tl)))                    7709
      v=vca*fk(ila)                                                         7710
      return                                                                7711
      end                                                                   7712
c #######======= 059                                                        7713
      subroutine czrh (ila,ke,cd,fakr,in,io,ioa,itri,limax)                 7714
c closest zone, rhombohedral case elaborated                                7715
c                                                                           7716
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     7717
      dimension cd(6)                                                       7718
      character*1 aw                                                        7719
      logical law                                                           7720
   10 call les (in)                                                         7721
      if (n.eq.0.or.ndi(1).gt.mdi) go to 40                                 7722
      if (abs(c(1))+abs(c(2))+abs(c(3)).eq.0..or.abs(c(4))+abs(c(5))+       7723
     1abs(c(6)).eq.0.) go to 40                                             7724
      wmx=c(7)                                                              7725
c  hexrh liefert iz=1 wenn c(1)-c(6) integers sind und                      7726
c        kuerzt  u1,v1,w1 (c(11)) und  u2,v2,w2 (c(12))                     7727
      call hexrh (iz)                                                       7728
      if (wmx.lt.0.) wmx=181.                                               7729
      if (wmx.eq.0.) wmx=90.                                                7730
      j=0                                                                   7731
   20 call cz (ila,ke,cd,fakr,wmx,io,ioa,0,limax,in)                        7732
c                                                                           7733
c trig. R, spec. cases u+v=3n and l(.ne.0)=3n, uuw, u0w, 0vw, uv0           7734
      if (j.eq.1) go to 10                                                  7735
      if (iz.ne.0) go to 10                                                 7736
      if (itri.eq.0) go to 10                                               7737
      if (c(6).eq.0.) go to 10                                              7738
c                                                                           7739
      if (abs(amod(c(4)+c(5),3.)).gt..01) go to 10                          7740
c hier wird auch hhl mit h=3n und l=3m+(1 od. 2) erfasst, Vorsicht!         7741
      if (abs(c(4)*c(5)).lt..01) go to 10                                   7742
      if (c(4).eq.c(5)) go to 10                                            7743
      if (abs(amod(c(4),3.)).gt..5.and.abs(amod(c(6),3.)).lt..5) go to      7744
     130                                                                    7745
      if (abs(amod(c(4),3.)).lt..5) go to 30                                7746
      go to 10                                                              7747
c                                                                           7748
   30 c(6)=-c(6)                                                            7749
      write (ioa,50) c(4),c(5),c(6)                                         7750
      read (in,60,end=40) aw                                                7751
      if (law(aw)) go to 10                                                 7752
      j=1                                                                   7753
      go to 20                                                              7754
c                                                                           7755
   40 return                                                                7756
c                                                                           7757
c                                                                           7758
c                                                                           7759
   50 format (4x,'##### try also: 2nd zone',3f7.2,' ? (y/n)')               7760
   60 format (a1)                                                           7761
      end                                                                   7762
c #######======= 060                                                        7763
      subroutine cz (ila,ke,cd,f,wm,io,ioa,iw,limax,in)                     7764
c find equivalent zone axes and compute angles with a given axis            7765
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     7766
      common /wi/ x1,x2,x3,dd                                               7767
      common /wis/ a1(48),a2(48),a3(48),wn(48),nn                           7768
      dimension cd(6), x(3,3), xx(3,3)                                      7769
      logical law                                                           7770
      character*1 aw                                                        7771
c                                                                           7772
      nl=1                                                                  7773
      iin=0                                                                 7774
      do 10 j=1,3                                                           7775
        if (amod(c(j),1.).ne.0.) iin=iin+1                                  7776
        if (amod(c(j+3),1.).ne.0.) iin=iin+1                                7777
        x(j,1)=c(j)                                                         7778
        x(j,2)=c(j+3)                                                       7779
   10   x(j,3)=x(j,2)-x(j,1)                                                7780
      if (iw.gt.0) go to 20                                                 7781
      if (iin.ne.0) write (ioa,210) iin                                     7782
      write (ioa,230) (c(i),i=1,6),wm                                       7783
      if (io.ne.ioa) write (io,230) (c(i),i=1,6),wm                         7784
   20 call trd (x,xx,cd)                                                    7785
      x1=xx(1,1)                                                            7786
      x2=xx(2,1)                                                            7787
      x3=xx(3,1)                                                            7788
      dd=sqrt(x1**2+x2**2+x3**2)                                            7789
      z1=xx(1,2)                                                            7790
      z2=xx(2,2)                                                            7791
      z3=xx(3,2)                                                            7792
      dd=1./(dd*sqrt(z1**2+z2**2+z3**2))                                    7793
      y1=x(1,2)                                                             7794
      y2=x(2,2)                                                             7795
      y3=x(3,2)                                                             7796
      do 30 i=1,48                                                          7797
        a1(i)=0.                                                            7798
        a2(i)=0.                                                            7799
        a3(i)=0.                                                            7800
   30   wn(i)=0.                                                            7801
      nn=0                                                                  7802
c                                                                           7803
      go to (40,50,60,80,80,80),ke+1                                        7804
c trk                                                                       7805
   40 call wii (x,y1,y2,y3,f,cd,wm)                                         7806
      call wii (x,-y1,-y2,-y3,f,cd,wm)                                      7807
      go to 130                                                             7808
c mkl                                                                       7809
   50 call wii (x,y1,y2,y3,f,cd,wm)                                         7810
      call wii (x,-y1,y2,-y3,f,cd,wm)                                       7811
      call wii (x,y1,-y2,y3,f,cd,wm)                                        7812
      call wii (x,-y1,-y2,-y3,f,cd,wm)                                      7813
      go to 130                                                             7814
c hex                                                                       7815
   60 ii=0                                                                  7816
   70 call wii (x,y1,y2,y3,f,cd,wm)                                         7817
      call wii (x,-y2,y1-y2,y3,f,cd,wm)                                     7818
      call wii (x,y2-y1,-y1,y3,f,cd,wm)                                     7819
      call wii (x,-y2,-y1,y3,f,cd,wm)                                       7820
      call wii (x,y1,y1-y2,y3,f,cd,wm)                                      7821
      call wii (x,y2-y1,y2,y3,f,cd,wm)                                      7822
      ii=ii+1                                                               7823
      if (ii.eq.4) go to 130                                                7824
      y1=-y1                                                                7825
      y2=-y2                                                                7826
      y3=-y3                                                                7827
      if (mod(ii,2).eq.1) go to 70                                          7828
c                                                                           7829
      if (ila.eq.5) go to 130                                               7830
      d=y1                                                                  7831
      y1=y2                                                                 7832
      y2=d                                                                  7833
      go to 70                                                              7834
c orh                                                                       7835
   80 ii=0                                                                  7836
   90 if (ii.gt.5) go to 130                                                7837
      do 100 jj=1,2                                                         7838
        call wii (x,y1,y2,y3,f,cd,wm)                                       7839
        call wii (x,-y1,y2,y3,f,cd,wm)                                      7840
        call wii (x,y1,-y2,y3,f,cd,wm)                                      7841
        call wii (x,y1,y2,-y3,f,cd,wm)                                      7842
        y1=-y1                                                              7843
        y2=-y2                                                              7844
  100   y3=-y3                                                              7845
      if (ke.eq.3) go to 130                                                7846
c tetr                                                                      7847
      if (ke.eq.4.and.ii.eq.1) go to 130                                    7848
      if (ke.eq.5.and.ii.eq.1) go to 110                                    7849
      if (ke.eq.5.and.ii.eq.3) go to 120                                    7850
      d=y1                                                                  7851
      y1=y2                                                                 7852
      y2=d                                                                  7853
      ii=ii+1                                                               7854
      go to 90                                                              7855
c cub                                                                       7856
  110 d=y1                                                                  7857
      y1=y2                                                                 7858
      y2=y3                                                                 7859
      y3=d                                                                  7860
      ii=ii+1                                                               7861
      go to 90                                                              7862
c                                                                           7863
  120 d=y2                                                                  7864
      y2=y3                                                                 7865
      y3=d                                                                  7866
      ii=ii+1                                                               7867
      go to 90                                                              7868
c                                                                           7869
  130 if (nn.eq.0) go to 200                                                7870
      if (nn.eq.1) go to 160                                                7871
c                                                                           7872
  140 iu=0                                                                  7873
      do 150 i=1,nn-1                                                       7874
        i1=i+1                                                              7875
        if (wn(i).le.wn(i+1)) go to 150                                     7876
        iu=iu+1                                                             7877
        z1=a1(i)                                                            7878
        z2=a2(i)                                                            7879
        z3=a3(i)                                                            7880
        a1(i)=a1(i1)                                                        7881
        a2(i)=a2(i1)                                                        7882
        a3(i)=a3(i1)                                                        7883
        a1(i1)=z1                                                           7884
        a2(i1)=z2                                                           7885
        a3(i1)=z3                                                           7886
        z1=wn(i)                                                            7887
        wn(i)=wn(i1)                                                        7888
        wn(i1)=z1                                                           7889
  150 continue                                                              7890
      if (iu.gt.0) go to 140                                                7891
c                                                                           7892
  160 if (iw.gt.0) return                                                   7893
c                                                                           7894
      do 180 i=1,nn                                                         7895
        nl=nl+1                                                             7896
        if (nl.le.limax) go to 170                                          7897
        write (ioa,250)                                                     7898
        read (in,260,end=190) aw                                            7899
        if (law(aw)) go to 190                                              7900
        nl=0                                                                7901
  170   write (ioa,220) a1(i),a2(i),a3(i),wn(i)                             7902
        if (io.ne.ioa) write (io,220) a1(i),a2(i),a3(i),wn(i)               7903
  180 continue                                                              7904
c                                                                           7905
  190 return                                                                7906
  200 if (iw.eq.0) write (ioa,240) wm                                       7907
      return                                                                7908
c                                                                           7909
c                                                                           7910
c                                                                           7911
  210 format (' ****** ',i2,' non-integer(s)! ******')                      7912
  220 format (27x,3f6.1,f10.2)                                              7913
  230 format (' input:',2(3f6.2,2x),', max(angle):',f7.2)                   7914
  240 format (15x,'no equivalent accessible within ',f5.1,' deg.')          7915
  250 format (1x,'cont.?')                                                  7916
  260 format (a1)                                                           7917
      end                                                                   7918
c #######======= 061                                                        7919
      subroutine wii (x,z1,z2,z3,f,cd,wm)                                   7920
c angle from cartesian coordinates                                          7921
      common /wi/ x1,x2,x3,dd                                               7922
      common /wis/ a1(48),a2(48),a3(48),wn(48),nn                           7923
      dimension x(3,3), xx(3,3), cd(6)                                      7924
c                                                                           7925
      nn=nn+1                                                               7926
      x(1,2)=z1                                                             7927
      x(2,2)=z2                                                             7928
      x(3,2)=z3                                                             7929
      call trd (x,xx,cd)                                                    7930
      wi=f*arco((x1*xx(1,2)+x2*xx(2,2)+x3*xx(3,2))*dd)                      7931
      if (wi.le.wm) go to 20                                                7932
   10 nn=nn-1                                                               7933
      return                                                                7934
c                                                                           7935
   20 if (nn.gt.1) go to 30                                                 7936
      a1(1)=z1                                                              7937
      a2(1)=z2                                                              7938
      a3(1)=z3                                                              7939
      wn(1)=wi                                                              7940
      return                                                                7941
c                                                                           7942
   30 do 40 i=1,nn-1                                                        7943
        if (z1.eq.a1(i).and.z2.eq.a2(i).and.z3.eq.a3(i)) go to 10           7944
   40 continue                                                              7945
      a1(nn)=z1                                                             7946
      a2(nn)=z2                                                             7947
      a3(nn)=z3                                                             7948
      wn(nn)=wi                                                             7949
      return                                                                7950
      end                                                                   7951
c #######======= 062                                                        7952
      subroutine ss (ig,isr,pftst1,rs0,rs,ier,id33)                         7953
c cell parameters from two patterns                                         7954
c                                                                           7955
      parameter (jj4=20)                                                    7956
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    7957
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       7958
     2jfw                                                                   7959
      common /b/ ii,jj,ila,ke,nq(jj4)                                       7960
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      7961
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      7962
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        7963
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,        7964
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,    7965
     2difa,difg,dc0                                                         7966
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     7967
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)                   7968
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv            7969
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      7970
      common /ti/ titel(18),text(17),tit(18,jj4)                            7971
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     7972
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,     7973
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0                                       7974
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                  7975
      common /its/ ftst(9),itst(9)                                          7976
      dimension dgd(6), dgdw(3)                                             7977
c                                                                           7978
      character*1 aw,s4                                                     7979
      character*3 s2                                                        7980
      character*4 isys,titel,tit,text,ta1,ta0,ta0l,p6                       7981
      character rs*10,rs0*10                                                7982
      logical law                                                           7983
c                                                                           7984
      isx=0                                                                 7985
      call cksg (io,ioa,in,sv,vmin,vmax,iii,-1,ilim,0,iall)                 7986
      iii=0                                                                 7987
c      iu=1                                                                 7988
      do 10 i=1,nx                                                          7989
   10   if (rf(1,i).gt..001) iii=iii+1                                      7990
      if (iii.gt.1) go to 20                                                7991
      write (ioa,360)                                                       7992
      go to 210                                                             7993
   20 write (ioa,300)                                                       7994
      call les (in)                                                         7995
      if (n.eq.0.or.ndi(1).gt.mdi.or.ndi(2).gt.mdi) go to 210               7996
      k=c(1)                                                                7997
      kk=c(2)                                                               7998
      i=iabs(k)                                                             7999
      j=iabs(kk)                                                            8000
      if (k*kk.lt.0) go to 30                                               8001
      k=i                                                                   8002
      kk=j                                                                  8003
   30 if (i.gt.nx.or.j.gt.nx.or.i.eq.0.or.j.eq.0) go to 210                 8004
      if (rf(1,i).gt.0..and.rf(1,j).gt.0.) go to 40                         8005
      if (rf(1,i).le.0.) write (ioa,370) i                                  8006
      if (rf(1,j).le.0.) write (ioa,370) j                                  8007
      go to 210                                                             8008
   40 if (abs(rf(3,i)*rf(1,j)/(rf(1,i)*rf(3,j))-1.).le.ftst(1)) go to       8009
     150                                                                    8010
      write (ioa,310) i,pftst1,j                                            8011
      go to 210                                                             8012
c                                                                           8013
   50 lm=2                                                                  8014
      if (irf(5,i).eq.2.or.irf(5,i).gt.4) lm=1                              8015
      if (irf(5,j).eq.2.or.irf(5,j).gt.4) lm=1                              8016
      if (k.lt.0.or.kk.lt.0) lm=1                                           8017
      lm16=limax/(2*lm-1)                                                   8018
c                                                                           8019
      call htoa (i)                                                         8020
      ix=2                                                                  8021
      rrgg(1)=r1/ak                                                         8022
      rrgg(2)=r2/ak                                                         8023
      rrgg(6)=cos(fak*wi)                                                   8024
      call htoa (j)                                                         8025
      ihv=jhv(hv)                                                           8026
      lq=lqq                                                                8027
      iv=ivv                                                                8028
      if (isr.eq.0.or.r0m.ne.0.) go to 60                                   8029
      lq=1                                                                  8030
      iv=1                                                                  8031
   60 rrgg(3)=r2/ak                                                         8032
      rgw3=rrgg(3)*sin(fak*wi)                                              8033
      rg5=cos(fak*wi)                                                       8034
      dd=1./(rrgg(1)*rrgg(2)*sqrt(1.-rrgg(6)**2))                           8035
      vmin=dd/rgw3+.05                                                      8036
      xx12=rrgg(2)*rrgg(6)                                                  8037
      xx22=rrgg(2)*sqrt(1.-rrgg(6)**2)                                      8038
      ila=1                                                                 8039
      rs=rs0                                                                8040
c                                                                           8041
c  iu: Kennzahl fuer Delaunay-Reduktion                                     8042
c                                                                           8043
   70 write (ioa,380)                                                       8044
      call les (in)                                                         8045
      if (n.eq.0) go to 210                                                 8046
      iu=c(1)                                                               8047
      if (iu.gt.-6.and.iu.lt.6) go to 80                                    8048
      write (ioa,240)                                                       8049
      go to 70                                                              8050
c                                                                           8051
   80 write (ioa,320) vmin                                                  8052
      call les (in)                                                         8053
      if (n.eq.0) go to 210                                                 8054
      if (c(1).lt.0.) go to 100                                             8055
      iwn=0                                                                 8056
      vmin=amax1(vmin,c(1))                                                 8057
      vmax=amax1(c(2),vmin)                                                 8058
      nce=0                                                                 8059
      if (c(3).eq.0.) c(3)=-1.                                              8060
      if (c(3).gt.0.) go to 90                                              8061
c                                                                           8062
      nce=1                                                                 8063
      delv=1.-.01*c(3)                                                      8064
      n=max1(1.,alog(vmax/vmin)/alog(delv)+0.5)                             8065
      delv=exp(alog(vmax/vmin)/amax0(n,1))                                  8066
      vv=vmin/delv                                                          8067
      if (vmax-vmin.lt..1) n=0                                              8068
      go to 110                                                             8069
c                                                                           8070
   90 n=max1(1.,(vmax-vmin)/c(3)+.5)                                        8071
      if (vmin.eq.vmax) n=0                                                 8072
      delv=0.                                                               8073
      if (n.gt.0) delv=(vmax-vmin)/float(n)                                 8074
      go to 110                                                             8075
c                                                                           8076
  100 c(1)=-c(1)                                                            8077
      wmin=amax1(c(1),1.)                                                   8078
      wmax=amax1(wmin,abs(c(2)))                                            8079
      c(3)=abs(c(3))                                                        8080
      if (c(3).eq.0.) c(3)=.5                                               8081
      n=max1(1.,(wmax-wmin)/c(3)+.5)                                        8082
      if (wmin.eq.wmax) n=0                                                 8083
      delw=0.                                                               8084
      if (n.gt.0) delw=(wmax-wmin)/float(n)                                 8085
      iwn=1                                                                 8086
c                                                                           8087
  110 ig=in                                                                 8088
      ta1='-SS-'                                                            8089
      call clt (text)                                                       8090
      do 190 m=0,n                                                          8091
        mm=0                                                                8092
        if (iwn.eq.0) go to 120                                             8093
c                                                                           8094
        win=wmin+delw*float(m)                                              8095
        vv=dd/(rgw3*sin(fak*win))                                           8096
        go to 130                                                           8097
  120   if (nce.eq.0) vv=vmin+delv*float(m)                                 8098
        if (nce.eq.1) vv=vv*delv                                            8099
        win=0.                                                              8100
  130   call rlgen2 (kk,mm,vv,dd,rrgg,fakr,dgd,dgdw,ie,rg5,xx12,xx22)       8101
        if (ie.eq.1) go to 220                                              8102
        ddd=dd/(rgw3*vv)                                                    8103
        if (abs(ddd).ge.1.) go to 220                                       8104
        if (iwn.eq.0) win=fakr*asin(ddd)                                    8105
        if (win.lt.1.) go to 230                                            8106
        if (iu.ne.0) go to 140                                              8107
        write (io,330) (dg(ll),ll=1,3),dgw,v0,win                           8108
        if (io.ne.ioa) write (ioa,330) (dg(ll),ll=1,3),dgw,v0,win           8109
c hier Delaunay (iu)                                                        8110
        go to 170                                                           8111
  140   ila=1                                                               8112
        ntr0=0                                                              8113
        call del (dg,dgw,ddw,ddv,ila,ntr,ntr0,rs,rs0,isx,nrt,id33,iu)       8114
c                                                                           8115
        if (nrt.eq.0) go to 160                                             8116
        if (iu.eq.0) go to 150                                              8117
        if (lm.eq.1) write (ioa,250) v0,win                                 8118
        if (lm.eq.2) write (ioa,260) v0,win,mm                              8119
c                                                                           8120
  150   read (in,350,end=200) aw                                            8121
        if (law(aw)) go to 200                                              8122
  160   if (ntr0.le.0.or.ntr.lt.ntr0) go to 170                             8123
c                                                                           8124
  170   if (lm.eq.2.and.mm.eq.1) go to 130                                  8125
        if (mod(m+1,lm16).ne.0) go to 180                                   8126
c                                                                           8127
        if (iu.ne.0) go to 190                                              8128
c                                                                           8129
        write (ioa,290)                                                     8130
        read (in,350,end=200) aw                                            8131
        if (law(aw)) go to 200                                              8132
  180   if (lm.eq.2.and.iu.eq.0) write (ioa,340)                            8133
  190 continue                                                              8134
  200 ier=2                                                                 8135
      return                                                                8136
c                                                                           8137
  210 ier=1                                                                 8138
      return                                                                8139
  220 write (ioa,270)                                                       8140
      go to 200                                                             8141
  230 write (ioa,280)                                                       8142
      go to 200                                                             8143
c                                                                           8144
c                                                                           8145
c                                                                           8146
  240 format (' -6 < value < +6 !')                                         8147
  250 format (2x,'V:',f7.1,', ang.:',f5.1,';  cont.?')                      8148
  260 format (2x,'V:',f7.1,', ang.:',f5.1,',  set ',i1,';  cont.?')         8149
  270 format ('  *** numerical problems ***')                               8150
  280 format ('  *** angle < 1 deg. ***')                                   8151
  290 format (' cont.?')                                                    8152
  300 format (1x,'#1, #2 in A-mem.; r1(#1) = r1(#2)'/13x,'nth number <0:    8153
     1 nth setting only (n = 1 or 2)')                                      8154
  310 format (1x,'d1(',i1,') differs more than',f5.2,'% from d1(',i1,')'    8155
     1)                                                                     8156
  320 format (' volume: min(<0:angle), max, delta(<0:%) (def.(vol.): 1%,    8157
     1 (ang):0.5deg.)?'/' min. vol.:',f8.1)                                 8158
  330 format (1x,3f9.3,3f8.2,', V:',f9.1,', ang.:',f6.2)                    8159
  340 format (' ')                                                          8160
  350 format (a1)                                                           8161
  360 format (1x,'at least 2 data sets in memory A required')               8162
  370 format (1x,i3,' is empty')                                            8163
  380 format (1x,'Delaunay reduction? (0:no; min. symm.: 1:mcl,2:orh,3:t    8164
     1et,4:hex,5:cub)')                                                     8165
      end                                                                   8166
c #######======= 063                                                        8167
      subroutine gon (holder,ibr,ihot,ihon,nx,ie)                           8168
c controls and evaluates goniometer data                                    8169
      parameter (jj3=140,jj4=20)                                            8170
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,    8171
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0,       8172
     2jfw                                                                   8173
      common /j8/ j8(jj3),j9(jj3),j85(6)                                    8174
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     8175
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda                      8176
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      8177
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      8178
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        8179
      common /cm12/ be01,be00,rbe1,rbe0                                     8180
      dimension holder(3)                                                   8181
      character holder*11,j8*2,j9*2,j85*5,aw*1                              8182
      logical law                                                           8183
c                                                                           8184
      go to (10,120,130),ibr-78                                             8185
c                                                                           8186
c GS --- calc. angles between zones from gonio. setting ---                 8187
c                                                                           8188
   10 write (ioa,280) holder(iho),holder                                    8189
      call les (in)                                                         8190
      if (n.eq.0.or.ndi(1).gt.mdi) go to 170                                8191
      ihon=c(1)                                                             8192
      if (ihon.ge.0) go to 30                                               8193
      if (ihot.ne.0) go to 20                                               8194
      write (ioa,290)                                                       8195
      go to 170                                                             8196
   20 write (ioa,200)                                                       8197
      read (in,370,end=170) aw                                              8198
      if (law(aw)) go to 170                                                8199
      ihot=0                                                                8200
      an0=0.                                                                8201
      an1=0.                                                                8202
      an2=0.                                                                8203
      write (ioa,300)                                                       8204
      go to 180                                                             8205
c                                                                           8206
   30 ihon=min0(ihon,3)                                                     8207
      if (ihon.eq.0) ihon=iho                                               8208
      iho=ihon                                                              8209
      ihot=ihon                                                             8210
c  ihon : CM12-Halter als Doppelkipp                                        8211
      if (ihot.eq.3) ihot=1                                                 8212
      write (ioa,210) holder(ihon)                                          8213
      go to (50,40,60),ihon                                                 8214
   40 write (ioa,190)                                                       8215
      iqaw=0                                                                8216
      ie=1                                                                  8217
      if (iqaw.eq.0) return                                                 8218
      write (ioa,260)                                                       8219
c  rot.-tilt                                                                8220
      call les (in)                                                         8221
      if (n.eq.0) go to 170                                                 8222
      if (abs(c(1)).gt.20.) go to 160                                       8223
      al0=c(1)                                                              8224
      go to 80                                                              8225
c  double tilt                                                              8226
   50 write (ioa,250)                                                       8227
      call les (in)                                                         8228
      if (n.eq.0) go to 170                                                 8229
      if (abs(c(1)).gt.20.) go to 160                                       8230
      be0=c(1)                                                              8231
      go to 80                                                              8232
c  double tilt  CM12                                                        8233
   60 write (ioa,220) be01,be00                                             8234
      call les (in)                                                         8235
      if (n.eq.0) go to 170                                                 8236
      if (c(1).lt.0.01) go to 70                                            8237
      be01=c(1)                                                             8238
      be00=c(2)                                                             8239
   70 write (ioa,230) be01,be00                                             8240
      rbe1=1./be01                                                          8241
      rbe0=-be00/be01                                                       8242
c                                                                           8243
   80 write (ioa,310) holder(ihon)                                          8244
      call les (in)                                                         8245
      if (n.eq.0) go to 180                                                 8246
      do 90 i=1,5                                                           8247
        if (c(i).ne.0.) go to 100                                           8248
   90 continue                                                              8249
      go to 180                                                             8250
c                                                                           8251
  100 if (ihon.ne.3) go to 110                                              8252
c  CM12                                                                     8253
      c(2)=be01*c(2)+be00                                                   8254
      c(4)=be01*c(4)+be00                                                   8255
      write (ioa,240) (c(i),i=1,4)                                          8256
  110 alp=zwi(c(1),c(2),c(3),c(4),ihon,al0,be0)                             8257
      write (ioa,320) alp                                                   8258
      go to 80                                                              8259
c                                                                           8260
c  GR --- read goniometer data ---                                          8261
c                                                                           8262
  120 ihot=iho                                                              8263
      if (ihot.eq.3) ihot=1                                                 8264
      ihon=iho                                                              8265
      write (ioa,330) holder(ihon),j9(79)                                   8266
      call les (in)                                                         8267
      if (n.eq.0) go to 170                                                 8268
      if (abs(c(1)).ge.100.) go to 20                                       8269
      if (ihon.eq.3) c(2)=be01*c(2)+be00                                    8270
      write (ioa,230) c(1),c(2)                                             8271
      an1=c(1)                                                              8272
      an2=c(2)                                                              8273
      an0=ihot                                                              8274
      go to 180                                                             8275
c                                                                           8276
c GC --- calc. angles between zones of patterns in A-mem. ---               8277
c                                                                           8278
  130 write (ioa,340)                                                       8279
      call les (in)                                                         8280
      if (n.eq.0.or.ndi(1).gt.mdi.or.ndi(2).gt.mdi) go to 170               8281
      i=abs(c(1))                                                           8282
      j=abs(c(2))                                                           8283
      if (i.gt.nx.or.j.gt.nx.or.i.le.0.or.j.le.0) go to 170                 8284
      if (rf(1,i).gt.0..and.rf(1,j).gt.0.) go to 140                        8285
      if (rf(1,i).le.0.) write (ioa,350) i                                  8286
      if (rf(1,j).le.0.) write (ioa,350) j                                  8287
      go to 170                                                             8288
  140 if (rf(25,i)*rf(25,j).ne.0..and.rf(25,i).eq.rf(25,j)) go to 150       8289
      write (ioa,360)                                                       8290
      go to 170                                                             8291
  150 ihott=rf(25,j)                                                        8292
      alp=zwi(rf(23,i),rf(24,i),rf(23,j),rf(24,j),ihott,al0,be0)            8293
      write (ioa,320) alp                                                   8294
      go to 180                                                             8295
c                                                                           8296
  160 write (ioa,270)                                                       8297
  170 ie=1                                                                  8298
      return                                                                8299
  180 ie=2                                                                  8300
      return                                                                8301
c                                                                           8302
c                                                                           8303
c                                                                           8304
  190 format (' ***** sorry, rotation tilt currently not provided')         8305
  200 format (' cancel goniometer data: are you sure?')                     8306
  210 format (3x,a11)                                                       8307
  220 format ('  factor, beta(0)? (def:',2f7.2,')')                         8308
  230 format (12x,2f8.2)                                                    8309
  240 format (15x,'transformed angles:',4f7.2)                              8310
  250 format (' beta(0)?')                                                  8311
  260 format (' alpha(0)?')                                                 8312
  270 format (' alpha(0) or beta(0) > 20 deg. is irrealistic')              8313
  280 format (' holder type? def: ',a11,'; 1:',a11,', 2:',a11,', 3:',       8314
     1a11/'  <0: cancel goniometer data')                                   8315
  290 format (' nothing to be cancelled')                                   8316
  300 format (' goniometer data canceled')                                  8317
  310 format (' beta1, alpha1, beta2, alpha2, ',a11,'; blank to escape')    8318
  320 format (1x,4f8.2)                                                     8319
  330 format (' beta, alpha ',a11,' (beta > 100: clear goniometer data (    8320
     1"no data"))'/' <',a2,'> to change holder type')                       8321
  340 format (' between which numbers?')                                    8322
  350 format (1x,i3,' is empty')                                            8323
  360 format (' mixed or missing goniometer data')                          8324
  370 format (a1)                                                           8325
      end                                                                   8326
c #######======= 064                                                        8327
      function zwi (c1,c2,c3,c4,iho,al0,be0)                                8328
c  angle between zone axes from goniometer setting                          8329
      data f/.0174532925/                                                   8330
      if (iho.ne.2) go to 10                                                8331
      cc1=(c1-al0)*f                                                        8332
      cc3=(c3-al0)*f                                                        8333
      cc2=c2*f                                                              8334
      cc4=c4*f                                                              8335
      zwi=arco(cos(cc1)*cos(cc3)+sin(cc1)*sin(cc3)*cos(cc2-cc4))/f          8336
      return                                                                8337
c                                                                           8338
   10 cc2=(c2-be0)*f                                                        8339
      cc4=(c4-be0)*f                                                        8340
      cc1=c1*f                                                              8341
      cc3=c3*f                                                              8342
      zwi=arco(sin(cc2)*sin(cc4)+cos(cc2)*cos(cc4)*cos(cc1-cc3))/f          8343
      return                                                                8344
      end                                                                   8345
c #######======= 065                                                        8346
      subroutine upn (ibr,ier,fak,in,ioa)                                   8347
c pocket calculator                                                         8348
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     8349
      common /xc/ xc(4),xm                                                  8350
      fdi=ifdi                                                              8351
      go to (110,140,160,180,200,220,260,280,300,330,90,100,310,320,70,     8352
     140,40,80,20,20,20,20,10,350,350,350,350,350,50,60,350,350,350,350,    8353
     2350,350,350,350,350,350,350,350,380,390,400,420,30),ibr-85            8354
c  ..                                                                       8355
   10 c(1)=xc(1)                                                            8356
      go to 120                                                             8357
c  .1 .2 .3 .4                                                              8358
   20 call les (in)                                                         8359
      if (n.eq.0) go to 340                                                 8360
      i=ibr-103                                                             8361
      xc(i)=c(1)                                                            8362
      go to 250                                                             8363
c .M                                                                        8364
   30 call les (in)                                                         8365
      if (n.eq.0) go to 340                                                 8366
      xm=c(1)                                                               8367
      go to 250                                                             8368
c AS, AC                                                                    8369
   40 if (abs(xc(1)).gt.1.) go to 370                                       8370
      alx=xc(1)                                                             8371
      if (ibr.eq.101) xc(1)=asin(xc(1))/fak                                 8372
      if (ibr.eq.102) xc(1)=acos(xc(1))/fak                                 8373
      go to 250                                                             8374
c LO (=ln)                                                                  8375
   50 if (xc(1).le.0.) go to 370                                            8376
      alx=xc(1)                                                             8377
      xc(1)=alog(xc(1))                                                     8378
      go to 250                                                             8379
c E* (=exp)                                                                 8380
   60 if (abs(xc(1)).gt.alog(10.**ifdi)) go to 370                          8381
      alx=xc(1)                                                             8382
      xc(1)=exp(xc(1))                                                      8383
      go to 250                                                             8384
c TG                                                                        8385
   70 c(1)=amod(abs(xc(1)),360.)                                            8386
      if (abs(c(1)-90.).lt.1.e-12.or.abs(c(1)-270.).lt.1.e-12) go to        8387
     1370                                                                   8388
      alx=xc(1)                                                             8389
      xc(1)=tan(xc(1)*fak)                                                  8390
      go to 250                                                             8391
c AT                                                                        8392
   80 alx=xc(1)                                                             8393
      xc(1)=atan(xc(1))/fak                                                 8394
      go to 250                                                             8395
c MP                                                                        8396
   90 xm=xc(1)                                                              8397
      go to 360                                                             8398
c MG                                                                        8399
  100 c(1)=xm                                                               8400
      go to 120                                                             8401
  110 call les (in)                                                         8402
      if (n.eq.0) go to 340                                                 8403
  120 do 130 i=4,2,-1                                                       8404
  130   xc(i)=xc(i-1)                                                       8405
      alx=xc(1)                                                             8406
      xc(1)=c(1)                                                            8407
      go to 250                                                             8408
c +                                                                         8409
  140 if (xc(1)+xc(2).eq.0.) go to 150                                      8410
      if (abs(alog10(abs(xc(1)+xc(2)))).gt.fdi) go to 370                   8411
  150 alx=xc(1)                                                             8412
      xc(1)=xc(1)+xc(2)                                                     8413
      go to 240                                                             8414
c -                                                                         8415
  160 if (xc(1)-xc(2).eq.0.) go to 170                                      8416
      if (abs(alog10(abs(xc(1)-xc(2)))).gt.fdi) go to 370                   8417
  170 alx=xc(1)                                                             8418
      xc(1)=xc(2)-xc(1)                                                     8419
      go to 240                                                             8420
c *                                                                         8421
  180 if (xc(2).eq.0..or.xc(1).eq.0.) go to 190                             8422
c?    if (abs(alog10(abs(xc(1)))+alog10(abs(xc(2)))).gt.fdi) go to 36       8423
      if (abs(alo+alog10(abs(xc(2)))).gt.fdi) go to 370                     8424
  190 alx=xc(1)                                                             8425
      xc(1)=xc(2)*xc(1)                                                     8426
      go to 240                                                             8427
c /                                                                         8428
  200 if (xc(1).eq.0.) go to 370                                            8429
      if (xc(2).eq.0.) go to 210                                            8430
      if (abs(alo-alog10(abs(xc(2)))).gt.fdi) go to 370                     8431
  210 alx=xc(1)                                                             8432
      xc(1)=xc(2)/xc(1)                                                     8433
      go to 240                                                             8434
c **                                                                        8435
  220 if (xc(1).eq.0..and.xc(2).eq.0.) go to 370                            8436
      if (xc(2).eq.0.) go to 230                                            8437
      if (xc(2).lt.0..or.abs(alog10(abs(xc(2)))*xc(1)).gt.fdi) go to        8438
     1370                                                                   8439
  230 alx=xc(1)                                                             8440
      xc(1)=xc(2)**xc(1)                                                    8441
  240 xc(2)=xc(3)                                                           8442
      xc(3)=xc(4)                                                           8443
  250 alo=-fdi                                                              8444
      if (xc(1).ne.0.) alo=alog10(abs(xc(1)))                               8445
      go to 360                                                             8446
c                                                                           8447
c   <  >  <> SI CO LX                                                       8448
c <                                                                         8449
  260 c(1)=xc(1)                                                            8450
      do 270 i=1,3                                                          8451
  270   xc(i)=xc(i+1)                                                       8452
      xc(4)=c(1)                                                            8453
      go to 250                                                             8454
c >                                                                         8455
  280 c(1)=xc(4)                                                            8456
      do 290 i=4,2,-1                                                       8457
  290   xc(i)=xc(i-1)                                                       8458
      xc(1)=c(1)                                                            8459
      go to 250                                                             8460
c <>                                                                        8461
  300 c(1)=xc(1)                                                            8462
      xc(1)=xc(2)                                                           8463
      xc(2)=c(1)                                                            8464
      go to 250                                                             8465
c SI , CO                                                                   8466
  310 alx=xc(1)                                                             8467
      xc(1)=sin(fak*xc(1))                                                  8468
      go to 250                                                             8469
  320 alx=xc(1)                                                             8470
      xc(1)=cos(fak*xc(1))                                                  8471
      go to 250                                                             8472
c LX                                                                        8473
  330 c(1)=alx                                                              8474
      go to 120                                                             8475
c                                                                           8476
  340 ier=1                                                                 8477
      write (ioa,430) xc,xm                                                 8478
  350 return                                                                8479
  360 write (ioa,430) xc,xm                                                 8480
      ier=2                                                                 8481
      return                                                                8482
  370 write (ioa,440)                                                       8483
      go to 340                                                             8484
c CS (change sign)                                                          8485
  380 xc(1)=-xc(1)                                                          8486
      go to 250                                                             8487
c 1/x                                                                       8488
  390 if (xc(1).eq.0.) go to 370                                            8489
      if (abs(alog10(abs(xc(1)))).gt.fdi) go to 370                         8490
c     alx=xc(1)                                                             8491
      xc(1)=1./xc(1)                                                        8492
      go to 250                                                             8493
c x**2                                                                      8494
  400 if (xc(1).eq.0.) go to 410                                            8495
      if (2.*abs(alog10(abs(xc(1)))).gt.fdi) go to 370                      8496
  410 alx=xc(1)                                                             8497
      xc(1)=xc(1)**2                                                        8498
      go to 250                                                             8499
c                                                                           8500
  420 if (xc(1).lt.0.) go to 370                                            8501
      alx=xc(1)                                                             8502
      xc(1)=sqrt(xc(1))                                                     8503
      go to 250                                                             8504
c                                                                           8505
c                                                                           8506
c                                                                           8507
  430 format (4g14.7,', M:',g14.7)                                          8508
  440 format ('  under- or overflow or invalid argument')                   8509
      end                                                                   8510
c #######======= 066                                                        8511
      subroutine pri (ila,k,j)                                              8512
c  transformation centered - primitive                                      8513
      common /prz/ kp(3,3,7),kz(3,3,7),kf(7)                                8514
      dimension k(3,2), j(3,2)                                              8515
      km=kf(ila)                                                            8516
      do 20 i=1,2                                                           8517
        do 20 l=1,3                                                         8518
        j(l,i)=0                                                            8519
        do 10 m=1,3                                                         8520
   10     j(l,i)=j(l,i)+k(m,i)*kp(m,l,ila)                                  8521
   20   j(l,i)=j(l,i)/km                                                    8522
      return                                                                8523
c                                                                           8524
c #######======= 067                                                        8525
      entry prir(ila,k,j)                                                   8526
c  tranformation primitive - centered                                       8527
      do 30 i=1,2                                                           8528
        do 30 l=1,3                                                         8529
        j(l,i)=0                                                            8530
        do 30 m=1,3                                                         8531
   30   j(l,i)=j(l,i)+k(m,i)*kz(m,l,ila)                                    8532
      return                                                                8533
      end                                                                   8534
c #######======= 068                                                        8535
      subroutine cepr (cp,ila)                                              8536
c  centered to primitive before Delaunay reduction                          8537
      common /tran/ acp(3,3),apc(3,3)                                       8538
      common /prz/ kp(3,3,7),kz(3,3,7),kf(7)                                8539
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik     8540
      dimension x(3,3), xx(3,3), cp(6), ccd(6)                              8541
c                                                                           8542
      call orth1 (cp,ccd,v0)                                                8543
c                                                                           8544
      do 10 i=1,3                                                           8545
        do 10 j=1,3                                                         8546
   10   xx(j,i)=0.                                                          8547
      do 20 i=1,3                                                           8548
   20   xx(i,i)=1.                                                          8549
c                                                                           8550
      call trd (xx,x,ccd)                                                   8551
c$$$$$$$$$$$$$$$$$$                                                         8552
c   hier war itd                                                            8553
c$$$$$$$$$$$$$$$$$$                                                         8554
      ff=kf(ila)                                                            8555
      do 40 i=1,3                                                           8556
        do 40 j=1,3                                                         8557
        xx(i,j)=0.                                                          8558
        do 30 m=1,3                                                         8559
   30     xx(i,j)=xx(i,j)+x(m,i)*float(kp(m,j,ila))                         8560
   40   xx(i,j)=xx(i,j)/ff                                                  8561
c                                                                           8562
      call xtodg (xx,cp)                                                    8563
      return                                                                8564
      end                                                                   8565
c #######======= 069                                                        8566
      subroutine xzd (ih1,ik1,il1,jh)                                       8567
c  determines zone defining reflections                                     8568
      dimension jh(3,2)                                                     8569
      n=1                                                                   8570
      ih=6*ih1                                                              8571
      ik=6*ik1                                                              8572
      il=6*il1                                                              8573
      if (ih.eq.0.and.il.eq.0) go to 10                                     8574
      jh(1,n)=il                                                            8575
      jh(2,n)=0                                                             8576
      jh(3,n)=-ih                                                           8577
      n=2                                                                   8578
   10 if (il.eq.0.and.ik.eq.0) go to 20                                     8579
      jh(1,n)=0                                                             8580
      jh(2,n)=-il                                                           8581
      jh(3,n)=ik                                                            8582
      if (n.eq.1) go to 20                                                  8583
      call vp (jh,j1,j2,j3,0,iz)                                            8584
      if (j1.ne.0.or.j2.ne.0.or.j3.ne.0) return                             8585
   20 jh(1,2)=ik                                                            8586
      jh(2,2)=-ih                                                           8587
      jh(3,2)=0                                                             8588
      return                                                                8589
      end                                                                   8590
c #######======= 070                                                        8591
      subroutine vp (j,j1,j2,j3,i,iz)                                       8592
c  vector product, integers                                                 8593
      dimension j(3,2)                                                      8594
      j1=j(2,1)*j(3,2)-j(3,1)*j(2,2)                                        8595
      j2=j(3,1)*j(1,2)-j(1,1)*j(3,2)                                        8596
      j3=j(1,1)*j(2,2)-j(2,1)*j(1,2)                                        8597
      iz=igt(j1,j2,j3)                                                      8598
      if (i.eq.0) return                                                    8599
      j1=j1/iz                                                              8600
      j2=j2/iz                                                              8601
      j3=j3/iz                                                              8602
      return                                                                8603
      end                                                                   8604
c #######======= 071                                                        8605
      subroutine fvp (x,x1,x2,x3,x11,sw)                                    8606
c  vector product, floating point                                           8607
      dimension x(3,2)                                                      8608
      x1=x(2,1)*x(3,2)-x(3,1)*x(2,2)                                        8609
      x2=x(3,1)*x(1,2)-x(1,1)*x(3,2)                                        8610
      x3=x(1,1)*x(2,2)-x(2,1)*x(1,2)                                        8611
      x11=sqrt(x1**2+x2**2+x3**2)                                           8612
      sw=x(1,1)**2+x(2,1)**2+x(3,1)**2                                      8613
      sw=sw*(x(1,2)**2+x(2,2)**2+x(3,2)**2)                                 8614
      sw=x11/amax1(.00001,sqrt(sw))                                         8615
      sw=amin1(1.,sw)                                                       8616
      sw=amax1(-1.,sw)                                                      8617
      return                                                                8618
      end                                                                   8619
c #######======= 072                                                        8620
      subroutine orth (rg,dg,cr,cd,v0,sg)                                   8621
c orthogonalization, matrix                                                 8622
      dimension cr(6), rg(6), dg(6), cd(6)                                  8623
      cr(1)=rg(1)                                                           8624
      sg=sqrt(1.-rg(6)*rg(6))                                               8625
      cr(2)=rg(2)*rg(6)                                                     8626
      cr(3)=rg(3)*rg(5)                                                     8627
      cr(4)=rg(2)*sg                                                        8628
      cr(5)=rg(3)*(rg(4)-rg(5)*rg(6))/sg                                    8629
      cr(6)=1./dg(3)                                                        8630
      cd(1)=1./cr(1)                                                        8631
      cd(2)=-cr(2)*cr(6)*v0                                                 8632
      cd(3)=(cr(2)*cr(5)-cr(3)*cr(4))*v0                                    8633
      cd(4)=cr(1)*cr(6)*v0                                                  8634
      cd(5)=-cr(1)*cr(5)*v0                                                 8635
      cd(6)=cr(1)*cr(4)*v0                                                  8636
      return                                                                8637
      end                                                                   8638
c #######======= 073                                                        8639
      subroutine orth1 (dg,cd,v0)                                           8640
c orthogonalization, matrix                                                 8641
      dimension cd(6), dg(6)                                                8642
      cd(1)=dg(1)                                                           8643
      sg=sqrt(1.-dg(6)*dg(6))                                               8644
      cd(2)=dg(2)*dg(6)                                                     8645
      cd(3)=dg(3)*dg(5)                                                     8646
      cd(4)=dg(2)*sg                                                        8647
      cd(5)=dg(3)*(dg(4)-dg(5)*dg(6))/sg                                    8648
      cd(6)=v0/(dg(1)*dg(2)*sg)                                             8649
      return                                                                8650
      end                                                                   8651
c #######======= 074                                                        8652
      subroutine tr (x,xx,cd)                                               8653
c orthogonalization, reciprocal space                                       8654
      dimension x(3,3), xx(3,3), cd(6)                                      8655
      do 10 i=1,3                                                           8656
        xx(1,i)=x(1,i)*cd(1)+x(2,i)*cd(2)+x(3,i)*cd(3)                      8657
        xx(2,i)=x(2,i)*cd(4)+x(3,i)*cd(5)                                   8658
   10   xx(3,i)=x(3,i)*cd(6)                                                8659
      return                                                                8660
      end                                                                   8661
c #######======= 075                                                        8662
      subroutine trd (x,xx,cd)                                              8663
c orthogonalization, direct space                                           8664
      dimension x(3,3), xx(3,3), cd(6)                                      8665
      do 10 i=1,3                                                           8666
        xx(3,i)=x(1,i)*cd(3)+x(2,i)*cd(5)+x(3,i)*cd(6)                      8667
        xx(2,i)=x(1,i)*cd(2)+x(2,i)*cd(4)                                   8668
   10   xx(1,i)=x(1,i)*cd(1)                                                8669
      return                                                                8670
      end                                                                   8671
c #######======= 076                                                        8672
      subroutine xtodg (xx,dg)                                              8673
c transf. cartesian coordinates > cell param.                               8674
      dimension xx(3,3), dg(6)                                              8675
      do 10 i=1,3                                                           8676
   10   dg(i)=sqrt(xx(1,i)**2+xx(2,i)**2+xx(3,i)**2)                        8677
c                                                                           8678
      dg(4)=(xx(1,2)*xx(1,3)+xx(2,2)*xx(2,3)+xx(3,2)*xx(3,3))/(dg(2)*       8679
     1dg(3))                                                                8680
      dg(5)=(xx(1,1)*xx(1,3)+xx(2,1)*xx(2,3)+xx(3,1)*xx(3,3))/(dg(1)*       8681
     1dg(3))                                                                8682
      dg(6)=(xx(1,2)*xx(1,1)+xx(2,2)*xx(2,1)+xx(3,2)*xx(3,1))/(dg(2)*       8683
     1dg(1))                                                                8684
      return                                                                8685
      end                                                                   8686
c #######======= 077                                                        8687
      subroutine prim (ila,ll,kk)                                           8688
c  indices of primitive mesh                                                8689
      dimension k(3,2), kk(3,2), ll(3,2)                                    8690
      call pri (ila,ll,k)                                                   8691
   10 ip=0                                                                  8692
      do 20 i=1,3                                                           8693
   20   if (k(i,1).eq.0.and.k(i,2).eq.0) ip=i                               8694
      if (ip.eq.0) go to 40                                                 8695
      do 30 i=1,2                                                           8696
        do 30 j=1,3                                                         8697
   30   k(j,i)=0                                                            8698
      i=mod(ip,3)+1                                                         8699
      j=mod(i,3)+1                                                          8700
      k(i,1)=1                                                              8701
      k(j,2)=1                                                              8702
      go to 150                                                             8703
   40 call vp (k,i1,i2,i3,0,igv)                                            8704
      do 60 i=1,2                                                           8705
        ig1=igt(k(1,i),k(2,i),k(3,i))                                       8706
        if (ig1.eq.1) go to 60                                              8707
        do 50 j=1,3                                                         8708
   50     k(j,i)=k(j,i)/ig1                                                 8709
        igv=igv/ig1                                                         8710
   60 continue                                                              8711
      if (igv.eq.1) go to 140                                               8712
      do 110 i=1,3                                                          8713
        iki=i                                                               8714
        if (k(i,1).eq.0.or.k(i,2).eq.0) go to 110                           8715
        if (k(i,1).gt.0) go to 80                                           8716
        do 70 j=1,3                                                         8717
   70     k(j,1)=-k(j,1)                                                    8718
   80   if (k(i,2).gt.0) go to 100                                          8719
        do 90 j=1,3                                                         8720
   90     k(j,2)=-k(j,2)                                                    8721
  100   call ggt1 (k(i,2),igv,ig1,i3)                                       8722
        if (i3) 120,110,120                                                 8723
  110 continue                                                              8724
  120 ib=-mod(k(iki,1)*i3,igv)                                              8725
      do 130 i=1,3                                                          8726
  130   k(i,1)=(ig1*k(i,1)+ib*k(i,2))/igv                                   8727
  140 call mini (k)                                                         8728
      call vp (k,i1,i2,i3,0,igv)                                            8729
      if (igv.gt.1) go to 10                                                8730
  150 call prir (ila,k,kk)                                                  8731
      call mini (kk)                                                        8732
      call chgs (kk)                                                        8733
      return                                                                8734
      end                                                                   8735
c #######======= 078                                                        8736
      integer function igt(i,j,k)                                           8737
c  GGT of 3 integers                                                        8738
      if (i.eq.0.or.j.eq.0) go to 10                                        8739
      call ggt1 (i,j,iii,i1)                                                8740
      go to 20                                                              8741
   10 iii=max0(iabs(i),iabs(j))                                             8742
   20 if (iii.eq.0.or.k.eq.0) go to 30                                      8743
      call ggt1 (iii,k,iu,i1)                                               8744
      go to 40                                                              8745
   30 iu=max0(iabs(iii),iabs(k))                                            8746
   40 igt=max0(iu,1)                                                        8747
      return                                                                8748
      end                                                                   8749
c #######======= 079                                                        8750
      subroutine ggt1 (i11,i22,i2,ix2)                                      8751
c  extended euclidean algorithm                                             8752
      i1=i11                                                                8753
      i2=i22                                                                8754
      ix1=1                                                                 8755
      ix2=0                                                                 8756
      iy1=0                                                                 8757
      iy2=1                                                                 8758
   10 id2=mod(i1,i2)                                                        8759
      if (id2.eq.0) go to 20                                                8760
      id=-i1/i2                                                             8761
      id1=id*ix2+ix1                                                        8762
      ix1=ix2                                                               8763
      ix2=id1                                                               8764
      id1=id*iy2+iy1                                                        8765
      iy1=iy2                                                               8766
      iy2=id1                                                               8767
      i1=i2                                                                 8768
      i2=id2                                                                8769
      go to 10                                                              8770
   20 i2=iabs(i2)                                                           8771
      return                                                                8772
      end                                                                   8773
c #######======= 080                                                        8774
      subroutine lind (i4,i5,i7)                                            8775
c determines coefficients x,y: hkl = x*hkl1 + y*hkl2  (MU>1)                8776
      dimension i4(3,2), i5(3,2), i7(2,2)                                   8777
      i1=1                                                                  8778
      i2=2                                                                  8779
   10 id=i5(i1,1)*i5(i2,2)-i5(i1,2)*i5(i2,1)                                8780
      if (id.ne.0) go to 20                                                 8781
      if (i2.eq.3) i1=2                                                     8782
      i2=3                                                                  8783
      go to 10                                                              8784
   20 i7(1,1)=(i4(i1,1)*i5(i2,2)-i4(i2,1)*i5(i1,2))/id                      8785
      i7(2,1)=(i4(i2,1)*i5(i1,1)-i4(i1,1)*i5(i2,1))/id                      8786
      i7(1,2)=(i4(i1,2)*i5(i2,2)-i4(i2,2)*i5(i1,2))/id                      8787
      i7(2,2)=(i4(i2,2)*i5(i1,1)-i4(i1,2)*i5(i2,1))/id                      8788
      return                                                                8789
      end                                                                   8790
c #######======= 081                                                        8791
      subroutine uni (r1,r2,wi,r1n,r2n,win,r3n,fak,ie)                      8792
c unique mesh                                                               8793
      dimension x(3,3)                                                      8794
      ie=0                                                                  8795
      do 10 i=1,3                                                           8796
        do 10 j=1,3                                                         8797
   10   x(j,i)=0.                                                           8798
      x(1,1)=r1                                                             8799
      x(1,2)=r2*cos(fak*wi)                                                 8800
      x(2,2)=r2*sin(fak*wi)                                                 8801
      call mini1 (x,1,2)                                                    8802
      call mini1 (x,2,1)                                                    8803
      call mini1 (x,1,2)                                                    8804
      call mini1 (x,2,1)                                                    8805
      r1n=sqrt(x(1,1)**2+x(2,1)**2+x(3,1)**2)                               8806
      r2n=sqrt(x(1,2)**2+x(2,2)**2+x(3,2)**2)                               8807
      win=abs((x(1,1)*x(1,2)+x(2,1)*x(2,2)+x(3,1)*x(3,2))/(r1n*r2n))        8808
      r3n=sqrt(r1n**2+r2n**2-2.*r1n*r2n*win)                                8809
      win=arco(win)/fak                                                     8810
      if (abs(wi-win).gt..01) ie=1                                          8811
      if (ie.eq.0.and.r1n.ne.r2n.and.r1n.eq.amax1(r1n,r2n)) ie=2            8812
      d=r1n+r2n                                                             8813
      r1n=amin1(r1n,r2n)                                                    8814
      r2n=d-r1n                                                             8815
      return                                                                8816
      end                                                                   8817
c #######======= 082                                                        8818
      subroutine mini (k)                                                   8819
c  minimal. length of basic vectors                                         8820
      dimension k(3,2)                                                      8821
      id=0                                                                  8822
   10 is=0                                                                  8823
      do 20 i=1,2                                                           8824
        do 20 j=1,3                                                         8825
   20   is=is+k(j,i)**2                                                     8826
      if (id.eq.0) go to 30                                                 8827
      if (is.ge.is0) return                                                 8828
   30 is0=is                                                                8829
      id=1                                                                  8830
      do 40 i=1,2                                                           8831
        m=3-i                                                               8832
        al=float(k(1,1)*k(1,2)+k(2,1)*k(2,2)+k(3,1)*k(3,2))/float(k(1,m)    8833
     1   **2+k(2,m)**2+k(3,m)**2)                                           8834
        il=al+sign(.5,al)                                                   8835
        do 40 j=1,3                                                         8836
   40   k(j,i)=k(j,i)-il*k(j,m)                                             8837
      go to 10                                                              8838
      end                                                                   8839
c #######======= 083                                                        8840
      subroutine mini1 (xx,i1,i2)                                           8841
c  minimal. length of basic vectors                                         8842
      dimension xx(3,3)                                                     8843
      al=xx(1,i1)*xx(1,i2)+xx(2,i1)*xx(2,i2)+xx(3,i1)*xx(3,i2)              8844
      n1=al/(xx(1,i2)**2+xx(2,i2)**2+xx(3,i2)**2)+sign(.5,al)               8845
      fn1=n1                                                                8846
      do 10 i=1,3                                                           8847
   10   xx(i,i1)=xx(i,i1)-fn1*xx(i,i2)                                      8848
      return                                                                8849
      end                                                                   8850
c #######======= 084                                                        8851
      subroutine minni (xx,j)                                               8852
c reduced cell: minimalization of lengths                                   8853
      dimension xx(3,3)                                                     8854
      do 10 iii=1,j                                                         8855
        call mini1 (xx,1,2)                                                 8856
        call mini1 (xx,2,1)                                                 8857
        call mini1 (xx,1,3)                                                 8858
        call mini1 (xx,3,1)                                                 8859
        call mini1 (xx,2,3)                                                 8860
   10   call mini1 (xx,3,2)                                                 8861
      return                                                                8862
      end                                                                   8863
c #######======= 085                                                        8864
      subroutine chec (ila,k,iz,ixj)                                        8865
c  GGT of components of a vector                                            8866
      dimension k(3,2), j(3,2), ixj(3)                                      8867
      call pri (ila,k,j)                                                    8868
      call vp (j,i1,i2,i3,0,iz)                                             8869
      ixj(1)=i1                                                             8870
      ixj(2)=i2                                                             8871
      ixj(3)=i3                                                             8872
      return                                                                8873
      end                                                                   8874
c #######======= 086                                                        8875
      subroutine ord (dg,i,j)                                               8876
c interchanges cell param.                                                  8877
      dimension dg(6)                                                       8878
      du=dg(i)                                                              8879
      dg(i)=dg(j)                                                           8880
      dg(j)=du                                                              8881
      du=dg(i+3)                                                            8882
      dg(i+3)=dg(j+3)                                                       8883
      dg(j+3)=du                                                            8884
      return                                                                8885
      end                                                                   8886
c #######======= 087                                                        8887
      subroutine vert (i4,i5)                                               8888
c  sequence of vectors defining the primitive mesh                          8889
      dimension i4(6), i5(6), i(6)                                          8890
      do 10 j=1,3                                                           8891
        i(j)=i4(j)                                                          8892
   10   i(j+3)=i5(j+3)                                                      8893
      call vp (i,j1,j2,j3,0,iz)                                             8894
      if (iabs(j1)+iabs(j2)+iabs(j3).eq.0) go to 30                         8895
      do 20 j=1,3                                                           8896
        i(j)=i4(j+3)                                                        8897
   20   i(j+3)=i5(j)                                                        8898
      call vp (i,j1,j2,j3,0,iz)                                             8899
      if (iabs(j1)+iabs(j2)+iabs(j3).ne.0) return                           8900
   30 do 40 j=1,3                                                           8901
        i(j)=i5(j)                                                          8902
        i5(j)=i5(j+3)                                                       8903
   40   i5(j+3)=i(j)                                                        8904
      return                                                                8905
      end                                                                   8906
c #######======= 088                                                        8907
      subroutine dire (dg,rg,rgw,fakr,v0,ier)                               8908
c  rec. cell param. and volume from dir. cell param. and vice versa         8909
      dimension rg(6), dg(6), rgw(3)                                        8910
      ier=0                                                                 8911
      v=1.-dg(4)**2-dg(5)**2-dg(6)**2+2.*dg(4)*dg(5)*dg(6)                  8912
      if (v.gt.1.e-07) go to 10                                             8913
      ier=1                                                                 8914
      return                                                                8915
   10 v0=dg(1)*dg(2)*dg(3)*sqrt(v)                                          8916
      if (v0.ge.1.e-07) go to 20                                            8917
      ier=1                                                                 8918
      return                                                                8919
   20 v1=1./v0                                                              8920
      sa=sqrt(1.-dg(4)*dg(4))                                               8921
      sb=sqrt(1.-dg(5)*dg(5))                                               8922
      sg=sqrt(1.-dg(6)*dg(6))                                               8923
      rg(1)=dg(2)*dg(3)*sa*v1                                               8924
      rg(2)=dg(3)*dg(1)*sb*v1                                               8925
      rg(3)=dg(1)*dg(2)*sg*v1                                               8926
      rg(4)=(dg(5)*dg(6)-dg(4))/(sb*sg)                                     8927
      rg(5)=(dg(6)*dg(4)-dg(5))/(sg*sa)                                     8928
      rg(6)=(dg(4)*dg(5)-dg(6))/(sa*sb)                                     8929
      rgw(1)=fakr*acos(rg(4))                                               8930
      rgw(2)=fakr*acos(rg(5))                                               8931
      rgw(3)=fakr*acos(rg(6))                                               8932
      do 30 i=1,3                                                           8933
        if (abs(rgw(i)-90.).gt..0001) go to 30                              8934
        rgw(i)=90.                                                          8935
        rg(i+3)=0.                                                          8936
   30 continue                                                              8937
      if (abs(rgw(3)-120.).gt..0001) go to 40                               8938
      rgw(3)=120.                                                           8939
      rg(6)=-.5                                                             8940
      return                                                                8941
   40 if (abs(rgw(3)-60.).gt..0001) return                                  8942
      rgw(3)=60.                                                            8943
      rg(6)=.5                                                              8944
      return                                                                8945
      end                                                                   8946
c #######======= 089                                                        8947
      subroutine cksys (is,ac,iers,dw,dv)                                   8948
c check for correctness of the assumed crystal class                        8949
      dimension ac(6)                                                       8950
      iers=0                                                                8951
      go to (30,10,10,10,20,10),is                                          8952
c monoclinic                                                                8953
   10 if (abs(ac(6)-90.).gt.dw) go to 50                                    8954
   20 if (abs(ac(4)-90.).gt.dw) go to 50                                    8955
      if (is.eq.2) return                                                   8956
c orthorhombic                                                              8957
      if (abs(ac(5)-90.).gt.dw) go to 50                                    8958
      if (is.eq.3) return                                                   8959
c tetragonal                                                                8960
      if (abs((ac(1)-ac(2))/(ac(1)+ac(2))).gt.dv) go to 50                  8961
      if (is.eq.4) return                                                   8962
      if (is.eq.6) go to 40                                                 8963
c hexagonal                                                                 8964
      if (abs(ac(6)-120.).gt.dw) go to 50                                   8965
   30 return                                                                8966
c cubic                                                                     8967
   40 if (abs((ac(1)-ac(3))/(ac(1)+ac(3))).gt.dv) go to 50                  8968
      if (abs((ac(3)-ac(2))/(ac(3)+ac(2))).gt.dv) go to 50                  8969
      return                                                                8970
   50 iers=1                                                                8971
      return                                                                8972
      end                                                                   8973
c #######======= 090                                                        8974
      subroutine del1 (dg,dgw,v0,dgd,dgdw)                                  8975
c reduced cell                                                              8976
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      8977
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      8978
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        8979
      dimension x(3,3), xx(3,3), cd(6)                                      8980
      dimension dg(6), dgw(3), dgd(6), dgdw(3), x111(3,4)                   8981
      call orth1 (dg,cd,v0)                                                 8982
      do 10 i=1,3                                                           8983
        do 10 j=1,3                                                         8984
   10   x(j,i)=0.                                                           8985
      do 20 i=1,3                                                           8986
   20   x(i,i)=1.                                                           8987
      call tr (x,xx,cd)                                                     8988
c                                                                           8989
      do 70 jj=1,2                                                          8990
        call minni (xx,3)                                                   8991
        do 30 i=1,3                                                         8992
          x111(i,1)=xx(i,1)+xx(i,2)+xx(i,3)                                 8993
          x111(i,2)=xx(i,1)+xx(i,2)-xx(i,3)                                 8994
          x111(i,3)=xx(i,1)-xx(i,2)+xx(i,3)                                 8995
   30     x111(i,4)=-xx(i,1)+xx(i,2)+xx(i,3)                                8996
        fmi=1.e20                                                           8997
        do 40 i=1,4                                                         8998
          s111=x111(1,i)**2+x111(2,i)**2+x111(3,i)**2                       8999
          if (s111.lt.fmi) k=i                                              9000
   40     fmi=amin1(fmi,s111)                                               9001
        fmi=sqrt(fmi)+.0001                                                 9002
c                                                                           9003
        do 50 i=1,3                                                         9004
   50     dg(i)=sqrt(xx(1,i)**2+xx(2,i)**2+xx(3,i)**2)                      9005
        if (fmi.ge.dg(1).and.fmi.ge.dg(2).and.fmi.ge.dg(3)) go to 80        9006
        j=1                                                                 9007
        if (dg(2).gt.dg(1)) j=2                                             9008
        if (dg(3).gt.amax1(dg(1),dg(2))) j=3                                9009
        do 60 i=1,3                                                         9010
   60     xx(i,j)=x111(i,k)                                                 9011
   70 continue                                                              9012
c                                                                           9013
   80 call xtodg (xx,dg)                                                    9014
      call orden (dg,dgw,fakr)                                              9015
      do 90 i=1,3                                                           9016
        dgd(i)=dg(i)                                                        9017
        dgd(i+3)=dg(i+3)                                                    9018
   90   dgdw(i)=dgw(i)                                                      9019
      return                                                                9020
      end                                                                   9021
c #######======= 091                                                        9022
      subroutine orden (dg,dgw,fakr)                                        9023
c reduced cell: sequence of a, b, c                                         9024
      dimension dg(6), dgw(3)                                               9025
      if (dg(4)*dg(5)*dg(6).le.0.) go to 20                                 9026
      do 10 i=4,6                                                           9027
   10   dg(i)=abs(dg(i))                                                    9028
      go to 40                                                              9029
c                                                                           9030
   20 do 30 i=4,6                                                           9031
   30   dg(i)=-abs(dg(i))                                                   9032
c                                                                           9033
   40 if (dg(3).lt.dg(2)) call ord (dg,2,3)                                 9034
      if (dg(1).le.dg(2)) go to 50                                          9035
      call ord (dg,1,2)                                                     9036
      go to 40                                                              9037
c                                                                           9038
   50 do 60 i=1,3                                                           9039
   60   dgw(i)=acos(dg(i+3))*fakr                                           9040
      return                                                                9041
      end                                                                   9042
c #######======= 092                                                        9043
      subroutine ca (cr,cd,v0,in,io,ioa,fk,ila,jsm,iiv,ilo,r,rz0,rz1,       9044
     1win,yzx,ydx,aq,ny1)                                                   9045
c metric calculations in reciprocal and direct space                        9046
      parameter (llin=78)                                                   9047
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,      9048
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,      9049
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr                                        9050
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     9051
      dimension cr(6), cd(6), fk(7), ah(3,3), hh(3,3), d(3), r(3),          9052
     1aq(llin), i4(6), i5(6), ih(3,3), aah(3,2), iih(3,2), jsm(7), jh(3,    9053
     22), jk(3,2), jd(3,2), bh(3,3), hd(3,3), hd2(3,2), dh(3,2), ax(3),     9054
     3ixj(3), iq(3)                                                         9055
c                                                                           9056
      equivalence (aah(1,1),ah(1,1)), (iih(1,1),ih(1,1)), (hd2(1,1),        9057
     1hd(1,1))                                                              9058
      character*1 jsm,aw,aq                                                 9059
      logical law                                                           9060
      ny=iabs(ny1)                                                          9061
      nz=1                                                                  9062
      if (ny1.lt.0) nz=2                                                    9063
      ifk=fk(ila)                                                           9064
      ak1=ak                                                                9065
      ila1=ila                                                              9066
   10 ipa=0                                                                 9067
      ilz=0                                                                 9068
      nm=0                                                                  9069
      if (iiv.eq.1) go to 40                                                9070
      write (io,730)                                                        9071
      if (io.ne.ioa) write (ioa,730)                                        9072
      call les (in)                                                         9073
      if (n.eq.0.or.c(1)**2+c(2)**2+c(3)**2.lt..0001) go to 560             9074
      write (io,600)                                                        9075
      if (io.ne.ioa) write (ioa,600)                                        9076
      do 20 i=1,6                                                           9077
        if (ndi(i).gt.mdi) go to 560                                        9078
   20 continue                                                              9079
      do 30 i=7,9                                                           9080
        if (ndi(i).gt.mdi) go to 560                                        9081
   30 continue                                                              9082
      ilo=0                                                                 9083
      go to 60                                                              9084
c                                                                           9085
   40 nm=1                                                                  9086
      ak1=1.                                                                9087
      ila1=1                                                                9088
      ilo=0                                                                 9089
      write (io,800)                                                        9090
      if (io.ne.ioa) write (ioa,800)                                        9091
      call les (in)                                                         9092
      if (n.eq.0) go to 560                                                 9093
      do 50 i=1,3                                                           9094
        c(i)=c(i)-c(i+6)                                                    9095
   50   c(i+3)=c(i+3)-c(i+6)                                                9096
      if (c(1)**2+c(2)**2+c(3)**2.lt..0001) go to 560                       9097
c                                                                           9098
   60 do 70 i=1,6                                                           9099
   70   i4(i)=c(i)+sign(.5,c(i))                                            9100
      if (c(7).lt.0.) go to 80                                              9101
      rz0=c(7)                                                              9102
      phi=atan(rz0/akl)*fakr                                                9103
      go to 90                                                              9104
   80 phi=-c(7)                                                             9105
      phi=amod(phi,180.)                                                    9106
      if (phi.gt.90.) phi=180.-phi                                          9107
      phi=amin1(phi,89.999)                                                 9108
      rz0=akl*tan(phi/fakr)                                                 9109
   90 rzo=amin1(rz0,9999.9)                                                 9110
c                                                                           9111
      izo=0                                                                 9112
      if (abs(c(8))+abs(c(9))+abs(c(10)).lt..5) go to 100                   9113
      izo=1                                                                 9114
c                                                                           9115
  100 nm=0                                                                  9116
      do 110 i=1,2                                                          9117
        i1=3*(i-1)                                                          9118
        do 110 j=1,3                                                        9119
        ah(j,i)=c(j+i1)                                                     9120
        if (nm.eq.0.and.abs(amod(ah(j,i),1.)).gt..0001) nm=1                9121
        ih(j,i)=ah(j,i)                                                     9122
  110 continue                                                              9123
      if (nm) 120,120,590                                                   9124
  120 do 130 i=1,2                                                          9125
        call ckex (ih,ila1,i,ie)                                            9126
        if (ie.ne.0) go to 570                                              9127
  130 continue                                                              9128
  140 do 150 i=1,3                                                          9129
        ih(i,3)=ih(i,2)-ih(i,1)                                             9130
  150   ah(i,3)=ah(i,2)-ah(i,1)                                             9131
      if (nm.eq.0) call vp (iih,j1,j2,j3,0,iz)                              9132
      if (nm.eq.1) call fvp (aah,x1,x2,x3,x11,sw)                           9133
      if (iiv.eq.0) call tr (ah,hh,cr)                                      9134
      if (iiv.eq.1) call trd (ah,hh,cd)                                     9135
      do 160 i=1,3                                                          9136
  160   d(i)=sqrt(hh(1,i)**2+hh(2,i)**2+hh(3,i)**2)                         9137
      r(1)=ak1*d(1)                                                         9138
      d(1)=1./d(1)                                                          9139
      if (d(2).lt..00001) go to (230,550),iiv+1                             9140
      r(2)=ak1*d(2)                                                         9141
      r(3)=ak1*d(3)                                                         9142
      d(2)=1./d(2)                                                          9143
      d(3)=amax1(d(3),.00001)                                               9144
      if (d(3).gt..000011) d(3)=1./d(3)                                     9145
      cwin=(hh(1,1)*hh(1,2)+hh(2,1)*hh(2,2)+hh(3,1)*hh(3,2))*d(1)*d(2)      9146
      win=fakr*arco(cwin)                                                   9147
      if (win.lt..03.or.win.gt.179.97.or.d(3).le..000011) go to (210,       9148
     1540),iiv+1                                                            9149
c                                                                           9150
      if (nm.eq.1.or.iiv.eq.1) go to 190                                    9151
c                                                                           9152
      call chec (ila,i4,iz,ixj)                                             9153
      cst=ak1*fk(ila)*d(1)*d(2)/(v0*amax1(.00001,sin(win/fakr)))            9154
      rz1=ra(rz0,ak1,iz,ala,cst)                                            9155
      cst=v0*amax1(.00001,sin(win/fakr))/(d(1)*d(2)*float(iz)*fk(ila))      9156
c                                                                           9157
      if (iz.eq.1) go to 170                                                9158
      call prim (ila,i4,i5)                                                 9159
      call vert (i4,i5)                                                     9160
      call chgs (i5)                                                        9161
      write (io,740) win,iz,i5,cst,rz1                                      9162
      if (io.ne.ioa) write (ioa,740) win,iz,i5,cst,rz1                      9163
      go to 180                                                             9164
  170 write (io,670) win,cst,rz1                                            9165
      if (io.ne.ioa) write (ioa,670) win,cst,rz1                            9166
  180 iz1=igt(j1,j2,j3)                                                     9167
      j1=j1/iz1                                                             9168
      j2=j2/iz1                                                             9169
      j3=j3/iz1                                                             9170
c+++++                                                                      9171
      write (io,690) (ih(j,1),j=1,3),d(1),r(1),phi,rzo,(ih(j,2),j=1,3),     9172
     1d(2),r(2),iz1,j1,j2,j3,(ih(j,3),j=1,3),d(3),r(3),ak1,hv               9173
      if (io.ne.ioa) write (ioa,690) (ih(j,1),j=1,3),d(1),r(1),phi,rzo,     9174
     1(ih(j,2),j=1,3),d(2),r(2),iz1,j1,j2,j3,(ih(j,3),j=1,3),d(3),r(3),     9175
     2ak1,hv                                                                9176
c+++++                                                                      9177
      ilo=1                                                                 9178
      go to 10                                                              9179
  190 if (iiv.eq.1) go to 200                                               9180
      write (io,760) win                                                    9181
      write (io,770) ((ah(j,i),j=1,3),d(i),r(i),i=1,2),x1,x2,x3,(ah(j,3)    9182
     1,j=1,3),d(3),r(3),ak1,hv                                              9183
      if (io.ne.ioa) write (ioa,760) win                                    9184
      if (io.ne.ioa) write (ioa,770) ((ah(j,i),j=1,3),d(i),r(i),i=1,2),     9185
     1x1,x2,x3,(ah(j,3),j=1,3),d(3),r(3),ak1,hv                             9186
      go to 10                                                              9187
  200 call fvp (ah,x1,x2,x3,x11,sw)                                         9188
      write (io,810) ((ah(j,i),j=1,3),r(i),i=1,2),win,(ah(j,3),j=1,3),      9189
     1r(3),x1,x2,x3                                                         9190
      if (io.ne.ioa) write (ioa,810) ((ah(j,i),j=1,3),r(i),i=1,2),win,      9191
     1(ah(j,3),j=1,3),r(3),x1,x2,x3                                         9192
      go to 10                                                              9193
c                                                                           9194
  210 ipa=1                                                                 9195
      write (ioa,720)                                                       9196
      i1=2                                                                  9197
      if (nm.eq.1) go to 220                                                9198
      write (io,620) (ih(j,2),j=1,3),d(2),r(2)                              9199
      if (io.ne.ioa) write (ioa,620) (ih(j,2),j=1,3),d(2),r(2)              9200
      go to 230                                                             9201
  220 write (io,750) i1,(ah(j,2),j=1,3),d(2),r(2),ak1,hv                    9202
      if (io.ne.ioa) write (ioa,750) i1,(ah(j,2),j=1,3),d(2),r(2),ak1,      9203
     1hv                                                                    9204
  230 i1=1                                                                  9205
      if (nm.eq.1) go to 530                                                9206
      if (ilz.eq.0) go to 240                                               9207
      write (io,710) (ih(j,1),j=1,3),jsm(ila),ak1,akl,hv                    9208
      if (io.ne.ioa) write (ioa,710) (ih(j,1),j=1,3),jsm(ila),ak1,akl,      9209
     1hv                                                                    9210
      go to 250                                                             9211
  240 write (io,700) (ih(j,1),j=1,3),d(1),r(1),ak1,akl,hv                   9212
      if (io.ne.ioa) write (ioa,700) (ih(j,1),j=1,3),d(1),r(1),ak1,akl,     9213
     1hv                                                                    9214
      if (ipa.eq.1) go to 10                                                9215
c                                                                           9216
  250 call xzd (ih(1,1),ih(2,1),ih(3,1),jh)                                 9217
      call prim (ila,jh,jk)                                                 9218
      do 260 i=1,3                                                          9219
        ah(i,1)=jk(i,1)                                                     9220
        ah(i,2)=jk(i,2)                                                     9221
  260   ah(i,3)=ah(i,2)-ah(i,1)                                             9222
      call tr (ah,hh,cr)                                                    9223
c                                                                           9224
      call mini1 (hh,1,2)                                                   9225
      call mini1 (hh,2,1)                                                   9226
      call tr (hh,ah,cd)                                                    9227
      do 270 i=1,2                                                          9228
        do 270 j=1,3                                                        9229
  270   jk(j,i)=ah(j,i)+sign(.5,ah(j,i))                                    9230
c                                                                           9231
      do 280 i=1,3                                                          9232
  280   d(i)=sqrt(hh(1,i)**2+hh(2,i)**2+hh(3,i)**2)                         9233
      if (d(1).le.d(2)) go to 300                                           9234
      win=d(1)                                                              9235
      d(1)=d(2)                                                             9236
      d(2)=win                                                              9237
      do 290 i=1,3                                                          9238
        j=jk(i,1)                                                           9239
        jk(i,1)=jk(i,2)                                                     9240
  290   jk(i,2)=j                                                           9241
c                                                                           9242
  300 r(1)=ak1*d(1)                                                         9243
      r(2)=ak1*d(2)                                                         9244
      d(1)=1./d(1)                                                          9245
      d(2)=1./d(2)                                                          9246
      cwin=(hh(1,1)*hh(1,2)+hh(2,1)*hh(2,2)+hh(3,1)*hh(3,2))*d(1)*d(2)      9247
      if (cwin.ge.0.) go to 320                                             9248
      cwin=-cwin                                                            9249
      do 310 i=1,3                                                          9250
  310   jk(i,1)=-jk(i,1)                                                    9251
  320 win=fakr*arco(cwin)                                                   9252
      r(3)=sqrt(r(1)**2+r(2)**2-2.*r(1)*r(2)*cwin)                          9253
c                                                                           9254
      call tr (ah,hh,cr)                                                    9255
c                                                                           9256
      cst=ak1*fk(ila)*d(1)*d(2)/(v0*amax1(.00001,sin(win/fakr)))            9257
      rz1=ra(rz0,ak1,1,ala,cst)                                             9258
      call chgs (jk)                                                        9259
      r1r1=r(1)                                                             9260
      r2r2=r(2)                                                             9261
      fak=1./fakr                                                           9262
      r3x=rr33(r1r1,r2r2,fak,win)                                           9263
c++++++                                                                     9264
      write (io,630) (ih(j,1),j=1,3),(jk(j,1),j=1,3),d(1),r(1),win,r3x,     9265
     1rz1,(jk(j,2),j=1,3),d(2),r(2),phi,rzo                                 9266
      if (io.ne.ioa) write (ioa,630) (ih(j,1),j=1,3),(jk(j,1),j=1,3),       9267
     1d(1),r(1),win,r3x,rz1,(jk(j,2),j=1,3),d(2),r(2),phi,rzo               9268
c                                                                           9269
c                                                                           9270
c test 1. Zone                                                              9271
c                                                                           9272
      call pri (ila,jk,jh)                                                  9273
      call vp (jh,j1,j2,j3,1,iz)                                            9274
c                                                                           9275
      do 330 i=1,3                                                          9276
        jd(i,1)=jh(i,1)                                                     9277
  330   jd(i,2)=0                                                           9278
      if (j1.eq.0.and.j2.eq.0) go to 340                                    9279
      if (j1.eq.0.and.j3.eq.0) go to 350                                    9280
      if (j2.eq.0.and.j3.eq.0) go to 360                                    9281
c                                                                           9282
      if (j1.eq.0) go to 370                                                9283
      if (j2.eq.0) go to 380                                                9284
      if (j3.eq.0) go to 390                                                9285
c                                                                           9286
      call ggt1 (j1,j2,i,j)                                                 9287
      if (i.eq.1) go to 390                                                 9288
      call ggt1 (j1,j3,i,j)                                                 9289
      if (i.eq.1) go to 380                                                 9290
      call ggt1 (j2,j3,i,j)                                                 9291
      if (i.eq.1) go to 370                                                 9292
c                                                                           9293
  340 jd(3,2)=1                                                             9294
      go to 400                                                             9295
c                                                                           9296
  350 jd(2,2)=1                                                             9297
      go to 400                                                             9298
c                                                                           9299
  360 jd(1,2)=1                                                             9300
      go to 400                                                             9301
c                                                                           9302
  370 call nnn (j2,j3,i1,i2)                                                9303
      jd(2,2)=i1                                                            9304
      jd(3,2)=i2                                                            9305
      go to 400                                                             9306
  380 call nnn (j1,j3,i1,i2)                                                9307
      jd(1,2)=i1                                                            9308
      jd(3,2)=i2                                                            9309
      go to 400                                                             9310
  390 call nnn (j1,j2,i1,i2)                                                9311
      jd(1,2)=i1                                                            9312
      jd(2,2)=i2                                                            9313
c                                                                           9314
  400 call prir (ila,jd,jh)                                                 9315
c                                                                           9316
      do 410 i=1,3                                                          9317
        bh(i,1)=jk(i,1)                                                     9318
        bh(i,2)=jk(i,2)                                                     9319
  410   bh(i,3)=jh(i,2)                                                     9320
c                                                                           9321
      call tr (bh,hd,cr)                                                    9322
c                                                                           9323
      call mini1 (hd,3,1)                                                   9324
      call mini1 (hd,3,2)                                                   9325
      call mini1 (hd,3,1)                                                   9326
      call mini1 (hd,3,2)                                                   9327
c                                                                           9328
      call fvp (hd2,x1,x2,x3,x11,sw)                                        9329
      rr=sqrt(hd(1,3)**2+hd(2,3)**2+hd(3,3)**2)                             9330
      hoh=rr*(x1*hd(1,3)+x2*hd(2,3)+x3*hd(3,3))/(x11*rr)                    9331
      ax(1)=x1/x11                                                          9332
      ax(2)=x2/x11                                                          9333
      ax(3)=x3/x11                                                          9334
      iju=0                                                                 9335
c                                                                           9336
      do 420 i=1,3                                                          9337
        dh(i,2)=hd(i,2)                                                     9338
  420   hd(i,2)=hd(i,3)-ax(i)*hoh                                           9339
c                                                                           9340
  430 dhd=1./amax1(sqrt(hd(1,2)**2+hd(2,2)**2+hd(3,2)**2),.00001)           9341
c                                                                           9342
      cw13=(hd(1,1)*hd(1,2)+hd(2,1)*hd(2,2)+hd(3,1)*hd(3,2))/amax1(.        9343
     100001,sqrt((hd(1,1)**2+hd(2,1)**2+hd(3,1)**2)*(hd(1,2)**2+hd(2,2)*    9344
     2*2+hd(3,2)**2)))                                                      9345
c                                                                           9346
      cw12=(dh(1,2)*hd(1,2)+dh(2,2)*hd(2,2)+dh(3,2)*hd(3,2))/amax1(.        9347
     100001,sqrt((dh(1,2)**2+dh(2,2)**2+dh(3,2)**2)*(hd(1,2)**2+hd(2,2)*    9348
     2*2+hd(3,2)**2)))                                                      9349
c                                                                           9350
      call fvp (hd2,x1,x2,x3,x11,sw13)                                      9351
      do 440 i=1,3                                                          9352
  440   dh(i,1)=hd(i,2)                                                     9353
      call fvp (dh,x1,x2,x3,x11,sw12)                                       9354
      dhd1=ak1/dhd                                                          9355
      if (iju.eq.1) go to 450                                               9356
      hoh=abs(hoh)                                                          9357
      dhoh=1./hoh                                                           9358
      hoh=ak1*hoh                                                           9359
c                                                                           9360
  450 call tr (hd,bh,cd)                                                    9361
c                                                                           9362
      do 460 j=1,3                                                          9363
  460   jd(j,2)=bh(j,3)+sign(.5,bh(j,3))                                    9364
c                                                                           9365
      w13=arco(cw13)*fakr                                                   9366
      if (iju.eq.1) go to 480                                               9367
      w12=arco(cw12)*fakr                                                   9368
      w123=w12+w13                                                          9369
      w234=w13-w12                                                          9370
      if (abs(w123-win).gt..05.and.abs(w234-win).gt..05) w13=-w13           9371
      if (w13.ge.0.) go to 480                                              9372
      w13=w13+180.                                                          9373
c                                                                           9374
      do 470 i=1,3                                                          9375
        bh(i,2)=-bh(i,2)                                                    9376
        bh(i,3)=-bh(i,3)                                                    9377
  470   jd(i,2)=-jd(i,2)                                                    9378
  480 if (w13.le.90.03) go to 500                                           9379
      do 490 i=1,3                                                          9380
        bh(i,2)=bh(i,2)+bh(i,1)                                             9381
  490   bh(i,3)=float(jd(i,2))+bh(i,1)                                      9382
      call tr (bh,hd,cr)                                                    9383
      iju=1                                                                 9384
      go to 430                                                             9385
  500 write (io,610) jd(1,2),jd(2,2),jd(3,2),dhoh,hoh,dhd1,w13              9386
      if (io.ne.ioa) write (ioa,610) jd(1,2),jd(2,2),jd(3,2),dhoh,hoh,      9387
     1dhd1,w13                                                              9388
c                                                                           9389
      if (izo.eq.0) go to 520                                               9390
      ih(1,1)=c(8)                                                          9391
      ih(2,1)=c(9)                                                          9392
      ih(3,1)=c(10)                                                         9393
      i=1                                                                   9394
      call ckex (ih,ila1,i,ie)                                              9395
      if (ie.eq.0) go to 510                                                9396
c                                                                           9397
      write (io,780) (ih(j,1),j=1,3),jsm(ila)                               9398
      if (io.ne.ioa) write (ioa,780) (ih(j,1),j=1,3),jsm(ila)               9399
      go to 520                                                             9400
c                                                                           9401
c      transformation of 2nd hkl-triple                                     9402
c                                                                           9403
  510 call bone (jk,jd,iq)                                                  9404
      write (io,840) ih(1,1),ih(2,1),ih(3,1),iq                             9405
      if (io.ne.ioa) write (ioa,840) ih(1,1),ih(2,1),ih(3,1),iq             9406
c                                                                           9407
  520 ilo=1                                                                 9408
      write (ioa,650)                                                       9409
      read (in,660,end=10) aw                                               9410
      if (law(aw)) call rpl (ioa,jk,r(1),r(2),win,yzx,fakr,ak1,akl,aq,      9411
     1rz0,rz1,dhd1,w13,ny,nz)                                               9412
      if (law(aw).and.io.ne.ioa) call rpl (io,jk,r(1),r(2),win,ydx,fakr,    9413
     1ak1,akl,aq,rz0,rz1,dhd1,w13,ny,nz)                                    9414
c wird 54(?) je erreicht?  JA!                                              9415
  530 if (nm.eq.1) write (io,750) i1,(ah(j,1),j=1,3),d(1),r(1),ak1,hv       9416
      if (nm.eq.0.and.io.ne.ioa) write (ioa,700) (ih(j,1),j=1,3),d(1),      9417
     1r(1),ak1,akl,hv                                                       9418
      if (nm.eq.0.and.io.ne.ioa) write (ioa,640) jk                         9419
      if (nm.eq.1.and.io.ne.ioa) write (ioa,750) i1,(ah(j,1),j=1,3),d(1)    9420
     1,r(1),ak1,hv                                                          9421
      go to 10                                                              9422
c                                                                           9423
  540 write (ioa,830)                                                       9424
      i1=2                                                                  9425
      write (io,820) i1,(ah(j,2),j=1,3),r(2)                                9426
      if (io.ne.ioa) write (ioa,820) i1,(ah(j,2),j=1,3),r(2)                9427
  550 i1=1                                                                  9428
      write (io,820) i1,(ah(j,1),j=1,3),r(1)                                9429
      if (io.ne.ioa) write (ioa,820) i1,(ah(j,1),j=1,3),r(1)                9430
      go to 10                                                              9431
c                                                                           9432
  560 write (ioa,680)                                                       9433
      return                                                                9434
c                                                                           9435
  570 if (iabs(ih(1,2))+iabs(ih(2,2))+iabs(ih(3,2)).ne.0) go to 580         9436
      ilz=1                                                                 9437
      go to 140                                                             9438
c                                                                           9439
  580 write (ioa,780) (ih(j,i),j=1,3),jsm(ila)                              9440
      nm=1                                                                  9441
      go to 140                                                             9442
c                                                                           9443
  590 if (iiv.eq.0) write (ioa,790)                                         9444
      nm=1                                                                  9445
      go to 140                                                             9446
c                                                                           9447
c                                                                           9448
c                                                                           9449
  600 format (' ====================')                                      9450
  610 format ('   reflection defining 1st L.z. (refers to origin "^" in     9451
     1the graph) :'/' hp:',3i4,', 1/d*:',f7.1,', [[dist.:',f5.1,', rp:',    9452
     2f6.1,', ang.(h1,rp):',f5.1,']]')                                      9453
  620 format (' h : ',3i5,',  d:',f8.4,',  r:',f8.2)                        9454
  630 format ('   reflections h1, h2, defining zone [',3i5,']:'/' h1:',     9455
     13i4,', d:',f6.2,', r:',f7.2,', ang.:',f5.1,', r3:',f6.2,', r(L1-0)    9456
     2:',f6.1/' h2:',3i4,f10.2,f11.2,13x,'phi:',f5.1,';   r(L0):',f7.1)     9457
  640 format (/' h1: ',3i5,', h2:',i4,2i5)                                  9458
  650 format (' omit graph?')                                               9459
  660 format (a1)                                                           9460
  670 format (18x,'angle:',f6.2,16x,'1/d*:',f8.3,', r(L1-0):',f8.1)         9461
  680 format (10x,' *** calculations finished ***')                         9462
  690 format ('   h1 ',3i5,'  d:',f8.4,'  r:',f8.2,3x,'phi:',f6.1,',  r(    9463
     1L0)  :',f8.1/'   h2 ',3i5,f12.4,f12.2,', h1 x h2:',i3,' x [',3i5,'    9464
     2]'/' h2-h1',3i5,f12.4,f12.2,',  c.c.:',f7.2,', volt:',f10.0/)         9465
  700 format (' h:',3i4,', d:',f7.4,', r:',f6.2,', cc:',f7.2,', cl:',f6.    9466
     10,', HV:',f8.0)                                                       9467
  710 format (' h:',3i5,', forbidden (cent.:',a1,'), cc:',f7.2,', cl:',     9468
     1f6.0', HV:',f9.0)                                                     9469
  720 format (' hkl(1) parallel hkl(2)')                                    9470
  730 format (' h1,k1,l1 (h2,k2,l2), [r(0. LZ), <0: phi(deg.)], (h,k,l t    9471
     1o be transformed)')                                                   9472
  740 format (' angle:',f6.2,', mult:',i2,' (',3i3,',',3i3,'), 1/d*:',      9473
     1f8.3,', r(L1-L0):',f7.1)                                              9474
  750 format ('   h',i1,2x,3f6.2,'  d:',f8.4,'  r:',f8.2,',  c.c.:',f7.     9475
     12,', volt:',f8.0)                                                     9476
  760 format (' angle:',f6.2)                                               9477
  770 format ('   h1  ',3f6.2,'  d:',f8.4,'  r:',f8.2/'   h2  ',3f6.2,      9478
     1f12.4,f12.2,' h1 x h2:',3f7.2/' h2-h1 ',3f6.2,f12.4,f12.2,',  c.c     9479
     2.:',f7.2,', volt:',f8.0)                                              9480
  780 format (' ***** ',3i5,' forbidden by ',a1,'-centering')               9481
  790 format ('   ***  non-integers ***')                                   9482
  800 format (' x1,y1,z1;  x2,y2,z2;  x0,y0,z0')                            9483
  810 format ('   x1  ',3f8.3,'  d:',f10.4/'   x2  ',3f8.3,4x,f10.4,'  a    9484
     1ngle:',f7.2/' x2-x1 ',3f8.3,4x,f10.4/' X1 x X2:',3f12.4)              9485
  820 format ('   x',i1,2x,3f8.4,'  d:',f10.4)                              9486
  830 format (' xyz(1) parallel xyz(2)')                                    9487
  840 format (7x,3i5,' --->',3i5)                                           9488
      end                                                                   9489
c #######======= 093                                                        9490
      subroutine ckex (ih,ila1,i,ie)                                        9491
c check extinctions conditioned by centering                                9492
      dimension ih(3,3)                                                     9493
      ie=0                                                                  9494
      go to (70,10,20,30,40,50,60),ila1                                     9495
   10 if (mod(ih(2,i)+ih(3,i),2)) 80,70,80                                  9496
   20 if (mod(ih(1,i)+ih(3,i),2)) 80,70,80                                  9497
   30 if (mod(ih(1,i)+ih(2,i),2)) 80,70,80                                  9498
   40 if (mod(ih(2,i)+ih(3,i)-ih(1,i),3)) 80,70,80                          9499
   50 if (mod(ih(1,i)+ih(2,i)+ih(3,i),2)) 80,70,80                          9500
   60 if (mod(ih(1,i)+ih(2,i),2).ne.0.or.mod(ih(2,i)+ih(3,i),2).ne.0)       9501
     1go to 80                                                              9502
   70 return                                                                9503
   80 ie=i                                                                  9504
      return                                                                9505
      end                                                                   9506
c #######======= 094                                                        9507
      subroutine bone (jk,jd,iq)                                            9508
c expresses h k l in terms of the coordinate system set up by CR            9509
c                                                                           9510
      dimension a(3,4), q(3), jk(3,2), jd(3,2), iq(3)                       9511
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     9512
c                                                                           9513
      a(1,1)=jk(1,1)                                                        9514
      a(2,1)=jk(2,1)                                                        9515
      a(3,1)=jk(3,1)                                                        9516
      a(1,2)=jk(1,2)                                                        9517
      a(2,2)=jk(2,2)                                                        9518
      a(3,2)=jk(3,2)                                                        9519
      a(1,3)=jd(1,2)                                                        9520
      a(2,3)=jd(2,2)                                                        9521
      a(3,3)=jd(3,2)                                                        9522
      a(1,4)=c(8)                                                           9523
      a(2,4)=c(9)                                                           9524
      a(3,4)=c(10)                                                          9525
c                                                                           9526
      call dit (0,det0,a)                                                   9527
c                                                                           9528
      do 10 jj=1,3                                                          9529
        jj1=jj                                                              9530
        call dit (jj1,q(jj1),a)                                             9531
   10   q(jj)=q(jj)/det0                                                    9532
c                                                                           9533
      do 20 i=1,3                                                           9534
   20   iq(i)=q(i)+sign(.5,q(i))                                            9535
      return                                                                9536
      end                                                                   9537
c #######======= 095                                                        9538
      subroutine dit (n,d,a)                                                9539
c determinants to solve 3 equations with 3 unknowns                         9540
c                                                                           9541
      dimension b(3,3), a(3,4)                                              9542
      do 30 k=1,3                                                           9543
        l=mod(k+n,4)                                                        9544
        if (l) 10,10,20                                                     9545
   10   l=4                                                                 9546
   20   b(1,k)=a(1,l)                                                       9547
        b(2,k)=a(2,l)                                                       9548
   30   b(3,k)=a(3,l)                                                       9549
      d=det(b)                                                              9550
      if (n.eq.2) d=-d                                                      9551
      return                                                                9552
      end                                                                   9553
c #######======= 096                                                        9554
      subroutine nnn (i1,i2,j2,j1)                                          9555
c find j1,j2: i1*j1+i2*j2=+-1                                               9556
c                                                                           9557
      ik11=0                                                                9558
      ik12=1                                                                9559
      ik21=1                                                                9560
      ik22=0                                                                9561
      ii1=i1                                                                9562
      ii2=i2                                                                9563
      j1=ik12                                                               9564
      j2=ik22                                                               9565
   10 iq=ii1/ii2                                                            9566
      id=ii1-iq*ii2                                                         9567
      if (id.eq.0) go to 20                                                 9568
      j1=ik11+iq*ik12                                                       9569
      j2=ik21+iq*ik22                                                       9570
      ii1=ii2                                                               9571
      ii2=id                                                                9572
      ik11=ik12                                                             9573
      ik12=j1                                                               9574
      ik21=ik22                                                             9575
      ik22=j2                                                               9576
      go to 10                                                              9577
   20 j1=-j1                                                                9578
      if (i1*j2+i2*j1.gt.0) return                                          9579
      j1=-j1                                                                9580
      j2=-j2                                                                9581
      return                                                                9582
      end                                                                   9583
c #######======= 097                                                        9584
      function alam (hv)                                                    9585
c wavelength from HV                                                        9586
      alam=12.2639/sqrt(hv*(1.+.97845e-06*hv))                              9587
      return                                                                9588
      end                                                                   9589
c #######======= 098                                                        9590
      subroutine test (r1,r2,r3,r4,wi,swi,dwi,fk,ie,in,io,ioa)              9591
c  angle from both r1-r2 and r1+r2                                          9592
      character*1 aw                                                        9593
      logical law                                                           9594
      ie=0                                                                  9595
      wi1=fk*arco((r1**2+r2**2-r3**2)/(2.*r1*r2))                           9596
      wi2=180.-fk*arco((r1**2+r2**2-r4**2)/(2.*r1*r2))                      9597
      d=(r3**2+r4**2-2.*(r1**2+r2**2))/(r1*r2)                              9598
      wi=.5*(wi1+wi2)                                                       9599
      dwi=amax1(swi,.7*abs(wi1-wi2))                                        9600
      write (io,20) wi1,wi2,wi,dwi,d                                        9601
      if (io.ne.ioa) write (ioa,20) wi1,wi2,wi,dwi,d                        9602
      read (in,30,end=10) aw                                                9603
      if (law(aw)) ie=1                                                     9604
      return                                                                9605
   10 ie=1                                                                  9606
      return                                                                9607
c                                                                           9608
c                                                                           9609
c                                                                           9610
   20 format (1x,'ang.(-):',f7.2,', ang.(+):',f7.2,', mean:',f7.2,' +-',    9611
     1f6.2,',  GOF:',f7.3/1x,'ok?')                                         9612
   30 format (a1)                                                           9613
      end                                                                   9614
c #######======= 099                                                        9615
      subroutine rhrh (dg,dgw,fak,sq3)                                      9616
c zu Transformation rhomb. P -> trig. R                                     9617
      dimension dg(6), dgw(3)                                               9618
      dgw(2)=sin(.5*fak*dgw(1))                                             9619
      dg(1)=2.*dg(1)*dgw(2)                                                 9620
      dg(2)=dg(1)                                                           9621
      dg(3)=dg(2)*sq3*tan(acos(2.*dgw(2)/sq3))                              9622
      dgw(1)=90.                                                            9623
      dgw(2)=dgw(1)                                                         9624
      dgw(3)=120.                                                           9625
      return                                                                9626
      end                                                                   9627
c #######======= 100                                                        9628
      function arco (w)                                                     9629
c  abs(argument of acos) =< 1.                                              9630
      w=amin1(w,1.)                                                         9631
      w=amax1(w,-1.)                                                        9632
      arco=acos(w)                                                          9633
      return                                                                9634
      end                                                                   9635
c #######======= 101                                                        9636
      subroutine chgs (kk)                                                  9637
c  number of neg. signs =< number of pos. signs                             9638
      dimension kk(3,2)                                                     9639
      j=0                                                                   9640
      k=0                                                                   9641
      do 10 i=1,2                                                           9642
        do 10 ii=1,3                                                        9643
        if (kk(ii,i).eq.0) go to 10                                         9644
        j=j+1                                                               9645
        if (kk(ii,i).gt.0) k=k+1                                            9646
   10 continue                                                              9647
      if (k.ge.(j+1)/2) return                                              9648
      do 20 i=1,2                                                           9649
        do 20 ii=1,3                                                        9650
   20   kk(ii,i)=-kk(ii,i)                                                  9651
      return                                                                9652
      end                                                                   9653
c ######### P5 #########                                                    9654
c #######======= 102                                                        9655
      logical function law(aw)                                              9656
c interprets answer y/n                                                     9657
      character*1 aw                                                        9658
      law=.false.                                                           9659
      if (aw.eq.'n'.or.aw.eq.'N') law=.true.                                9660
      return                                                                9661
      end                                                                   9662
c #######======= 103                                                        9663
      subroutine bra (in,io,ioa,ibr,j9,j8,if5)                              9664
c command interpreter and help                                              9665
      parameter (jj3=140)                                                   9666
      common /idim/ idi,ibe,nsb,nx,nso,nlc                                  9667
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     9668
      dimension j9(jj3), j8(jj3), sta(2)                                    9669
      character*1 aw                                                        9670
      character*2 j9,j8,is,sta                                              9671
      logical law                                                           9672
      data sta/'* ','**'/                                                   9673
      ij=1                                                                  9674
      if (io.ne.ioa) ij=2                                                   9675
   10 write (ioa,220) sta(ij)                                               9676
      iij=0                                                                 9677
      read (in,220,end=180) is                                              9678
      if (is.eq.'EX'.or.is.eq.'ex') go to 50                                9679
      if (is.eq.'QU'.or.is.eq.'qu') go to 50                                9680
      do 20 i=1,nsb                                                         9681
        if (is.eq.j9(i).or.is.eq.j8(i)) go to 30                            9682
   20 continue                                                              9683
      go to 40                                                              9684
c                                                                           9685
   30 if (if5.eq.1.or.ij.eq.2) write (88,190) is                            9686
      if (i.eq.37) go to 70                                                 9687
      if (i.eq.117) go to 60                                                9688
      ibr=i                                                                 9689
      return                                                                9690
   40 write (ioa,420) j9(37),j9(117)                                        9691
      go to 10                                                              9692
c                                                                           9693
   50 ibr=9                                                                 9694
      return                                                                9695
   60 write (ioa,200)                                                       9696
      call les (in)                                                         9697
      if (n.eq.0.or.ndi(1).gt.mdi) go to 10                                 9698
      iij=c(1)+.5                                                           9699
      if (iij.lt.1.or.iij.gt.11) iij=0                                      9700
      go to (70,70,80,90,100,110,120,130,140,150,160,170),iij+1             9701
c                                                                           9702
   70 write (io,250) j9(1),(j9(j),j=14,20),j9(12),j9(85),j9(62),j9(120),    9703
     1j9(117),j9(135)                                                       9704
      if (iij.gt.0) go to 10                                                9705
      write (ioa,230)                                                       9706
      read (in,240,end=10) aw                                               9707
      if (law(aw)) go to 10                                                 9708
c                                                                           9709
   80 write (io,260) j9(13),j9(4),j9(38),j9(5),j9(6),j9(8),j9(7),j9(5),     9710
     1j9(6),(j9(j),j=26,29),j9(25),j9(5),j9(6),j9(7),j9(8),j9(4)            9711
      write (io,270) j9(122),j9(125),j9(122)                                9712
      write (io,280) j9(84),j9(82),(j9(j),j=41,44),j9(41),j9(42),j9(48),    9713
     1j9(80),j9(22),j9(110),j9(109),j9(50)                                  9714
      if (iij.gt.0) go to 10                                                9715
      write (ioa,230)                                                       9716
      read (in,240,end=10) aw                                               9717
      if (law(aw)) go to 10                                                 9718
c                                                                           9719
   90 write (io,290) j9(11),j9(133),j9(55),j9(39),j9(40),j9(76),j9(21),     9720
     1j9(111),j9(112)                                                       9721
      if (iij.gt.0) go to 10                                                9722
c                                                                           9723
  100 write (io,300) j9(24),j9(5),j9(6),j9(4),j9(3),j9(23),j9(2),j9(123)    9724
     1,j9(122),j9(125)                                                      9725
      write (io,310) j9(45),j9(36),j9(47),j9(46),j9(49),j9(83)              9726
      if (iij.gt.0) go to 10                                                9727
      write (ioa,230)                                                       9728
      read (in,240,end=10) aw                                               9729
      if (law(aw)) go to 10                                                 9730
c                                                                           9731
  110 write (io,320) j9(10),j9(32),j9(10),j9(31),j9(64),j9(117),j9(51)      9732
      write (io,330) j9(54),j9(59),j9(30),j9(57),j9(51),j9(54),j9(85),      9733
     1j9(58),j9(118),j9(134)                                                9734
      if (iij.gt.0) go to 10                                                9735
  120 write (io,340) j9(80),j9(81),j9(79),j9(113),j9(126),j9(127),          9736
     1j9(136)                                                               9737
      if (iij.gt.0) go to 10                                                9738
      write (ioa,230)                                                       9739
      read (in,240,end=10) aw                                               9740
      if (law(aw)) go to 10                                                 9741
c                                                                           9742
  130 write (io,350) j9(53),j9(52),j9(55),j9(56),j9(33),j9(34),j9(35),      9743
     1j9(67),j9(68),j9(77),j9(69),j9(75)                                    9744
      if (iij.gt.0) go to 10                                                9745
      write (ioa,230)                                                       9746
      read (in,240,end=10) aw                                               9747
      if (law(aw)) go to 10                                                 9748
c                                                                           9749
  140 write (io,360) j9(60),j9(61),j9(121),j9(61)                           9750
      write (io,370) j9(64),j9(51),j9(54),j9(61),j9(61),j9(63),j9(61),      9751
     1j9(65),j9(61),j9(62),j9(116),j9(66),j9(61),j9(73),j9(74),j9(118)      9752
      if (iij.gt.0) go to 10                                                9753
      write (ioa,230)                                                       9754
      read (in,240,end=10) aw                                               9755
      if (law(aw)) go to 10                                                 9756
c                                                                           9757
  150 write (io,380) j9(70),j9(71),j9(78),j9(72),j9(119)                    9758
      if (iij.gt.0) go to 10                                                9759
  160 write (io,390) (j9(i),i=86,91),j9(86),(j9(j),j=92,103),j9(114),       9760
     1j9(115),(j9(j),j=104,107),j9(132),j9(108)                             9761
      write (io,400) (j9(i),i=128,131),j9(124),j9(135)                      9762
      if (iij.gt.0) go to 10                                                9763
  170 write (io,410) j9(37),j9(117),j9(9),j8(9)                             9764
      if (io.ne.ioa) write (ioa,210) j9(21)                                 9765
      go to 10                                                              9766
  180 ibr=9                                                                 9767
      return                                                                9768
c                                                                           9769
c                                                                           9770
c                                                                           9771
  190 format (' #### ',a2,' ####')                                          9772
  200 format (' choose one of the following topics for help:'/3x,'1: cel    9773
     1l parameters',9x,'7: data management (see also 1 and 8)'/3x,'2: SA    9774
     2D-data',16x,'8: cell parameter determination'/3x,'3: output',18x,'    9775
     39: calculations in reciprocal and direct space'/3x,'4: parameters'    9776
     4,13x,'10: pocket calculator'/3x,'5: indexing and scans',5x,'11: he    9777
     5lp, exit'/3x,'6: goniometer data,'/6x,'input and evaluation')         9778
  210 format (a2,' terminates parallel output')                             9779
  220 format (a2)                                                           9780
  230 format (1x,'cont.?')                                                  9781
  240 format (a1)                                                           9782
  250 format (/3x,'cell parameters:'/1x,a2,' : Cell Parameters, a<0 : re    9783
     1ciprocal, =0: assign a file'/1x,5(a2,', '),a2,' : cell parameters,    9784
     2 separately, <0: reciprocal'/1x,a2,' : CeNtering'/1x,a2,' : Get La    9785
     3ttice constants from file'/1x,a2,' : list (Write) Lattice constant    9786
     4 file'/1x,a2,' : DElaunay reduction'/1x,a2,' : Idealize Symmetry o    9787
     5f cell parameters'/8x,'see also "data management" (',a2,', topic 7    9788
     6)'/8x,'and <',a2,'> (matrix operations, topic 10)')                   9789
  260 format (/3x,'SAD data:'/1x,a2,' : TItle of SAD pattern'/1x,a2,' :     9790
     1Camera Constant or camera length'/1x,a2,' : High Voltage or lambda    9791
     2'/1x,a2,' : "1"st Radius or d-value'/1x,a2,' : "2"nd Radius ..'/      9792
     31x,a2,' : ANgle'/1x,a2,' : "3"rd Radius (=length of vector(',a2,'-    9793
     4',a2,'))'/1x,4(a2,', '),a2,' : estimated Errors for ',4(a2,','),      9794
     5a2)                                                                   9795
  270 format (1x,a2,' : data from deflector current read-out (JEol)'/1x,    9796
     1a2,' : as ',a2,', Hexadecimal integers >0 expected')                  9797
  280 format (1x,a2,' : replace SAD sigmas by Default Sigmas'/1x,a2,' :     9798
     1New Default sigmas for camera const., radii, angle'/1x,a2,' : radi    9799
     2us 0. Laue zone'/1x,a2,' : difference radius Laue zone 1 - Laue zo    9800
     3ne 0'/1x,a2,', ',a2,' : estimated errors (Deltas) for ',a2,', ',      9801
     4a2/1x,a2,' : Estimated error for Volume'/1x,a2,' : (Read) Goniomet    9802
     5er data of the pattern'/1x,a2,' : Interchange R1 and R2'/1x,a2,' :    9803
     6 ROtate: r2>r1, r3>r2, r1>r3'/1x,a2,' : reduce ("UNify") pattern'/    9804
     71x,a2,' : New Pattern')                                               9805
  290 format (/3x,'output:'/1x,a2,' : List of current parameters'/1x,a2,    9806
     1' : List memory A (d-values, short), see also "',a2,'", topic 7'/     9807
     21x,a2,' : Output: Radii (as measured, default)'/1x,a2,' : Output:     9808
     3D-values'/1x,a2,' : Zone Axes (h1 x h2) output (on/off)'/1x,a2,' :    9809
     4 Parallel Output on protocol file 1 (on/off)'//3x,'screen:'/1x,a2,    9810
     5' : parameters for graph (Y-axis, X-axis)'/1x,a2,' : Number of Lin    9811
     6es per screen')                                                       9812
  300 format (/3x,'parameters:'/1x,a2,' : Rigid Limits for ',2(a2,', '),    9813
     1a2,' (0=yes(def.), 1=no)'/1x,a2,' : NumbeR of best solutions to be    9814
     2 output'/1x,a2,' : maximum MUltiplicity of the mesh'/1x,a2,' : Wei    9815
     3ghTs for calculation of R'/1x,a2,' : New Calibration for ',a2,' or    9816
     4 ',a2)                                                                9817
  310 format (1x,a2,' : Laue zone criterion applied: Yes'/1x,a2,' :         9818
     1      - " -            : No (default)'/1x,a2,' : Volume criterion     9819
     2applied: Yes'/1x,a2,' :          - " -          : No (default)'/      9820
     31x,a2,' : Restore Default values (modi and data)'/1x,a2,' : list (    9821
     4View) conditions')                                                    9822
  320 format (/3x,'indexing and scans:'/1x,a2,' : Index a pattern'/1x,      9823
     1a2,' : Save results of ',a2,' on protocol File 2'/1x,a2,' : SCan t    9824
     2hrough cell parameter file'/1x,a2,' : (BReak) see "cell parameter     9825
     3determination" (',a2,', topic 8)'/1x,a2,' : Scan (1 pattern) throu    9826
     4gh cell parameter file controlled by ',a2)                            9827
  330 format (1x,a2,' : Scan using data from memory A'/1x,a2,' : CoMpreh    9828
     1ensiveness of protocol 2'/1x,a2,' : ReWind cell parameter file'/      9829
     21x,a2,' : self-acting Rewind (',2(a2,', '),a2,'): No'/1x,a2,' :',     9830
     332x,':Yes (default)'/1x,a2,' : eXclude pattern in mem. A from cell    9831
     4 param. determ. ','and scans'/6x,'(also include)'/1x,a2,' : Invert    9832
     5 all exclusion marks in mem. A')                                      9833
  340 format (/3x,'goniometer data, input and evaluation'/1x,a2,' : Goni    9834
     1ometer data (Read) of the current SAD pattern'/1x,a2,' : Goniomete    9835
     2r: Calculate angle between orientations of',' data in mem. A'/1x,     9836
     3a2,' : Goniometer type, angle between goniometer Settings, clear g    9837
     4oniom. data'/1x,a2,' : Calculate radius 0. Laue zone from tilt ang    9838
     5le phi'/1x,a2,' : set up Orientation defining Zones'/1x,a2,' : cal    9839
     6culate goniometer angles (Alpha, Beta)'/6x,' from zone indices uvw    9840
     7 (all equivalents, current orientation)'/1x,a2,' : calculate Gonio    9841
     8meter angles for all zones'/6x,' up to Upper limits for beta and a    9842
     9lpha (current orientation)')                                          9843
  350 format (/3x,'SAD-data <-> memory A (SAD data):'/1x,a2,' : Put into    9844
     1 ......'/1x,a2,' : Get from ......'/1x,a2,' : Write..........'/1x,    9845
     2a2,' : Delete from ... memory A'//3x,'SAD-data <-> file'/1x,a2,' :    9846
     3 Put into ..'/1x,a2,' : Get from ..'/1x,a2,' : Write ..... SAD pat    9847
     4tern file'//3x,'cell parameters <-> memory B (cell parameters):'/     9848
     51x,a2,' : Put into ....'/1x,a2,' : Get from.....'/1x,a2,' : Write.    9849
     6.......'/1x,a2,' : Delete from.. memory B'//3x,'mem. B --> file'/     9850
     71x,a2,' : Save cell param. from memory B on scratch file')            9851
  360 format (/3x,'cell parameter determination:'/1x,a2,' : Prepare Cell    9852
     1 parameter determination'/1x,a2,' : Determine Cell parameters'/1x,    9853
     2a2,' : TEmporary sigmas during <',a2,'>')                             9854
  370 format (1x,a2,' : BReak at each match for ',a2,', ',a2,', ',a2,' o    9855
     1r after each layer for ',a2/1x,a2,' : Write sorted list of cell pa    9856
     2ram. from ',a2,' (mem.C)'/1x,a2,' : Get cell parameters from ',a2,    9857
     3' (mem.C)'/1x,a2,' : DElaunay reduction'/1x,a2,' : Delaunay red.,     9858
     4Scan through mem. C'/1x,a2,' : limits for EQuivalence in ',a2/1x,     9859
     5a2,' : ReFine (not yet implemented, instead internal list)'/1x,a2,    9860
     6' : cell parameters from angle scan (no mnemonic)'/1x,a2,' : eXclu    9861
     7de pattern in mem. A from cell param. determ. ','and scans'/6x,'(a    9862
     8lso include)')                                                        9863
  380 format (/3x,'calculations'/1x,a2,' : Calculations in Reciprocal sp    9864
     1ace, hkl input'/1x,a2,' : Calculations in Direct space, xyz or uvw    9865
     2 input'/1x,a2,' : X-ray Wavelength for list of d-values'/1x,a2,' :    9866
     3 LoaD calculated data'/1x,a2,' : calc. angles between a zone and a    9867
     4ll equiv. of a 2nd zone'/6x,'Closest Zone first')                     9868
  390 format (/3x,'pocket calculator (RPN) ("x" = register 1)'/1x,6(a2,     9869
     11x),' : operations, "',a2,'": enter to x and shift stack'/1x,4(a2,    9870
     21x),' : roll down, up, interchange x<>y, last x'/1x,2(a2,1x),' : P    9871
     3ut reg.1 to Mem., Get reg.1 from Mem. (shift)'/1x,8(a2,1x),' : sin    9872
     4, cos, tg, asin, acos, atan, ln, exp'/1x,4(a2,1x),' : store in sta    9873
     5ck reg. # (override)'/1x,a2,' : store in memory reg. (override)'/     9874
     61x,a2,' : enter (shift stack and preserve mem. reg. 1)')              9875
  400 format (1x,a2,' : Change Sign(x)'/1x,a2,' : 1/x (REzipr.)'/1x,a2,'    9876
     1 : SQare(x)'/1x,a2,' : sqRT(x)'/1x,a2,' : Hexadecimal integers >0     9877
     2to Decimal'//1x,a2,' : Matr.-Vect.-, matr.-matr. and vect.-vect. o    9878
     3perations')                                                           9879
  410 format (/1x,a2,' : Help, complete listing'/1x,a2,' : Help for a ch    9880
     1osen topic'/1x,a2,', ',a2,', EX, ex, QU, qu: end (all equivalent)'    9881
     2)                                                                     9882
  420 format (1x,'unknown command (',a2,' or ',a2,' for help)')             9883
      end                                                                   9884
c ######### P6 #######                                                      9885
c #######======= 104                                                        9886
      subroutine mvvm (cd,dg,dgw,fak,cvm,ivm)                               9887
c  matrix-vector-operations                                                 9888
      common /cc/ ifu,iou,koma,ifdi,mdi,c(15),n,ndi(15)                     9889
      dimension cd(6), cp(6), dg(6), dgw(3), xx(3,3), cvm(6)                9890
      dimension a(3,3), b(3,3), c2(3,3), bs(3,3), bi(3,3)                   9891
      dimension aa(3), bb(3), cc(3), co(16), ca(16)                         9892
      character co*2,ca*2,cm*2,yn*1                                         9893
      data a,bs,aa/1.,3*0.,1.,3*0.,1.,1.,3*0.,1.,3*0.,1.,1.,0.,0./          9894
      data co/'v ','m1','m2','i1','i2','mi','mm','vm','mv','vv','vs','ma    9895
     1','mr','l ','en','h '/                                                9896
c      12       1    2    3    4    5    6    7    8    9   10   11         9897
      data ca/'V ','M1','M2','I1','I2','MI','MM','VM','MV','VV','VS','MA    9898
     1','MR','L ','EN','H '/                                                9899
c      12       1    2    3    4    5    6    7    8    9   10   11         9900
c                                                                           9901
      ivm=0                                                                 9902
      write (6,330) co(16)                                                  9903
   10 write (6,360) dg(1),dg(2),dg(3),dgw(1),dgw(2),dgw(3)                  9904
      do 20 i=1,3                                                           9905
        cvm(i)=dg(i)                                                        9906
   20   cvm(i+3)=dgw(i)                                                     9907
      d=det(a)                                                              9908
      ds=det(bs)                                                            9909
      call wm (a,bs,d,ds)                                                   9910
      write (6,410) aa                                                      9911
   30 write (6,420) co                                                      9912
c                                                                           9913
      read (5,430,end=310) cm                                               9914
c                                                                           9915
      do 40 i=1,16                                                          9916
        ii=i                                                                9917
        if (cm.eq.co(i)) go to 50                                           9918
        if (cm.eq.ca(i)) go to 50                                           9919
   40 continue                                                              9920
c     if (cm.eq.'QU'.or.cm.eq.'qu'.or.cm.eq.'ex'.or.cm.eq.'EX') go to       9921
c    1320                                                                   9922
      write (6,520) co(15),co(16)                                           9923
      go to 30                                                              9924
   50 go to (140,60,70,150,160,80,210,260,270,280,290,100,120,10,310,       9925
     1300),ii                                                               9926
c                                                                           9927
c m1  : matrix1 input                                                       9928
   60 write (6,440)                                                         9929
      call les (5)                                                          9930
      if (n.eq.0) go to 30                                                  9931
      a(1,1)=c(1)                                                           9932
      a(2,1)=c(2)                                                           9933
      a(3,1)=c(3)                                                           9934
      a(1,2)=c(4)                                                           9935
      a(2,2)=c(5)                                                           9936
      a(3,2)=c(6)                                                           9937
      a(1,3)=c(7)                                                           9938
      a(2,3)=c(8)                                                           9939
      a(3,3)=c(9)                                                           9940
      d=det(a)                                                              9941
      call wm (a,bs,d,ds)                                                   9942
      go to 30                                                              9943
c                                                                           9944
c m2 : matrix2 input                                                        9945
   70 write (6,450)                                                         9946
      call les (5)                                                          9947
      if (n.eq.0) go to 30                                                  9948
      bs(1,1)=c(1)                                                          9949
      bs(2,1)=c(2)                                                          9950
      bs(3,1)=c(3)                                                          9951
      bs(1,2)=c(4)                                                          9952
      bs(2,2)=c(5)                                                          9953
      bs(3,2)=c(6)                                                          9954
      bs(1,3)=c(7)                                                          9955
      bs(2,3)=c(8)                                                          9956
      bs(3,3)=c(9)                                                          9957
      ds=det(bs)                                                            9958
      call wm (a,bs,d,ds)                                                   9959
      go to 30                                                              9960
c                                                                           9961
c mi : interchange matrix 1 and matrix 2                                    9962
   80 do 90 i=1,3                                                           9963
        do 90 j=1,3                                                         9964
        bd=a(i,j)                                                           9965
        a(i,j)=bs(i,j)                                                      9966
   90   bs(i,j)=bd                                                          9967
      bd=d                                                                  9968
      d=ds                                                                  9969
      ds=bd                                                                 9970
      call wm (a,bs,d,ds)                                                   9971
      go to 30                                                              9972
c                                                                           9973
c ma  :  apply matrix 1                                                     9974
  100 write (6,360) dg(1),dg(2),dg(3),dgw(1),dgw(2),dgw(3)                  9975
      write (6,350)                                                         9976
      read (5,490,end=30) yn                                                9977
      if (yn.eq.'n'.or.yn.eq.'N') go to 30                                  9978
      call trd (a,xx,cd)                                                    9979
      call xtodg (xx,cp)                                                    9980
      cp(4)=fak*acos(cp(4))                                                 9981
      cp(5)=fak*acos(cp(5))                                                 9982
      cp(6)=fak*acos(cp(6))                                                 9983
      write (6,370) cp                                                      9984
      write (6,380)                                                         9985
      read (5,490,end=30) yn                                                9986
      if (yn.eq.'n'.or.yn.eq.'N') go to 30                                  9987
      do 110 i=1,6                                                          9988
  110   cvm(i)=cp(i)                                                        9989
      ivm=1                                                                 9990
      return                                                                9991
c                                                                           9992
c mr  : reset matrix                                                        9993
  120 write (6,340)                                                         9994
      read (5,490,end=30) yn                                                9995
      if (yn.eq.'n'.or.yn.eq.'N') go to 30                                  9996
      do 130 i=1,3                                                          9997
        do 130 j=1,3                                                        9998
        a(i,j)=0.                                                           9999
  130   if (i.eq.j) a(i,j)=1.                                              10000
      go to 10                                                             10001
c                                                                          10002
c v   : vector input                                                       10003
  140 write (6,460)                                                        10004
      call les (5)                                                         10005
      if (n.eq.0) go to 30                                                 10006
      aa(1)=c(1)                                                           10007
      aa(2)=c(2)                                                           10008
      aa(3)=c(3)                                                           10009
      write (6,470) aa                                                     10010
      go to 30                                                             10011
c                                                                          10012
c i1  : invert matrix                                                      10013
  150 call m3inv (a,b,d,ie)                                                10014
      if (ie.eq.0) go to 170                                               10015
      write (6,500)                                                        10016
      go to 30                                                             10017
c                                                                          10018
c i2  : invert matrix 2                                                    10019
  160 call m3inv (bs,bi,ds,ie)                                             10020
      if (ie.eq.0) go to 190                                               10021
      write (6,500)                                                        10022
      go to 30                                                             10023
c                                                                          10024
c replace m1                                                               10025
  170 d=det(b)                                                             10026
      write (6,470) b                                                      10027
      write (6,540) d                                                      10028
      write (6,480)                                                        10029
      read (5,490,end=30) yn                                               10030
      if (yn.eq.'n'.or.yn.eq.'N') go to 30                                 10031
      do 180 i=1,3                                                         10032
        do 180 j=1,3                                                       10033
  180   a(i,j)=b(i,j)                                                      10034
      go to 10                                                             10035
c                                                                          10036
c  replace m2                                                              10037
  190 ds=det(bi)                                                           10038
      write (6,470) bi                                                     10039
      write (6,540) ds                                                     10040
      write (6,480)                                                        10041
      read (5,490,end=30) yn                                               10042
      if (yn.eq.'n'.or.yn.eq.'N') go to 30                                 10043
      do 200 i=1,3                                                         10044
        do 200 j=1,3                                                       10045
  200   bs(i,j)=bi(i,j)                                                    10046
      go to 10                                                             10047
c                                                                          10048
c mm  : multiply two matrices                                              10049
  210 call mm (bs,a,c2,dc2)                                                10050
      write (6,470) c2                                                     10051
      dc2=det(c2)                                                          10052
      write (6,530) dc2                                                    10053
      call les (5)                                                         10054
      if (n.eq.0) go to 30                                                 10055
      i=c(1)                                                               10056
      if (i.eq.1) go to 220                                                10057
      if (i.eq.2) go to 240                                                10058
      go to 30                                                             10059
  220 do 230 i=1,3                                                         10060
        do 230 j=1,3                                                       10061
  230   a(i,j)=c2(i,j)                                                     10062
      d=det(a)                                                             10063
      ds=det(bs)                                                           10064
      call wm (a,bs,d,ds)                                                  10065
      go to 30                                                             10066
  240 do 250 i=1,3                                                         10067
        do 250 j=1,3                                                       10068
  250   bs(i,j)=c2(i,j)                                                    10069
      d=det(a)                                                             10070
      ds=det(bs)                                                           10071
      call wm (a,bs,d,ds)                                                  10072
      go to 30                                                             10073
c                                                                          10074
c vm  : multiply vector *  matrix                                          10075
  260 call vm (aa,a,bb)                                                    10076
      write (6,470) bb                                                     10077
      go to 30                                                             10078
c                                                                          10079
c mv  : multiply  matrix * vector                                          10080
  270 call mv (a,aa,bb)                                                    10081
      write (6,470) bb                                                     10082
      go to 30                                                             10083
c                                                                          10084
c vv  : vector product [v1 x v2]                                           10085
  280 write (6,510)                                                        10086
      call les (5)                                                         10087
      if (n.eq.0) go to 30                                                 10088
      bb(1)=c(1)                                                           10089
      bb(2)=c(2)                                                           10090
      bb(3)=c(3)                                                           10091
      call vv (aa,bb,cc)                                                   10092
      write (6,470) cc                                                     10093
      go to 30                                                             10094
c                                                                          10095
c vs  : scalar product (v1 * v2)                                           10096
  290 write (6,510)                                                        10097
      call les (5)                                                         10098
      if (n.eq.0) go to 30                                                 10099
      bb(1)=c(1)                                                           10100
      bb(2)=c(2)                                                           10101
      bb(3)=c(3)                                                           10102
      x=vs(aa,bb)                                                          10103
      write (6,470) x                                                      10104
      go to 30                                                             10105
c                                                                          10106
c h  : help                                                                10107
  300 write (6,390) (co(i),i=1,9)                                          10108
      write (6,400) (co(i),i=10,16)                                        10109
      go to 30                                                             10110
c                                                                          10111
  310 write (6,320) (cvm(i),i=1,6)                                         10112
      return                                                               10113
c                                                                          10114
c                                                                          10115
c                                                                          10116
  320 format ('current cell:',3f9.4,f9.3,2f8.2/15x,'check centering!')     10117
  330 format (1x,a2,' for help'/)                                          10118
  340 format (' reset matrix 1 to 1?')                                     10119
  350 format (' apply matrix 1?')                                          10120
  360 format (' current cell parameters:'/3f10.3,f10.2,2f8.2)              10121
  370 format (' transformed cell parameters:'/3f10.3,f10.2,2f8.2)          10122
  380 format ('  replace current cell parameters?')                        10123
  390 format (1x,'col.1'/2x,'v'/2x,a2,': read vector'/2x,a2,': read matr   10124
     1ix 1'/2x,a2,': read matrix 2'/2x,a2,': invert matrix 1'/2x,a2,': i   10125
     2nvert matrix 2'/2x,a2,': interchange matrix 1 and matrix 2'/2x,a2,   10126
     3': matrix 1 * matrix 2'/2x,a2,': vector * matrix 1'/2x,a2,': matri   10127
     4x 1 * vector')                                                       10128
  400 format (2x,a2,': vector x vector'/2x,a2,': vector * vector (scalar   10129
     1)'/2x,a2,': apply matrix 1 to current cell parameters'/2x,a2,': re   10130
     2set matrix 1 to 1'/2x,a2,': list current cell parameters, matrices   10131
     3 and vector'/2x,a2,': end (return to "*")'/2x,a2,': help'/)          10132
  410 format (/'  vektor: ',3g10.4)                                        10133
  420 format (/3x,a2,14(',',a2),'; ',a2,' for help')                       10134
  430 format (a2)                                                          10135
  440 format (' matrix 1?')                                                10136
  450 format (' matrix 2?')                                                10137
  460 format (' vektor?')                                                  10138
  470 format (3g14.7)                                                      10139
  480 format (' replace?')                                                 10140
  490 format (a1)                                                          10141
  500 format (' determinant = 0.')                                         10142
  510 format (' 2nd vector?')                                              10143
  520 format (' unknown command, ',a2,' to escape, ',a2,' for help')       10144
  530 format (' det:',g14.7/'  store? ("1" or "2": override matrix 1 or    10145
     12, resp., otherwise: no)')                                           10146
  540 format (' det:',g14.7)                                               10147
      end                                                                  10148
c #######======= 105                                                       10149
      subroutine wm (a,b,da,db)                                            10150
c write the two matrices and determinants at the prompt                    10151
      dimension a(3,3), b(3,3)                                             10152
      write (6,10) (a(1,i),a(2,i),a(3,i),b(1,i),b(2,i),b(3,i),i=1,3)       10153
      write (6,20) da,db                                                   10154
      return                                                               10155
c                                                                          10156
c                                                                          10157
c                                                                          10158
   10 format (/'  matrix 1',31x,'matrix 2'/(1x,3g12.6,3x,3g12.6))          10159
   20 format (' det1:',g14.7,20x,'det2:',g14.7)                            10160
      end                                                                  10161
c #######======= 106                                                       10162
      function det (a)                                                     10163
c  determinante                                                            10164
      dimension a(3,3)                                                     10165
      det=a(1,1)*(a(2,2)*a(3,3)-a(2,3)*a(3,2))+a(1,2)*(a(2,3)*a(3,1)-      10166
     1a(2,1)*a(3,3))+a(1,3)*(a(2,1)*a(3,2)-a(2,2)*a(3,1))                  10167
      return                                                               10168
      end                                                                  10169
c #######======= 107                                                       10170
      subroutine m3inv (a,b,d,ie)                                          10171
c inversion of a 3x3 matrix                                                10172
      dimension a(3,3), b(3,3)                                             10173
      ie=0                                                                 10174
      d=det(a)                                                             10175
      if (abs(d).lt.1.e-10) go to 20                                       10176
c                                                                          10177
      do 10 j=1,3                                                          10178
        j1=mod(j,3)+1                                                      10179
        j2=mod(j+1,3)+1                                                    10180
        do 10 i=1,3                                                        10181
        i1=mod(i,3)+1                                                      10182
        i2=mod(i+1,3)+1                                                    10183
   10   b(i,j)=(a(j1,i1)*a(j2,i2)-a(j2,i1)*a(j1,i2))/d                     10184
c      d=det(b)                                                            10185
c                                                                          10186
      return                                                               10187
   20 ie=1                                                                 10188
      return                                                               10189
      end                                                                  10190
c #######======= 108                                                       10191
      subroutine vv (aa,bb,cc)                                             10192
c vector product                                                           10193
      dimension aa(3), bb(3), cc(3)                                        10194
      cc(1)=aa(2)*bb(3)-aa(3)*bb(2)                                        10195
      cc(2)=aa(3)*bb(1)-aa(1)*bb(3)                                        10196
      cc(3)=aa(1)*bb(2)-aa(2)*bb(1)                                        10197
      return                                                               10198
      end                                                                  10199
c #######======= 109                                                       10200
      function vs (aa,bb)                                                  10201
c scalar product                                                           10202
      dimension aa(3), bb(3)                                               10203
      vs=aa(1)*bb(1)+aa(2)*bb(2)+aa(3)*bb(3)                               10204
      return                                                               10205
      end                                                                  10206
c #######======= 110                                                       10207
      subroutine vm (a,g,b)                                                10208
c vektor*matrix                                                            10209
      dimension a(3), g(3,3), b(3)                                         10210
      do 10 i=1,3                                                          10211
        b(i)=0.                                                            10212
        do 10 k=1,3                                                        10213
   10   b(i)=b(i)+a(k)*g(i,k)                                              10214
      return                                                               10215
      end                                                                  10216
c #######======= 111                                                       10217
      subroutine mv (g,a,b)                                                10218
c matrix*vektor                                                            10219
      dimension a(3), g(3,3), b(3)                                         10220
      do 10 i=1,3                                                          10221
        b(i)=0.                                                            10222
        do 10 k=1,3                                                        10223
   10   b(i)=b(i)+a(k)*g(k,i)                                              10224
      return                                                               10225
      end                                                                  10226
c #######======= 112                                                       10227
      subroutine mm (a,b,c,dc)                                             10228
c matrix a * matrix b = matrix c                                           10229
      dimension b(3,3), a(3,3), c(3,3)                                     10230
      do 10 i=1,3                                                          10231
        do 10 k=1,3                                                        10232
        c(i,k)=0.                                                          10233
        do 10 l=1,3                                                        10234
   10   c(i,k)=c(i,k)+a(i,l)*b(l,k)                                        10235
      dc=det(c)                                                            10236
      return                                                               10237
      end                                                                  10238
