!--------------------------------------------------------------------------------------------------
! $Id$
!--------------------------------------------------------------------------------------------------
!> @author Pratheek Shanthraj, Max-Planck-Institut für Eisenforschung GmbH
!> @brief material subroutine for vacancy generation due to thermal fluctuations
!> @details to be done
!--------------------------------------------------------------------------------------------------
module source_vacancy_thermalfluc
 use prec, only: &
   pReal, &
   pInt

 implicit none
 private
 integer(pInt),                       dimension(:),           allocatable,         public, protected :: &
   source_vacancy_thermalfluc_sizePostResults, &                                                        !< cumulative size of post results
   source_vacancy_thermalfluc_offset, &                                                                 !< which source is my current damage mechanism?
   source_vacancy_thermalfluc_instance                                                                  !< instance of damage source mechanism

 integer(pInt),                       dimension(:,:),         allocatable, target, public :: &
   source_vacancy_thermalfluc_sizePostResult                                                            !< size of each post result output

 character(len=64),                   dimension(:,:),         allocatable, target, public :: &
   source_vacancy_thermalfluc_output                                                                    !< name of each post result output
   
 integer(pInt),                       dimension(:),           allocatable, target, public :: &
   source_vacancy_thermalfluc_Noutput                                                                   !< number of outputs per instance of this damage 

 real(pReal),                         dimension(:),           allocatable,        private :: &
   source_vacancy_thermalfluc_amplitude

 public :: &
   source_vacancy_thermalfluc_init, &
   source_vacancy_thermalfluc_deltaState, &
   source_vacancy_thermalfluc_getRateAndItsTangent

contains


!--------------------------------------------------------------------------------------------------
!> @brief module initialization
!> @details reads in material parameters, allocates arrays, and does sanity checks
!--------------------------------------------------------------------------------------------------
subroutine source_vacancy_thermalfluc_init(fileUnit)
 use, intrinsic :: iso_fortran_env                                                                  ! to get compiler_version and compiler_options (at least for gfortran 4.6 at the moment)
 use debug, only: &
   debug_level,&
   debug_constitutive,&
   debug_levelBasic
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
   phase_source, &
   phase_Nsources, &
   phase_Noutput, &
   SOURCE_vacancy_thermalfluc_label, &
   SOURCE_vacancy_thermalfluc_ID, &
   material_Nphase, &
   material_phase, &  
   sourceState, &
   MATERIAL_partPhase
 use numerics,only: &
   worldrank, &
   numerics_integrator

 implicit none
 integer(pInt), intent(in) :: fileUnit

 integer(pInt), parameter :: MAXNCHUNKS = 7_pInt
 integer(pInt), dimension(1+2*MAXNCHUNKS) :: positions
 integer(pInt) :: maxNinstance,phase,instance,source,sourceOffset
 integer(pInt) :: sizeState, sizeDotState
 integer(pInt) :: NofMyPhase   
 character(len=65536) :: &
   tag  = '', &
   line = ''

 mainProcess: if (worldrank == 0) then 
   write(6,'(/,a)')   ' <<<+-  source_'//SOURCE_vacancy_thermalfluc_label//' init  -+>>>'
   write(6,'(a)')     ' $Id$'
   write(6,'(a15,a)') ' Current time: ',IO_timeStamp()
#include "compilation_info.f90"
 endif mainProcess
 
 maxNinstance = int(count(phase_source == SOURCE_vacancy_thermalfluc_ID),pInt)
 if (maxNinstance == 0_pInt) return
 if (iand(debug_level(debug_constitutive),debug_levelBasic) /= 0_pInt) &
   write(6,'(a16,1x,i5,/)') '# instances:',maxNinstance
 
 allocate(source_vacancy_thermalfluc_offset(material_Nphase), source=0_pInt)
 allocate(source_vacancy_thermalfluc_instance(material_Nphase), source=0_pInt)
 do phase = 1, material_Nphase
   source_vacancy_thermalfluc_instance(phase) = count(phase_source(:,1:phase) == source_vacancy_thermalfluc_ID)
   do source = 1, phase_Nsources(phase)
     if (phase_source(source,phase) == source_vacancy_thermalfluc_ID) &
       source_vacancy_thermalfluc_offset(phase) = source
   enddo    
 enddo
   
 allocate(source_vacancy_thermalfluc_sizePostResults(maxNinstance),                     source=0_pInt)
 allocate(source_vacancy_thermalfluc_sizePostResult(maxval(phase_Noutput),maxNinstance),source=0_pInt)
 allocate(source_vacancy_thermalfluc_output(maxval(phase_Noutput),maxNinstance))
          source_vacancy_thermalfluc_output = ''
 allocate(source_vacancy_thermalfluc_Noutput(maxNinstance),                             source=0_pInt) 
 allocate(source_vacancy_thermalfluc_amplitude(maxNinstance),                           source=0.0_pReal) 

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

   if (phase > 0_pInt ) then; if (any(phase_source(:,phase) == SOURCE_vacancy_thermalfluc_ID)) then ! do not short-circuit here (.and. with next if statemen). It's not safe in Fortran

     instance = source_vacancy_thermalfluc_instance(phase)                                          ! which instance of my vacancy is present phase
     positions = IO_stringPos(line,MAXNCHUNKS)
     tag = IO_lc(IO_stringValue(line,positions,1_pInt))                                             ! extract key
     select case(tag)
       case ('thermalfluctuation_amplitude')
         source_vacancy_thermalfluc_amplitude(instance) = IO_floatValue(line,positions,2_pInt)

     end select
   endif; endif
 enddo parsingFile
 
 initializeInstances: do phase = 1_pInt, material_Nphase
   if (any(phase_source(:,phase) == SOURCE_vacancy_thermalfluc_ID)) then
     NofMyPhase=count(material_phase==phase)
     instance = source_vacancy_thermalfluc_instance(phase)
     sourceOffset = source_vacancy_thermalfluc_offset(phase)

     sizeDotState              =   1_pInt
     sizeState                 =   1_pInt
     sourceState(phase)%p(sourceOffset)%sizeState =       sizeState
     sourceState(phase)%p(sourceOffset)%sizeDotState =    sizeDotState
     sourceState(phase)%p(sourceOffset)%sizePostResults = source_vacancy_thermalfluc_sizePostResults(instance)
     allocate(sourceState(phase)%p(sourceOffset)%aTolState           (sizeState),                source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%state0              (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%partionedState0     (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%subState0           (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%state               (sizeState,NofMyPhase),     source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%state_backup        (sizeState,NofMyPhase),     source=0.0_pReal)

     allocate(sourceState(phase)%p(sourceOffset)%dotState            (sizeDotState,NofMyPhase),  source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%deltaState          (sizeDotState,NofMyPhase),  source=0.0_pReal)
     allocate(sourceState(phase)%p(sourceOffset)%dotState_backup     (sizeDotState,NofMyPhase),  source=0.0_pReal)
     if (any(numerics_integrator == 1_pInt)) then
       allocate(sourceState(phase)%p(sourceOffset)%previousDotState  (sizeDotState,NofMyPhase),  source=0.0_pReal)
       allocate(sourceState(phase)%p(sourceOffset)%previousDotState2 (sizeDotState,NofMyPhase),  source=0.0_pReal)
     endif
     if (any(numerics_integrator == 4_pInt)) &
       allocate(sourceState(phase)%p(sourceOffset)%RK4dotState       (sizeDotState,NofMyPhase),  source=0.0_pReal)
     if (any(numerics_integrator == 5_pInt)) &
       allocate(sourceState(phase)%p(sourceOffset)%RKCK45dotState    (6,sizeDotState,NofMyPhase),source=0.0_pReal)      

   endif
 
 enddo initializeInstances
end subroutine source_vacancy_thermalfluc_init

!--------------------------------------------------------------------------------------------------
!> @brief calculates derived quantities from state
!--------------------------------------------------------------------------------------------------
subroutine source_vacancy_thermalfluc_deltaState(ipc, ip, el)
 use material, only: &
   mappingConstitutive, &
   sourceState

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< component-ID of integration point
   ip, &                                                                                            !< integration point
   el                                                                                               !< element
 integer(pInt) :: &
   phase, constituent, sourceOffset 
 real(pReal) :: &
   randNo   

 phase       = mappingConstitutive(2,ipc,ip,el)
 constituent = mappingConstitutive(1,ipc,ip,el)
 sourceOffset = source_vacancy_thermalfluc_offset(phase)

 call random_number(randNo)
 sourceState(phase)%p(sourceOffset)%deltaState(1,constituent) = &
   randNo - sourceState(phase)%p(sourceOffset)%state(1,constituent)

end subroutine source_vacancy_thermalfluc_deltaState

!--------------------------------------------------------------------------------------------------
!> @brief returns local vacancy generation rate 
!--------------------------------------------------------------------------------------------------
subroutine source_vacancy_thermalfluc_getRateAndItsTangent(CvDot, dCvDot_dCv, ipc, ip, el)
 use material, only: &
   mappingConstitutive, &
   sourceState

 implicit none
 integer(pInt), intent(in) :: &
   ipc, &                                                                                           !< grain number
   ip, &                                                                                            !< integration point number
   el                                                                                               !< element number
 real(pReal), intent(out) :: &
   CvDot, dCvDot_dCv
 integer(pInt) :: &
   instance, phase, constituent, sourceOffset 

 phase = mappingConstitutive(2,ipc,ip,el)
 constituent = mappingConstitutive(1,ipc,ip,el)
 instance = source_vacancy_thermalfluc_instance(phase)
 sourceOffset = source_vacancy_thermalfluc_offset(phase)
 
 CvDot = source_vacancy_thermalfluc_amplitude(instance)*(sourceState(phase)%p(sourceOffset)%state0(2,constituent) - 0.5_pReal)
 dCvDot_dCv = 0.0_pReal
 
end subroutine source_vacancy_thermalfluc_getRateAndItsTangent
 
end module source_vacancy_thermalfluc
