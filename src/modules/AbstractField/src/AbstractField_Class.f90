! This program is a part of EASIFEM library
! Copyright (C) 2020-2021  Vikas Sharma, Ph.D
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <https: //www.gnu.org/licenses/>
!

!> authors: Vikas Sharma, Ph. D.
! date: 16 Jul 2021
! summary: Abstract field is designed to handle fields over finite element meshes
!
!### Introduction
! - In FEM, we use variables of different ranks. These varibles will be designated as the field. These fields can be defined at:
!   - Spatial-temporal nodal points
!   - Quadrature points inside the element
! - In addition, global matrices can also be described as the field.
! - In this way, Fields are high level objects in finite element modeling.
!
! [[AbstractField_]] defines an abstract class. This class will be extended to [[AbstractNodeField_]], [[AbstractElementField_]], [[AbstractMatrixField_]].

MODULE AbstractField_Class
USE GlobalData
USE BaseType
USE FPL, ONLY: ParameterList_
USE HDF5File_Class, ONLY : HDF5File_
USE ExceptionHandler_Class, ONLY : ExceptionHandler_
USE Domain_Class
IMPLICIT NONE
PRIVATE
INTEGER( I4B ), PARAMETER, PUBLIC :: FIELD_TYPE_NORMAL = 1
INTEGER( I4B ), PARAMETER, PUBLIC :: FIELD_TYPE_CONSTANT = 2
INTEGER( I4B ), PARAMETER, PUBLIC :: FIELD_TYPE_CONSTANT_SPACE = 3
INTEGER( I4B ), PARAMETER, PUBLIC :: FIELD_TYPE_CONSTANT_TIME = 4
CHARACTER( LEN = * ), PARAMETER, PUBLIC :: FIELD_TYPE_NAME( 4 ) = &
  & [ &
      & "NORMAL        ", &
      & "CONSTANT      ", &
      & "CONSTANT_SPACE", &
      & "CONSTANT_TIME " &
  & ]

!----------------------------------------------------------------------------
!                                                           AbstractField_
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 16 Jul 2021
! summary: Abstract field is designed to handle fields over finite element meshes
!
!### Introduction
! - In FEM, we use variables of different ranks. These varibles will be designated as the field. These fields can be defined at:
!   - Spatial-temporal nodal points
!   - Quadrature points inside the element
! - In addition, global matrices can also be described as the field.
! - In this way, Fields are high level objects in finite element modeling.
!
! [[AbstractField_]] defines an abstract class. This class will be extended to [[AbstractNodeField_]], [[AbstractElementField_]], [[AbstractMatrixField_]].

TYPE, ABSTRACT :: AbstractField_
  LOGICAL( LGT ) :: isInitiated = .FALSE.
    !! It is true if the object is initiated
  INTEGER( I4B ) :: fieldType = FIELD_TYPE_NORMAL
    !! fieldType can be normal, constant, can vary in space and/ or both.
  TYPE( Domain_ ), POINTER :: domain => NULL()
    !! Domain contains the information of the finite element meshes.
  TYPE( String ) :: name
    !! name of the field
  TYPE( String ) :: engine
    !! Engine of the field, for example NATIVE_SERIAL, NATIVE_OMP,
    !! NATIVE_MPI, PETSC, LIS_SERIAL, LIS_OMP, LIS_MPI
  CONTAINS
  PRIVATE
    PROCEDURE(aField_addSurrogate), DEFERRED, PUBLIC, PASS( obj ) :: addSurrogate
      !! check essential parameters
    PROCEDURE(aField_checkEssentialParam), DEFERRED, PUBLIC, PASS( obj ) :: checkEssentialParam
      !! check essential parameters
    PROCEDURE(aField_Initiate1), DEFERRED, PUBLIC, PASS( obj ) :: Initiate1
      !! Initiate the field
    PROCEDURE(aField_Initiate2), DEFERRED, PUBLIC, PASS( obj ) :: Initiate2
      !! Initiate by copying other fields
    GENERIC, PUBLIC :: Initiate => Initiate1, Initiate2
    PROCEDURE(aField_DeallocateData), DEFERRED, PUBLIC, PASS( obj ) :: DeallocateData
      !! Deallocate the field
    PROCEDURE(aField_Display), DEFERRED, PUBLIC, PASS( obj ) :: Display
      !! Display the field
    PROCEDURE(aField_Import), DEFERRED, PUBLIC, PASS( obj ) :: Import
      !! Import data from hdf5 file
    PROCEDURE(aField_Export), DEFERRED, PUBLIC, PASS( obj ) :: Export
      !! Export data in hdf5 file
END TYPE AbstractField_

PUBLIC :: AbstractField_

!----------------------------------------------------------------------------
!                                           addSurrogate@Constructor
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 25 June 2021
! summary: This routine check the essential parameters in param.

ABSTRACT INTERFACE
SUBROUTINE aField_addSurrogate( obj, UserObj )
  IMPORT :: AbstractField_, ExceptionHandler_
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
  TYPE( ExceptionHandler_ ), INTENT( IN ) :: UserObj
END SUBROUTINE aField_addSurrogate
END INTERFACE

!----------------------------------------------------------------------------
!                                           checkEssentialParam@Constructor
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 25 June 2021
! summary: This routine check the essential parameters in param.

ABSTRACT INTERFACE
SUBROUTINE aField_checkEssentialParam( obj, param )
  IMPORT :: AbstractField_, ParameterList_
  CLASS( AbstractField_ ), INTENT( IN ) :: obj
  TYPE( ParameterList_ ), INTENT( IN ) :: param
END SUBROUTINE aField_checkEssentialParam
END INTERFACE

!----------------------------------------------------------------------------
!                                                                 Initiate
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
SUBROUTINE aField_Initiate1( obj, param, dom )
  IMPORT :: AbstractField_, ParameterList_, Domain_
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
  TYPE( ParameterList_ ), INTENT( IN ) :: param
  TYPE( Domain_ ), TARGET, INTENT( IN ) :: dom
END SUBROUTINE aField_Initiate1
END INTERFACE

!----------------------------------------------------------------------------
!                                                            InitiateByCopy
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
SUBROUTINE aField_Initiate2( obj, obj2, copyFull, copyStructure, &
  & usePointer )
  IMPORT :: AbstractField_, LGT
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj2
  LOGICAL( LGT ), OPTIONAL, INTENT( IN ) :: copyFull
  LOGICAL( LGT ), OPTIONAL, INTENT( IN ) :: copyStructure
  LOGICAL( LGT ), OPTIONAL, INTENT( IN ) :: usePointer
END SUBROUTINE aField_Initiate2
END INTERFACE

!----------------------------------------------------------------------------
!                                                                 Display
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
SUBROUTINE aField_Display( obj, msg, unitNo )
  IMPORT :: AbstractField_, I4B
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
  CHARACTER( LEN = * ), INTENT( IN ) :: msg
  INTEGER( I4B ), OPTIONAL, INTENT( IN ) :: unitNo
END SUBROUTINE aField_Display
END INTERFACE

!----------------------------------------------------------------------------
!                                                             DeallocateData
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
SUBROUTINE aField_DeallocateData( obj )
  IMPORT :: AbstractField_
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
END SUBROUTINE aField_DeallocateData
END INTERFACE

!----------------------------------------------------------------------------
!                                                                 IMPORT
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
SUBROUTINE aField_Import( obj, hdf5, group, dom )
  IMPORT :: AbstractField_, I4B, HDF5File_, Domain_
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
  TYPE( HDF5File_ ), INTENT( INOUT ) :: hdf5
  CHARACTER( LEN = * ), INTENT( IN ) :: group
  TYPE( Domain_ ), TARGET, INTENT( IN ) :: dom
END SUBROUTINE aField_Import
END INTERFACE

!----------------------------------------------------------------------------
!                                                                 Export
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
SUBROUTINE aField_Export( obj, hdf5, group )
  IMPORT :: AbstractField_, HDF5File_
  CLASS( AbstractField_ ), INTENT( INOUT ) :: obj
  TYPE( HDF5File_ ), INTENT( INOUT ) :: hdf5
  CHARACTER( LEN = * ), INTENT( IN ) :: group
END SUBROUTINE aField_Export
END INTERFACE

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END MODULE AbstractField_Class