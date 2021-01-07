!----------------------------------------------------------------------------------------------------
!> @brief internal microstructure state for all thermal sources and kinematics constitutive models
!----------------------------------------------------------------------------------------------------
submodule(constitutive) constitutive_thermal

  type :: tDataContainer
    real(pReal), dimension(:), allocatable :: T
  end type tDataContainer
  integer(kind(SOURCE_undefined_ID)),     dimension(:,:), allocatable :: &
    thermal_source

  type(tDataContainer), dimension(:), allocatable :: current

  integer :: thermal_source_maxSizeDotState
  interface

  module function source_thermal_dissipation_init(source_length) result(mySources)
    integer, intent(in) :: source_length
    logical, dimension(:,:), allocatable :: mySources
  end function source_thermal_dissipation_init

  module function source_thermal_externalheat_init(source_length) result(mySources)
    integer, intent(in) :: source_length
    logical, dimension(:,:), allocatable :: mySources
  end function source_thermal_externalheat_init

  module function kinematics_thermal_expansion_init(kinematics_length) result(myKinematics)
    integer, intent(in) :: kinematics_length
    logical, dimension(:,:), allocatable :: myKinematics
  end function kinematics_thermal_expansion_init


  module subroutine source_thermal_dissipation_getRateAndItsTangent(TDot, dTDot_dT, Tstar, Lp, phase)
    integer, intent(in) :: &
      phase                                                                                         !< phase ID of element
    real(pReal),  intent(in), dimension(3,3) :: &
      Tstar                                                                                         !< 2nd Piola Kirchhoff stress tensor for a given element
    real(pReal),  intent(in), dimension(3,3) :: &
      Lp                                                                                            !< plastic velocuty gradient for a given element
    real(pReal),  intent(out) :: &
      TDot, &
      dTDot_dT
  end subroutine source_thermal_dissipation_getRateAndItsTangent

  module subroutine source_thermal_externalheat_getRateAndItsTangent(TDot, dTDot_dT, phase, of)
    integer, intent(in) :: &
      phase, &
      of
    real(pReal),  intent(out) :: &
      TDot, &
      dTDot_dT
  end subroutine source_thermal_externalheat_getRateAndItsTangent

 end interface

contains

!----------------------------------------------------------------------------------------------
!< @brief initializes thermal sources and kinematics mechanism
!----------------------------------------------------------------------------------------------
module subroutine thermal_init(phases)

  class(tNode), pointer :: &
    phases

  class(tNode), pointer :: &
    phase, thermal, sources

  integer :: &
    ph, so, &
    Nconstituents


  print'(/,a)', ' <<<+-  constitutive_thermal init  -+>>>'

  allocate(current(phases%length))

  allocate(thermalState (phases%length))
  allocate(thermal_Nsources(phases%length),source = 0)

  do ph = 1, phases%length

    Nconstituents = count(material_phaseAt == ph) * discretization_nIPs

    allocate(current(ph)%T(Nconstituents))
    phase => phases%get(ph)
    if(phase%contains('thermal')) then
      thermal => phase%get('thermal')
      sources => thermal%get('source',defaultVal=emptyList)

      thermal_Nsources(ph) = sources%length
    endif
    allocate(thermalstate(ph)%p(thermal_Nsources(ph)))
  enddo

  allocate(thermal_source(maxval(thermal_Nsources),phases%length), source = SOURCE_undefined_ID)

  if(maxval(thermal_Nsources) /= 0) then
    where(source_thermal_dissipation_init (maxval(thermal_Nsources))) thermal_source = SOURCE_thermal_dissipation_ID
    where(source_thermal_externalheat_init(maxval(thermal_Nsources))) thermal_source = SOURCE_thermal_externalheat_ID
  endif

  thermal_source_maxSizeDotState = 0
  PhaseLoop2:do ph = 1,phases%length

    do so = 1,thermal_Nsources(ph)
      thermalState(ph)%p(so)%partitionedState0 = thermalState(ph)%p(so)%state0
      thermalState(ph)%p(so)%state             = thermalState(ph)%p(so)%partitionedState0
    enddo

    thermal_source_maxSizeDotState   = max(thermal_source_maxSizeDotState, &
                                                maxval(thermalState(ph)%p%sizeDotState))
  enddo PhaseLoop2

!--------------------------------------------------------------------------------------------------
!initialize kinematic mechanisms
  if(maxval(phase_Nkinematics) /= 0) where(kinematics_thermal_expansion_init(maxval(phase_Nkinematics))) &
                                           phase_kinematics = KINEMATICS_thermal_expansion_ID

end subroutine thermal_init


!----------------------------------------------------------------------------------------------
!< @brief calculates thermal dissipation rate
!----------------------------------------------------------------------------------------------
module subroutine constitutive_thermal_getRateAndItsTangents(TDot, dTDot_dT, T, ip, el)

  integer, intent(in) :: &
    ip, &                                                                                           !< integration point number
    el                                                                                              !< element number
  real(pReal), intent(in) :: &
    T                                                                                             !< plastic velocity gradient
  real(pReal), intent(inout) :: &
    TDot, &
    dTDot_dT

  real(pReal) :: &
    my_Tdot, &
    my_dTdot_dT
  integer :: &
    ph, &
    homog, &
    instance, &
    me, &
    so, &
    co

   homog  = material_homogenizationAt(el)
   instance = thermal_typeInstance(homog)

  do co = 1, homogenization_Nconstituents(homog)
     ph = material_phaseAt(co,el)
     me = material_phasememberAt(co,ip,el)
     do so = 1, thermal_Nsources(ph)
       select case(thermal_source(so,ph))
         case (SOURCE_thermal_dissipation_ID)
          call source_thermal_dissipation_getRateAndItsTangent(my_Tdot, my_dTdot_dT, &
                                                               mech_S(ph,me),mech_L_p(ph,me), ph)

         case (SOURCE_thermal_externalheat_ID)
          call source_thermal_externalheat_getRateAndItsTangent(my_Tdot, my_dTdot_dT, &
                                                                ph, me)

         case default
          my_Tdot = 0.0_pReal
          my_dTdot_dT = 0.0_pReal
       end select
       Tdot = Tdot + my_Tdot
       dTdot_dT = dTdot_dT + my_dTdot_dT
     enddo
   enddo

end subroutine constitutive_thermal_getRateAndItsTangents


!--------------------------------------------------------------------------------------------------
!> @brief contains the constitutive equation for calculating the rate of change of microstructure
!--------------------------------------------------------------------------------------------------
function constitutive_thermal_collectDotState(ph,me) result(broken)

  integer, intent(in) :: ph, me
  logical :: broken

  integer :: i


  broken = .false.

  SourceLoop: do i = 1, thermal_Nsources(ph)

    if (thermal_source(i,ph) == SOURCE_thermal_externalheat_ID) &
      call source_thermal_externalheat_dotState(ph,me)

    broken = broken .or. any(IEEE_is_NaN(thermalState(ph)%p(i)%dotState(:,me)))

  enddo SourceLoop

end function constitutive_thermal_collectDotState


!--------------------------------------------------------------------------------------------------
!> @brief integrate stress, state with adaptive 1st order explicit Euler method
!> using Fixed Point Iteration to adapt the stepsize
!--------------------------------------------------------------------------------------------------
module function integrateThermalState(dt,co,ip,el) result(broken)

  real(pReal), intent(in) :: dt
  integer, intent(in) :: &
    el, &                                                                                            !< element index in element loop
    ip, &                                                                                            !< integration point index in ip loop
    co                                                                                               !< grain index in grain loop

  integer :: &
    NiterationState, &                                                                              !< number of iterations in state loop
    ph, &
    me, &
    so
  integer, dimension(maxval(thermal_Nsources)) :: &
    size_so
  real(pReal) :: &
    zeta
  real(pReal), dimension(thermal_source_maxSizeDotState) :: &
    r                                                                                               ! state residuum
  real(pReal), dimension(thermal_source_maxSizeDotState,2,maxval(thermal_Nsources)) :: source_dotState
  logical :: &
    broken, converged_


  ph = material_phaseAt(co,el)
  me = material_phaseMemberAt(co,ip,el)

  converged_ = .true.
  broken = constitutive_thermal_collectDotState(ph,me)
  if(broken) return

  do so = 1, thermal_Nsources(ph)
    size_so(so) = thermalState(ph)%p(so)%sizeDotState
    thermalState(ph)%p(so)%state(1:size_so(so),me) = thermalState(ph)%p(so)%subState0(1:size_so(so),me) &
                                                   + thermalState(ph)%p(so)%dotState (1:size_so(so),me) * dt
    source_dotState(1:size_so(so),2,so) = 0.0_pReal
  enddo

  iteration: do NiterationState = 1, num%nState

    do so = 1, thermal_Nsources(ph)
      if(nIterationState > 1) source_dotState(1:size_so(so),2,so) = source_dotState(1:size_so(so),1,so)
      source_dotState(1:size_so(so),1,so) = thermalState(ph)%p(so)%dotState(:,me)
    enddo

    broken = constitutive_thermal_collectDotState(ph,me)
    if(broken) exit iteration

    do so = 1, thermal_Nsources(ph)
      zeta = damper(thermalState(ph)%p(so)%dotState(:,me), &
                    source_dotState(1:size_so(so),1,so),&
                    source_dotState(1:size_so(so),2,so))
      thermalState(ph)%p(so)%dotState(:,me) = thermalState(ph)%p(so)%dotState(:,me) * zeta &
                                        + source_dotState(1:size_so(so),1,so)* (1.0_pReal - zeta)
      r(1:size_so(so)) = thermalState(ph)%p(so)%state    (1:size_so(so),me)  &
                       - thermalState(ph)%p(so)%subState0(1:size_so(so),me)  &
                       - thermalState(ph)%p(so)%dotState (1:size_so(so),me) * dt
      thermalState(ph)%p(so)%state(1:size_so(so),me) = thermalState(ph)%p(so)%state(1:size_so(so),me) &
                                                - r(1:size_so(so))
      converged_ = converged_  .and. converged(r(1:size_so(so)), &
                                               thermalState(ph)%p(so)%state(1:size_so(so),me), &
                                               thermalState(ph)%p(so)%atol(1:size_so(so)))
    enddo

    if(converged_) exit iteration

  enddo iteration

  broken = broken .or. .not. converged_


  contains

  !--------------------------------------------------------------------------------------------------
  !> @brief calculate the damping for correction of state and dot state
  !--------------------------------------------------------------------------------------------------
  real(pReal) pure function damper(current,previous,previous2)

  real(pReal), dimension(:), intent(in) ::&
    current, previous, previous2

  real(pReal) :: dot_prod12, dot_prod22

  dot_prod12 = dot_product(current  - previous,  previous - previous2)
  dot_prod22 = dot_product(previous - previous2, previous - previous2)
  if ((dot_product(current,previous) < 0.0_pReal .or. dot_prod12 < 0.0_pReal) .and. dot_prod22 > 0.0_pReal) then
    damper = 0.75_pReal + 0.25_pReal * tanh(2.0_pReal + 4.0_pReal * dot_prod12 / dot_prod22)
  else
    damper = 1.0_pReal
  endif

  end function damper

end function integrateThermalState



module subroutine thermal_initializeRestorationPoints(ph,me)

  integer, intent(in) :: ph, me

  integer :: so


  do so = 1, size(thermalState(ph)%p)
    thermalState(ph)%p(so)%partitionedState0(:,me) = thermalState(ph)%p(so)%state0(:,me)
  enddo

end subroutine thermal_initializeRestorationPoints



module subroutine thermal_windForward(ph,me)

  integer, intent(in) :: ph, me

  integer :: so


  do so = 1, size(thermalState(ph)%p)
    thermalState(ph)%p(so)%partitionedState0(:,me) = thermalState(ph)%p(so)%state(:,me)
  enddo

end subroutine thermal_windForward


module subroutine thermal_forward()

  integer :: ph, so


  do ph = 1, size(thermalState)
    do so = 1, size(thermalState(ph)%p)
      thermalState(ph)%p(so)%state0 = thermalState(ph)%p(so)%state
    enddo
  enddo

end subroutine thermal_forward


module subroutine thermal_restore(ip,el)

  integer, intent(in) :: ip, el

  integer :: co, ph, me, so


  do co = 1, homogenization_Nconstituents(material_homogenizationAt(el))
    ph = material_phaseAt(co,el)
    me = material_phaseMemberAt(co,ip,el)

    do so = 1, size(thermalState(ph)%p)
      thermalState(ph)%p(so)%state(:,me) = thermalState(ph)%p(so)%partitionedState0(:,me)
    enddo

  enddo

end subroutine thermal_restore


!----------------------------------------------------------------------------------------------
!< @brief Get temperature (for use by non-thermal physics)
!----------------------------------------------------------------------------------------------
module function thermal_T(ph,me) result(T)

  integer, intent(in) :: ph, me
  real(pReal) :: T


  T = current(ph)%T(me)

end function thermal_T


!----------------------------------------------------------------------------------------------
!< @brief Set temperature
!----------------------------------------------------------------------------------------------
module subroutine constitutive_thermal_setT(T,co,ip,el)

  real(pReal), intent(in) :: T
  integer, intent(in) :: co, ip, el


  current(material_phaseAt(co,el))%T(material_phaseMemberAt(co,ip,el)) = T

end subroutine constitutive_thermal_setT



!--------------------------------------------------------------------------------------------------
!> @brief checks if a source mechanism is active or not
!--------------------------------------------------------------------------------------------------
function thermal_active(source_label,src_length)  result(active_source)

  character(len=*), intent(in)         :: source_label                                              !< name of source mechanism
  integer,          intent(in)         :: src_length                                                !< max. number of sources in system
  logical, dimension(:,:), allocatable :: active_source

  class(tNode), pointer :: &
    phases, &
    phase, &
    sources, thermal, &
    src
  integer :: p,s

  phases => config_material%get('phase')
  allocate(active_source(src_length,phases%length), source = .false. )
  do p = 1, phases%length
    phase => phases%get(p)
    if (phase%contains('thermal')) then
      thermal =>  phase%get('thermal',defaultVal=emptyList)
      sources =>  thermal%get('source',defaultVal=emptyList)
      do s = 1, sources%length
        src => sources%get(s)
        if(src%get_asString('type') == source_label) active_source(s,p) = .true.
      enddo
    endif
  enddo


end function thermal_active


end submodule constitutive_thermal
