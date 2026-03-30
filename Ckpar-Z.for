cc ==========
c 
c  CHECK OF THE PARAMETER FILE FOR:
c 
c       ********************************************
c       *  =PIEP=    A PROGRAM FOR INTERPRETING    *
c       *           ELECTRON DIFFRACTION PATTERNS  *
c       *------------------------------------------*
c       *  Darmstadt              (G.MIEHE)        *
c       *  update    28-feb-2013                   *
c       ********************************************
c 
      parameter (jj1=19,jj2=199,jj3=140,jj4=20,jj5=100,jj6=40,jj7=136)
c-p      parameter (jj1=19,jj2=999,jj3=140,jj4=15,jj5=100,jj6=15,jj7=136
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,
     2difa,difg,dc0
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0
      common /sb1/ jsm(7),jsml(7),ivo(2),s1(2),p7(2),p7l(2),p9(2),p8(2),
     1rs,holder(3)
      common /j8/ j8(jj3),j9(jj3),j85(6)
      common /cc/ koma,ifdi,mdi,c(15),n,ndi(15)
c n = ier                             ^
      common /files/ file1,file2,file3,file4,file5,fdd
      common /idim/ idi,ibe,nsb,nx,nso,nlc
      common /itst/ ftst(9),itst(9)
      dimension d(26), id(7), idd(2)
c     equivalence (wiw,d(1)), (id(1),iho), (idd(1),ifdi)
      character*20 file1,file2,file3,file4,file5,filep,filed,fdd
      character*1 jsm,jsml,ivo,s1,p7,p7l,p9,p8
      character*1 aw
      character*2 j8,j9
      character*5 j85
      character*9 datum
      character*12 iden,iden1,iden2,iden3(4)
      character rs*10,holder*11
      logical law
      data ftst,itst/9*0.,9*0/
      data iden1,iden2,datum/'93822','TEST','28-feb-13'/
c-p      data filep/'pix.par'/
c-p      data filep/'PIEP-2017.par'/
      data filep/'piep.par'/
c 
      j77=jj7
      ftst(1)=sr1
      itst(1)=1
      itst(2)=0
      ntst=0
      idi=jj1
      ibe=jj2
      nsb=jj3
      nx=jj4
      nso=jj5
      nlc=jj6
      icom=0
      koma=0
c IPAR=unit for paramater file PIEP.PAR
      ipar=40
c 
c NWM=default value for maximum number of solutions to be output
c 
      nwm=ibe
c 
      write (io,640) datum
c      write (ioa,11)
c      read (in,12,end=10) aw
c      if (law(aw)) go to 10
      write (ioa,610) filep
      read (in,660) filed
      if (filed.ne.' ') filep=filed
      open (unit=ipar,file=filep,status='OLD')
      read (ipar,620) iden,iden3
      if (iden.ne.iden1) go to 10
      ntst=1
      iden=iden2
   10 write (ioa,700)
      write (ioa,630) iden,iden3
      write (ioa,700)
      read (ipar,620) iden,iden3
      if (iden.eq.'%%e7%2017--%') go to 20
      if (iden3(1).eq.' ') iden3(1)=' 24-DEC-1871'
      write (ioa,650) iden3(1),datum
      stop
   20 read (ipar,600,end=180) aw
      if (aw.ne.'$') go to 20
      read (ipar,660) file1
      read (ipar,660) file2
      read (ipar,660) file4
      read (ipar,660) file3
      read (ipar,660) file5
      write (ioa,200) file1,file2,file3,file4,file5
c 
   30 call les (ipar)
      if (n.eq.0) go to 30
      if (n.ne.0.and.c(2).eq.0.) write (ioa,210)
      if (n.ne.0.and.c(2).ne.0.) write (ioa,220)
      if (n.ne.0.and.c(3).eq.1.) write (ioa,230)
      if (n.ne.0.and.c(3).eq.0.) write (ioa,240)
      if (n.ne.0.and.c(4).eq.0.) write (ioa,250)
      if (n.ne.0.and.c(4).ne.0.) write (ioa,260)
      if (n.ne.0.and.c(6).eq.0.) write (ioa,263)
  263 format (/' listing of memory A: f9.4') 
      if (n.ne.0.and.c(6).ne.0.) write (ioa,264)
  264 format (/' listing of memory A: f9.2') 
      if (n.ne.0.and.c(7).ne.0.) write (ioa,251)
  251 format (/' output control digits c1 - c15')
      if (n.ne.0.and.c(7).eq.0.) write (ioa,252)
  252 format (/' omit output of control digits')
      if (n.eq.0.or.c(1).le.0.) go to 40
      write (ioa,270) file1,file2
      go to 50
c 
   40 write (ioa,280)
   50 write (ioa,290)
      read (in,600,end=170) aw
      if (law(aw)) stop
      m=1
   60 call les (ipar)
      if (n.eq.0) go to 60
      d(m)=c(1)
      m=m+1
c 
      if (m.eq.4) then
        write (ioa,300) d(1),d(2),d(3),wiw,wiv,wik
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.7) then
        write (ioa,310) d(4),d(5),d(6),sk,sr1,swi
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.11) then
        write (ioa,320) d(7),d(10),d(8),d(9)
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.12) then
        write (ioa,330) d(11),da0
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.16) then
        write (ioa,340) d(12),d(13),d(14),csig0,rsig0,asig0
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.17) then
        write (ioa,350) d(15),d(16),difw,dazb
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.19) then
        write (ioa,360) d(17),d(18),ddw,ddv
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.27) then
        write (ioa,370) d(23),d(24),d(25),d(26)
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.27) then
        write (ioa,380) d(19),d(20),d(22),d(21),vdd,dl0,dl1,dw0
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.lt.27) go to 60
c 
      m=1
   70 call les (ipar)
      if (n.eq.0.or.ndi(1).gt.mdi) go to 70
      id(m)=c(1)+.5
      m=m+1
c 
      if (m.eq.2) then
        if (id(1).gt.0.and.id(1).le.3) go to 80
        write (ioa,390) id(1)
        stop
   80   if (id(1).lt.3) write (ioa,410) id(1),holder(id(1))
        if (id(1).eq.3) write (ioa,420) id(1),holder(id(1)),c(2),c(3)
        if (id(1).ne.3) go to 90
        if (c(2).ne.0.) go to 90
        write (ioa,400)
        stop
   90   write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.3) then
        write (ioa,430) id(2)
        if (id(2).gt.1.and.id(2).le.ibe) go to 100
        if (id(2).gt.ibe) then
          write (ioa,440) ibe
        end if
        ibep1=ibe+1
        if (id(2).lt.2) write (ioa,450) ibep1
  100   write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.4) then
        write (ioa,460) id(3)
        if (id(3).gt.0.and.id(3).lt.3) go to 110
        write (ioa,470)
        stop
  110   write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.5) then
        write (ioa,480) id(4)
        if (id(4).lt.100) write (ioa,490)
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.6) then
        write (ioa,500) id(5)
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.eq.7) then
        write (ioa,510) id(6)
        if (mod(id(6),2).ne.0) write (ioa,520)
        if (id(6).lt.7.or.id(6).gt.20) then
          write (ioa,530)
          stop
        end if
        write (ioa,290)
        read (in,600,end=170) aw
        if (law(aw)) stop
      end if
c 
      if (m.lt.7) go to 70
      m=1
  120 call les (ipar)
      if (n.eq.0.or.ndi(1).gt.mdi) go to 120
      idd(m)=c(1)+.5
      m=m+1
      if (m.lt.3) go to 120
      istt=10
      ftst(1)=sr1
c 
      write (ioa,540) idd(1),idd(2)
      write (ioa,290)
      read (in,600,end=170) aw
      if (law(aw)) stop
c 
  130 read (ipar,600,end=170) aw
      if (aw.eq.'*'.and.ntst.ne.0) go to 150
      if (aw.ne.'%') go to 130
      read (ipar,670) j9
      read (ipar,670) j8
      icom=1
      write (ioa,550)
      write (ioa,670) (j9(i),i=1,j77)
      write (ioa,290)
      read (in,600,end=170) aw
      if (law(aw)) stop
      write (ioa,560)
      write (ioa,670) (j8(i),i=1,j77)
c 
      call ckco (j77,ie,ioa)
      if (ie.eq.1) go to 191
      if (ntst.eq.0) go to 170
c 
  140 read (ipar,600,end=170) aw
      if (aw.ne.'*') go to 140
  150 call les (ipar)
      if (n.eq.0) go to 150
      fd=c(1)
      fw=c(2)
      itst(1)=c(3)
      ftst(1)=c(4)
      istt=c(5)
      itst(2)=c(6)
      write (io,680) fd,fw,itst(1),ftst(1),istt,itst(2)
  160 call les (ipar)
      if (n.eq.0) go to 160
      flim=c(1)
      write (io,690) flim,ifdi,mdi
c 
  170 if (icom.eq.0) write (ioa,570)
      if (ie.eq.0) go to 190
c ????
      ddv=.5*ddv
      nwm=min0(nwm,ibe)
      yzx=amin1(yzx,4.)
      yzx=amax1(yzx,.3)
      ydx=amin1(ydx,4.)
      ydx=amax1(ydx,.3)
      ny=max0(ny,7)
      ny=min0(ny,20)
c ????
      write (ioa,290)
      read (in,600,end=170) aw
      if (law(aw)) stop
      close (ipar)
      stop
  180 write (ioa,580)
      read (in,600,end=170) aw
      stop
  190 write (io,590)
  191 read (in,600) aw
      stop
c 
c 
c
  200 format (' files:'/' cell parameters (perm.): ',a20/'            SA
     1D data    : ',a20/'          protocol 1    : ',a20/'          prot
     2ocol 2    : ',a20/' cell parameters (scr.) : ',a20)
  210 format (/' input sequence for distances: r, sigma, mult.')
  220 format (/' input sequence for distances: r, mult., sigma')
  230 format (/' comma (,) permitted as well as decimal point')
  240 format (/' comma (,) handled as space')
  250 format (/' transf. with non-integer matrix elements in Delaunay re
     1duction omitted')
  260 format (/' transf. with non-integer elements in Delaunay red. perm
     1itted')
  270 format (/' short starting procedure'//' files required: ',a20,
     1/17x,a20)
  280 format (/' files may be assigned at runtime')
  290 format (' cont.?')
  300 format ('  weights for angle, r1/r2, camera const.:',3f10.3/30x,'r
     1ecommended:',3f10.3)
  310 format ('  sigma   for camera const., radii, angle:',3f10.3/30x,'r
     1ecommended:',3f10.3)
  320 format (4x,' high voltage:',f10.0/' x-ray wavelength:',f10.6//' ch
     1aracter height/width: screen:',f7.3,', printer:',f7.3)
  330 format ('  increment factor f :',f8.3/10x,'recommended:',f8.3)
  340 format ('  default temporary errors for cc, r, angle:',3f7.3/32x,'
     1recommended:',3f7.3)
  350 format (' equiv. of reduced cells: angles, ratios:',f6.1,f7.3/29x,
     1'recommended:',f6.1,f7.3)
  360 format (' Delaunay red.: max. deviation from prescribed values:'/'
     1  angles, ratios:',f6.1,f7.3/'     recommended:',f6.1,f7.3)
  370 format (' calibration factors for deflector currents:'/2(5x,2f10.
     15))
  380 format (' sigma for volume(%), zero and 1. Laue zone radii (mm), t
     1ilt angle (deg.)'/17x,f6.1,3f7.3/'     recommended:',f6.1,3f7.3)
  390 format (/' *** error, holder type (',i3,') must be 1, 2 or 3')
  400 format (/' *** error, 1st constant for holder type 3 must not be 0
     1.')
  410 format (' holder type',i2,' (',a11,')')
  420 format (' holder type',i2,' (',a11,'), beta=',f6.2,'*value +',f7.
     12)
  430 format (' maximum number of indexings to be output:',i5)
  440 format (34x,'reset to',i5)
  450 format (' **** recommended: > 4, must be <',i4)
  460 format (' max. multiplicity for cell param. determ.:',i3)
  470 format (' **** should be 1 or 2 ****')
  480 format (' number of unindexible c.p. sets between inquiries:',i8)
  490 format (' **** should be at least 100 ****')
  500 format (' lines per screen:',i4)
  510 format (' spacing (lines) of rows of reflections in graphic ','rep
     1resentation'/' of zone patterns (>6, <21):',i3)
  520 format (' **** even numbers recommended ****')
  530 format (' **** outside permitted range ****')
  540 format (' max floating point size: 10**',i2/' max integer size    
     1   : 10**',i2)
  550 format ('  commands 1:')
  560 format ('  commands 2:')
  570 format (/' **** no commands defined (no "%" in col. 1) ****')
  580 format (' ****  no "$" in col.1 (preceding file names)',' encounte
     1red ****')
  590 format (/' *** ok, no grammatical errors detected ***'/'          
     1 strike any key to exit ')
  600 format (a1)
  610 format (' parameter-file ',a20,'? (blank), otherwise name')
  620 format (5a12)
  630 format (' comment: ',5a12)
  640 format (/10x,'===== VERSION ',a9,' ====='/)
  650 format ('  unsuited parameter file'/'  version date (',a12,') must
     1 be ',a9)
  660 format (a20)
  670 format (17x,11(a2,3x),10(/7x,13(a2,3x)))
  680 format (' FD:',f8.3,', FW:',f8.3/' ITST(1):',i2,', FTST(1):',f5.3,
     1', ISTT:',i3,', ITST(2):',i3)
  690 format (' FLIM:',f10.2,', alog10(size):',2i4)
  700 format (1x,71('*'))
      end
c ===========
      logical function law(aw)
      character*1 aw
      law=.false.
      if (aw.eq.'n'.or.aw.eq.'N') law=.true.
      return
      end
c ==========
      subroutine ckco (j77,ie,ioa)
      parameter (jj1=19,jj2=199,jj3=140,jj4=20,jj5=100,jj6=40)
c-p      parameter (jj1=19,jj2=999,jj3=140,jj4=15,jj5=100,jj6=15)
      common /j8/ j8(jj3),j9(jj3),j85(6)
      character*2 j8,j9,j1,j2
      character*5 j85
      ie=0
      do 40 i=1,j77-1
        j1=j9(i)
        j2=j8(i)
        do 40 j=i+1,j77
        if (j9(j).eq.j1.or.j9(j).eq.j2) go to 20
   10   if (j8(j).eq.j1.or.j8(j).eq.j2) go to 30
        go to 40
   20   write (ioa,50) i,j,j9(j)
        ie=1
        go to 10
   30   write (ioa,50) i,j,j8(j)
        ie=1
   40 continue
      return
c 
c
   50 format (44('*')/' *** duplicated command: #',i3,', #',i3' : ',a2,'
     1 ***'/44('*'))
      end
c ==========
c subr. for interpretation of free format and check in col.1
c 
      subroutine les (in)
c 
c The labeled common /cc/ contains the following values
c koma   : If = 1:  ',' interpreted as decimal '.' (in addition)
c ifdi   : max. exponent of 10 for floating point
c mdi    : max. exponent of 10 for integers
c          For mdi .gt. 7 the last digit is not reliable.
c c(15)  : the numbers, tailing numbers are zeroed
c ndi(15): ndi(i)=iabs(int(alog10(c(i))))
c ie  : 0: all normal
c       1: non numeric symbol in col. 1
c       2: at least one abs(c(i)) > 10**ifdi or < 10**(-ifdi)
c       3: end of file
c       4: misplaced "." or "-"
c remark: interpretation stops after the first occurence of b(13)(;)
c         the remaining c's are zeroed. Any other character except
c         figures, "." and "-" is a separator between two numbers.
c 
      common /cc/ koma,ifdi,mdi,c(15),ier,ndi(15)
      common /xc/ xc(4),xm
      dimension k(15), a(70), f(15), b(15)
      character*1 b,a
      data b/'1','2','3','4','5','6','7','8','9','0','.','-',';',' ','!'
     1/
c             ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
c             1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
      data ioa/6/
      read (in,220,end=180) a
      ier=1
c     ie=0
      i1=1
ccccc
      if (koma.eq.1.and.a(1).eq.',') a(1)='.'
ccccc
      do 10 i=1,15
        if (a(1).eq.b(i)) go to 20
   10 continue
      ier=0
c     ie=1
      return
   20 do 30 i=1,15
        ndi(i)=0
   30   c(i)=0.
      if (a(1).eq.b(15)) go to 200
      n=0
      i2=1
      im=1
      i0=1
      do 140 i=1,70
ccccc
        if (koma.eq.1.and.a(i).eq.',') a(i)='.'
ccccc
        if (a(i).eq.' ') go to 130
        do 40 j=1,13
          if (a(i).eq.b(j)) go to (50,60),i2
   40   continue
        go to 130
c 
   50   if (j.eq.10) i0=2
        i2=2
        if (n.eq.15) go to 150
        n=n+1
        k(n)=0
        i1=1
        f(n)=1.
   60   if (j-11) 70,110,120
   70   if (j.eq.10.and.i0.eq.2) go to 80
        i0=1
        ndi(n)=ndi(n)+1
        if (ndi(n).gt.ifdi) go to 90
   80   c(n)=10.*c(n)+float(mod(j,10))
        go to (140,100),i1
   90   if (iabs(ndi(n)-k(n)).gt.ifdi) go to 170
        go to 140
c 
  100   k(n)=k(n)+1
        go to 140
c 
  110   if (i1.eq.2) go to 190
        i1=2
        i0=1
        go to 140
c 
  120   if (j.eq.13) go to 150
        if (c(n).gt.0..or.i1.eq.2) go to 190
        if (im.eq.2.or.i0.eq.2) go to 190
        f(n)=-1.
        im=2
        go to 140
c 
  130   i2=1
        i0=1
        im=1
  140 continue
  150 if (n.eq.0) return
      do 160 i=1,n
        c(i)=f(i)*c(i)/10.**k(i)
  160   ndi(i)=ndi(i)-k(i)
      return
  170 ier=0
c     ie=2
      write (ioa,230) ifdi
      return
  180 ier=0
c     ie=3
      write (ioa,240)
      return
  190 ier=0
c     ie=4
      write (ioa,250)
      return
  200 c(1)=xc(1)
      do 210 i=2,4
  210   if (a(2).eq.b(i)) c(1)=xc(i)
      if (a(2).eq.b(15)) c(1)=xm
      write (6,*) c(1)
      return
c 
c 
c
  220 format (80a1)
  230 format (' real number exceeds 10**(+-)',i2)
  240 format (' command not executed or end of file')
  250 format (' misplaced "." or "-"')
      end
c ==========
      block data
c 
c jj1=max(max(hkl mit r=r1+-delta , hkl mit r=r2+-delta))
c     muss bei grossen problemen evtl. erhoeht werden.
c Jj2=maximalzahl der besten hkl-paare fuer ausgabe
c jj3=zahl der befehle (darf nicht geaendert werden)
c jj4=maximalzahl der datensaetze im A-speicher
c 
      parameter (jj1=19,jj2=199,jj3=140,jj4=20)
c-p      parameter (jj1=19,jj2=999,jj3=140,jj4=15)
c 
      common /r/ in,io,ioa,igl,igh,iru,iro,iul,iuh,nnn,ivr,ix,iy,isf,nu,
     1nru,irw,nbb,iop,istp1,iho,nwm,mul2,nstop,limax,ny,istt,al0,be0
      common /cd1/ d1d(jj1),d2d(jj1),h1h(3,jj1),h2h(3,jj1)
      common /cc/ koma,ifdi,mdi,c(15),n,ndi(15)/csb/b(14)
      common /cgg/ gg(14,jj2),ac(jj2)/izz/izm(jj2),i6(jj3)
      common /date/ wiw,wiv,wik,sk,sr1,swi,hv0,yzx,ydx,xl,da0,csig0,
     1rsig0,asig0,difw,dazb,ddw,ddv,vdd,dl0,dw0,dl1,xj,yj,xjh,yjh,fd,fw,
     2difa,difg,dc0
      common /j8/ j8(jj3),j9(jj3),j85(6)
      common /prz/ kp(3,3,7),kz(3,3,7),kf(7)
      common /b/ ii,jj,ila,ke,nq(jj4)
      common /rer/ ak,dak,r1,dr1,r2,dr2,r3,dr3,wi,dwi,r01,sr0,r0m,su1,
     1hv,v22,r0,rl1,tl,ph,akl,vca,an1,an2,an0,du(2),do(2),ala,se,ako2,
     2aku2,cw1,wo,wu,d4,s1u,s1o,fakr
      common /sb1/ jsm(7),jsml(7),ivo(2),s1(2),p7(2),p7l(2),p9(2),p8(2),
     1rs,holder(3)
      common /sb2/ isys(6),ta0,ta0l,ta1,p6(2),s2(2),s4(2)
      common /cons/ l,icm,ira,ine,np,lq,l8,l7,j4,imir,iv,lqq,ivv
      common /cons2/ fk(7),sq3,a9
      common /tran/ acp(3,3),apc(3,3),itdel,ni(3)
      common /rec/ rf(40,jj4),irf(8,jj4),ind(jj4),inda
      common /gg/ dg(6),rg(6),g(14),dgw(3),rgw(3),v0,vj,fak,viw,viv,vik
      common /ti/ titel(18),text(17),tit(18,jj4)
      common /ld/ da,db,dc,nce,hmis,dec5,dew,flc,flc1,flim,sga,sga2,al,
     1be,x(3,3),xx(3,3),rrgg(6),nc,h0
      common /dd1/ jc(4,4),ncl(30),iq(27),nvv(8),iiv(7,7),inc(3,7),
     1kis(8,30),it1(432),it2(333),mvv(8),lvv(8),itt(20,14),isb(30),
     2idt(13)
      common /cm12/ be01,be00,rbe1,rbe0
      common /xc/ xc(4),xm
      common /dd2/ pp(4,4,6),gg6(4,4)
      common /ngk/ ngk
      common /iskip/ iskip,isig,isig0
      common /files/ file1,file2,file3,file4,file5,fdd
      character*20 file1,file2,file3,file4,file5,fdd
      character*1 jsm,jsml,ivo,s1,p7,p7l,p9,p8,b,ni,s4
      character*2 j9,j8
      character*3 s2
      character*4 isys,ta0,ta0l,ta1,titel,tit,text,p6
      character*5 j85
      character rs*10,holder*11
c 
c********
c             Parameters(1)
c********
c 
c IN=input unit (terminal)
c IO=standard output unit (terminal)
c 
      data in,io,ioa/5,6,6/
c FD, FW : factors for sigma generation (in LDINI etc.)
c     data fd,fw/.55,.5/
      data fd,fw/.55,.65/
c 
c IUL=lowest logical unit for protocol file
c IUH=highest    -- ' --      protocol file
c 
c IGL=lowest     -- ' --      lattice constant file
c IGH=highest    -- ' --      lattice constant file
c 
c IRU=lowest     -- ' --      reflection file
c IRO=highest    -- ' --      reflection file
c 
c    These three ranges should not overlap
c 
      data iul,iuh,igl,igh,iru,iro/8,19,20,29,30,39/
c 
c********
c Parameters(2) (if no file PIEP.PAR is present)
c********
c 
c 
c WIW=default value of weight for error in angle (deg.)
c WIV=              -- ' --             in R1/R2(%)
c WIK=              -- ' --             in camera constant(%)
c      for the figure of merit (sum(weight*ABS(error)))
c1
      data wiw,wiv,wik/0.6,0.8,0.3/
c 
c SK=default value of sigma(camera constant) (relative)
c SR1=     -- ' --         (radii) (relative)
c SWI=     -- ' --         (angle) (deg.)
c2
      data sk,sr1,swi/0.05,0.03,3.0/
c 
c HV0=default value for high tension (volt)
c3
      data hv0/200000./
c 
c YZX=default value for ratio height/width of a character
c YDX= same for lineprinter
c3a
      data yzx,ydx/1.8,2.0/
c 
c XL : X-ray wavelength for 2-theta calculations
c4
      data xl/1.54056/
c 
c DA0,CSIG0,RSIG0,ASUG0: default values for increment f,
c5 default temporary errors in lattice constant determination routine
      data da0,csig0,rsig0,asig0/.035,.01,.01,.5/
c 
c DIFW: maximum difference in angle
c DAZB:        - " -          a/c, b/c for check of equivalence
c       in lattice constant determination routine
c6
      data difw,dazb/2.,0.05/
c 
c DDW: max. deviation of angle
c DDV: max. deviation of ratio of axes
c               in Delaunay reduction, from the value
c               prescribed by crystal class
c7
      data ddw,ddv/4.0,0.1/
c 
c DIFA: max. relative difference of two lengths to be considered as
c        being equal (in cell parameter determination)
c DIFG: max. deviation of an angel to be considered as 90 deg.
c        from 90 deg. (in cell parameter determination)
c8
      data difa,difg/.001,0.2/
c 
c VDD=default value for largest accepted deviation in volume (%)
c DL0=default value   sigma(radius 0. Laue zone) (absolute, mm)
c DW0=default value   sigma(tilt angle) (deg.)
c DL1=     -- ' --         (difference radius 1.-0. Laue zone)(abs., mm)
c10
      data vdd,dl0,dw0,dl1/50.0,5.0,1.0,5.0/
c 
c 
c XJ,YJ: scale factors for x- and y-deflector coils
      data xj,yj/.46312,.41377/
c XJH,YJH: scale factors for x- and y-deflector coils, hexadec. input
      data xjh,yjh/.065,.063/
c 
c  JEM3010, 3000mm camera length
c 
c====== INTEGERS =====
c 
c IHO: default type of holder: 1: double tilt, 2: rotation
c 
c MUL2: max. multiplicity of primitive mesh enforced by <LD>
c 
c NSTOP= approximate number of lattice constant generations
c        between two inquiries (if ISTP=1)
c 
c ISTT: cycles in Delaunay reduction
c 
c LIMAX: Zeilen/Bildschirm
c 
c NY: lines/row for graphic representation of zone axes
c 
c IFDI: log10(maximum floating point size)
c 
c MDI: log10(maximum integer size)
c 
      data iho,mul2,nstop,limax,ny,istt,ifdi,mdi/1,2,10000,18,8,10,27,7/
c 
c commands
      data j9/'CP','WT','NR','CC','R1','R2','R3','AN','EN','I ','L ','LG
     1','TI','A ','B ','C ','AL','BE','GA','CN','PO','IR','MU','RL','EC'
     2,'E1','E2','E3','EA','RW','SC','SF','PS','PG','PW','LN','H ','HV',
     3'OR','OD','L0','L1','D0','D1','LY','VN','VY','EV','RD','NP','S1','
     4AG','AP','SA','AW','AD','RN','RY','CM','PC','DC','DE','CW','BR','C
     5G','EQ','BP','BG','BD','CR','CD','LD','RF','SS','BS','ZA','BW','XW
     6','GS','GR','GC','ND','V ','DS','LW','. ','+ ','- ','* ',':','**',
     7'< ','> ','<>','LX','MP','MG','SI','CO','TG','AS','AC','AT','.1','
     8.2','.3','.4','..','UN','RO','YX','NL','C0','LO','E*','SD','HH','A
     9E','CZ','IS','TE','JE','NC','HD','JH','OZ','AB','CS','RE','SQ','RT
     x','.M','LA','AI','MV',5*'DU'/
      data j8/'cp','wt','nr','cc','r1','r2','r3','an','en','i ','l ','lg
     1','ti','a ','b ','c ','al','be','ga','cn','po','ir','mu','rl','ec'
     2,'e1','e2','e3','ea','rw','sc','sf','ps','pg','pw','ln','h ','hv',
     3'or','od','l0','l1','d0','d1','ly','vn','vy','ev','rd','np','s1','
     4ag','ap','sa','aw','ad','rn','ry','cm','pc','dc','de','cw','br','c
     5g','eq','bp','bg','bd','cr','cd','ld','rf','ss','bs','za','bw','xw
     6','gs','gr','gc','nd','v ','ds','lw','. ','+ ','- ','* ','/ ','**'
     7,'< ','> ','<>','lx','mp','mg','si','co','tg','as','ac','at','.1',
     8'.2','.3','.4','..','un','ro','yx','nl','c0','lo','e*','sd','hh','
     9ae','cz','is','te','je','nc','hd','jh','oz','ab','cs','re','sq','r
     xt','.m','la','ai','mv',5*'du'/
c 
c 
      data file1,file2,file3,file4,file5/'CELL.DAT','SAD.DAT','PRO2.DAT'
     1,'PRO1.DAT','CELL.SCR'/
c************
c  Parameters(2) (if no file PIEP.PAR is present): end
c************
c 
      data ni,s4/' ','*','?','c','l'/
      data jsm,p7,ta0/'P','A','B','C','R','I','F','N','Y','.   '/
      data jsml,p7l,ta0l/'p','a','b','c','r','i','f','n','y',',  '/
c 
      data ivo,s1,p9,p8/'-','+','r','d',':','>',':','<'/
      data isys/'trik','mkl.','hexa','orth','tetr','cub.'/
      data j85/'    a','    b','    c','alpha',' beta','gamma'/
      data b/'1','2','3','4','5','6','7','8','9','0','.','-',';',' '/
      data rs,holder/' (***)    ','double tilt','rotation h.','CM12 dbl.
     1t.'/
      data nu,nru,nnn,ivr,iy,ix,isf,ila,iv,iop,ngk/0,9,3*0,4*1,2,0/
      data itdel,irw,icm,l,ira,ine,np,lq,l7,l8,j4,lqq,ivv/0,2,2,2*0,8*1/
      data fk,sq3,r0,r0m,sr0,rl1,su1,ph,tl,vca,a9,fakr,al0,be0/1.,3*2.,
     13.,2.,4.,1.732050808,8*0.,999999.,57.2957795,0.,0./
      data i6/1,1,0,5*1,3*0,1,0,7*1,0,10*1,0,0,1,0,1,0,1,0,0,14*1,5*0,1,
     11,1,0,0,1,1,0,1,0,0,0,1,0,1,9*0,1,24*0,1,1,5*0,1,3*0,1,0,1,0,0,1,
     215*0/
      data kp/1,3*0,1,3*0,1,2,3*0,1,1,0,-1,1,1,0,-1,0,2,0,1,0,3*1,0,-1,
     11,3*0,2,2,1,1,-1,1,1,-1,-2,1,-1,3*1,-1,3*1,-1,0,3*1,0,3*1,0/
c 
c     data kf,istp1,flim/1,3*2,3,2,2,2,.5/
      data iskip,isig,isig0,kf,istp1,flim/0,3*1,3*2,3,2,2,2,2./
c 
      data kz/1,3*0,1,3*0,1,1,3*0,1,-1,0,3*1,0,1,0,1,0,-1,0,1,1,-1,0,1,
     11,3*0,1,1,-1,0,0,1,-1,3*1,0,3*1,0,3*1,0,-1,3*1,-1,3*1,-1/
      data p6,s2/'L1-0','1/d*',' +-',';mm'/
      data an0,r1/0.,0./
      data gg6,xc,xm/21*0./
      data jc/0,12,13,14,12,0,23,24,13,23,0,34,14,24,34,0/,ncl/30*0/,iq/
     11,1,4,1,1,2,3,2,2,1,1,3,1,1,4,4,3*2,3,3,4,2,3,4,4,1/
      data pp/-1.,3*0.,1.,0.,1.,2*0.,1.,2*0.,1.,2*0.,1.,-1.,3*0.,2*1.,4*
     10.,1.,0.,1.,2*0.,1.,-1.,3*0.,2*1.,5*0.,2*1.,0.,1.,2*0.,-1.,2*0.,2*
     21.,4*0.,1.,2*0.,1.,0.,1.,0.,-1.,2*0.,2*1.,5*0.,1.,0.,2*1.,3*0.,-1.
     3,0.,1.,0.,1.,4*0.,1.,0.,2*1.,0./
      data nvv/14,15,19,14,14,17,18,16/,iiv/0,5,6,7,2,3,4,5,0,7,6,1,4,3,
     16,7,0,5,4,1,2,7,6,5,0,3,2,1,2,1,4,3,0,0,0,3,4,1,2,3*0,4,3,2,1,3*0/
      data inc/1,3*0,1,3*0,1,3*-1,1,1,0,1,0,1,0,1,1/
      data kis/0,0,14,0,2*14,1,61,0,0,3*14,0,2,61,0,4*13,0,3,65,6*12,4,
     166,12,0,12,0,12,34,1,51,0,3*13,24,0,5,57,2*12,14,12,2*14,6,57,0,0,
     214,0,14,34,1,41,0,0,2*14,24,0,2,41,0,0,14,23,0,23,13,41,0,4*13,34,
     37,46,12,4*13,12,4,46,0,0,14,0,24,34,1,31,0,0,14,23,24,0,2,31,0,13,
     42*14,13,0,4,36,0,2*13,2*23,0,7,36,12,0,14,0,12,34,8,34,12,0,14,0,
     514,34,9,34,0,2*13,2*23,34,7,36,12,13,2*14,13,12,4,36,12,4*13,34,3,
     635,0,13,14,0,24,34,1,21,0,13,14,2*23,0,10,26,0,13,14,23,13,0,28,
     726,0,13,2*14,13,34,11,26,0,13,14,13,14,34,12,26,0,13,14,2*23,34,
     810,26,12,13,2*14,13,34,11,26,12,13,14,13,14,34,12,26,12,13,14,23,
     924,34,1,11/
      data it1/1,3*0,1,3*0,1,1,4*0,1,0,4*1,0,-1,1,0,1,1,2,0,3*1,0,3*1,0,
     11,4*0,1,1,3,2,1,-1,0,0,1,-1,4*1,3*0,1,0,1,1,2,2,1,0,0,1,3*0,1,1,-
     21,0,1,1,3*0,1,2*-1,-2,0,1,0,1,3*0,4*1,0,-1,0,4*-1,1,-1,3*0,1,0,1,
     30,0,3*1,0,0,1,3*0,1,3*0,1,0,-1,0,-1,4*0,-1,2*0,-1,0,-1,0,-1,3*0,1,
     43*0,1,1,4*0,1,1,3*0,1,0,-1,4*0,-1,0,-1,0,1,3*0,-1,0,-1,0,-1,2*0,-
     51,0,1,0,1,0,1,1,0,1,0,1,0,-1,2*0,1,0,1,0,-1,3*0,-1,1,3*0,1,3*0,2*
     61,3*0,-1,3*0,2*-1,3*0,1,3*0,2*-1,3*0,-1,3*0,3*1,0,0,1,1,-1,0,-1,1,
     71,0,0,-1,1,1,4*-1,0,0,1,1,-1,1,2*-1,1,0,0,4*-1,1,1,0,1,1,0,-1,0,1,
     80,0,1,1,0,-1,1,1,4*0,3*1,0,-1,1,-1,0,0,1,1,-1,0,1,1,-1,1,3*0,1,1,
     92*-1,1,1,3*0,-1,1,3*-1,0,1,0,1,0,1,1,2*-1,0,1,0,1,0,5*-1,1,3*0,1,
     x1,0,0,1,3*0,1,0,-1,0,1,0,-1,1,1,4*0,1,0,1,3*0,1,1,-1,0,0,3*1,4*0,-
     x1,1,0,-1,0,1,3*0,1,1,0,0,1,2,3*0,1,0,1,0,-2,-1,3*0,1,1,2,1,1,4*0,-
     x1/
      data it2/1,0,-1,1,2,3*0,1,-1,4*1,3*0,-1,1,1,2*-1,1,3*0,1,2,1,1,0,
     11,3*0,1,0,0,1,2,1,0,0,1,-1,6,-6,0,0,6,-6,3*3,6,6,0,0,-6,6,3,2*-3,
     22*-6,0,0,6,6,-3,3,-3,-6,6,0,0,2*-6,2*-3,3,3,-3,3,6,6,0,-3,3,3,2*-
     33,3,6,-6,0,3*3,-3,3,3,6,0,6,3,3,-3,3*3,6,0,-6,-3,3,-3,3,3,-3,0,6,
     46,3,-3,3,3,2*-3,0,6,-6,4*3,-3,0,3,3,3*0,6,3,0,3,3,0,-3,0,6,0,0,3,
     53,0,-3,3,6,0,0,3,-3,0,0,3,-3,3*6,3,3,0,0,-3,3,6,2*-6,2*-3,0,0,3,3,
     6-6,6,-6,-3,3,0,0,2*-3,2*-6,6,0,0,6,3,3,0,-3,3,3*0,6,3,-3,0,3,3,0,
     76,3*0,3,3,0,-3,3,6,3*0,-3,3,0,2*-3,0,6,0,3,0,3,3,0,-3,0,6,0,3,0,2*
     8-3,0,-3,0,0,6,6,0,0,2,4,-2,2,2*-2,6,6,3*0,6,4,2,-2,0,6,3*0,6,0,-3,
     93,6,3*0,3,3,3,0,-3,0,6,0,3,0,3*3,3*0,6,3,-3,0,-2,-4,-2,6,0,0,-4,-
     x8,2,2,2*-2,6,6,0,4,-4,2,4,2,-2,0,6,0,8,4,2/
      data mvv/14,15,14,17,19,14,18,16/,lvv/14,14,20,22,16,21,14,23/,
     1itt/141,1741,1841,657,2957,3057,3157,131,934,3234,3334,121,1721,
     21821,3426,3526,3626,3726,3826,3926,146,1746,1846,5457,5557,5657,
     35757,136,935,3235,3335,126,1726,1826,5826,5926,6026,6126,6226,
     46326,6446,6546,6646,6757,6857,6957,7057,135,6436,6536,6636,6426,
     56526,6626,7126,7226,7326,7426,7526,7626,131,934,121,1721,1821,
     63426,3526,13*0,136,935,126,1726,1826,5826,5926,13*0,4634,934,4734,
     7121,4826,4926,5026,5126,5226,5326,10*0,7726,7826,7926,17*0,121,
     81721,1821,17*0,8021,4026,4126,17*0,8121,4226,4326,17*0,8221,4426,
     94526,17*0,8026,8126,8226,17*0,126,1726,1826,17*0,8326,8426,8526,
     x17*0/
      data isb/4*21,11,4,4,5*8,9*4,9*1/,idt/61,66,65,41,46,51,57,31,32,
     133,34,35,36/
c 
      end
