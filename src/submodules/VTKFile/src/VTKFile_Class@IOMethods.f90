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

SUBMODULE( VTKFile_Class ) IOMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteRootTag
  CHARACTER( LEN = * ), PARAMETER :: myName="VTKFile_WriteRootTag"
  TYPE( String ) :: buffer
  CHARACTER( LEN = 100 ) :: ioerrmsg
  INTEGER( I4B ) :: ierr

  IF( .NOT. obj%isInitiated ) THEN
    CALL e%raiseError(modName//'::'//myName// &
      & ' - VTKFile is not initiated!')
  END IF

  IF( .NOT. obj%isOpen() ) THEN
    CALL e%raiseError(modName//'::'//myName// &
      & ' - VTKFile is not open')
  END IF

  IF( .NOT. obj%isWrite() ) THEN
    CALL e%raiseError(modName//'::'//myName// &
      & ' - VTKFile does not have write permission')
  END IF

  buffer = '<?xml version="1.0" encoding="UTF-8"?>'//CHAR_LF

  IF (endian .EQ. endianL) THEN
    buffer = buffer//'<VTKFile type="'//trim(obj%DataStructureName)//'" version="1.0" byte_order="LittleEndian">'
  ELSE
    buffer = buffer//'<VTKFile type="'//trim(obj%DataStructureName)//'" version="1.0" byte_order="BigEndian">'
  END IF

  WRITE( obj%unitNo, "(a)", iostat=ierr, iomsg=ioerrmsg ) trim( buffer%chars() ) // CHAR_LF
  obj%indent = 2

  IF( ierr .NE. 0 ) THEN
    CALL e%raiseError(modName//'::'//myName// &
      & ' - Error has occured while writing header info in VTKFile &
      & iostat = ' // trim(str(ierr, .true.)) // ' error msg :: ' // &
      & TRIM( ioerrmsg ) )
  END IF
END PROCEDURE VTKFile_WriteRootTag

!----------------------------------------------------------------------------
!                                                      WriteDataStructureTag
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteDataStructureTag
  CHARACTER( LEN = * ), PARAMETER :: myName = "VTKFile_WriteDataStructureTag"
  INTEGER( I4B ) :: tattr
  TYPE( String ) :: attrNames( 4 ), attrValues( 4 )

  !> main
  SELECT CASE( obj%DataStructureType )
  CASE(VTK_RectilinearGrid, VTK_StructuredGrid )
    attrNames( 1 ) = "WholeExtent"
    attrValues( 1 ) = &
      & '"' // &
      & str( obj%WholeExtent( 1 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 2 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 3 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 4 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 5 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 6 ), .TRUE. )  // &
      & '"'
    tattr = 1
  !>
  CASE( PARALLEL_VTK_RectilinearGrid, PARALLEL_VTK_StructuredGrid  )
    attrNames( 1 ) = "WholeExtent"
    attrValues( 1 ) = &
      & '"' // &
      & str( obj%WholeExtent( 1 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 2 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 3 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 4 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 5 ), .TRUE. )  // CHAR_SPACE // &
      & str( obj%WholeExtent( 6 ), .TRUE. )  // &
      & '"'
    tattr = 1
    !>
    attrNames( 2 ) = "GhostLevel"
    attrValues( 2 ) = '"#"'
    tattr = 2
  !>
  CASE( PARALLEL_VTK_UnstructuredGrid )
    attrNames( 1 ) = "GhostLevel"
    attrValues( 1 ) = '"#"'
    tattr = 1
  END SELECT
  !>
  CALL obj%writeStartTag( name=String(obj%DataStructureName), &
    & attrNames=attrNames(1:tattr), attrValues=attrValues(1:tattr) )

  ! parallel topologies peculiars
  SELECT CASE( obj%DataStructureType )
  CASE( PARALLEL_VTK_RectilinearGrid )
    CALL e%raiseError(modName//'::'//myName// &
      & ' - Parallel VTKFile is currently unavaialable, see &
      & https://github.com/szaghi/VTKFortran/blob/master/src/lib/&
      & vtk_fortran_vtk_file_xml_writer_abstract.f90 for implementation' )
  CASE ( PARALLEL_VTK_StructuredGrid, PARALLEL_VTK_UnstructuredGrid )
    CALL e%raiseError(modName//'::'//myName// &
      & ' - Parallel VTKFile is currently unavaialable, see &
      & https://github.com/szaghi/VTKFortran/blob/master/src/lib/&
      & vtk_fortran_vtk_file_xml_writer_abstract.f90 for implementation' )
  END SELECT
END PROCEDURE VTKFile_WriteDataStructureTag

!----------------------------------------------------------------------------
!                                                             WriteStartTag
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteStartTag
  TYPE( XMLTag_ ) :: tag
  CALL tag%set( name=name, attrNames=attrNames, attrValues=attrValues, &
    & Indent=obj%Indent )
  CALL tag%write( unitNo=obj%unitNo, isIndented=.TRUE., endRecord= CHAR_LF, &
    & onlyStart = .TRUE. )
  obj%Indent = obj%Indent + 2
  CALL tag%DeallocateData()
END PROCEDURE VTKFile_WriteStartTag

!----------------------------------------------------------------------------
!                                                              WriteEndTag
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteEndTag
  TYPE( XMLTag_ ) :: tag
  CALL tag%set( name=name, indent=obj%indent)
  CALL tag%write(unitNo=obj%unitNo, isIndented=.TRUE., endRecord=CHAR_LF, &
    & onlyEnd=.TRUE. )
  CALL tag%DeallocateData()
END PROCEDURE VTKFile_WriteEndTag

!----------------------------------------------------------------------------
!                                                       WriteSelfClosingTag
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteSelfClosingTag
  TYPE( XMLTag_ ) :: tag
  CALL tag%set( name=name, attrNames=attrNames, attrValues=attrValues, &
    & indent=obj%Indent, isSelfClosing=.TRUE. )
  CALL tag%write(unitNo=obj%unitNo, isIndented=.TRUE., endRecord=CHAR_LF)
  CALL tag%DeallocateData()
END PROCEDURE VTKFile_WriteSelfClosingTag

!----------------------------------------------------------------------------
!                                                                   WriteTag
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteTag
  TYPE( XMLTag_ ) :: tag
  CALL tag%set( name=name, attrNames=attrNames, attrValues=attrValues, &
    & content=content, Indent=obj%Indent )
  CALL tag%write(unitNo=obj%unitNo, isIndented=.TRUE., &
    & isContentIndented=.TRUE., endRecord=CHAR_LF )
  CALL tag%DeallocateData()
END PROCEDURE VTKFile_WriteTag

END SUBMODULE IOMethods