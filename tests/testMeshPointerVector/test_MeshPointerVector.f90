
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

module test_m
use easifemBase
use easifemClasses
implicit none
contains

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

subroutine test0
  type( meshPointer_ ) :: meshptr
  type( MeshPointerVector_ ) :: list
  type( HDF5File_ ) :: meshfile

  call display( "Testing MeshPointerVector Initiate")
  call list%initiate()
  call meshfile%initiate( filename="./mesh.h5", mode="READ" )
  call meshfile%open()
  meshptr%ptr => Mesh_Pointer(meshfile=meshfile, xidim=2, id=1 )
  call list%pushback( meshptr )
  meshptr%ptr => Mesh_Pointer(meshfile=meshfile, xidim=2, id=2 )
  call list%pushback( meshptr )
  call display( list%size(), "2==")
  ! call list%display( "list after two entries = ")
  call list%DeallocateData()
  call meshfile%close()
  call meshfile%deallocateData()
  ! call obj%GenerateMeshData()
end subroutine

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

subroutine exportMesh
  TYPE( MSH_ ) :: mshFile
  CALL mshFile%initiate( file="./mesh.msh", NSD=2 )
  CALL mshFile%ExportMesh( file="./mesh.h5" )
  CALL mshFile%DeallocateData()
end


end module test_m

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

program main
use test_m
implicit none
call exportMesh
call test0
end program main