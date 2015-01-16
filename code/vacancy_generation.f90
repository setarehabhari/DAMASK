!--------------------------------------------------------------------------------------------------
! $Id$
!--------------------------------------------------------------------------------------------------
!> @author Pratheek Shanthraj, Max-Planck-Institut für Eisenforschung GmbH
!> @brief material subroutine for plastically generated vacancy concentrations
!> @details to be done
!--------------------------------------------------------------------------------------------------
module vacancy_generation
 use prec, only: &
   pReal, &
   pInt

 implicit none
 private
 integer(pInt),                       dimension(:),           allocatable,         public, protected :: &
   vacancy_generation_sizePostResults                                                           !< cumulative size of post results

 integer(pInt),                       dimension(:,:),         allocatable, target, public :: &
   vacancy_generation_sizePostResult                                                            !< size of each post result output

 character(len=64),                   dimension(:,:),         allocatable, target, public :: &
   vacancy_generation_output                                                                    !< name of each post result output
   
 integer(pInt),                       dimension(:),           allocatable, target, public :: &
   vacancy_generation_Noutput                                                                   !< number of outputs per instance of this damage 

 real(pReal),                         dimension(:),           allocatable,        private :: &
   vacancy_generation_aTol, &
   vacancy_generation_freq, &
   vacancy_generation_formationEnergy, &
   vacancy_generation_specificFormationEnergy, &
   vacancy_generation_migrationEnergy, &
   vacancy_generation_diffusionCoeff0, &                                                        !< the temperature-independent diffusion coefficient D_0
   vacancy_generation_atomicVol, &
   vacancy_generation_surfaceEnergy, &
   vacancy_generation_plasticityCoeff, &
   vacancy_generation_kBCoeff

 real(pReal),                                                 parameter,           private :: &
   kB = 1.3806488e-23_pReal                                                                          !< Boltzmann constant in J/Kelvin

 enum, bind(c) 
   enumerator :: undefined_ID, &
                 vacancy_concentration_ID
 end enum
 integer(kind(undefined_ID)),         dimension(:,:),         allocatable,          private :: & 
   vacancy_generation_outputID                                                                  !< ID of each post result output


 public :: &
   vacancy_generation_init, &
   vacancy_generation_stateInit, &
   vacancy_generation_aTolState, &
   vacancy_generation_microstructure, &
   vacancy_generation_getLocalConcentration, &
   vacancy_generation_putLocalConcentration, &
   vacancy_generation_getConcentration, &
   vacancy_generation_getVacancyDiffusion33, &
   vacancy_generation_getVacancyMobility33, &
   vacancy_generation_getVacancyEnergy, &
   vacancy_generation_postResults

contains


!--------------------------------------------------------------------------------------------------
!> @brief module initialization
!> @details reads in material parameters, allocates arrays, and does sanity checks
!--------------------------------------------------------------------------------------------------
subroutine vacancy_generation_init(fileUnit)
 use, intrinsic :: iso_fortran_env                                                                  ! to get compiler_version and compiler_options (at least for gfortran 4.6 at the moment)
 use debug, only: &
   debug_level,&
   debug_constitutive,&
   debug_levelBasic
 use mesh, only: &
   mesh_maxNips, &
   mesh_NcpElems
 use IO, only: &
   IO_read, &
   IO_lc, &
   IO_getTag, &
   IO_isBlank, &
   IO_stringPos, &
   IO_stringValue, &
   IO_floatValue, &
   IO_intValue, &
   IO_warning, &
   IO_error, &
   IO_timeStamp, &
   IO_EOF
 use material, only: &
   homogenization_maxNgrains, &
   phase_vacancy, &
   phase_vacancyInstance, &
   phase_Noutput, &
   LOCAL_VACANCY_GENERATION_label, &
   LOCAL_VACANCY_generation_ID, &
   material_phase, &  
   vacancyState, &
   MATERIAL_partPhase
 use numerics,only: &
   worldrank, &
   numerics_integrator

 implicit none
 integer(pInt), intent(in) :: fileUnit

 integer(pInt), parameter :: MAXNCHUNKS = 7_pInt
 integer(pInt), dimension(1+2*MAXNCHUNKS) :: positions
 integer(pInt) :: maxNinstance,mySize=0_pInt,phase,instance,o
 integer(pInt) :: sizeState, sizeDotState
 integer(pInt) :: NofMyPhase   
 character(len=65536) :: &
   tag  = '', &
   line = ''

 mainProcess: if (worldrank == 0) then 
   write(6,'(/,a)')   ' <<<+-  vacancy_'//LOCAL_VACANCY_GENERATION_label//' init  -+>>>'
   write(6,'(a)')     ' $Id$'
   write(6,'(a15,a)') ' Current time: ',IO_timeStamp()
#include "compilation_info.f90"
 endif mainProcess
 
 maxNinstance = int(count(phase_vacancy == LOCAL_VACANCY_generation_ID),pInt)
 if (maxNinstance == 0_pInt) return
 if (iand(debug_level(debug_constitutive),debug_levelBasic) /= 0_pInt) &
   write(6,'(a16,1x,i5,/)') '# instances:',maxNinstance
 
 allocate(vacancy_generation_sizePostResults(maxNinstance),                     source=0_pInt)
 allocate(vacancy_generation_sizePostResult(maxval(phase_Noutput),maxNinstance),source=0_pInt)
 allocate(vacancy_generation_output(maxval(phase_Noutput),maxNinstance))
          vacancy_generation_output = ''
 allocate(vacancy_generation_outputID(maxval(phase_Noutput),maxNinstance),      source=undefined_ID)
 allocate(vacancy_generation_Noutput(maxNinstance),                             source=0_pInt) 
 allocate(vacancy_generation_aTol(maxNinstance),                                source=0.0_pReal) 
 allocate(vacancy_generation_freq(maxNinstance),                                source=0.0_pReal) 
 allocate(vacancy_generation_formationEnergy(maxNinstance),                     source=0.0_pReal) 
 allocate(vacancy_generation_specificFormationEnergy(maxNinstance),             source=0.0_pReal) 
 allocate(vacancy_generation_migrationEnergy(maxNinstance),                     source=0.0_pReal) 
 allocate(vacancy_generation_diffusionCoeff0(maxNinstance),                     source=0.0_pReal) 
 allocate(vacancy_generation_atomicVol(maxNinstance),                           source=0.0_pReal) 
 allocate(vacancy_generation_surfaceEnergy(maxNinstance),                       source=0.0_pReal)
 allocate(vacancy_generation_plasticityCoeff(maxNinstance),                     source=0.0_pReal)
 allocate(vacancy_generation_kBCoeff(maxNinstance),                             source=0.0_pReal)

 rewind(fileUnit)
 phase = 0_pInt
 do while (trim(line) /= IO_EOF .and. IO_lc(IO_getTag(line,'<','>')) /= MATERIAL_partPhase)         ! wind forward to <phase>
   line = IO_read(fileUnit)
 enddo
 
 parsingFile: do while (trim(line) /= IO_EOF)                                                       ! read through sections of phase part
   line = IO_read(fileUnit)
   if (IO_isBlank(line)) cycle                                                                      ! skip empty lines
   if (IO_getTag(line,'<','>') /= '') then                                                          ! stop at next part
     line = IO_read(fileUnit, .true.)                                                               ! reset IO_read
     exit                                                                                           
   endif   
   if (IO_getTag(line,'[',']') /= '') then                                                          ! next phase section
     phase = phase + 1_pInt                                                                         ! advance phase section counter
     cycle                                                                                          ! skip to next line
   endif

   if (phase > 0_pInt ) then; if (phase_vacancy(phase) == LOCAL_VACANCY_generation_ID) then               ! do not short-circuit here (.and. with next if statemen). It's not safe in Fortran

     instance = phase_vacancyInstance(phase)                                                     ! which instance of my vacancy is present phase
     positions = IO_stringPos(line,MAXNCHUNKS)
     tag = IO_lc(IO_stringValue(line,positions,1_pInt))                                             ! extract key
     select case(tag)
       case ('(output)')
         select case(IO_lc(IO_stringValue(line,positions,2_pInt)))
           case ('vacancy_concentration')
             vacancy_generation_Noutput(instance) = vacancy_generation_Noutput(instance) + 1_pInt
             vacancy_generation_outputID(vacancy_generation_Noutput(instance),instance) = vacancy_concentration_ID
             vacancy_generation_output(vacancy_generation_Noutput(instance),instance) = &
                                                       IO_lc(IO_stringValue(line,positions,2_pInt))
          end select

       case ('atolvacancygeneration')
         vacancy_generation_aTol(instance) = IO_floatValue(line,positions,2_pInt)

       case ('vacancyformationfreq')
         vacancy_generation_freq(instance) = IO_floatValue(line,positions,2_pInt)

       case ('vacancyformationenergy')
         vacancy_generation_formationEnergy(instance) = IO_floatValue(line,positions,2_pInt)

       case ('vacancymigrationenergy')
         vacancy_generation_migrationEnergy(instance) = IO_floatValue(line,positions,2_pInt)

       case ('vacancydiffusioncoeff0')
         vacancy_generation_diffusionCoeff0(instance) = IO_floatValue(line,positions,2_pInt)

       case ('atomicvolume')
         vacancy_generation_atomicVol(instance) = IO_floatValue(line,positions,2_pInt)
         
       case ('surfaceenergy')
         vacancy_generation_surfaceEnergy(instance) = IO_floatValue(line,positions,2_pInt)

       case ('vacancyplasticitycoeff')
         vacancy_generation_plasticityCoeff(instance) = IO_floatValue(line,positions,2_pInt)

     end select
   endif; endif
 enddo parsingFile
 
 initializeInstances: do phase = 1_pInt, size(phase_vacancy)
   if (phase_vacancy(phase) == LOCAL_VACANCY_generation_ID) then
     NofMyPhase=count(material_phase==phase)
     instance = phase_vacancyInstance(phase)

!--------------------------------------------------------------------------------------------------
!  pre-calculating derived material parameters
     vacancy_generation_kBCoeff(instance) = kB/vacancy_generation_atomicVol(instance)
     vacancy_generation_specificFormationEnergy(instance) = &
       vacancy_generation_formationEnergy(instance)/vacancy_generation_atomicVol(instance)
     
!--------------------------------------------------------------------------------------------------
!  Determine size of postResults array
     outputsLoop: do o = 1_pInt,vacancy_generation_Noutput(instance)
       select case(vacancy_generation_outputID(o,instance))
         case(vacancy_concentration_ID)
           mySize = 1_pInt
       end select
 
       if (mySize > 0_pInt) then  ! any meaningful output found
          vacancy_generation_sizePostResult(o,instance) = mySize
          vacancy_generation_sizePostResults(instance)  = vacancy_generation_sizePostResults(instance) + mySize
       endif
     enddo outputsLoop
! Determine size of state array
     sizeDotState              =   0_pInt
     sizeState                 =   1_pInt
     vacancyState(phase)%sizeState =       sizeState
     vacancyState(phase)%sizeDotState =    sizeDotState
     vacancyState(phase)%sizePostResults = vacancy_generation_sizePostResults(instance)
     allocate(vacancyState(phase)%aTolState           (sizeState),                source=0.0_pReal)
     allocate(vacancyState(phase)%state0              (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(vacancyState(phase)%partionedState0     (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(vacancyState(phase)%subState0           (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(vacancyState(phase)%state               (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(vacancyState(phase)%state_backup        (sizeState,NofMyPhase),     source=0.0_pReal)

     allocate(vacancyState(phase)%dotState            (sizeDotState,NofMyPhase),  source=0.0_pReal)
     allocate(vacancyState(phase)%deltaState          (sizeDotState,NofMyPhase),  source=0.0_pReal)
     allocate(vacancyState(phase)%dotState_backup     (sizeDotState,NofMyPhase),  source=0.0_pReal)
     if (any(numerics_integrator == 1_pInt)) then
       allocate(vacancyState(phase)%previousDotState  (sizeDotState,NofMyPhase),  source=0.0_pReal)
       allocate(vacancyState(phase)%previousDotState2 (sizeDotState,NofMyPhase),  source=0.0_pReal)
     endif
     if (any(numerics_integrator == 4_pInt)) &
       allocate(vacancyState(phase)%RK4dotState       (sizeDotState,NofMyPhase),  source=0.0_pReal)
     if (any(numerics_integrator == 5_pInt)) &
       allocate(vacancyState(phase)%RKCK45dotState    (6,sizeDotState,NofMyPhase),source=0.0_pReal)      

     call vacancy_generation_stateInit(phase)
     call vacancy_generation_aTolState(phase,instance)
   endif
 
 enddo initializeInstances
end subroutine vacancy_generation_init

!--------------------------------------------------------------------------------------------------
!> @brief sets the relevant  NEW state values for a given instance of this vacancy model
!--------------------------------------------------------------------------------------------------
subroutine vacancy_generation_stateInit(phase)
 use material, only: &
   vacancyState
 use lattice, only: &
  lattice_equilibriumVacancyConcentration
 
 implicit none
 integer(pInt), intent(in) :: phase                                                    !< number specifying the phase of the vacancy
 real(pReal), dimension(vacancyState(phase)%sizeState) :: tempState

 tempState(1) = lattice_equilibriumVacancyConcentration(phase)
 vacancyState(phase)%state0 = spread(tempState,2,size(vacancyState(phase)%state(1,:)))

end subroutine vacancy_generation_stateInit

!--------------------------------------------------------------------------------------------------
!> @brief sets the relevant state values for a given instance of this vacancy model
!--------------------------------------------------------------------------------------------------
subroutine vacancy_generation_aTolState(phase,instance)
 use material, only: &
  vacancyState

 implicit none
 integer(pInt), intent(in) ::  &
   phase, &
   instance                                                                                         ! number specifying the current instance of the vacancy
 real(pReal), dimension(vacancyState(phase)%sizeState) :: tempTol

 tempTol = vacancy_generation_aTol(instance)
 vacancyState(phase)%aTolState = tempTol
end subroutine vacancy_generation_aTolState
 
!--------------------------------------------------------------------------------------------------
!> @brief calculates derived quantities from state
!--------------------------------------------------------------------------------------------------
subroutine vacancy_generation_microstructure(Tstar_v, temperature, damage, subdt, &
                                             ipc, ip, el)
 use material, only: &
   mappingConstitutive, &
   phase_vacancyInstance, &
   plasticState, &
   vacancyState
 use math, only : &
   math_Mandel6to33, &
   math_trace33

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< component-ID of integration point
   ip, &                                                                                            !< integration point
   el                                                                                               !< element
 real(pReal), intent(in) :: &
   Tstar_v(6), &
   temperature, &                                                                                   !< 2nd Piola Kirchhoff stress tensor (Mandel)
   damage, &
   subdt
 real(pReal) :: &
   pressure, &
   stressBarrier
 integer(pInt) :: &
   instance, phase, constituent 

 phase = mappingConstitutive(2,ipc,ip,el)
 constituent = mappingConstitutive(1,ipc,ip,el)
 instance = phase_vacancyInstance(phase)

 pressure = math_trace33(math_Mandel6to33(Tstar_v))/3.0_pReal
 stressBarrier = max(0.0_pReal, &
                     vacancy_generation_specificFormationEnergy(instance) - &
                     pressure - &
                     vacancy_generation_plasticityCoeff(instance)* &
                     sum(plasticState(phase)%accumulatedSlip(:,constituent))) 

 vacancyState(phase)%state(1,constituent) = &
   vacancyState(phase)%subState0(1,constituent) + &
   subdt* &
   damage*damage* &
   vacancy_generation_freq(instance)* &
   exp(-stressBarrier/(vacancy_generation_kBCoeff(instance)*temperature))

end subroutine vacancy_generation_microstructure

!--------------------------------------------------------------------------------------------------
!> @brief returns vacancy concentration based on state layout 
!--------------------------------------------------------------------------------------------------
function vacancy_generation_getLocalConcentration(ipc, ip, el)
 use material, only: &
   mappingConstitutive, &
   vacancyState

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 real(pReal) :: vacancy_generation_getLocalConcentration
 
 vacancy_generation_getLocalConcentration = &
   vacancyState(mappingConstitutive(2,ipc,ip,el))%state(1,mappingConstitutive(1,ipc,ip,el))
 
end function vacancy_generation_getLocalConcentration
 
!--------------------------------------------------------------------------------------------------
!> @brief returns temperature based on local damage model state layout 
!--------------------------------------------------------------------------------------------------
subroutine vacancy_generation_putLocalConcentration(ipc, ip, el, localVacancyConcentration)
 use material, only: &
   mappingConstitutive, &
   vacancyState

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 real(pReal),   intent(in) :: &
   localVacancyConcentration
 
 vacancyState(mappingConstitutive(2,ipc,ip,el))%state(1,mappingConstitutive(1,ipc,ip,el))= &
   localVacancyConcentration
 
end subroutine vacancy_generation_putLocalConcentration
 
!--------------------------------------------------------------------------------------------------
!> @brief returns vacancy concentration based on state layout 
!--------------------------------------------------------------------------------------------------
function vacancy_generation_getConcentration(ipc, ip, el)
 use material, only: &
   mappingHomogenization, &
   material_phase, &
   fieldVacancy, &
   field_vacancy_type, &
   FIELD_VACANCY_local_ID, &
   FIELD_VACANCY_nonlocal_ID, &
   material_homog

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 real(pReal) :: vacancy_generation_getConcentration
 
 select case(field_vacancy_type(material_homog(ip,el)))                                                   
   case (FIELD_VACANCY_local_ID)
    vacancy_generation_getConcentration = vacancy_generation_getLocalConcentration(ipc, ip, el)      
    
   case (FIELD_VACANCY_nonlocal_ID)
    vacancy_generation_getConcentration = fieldVacancy(material_homog(ip,el))% &
      field(1,mappingHomogenization(1,ip,el))                                                     ! Taylor type 
 end select

end function vacancy_generation_getConcentration
 
!--------------------------------------------------------------------------------------------------
!> @brief returns generation vacancy diffusion tensor 
!--------------------------------------------------------------------------------------------------
function vacancy_generation_getVacancyDiffusion33(ipc,ip,el)
 use lattice, only: &
   lattice_VacancyDiffusion33
 use material, only: &
   mappingConstitutive

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 real(pReal), dimension(3,3) :: &
   vacancy_generation_getVacancyDiffusion33
 
 vacancy_generation_getVacancyDiffusion33 = &
   lattice_VacancyDiffusion33(1:3,1:3,mappingConstitutive(2,ipc,ip,el))
    
end function vacancy_generation_getVacancyDiffusion33

!--------------------------------------------------------------------------------------------------
!> @brief returns generation vacancy mobility tensor 
!--------------------------------------------------------------------------------------------------
function vacancy_generation_getVacancyMobility33(temperature,ipc,ip,el)
 use math, only: &
   math_I3
 use material, only: &
   mappingConstitutive, &
   phase_vacancyInstance, &
   plasticState

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 real(pReal), dimension(3,3) :: &
   vacancy_generation_getVacancyMobility33
 real(pReal) :: &
   temperature
 integer(pInt) :: &
   phase, constituent, instance
 
 phase = mappingConstitutive(2,ipc,ip,el)
 constituent = mappingConstitutive(1,ipc,ip,el)
 instance = phase_vacancyInstance(phase)

 vacancy_generation_getVacancyMobility33 = &
   math_I3*(1.0_pReal + sum(plasticState(phase)%accumulatedSlip(:,constituent)))
       
end function vacancy_generation_getVacancyMobility33

!--------------------------------------------------------------------------------------------------
!> @brief returns generation vacancy mobility tensor 
!--------------------------------------------------------------------------------------------------
real(pReal) function vacancy_generation_getVacancyEnergy(ipc,ip,el)
 use material, only: &
   mappingConstitutive, &
   phase_vacancyInstance

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 integer(pInt) :: &
   instance
   
 instance = phase_vacancyInstance(mappingConstitutive(2,ipc,ip,el))   
 vacancy_generation_getVacancyEnergy = &
   vacancy_generation_specificFormationEnergy(instance)/vacancy_generation_surfaceEnergy(instance)
    
end function vacancy_generation_getVacancyEnergy

!--------------------------------------------------------------------------------------------------
!> @brief return array of constitutive results
!--------------------------------------------------------------------------------------------------
function vacancy_generation_postResults(ipc,ip,el)
 use material, only: &
   mappingConstitutive, &
   phase_vacancyInstance, &
   vacancyState

 implicit none
 integer(pInt),              intent(in) :: &
   ipc, &                                                                                           !< component-ID of integration point
   ip, &                                                                                            !< integration point
   el                                                                                               !< element
 real(pReal), dimension(vacancy_generation_sizePostResults(phase_vacancyInstance(mappingConstitutive(2,ipc,ip,el)))) :: &
   vacancy_generation_postResults

 integer(pInt) :: &
   instance, phase, constituent, o, c
   
 phase = mappingConstitutive(2,ipc,ip,el)
 constituent = mappingConstitutive(1,ipc,ip,el)
 instance  = phase_vacancyInstance(phase)

 c = 0_pInt
 vacancy_generation_postResults = 0.0_pReal

 do o = 1_pInt,vacancy_generation_Noutput(instance)
    select case(vacancy_generation_outputID(o,instance))
 
      case (vacancy_concentration_ID)
        vacancy_generation_postResults(c+1_pInt) = vacancyState(phase)%state(1,constituent)
        c = c + 1
    end select
 enddo
end function vacancy_generation_postResults

end module vacancy_generation
