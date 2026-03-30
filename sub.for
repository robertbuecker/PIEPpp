      dimension b(8)
      character a*16, c*16, b*8
      c= 'c #######======='
    1 read(1,11,end=99)a,b
      if(a.ne.c)goto 1
      write(2,12)b(1),b(8)
   11 format(a16,8a8)
   12 format(1x,2a8)
      do 13 j=1,3
      read(1,11,end=99)a,b
   13 write(2,11)a,(b(i),i=1,7)
      go to 1
   99 stop
      end
      
