
!##############################################################
 MODULE debug
!##############################################################
 use prec

 implicit none
 integer(pInt), dimension(:), allocatable :: debug_StressLoopDistribution
 integer(pInt), dimension(:), allocatable :: debug_StateLoopDistribution
 integer(pInt), dimension(:), allocatable :: debug_StiffnessStateLoopDistribution
 integer(pInt), dimension(:), allocatable :: debug_CrystalliteLoopDistribution
 integer(pInt), dimension(:), allocatable :: debug_MaterialpointLoopDistribution          ! added <<<updated 31.07.2009>>>
 integer(pLongInt) :: debug_cumLpTicks = 0_pInt
 integer(pLongInt) :: debug_cumDotStateTicks = 0_pInt
 integer(pLongInt) :: debug_cumDotTemperatureTicks = 0_pInt
 integer(pInt) :: debug_cumLpCalls = 0_pInt
 integer(pInt) :: debug_cumDotStateCalls = 0_pInt
 integer(pInt) :: debug_cumDotTemperatureCalls = 0_pInt
 logical :: debugger = .false.
 logical :: distribution_init = .false.

 CONTAINS

subroutine debug_init()
  
  use prec,     only: pInt  
  use numerics, only: nStress, &
                      nState, &
                      nCryst, &
                      nHomog                                                              ! added <<<updated 31.07.2009>>>
  implicit none
  
  write(6,*)
  write(6,*) '<<<+-  debug init  -+>>>'
  write(6,*)
 
  allocate(debug_StressLoopDistribution(nStress)) ;        debug_StressLoopDistribution = 0_pInt
  allocate(debug_StateLoopDistribution(nState)) ;          debug_StateLoopDistribution = 0_pInt
  allocate(debug_StiffnessStateLoopDistribution(nState)) ; debug_StiffnessStateLoopDistribution = 0_pInt
  allocate(debug_CrystalliteLoopDistribution(nCryst)) ;    debug_CrystalliteLoopDistribution = 0_pInt
  allocate(debug_MaterialpointLoopDistribution(nhomog)) ;  debug_MaterialpointLoopDistribution = 0_pInt ! added <<<updated 31.07.2009>>>
endsubroutine
 
!********************************************************************
! reset debug distributions
!********************************************************************
subroutine debug_reset()

  use prec
  implicit none

  debug_StressLoopDistribution         = 0_pInt ! initialize debugging data
  debug_StateLoopDistribution          = 0_pInt
  debug_StiffnessStateLoopDistribution = 0_pInt
  debug_CrystalliteLoopDistribution    = 0_pInt
  debug_MaterialpointLoopDistribution  = 0_pInt ! added <<<updated 31.07.2009>>>
  debug_cumLpTicks       = 0_pInt
  debug_cumDotStateTicks = 0_pInt
  debug_cumDotTemperatureTicks = 0_pInt
  debug_cumLpCalls       = 0_pInt
  debug_cumDotStateCalls = 0_pInt
  debug_cumDotTemperatureCalls = 0_pInt

endsubroutine

!********************************************************************
! write debug statements to standard out
!********************************************************************
 subroutine debug_info()

 use prec
 use numerics, only: nStress, &
                      nState, &
                      nCryst, &
                      nHomog              ! added <<<updated 31.07.2009>>>
 implicit none

 integer(pInt) i,integral
 integer(pLongInt) tickrate
 

 write(6,*)
 write(6,*) 'DEBUG Info'
 write(6,*)
 write(6,'(a33,x,i12)')	'total calls to LpAndItsTangent  :',debug_cumLpCalls
 if (debug_cumLpCalls > 0_pInt) then
   call system_clock(count_rate=tickrate)
   write(6,'(a33,x,f12.6)') 'avg CPU time/microsecs per call :',dble(debug_cumLpTicks)/tickrate/1.0e-6_pReal/debug_cumLpCalls
   write(6,'(a33,x,f12.3)') 'total CPU time/s                :',dble(debug_cumLpTicks)/tickrate
 endif
 write(6,*)
 write(6,'(a33,x,i12)')	'total calls to dotState             :',debug_cumDotStateCalls
 if (debug_cumdotStateCalls > 0_pInt) then
   call system_clock(count_rate=tickrate)
   write(6,'(a33,x,f12.6)') 'avg CPU time/microsecs per call :',&
     dble(debug_cumDotStateTicks)/tickrate/1.0e-6_pReal/debug_cumDotStateCalls
   write(6,'(a33,x,f12.3)') 'total CPU time/s                :',dble(debug_cumDotStateTicks)/tickrate
 endif
 write(6,*)
 write(6,'(a33,x,i12)')	'total calls to dotTemperature       :',debug_cumDotTemperatureCalls
 if (debug_cumdotTemperatureCalls > 0_pInt) then
   call system_clock(count_rate=tickrate)
   write(6,'(a33,x,f12.6)') 'avg CPU time/microsecs per call :',&
     dble(debug_cumDotTemperatureTicks)/tickrate/1.0e-6_pReal/debug_cumDotTemperatureCalls
   write(6,'(a33,x,f12.3)') 'total CPU time/s                :',dble(debug_cumDotTemperatureTicks)/tickrate
 endif

 integral = 0_pInt
 write(6,*)
 write(6,*)	'distribution_StressLoop :'
 do i=1,nStress
   if (debug_StressLoopDistribution(i) /= 0) then
     integral = integral + i*debug_StressLoopDistribution(i)
     write(6,'(i25,i10)') i,debug_StressLoopDistribution(i)
   endif
 enddo
 write(6,'(a15,i10,i10)') '          total',integral,sum(debug_StressLoopDistribution)
 
 integral = 0_pInt
 write(6,*)
 write(6,*)	'distribution_StateLoop :'
 do i=1,nState
   if (debug_StateLoopDistribution(i) /= 0) then
     integral = integral + i*debug_StateLoopDistribution(i)
     write(6,'(i25,i10)') i,debug_StateLoopDistribution(i)
   endif
 enddo
 write(6,'(a15,i10,i10)') '          total',integral,sum(debug_StateLoopDistribution)

 integral = 0_pInt
 write(6,*)
 write(6,*)	'distribution_StiffnessStateLoop :'
 do i=1,nState
   if (debug_StiffnessStateLoopDistribution(i) /= 0) then
     integral = integral + i*debug_StiffnessStateLoopDistribution(i)
     write(6,'(i25,i10)') i,debug_StiffnessStateLoopDistribution(i)
   endif
 enddo
 write(6,'(a15,i10,i10)') '          total',integral,sum(debug_StiffnessStateLoopDistribution)
 
 integral = 0_pInt
 write(6,*)
 write(6,*)	'distribution_CrystalliteLoop :'
 do i=1,nCryst
   if (debug_CrystalliteLoopDistribution(i) /= 0) then
     integral = integral + i*debug_CrystalliteLoopDistribution(i)
     write(6,'(i25,i10)') i,debug_CrystalliteLoopDistribution(i)
   endif
 enddo
 write(6,'(a15,i10,i10)') '          total',integral,sum(debug_CrystalliteLoopDistribution)
 write(6,*)

!* Material point loop counter <<<updated 31.07.2009>>>
 integral = 0_pInt
 write(6,*)
 write(6,*)	'distribution_MaterialpointLoop :'
 do i=1,nCryst
   if (debug_MaterialpointLoopDistribution(i) /= 0) then
     integral = integral + i*debug_MaterialpointLoopDistribution(i)
     write(6,'(i25,i10)') i,debug_MaterialpointLoopDistribution(i)
   endif
 enddo
 write(6,'(a15,i10,i10)') '          total',integral,sum(debug_MaterialpointLoopDistribution)
 write(6,*)

 endsubroutine
 
 END MODULE debug
